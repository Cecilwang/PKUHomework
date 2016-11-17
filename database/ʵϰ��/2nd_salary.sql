--清理数据库
if OBJECT_ID('Works') is not null
	drop table Works
if OBJECT_ID('Dept') is not null
	drop table Dept
if OBJECT_ID('Emp') is not null
	drop table Emp
if OBJECT_ID('CheckSalary') is not null
	drop function CheckSalary
go

--建立数据库表
create table Emp
	(eid int,
	 ename varchar(20),
	 age int,
	 salary int,
	 primary key(eid))

create table Dept
	(did int,
	 budget int,
	 managerid int,
	 primary key (did),
	 foreign key (managerid) references Emp(eid)
	)

create table Works
	(eid int,
	 did int,
	 pct_time real,
	 primary key (eid, did),
	 foreign key (eid) references Emp(eid),
	 foreign key (did) references Dept(did))

go

--创建约束函数
create function CheckSalary (
	@did int,
	@managerid int
)
returns bit
as
begin
	--判断是否存在比管理员薪水高的员工
	if exists (
	select eid from Emp
	where (eid) in (select eid from Works where did=@did and eid <> @managerid) --判断员工是否在对应的部门工作
	and salary >= (select salary from Emp where eid = @managerid) )  --获得管理员的薪水与其比较
		return 0

	return 1
end
go

--添加约束
alter table Dept add check(dbo.CheckSalary(did, managerid)=1)
go

--样例一
--添加员工
insert into Emp values(1,'1',1,2)
insert into Emp values(2,'1',1,1)
insert into Emp values(3,'1',1,1)
insert into Emp values(4,'1',1,1)
select * from Emp

--添加部门
insert into Dept(did, budget, managerid) values (1,1,1)
insert into Dept(did, budget, managerid) values (2,1,4)
select * from Dept

--分配工作
insert into Works values(1,1, 0.5)
insert into Works values(2,1, 0.5)
insert into Works values(3,2, 0.2)
insert into Works values(4,2, 0.5)
insert into Works values(3,1, 0.8)
select * from Works

--重新分配主管
update Dept set managerid = 3 where did = 2
select * from Dept

--样例二
insert into Dept(did, budget) values(3,1)
select * from Dept

insert into Works values (2,3,0.1)
insert into Works values (3,3,0.1)
insert into Works values (4,3,0.1)
select * from Works

update Dept set managerid = 3 where did = 3
select * from Dept
go

--薪水更新触发器
create trigger ChangeSalary on Emp after update as
	if ( @@ROWCOUNT = 0 ) return
	--判断是否是更新了salary属性
	if update (salary) 
	begin
		declare @eidd int, @salaryd int, @salaryi int, @increment int
		--通过游标的方式取出修改前的元组
		declare eDeleted cursor for select eid, salary from deleted
		open eDeleted
		fetch next from eDeleted into @eidd, @salaryd
		while @@FETCH_STATUS = 0
		begin
			--取出修改后的值
			select @salaryi=salary from inserted where eid=@eidd
			--计算差值
			set @increment = @salaryi - @salaryd

			--更新部门预算
			update Dept
			set budget = budget + @increment * t2.pct_time
			from Dept join (select * from Works where eid=@eidd) t2 on Dept.did = t2.did
			where Dept.did = t2.did

			--取出下一个元组
			fetch next from eDeleted into @eidd, @salaryd
		end
		close eDeleted
		deallocate eDeleted
	end
go

--测试样例
update Emp set salary = 21 where eid = 3
select * from Emp
select * from Dept

