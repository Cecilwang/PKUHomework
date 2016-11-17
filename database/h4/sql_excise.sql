---------------------------------------------------------------------
-- Inside Microsoft SQL Server 2008: T-SQL Querying (MSPress, 2009)
-- Chapter 06 - Subqueries, Table Expressions and Ranking Functions
-- Copyright Itzik Ben-Gan, 2009
-- All Rights Reserved
---------------------------------------------------------------------

---------------------------------------------------------------------
--ע��
--����select��ѡ����from��where�޶������µ�Ԫ�������
--�ʣ��ں���ע���н�����˵��selectѡ�������ԣ�
--�ҽ���ע����Ҫ����˵��from��where�޶��µ�Ԫ��
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Subqueries
---------------------------------------------------------------------

-- Scalar subquery
---------------------------------------------------------------------
--�ҵ���󶩵���
--11077	65
---------------------------------------------------------------------
SET NOCOUNT ON;
USE InsideTSQL2008;

SELECT orderid, custid
FROM Sales.Orders
WHERE orderid = (SELECT MAX(orderid) FROM Sales.Orders);

-- Correlated subquery
---------------------------------------------------------------------
--�ҵ�ÿ���˿͵���󶩵���
--11044	91
--11005	90
--11066	89
--10935	88
---------------------------------------------------------------------
SELECT orderid, custid
FROM Sales.Orders AS O1
WHERE orderid = (SELECT MAX(O2.orderid)
                 FROM Sales.Orders AS O2
                 WHERE O2.custid = O1.custid);

-- Multivalued subquery
---------------------------------------------------------------------
--�ҵ���ÿ���˿Ͷ�Ӧ�Ĺ�˾
--1	Customer NRZBB
--2	Customer MLTDN
--3	Customer KBUDE
--4	Customer HFBZG
---------------------------------------------------------------------
SELECT custid, companyname
FROM Sales.Customers
WHERE custid IN (SELECT custid FROM Sales.Orders);

-- Table subquery
---------------------------------------------------------------------
--�ҵ�ÿ�����󶩵���
--2007	10807
--2008	11077
--2006	10399
---------------------------------------------------------------------
SELECT orderyear, MAX(orderid) AS max_orderid
FROM (SELECT orderid, YEAR(orderdate) AS orderyear
      FROM Sales.Orders) AS D
GROUP BY orderyear;

---------------------------------------------------------------------
-- Self-Contained Subqueries
---------------------------------------------------------------------

-- Scalar subquery example
---------------------------------------------------------------------
--�ҵ�lastnameΪN'Davis'�Ĺ�Ա�����ж�����
--10258
--10270
--10275
--10285
--10292
--10293
---------------------------------------------------------------------
SELECT orderid FROM Sales.Orders
WHERE empid =
  (SELECT empid FROM HR.Employees
   -- also try with N'Kollar' and N'D%'
   WHERE lastname LIKE N'Davis');

-- Customers with orders handled by all employees from the USA
-- using literals
---------------------------------------------------------------------
--�ҵ���1,2,3,4,8�����Աȫ���н��׵Ĺ˿�
--5
--9
--20
--24
--34
---------------------------------------------------------------------
SELECT custid
FROM Sales.Orders
WHERE empid IN(1, 2, 3, 4, 8)
GROUP BY custid
HAVING COUNT(DISTINCT empid) = 5;

-- Customers with orders handled by all employees from the USA
-- using subqueries
---------------------------------------------------------------------
--�ҵ������б�����Աȫ���н��׵Ĺ˿�
--5
--9
--20
--24
--34
---------------------------------------------------------------------
SELECT custid
FROM Sales.Orders
WHERE empid IN
  (SELECT empid FROM HR.Employees
   WHERE country = N'USA')
GROUP BY custid
HAVING COUNT(DISTINCT empid) =
  (SELECT COUNT(*) FROM HR.Employees
   WHERE country = N'USA');

-- Orders placed on last actual order date of the month
---------------------------------------------------------------------
--�ҵ�ÿ��ÿ������һ������н��׼�¼
--10269	89	5	2006-07-31 00:00:00.000
--10294	65	4	2006-08-30 00:00:00.000
--10317	48	6	2006-09-30 00:00:00.000
--10343	44	4	2006-10-31 00:00:00.000
---------------------------------------------------------------------
SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE orderdate IN
  (SELECT MAX(orderdate)
   FROM Sales.Orders
   GROUP BY YEAR(orderdate), MONTH(orderdate));
GO

---------------------------------------------------------------------
-- Correlated Subqueries
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Tiebreaker
---------------------------------------------------------------------

-- Index for tiebreaker problems
---------------------------------------------------------------------
-- ��������
---------------------------------------------------------------------
CREATE UNIQUE INDEX idx_eid_od_oid
  ON Sales.Orders(empid, orderdate, orderid);
CREATE UNIQUE INDEX idx_eid_od_rd_oid
  ON Sales.Orders(empid, orderdate, requireddate, orderid);
GO

-- Orders with the maximum orderdate for each employee
-- Incorrect solution
---------------------------------------------------------------------
-- �����г����й�Ա�����������
-- Ȼ���г����з�������Щ�����еĽ���
-- 11040	32	4	2008-04-22 00:00:00.000	2008-05-20 00:00:00.000
-- 11041	14	3	2008-04-22 00:00:00.000	2008-05-20 00:00:00.000
-- 11042	15	2	2008-04-22 00:00:00.000	2008-05-06 00:00:00.000
-- 11043	74	5	2008-04-22 00:00:00.000	2008-05-20 00:00:00.000
---------------------------------------------------------------------
SELECT orderid, custid, empid, orderdate, requireddate
FROM Sales.Orders
WHERE orderdate IN
  (SELECT MAX(orderdate) FROM Sales.Orders
   GROUP BY empid);

-- Orders with maximum orderdate for each employee
---------------------------------------------------------------------
-- �ҵ�ÿ����Ա���һ�ν��׵����ڼ����췢�������н���
--11058	6	9	2008-04-29 00:00:00.000	2008-05-27 00:00:00.000
--11075	68	8	2008-05-06 00:00:00.000	2008-06-03 00:00:00.000
--11074	73	7	2008-05-06 00:00:00.000	2008-06-03 00:00:00.000
--11045	10	6	2008-04-23 00:00:00.000	2008-05-21 00:00:00.000
---------------------------------------------------------------------
SELECT orderid, custid, empid, orderdate, requireddate
FROM Sales.Orders AS O1
WHERE orderdate =
  (SELECT MAX(orderdate)
   FROM Sales.Orders AS O2
   WHERE O2.empid = O1.empid);

-- Most recent order for each employee
-- Tiebreaker: max order id
---------------------------------------------------------------------
-- �ҵ�ÿ����Ա���һ�콻���ж��������Ľ���
--11077	65	1	2008-05-06 00:00:00.000	2008-06-03 00:00:00.000
--11073	58	2	2008-05-05 00:00:00.000	2008-06-02 00:00:00.000
--11063	37	3	2008-04-30 00:00:00.000	2008-05-28 00:00:00.000
---------------------------------------------------------------------
SELECT orderid, custid, empid, orderdate, requireddate
FROM Sales.Orders AS O1
WHERE orderdate =
  (SELECT MAX(orderdate)
   FROM Sales.Orders AS O2
   WHERE O2.empid = O1.empid)
  AND orderid =
  (SELECT MAX(orderid)
   FROM Sales.Orders AS O2
   WHERE O2.empid = O1.empid
     AND O2.orderdate = O1.orderdate);

-- Most recent order for each employee, nesting subqueries
-- Tiebreaker: max order id
---------------------------------------------------------------------
-- �ҵ�ÿ����Ա���һ�콻���ж��������Ľ���
--11077	65	1	2008-05-06 00:00:00.000	2008-06-03 00:00:00.000
--11073	58	2	2008-05-05 00:00:00.000	2008-06-02 00:00:00.000
--11063	37	3	2008-04-30 00:00:00.000	2008-05-28 00:00:00.000
---------------------------------------------------------------------
SELECT orderid, custid, empid, orderdate, requireddate
FROM Sales.Orders AS O1
WHERE orderid =
  (SELECT MAX(orderid)
   FROM Sales.Orders AS O2
   WHERE O2.empid = O1.empid
     AND O2.orderdate =
       (SELECT MAX(orderdate)
        FROM Sales.Orders AS O3
        WHERE O3.empid = O1.empid));

-- Most recent order for each employee
-- Tiebreaker: max requireddate, max orderid
---------------------------------------------------------------------
-- �ҵ�ÿ����Ա���һ�콻���������������Ľ��ף�������ͬ�ڸ��ݶ���������
--11077	65	1	2008-05-06 00:00:00.000	2008-06-03 00:00:00.000
--11073	58	2	2008-05-05 00:00:00.000	2008-06-02 00:00:00.000
--11063	37	3	2008-04-30 00:00:00.000	2008-05-28 00:00:00.000
---------------------------------------------------------------------
SELECT orderid, custid, empid, orderdate, requireddate
FROM Sales.Orders AS O1
WHERE orderdate =
  (SELECT MAX(orderdate)
   FROM Sales.Orders AS O2
   WHERE O2.empid = O1.empid)
  AND requireddate =
  (SELECT MAX(requireddate)
   FROM Sales.Orders AS O2
   WHERE O2.empid = O1.empid
     AND O2.orderdate = O1.orderdate)
  AND orderid =
  (SELECT MAX(orderid)
   FROM Sales.Orders AS O2
   WHERE O2.empid = O1.empid
     AND O2.orderdate = O1.orderdate
     AND O2.requireddate = O1.requireddate);

-- Cleanup
DROP INDEX Sales.Orders.idx_eid_od_oid;
DROP INDEX Sales.Orders.idx_eid_od_rd_oid;
GO

---------------------------------------------------------------------
-- EXISTS
---------------------------------------------------------------------

-- Customers from Spain that made orders
-- Using EXISTS
---------------------------------------------------------------------
-- �����������������н��׹˿�
--8	Customer QUHWH
--29	Customer MDLWA
--30	Customer KSLQF
---------------------------------------------------------------------
SELECT custid, companyname
FROM Sales.Customers AS C
WHERE country = N'Spain'
  AND EXISTS
    (SELECT * FROM Sales.Orders AS O
     WHERE O.custid = C.custid);

---------------------------------------------------------------------
-- EXISTS vs. IN
---------------------------------------------------------------------

-- Customers from Spain that made orders
-- Using IN
---------------------------------------------------------------------
-- �����������������н��׵Ĺ˿�
--8	Customer QUHWH
--29	Customer MDLWA
--30	Customer KSLQF
---------------------------------------------------------------------
SELECT custid, companyname
FROM Sales.Customers AS C
WHERE country = N'Spain'
  AND custid IN(SELECT custid FROM Sales.Orders);

---------------------------------------------------------------------
-- NOT EXISTS vs. NOT IN
---------------------------------------------------------------------

-- Customers from Spain who made no Orders
-- Using EXISTS
---------------------------------------------------------------------
-- ����������������û�н��׵Ĺ˿�
--22	Customer DTDMN
---------------------------------------------------------------------
SELECT custid, companyname
FROM Sales.Customers AS C
WHERE country = N'Spain'
  AND NOT EXISTS
    (SELECT * FROM Sales.Orders AS O
     WHERE O.custid = C.custid);

-- Customers from Spain who made no Orders
-- Using IN, try 1
---------------------------------------------------------------------
-- ����������������û�н��׵Ĺ˿�
--22	Customer DTDMN
---------------------------------------------------------------------
SELECT custid, companyname
FROM Sales.Customers AS C
WHERE country = N'Spain'
  AND custid NOT IN(SELECT custid FROM Sales.Orders);

-- Add a row to Orders with a NULL customer id
INSERT INTO Sales.Orders
  (custid, empid, orderdate, requireddate, shippeddate, shipperid,
   freight, shipname, shipaddress, shipcity, shipregion,
   shippostalcode, shipcountry)
  VALUES(NULL, 1, '20090212', '20090212',
         '20090212', 1, 123.00, N'abc', N'abc', N'abc',
         N'abc', N'abc', N'abc');

-- Customers from Spain that made no Orders
-- Using IN, try 2
---------------------------------------------------------------------
-- ����������������û�н��׵Ĺ˿���custid����NULL
--22	Customer DTDMN
---------------------------------------------------------------------
SELECT custid, companyname
FROM Sales.Customers AS C
WHERE country = N'Spain'
  AND custid NOT IN(SELECT custid FROM Sales.Orders
                    WHERE custid IS NOT NULL);

-- Remove the row from Orders with the NULL customer id
DELETE FROM Sales.Orders WHERE custid IS NULL;
DBCC CHECKIDENT('Sales.Orders', RESEED, 11077);
GO



---------------------------------------------------------------------
-- Joins
---------------------------------------------------------------------

---------------------------------------------------------------------
-- CROSS
---------------------------------------------------------------------

SET NOCOUNT ON;
USE InsideTSQL2008;
GO

-- Get all Possible Combinations, ANSI SQL:1992
---------------------------------------------------------------------
-- ��Ա�Ŀ��ϻ�
--Sara	Davis	Sara	Davis
--Don	Funk	Sara	Davis
--Judy	Lew	Sara	Davis
---------------------------------------------------------------------
SELECT E1.firstname, E1.lastname AS emp1,
  E2.firstname, E2.lastname AS emp2
FROM HR.Employees AS E1
  CROSS JOIN HR.Employees AS E2;

-- Get all Possible Combinations, ANSI SQL:1989
---------------------------------------------------------------------
-- ��Ա�Ŀ��ϻ�
--Sara	Davis	Sara	Davis
--Don	Funk	Sara	Davis
--Judy	Lew	Sara	Davis
---------------------------------------------------------------------
SELECT E1.firstname, E1.lastname AS emp1,
  E2.firstname, E2.lastname AS emp2
FROM HR.Employees AS E1, HR.Employees AS E2;
GO


-- Creating and Populating the Nums Auxiliary Table
SET NOCOUNT ON;
IF OBJECT_ID('dbo.Nums', 'U') IS NOT NULL
  DROP TABLE dbo.Nums;
CREATE TABLE dbo.Nums(n INT NOT NULL PRIMARY KEY);

DECLARE @max AS INT, @rc AS INT;
SET @max = 1000000;
SET @rc = 1;

INSERT INTO dbo.Nums(n) VALUES(1);
WHILE @rc * 2 <= @max
BEGIN
  INSERT INTO dbo.Nums(n) SELECT n + @rc FROM dbo.Nums;
  SET @rc = @rc * 2;
END

INSERT INTO dbo.Nums(n)
  SELECT n + @rc FROM dbo.Nums WHERE n + @rc <= @max;
GO

-- Generate Copies, using a Literal
---------------------------------------------------------------------
-- Salces.Customers,HR.Employees,dbo.Numbs�Ŀ��ϻ�
-- ��ֻȡ��2009��1��1��֮��31�������
--1	2	2009-01-01 00:00:00.000
--2	2	2009-01-01 00:00:00.000
--3	2	2009-01-01 00:00:00.000
---------------------------------------------------------------------
SELECT custid, empid,
  DATEADD(day, n-1, '20090101') AS orderdate
FROM Sales.Customers
  CROSS JOIN HR.Employees
  CROSS JOIN dbo.Nums
WHERE n <= 31;
GO

-- Make Sure MyOrders does not Exist
IF OBJECT_ID('dbo.MyOrders') IS NOT NULL
  DROP TABLE dbo.MyOrders;
GO

-- Generate Copies, using Arguments
DECLARE
  @fromdate AS DATE = '20090101',
  @todate   AS DATE = '20090131';

WITH Orders
AS
(
  SELECT custid, empid,
    DATEADD(day, n-1, @fromdate) AS orderdate
  FROM Sales.Customers
    CROSS JOIN HR.Employees
    CROSS JOIN dbo.Nums
  WHERE n <= DATEDIFF(day, @fromdate, @todate) + 1
)
SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 0)) AS orderid,
  custid, empid, orderdate
INTO dbo.MyOrders
FROM Orders;
GO

-- Cleanup
DROP TABLE dbo.MyOrders;
GO

-- Avoiding Multiple Subqueries
IF OBJECT_ID('dbo.MyOrderValues', 'U') IS NOT NULL
  DROP TABLE dbo.MyOrderValues;
GO

SELECT *
INTO dbo.MyOrderValues
FROM Sales.OrderValues;

ALTER TABLE dbo.MyOrderValues
  ADD CONSTRAINT PK_MyOrderValues PRIMARY KEY(orderid);

CREATE INDEX idx_val ON dbo.MyOrderValues(val);
GO

-- Listing 7-1 Query obtaining aggregates with subqueries
---------------------------------------------------------------------
-- ��ÿ������value��ռ���ܶ����İٷֱȣ��Լ���ƽ��ֵ�Ĳ�
--10248	85	440.00	0.03	-1085.05
--10249	79	1863.40	0.15	338.35
--10250	34	1552.60	0.12	27.55
---------------------------------------------------------------------
SELECT orderid, custid, val,
  CAST(val / (SELECT SUM(val) FROM dbo.MyOrderValues) * 100.
       AS NUMERIC(5, 2)) AS pct,
  CAST(val - (SELECT AVG(val) FROM dbo.MyOrderValues)
       AS NUMERIC(12, 2)) AS diff
FROM dbo.MyOrderValues;

-- Listing 7-2 Query obtaining aggregates with a cross join
---------------------------------------------------------------------
-- ��ÿ������value��ռ���ܶ����İٷֱȣ��Լ���ƽ��ֵ�Ĳ�
--10248	85	440.00	0.03	-1085.05
--10249	79	1863.40	0.15	338.35
--10250	34	1552.60	0.12	27.55
---------------------------------------------------------------------
WITH Aggs AS
(
  SELECT SUM(val) AS sumval, AVG(val) AS avgval
  FROM dbo.MyOrderValues
)
SELECT orderid, custid, val,
  CAST(val / sumval * 100. AS NUMERIC(5, 2)) AS pct,
  CAST(val - avgval AS NUMERIC(12, 2)) AS diff
FROM dbo.MyOrderValues
  CROSS JOIN Aggs;

-- Cleanup
IF OBJECT_ID('dbo.MyOrderValues', 'U') IS NOT NULL
  DROP TABLE dbo.MyOrderValues;
GO

---------------------------------------------------------------------
-- INNER
---------------------------------------------------------------------

-- Inner Join, ANSI SQL:1992
---------------------------------------------------------------------
-- �����ӣ��ҹ˿���������
--32	Customer YSIQX	10528
--32	Customer YSIQX	10589
--32	Customer YSIQX	10616
---------------------------------------------------------------------
SELECT C.custid, companyname, orderid
FROM Sales.Customers AS C
  JOIN Sales.Orders AS O
    ON C.custid = O.custid
WHERE country = N'USA';

-- Inner Join, ANSI SQL:1989
---------------------------------------------------------------------
-- �����ӣ��ҹ˿���������
--32	Customer YSIQX	10528
--32	Customer YSIQX	10589
--32	Customer YSIQX	10616
---------------------------------------------------------------------
SELECT C.custid, companyname, orderid
FROM Sales.Customers AS C, Sales.Orders AS O
WHERE C.custid = O.custid
  AND country = N'USA';
GO


-- Forgetting to Specify Join Condition, ANSI SQL:1989
---------------------------------------------------------------------
-- �ѿ�����
--72	Customer AHPOP	10248
--72	Customer AHPOP	10249
--72	Customer AHPOP	10250
---------------------------------------------------------------------
SELECT C.custid, companyname, orderid
FROM Sales.Customers AS C, Sales.Orders AS O;
GO

-- Forgetting to Specify Join Condition, ANSI SQL:1989
---------------------------------------------------------------------
--�﷨����
---------------------------------------------------------------------
SELECT C.custid, companyname, orderid
FROM Sales.Customers AS C JOIN Sales.Orders AS O;
GO

---------------------------------------------------------------------
-- OUTER
---------------------------------------------------------------------

-- Outer Join, ANSI SQL:1992
---------------------------------------------------------------------
-- ������
--1	Customer NRZBB	10643
--1	Customer NRZBB	10692
--1	Customer NRZBB	10702
---------------------------------------------------------------------
SELECT C.custid, companyname, orderid
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON C.custid = O.custid;
GO

-- Changing the Database Compatibility Level to 2000
ALTER DATABASE InsideTSQL2008 SET COMPATIBILITY_LEVEL = 80;
GO


---------------------------------------------------------------------
-- �﷨����
---------------------------------------------------------------------
-- Outer Join, Old-Style Non-ANSI
SELECT C.custid, companyname, orderid
FROM Sales.Customers AS C, Sales.Orders AS O
WHERE C.custid *= O.custid;
GO

-- Outer Join with Filter, ANSI SQL:1992
---------------------------------------------------------------------
-- ��������
--22	Customer DTDMN	NULL
--57	Customer WVAXS	NULL
---------------------------------------------------------------------
SELECT C.custid, companyname, orderid
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON C.custid = O.custid
WHERE O.custid IS NULL;

---------------------------------------------------------------------
-- �﷨����
---------------------------------------------------------------------
-- Outer Join with Filter, Old-Style Non-ANSI
SELECT C.custid, companyname, orderid
FROM Sales.Customers AS C, Sales.Orders AS O
WHERE C.custid *= O.custid
  AND O.custid IS NULL;

-- Changing the Database Compatibility Level Back to 2008
ALTER DATABASE InsideTSQL2008 SET COMPATIBILITY_LEVEL = 100;
GO

-- Creating and Populating the Table T1
USE tempdb;
IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1;

CREATE TABLE dbo.T1
(
  keycol  INT         NOT NULL PRIMARY KEY,
  datacol VARCHAR(10) NOT NULL
);
GO

INSERT INTO dbo.T1(keycol, datacol) VALUES
  (1, 'e'),
  (2, 'f'),
  (3, 'a'),
  (4, 'b'),
  (6, 'c'),
  (7, 'd');

-- Using Correlated Subquery to Find Minimum Missing Value
---------------------------------------------------------------------
-- �ҵ���С��keycol�Ķϵ㣬��������
--5
---------------------------------------------------------------------
SELECT MIN(A.keycol) + 1
FROM dbo.T1 AS A
WHERE NOT EXISTS
  (SELECT * FROM dbo.T1 AS B
   WHERE B.keycol = A.keycol + 1);

-- Using Outer Join to Find Minimum Missing Value
---------------------------------------------------------------------
-- �ҵ���С��keycol�Ķϵ㣬��������
--5
---------------------------------------------------------------------
SELECT MIN(A.keycol) + 1
FROM dbo.T1 AS A
  LEFT OUTER JOIN dbo.T1 AS B
    ON B.keycol = A.keycol + 1
WHERE B.keycol IS NULL;
GO

---------------------------------------------------------------------
-- Non-Supported Join Types
---------------------------------------------------------------------

---------------------------------------------------------------------
-- NATURAL, UNION Joins
---------------------------------------------------------------------
USE InsideTSQL2008;
GO

-- NATURAL Join
/*
SELECT C.custid, companyname, orderid
FROM Sales.Customers AS C NATURAL JOIN Sales.Orders AS O;
*/

-- Logically Equivalent Inner Join
---------------------------------------------------------------------
-- ������
--72	Customer AHPOP	10643
--72	Customer AHPOP	10692
---------------------------------------------------------------------

SELECT C.custid, companyname, orderid
FROM Sales.Customers AS C
  JOIN Sales.Orders AS O
    ON O.custid = O.custid;
GO

---------------------------------------------------------------------
-- Further Examples of Joins
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Self Joins
---------------------------------------------------------------------
USE InsideTSQL2008;
GO

---------------------------------------------------------------------
-- �������ӣ�ֻ��mgrid��empid����������
--Sara	Davis	NULL	NULL
--Don	Funk	Sara	Davis
--Judy	Lew	Don	Funk
--Yael	Peled	Judy	Lew
---------------------------------------------------------------------
SELECT E.firstname, E.lastname AS emp,
  M.firstname, M.lastname AS mgr
FROM HR.Employees AS E
  LEFT OUTER JOIN HR.Employees AS M
    ON E.mgrid = M.empid;
GO

---------------------------------------------------------------------
-- Non-Equi-Joins
---------------------------------------------------------------------

-- Cross without Mirrored Pairs and without Self
---------------------------------------------------------------------
-- ��E1��empidС��E2��empidʱ����
--1	Davis	Sara	2	Funk	Don
--1	Davis	Sara	3	Lew	Judy
--2	Funk	Don	3	Lew	Judy
---------------------------------------------------------------------
SELECT E1.empid, E1.lastname, E1.firstname,
  E2.empid, E2.lastname, E2.firstname
FROM HR.Employees AS E1
  JOIN HR.Employees AS E2
    ON E1.empid < E2.empid;

-- Calculating Row Numbers using a Join
---------------------------------------------------------------------
-- ͳ����orderid��custid��empid����֮������С��orderid�ĸ���
--10248	85	5	1
--10249	79	6	2
--10250	34	4	3
---------------------------------------------------------------------
SELECT O1.orderid, O1.custid, O1.empid, COUNT(*) AS rn
FROM Sales.Orders AS O1
  JOIN Sales.Orders AS O2
    ON O2.orderid <= O1.orderid
GROUP BY O1.orderid, O1.custid, O1.empid;

---------------------------------------------------------------------
-- Multi-Join Queries
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Controlling the Physical Join Evaluation Order
---------------------------------------------------------------------

-- Listing 7-3 Multi-join query
-- Suppliers that Supplied Products to Customers
---------------------------------------------------------------------
-- ͨ�������ӻ�ȡ�˿ͺ͹�Ӧ��
--Customer AHPOP	Supplier BWGYE
--Customer AHPOP	Supplier ELCRN
--Customer AHPOP	Supplier EQPNC
---------------------------------------------------------------------
SELECT DISTINCT C.companyname AS customer, S.companyname AS supplier
FROM Sales.Customers AS C
  JOIN Sales.Orders AS O
    ON O.custid = C.custid
  JOIN Sales.OrderDetails AS OD
    ON OD.orderid = O.orderid
  JOIN Production.Products AS P
    ON P.productid = OD.productid
  JOIN Production.Suppliers AS S
    ON S.supplierid = P.supplierid;

-- Listing 7-4 Multi-join query, forcing order
-- Controlling the Physical Join Evaluation Order
---------------------------------------------------------------------
-- ͨ�������ӻ�ȡ�˿ͺ͹�Ӧ��,���ǲ��ı�����˳��
--Customer AHPOP	Supplier BWGYE
--Customer AHPOP	Supplier ELCRN
--Customer AHPOP	Supplier EQPNC
---------------------------------------------------------------------
SELECT DISTINCT C.companyname AS customer, S.companyname AS supplier
FROM Sales.Customers AS C
  JOIN Sales.Orders AS O
    ON O.custid = C.custid
  JOIN Sales.OrderDetails AS OD
    ON OD.orderid = O.orderid
  JOIN Production.Products AS P
    ON P.productid = OD.productid
  JOIN Production.Suppliers AS S
    ON S.supplierid = P.supplierid
OPTION (FORCE ORDER);

---------------------------------------------------------------------
-- Controlling the Logical Join Evaluation Order
---------------------------------------------------------------------

-- Including Customers with no Orders, Attempt with Left Join
---------------------------------------------------------------------
-- ͨ���������ӻ�ȡ�˿ͺ͹�Ӧ��,�п����еĿͻ������ڶ���
--Customer AHPOP	Supplier BWGYE
--Customer AHPOP	Supplier ELCRN
--Customer AHPOP	Supplier EQPNC
---------------------------------------------------------------------
SELECT DISTINCT C.companyname AS customer, S.companyname AS supplier
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON O.custid = C.custid
  JOIN Sales.OrderDetails AS OD
    ON OD.orderid = O.orderid
  JOIN Production.Products AS P
    ON P.productid = OD.productid
  JOIN Production.Suppliers AS S
    ON S.supplierid = P.supplierid;

-- Multiple Left Joins
---------------------------------------------------------------------
-- ͨ���������ӻ�ȡ�˿ͺ͹�Ӧ��,�м��κ�һ�����ڶ��п���ΪNULL
--Customer AHPOP	Supplier BWGYE
--Customer AHPOP	Supplier ELCRN
--Customer AHPOP	Supplier EQPNC
---------------------------------------------------------------------
SELECT DISTINCT C.companyname AS customer, S.companyname AS supplier
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON O.custid = C.custid
  LEFT OUTER JOIN Sales.OrderDetails AS OD
    ON OD.orderid = O.orderid
  LEFT OUTER JOIN Production.Products AS P
    ON P.productid = OD.productid
  LEFT OUTER JOIN Production.Suppliers AS S
    ON S.supplierid = P.supplierid;

-- Right Join Performed Last
---------------------------------------------------------------------
-- ͨ���������ӻ�ȡ�˿ͺ͹�Ӧ��,�п����еĿͻ������ڹ�Ӧ��
--Customer AHPOP	Supplier BWGYE
--Customer AHPOP	Supplier ELCRN
--Customer AHPOP	Supplier EQPNC
---------------------------------------------------------------------
SELECT DISTINCT C.companyname AS customer, S.companyname AS supplier
FROM Sales.Orders AS O
  JOIN Sales.OrderDetails AS OD
    ON OD.orderid = O.orderid
  JOIN Production.Products AS P
    ON P.productid = OD.productid
  JOIN Production.Suppliers AS S
    ON S.supplierid = P.supplierid
  RIGHT OUTER JOIN Sales.Customers AS C
    ON O.custid = C.custid;

-- Using Parenthesis
---------------------------------------------------------------------
-- ����������һ������������д
--Customer AHPOP	Supplier BWGYE
--Customer AHPOP	Supplier ELCRN
--Customer AHPOP	Supplier EQPNC
---------------------------------------------------------------------
SELECT DISTINCT C.companyname AS customer, S.companyname AS supplier
FROM Sales.Customers AS C
  LEFT OUTER JOIN
    (     Sales.Orders AS O
     JOIN Sales.OrderDetails AS OD
       ON OD.orderid = O.orderid
     JOIN Production.Products AS P
       ON P.productid = OD.productid
     JOIN Production.Suppliers AS S
       ON S.supplierid = P.supplierid)
    ON O.custid = C.custid;

-- Changing ON Clause Order
---------------------------------------------------------------------
-- ����������һ��
--Customer AHPOP	Supplier BWGYE
--Customer AHPOP	Supplier ELCRN
--Customer AHPOP	Supplier EQPNC
---------------------------------------------------------------------
SELECT DISTINCT C.companyname AS customer, S.companyname AS supplier
FROM Sales.Customers AS C
  LEFT OUTER JOIN
          Sales.Orders AS O
     JOIN Sales.OrderDetails AS OD
       ON OD.orderid = O.orderid
     JOIN Production.Products AS P
       ON P.productid = OD.productid
     JOIN Production.Suppliers AS S
       ON S.supplierid = P.supplierid
    ON O.custid = C.custid;

---------------------------------------------------------------------
-- ����������һ��
--Customer AHPOP	Supplier BWGYE
--Customer AHPOP	Supplier ELCRN
--Customer AHPOP	Supplier EQPNC
---------------------------------------------------------------------
SELECT DISTINCT C.companyname AS customer, S.companyname AS supplier
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
  JOIN Production.Products AS P
  JOIN Sales.OrderDetails AS OD
    ON P.productid = OD.productid
    ON OD.orderid = O.orderid
  JOIN Production.Suppliers AS S
    ON S.supplierid = P.supplierid
    ON O.custid = C.custid;

---------------------------------------------------------------------
-- ����������һ��
--Customer AHPOP	Supplier BWGYE
--Customer AHPOP	Supplier ELCRN
--Customer AHPOP	Supplier EQPNC
---------------------------------------------------------------------
SELECT DISTINCT C.companyname AS customer, S.companyname AS supplier
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
  JOIN Sales.OrderDetails AS OD
  JOIN Production.Products AS P
  JOIN Production.Suppliers AS S
    ON S.supplierid = P.supplierid
    ON P.productid = OD.productid
    ON OD.orderid = O.orderid
    ON O.custid = C.custid;
GO


---------------------------------------------------------------------
-- Set Operations
---------------------------------------------------------------------

---------------------------------------------------------------------
-- UNION
---------------------------------------------------------------------

---------------------------------------------------------------------
-- UNION DISTINCT
---------------------------------------------------------------------

-- UNION DISTINCT
USE InsideTSQL2008;

---------------------------------------------------------------------
-- ���ϲ���ȥ��
--Argentina	NULL	Buenos Aires
--Austria	NULL	Graz
--Austria	NULL	Salzburg
---------------------------------------------------------------------
SELECT country, region, city FROM HR.Employees
UNION
SELECT country, region, city FROM Sales.Customers;

---------------------------------------------------------------------
-- UNION ALL
---------------------------------------------------------------------

-- UNION ALL
---------------------------------------------------------------------
-- ���ϲ�����ȥ��
--Argentina	NULL	Buenos Aires
--Austria	NULL	Graz
--Austria	NULL	Salzburg
---------------------------------------------------------------------
SELECT country, region, city FROM HR.Employees
UNION ALL
SELECT country, region, city FROM Sales.Customers;

---------------------------------------------------------------------
-- EXCEPT
---------------------------------------------------------------------

---------------------------------------------------------------------
-- EXCEPT DISTINCT
---------------------------------------------------------------------

-- EXCEPT DISTINCT, Employees EXCEPT Customers
---------------------------------------------------------------------
-- ���ϲ������HR����������Sales
--USA	WA	Redmond
--USA	WA	Tacoma
---------------------------------------------------------------------
SELECT country, region, city FROM HR.Employees
EXCEPT
SELECT country, region, city FROM Sales.Customers;

-- EXCEPT DISTINCT, Customers EXCEPT Employees
---------------------------------------------------------------------
-- ���ϲ������Sales����������HR
--Austria	NULL	Graz
--Austria	NULL	Salzburg
---------------------------------------------------------------------
SELECT country, region, city FROM Sales.Customers
EXCEPT
SELECT country, region, city FROM HR.Employees;

---------------------------------------------------------------------
-- EXCEPT ALL
---------------------------------------------------------------------
---------------------------------------------------------------------
-- ���ϲ
--���ȶ�ÿһ�������ͬ��country��region��city��Ԫ����б�ţ���Ϊrn
--USA	WA	Redmond
--USA	WA	Tacoma
--USA	WA	Seattle
---------------------------------------------------------------------
WITH EXCEPT_ALL
AS
(
  SELECT
    ROW_NUMBER()
      OVER(PARTITION BY country, region, city
           ORDER     BY (SELECT 0)) AS rn,
    country, region, city
    FROM HR.Employees

  EXCEPT

  SELECT
    ROW_NUMBER()
      OVER(PARTITION BY country, region, city
           ORDER     BY (SELECT 0)) AS rn,
    country, region, city
  FROM Sales.Customers
)
SELECT country, region, city
FROM EXCEPT_ALL;

---------------------------------------------------------------------
-- INTERSCET
---------------------------------------------------------------------

---------------------------------------------------------------------
-- INTERSECT DISTINCT
---------------------------------------------------------------------
---------------------------------------------------------------------
-- ���Ͻ���
--UK	NULL	London
--USA	WA	Kirkland
--USA	WA	Seattle
---------------------------------------------------------------------
SELECT country, region, city FROM HR.Employees
INTERSECT
SELECT country, region, city FROM Sales.Customers;

---------------------------------------------------------------------
-- INTERSECT ALL
---------------------------------------------------------------------
---------------------------------------------------------------------
-- ���Ͻ�����ȥ��
--UK	NULL	London
--USA	WA	Kirkland
--USA	WA	Seattle
--UK	NULL	London
--UK	NULL	London
--UK	NULL	London
---------------------------------------------------------------------
WITH INTERSECT_ALL
AS
(
  SELECT
    ROW_NUMBER()
      OVER(PARTITION BY country, region, city
           ORDER     BY (SELECT 0)) AS rn,
    country, region, city
  FROM HR.Employees

  INTERSECT

  SELECT
    ROW_NUMBER()
      OVER(PARTITION BY country, region, city
           ORDER     BY (SELECT 0)) AS rn,
    country, region, city
    FROM Sales.Customers
)
SELECT country, region, city
FROM INTERSECT_ALL;

---------------------------------------------------------------------
-- Precedence
---------------------------------------------------------------------

-- INTERSECT Precedes EXCEPT
---------------------------------------------------------------------
-- �Ƚ��ٲ�
--Australia	NSW	Sydney
--Australia	Victoria	Melbourne
--Brazil	NULL	Sao Paulo
--Canada	Qu��bec	Montr��al
---------------------------------------------------------------------
SELECT country, region, city FROM Production.Suppliers
EXCEPT
SELECT country, region, city FROM HR.Employees
INTERSECT
SELECT country, region, city FROM Sales.Customers;

-- Using Parenthesis
---------------------------------------------------------------------
-- �Ȳ��ٽ�
--Canada	Qu��bec	Montr��al
--France	NULL	Paris
--Germany	NULL	Berlin
---------------------------------------------------------------------
(SELECT country, region, city FROM Production.Suppliers
 EXCEPT
 SELECT country, region, city FROM HR.Employees)
INTERSECT
SELECT country, region, city FROM Sales.Customers;

-- Using INTO with Set Operations
SELECT country, region, city INTO #T FROM Production.Suppliers
EXCEPT
SELECT country, region, city FROM HR.Employees
INTERSECT
SELECT country, region, city FROM Sales.Customers;

-- Cleanup
DROP TABLE #T;
GO

---------------------------------------------------------------------
-- Circumventing Unsupported Logical Phases
---------------------------------------------------------------------

-- Number of Cities per Country Covered by Both Customers
-- and Employees
---------------------------------------------------------------------
-- ����ÿ�������ж��ټ��й˿����й�Ա�ĳ���
--Argentina	1
--Austria	2
--Belgium	2
--Brazil	4
---------------------------------------------------------------------
SELECT country, COUNT(*) AS numcities
FROM (SELECT country, region, city FROM HR.Employees
      UNION
      SELECT country, region, city FROM Sales.Customers) AS U
GROUP BY country;

-- Two most recent orders for employees 3 and 5
---------------------------------------------------------------------
-- �ҵ�3��5��Ա�������������
--3	11063	2008-04-30 00:00:00.000
--3	11057	2008-04-29 00:00:00.000
--5	11043	2008-04-22 00:00:00.000
--5	10954	2008-03-17 00:00:00.000
---------------------------------------------------------------------
SELECT empid, orderid, orderdate
FROM (SELECT TOP (2) empid, orderid, orderdate
      FROM Sales.Orders
      WHERE empid = 3
      ORDER BY orderdate DESC, orderid DESC) AS D1

UNION ALL

SELECT empid, orderid, orderdate
FROM (SELECT TOP (2) empid, orderid, orderdate
      FROM Sales.Orders
      WHERE empid = 5
      ORDER BY orderdate DESC, orderid DESC) AS D2;

-- Sorting each Input Independently
---------------------------------------------------------------------
-- ���˿�1�����ж�����orderid��������
-- ͬʱ����Ա3�����ж�����orderdate������
-- ͨ��sortcol������
--6	1	10643	2007-08-25 00:00:00.000
--4	1	10692	2007-10-03 00:00:00.000
--4	1	10702	2007-10-13 00:00:00.000
---------------------------------------------------------------------
SELECT empid, custid, orderid, orderdate
FROM (SELECT 1 AS sortcol, custid, empid, orderid, orderdate
      FROM Sales.Orders
      WHERE custid = 1

      UNION ALL

      SELECT 2 AS sortcol, custid, empid, orderid, orderdate
      FROM Sales.Orders
      WHERE empid = 3) AS U
ORDER BY sortcol,
  CASE WHEN sortcol = 1 THEN orderid END,
  CASE WHEN sortcol = 2 THEN orderdate END DESC;


---------------------------------------------------------------------
-- Grouping Factor
---------------------------------------------------------------------

-- Creating and Populating the Stocks Table
USE tempdb;

IF OBJECT_ID('Stocks') IS NOT NULL DROP TABLE Stocks;

CREATE TABLE dbo.Stocks
(
  dt    DATE NOT NULL PRIMARY KEY,
  price INT  NOT NULL
);
GO

INSERT INTO dbo.Stocks(dt, price) VALUES
  ('20090801', 13),
  ('20090802', 14),
  ('20090803', 17),
  ('20090804', 40),
  ('20090805', 40),
  ('20090806', 52),
  ('20090807', 56),
  ('20090808', 60),
  ('20090809', 70),
  ('20090810', 30),
  ('20090811', 29),
  ('20090812', 29),
  ('20090813', 40),
  ('20090814', 45),
  ('20090815', 60),
  ('20090816', 60),
  ('20090817', 55),
  ('20090818', 60),
  ('20090819', 60),
  ('20090820', 15),
  ('20090821', 20),
  ('20090822', 30),
  ('20090823', 40),
  ('20090824', 20),
  ('20090825', 60),
  ('20090826', 60),
  ('20090827', 70),
  ('20090828', 70),
  ('20090829', 40),
  ('20090830', 30),
  ('20090831', 10);

CREATE UNIQUE INDEX idx_price_dt ON Stocks(price, dt);
GO

-- Ranges where Stock Price was >= 50
---------------------------------------------------------------------
-- ����ʹ������Ӳ�ѯ�ҵ����м۸����50������
-- Ȼ����������ֹ��ʱ����飬��dtȡ��С����ȡ�����е�����
--2009-08-06	2009-08-09	4	70
--2009-08-15	2009-08-19	5	60
--2009-08-25	2009-08-28	4	70
---------------------------------------------------------------------
SELECT MIN(dt) AS startrange, MAX(dt) AS endrange,
  DATEDIFF(day, MIN(dt), MAX(dt)) + 1 AS numdays,
  MAX(price) AS maxprice
FROM (SELECT dt, price,
        (SELECT MIN(dt)
         FROM dbo.Stocks AS S2
         WHERE S2.dt > S1.dt
          AND price < 50) AS grp
      FROM dbo.Stocks AS S1
      WHERE price >= 50) AS D
GROUP BY grp;

-- Solution using ROW_NUMBER
---------------------------------------------------------------------
-- ���Ȼ�����м۸����50�����ڣ�������������кţ�
-- Ȼ�������ڼ����Ե��кż�Ϊ��ʼʱ���ǰһ��
-- Ȼ��������俪ʼ��ʱ����飬��dtȡ��󼴿�ȡ�����е�����
--2009-08-06	2009-08-09	4	70
--2009-08-15	2009-08-19	5	60
--2009-08-25	2009-08-28	4	70
---------------------------------------------------------------------
SELECT MIN(dt) AS startrange, MAX(dt) AS endrange,
  DATEDIFF(day, MIN(dt), MAX(dt)) + 1 AS numdays,
  MAX(price) AS maxprice
FROM (SELECT dt, price,
        DATEADD(day, -1 * ROW_NUMBER() OVER(ORDER BY dt), dt) AS grp
      FROM dbo.Stocks AS S1
      WHERE price >= 50) AS D
GROUP BY grp;
GO

---------------------------------------------------------------------
-- Grouping Sets
---------------------------------------------------------------------

-- Code to Create and Populate the Orders Table (same as in Listing 8-1)
SET NOCOUNT ON;
USE tempdb;

IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
GO

CREATE TABLE dbo.Orders
(
  orderid   INT        NOT NULL,
  orderdate DATETIME   NOT NULL,
  empid     INT        NOT NULL,
  custid    VARCHAR(5) NOT NULL,
  qty       INT        NOT NULL,
  CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);
GO

INSERT INTO dbo.Orders
  (orderid, orderdate, empid, custid, qty)
VALUES
  (30001, '20060802', 3, 'A', 10),
  (10001, '20061224', 1, 'A', 12),
  (10005, '20061224', 1, 'B', 20),
  (40001, '20070109', 4, 'A', 40),
  (10006, '20070118', 1, 'C', 14),
  (20001, '20070212', 2, 'B', 12),
  (40005, '20080212', 4, 'A', 10),
  (20002, '20080216', 2, 'C', 20),
  (30003, '20080418', 3, 'B', 15),
  (30004, '20060418', 3, 'C', 22),
  (30007, '20060907', 3, 'D', 30);

---------------------------------------------------------------------
-- GROUPING SETS Subclause
---------------------------------------------------------------------
---------------------------------------------------------------------
-- ��group by( custid, empid, YEAR(orderdate) )
-- ��group by( custid, YEAR(orderdate)
-- ��group by( empid, YEAR(orderdate)         )
-- �Ͳ�����
-- �Ľ����������ͳ�Ƹ���
--A	1	2006	12
--B	1	2006	20
--NULL	1	2006	32
--C	1	2007	14
--NULL	1	2007	14
--B	2	2007	12
---------------------------------------------------------------------
SELECT custid, empid, YEAR(orderdate) AS orderyear, SUM(qty) AS qty
FROM dbo.Orders
GROUP BY GROUPING SETS
(
  ( custid, empid, YEAR(orderdate) ),
  ( custid, YEAR(orderdate)        ),
  ( empid, YEAR(orderdate)         ),
  ()
);

-- Logically equivalent to unifying multiple aggregate queries:

---------------------------------------------------------------------
-- ����������һ��
--A	1	2006	12
--A	3	2006	10
--A	4	2007	40
--A	4	2008	10
---------------------------------------------------------------------
SELECT custid, empid, YEAR(orderdate) AS orderyear, SUM(qty) AS qty
FROM dbo.Orders
GROUP BY custid, empid, YEAR(orderdate)

UNION ALL

SELECT custid, NULL AS empid, YEAR(orderdate) AS orderyear, SUM(qty) AS qty
FROM dbo.Orders
GROUP BY custid, YEAR(orderdate)

UNION ALL

SELECT NULL AS custid, empid, YEAR(orderdate) AS orderyear, SUM(qty) AS qty
FROM dbo.Orders
GROUP BY empid, YEAR(orderdate)

UNION ALL

SELECT NULL AS custid, NULL AS empid, NULL AS orderyear, SUM(qty) AS qty
FROM dbo.Orders;

---------------------------------------------------------------------
-- CUBE Subclause
---------------------------------------------------------------------

---------------------------------------------------------------------
-- ��custid��empid��ͬά�ȵ���Ϸ���
--A	1	12
--B	1	20
--C	1	14
--NULL	1	46
---------------------------------------------------------------------
SELECT custid, empid, SUM(qty) AS qty
FROM dbo.Orders
GROUP BY CUBE(custid, empid);

-- Equivalent to:
---------------------------------------------------------------------
-- ��������ͬ
--A	1	12
--B	1	20
--C	1	14
--NULL	1	46
---------------------------------------------------------------------
SELECT custid, empid, SUM(qty) AS qty
FROM dbo.Orders
GROUP BY GROUPING SETS
  (
    ( custid, empid ),
    ( custid        ),
    ( empid         ),
    ()
  );

-- Pre-2008 CUBE option
---------------------------------------------------------------------
-- ��������ͬ
--A	1	12
--B	1	20
--C	1	14
--NULL	1	46
---------------------------------------------------------------------
SELECT custid, empid, SUM(qty) AS qty
FROM dbo.Orders
GROUP BY custid, empid
WITH CUBE;

---------------------------------------------------------------------
-- ROLLUP Subclause
---------------------------------------------------------------------
---------------------------------------------------------------------
-- rollup������grouping set�ļ�д
-- ����Ҫע��˳��
--2006	4	18	22
--2006	4	NULL	22
--2006	8	2	10
---------------------------------------------------------------------
SELECT
  YEAR(orderdate) AS orderyear,
  MONTH(orderdate) AS ordermonth,
  DAY(orderdate) AS orderday,
  SUM(qty) AS qty
FROM dbo.Orders
GROUP BY
  ROLLUP(YEAR(orderdate), MONTH(orderdate), DAY(orderdate));

-- Equivalent to:
---------------------------------------------------------------------
-- ��������ͬ
--2006	4	18	22
--2006	4	NULL	22
--2006	8	2	10
---------------------------------------------------------------------
SELECT
  YEAR(orderdate) AS orderyear,
  MONTH(orderdate) AS ordermonth,
  DAY(orderdate) AS orderday,
  SUM(qty) AS qty
FROM dbo.Orders
GROUP BY
  GROUPING SETS
  (
    ( YEAR(orderdate), MONTH(orderdate), DAY(orderdate) ),
    ( YEAR(orderdate), MONTH(orderdate)                 ),
    ( YEAR(orderdate)                                   ),
    ()
  );

-- Pre-2008 ROLLUP option
---------------------------------------------------------------------
-- ��������ͬ
--2006	4	18	22
--2006	4	NULL	22
--2006	8	2	10
---------------------------------------------------------------------
SELECT
  YEAR(orderdate) AS orderyear,
  MONTH(orderdate) AS ordermonth,
  DAY(orderdate) AS orderday,
  SUM(qty) AS qty
FROM dbo.Orders
GROUP BY YEAR(orderdate), MONTH(orderdate), DAY(orderdate)
WITH ROLLUP;


---------------------------------------------------------------------
-- GROUPING_ID Function
---------------------------------------------------------------------
---------------------------------------------------------------------
--0	C	3	2006	4	18	22
--16	NULL	3	2006	4	18	22
--24	NULL	NULL	2006	4	18	22
---------------------------------------------------------------------
SELECT
  GROUPING_ID(
    custid, empid,
    YEAR(orderdate), MONTH(orderdate), DAY(orderdate) ) AS grp_id,
  custid, empid,
  YEAR(orderdate) AS orderyear,
  MONTH(orderdate) AS ordermonth,
  DAY(orderdate) AS orderday,
  SUM(qty) AS qty
FROM dbo.Orders
GROUP BY
  CUBE(custid, empid),
  ROLLUP(YEAR(orderdate), MONTH(orderdate), DAY(orderdate));

---------------------------------------------------------------------
-- ͨ��group idģ���������
--0	0	0	0	0	0
--1	0	0	0	0	1
--2	0	0	0	1	0
---------------------------------------------------------------------
SELECT
  GROUPING_ID(e, d, c, b, a) as n,
  COALESCE(e, 1) as [16],
  COALESCE(d, 1) as [8],
  COALESCE(c, 1) as [4],
  COALESCE(b, 1) as [2],
  COALESCE(a, 1) as [1]
FROM (VALUES(0, 0, 0, 0, 0)) AS D(a, b, c, d, e)
GROUP BY CUBE (a, b, c, d, e)
ORDER BY n;

-- Pre-2008, Identifying Grouping Set
---------------------------------------------------------------------
-- ģ��group id
--0	A	1	2006	12
--0	B	1	2006	20
--4	NULL	1	2006	32
---------------------------------------------------------------------
SELECT
  GROUPING(custid)          * 4 +
  GROUPING(empid)           * 2 +
  GROUPING(YEAR(orderdate)) * 1 AS grp_id,
  custid, empid, YEAR(orderdate) AS orderyear,
  SUM(qty) AS totalqty
FROM dbo.Orders
GROUP BY custid, empid, YEAR(orderdate)
WITH CUBE;
