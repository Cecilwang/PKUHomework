---------------------------------------------------------------------
-- Inside Microsoft SQL Server 2008: T-SQL Querying (MSPress, 2009)
-- Chapter 06 - Subqueries, Table Expressions and Ranking Functions
-- Copyright Itzik Ben-Gan, 2009
-- All Rights Reserved
---------------------------------------------------------------------

---------------------------------------------------------------------
--注：
--由于select是选定在from和where限定条件下的元组的属性
--故，在后续注释中将不再说明select选定的属性，
--我将把注释主要用于说明from和where限定下的元组
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Subqueries
---------------------------------------------------------------------

-- Scalar subquery
---------------------------------------------------------------------
--找到最大订单号
--11077	65
---------------------------------------------------------------------
SET NOCOUNT ON;
USE InsideTSQL2008;

SELECT orderid, custid
FROM Sales.Orders
WHERE orderid = (SELECT MAX(orderid) FROM Sales.Orders);

-- Correlated subquery
---------------------------------------------------------------------
--找到每个顾客的最大订单号
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
--找到在每个顾客对应的公司
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
--找到每年的最大订单号
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
--找到lastname为N'Davis'的雇员的所有订单号
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
--找到与1,2,3,4,8五个雇员全部有交易的顾客
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
--找到与所有北美雇员全部有交易的顾客
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
--找到每年每月最晚一天的所有交易记录
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
-- 建立索引
---------------------------------------------------------------------
CREATE UNIQUE INDEX idx_eid_od_oid
  ON Sales.Orders(empid, orderdate, orderid);
CREATE UNIQUE INDEX idx_eid_od_rd_oid
  ON Sales.Orders(empid, orderdate, requireddate, orderid);
GO

-- Orders with the maximum orderdate for each employee
-- Incorrect solution
---------------------------------------------------------------------
-- 首先列出所有雇员的最后交易日期
-- 然后列出所有发生在这些日期中的交易
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
-- 找到每个雇员最后一次交易的日期及当天发生的所有交易
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
-- 找到每个雇员最后一天交易中订单号最大的交易
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
-- 找到每个雇员最后一天交易中订单号最大的交易
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
-- 找到每个雇员最后一天交易中请求日期最大的交易，若有相同在根据订单号排序
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
-- 所有来自西班牙的有交易顾客
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
-- 所有来自西班牙的有交易的顾客
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
-- 所有来自西班牙的没有交易的顾客
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
-- 所有来自西班牙的没有交易的顾客
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
-- 所有来自西班牙的没有交易的顾客且custid不是NULL
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
-- 雇员的卡氏积
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
-- 雇员的卡氏积
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
-- Salces.Customers,HR.Employees,dbo.Numbs的卡氏积
-- 但只取出2009年1月1日之后31天的内容
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
-- 求每个订单value所占的总订单的百分比，以及与平均值的差
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
-- 求每个订单value所占的总订单的百分比，以及与平均值的差
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
-- 内连接，且顾客来自美国
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
-- 内连接，且顾客来自美国
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
-- 笛卡尔积
--72	Customer AHPOP	10248
--72	Customer AHPOP	10249
--72	Customer AHPOP	10250
---------------------------------------------------------------------
SELECT C.custid, companyname, orderid
FROM Sales.Customers AS C, Sales.Orders AS O;
GO

-- Forgetting to Specify Join Condition, ANSI SQL:1989
---------------------------------------------------------------------
--语法错误
---------------------------------------------------------------------
SELECT C.custid, companyname, orderid
FROM Sales.Customers AS C JOIN Sales.Orders AS O;
GO

---------------------------------------------------------------------
-- OUTER
---------------------------------------------------------------------

-- Outer Join, ANSI SQL:1992
---------------------------------------------------------------------
-- 外连接
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
-- 语法错误
---------------------------------------------------------------------
-- Outer Join, Old-Style Non-ANSI
SELECT C.custid, companyname, orderid
FROM Sales.Customers AS C, Sales.Orders AS O
WHERE C.custid *= O.custid;
GO

-- Outer Join with Filter, ANSI SQL:1992
---------------------------------------------------------------------
-- 左外连接
--22	Customer DTDMN	NULL
--57	Customer WVAXS	NULL
---------------------------------------------------------------------
SELECT C.custid, companyname, orderid
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON C.custid = O.custid
WHERE O.custid IS NULL;

---------------------------------------------------------------------
-- 语法错误
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
-- 找到最小的keycol的断点，即不连续
--5
---------------------------------------------------------------------
SELECT MIN(A.keycol) + 1
FROM dbo.T1 AS A
WHERE NOT EXISTS
  (SELECT * FROM dbo.T1 AS B
   WHERE B.keycol = A.keycol + 1);

-- Using Outer Join to Find Minimum Missing Value
---------------------------------------------------------------------
-- 找到最小的keycol的断点，即不连续
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
-- 内连接
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
-- 左外连接，只在mgrid与empid属性上连接
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
-- 当E1的empid小于E2的empid时连接
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
-- 统计以orderid，custid，empid分组之后满足小于orderid的个数
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
-- 通过内连接获取顾客和供应商
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
-- 通过内连接获取顾客和供应商,但是不改变连接顺序
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
-- 通过左外连接获取顾客和供应商,有可能有的客户不存在订单
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
-- 通过左外连接获取顾客和供应商,中间任何一个环节都有可能为NULL
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
-- 通过右外连接获取顾客和供应商,有可能有的客户不存在供应商
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
-- 与上述功能一样，改用括号写
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
-- 与上述功能一样
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
-- 与上述功能一样
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
-- 与上述功能一样
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
-- 集合并，去重
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
-- 集合并，不去重
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
-- 集合差，出现在HR但不出现在Sales
--USA	WA	Redmond
--USA	WA	Tacoma
---------------------------------------------------------------------
SELECT country, region, city FROM HR.Employees
EXCEPT
SELECT country, region, city FROM Sales.Customers;

-- EXCEPT DISTINCT, Customers EXCEPT Employees
---------------------------------------------------------------------
-- 集合差，出现在Sales但不出现在HR
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
-- 集合差，
--首先对每一组具有相同的country、region、city的元组进行编号，作为rn
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
-- 集合交，
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
-- 集合交，不去重
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
-- 先交再差
--Australia	NSW	Sydney
--Australia	Victoria	Melbourne
--Brazil	NULL	Sao Paulo
--Canada	Québec	Montréal
---------------------------------------------------------------------
SELECT country, region, city FROM Production.Suppliers
EXCEPT
SELECT country, region, city FROM HR.Employees
INTERSECT
SELECT country, region, city FROM Sales.Customers;

-- Using Parenthesis
---------------------------------------------------------------------
-- 先差再交
--Canada	Québec	Montréal
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
-- 计算每个国家有多少既有顾客又有雇员的城市
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
-- 找到3、5雇员最近的两个订单
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
-- 将顾客1的所有订单按orderid升序排序
-- 同时将雇员3的所有订单按orderdate升序降序
-- 通过sortcol来控制
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
-- 首先使用相关子查询找到所有价格大于50的区间
-- 然后根据区间截止的时间分组，对dt取最小即可取到所有的区间
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
-- 首先获得所有价格大于50的日期，按升序排序给行号，
-- 然后用日期减各自的行号即为开始时间的前一天
-- 然后根据区间开始的时间分组，对dt取最大即可取到所有的区间
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
-- 将group by( custid, empid, YEAR(orderdate) )
-- 和group by( custid, YEAR(orderdate)
-- 和group by( empid, YEAR(orderdate)         )
-- 和不分组
-- 的结果并起来并统计个数
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
-- 和上述操作一样
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
-- 按custid，empid不同维度的组合分组
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
-- 与上述相同
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
-- 与上述相同
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
-- rollup操作是grouping set的简写
-- 但是要注意顺序
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
-- 与上述相同
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
-- 与上述相同
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
-- 通过group id模拟二进制数
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
-- 模拟group id
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
