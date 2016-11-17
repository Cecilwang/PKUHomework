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

SELECT custid, empid, YEAR(orderdate) AS orderyear, SUM(qty) AS qty
FROM dbo.Orders
GROUP BY GROUPING SETS
(
  ( custid, empid, YEAR(orderdate) ),
  ( custid, YEAR(orderdate)        ),
  ( empid, YEAR(orderdate)         ),
  ()
);