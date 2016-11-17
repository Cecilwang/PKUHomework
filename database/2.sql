if object_id('employee') is not null
	drop  table employee
go


create table employee (
	id varchar,
	salary int 
)

go

insert into employee values ('A',20)
insert into employee values ('B',30)
go

--set transaction isolation level read uncommitted
--set transaction isolation level read committed
--set transaction isolation level repeatable read
set transaction isolation level serializable

waitfor time '15:32:30'
go

begin transaction
insert into employee values('C', 40)
update employee set salary = salary+10 where ID='A';
commit transaction



