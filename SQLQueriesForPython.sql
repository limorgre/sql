GO
CREATE VIEW PolicyDetails1
AS
SELECT PD.PolicyId, PD.InsuredID, PD.InsProductId, PD.InsuredStatus, PD.Policy_Start_Date, PD.Policy_End_Date, PD.Policy_End_Reason
, PD.Price_Before_Discuont1, ISNULL( PD.DiscountPackageID, 100000) AS DiscountPackageID , PD.CompensationSum, PD.Smoke
FROM PolicyDetails PD
GO

GO
CREATE VIEW SALES
AS
SELECT PD.PolicyId, PD.Policy_Start_Date, PD.Price_Before_Discuont1, ISNULL(PD.DiscountPackageID,100000) AS DiscountPackageID, DP.Discount, PD.Price_Before_Discuont1*(1-DP.Discount) AS Price_After_Discount
, M.EmployeeId, M.LastName+' '+M.FirstName AS 'Marketer''s_Name' 
FROM  PolicyDetails1 PD JOIN Policy P
ON P.PolicyId=PD.PolicyId
	JOIN Marketers M
ON M.EmployeeId=P.EmployeeID
	JOIN DiscountPackage DP	
ON PD.DiscountPackageID=DP.DiscountPackageID
GO

GO
CREATE VIEW PolicyDetails2
AS
SELECT PD.PolicyId, PD.InsProductId, IP.InsProductName, IP.InsCategoryId, IC.InsCategoryName,  PD.Policy_Start_Date, PD.Policy_End_Date, PD.Policy_End_Reason
, PD.Price_Before_Discuont1, DP.Discount, PD.Price_Before_Discuont1*(1-DP.Discount) AS Price_After_Discount , PD.CompensationSum, PD.Smoke
, M.EmployeeId, M.LastName+' '+M.FirstName AS 'Marketer''s_Name'  
FROM  PolicyDetails1 PD JOIN Customers C
ON C.Id=PD.InsuredID
	JOIN InsProducts IP
ON PD.InsProductId=IP.InsProductId
	JOIN InsCategory IC
ON IP.InsCategoryId=IC.InsCategoryId
	JOIN DiscountPackage DP	
ON PD.DiscountPackageID=DP.DiscountPackageID
	JOIN Policy P
ON P.PolicyId=PD.PolicyId
	JOIN Marketers M
ON P.EmployeeID=M.EmployeeId

GO


SELECT *
FROM PolicyDetails2

SELECT *
FROM DiscountPackage


GO
CREATE VIEW PolicyDetails3
AS
SELECT PD.PolicyId, PD.InsuredID, PD.InsProductId, IP.InsProductName, IP.InsCategoryId, IC.InsCategoryName,  PD.Policy_Start_Date, PD.Policy_End_Date, PD.Policy_End_Reason
, PD.Price_Before_Discuont1, DP.Discount, PD.Price_Before_Discuont1*(1-DP.Discount) AS Price_After_Discount , PD.CompensationSum, PD.Smoke
,C.BirthDate,C.Gender,C.Salary 
FROM  PolicyDetails1 PD JOIN InsProducts IP
ON PD.InsProductId=IP.InsProductId
	JOIN InsCategory IC
ON IP.InsCategoryId=IC.InsCategoryId
	JOIN DiscountPackage DP	
ON PD.DiscountPackageID=DP.DiscountPackageID 
	JOIN Customers C
ON C.Id=PD.InsuredID

GO

SELECT * FROM PolicyDetails3

select *
from PolicyDetails



GO
CREATE VIEW PolicyDetails4
AS
SELECT PD.PolicyId, PD.InsuredID, PD.InsuredStatus, DATEDIFF(YY,C.BirthDate,GETDATE()) AS Age
, PD.Price_Before_Discuont1*(1-DP.Discount) AS Price_After_Discount ,C.Salary 
FROM  PolicyDetails1 PD JOIN DiscountPackage DP	
ON PD.DiscountPackageID=DP.DiscountPackageID 
	JOIN Customers C
ON C.Id=PD.InsuredID

GO

SELECT * FROM PolicyDetails4




GO
CREATE VIEW SalesRelationship
AS
SELECT TBL.InsuredID, TBL.InsuredStatus, TBL.PolicyId, TBL.PoliciesTotalSum, AVG(TBL.Salary)OVER(PARTITION BY TBL.PolicyId) AS AvgSalary
, AVG(TBL.Age)OVER(PARTITION BY TBL.PolicyId) AS AvgAge  
FROM(SELECT DISTINCT PD.InsuredID, PD.InsuredStatus, PD.PolicyId 
     ,SUM(PD.Price_Before_Discuont1*(1-DP.Discount))OVER(PARTITION BY PD.PolicyId) AS PoliciesTotalSum
     ,C.Salary, DATEDIFF(YY,C.BirthDate,GETDATE()) AS Age
     FROM PolicyDetails1 PD JOIN Customers C
     ON PD.InsuredID=C.Id
	  JOIN DiscountPackage DP
     ON PD.DiscountPackageID=DP.DiscountPackageID
     WHERE PD.InsuredStatus=1 OR PD.InsuredStatus=2)TBL
WHERE TBL.InsuredStatus=1






