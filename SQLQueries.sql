--Question 1

USE AdventureWorks2022
SELECT P.ProductID, P.Name, P.Color, P.ListPrice, P.Size
FROM Production.Product P
WHERE P.ProductID IN (SELECT PR.ProductID
		      FROM Production.Product PR
		      EXCEPT
		      SELECT SOD.ProductID
		      FROM Sales.SalesOrderDetail SOD)

--Question 2
/* The database schema is one in which customer details who have never placed an order are not stored. Therefore, all customers who have not placed an order are
essentially customer codes without any additional details*/
 SELECT CU.CustomerID, IIF(CU.PersonID  IS NULL, 'Unknown', CAST(CU.PersonID AS VARCHAR) )AS Name --NULL  Their identification in the PERSON table is by the PERSONID         
 FROM   Sales.Customer CU
 WHERE  CU.CustomerID IN (SELECT C.CustomerID--701 Customers who have not placed orders
			  FROM Sales.Customer C
			  EXCEPT
			  SELECT SOH.CustomerID
			  FROM Sales.SalesOrderHeader SOH)
 

 --Another way to solve
 SELECT CU.CustomerID, IIF(CU.PersonID  IS NULL, 'Unknown', CAST(CU.PersonID AS VARCHAR) )AS Name --NULL  Their identification in the PERSON table is by the PERSONID 
 FROM   Sales.Customer CU
 WHERE  CU.CustomerID IN(SELECT C.CustomerID
			 FROM Sales.Customer C LEFT JOIN Sales.SalesOrderHeader SOH
			 ON C.CustomerID=SOH.CustomerID
			 WHERE SOH.SalesOrderID IS NULL)



--Question 3
SELECT TOP 10 SOH.CustomerID, p.FirstName, p.LastName,COUNT(SOH.SalesOrderID)AS CountOfOrders
FROM Sales.SalesOrderHeader SOH JOIN Sales.Customer C
ON SOH.CustomerID=C.CustomerID
	JOIN Person.Person P
ON C.PersonID=P.BusinessEntityID
GROUP BY SOH.CustomerID, p.FirstName, p.LastName
ORDER BY CountOfOrders DESC, SOH.CustomerID 


--Question 4
SELECT TBL.FirstName, TBL.LastName, TBL.JobTitle, TBL.HireDate, TBL.CountOfTitle
FROM (SELECT E.BusinessEntityID,  P.FirstName,P.LastName, E.JobTitle, E.HireDate, COUNT(*)OVER(PARTITION BY E.JobTitle)AS CountOfTitle
      FROM HumanResources.Employee E JOIN Person.Person P
      ON E.BusinessEntityID=P.BusinessEntityID)TBL
ORDER BY TBL.JobTitle


--Question 5
-- Display customers who have placed either one order or two different orders on the same day
WITH CTE1
AS
(SELECT SOH.SalesOrderID, SOH.CustomerID, P.LastName, P.FirstName,SOH.OrderDate
,LAG(SOH.OrderDate,1)OVER(PARTITION BY SOH.CustomerID ORDER BY SOH.OrderDate )AS PreviousOrder 
,DENSE_RANK()OVER(PARTITION BY SOH.CustomerID ORDER BY SOH.OrderDate DESC) AS DNR 
FROM Sales.SalesOrderHeader SOH JOIN Sales.Customer C
ON SOH.CustomerID=C.CustomerID
	JOIN Person.Person P
ON C.PersonID=P.BusinessEntityID)
SELECT SalesOrderID, CustomerID, LastName, FirstName, OrderDate AS LastOrder, PreviousOrder
FROM CTE1
WHERE DNR=1 


--Question 6
SELECT "Year", SalesOrderID, LastName, FirstName, FORMAT(ROUND(Total,1),'#,#.0')AS Total
FROM( SELECT YEAR(SOH.OrderDate)AS "Year",SOD.SalesOrderID ,P.LastName, P.FirstName ,SUM(SOD.UnitPrice*(1-SOD.UnitPriceDiscount)*SOD.OrderQty)AS Total
     ,DENSE_RANK()OVER(PARTITION BY YEAR(SOH.OrderDate) ORDER BY SUM(SOD.UnitPrice*(1-SOD.UnitPriceDiscount)*SOD.OrderQty) DESC)AS DRK
      FROM Sales.SalesOrderDetail SOD JOIN Sales.SalesOrderHeader SOH
      ON SOD.SalesOrderID=SOH.SalesOrderID
	   JOIN Sales.Customer C
      ON C.CustomerID=SOH.CustomerID
	   JOIN Person.Person P
      ON C.PersonID=P.BusinessEntityID
      GROUP BY SOD.SalesOrderID, YEAR(SOH.OrderDate), P.LastName, P.FirstName)TBL
WHERE DRK=1


--Question 7
SELECT "Month",[2011],[2012],[2013],[2014]
FROM(SELECT YEAR(SOH.OrderDate)AS YY, MONTH(SOH.OrderDate)AS "Month", SOH.SalesOrderID FROM Sales.SalesOrderHeader SOH)TBL
PIVOT(COUNT(TBL.SalesOrderID) FOR YY IN([2011],[2012],[2013],[2014]))PVT
ORDER BY "Month"


--Question 8
GO
CREATE VIEW LIM
AS
SELECT TBL.Year, CAST(TBL.MONTH AS NVARCHAR)AS "Month" , ROUND(TBL.Sum_Price,2 )AS Sum_Price
,ROUND(SUM(TBL.Sum_Price)OVER(PARTITION BY TBL.Year ORDER BY TBL.Year, TBL.Month),2)AS CumSum
FROM  ( SELECT YEAR(SOH.OrderDate)AS "Year" , MONTH(SOH.OrderDate)AS "Month" 
	,SUM(SOD.UnitPrice*(1-SOD.UnitPriceDiscount)*SOD.OrderQty)AS Sum_Price
	FROM Sales.SalesOrderDetail SOD JOIN Sales.SalesOrderHeader SOH
	ON SOD.SalesOrderID=SOH.SalesOrderID
	GROUP BY YEAR(SOH.OrderDate), MONTH(SOH.OrderDate))TBL
 
GO
SELECT LIM.Year, LIM.Month, LIM.Sum_Price, LIM.CumSum
FROM LIM

UNION

(SELECT LIM.YEAR, 'grand_total', NULL, ROUND(SUM(LIM.Sum_Price),2)
FROM LIM
GROUP BY LIM.YEAR)
ORDER BY LIM.YEAR, LIM.CumSum  


--Another way to solve 
GO
SELECT TBL.Year,CAST(TBL.Month AS VARCHAR)AS "Month",  FORMAT(TBL.Sum_Price,'#.00' )AS Sum_Price
,FORMAT(SUM(TBL.Sum_Price)OVER(PARTITION BY TBL.Year ORDER BY TBL.Year, TBL.Month),'#.00')AS CumSum
FROM(SELECT YEAR(SOH.OrderDate)AS "Year" ,MONTH(SOH.OrderDate)AS "Month" 
     ,SUM(SOD.UnitPrice*(1-SOD.UnitPriceDiscount)*SOD.OrderQty)AS Sum_Price
     FROM Sales.SalesOrderHeader SOH JOIN Sales.SalesOrderDetail SOD
     ON SOH.SalesOrderID=SOD.SalesOrderID
     GROUP BY YEAR(SOH.OrderDate), MONTH(SOH.OrderDate))TBL

UNION

(SELECT TBL1.Year, 'grand_total', NULL, ROUND(SUM(TBL1.Sum_Price),2)
 FROM (SELECT YEAR(SOH.OrderDate)AS "Year" ,MONTH(SOH.OrderDate)AS "Month" 
       ,SUM(SOD.UnitPrice*(1-SOD.UnitPriceDiscount)*SOD.OrderQty)AS Sum_Price
	FROM Sales.SalesOrderHeader SOH JOIN Sales.SalesOrderDetail SOD
	ON SOH.SalesOrderID=SOD.SalesOrderID
	GROUP BY YEAR(SOH.OrderDate), MONTH(SOH.OrderDate))TBL1
 GROUP BY TBL1.Year)
 ORDER BY  "Year",CumSum



--Question 9

--Display every employee in the company in his current department as well as in previous departments, including those who arrived before him in the current department
--and previous departments. Show the complete department history of the employee. An employee can appear more than once in the table
SELECT D.Name AS DepartmentName, E.BusinessEntityID AS 'Employee''sId', P.FirstName+' '+P.LastName AS 'Employee''sFullName', E.HireDate
,DATEDIFF(MM,E.HireDate, GETDATE())AS Seniority
,LEAD(P.FirstName+' '+P.LastName)OVER(PARTITION BY D.Name ORDER BY E.HireDate DESC)AS PreviusEmpName
,LEAD(E.HireDate)OVER(PARTITION BY D.Name ORDER BY E.HireDate DESC)AS PreviusEmpHDate
,DATEDIFF(DD, LEAD(E.HireDate)OVER(PARTITION BY D.Name ORDER BY E.HireDate DESC),E.HireDate )AS DiffDays
FROM HumanResources.Employee E JOIN HumanResources.EmployeeDepartmentHistory EDH
ON E.BusinessEntityID=EDH.BusinessEntityID
	JOIN HumanResources.Department D
ON EDH.DepartmentID=D.DepartmentID
	JOIN Person.Person P
ON E.BusinessEntityID=P.BusinessEntityID



--Question 10
SELECT E.HireDate, EDH.DepartmentID, STRING_AGG(CONCAT_WS(' ',E.BusinessEntityID, P.LastName,P.FirstName), ',') AS TeamEmployees 
FROM HumanResources.Employee E JOIN HumanResources.EmployeeDepartmentHistory EDH
ON E.BusinessEntityID=EDH.BusinessEntityID
	JOIN Person.Person P
ON E.BusinessEntityID=P.BusinessEntityID
WHERE EDH.EndDate IS NULL
GROUP BY E.HireDate, EDH.DepartmentID
ORDER BY E.HireDate DESC, EDH.DepartmentID 






