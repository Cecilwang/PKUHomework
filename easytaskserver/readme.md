#EasyTaskServer  API

-------

##说明
  + 包交换以JSON为基础
  + URL前缀如下，```IP:PORT/api/```，其中IP为IP地址(目前测试使用的IP地址为222.29.97.166)，port为端口号(8001)
  + Method必须为post
  + 请求与响应中内容形式为：
```
key:type 或 key:[type] 或 key=固定值
[type]表示type类型构成的数组
可添加#， 其后的为注释
```
+ 服务器响应页面会根据具体情况返回不同的```HTTP Status Code```
+ 服务器响应内容中必包含success字段，若值为false则操作未成功，可继续查看message字段查看错误信息，若值为true则操作成功且不包含message字段

##API

1. 无需权限验证API

| 功能  | URL | Client请求 | Server响应 | 备注 | 完成情况 |
|------|--------|-------------------------------|-------------------------|-------------|---|
| 登录 | login | name: string  password:string | token:string uid:int | token时效三个月 | 完成 |
| 注册 | signup | name:string  password:string |  |  | 完成 |

2. 需权限验证API

>Requset每次必须包含
>
>| client请求   |
>|--------------|
>| token:string |
>| uid:int |

| 功能 | URL | Client请求 | Server响应 | 备注 | 完成情况 |
|----------------------|----------------|-----------------------------------------------------------------------------|---------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------|----------|
| 获取个人全部信息 | getUserInfo |  | uid:int name:string task:[int] tasktype:[int] score:int team:[int] leader:[int] |  | 完成 |
| 修改个人信息 | modifyUserInfo | name:string password:string tasktype:[int]  |  |  | 完成 |
| 获取积分 | getUserScore |  | score:int |  | 完成 |
| 获取个人全部任务 |  |  | task:[int] |  |  |
|  |  |  |  |  |  |
| 获取所在队伍 |  |  | team:[int] |  |  |
| 获取单个队伍详细信息 | getTeamInfo | teamid:int | team:team | team类型如下 teamid:int name:string member:[int] leader:int task:[int] | 完成 |
| 加入队伍 |  |  |  |  |  |
| 退出队伍 |  |  |  |  |  |
|  |  |  |  |  |  |
| 获取担任队长的队伍 |  |  | team:[int] |  |  |
| 修改队伍信息 |  | name:string |  |  |  |
| 踢人 |  |  |  |  |  |
| 加人 |  |  |  |  |  |
|  |  |  |  |  |  |
| 分享任务 |  |  |  |  |  |
| 邀请组队 |  |  |  |  |  |
|  |  |  |  |  |  |
| 任务排序 |  |  | task:[int] |  |  |
| 增加任务 |  | name:string  ddl:string  tasktype:[int]  remindertime:[string] priority:int |  |  |  |
| 获取单个任务详细信息 |  |  | task[task] | task类型如下 tid:int name:string ddl:string remindertime:[string] tasktype:[int] priority:int |  |
| 修改任务ddl |  | ddl:string |  |  |  |
| 修改任务提醒时间 |  | remindertime:string |  |  |  |
| 修改任务优先级 |  | priority:int |  |  |  |
|  |  |  |  |  |  |