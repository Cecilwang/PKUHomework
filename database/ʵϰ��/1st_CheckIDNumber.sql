--�������ݿ�
if OBJECT_ID('ID') is not null
	drop table ID
if object_id('CheckIDNumber') is not null
	drop function CheckIDNumber
go

--����Լ������
create function CheckIDNumber (
	@IDNumber varchar(18)
)
returns bit
as
begin
	--�ж����֤���볤���Ƿ�Ϊ18
	if(len(@IDNumber)<>18)
		return 0

	--�������һλӳ���7
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

	--��������result�ж�Ӧÿһλ���֤�����Ӧ��ϵ����˵Ľ��
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
	
	--��������
	declare @checksum int
	select @checksum = sum(result) from @CalcTable
	set @checksum = @checksum  % 11

	--ȡ��ӳ��
	declare @mapvalue char
	select @mapvalue=value from @MapTable where idn = @checksum
	
	--�ж��Ƿ����ӳ��
	if(SUBSTRING(@IDNumber, 18, 1) <> @mapvalue )
		return 0
	
	return 1
end;
go

--�������ݿ�����Լ��
create table ID (IDNumber char(18) check(dbo.CheckIDNumber(IDNumber)=1));
go

--��������
insert into ID values('52263519830114890X');
insert into ID values('130231252361241241');
insert into ID values('522635198708184662');
insert into ID values('522635198708184612');
go

--������
select * from ID
go

