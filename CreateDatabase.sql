USE master;

GO

IF EXISTS (SELECT * FROM sysdatabases WHERE NAME = 'MenoraMivt')
	DROP DATABASE MenoraMivt;
GO

CREATE DATABASE MenoraMivt;

GO

USE MenoraMivt;

GO


CREATE TABLE InsCategory --Product Categories Table
(InsCategoryId INT CONSTRAINT InsCategory_InsCategoryId_pk PRIMARY KEY,
 InsCategoryName VARCHAR(30) NOT NULL,
 InsCategoryDescription VARCHAR(200) 
 )
 
GO

CREATE TABLE DiscountPackage  --Discount Packages Table-Each product is entitled to one discount package for use
(DiscountPackageID INT CONSTRAINT DiscountPackage_DiscountPackageID_pk PRIMARY KEY ,
 Discount REAL NOT NULL,
 NumOfYears INT NOT NULL, 
 StartDate DATE NOT NULL,
 EndDate DATE 
 )

 GO

CREATE TABLE InsProducts --Insurance products table
(InsProductId INT CONSTRAINT InsProducts_InsProductId_pk PRIMARY KEY,
 InsProductName VARCHAR(50) NOT NULL,
 InsCategoryId INT NOT NULL CONSTRAINT InsProducts_InsCategoryId_fk FOREIGN KEY REFERENCES InsCategory(InsCategoryId) ,
 DiscountPackageID INT CONSTRAINT InsProducts_DiscountPackageID_fk FOREIGN KEY REFERENCES DiscountPackage(DiscountPackageID),--Discount package today is a fixed percentage discount for a number of years for each product
 "Indemnity or compensation" VARCHAR(2) NOT NULL, -- Is the product a compensation or indemnity type product
 StartDate DATE NOT NULL,
 EndDate DATE,
 Details VARCHAR(200) NULL
 )
 
GO

CREATE TABLE Marketers 
(EmployeeId INT IDENTITY CONSTRAINT Marketers_EmployeeId_pk PRIMARY KEY,
 FirstName VARCHAR(15) NOT NULL,
 LastName VARCHAR(15) NOT NULL,
 Phone VARCHAR(11) NOT NULL CONSTRAINT Marketers_Phone_uk UNIQUE,
 EMail VARCHAR(50) NOT NULL CONSTRAINT Marketers_EMail_uk UNIQUE,
 Street VARCHAR(20) NOT NULL,
 Number VARCHAR(4) NOT NULL,
 City VARCHAR(15) NOT NULL,
 BirthDate DATE NOT NULL,
 HireDate DATE DEFAULT GETDATE() NOT NULL,
 CONSTRAINT Marketers_Phone_ck CHECK(len(Phone)=11),
 CONSTRAINT Marketers_EMail_ck CHECK(EMail LIKE '%@%.%')
 )
   
GO

CREATE TABLE CreditCards --Credit details can be those of the customer or any immediate family member who is not a customer
( CardNumber VARCHAR(20)  CONSTRAINT CreditCards_CardNumber_pk PRIMARY KEY,
 CardType VARCHAR(25) NOT NULL, 
 ExpMonth INT NOT NULL,
 ExpYear INT NOT NULL,
 Num_3 VARCHAR(5) NOT NULL,--digits on the back of the credit card
 CreditOwnerId VARCHAR(9) NOT NULL,--ID number of the credit card holder
 Lname VARCHAR(15) NOT NULL,
 Fname VARCHAR(10) NOT NULL,
 )

 GO

CREATE TABLE Customers --Customer table = main insured/secondary/children details
(Id VARCHAR(9) CONSTRAINT Customers_ID_pk PRIMARY KEY,
 Lname VARCHAR(15) NOT NULL,
 Fname VARCHAR(10) NOT NULL,
 Phone VARCHAR(11) NOT NULL,
 Street VARCHAR(15) NOT NULL,
 Number VARCHAR(4) NOT NULL,
 City VARCHAR(15) NOT NULL,
 EMail VARCHAR(30) NULL CONSTRAINT Customers_EMail_ck CHECK(EMail LIKE '%@%.%'),
 BirthDate DATE NOT NULL,
 Merital_Status VARCHAR(2) NOT NULL,--s/m/d
 Gender VARCHAR(2) NOT NULL,--m/f
 Salary MONEY NULL
 )

 GO 

CREATE TABLE Direct_Debit --Bank details of the main/secondary insured = Customers
(BankNumber VARCHAR(5),
 BranchNumber VARCHAR(5),
 AccountNumber VARCHAR(15),
 BankName VARCHAR(15) NULL, 
 BranchName VARCHAR(20) NULL,
 AccountOwnerID VARCHAR(9) NOT NULL CONSTRAINT Customers_ID_fk FOREIGN KEY REFERENCES Customers(Id)
 CONSTRAINT Direct_Debit_BankNumber_BranchNumber_AccountNumber_pk PRIMARY KEY (BankNumber, BranchNumber, AccountNumber) 
 )

GO


CREATE TABLE "Policy"  --Policies Table
(PolicyId VARCHAR(15) CONSTRAINT Policy_PolicyId_pk PRIMARY KEY,
 EmployeeID INT NOT NULL CONSTRAINT Policy_EmployeeID_fk FOREIGN KEY REFERENCES Marketers(EmployeeID) , --Marketer's ID
 CardNumber VARCHAR(20) NULL CONSTRAINT Policy_CardNumber_fk FOREIGN KEY REFERENCES CreditCards(CardNumber),
 BankNumber VARCHAR(5),
 BranchNumber VARCHAR(5),
 AccountNumber VARCHAR(15), 
 CONSTRAINT Policy_BankNumber_BranchNumber_AccountNumber_fk FOREIGN KEY (BankNumber, BranchNumber, AccountNumber) REFERENCES Direct_Debit(BankNumber, BranchNumber, AccountNumber)
 )

 GO 

 

 CREATE TABLE PolicyDetails  --Policy Details Table
(PolicyId VARCHAR(15) CONSTRAINT PolicyDetails_PolicyId_fk FOREIGN KEY REFERENCES Policy(PolicyId), 
 InsuredID VARCHAR(9) CONSTRAINT PolicyDetails_InsuredID_fk FOREIGN KEY REFERENCES Customers(ID), --ID number of the main insured/secondary insured/children
 InsProductId INT CONSTRAINT PolicyDetails_InsProductId_fk FOREIGN KEY REFERENCES  InsProducts(InsProductId), --Insurance product number
 InsuredStatus INT NOT NULL, --Insured status: 1=Primary 2=Secondary 3=Children
 Policy_Start_Date DATE NOT NULL,
 Policy_End_Date DATE NULL,
 Policy_End_Reason VARCHAR(15) Null, 
 Price_Before_Discuont1 MONEY NOT NULL,
 DiscountPackageID INT CONSTRAINT PolicyDetails_DiscountPackageID_fk FOREIGN KEY REFERENCES  DiscountPackage(DiscountPackageID),--The decision of the marketer whether to grant a discount to the policy or not, therefore this column appears in this table 
 CompensationSum MONEY NULL,  --Compensation amount - for compensation policy only
 Smoke BIT NOT NULL ,  --Is the insured a smoker (on the policy issue date) 1=Yes 0=No
 CONSTRAINT PolicyDetails_PolicyId_InsuredIDÉÉÉ_InsProductId_pk PRIMARY KEY (PolicyId, InsuredID, InsProductId)
 )

 GO 

 INSERT INTO InsCategory (InsCategoryId ,InsCategoryName, InsCategoryDescription)
 VALUES (1, 'Life', 'receiving compensation in case of death'),
        (2, 'Health', 'get indemnity or compensation in case of medical problem'),
        (3, 'Loss of working capacity', 'compensation in case of loss of working capacity')

GO


INSERT INTO DiscountPackage(DiscountPackageID, Discount, NumOfYears, StartDate, EndDate)
VALUES (100000, 0, 0, '1930-01-01', NULL),
	   (100101, 0.5, 2, '2015-01-01', NULL),
	   (100102, 0.15, 10, '2016-01-01', NULL),
	   (100103, 0.1, 15,'2013-01-01', NULL),
	   (100104, 0.1, 3, '2015-01-01', NULL),
	   (100106, 0.15, 2, '2017-01-01', NULL),
	   (100107, 0.1, 2, '2017-01-01', NULL),
	   (100108,  0.2, 2, '2019-01-01', NULL),
	   (100109,  0.05, 5, '2019-01-01', NULL),
	   (100110, 0.08, 5, '2015-01-01', NULL),
	   (100111, 0.1, 10, '2015-01-01', '2022-01-15')

GO

INSERT INTO InsProducts( InsProductId,InsProductName,InsCategoryId, DiscountPackageID, "Indemnity or compensation", StartDate, EndDate, Details)
VALUES (101,'RISK-1',1, 100101, 'C','1970-01-01',NULL, 'Compansatiton in case of death. The price goes up every year'),
	   (102,'RISK-10',1 , 100102, 'C','1989-01-01',NULL,'Compansatiton in case of death. The price is fixed for ten years'),
	   (103,'RISK-15',1 , 100103, 'C','1989-01-01',NULL,'Compansatiton in case of death. The price is fixed for fifteen years'),
	   (104,'BASIK', 2, 100104,  'I', '1990-01-01', NULL, 'Medicines + Surgery abroad + Organ transplant'),
	   (105,'Surgeries in Israel', 2, 100104, 'I','1990-01-01', NULL, 'Surgery in Israel from the first shekel'),
	   (106,'Ambulatory', 2, 100106,'I', '1990-05-02', NULL, 'Medical tests and consultations'),
	   (107, 'Service letter- TOP to the child', 2, 100107, 'I', '2016-10-01', NULL, 'Developmental treatments for children' ),
	   (108, 'Critical illness', 2, 100108, 'C', '2000-07-15', NULL, 'Compansatiton in case of Critical illness'),
	   (109, 'MITRIYA insurance', 3, 100109, 'C','2019-01-01', NULL, 'Compansatiton in case of loss of working capacity, goes with Pension' ),
	   (110, 'Disability insurance SA', 3, 100110,  'C', '1989-01-01', NULL, 'Compansatiton in case of loss of working capacity'),
	   (111, 'Personal accidents', 1, 100111, 'C', '1992-01-01', '2022-01-15', 'Compansatiton in case of accident' )
	   
GO

INSERT INTO Marketers(FirstName, LastName, Phone, EMail, Street, Number, City, BirthDate, HireDate)
VALUES ('Amir', 'Levi', '053-7756463', 'amirl@menoramivt.co.il','Hadas','45', 'Mevo-Horon', '1983-05-17', '2015-06-06'),
	   ('Asaf', 'Cohen', '053-7962463', 'asafc@menoramivt.co.il','Harimon','25', 'Mevo-Dotann', '1979-05-17', '2020-07-06'),
	   ('Efrat', 'Levi', '052-7909463', 'efratl@menoramivt.co.il','Teena','5', 'Modiin', '1972-08-07', '2017-06-25'),
	   ('Shmulik', 'Green', '053-7756003', 'shmulikg@menoramivt.co.il','Seora','4', 'Mevo-Horon', '1974-08-17', '2019-06-12'),
	   ('Tami', 'Levitan', '052-7906463', 'tamil@menoramivt.co.il','Hshikma','90', 'Beer-Sheva', '1981-05-27', '2022-12-06')
	   

GO

INSERT INTO CreditCards (CardNumber, CardType,  ExpMonth, ExpYear, Num_3, CreditOwnerId, Lname, Fname)
VALUES  ( '4580561268950364','VISA', 8, 2028, '785','025096863', 'Green', 'Limor'),
		( '4580561005450364', 'VISA',10, 2029, '754','025091763', 'Greenwald', 'Michal'),
		( '4580952768950364','VISA', 9, 2030, '884','025099963', 'Meir', 'Shmuel'),
		( '5326105368950364','ISRACARD', 7, 2028, '234','037096863', 'Beyo', 'Tami'),
		( '5326105300950364','ISRACARD', 2, 2030, '214','037025863', 'Berger', 'Tali'),
		( '5326105300950377','ISRACARD', 1, 2030, '219','027025163', 'Berg', 'Eli'),
		( '5326105301740364', 'ISRACARD',1, 2028, '914','037044863', 'Mualem', 'Tal'),
		( '4580952766673649','VISA', 11, 2030, '894','025599913', 'Dahan', 'Eynat'),
		( '4580952768110364','VISA', 9, 2030, '873','025025963', 'Menachem', 'Shimi'),
		( '4580952768220364', 'VISA',9, 2028, '829','025071963', 'Yosef', 'Sason')

GO



INSERT INTO Customers
(Id, Lname, Fname, Phone, Street, Number, City, EMail, BirthDate, Merital_Status, Gender, Salary)
VALUES ('025096863', 'Green', 'Limor','052-2862510', 'Nahal-Tzalmon', '12', 'Modiin', 'limorgre@gmail.com', '1972-12-11', 'M', 'F', 15000),
	   ('036498112', 'Green', 'Hilel', '053-2862710', 'Nahal-Tzalmon', '12', 'Modiin', 'limorgre@gmail.com', '1972-06-17', 'M', 'M', 10000),
	   ('384922088', 'Green', 'Eyal','052-2862510', 'Nahal-Tzalmon', '12', 'Modiin', 'limorgre@gmail.com', '2002-02-11', 'S', 'M', NULL),
	   ('384922001', 'Green', 'Ido','052-2862510', 'Nahal-Tzalmon', '12', 'Modiin', 'limorgre@gmail.com', '2004-12-02', 'S', 'M', NULL),
	   ('025091763', 'Greenwald', 'Michal','053-3462510', 'Emek-Ayalon', '19', 'Modiin', 'michalgr@gmail.com', '1998-12-14', 'S', 'F', 8000),
	   ('025099963', 'Meir', 'Shmuel','053-2910710', 'Hadas', '121', 'Jerusalem', 'meirsh@gmail.com', '1974-06-23', 'M', 'M', 22000),
	   ('037096863', 'Beyo', 'Tami','053-9162640', 'Shoshan', '49', 'Tel-Aviv', 'tami_b@gmail.com', '1983-12-24', 'M', 'F', 8000),
	   ('037091483', 'Beyo', 'Gadi','050-2861310', 'Shoshan', '49', 'Tel-Aviv', 'gadi123@gmail.com', '1981-08-17', 'M', 'M', 5000),
	   ('395091483', 'Beyo', 'David','053-7962640', 'Shoshan', '49', 'Tel-Aviv', 'tami_b@gmail.com', '2006-12-24', 'S', 'M', NULL),
	   ('311091483', 'Beyo', 'Tomer','053-7112640', 'Shoshan', '49', 'Tel-Aviv', 'tami_b@gmail.com', '2008-12-24', 'S', 'M', NULL),
	   ('037025863', 'Berger', 'Tali','050-7798640', 'Shilo', '99', 'Tel-Aviv', 'tali_ber@gmail.com', '1975-11-24', 'S', 'F', 19000),
	   ('027025163', 'Berg', 'Eli','050-7112540', 'Bezeq', '114', 'Tel-Aviv', 'eli.b@gmail.com', '1980-12-13', 'S', 'M', 15500),
	   ('037044863', 'Mualem', 'Tal','053-2262040', 'Tohar', '3', 'Beit-Shemesh', 'tal_mu@gmail.com', '1985-10-04', 'S', 'M', NULL),
	   ('025599913', 'Dahan', 'Eynat','050-1138640', 'Shlomo', '109', 'Beer-Sheva', 'e02390@gmail.com', '1975-05-14', 'M', 'F', 19000),
	   ('025025963', 'Menachem', 'Shimi','052-1098290', 'Yehuda', '9', 'Haifa', 'shimi1975@gmail.com', '1975-01-29', 'M', 'M', 7000),
	   ('034525963', 'Menachem', 'Talya','050-7496640', 'Yehuda', '9', 'Haifa', 'shimi1975@gmail.com', '1977-09-07', 'M', 'F', 9500 ),
	   ('033025963', 'Sason', 'Efrat','052-2226640', 'Yehuda', '29', 'Yahud', 'efis@gmail.com', '1982-09-17', 'S', 'F', 25500 ),
	   ('025117849', 'Levitan', 'Zvi','054-7477226', 'Eytan', '79', 'Haifa', 'zvilev@gmail.com', '1990-03-09', 'M', 'F', 3500),
	   ('039617849', 'Levitan', 'Tova','054-7411221', 'Eytan', '79', 'Haifa', 'zvilev@gmail.com', '1991-02-07', 'M', 'F', 6500 ),
	   ('035117849', 'Yehezkely', 'Dov','054-7433126', 'Avivim', '11', 'Beit-Shemesh', 'dov1234@gmail.com', '1970-02-26', 'M', 'M', 16500),
	   ('024117849', 'David', 'Yitzhak','054-7033196', 'Amirim', '15', 'Beit-Shemesh', 'izik76@gmail.com', '1970-12-16', 'M', 'M', 16500),
	   ('025517849', 'Asaf', 'Shmuel', '054-8909399', 'Begin', '85', 'Raanana', 'shmuel6845@gmail.com', '1969-04-26', 'M', 'M', 11500),
	   ('025167849', 'Glas', 'Hana','053-6032196', 'Patada', '11', 'Raanana', 'hanag1@gmail.com', '1970-10-21', 'M', 'F', 4500),
	   ('028360099', 'Glas', 'Hagay', '053-9949496', 'Patada', '11', 'Raanana', 'hanag1@gmail.com', '1969-01-21', 'M', 'M', 24500),
	   ('025114849', 'Tzaig', 'Yael','058-2132196', 'Avraham Avinu', '95', 'Raanana', 'yaelit@gmail.com', '1988-10-05', 'M', 'F', 14500),
	   ('055117949', 'Omer', 'Shilo','058-3542707', 'Tzlil', '61', 'Raanana', 'shiloomer1@gmail.com', '1982-03-24', 'M', 'M', 23500),
	   ('025117809', 'Netzer', 'Yishay','058-3542708', 'Tzlil', '34', 'Bat-Yam', 'y0583542708@gmail.com', '1977-03-20', 'M', 'M', 23000),
	   ('013287809', 'Netzer', 'Moriya','058-3542709', 'Tzlil', '34', 'Bat-Yam', 'y0583542708@gmail.com', '1978-04-23', 'M', 'F', 13000),
	   ('025117840', 'Harel', 'Israel', '058-5609202', 'Tpuz', '32', 'Bat-Yam', 'i0585609202@gmail.com', '1985-06-22', 'D', 'M', 13000),
	   ('035117249', 'Shemen', 'Tal','058-9560700', 'Tel-Sheva', '39', 'Bat-Yam', 't058560700@gmail.com', '1974-09-25', 'M', 'M', 21000)



INSERT INTO Direct_Debit (BankNumber, BranchNumber, AccountNumber, BankName, BranchName, AccountOwnerID)
VALUES ( '10', '215', '10723990', 'Leumi','Hameyasdim','025117849'),
       ( '20','114', '639720', 'Mizrahi','Lev Hair', '035117849' ),
	   ( '12', '218', '84042924','Poalim','Kicar Hair', '024117849' ),
	   ( '10', '117', '10409990', 'Leumi','Hamelech Gorge','025517849' ),
	   ( '10','610', '10723776', 'Leumi','Begin', '025167849' ),
	   ( '20','730', '10882776', 'Mizrahi','Hadar', '025114849' ),
	   ( '20', '202', '10811576','Mizrahi', 'Hilel','055117949' ),
	   ( '20','118', '10811996','Mizrahi', 'Macabim', '025117809' ),
	   ( '12','634', '82400092','Poalim', 'Kicar Hashabat', '025117840' ),
	   ( '4','116', '986243','Yahav', 'Hatzorfim', '035117249' )

GO 

INSERT INTO "Policy"(PolicyId, EmployeeID, CardNumber, BankNumber, BranchNumber, AccountNumber)
VALUES ('900500111',1, '4580561268950364', NULL, NULL, NULL),
	   ('900500112',2, NULL, '10', '215', '10723990'),
	   ('900500113',3, '4580561005450364',  NULL, NULL, NULL ),
	   ('900500114',4, NULL, '20','114', '639720' ),
	   ('900500115',5, '4580952768950364', NULL, NULL, NULL ),
	   ('900500116',1, NULL, '12', '218' , '84042924' ),
	   ('900500117',2, '5326105368950364',  NULL, NULL, NULL ),
	   ('900500118',3, NULL, '10', '117', '10409990' ),
	   ('900500119',4, '5326105300950364',  NULL, NULL, NULL ),
	   ('900500120',5, NULL, '10', '610', '10723776' ),
	   ('900500121',1, '5326105300950377',  NULL, NULL, NULL ),
	   ('900500122',2, NULL, '20', '730', '10882776' ),
	   ('900500123',3, '5326105301740364',  NULL, NULL, NULL ),
	   ('900500124',4, NULL, '20', '202', '10811576' ),
	   ('900500125',5, '4580952766673649',  NULL, NULL, NULL ),
	   ('900500126',1, NULL, '20', '118', '10811996' ),
	   ('900500127',2, '4580952768110364',  NULL, NULL, NULL ),
	   ('900500128',3, NULL, '12', '634', '82400092' ),
	   ('900500129',4, '4580952768220364',  NULL, NULL, NULL ),
	   ('900500130',5, NULL, '4', '116', '986243'),
	   ('900500131',1, '4580561268950364',  NULL, NULL, NULL ),
	   ('900500132',2, NULL, '10', '610', '10723776' ),
	   ('900500133',3, '5326105368950364',  NULL, NULL, NULL ),
	   ('900500134',4, NULL, '20', '202', '10811576' ),
	   ('900500135',5, '5326105301740364',  NULL, NULL, NULL ),
	   ('900500136',1, '4580561268950364', NULL, NULL, NULL),
	   ('900500137',2, NULL, '10', '215', '10723990'),
	   ('900500138',3, '4580561005450364',  NULL, NULL, NULL ),
	   ('900500139',4, NULL, '20','114', '639720' ),
	   ('900500140',5, '4580952768950364', NULL, NULL, NULL ),
	   ('900500141',1, NULL, '12', '218' , '84042924' ),
	   ('900500142',2, '5326105368950364',  NULL, NULL, NULL ),
	   ('900500143',3, NULL, '10', '117', '10409990' ),
	   ('900500144',4, '5326105300950364',  NULL, NULL, NULL ),
	   ('900500145',5, NULL, '10', '610', '10723776' ),
	   ('900500146',1, '5326105300950377',  NULL, NULL, NULL ),
	   ('900500147',2, NULL, '20', '730', '10882776' ),
	   ('900500148',3, '5326105301740364',  NULL, NULL, NULL ),
	   ('900500149',4, NULL, '20', '202', '10811576' ),
	   ('900500150',5, '4580952766673649',  NULL, NULL, NULL ),
	   ('900500151',1, NULL, '20', '118', '10811996' ),
	   ('900500152',2, '4580952768110364',  NULL, NULL, NULL ),
	   ('900500153',3, NULL, '12', '634', '82400092' ),
	   ('900500154',4, '4580952768220364',  NULL, NULL, NULL ),
	   ('900500155',5, NULL, '4', '116', '986243'),
	   ('900500156',1, '4580561268950364',  NULL, NULL, NULL ),
	   ('900500157',2, NULL, '10', '610', '10723776' ),
	   ('900500158',3, '5326105368950364',  NULL, NULL, NULL ),
	   ('900500159',4, NULL, '20', '202', '10811576' ),
	   ('900500160',5, '5326105301740364',  NULL, NULL, NULL )
GO


INSERT INTO PolicyDetails(PolicyId, InsuredID, InsProductId, InsuredStatus, Policy_Start_Date, Policy_End_Date, Policy_End_Reason, Price_Before_Discuont1 , DiscountPackageID, CompensationSum, Smoke)
VALUES ('900500111', '025096863',104, 1, '2020-12-06', Null, Null, 40, 100104, NULL, 0),
	   ('900500111', '025096863',105, 1, '2020-12-06', Null, Null, 80, 100104,  NULL, 0),  
	   ('900500111', '025096863',106, 1, '2020-12-06', Null, Null, 20 , 100106,  NULL, 0), 
	   ('900500111', '036498112',104, 2, '2020-12-06', Null, Null, 43, 100104, NULL, 0),
	   ('900500111', '036498112',105, 2, '2020-12-06', Null, Null, 87, 100104,  NULL, 0),
	   ('900500111', '036498112',106, 2, '2020-12-06', Null, Null, 20, 100106,  NULL, 0),
	   ('900500111', '384922088',104, 3, '2020-12-06', Null, Null, 32, 100104,  NULL, 0),
	   ('900500111', '384922088',105, 3, '2020-12-06', Null, Null, 52, 100104, NULL, 0),
	   ('900500111', '384922088',106, 3, '2020-12-06', Null, Null, 15, 100106,  NULL, 0),
	   ('900500111', '384922001',104, 3, '2020-12-06', Null, Null, 29, 100104, NULL, 0),
	   ('900500111', '384922001',105, 3, '2020-12-06', Null, Null, 47, 100104,  NULL, 0),
	   ('900500111', '384922001',106, 3, '2020-12-06', Null, Null, 15, 100106,  NULL, 0),
	   ('900500112', '025117849',102, 1, '2020-11-09', Null, Null, 56 , 100102, 750000, 1),
	   ('900500112', '025117849',108, 1, '2020-11-09', Null, Null, 112 , 100108, 200000, 1),
	   ('900500112', '039617849',102, 2, '2020-11-09', Null, Null, 48 , 100102,  750000 ,0),
	   ('900500112', '039617849',108, 2, '2020-11-09', Null, Null, 86 , 100108, 200000 ,0 ),
	   ('900500113', '025091763', 109, 1, '2020-3-20', Null, Null, 54, 100109, 8000, 1),
	   ('900500113', '025091763', 110, 1, '2020-3-20', Null, Null, 123, 100110,  10000, 1), 
	   ('900500114', '035117849', 104, 1, '2020-10-21', '2023-10-01', 'cancelation', 65 , 100104, NULL, 0),
	   ('900500114', '035117849', 105, 1, '2020-10-21', '2023-10-01', 'cancelation', 185 , 100104, NULL, 0),
	   ('900500115', '025099963', 108 ,1 ,'2020-09-08', Null, Null, 254, 100108,  200000, 1),
	   ('900500116', '024117849', 101, 1, '2020-08-26', Null, Null, 489, 100101, 1000000, 1),
	   ('900500117', '037096863', 104, 1, '2020-04-07', Null, Null, 64, 100104, NULL, 0),
	   ('900500117', '037091483', 104, 2, '2020-04-07' , Null, Null, 78, 100104, NULL, 1 ),
	   ('900500117', '395091483', 104, 3, '2020-04-07', Null, Null, 23 , 100104, NULL, 0),
	   ('900500117', '311091483', 104, 3, '2020-04-07', Null, Null, 23 , 100104, NULL, 0),
	   ('900500117', '037096863', 108, 1, '2020-04-07', Null, Null, 153 , 100108,  200000, 0),
	   ('900500117', '037091483', 108, 2, '2020-04-07', Null, Null, 325, 100108, 200000, 1 ),
	   ('900500117', '395091483', 108, 3, '2020-04-07', Null, Null, 56 , 100108, 200000, 0),
	   ('900500117', '311091483', 108, 3, '2020-04-07', Null, Null, 56 , 100108, 200000, 0 ),
	   ('900500118', '025517849', 109, 1, '2020-12-24', '2023-11-20', 'cancelation', 175, 100109, 15000, 1),
	   ('900500119', '037025863', 110, 1, '2020-09-25', Null, Null, 215, 100110, 10000, 1),
	   ('900500120', '025167849', 104, 1 , '2020-02-14', Null, Null, 98, 100104, NULL, 1),
	   ('900500120', '025167849', 106, 1 , '2020-02-14', Null, Null, 35, 100106, NULL, 1),
	   ('900500120', '028360099', 104, 2 , '2020-02-14', Null, Null, 79, 100104, NULL , 0),
	   ('900500120', '028360099', 106, 2 , '2020-02-14', Null, Null, 26, 100106, NULL, 0),
	   ('900500121', '027025163', 109, 1, '2021-12-15', Null, Null, 189, 100109, 13000, 1),
	   ('900500122', '025114849',104 ,1 ,'2021-08-12', Null, Null, 56, 100104, NULL, 0 ),
	   ('900500122', '025114849',107 ,1 ,'2021-08-12', Null, Null, 17, 100107, NULL, 0 ),
	   ('900500123', '037044863', 103, 1, '2021-03-27', Null, Null, 143, 100103, 750000, 0),
	   ('900500124', '055117949', 104, 1, '2021-06-13', '2024-03-25', 'cancelation', 64, 100104, NULL, 0),
	   ('900500124', '055117949', 105, 1, '2021-06-13', '2024-03-25', 'cancelation', 105, 100104, NULL, 0),
	   ('900500125', '025599913', 110, 1, '2021-05-03', Null, Null, 289, 100110, 8000, 0),
	   ('900500126','025117809', 108, 1, '2021-09-03', Null, Null, 487, 100108, 200000, 1),
	   ('900500126','013287809', 108, 2, '2021-09-03', Null, Null, 276, 100108, 200000, 0 ),
	   ('900500127', '025025963', 102, 1, '2021-05-03', Null, Null, 298, 100102, 1000000, 0),
	   ('900500127', '034525963', 102, 2, '2021-05-03', Null, Null, 254, 100102, 1000000, 0),
	   ('900500128', '025117840', 104, 1, '2021-09-05', '2023-09-20', 'cancelation', 67, Null, NULL, 1),
	   ('900500129', '033025963', 109, 1, '2021-06-17', '2023-05-20', 'cancelation', 87, 100109, 9000, 0),
	   ('900500130', '035117249', 103, 1, '2021-07-07', Null, Null, 236, 100103, 800000, 0),
	   ('900500131', '025096863', 103, 1, '2021-12-06', Null, Null, 76, 100103, 800000, 0),
	   ('900500131', '036498112', 103, 2, '2021-12-06', Null, Null, 118 , 100103, 800000, 0),
	   ('900500132', '025167849', 102, 1, '2021-09-09', Null, Null, 523, 100102, 1000000, 1),
	   ('900500132', '028360099', 102, 2, '2021-09-09', Null, Null, 267, 100102, 1000000, 0),
	   ('900500133', '037096863', 103, 1, '2021-04-06', Null, Null, 287, 100103, 800000, 0),
	   ('900500133', '037091483', 103, 2, '2021-04-06', Null, Null, 389, 100103, 800000, 0),
	   ('900500134', '055117949', 108, 1, '2021-11-13', Null, Null, 370, 100108, 300000, 1),
	   ('900500135', '037044863', 104, 1, '2021-11-13', Null, Null, 57, Null, NULL, 0),
       ('900500136', '025096863',108, 1, '2021-12-06', '2023-11-27', 'cancelation', 250, 100108, 200000, 0),
	   ('900500136', '025096863',109, 1, '2021-12-06', '2023-11-27', 'cancelation', 80, 100109,  13000, 0),   
	   ('900500136', '036498112',108, 2, '2021-12-06', '2023-11-27', 'cancelation', 200, 100108, 200000, 0),
	   ('900500136', '036498112',109, 2, '2021-12-06', '2023-11-27', 'cancelation', 87, 100109,  8000, 0),
	   ('900500136', '384922088',108, 3, '2021-12-06', '2023-11-27', 'cancelation', 15, 100108,  200000, 0),
	   ('900500136', '384922001',108, 3, '2021-12-06', '2023-11-27', 'cancelation', 15, 100108, 200000, 0),
	   ('900500137', '025117849',104, 1, '2021-11-09', Null, Null, 70 , 100104, NULL, 1),
	   ('900500137', '025117849',105, 1, '2021-11-09', Null, Null, 112 , 100104, NULL, 1),
	   ('900500137', '039617849',104, 2, '2021-11-09', Null, Null, 82 , 100104,  NULL ,0),
	   ('900500137', '039617849',105, 2, '2021-11-09', Null, Null, 129 , 100104, NULL ,0 ),
	   ('900500138', '025091763', 104, 1, '2021-3-20', Null, Null, 89, 100104, 8000, 1),
	   ('900500138', '025091763', 105, 1, '2021-3-20', Null, Null, 156, 100104,  10000, 1), 
	   ('900500139', '035117849', 102, 1, '2021-10-21', Null, Null, 265 , 100102, 1000000, 0),
	   ('900500139', '035117849', 108, 1, '2022-10-21', Null, Null, 185 , 100108, 200000, 0),
	   ('900500140', '025099963', 104 ,1 ,'2022-09-08', '2023-10-20', 'cancelation', 87, 100104, Null, 1),
	   ('900500141', '024117849', 105, 1, '2022-08-26', '2023-10-20', 'cancelation', 215, 100104, Null, 1),
	   ('900500142', '037096863', 105, 1, '2022-04-07', Null, Null, 95, 100104, NULL, 0),
	   ('900500142', '037091483', 105, 2, '2022-04-07' , Null, Null, 78, 100104, NULL, 1 ),
	   ('900500142', '395091483', 105, 3, '2022-04-07', Null, Null, 52 , 100104, NULL, 0),
	   ('900500142', '311091483', 105, 3, '2022-04-07', Null, Null, 52 , 100104, NULL, 0),
	   ('900500142', '037096863', 106, 1, '2022-04-07', Null, Null, 30 , 100106,  NULL, 0),
	   ('900500142', '037091483', 106, 2, '2022-04-07', Null, Null, 55, 100106, NULL, 1 ),
	   ('900500142', '395091483', 106, 3, '2022-04-07', Null, Null, 25 , 100106, NULL, 0),
	   ('900500142', '311091483', 106, 3, '2022-04-07', Null, Null, 25 , 100106, NULL, 0 ),
	   ('900500143', '025517849', 102, 1, '2022-12-24', '2023-08-22', 'cancelation', 249, 100102, 1000000, 1),
	   ('900500144', '037025863', 102, 1, '2022-09-25', Null, Null, 215, 100102, 1000000, 1),
	   ('900500145', '025167849', 105, 1 , '2022-02-14', Null, Null, 243, 100104, NULL, 1),
	   ('900500145', '025167849', 108, 1 , '2022-02-14', Null, Null, 357, 100106, 200000, 1),
	   ('900500145', '028360099', 105, 2 , '2022-02-14', Null, Null, 215, 100104, NULL , 0),
	   ('900500145', '028360099', 108, 2 , '2022-02-14', Null, Null, 186, 100106, 200000, 0),
	   ('900500146', '027025163', 101, 1, '2022-12-15', '2023-07-23', 'cancelation', 254, 100101, 1000000, 1),
	   ('900500147', '025114849',105 ,1 ,'2022-08-12', Null, Null, 156, 100104, NULL, 0 ),
	   ('900500147', '025114849',106 ,1 ,'2022-08-12', Null, Null, 56, 100106, NULL, 0 ),
	   ('900500148', '037044863', 103, 1, '2022-03-27', Null, Null, 143, 100103, 750000, 0),
	   ('900500149', '055117949', 102, 1, '2022-06-13', '2024-03-25', 'cancelation', 352, 100102, 1000000, 0),
	   ('900500149', '055117949', 108, 1, '2022-06-13', '2024-03-25', 'cancelation', 168, 100108, 250000, 0),
	   ('900500150', '025599913', 103, 1, '2022-05-03', Null, Null, 345, 100103, 1000000, 0),
	   ('900500151','025117809', 103, 1, '2022-09-03', Null, Null, 568, 100103, 1500000, 1),
	   ('900500151','013287809', 103, 2, '2022-09-03', Null, Null, 298, 100103, 1500000, 0 ),
	   ('900500152', '025025963', 104, 1, '2022-05-03', Null, Null, 87, 100104, NULL, 0),
	   ('900500152', '034525963', 104, 2, '2022-05-03', Null, Null, 95, 100104, NULL, 0),
	   ('900500153', '025117840', 105, 1, '2022-09-05', '2023-08-24', 'cancelation', 128, NULL, NULL, 1),
	   ('900500154', '033025963', 105, 1, '2022-06-17', '2023-04-21', 'cancelation', 165, 100104, NULL, 0),
	   ('900500155', '035117249', 105, 1, '2022-07-07', '2023-05-26', 'cancelation', 189, 100104, NULL, 0),
	   ('900500156', '025096863', 105, 1, '2022-12-06', Null, Null, 156, 100104, NULL, 0),
	   ('900500156', '036498112', 105, 2, '2022-12-06', Null, Null, 186 , 100104, NULL, 0),
	   ('900500157', '025167849', 105, 1, '2022-09-09', '2024-12-20', 'cancelation', 263, 100104, NULL ,1),
	   ('900500157', '028360099', 105, 2, '2022-09-09', '2024-12-20', 'cancelation', 186, 100104, NULL, 0),
	   ('900500158', '037096863', 104, 1, '2022-04-06', Null, Null, 86, 100104, NULL, 0),
	   ('900500158', '037091483', 104, 2, '2022-04-06', Null, Null, 95, 100104, NULL, 0),
	   ('900500159', '055117949', 103, 1, '2022-11-13', '2024-11-20', 'cancelation', 485, 100103, 2000000, 1),
	   ('900500160', '037044863', 105, 1, '2022-11-13', '2024-06-17', 'cancelation', 157, Null, NULL, 0)
