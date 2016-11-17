--�������
dbcc dropcleanbuffers
dbcc freeproccache
go

--������
if OBJECT_ID('STC') is not null
	drop table STC
create table STC(sno int, tno int, cno int);
go

--����Լ��
if OBJECT_ID('Check3NF') is not null
	drop function Check3NF
go

create function Check3NF(
	@sno int,
	@tno int,
	@cno int
) returns bit as
begin
	--�ж��Ƿ�����tno->cno
	if exists(
	select *
	from STC
	where tno = @tno and cno <> @cno)
		return 0

	--�ж��Ƿ�����(sno, cno)->tno
	if exists(
	select *
	from STC
	where sno = @sno and cno = @cno and tno <> @tno)
		return 0

	return 1
end
go

--���Լ��
alter table STC add check(dbo.Check3NF(sno, tno, cno)=1)

--������
/*
insert into STC values(1,1,1)
insert into STC values(1,1,1)
insert into STC values(1,2,3)
insert into STC values(1,2,4)
insert into STC values(1,1,5)
insert into STC values(1,2,1)
select * from STC
*/

--�������
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
select [����Լ��ʱ�䣨ms��]=datediff(ms, @starttime, getdate())
select [�ɹ�����]=@totaltime - @failtime
select [ʧ�ܴ���]=@failtime
select [tno,cno��ͬ�Ķ���]=count(*) from (select count(*)as B from STC group by tno, cno)A
--------------------------------------------------------------

--�������
dbcc dropcleanbuffers
dbcc freeproccache
go

--������
if OBJECT_ID('STC') is not null
	drop table STC
create table STC(sno int, tno int, cno int);
go

--������
create trigger Check3NF_trigger on STC after insert as
	if ( @@ROWCOUNT = 0 ) return
	if ( @@ROWCOUNT > 1 ) 
	begin
		return
	end
	/*
	declare @sno int, @tno int, @cno int
	--ͨ���α�ķ�ʽȡ�������Ԫ��
	declare stcInserted cursor local for select sno, tno, cno from inserted
	open stcInserted
	fetch next from stcInserted into @sno, @tno, @cno
	while @@FETCH_STATUS = 0
	begin
		--�ж��Ƿ�����tno->cno
		if exists(
		select *
		from STC
		where tno = @tno and cno <> @cno)
		begin
			rollback tran
			return 
		end

		--�ж��Ƿ�����(sno, cno)->tno
		if exists(
		select *
		from STC
		where sno = @sno and cno = @cno and tno <> @tno)
		begin
			rollback tran
			return 
		end

		--ȡ����һ��Ԫ��
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

--������
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

--�������
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
select [������ʱ�䣨ms��]=datediff(ms, @starttime, getdate())
select [�ɹ�����]=@totaltime - @failtime
select [ʧ�ܴ���]=@failtime
select [tno,cno��ͬ�Ķ���]=count(*) from (select count(*)as B from STC group by tno, cno)A