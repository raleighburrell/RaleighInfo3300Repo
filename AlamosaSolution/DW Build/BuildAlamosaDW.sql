--Created by Raleigh Burrell on Oct 10, 2017
--Version 1
--Builds the Tables & Relationships for the Alamosa Tourism Email Datamart

--Creating the DM
USE Master
GO
IF NOT EXISTS(
    SELECT *
    FROM sys.databases
    WHERE name = N'AlamosaDW'
  )
  CREATE DATABASE AlamosaDW
GO
USE AlamosaDW
GO

--Removing Existing Tables
IF EXISTS( --removes a table if it exists
  	SELECT *
  	FROM sys.tables
  	WHERE name = N'FactClick'
	)
	DROP TABLE FactClick;

IF EXISTS(
  	SELECT *
  	FROM sys.tables
  	WHERE name = N'DimDate'
	)
	DROP TABLE DimDate;

IF EXISTS(
  	SELECT *
  	FROM sys.tables
  	WHERE name = N'DimTime'
	)
	DROP TABLE DimTime;

IF EXISTS(
  	SELECT *
  	FROM sys.tables
  	WHERE name = N'DimSuscriber'
	)
	DROP TABLE DimSuscriber;

IF EXISTS(
  	SELECT *
  	FROM sys.tables
  	WHERE name = N'DimList'
	)
	DROP TABLE DimList;

IF EXISTS(
  	SELECT *
  	FROM sys.tables
  	WHERE name = N'DimMail'
	)
	DROP TABLE DimMail;

IF EXISTS(
  	SELECT *
  	FROM sys.tables
  	WHERE name = N'DimLocation'
	)
	DROP TABLE DimLocation;
GO


--Creating Tables
---Date Dimension
CREATE TABLE [dbo].[DimDate]
	(
		DateSK INT CONSTRAINT pk_dim_date PRIMARY KEY,
		Date DATETIME,
		FullDate CHAR(10),-- Date in MM-dd-yyyy format
		DayOfMonth INT, -- Field will hold day number of Month
		DayName VARCHAR(9), -- Contains name of the day, Sunday, Monday
		DayOfWeek INT,-- First Day Sunday=1 and Saturday=7
		DayOfWeekInMonth INT, -- 1st Monday or 2nd Monday in Month
		DayOfWeekInYear INT,
		DayOfQuarter INT,
		DayOfYear INT,
		WeekOfMonth INT,-- Week Number of Month
		WeekOfQuarter INT, -- Week Number of the Quarter
		WeekOfYear INT,-- Week Number of the Year
		Month INT, -- Number of the Month 1 to 12{}
		MonthName VARCHAR(9),-- January, February etc
		MonthOfQuarter INT,-- Month Number belongs to Quarter
		Quarter CHAR(2),
		QuarterName VARCHAR(9),-- First,Second..
		Year INT,-- Year value of Date stored in Row
		YearName CHAR(7), -- CY 2015,CY 2016
		MonthYear CHAR(10), -- Jan-2016,Feb-2016
		MMYYYY INT,
		FirstDayOfMonth DATE,
		LastDayOfMonth DATE,
		FirstDayOfQuarter DATE,
		LastDayOfQuarter DATE,
		FirstDayOfYear DATE,
		LastDayOfYear DATE,
		IsHoliday BIT,-- Flag 1=National Holiday, 0-No National Holiday
		IsWeekday BIT,-- 0=Week End ,1=Week Day
		Holiday VARCHAR(50),--Name of Holiday in US
		Season VARCHAR(10)--Name of Season
	);

---Time Dimension
CREATE TABLE [dbo].[DimTime]
	(
  	TimeSK INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_dim_time PRIMARY KEY,
  	Time CHAR(8) NOT NULL,
  	Hour CHAR(2) NOT NULL,
  	MilitaryHour CHAR(2) NOT NULL,
  	Minute CHAR(2) NOT NULL,
  	Second CHAR(2) NOT NULL,
  	AmPm CHAR(2) NOT NULL,
  	StandardTime CHAR(11) NULL
	);

---Suscriber Dimension
CREATE TABLE dbo.DimSuscriber
  (
    SuscriberSK INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_dim_suscriber PRIMARY KEY,
    SuscriberAK INT NOT NULL,
    Country NVARCHAR(50) NOT NULL,
    State NVARCHAR(50) NOT NULL,
    ZIP NVARCHAR(50) NOT NULL,
    City NVARCHAR(50) NOT NULL,
    LeadSource NVARCHAR(50) NOT NULL
  );

---List Dimension
CREATE TABLE dbo.DimList
  (
    ListSK INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_dim_list PRIMARY KEY,
    ListAK INT NOT NULL,
    Name NVARCHAR(50) NOT NULL
  );

---Mail Dimension
CREATE TABLE dbo.DimMail
  (
    MailSK INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_dim_mail PRIMARY KEY,
    MailAK INT NOT NULL,
    Type NVARCHAR(50) NOT NULL,
    Alias NVARCHAR(50) NOT NULL
  );

---Location Dimension
CREATE TABLE dbo.DimLocation
  (
    LocationSK INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_dim_location PRIMARY KEY,
    LocationAK NVARCHAR(250) NOT NULL,
    Country NVARCHAR(50) NOT NULL,
    State NVARCHAR(50) NOT NULL,
    ZIP NVARCHAR(50) NOT NULL,
    City NVARCHAR(50) NOT NULL,
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6)
  );

---Click Fact Table
CREATE TABLE dbo.FactClick
  (
    --Foreign Keys
    ClickDate INT CONSTRAINT fk_fact_click_dim_date_click FOREIGN KEY REFERENCES DimDate(DateSK),
    ClickTime INT CONSTRAINT fk_fact_click_dim_time_click FOREIGN KEY REFERENCES DimTime(TimeSK),
    SuscriberSK INT CONSTRAINT fk_fact_click_dim_suscriber FOREIGN KEY REFERENCES DimSuscriber(SuscriberSK),
    ListSK INT CONSTRAINT fk_fact_click_dim_list FOREIGN KEY REFERENCES DimList(ListSK),
    MailSK INT CONSTRAINT fk_fact_click_dim_mail FOREIGN KEY REFERENCES DimMail(MailSK),
    LocationSK INT CONSTRAINT fk_fact_click_dim_location FOREIGN KEY REFERENCES DimLocation(LocationSK),
    --Measures
    ClickCount INT,
    DateSent INT CONSTRAINT fk_fact_click_dim_date_sent FOREIGN KEY REFERENCES DimDate(DateSK),
    TimeSent INT CONSTRAINT fk_fact_click_dim_time_sent FOREIGN KEY REFERENCES DimTime(TimeSK),
    TimeUnopened TIME
  );
