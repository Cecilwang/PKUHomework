--清理数据库
if OBJECT_ID('ID') is not null
	drop table ID
if object_id('CheckIDNumber') is not null
	drop function CheckIDNumber
go

--创建约束函数
create function CheckIDNumber (
	@IDNumber varchar(18)
)
returns bit
as
begin
	--判断身份证号码长度是否为18
	if(len(@IDNumber)<>18)
		return 0

	--定义最后一位映射表7
	declare @MapTable table(value char, idn int)
	insert into @MapTable (value, idn) values ('1', 0)
	insert into @MapTable (value, idn) values ('0', 1)
	insert into @MapTable (value, idn) values ('X', 2)
	insert into @MapTable (value, idn) values ('9', 3)
	insert into @MapTable (value, idn) values ('8', 4)
	insert into @MapTable (value, idn) values ('7', 5)
	insert into @MapTable (value, idn) values ('6', 6)
	insert into @MapTable (value, idn) values ('4', 7)
	insert into @MapTable (value, idn) values ('3', 8)
	insert into @MapTable (value, idn) values ('2', 9)

	--定义计算表，result列对应每一位身份证号与对应的系数相乘的结果
	declare @CalcTable table(result int)
	insert into @CalcTable  values (CONVERT(int, SUBSTRING(@IDNumber, 1, 1)) * 7)
	insert into @CalcTable  values (CONVERT(int, SUBSTRING(@IDNumber, 2, 1)) * 9)
	insert into @CalcTable  values (CONVERT(int, SUBSTRING(@IDNumber, 3, 1)) * 10)
	insert into @CalcTable  values (CONVERT(int, SUBSTRING(@IDNumber, 4, 1)) * 5)
	insert into @CalcTable  values (CONVERT(int, SUBSTRING(@IDNumber, 5, 1)) * 8)
	insert into @CalcTable  values (CONVERT(int, SUBSTRING(@IDNumber, 6, 1)) * 4)
	insert into @CalcTable  values (CONVERT(int, SUBSTRING(@IDNumber, 7, 1)) * 2)
	insert into @CalcTable  values (CONVERT(int, SUBSTRING(@IDNumber, 8, 1)) * 1)
	insert into @CalcTable  values (CONVERT(int, SUBSTRING(@IDNumber, 9, 1)) * 6)
	insert into @CalcTable  values (CONVERT(int, SUBSTRING(@IDNumber, 10, 1)) * 3)
	insert into @CalcTable  values (CONVERT(int, SUBSTRING(@IDNumber, 11, 1)) * 7)
	insert into @CalcTable  values (CONVERT(int, SUBSTRING(@IDNumber, 12, 1)) * 9)
	insert into @CalcTable  values (CONVERT(int, SUBSTRING(@IDNumber, 13, 1)) * 10)
	insert into @CalcTable  values (CONVERT(int, SUBSTRING(@IDNumber, 14, 1)) * 5)
	insert into @CalcTable  values (CONVERT(int, SUBSTRING(@IDNumber, 15, 1)) * 8)
	insert into @CalcTable  values (CONVERT(int, SUBSTRING(@IDNumber, 16, 1)) * 4)
	insert into @CalcTable  values (CONVERT(int, SUBSTRING(@IDNumber, 17, 1)) * 2)
	
	--计算余数
	declare @checksum int
	select @checksum = sum(result) from @CalcTable
	set @checksum = @checksum  % 11

	--取出映射
	declare @mapvalue char
	select @mapvalue=value from @MapTable where idn = @checksum
	
	--判断是否符合映射
	if(SUBSTRING(@IDNumber, 18, 1) <> @mapvalue )
		return 0
	
	return 1
end;
go

--建立数据库表并添加约束
create table ID (IDNumber char(18) check(dbo.CheckIDNumber(IDNumber)=1));
go

--测试样例
insert into ID values('52263519830114890X');
insert into ID values('130231252361241241');
insert into ID values('522635198708184662');
insert into ID values('522635198708184612');
go

--输出结果
select * from ID
go

