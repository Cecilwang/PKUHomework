#! /usr/bin/bash
#Created on: Mar 26, 2016
#Author: Cecil Wang (cecilwang@126.com)

set -o errexit
#set -xv

#判断参数个数
if [ $# -ne 1 ]
then
    echo "H1-Q1:  requires only one argument."
    echo -e "\nUsage: H1-Q1 directory"
    exit 1
fi

#判断参数是否为文件夹
if ! test -d $1
then
    echo "H1-Q1: argument must be a directory"
    exit 1
fi

(
#切换目录
cd $1
echo -e "H1-Q1: count all the file in $(pwd)\n"

#可以处理隐藏文件，需要将以下所有注释去掉
#declare -a allfile=$(ls -a)
#将ls的输出建立成数组
declare -a allfile=$(ls)
declare -A sum
declare -i dsum=0
declare -i xsum=0

#遍历每个文件
for file in ${allfile}
do

    #echo ${file}
    #处理隐藏文件
    #head=${file%%.*}
    #if [ ${#head} -eq 0 ]
    #then
    #    file=${file:1:$[${#file}-1]}
    #fi
    fullpath=$(pwd)/${file}
    #echo ${fullpath}
    #判断是否为目录
    if test -d ${fullpath}
    then
        let dsum+=1
    else
        #获取类别
        type=${file##*.}
        #echo ${type}

        #增加计数
        if [ ${#type} -ne 0 ]
        then
            let sum[${type}]+=1
        fi

        #判断是否可执行
        if test -x ${fullpath}
        then
            let xsum+=1
        fi
    fi
done

#输出结果
echo "-----type-----"
for type in ${!sum[@]}
do
    echo "${type} ${sum[${type}]}"
  done

echo "-----directory----"
echo ${dsum}
echo "-----exectable file-----"
echo ${xsum}

echo -e "\nH1-Q1: successful"
)

#eof
