#! /usr/bin/bash
#Created on: Mar 26, 2016
#Author: Cecil Wang (cecilwang@126.com)

set -o errexit
#set -xv

declare -A URLlist
declare -a URLnotused
declare -i URLtotal=0
declare -i URLindex=0
declare -i FindPage=0

#增加一个候选URL
function addURL()
{
  let URLlist[${URL}]+=1
  if [ ${URLlist[${URL}]} -eq 1 ]
  then
    let URLtotal+=1
    URLnotused[${URLtotal}]=$URL
  fi
}

#取出一个候选URL
function getURL()
{
  let URLindex+=1;
  URL=${URLnotused[${URLindex}]}
  #URLnotused=("${URLnotused[@]:1}")
}

#在网页中寻找候选URL
function searchURL()
{
  #提取href超链接，每个处理后的链接以"结尾， 使用perl正则表达式以支持懒惰模式
  local allURL=$(echo ${PageContent} | grep -oP 'href="\K.+?"')

  #将链接结尾的"替换为换行方便处理
  for i in `echo "${allURL}" | sed 's/"/\n/g'`
  do
    #补全缺省的URL
    tmp=$(echo $i | sed 's/^\/\//https:\/\//' |
          sed 's/^\/wiki/https:\/\/en.wikipedia.org\/wiki/')

    #过滤不可识别的URL
    if [[ ${tmp} == https://* ]]
    then
      URL=${tmp}
      addURL
    fi
  done
}

#获取网页内容
function getPage()
{
  #屏蔽wget的输出，并将网页内容输出到标准输出
  PageContent=$(wget ${URL} -O- 2>/dev/null)

  #过滤非html文件
  if [[ ${PageContent} != \<!DOCTYPE\ html\>* ]]
  then
    echo "${URL} is not a html file"
    return 0
  fi
  echo ${URL}
  let FindPage+=1
  searchURL

  #过滤标签，将所有网页组织到一个文件中，免除awk的结果合并问题
  echo ${PageContent} | awk '{
    gsub(/<script>[^<]*<\/script>/, " ")
    gsub(/<style>[^<]*<\/style>/, " ")
    gsub(/<[^>]*>/, " ")
    printf ("%s ", $0)
  }' >> tmp/all.txt
}

#统计字符
function count()
{
  cat tmp/all.txt | awk  -F"[[:punct:] \t\n\r]+" '
  {
  	for (i = 1; i <= NF; i++) {
        #统一为小写字母
  		$i = tolower($i);
        #只匹配字母
  		if ($i ~ /^[a-z]+$/)
  		  table[$i]++;
  	}
  }
  END{
  	for (i in table)
  	 print i, table[i];
  }'>tmp/table.txt
}

#删除已存在的临时文件
tmp=$(echo "$(pwd)/tmp/all.txt")
if test -e ${tmp}
then
  rm ${tmp}
fi

#设置初始网页
URL=https://en.wikipedia.org
addURL

#游走网页
echo -----URLList-----
FindPage=0
while [ ${FindPage} -lt 100 ]
do
  getURL
  getPage
done

#统计
echo -----Table-----
count
sort -fbrn -k2 < tmp/table.txt

#eof
