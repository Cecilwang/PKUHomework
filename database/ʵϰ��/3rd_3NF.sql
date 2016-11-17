--清除缓存
dbcc dropcleanbuffers
dbcc freeproccache
go

--建立表
if OBJECT_ID('STC') is not null
	drop table STC
create table STC(sno int, tno int, cno int);
go

--函数约束
if OBJECT_ID('Check3NF') is not null
	drop function Check3NF
go

create function Check3NF(
	@sno int,
	@tno int,
	@cno int
) returns bit as
begin
	--判断是否满足tno->cno
	if exists(
	select *
	from STC
	where tno = @tno and cno <> @cno)
		return 0

	--判断是否满足(sno, cno)->tno
	if exists(
	select *
	from STC
	where sno = @sno and cno = @cno and tno <> @tno)
		return 0

	return 1
end
go

--添加约束
alter table STC add check(dbo.Check3NF(sno, tno, cno)=1)

--简单样例
/*
insert into STC values(1,1,1)
insert into STC values(1,1,1)
insert into STC values(1,2,3)
insert into STC values(1,2,4)
insert into STC values(1,1,5)
insert into STC values(1,2,1)
select * from STC
*/

--随机插入
declare @totaltime int
set @totaltime = 100000
declare @starttime datetime
set @starttime=GETDATE()
declare @failtime int
set @failtime = 0
declare @i int
set @i = 0
while @i < @totaltime
begin
	begin try
		insert into STC values( 
			FLOOR(RAND()*10000),
			FLOOR(RAND()*1000),
			FLOOR(RAND()*100))
	end try
	begin catch
		set @failtime = @failtime + 1
	end catch
	set @i = @i + 1
end
--select * from STC
select [函数约束时间（ms）]=datediff(ms, @starttime, getdate())
select [成功次数]=@totaltime - @failtime
select [失败次数]=@failtime
select [tno,cno不同的对数]=count(*) from (select count(*)as B from STC group by tno, cno)A
--------------------------------------------------------------

--清除缓存
dbcc dropcleanbuffers
dbcc freeproccache
go

--建立表
if OBJECT_ID('STC') is not null
	drop table STC
create table STC(sno int, tno int, cno int);
go

--触发器
create trigger Check3NF_trigger on STC after insert as
	if ( @@ROWCOUNT = 0 ) return
	if ( @@ROWCOUNT > 1 ) 
	begin
		return
	end
	/*
	declare @sno int, @tno int, @cno int
	--通过游标的方式取出插入的元组
	declare stcInserted cursor local for select sno, tno, cno from inserted
	open stcInserted
	fetch next from stcInserted into @sno, @tno, @cno
	while @@FETCH_STATUS = 0
	begin
		--判断是否满足tno->cno
		if exists(
		select *
		from STC
		where tno = @tno and cno <> @cno)
		begin
			rollback tran
			return 
		end

		--判断是否满足(sno, cno)->tno
		if exists(
		select *
		from STC
		where sno = @sno and cno = @cno and tno <> @tno)
		begin
			rollback tran
			return 
		end

		--取出下一个元组
		fetch next from stcInserted into @sno, @tno, @cno
	end
	close stcInserted
	deallocate stcInserted
	*/
	declare @sno int, @tno int, @cno int
	select @sno=sno from inserted
	select @tno=tno from inserted
	select @cno=cno from inserted

	if exists(
	select *
	from STC
	where tno = @tno and cno <> @cno)
	begin
		rollback tran
		return 
	end

	
	if exists(
	select *
	from STC
	where sno = @sno and cno = @cno and tno <> @tno)
	begin
		rollback tran
		return 
	end
go

--简单样例
/*
insert into STC values(1,1,1)
insert into STC values(1,1,1)
insert into STC values(1,2,3)
begin try
insert into STC values(1,2,4)
end try
begin catch
	print 'hehe'
end catch
begin try
insert into STC values(1,1,5)
end try
begin catch
	print 'hehe'
end catch
begin try
insert into STC values(1,2,1)
end try
begin catch
	print 'hehe'
end catch
select * from STC
*/

--随机插入
declare @totaltime int
set @totaltime = 100000
declare @starttime datetime
set @starttime=GETDATE()
declare @failtime int
set @failtime = 0
declare @i int
set @i = 0
while @i < @totaltime
begin
	begin try
		insert into STC values( 
			FLOOR(RAND()*10000),
			FLOOR(RAND()*1000),
			FLOOR(RAND()*100))
	end try
	begin catch
		set @failtime = @failtime + 1
	end catch
	set @i = @i + 1
end
--select * from STC
select [触发器时间（ms）]=datediff(ms, @starttime, getdate())
select [成功次数]=@totaltime - @failtime
select [失败次数]=@failtime
select [tno,cno不同的对数]=count(*) from (select count(*)as B from STC group by tno, cno)A