if object_id('T') is not null drop  table T

create table T
(
id int,
tid varchar(10),
operation_type varchar(10),
item varchar(10)
)
insert into T values (1,'T1','read','A')
insert into T values (2,'T2','write','A')
insert into T values (3,'T3','read','A')
insert into T values (4,'T1','write','A')
insert into T values (5,'T3','write','A')

go

if object_id('E') is not null drop  table E

create table E
(
bg varchar(10),
ed varchar(10),
item varchar(10),
)

if object_id('B') is not null drop  table B

create table B
(
item varchar(10),
tid varchar(10)
)
declare @tid varchar(10)
declare @operation_type varchar(10)
declare @item varchar(10)
insert into B select distinct item,'Tb' as tid from T

declare i cursor
FOR (select tid,operation_type,item from T)
open i
fetch next from i into @tid,@operation_type,@item
while (@@FETCH_STATUS=0)
begin
	declare @now_status varchar(10)
	if (@operation_type='read')
	begin
		select @now_status=tid from B where item=@item
		insert into E values (@now_status,@tid,@item)
	end	
	if (@operation_type='write')
	begin
		update B set tid=@tid
	end
	fetch next from i into @tid,@operation_type,@item
end
deallocate i
insert into E select distinct tid,'Tf',@item from B

go

if object_id('final_view') is not null drop table final_view
create table final_view
(
num int,
label int,
bg varchar(10),
ed varchar(10)
)

if object_id('trans_group') is not null drop table trans_group
create table trans_group
(
ti varchar(10),
tj varchar(10),
tk varchar(10)
)
insert into final_view select ROW_NUMBER()over (order by (select 0)),0,bg,ed from E
declare @num int
declare @id int
declare @tid varchar(10)
declare @operation_type varchar(10)
declare @item varchar(10)
select @num=COUNT(*)+1 from final_view
set @id=1

declare i cursor
FOR (select tid,operation_type,item from T)
open i
fetch next from i into @tid,@operation_type,@item
while (@@FETCH_STATUS=0)
begin
	declare @now_status varchar(10)
	if (@operation_type='write')
	begin
		insert into trans_group select bg,ed,@tid from E where @tid!=bg and @tid!=ed and item=@item
	end
	
	fetch next from i into @tid,@operation_type,@item
end
deallocate i

declare @ti varchar(10)
declare @tj varchar(10)
declare @tk varchar(10)
declare @flag int
declare i cursor
FOR (select ti,tj,tk from trans_group)
open i
fetch next from i into @ti,@tj,@tk
while (@@FETCH_STATUS=0)
begin
	if (@ti='Tb' and @tj!='Tf')
	begin
		set @flag=0
		select @flag=1 from final_view where (label=0 and bg=@tj and ed=@tk)
		if (@flag=0)
		begin
			insert into final_view values (@num,0,@tj,@tk)
			set @num=@num+1
		end
	end
	if (@ti!='Tb' and @tj='Tf')
	begin
		set @flag=0
		select @flag=1 from final_view where (label=0 and bg=@tk and ed=@ti)
		if (@flag=0)
		begin
			insert into final_view values (@num,0,@tk,@ti)
			set @num=@num+1
		end
	end
	if (@ti!='Tb' and @tj!='Tf')
	begin
		
		insert into final_view values(@num,@id,@tk,@ti)
		set @num=@num+1
		insert into final_view values(@num,@id,@tj,@tk)
		set @num=@num+1
		set @id=@id+1
	end
	
	fetch next from i into @ti,@tj,@tk
end
deallocate i

go

if object_id('circle') is not null drop  function circle
go

create function circle(@st varchar(10))
returns table
as
return
 with result(bg,ed) as
(select now_view.bg, now_view.ed from now_view
 where now_view.bg = @st
 union all
 select now_view.bg, now_view.ed 
 from now_view , result 
 where now_view.bg = result.ed and now_view.bg!=@st
 )
 select bg,ed from result
 go


if object_id('now_view') is not null drop  table now_view

create table now_view
(
bg varchar(10),
ed varchar(10),
)

if object_id('enumeration') is not null drop  table enumeration

create table enumeration
(
label int,
odd int
)

if object_id('node') is not null drop  table node

create table node
(
tid varchar(10)
)
insert into enumeration select distinct label,0 from final_view where label>0
declare @last int
declare @is_circle int
select @last=COUNT(*) from enumeration
set @last=POWER(2,@last)
declare @tid varchar(10)
while @last>0 
begin
	print(1)
	set @is_circle=1
	truncate table now_view
	truncate table node
	insert into now_view select distinct final_view.bg,final_view.ed  from final_view,enumeration where final_view.label=0 or (final_view.label=enumeration.label and final_view.num%2=enumeration.odd) 
	
	insert into node select distinct bg from now_view 
	declare i cursor
	FOR (select tid from node)
	open i
	fetch next from i into @tid  
	while (@@FETCH_STATUS=0)
	begin
		if @tid in (select ed from circle(@tid))
		begin
			set @is_circle=0
			break
		end
		
		--select @is_circle=0 from node where @tid in dbo.circle(@tid)
		fetch next from i into @tid
	end
	deallocate i
	if (@is_circle=1) break
	
	declare @label int
	declare @odd int
	set @last=@last-1;
	if (@last=0) break
	declare j cursor
	FOR (select label,odd from enumeration)
	open j
	fetch next from j into @label,@odd
	while (@@FETCH_STATUS=0)
	begin
		if (@odd=0)
		begin
			update enumeration set odd=0 where label<@label
			update enumeration set odd=1 where label=@label
			break
		end
		fetch next from j into @label,@odd
	end
	deallocate j
end
if @is_circle=1 begin
	print('可串行化')
end
else
begin
	print('不可串行化')
end

go


