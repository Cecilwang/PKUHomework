--�������ݿ�
if OBJECT_ID('Works') is not null
	drop table Works
if OBJECT_ID('Dept') is not null
	drop table Dept
if OBJECT_ID('Emp') is not null
	drop table Emp
if OBJECT_ID('CheckSalary') is not null
	drop function CheckSalary
go

--�������ݿ��
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

--����Լ������
create function CheckSalary (
	@did int,
	@managerid int
)
returns bit
as
begin
	--�ж��Ƿ���ڱȹ���Աнˮ�ߵ�Ա��
	if exists (
	select eid from Emp
	where (eid) in (select eid from Works where did=@did and eid <> @managerid) --�ж�Ա���Ƿ��ڶ�Ӧ�Ĳ��Ź���
	and salary >= (select salary from Emp where eid = @managerid) )  --��ù���Ա��нˮ����Ƚ�
		return 0

	return 1
end
go

--���Լ��
alter table Dept add check(dbo.CheckSalary(did, managerid)=1)
go

--����һ
--���Ա��
insert into Emp values(1,'1',1,2)
insert into Emp values(2,'1',1,1)
insert into Emp values(3,'1',1,1)
insert into Emp values(4,'1',1,1)
select * from Emp

--��Ӳ���
insert into Dept(did, budget, managerid) values (1,1,1)
insert into Dept(did, budget, managerid) values (2,1,4)
select * from Dept

--���乤��
insert into Works values(1,1, 0.5)
insert into Works values(2,1, 0.5)
insert into Works values(3,2, 0.2)
insert into Works values(4,2, 0.5)
insert into Works values(3,1, 0.8)
select * from Works

--���·�������
update Dept set managerid = 3 where did = 2
select * from Dept

--������
insert into Dept(did, budget) values(3,1)
select * from Dept

insert into Works values (2,3,0.1)
insert into Works values (3,3,0.1)
insert into Works values (4,3,0.1)
select * from Works

update Dept set managerid = 3 where did = 3
select * from Dept
go

--нˮ���´�����
create trigger ChangeSalary on Emp after update as
	if ( @@ROWCOUNT = 0 ) return
	--�ж��Ƿ��Ǹ�����salary����
	if update (salary) 
	begin
		declare @eidd int, @salaryd int, @salaryi int, @increment int
		--ͨ���α�ķ�ʽȡ���޸�ǰ��Ԫ��
		declare eDeleted cursor for select eid, salary from deleted
		open eDeleted
		fetch next from eDeleted into @eidd, @salaryd
		while @@FETCH_STATUS = 0
		begin
			--ȡ���޸ĺ��ֵ
			select @salaryi=salary from inserted where eid=@eidd
			--�����ֵ
			set @increment = @salaryi - @salaryd

			--���²���Ԥ��
			update Dept
			set budget = budget + @increment * t2.pct_time
			from Dept join (select * from Works where eid=@eidd) t2 on Dept.did = t2.did
			where Dept.did = t2.did

			--ȡ����һ��Ԫ��
			fetch next from eDeleted into @eidd, @salaryd
		end
		close eDeleted
		deallocate eDeleted
	end
go

--��������
update Emp set salary = 21 where eid = 3
select * from Emp
select * from Dept

