--Created by Raleigh Burrell on September 29th
--Version 1
--Buil Alamosa Database
--
-- Replace <data_path> with the full path to this file
-- Ensure it ends with a backslash.
-- E.g., C:\MyDatabases\ See line 16
--
--Tables Built:
--	Suscriber
--	Mail
--	Url
--	UrlClick
--	List
--	ListMail
--	ListSubscriber
--	Geolocation

--Step 1: Create Databse
IF NOT EXISTS(SELECT * FROM sys.databases  --only adds if it doesn't exist
	WHERE name = N'Alamosa')
	CREATE DATABASE Alamosa
GO
USE Alamosa

DECLARE
	@data_path NVARCHAR(256);
SELECT @data_path = '\\Mac\Home\Documents\GitHub\RaleighInfo3300Repo\BuildAlamosa\'; --Change this!
GO


--Step 2: Delete Existing Tables
IF EXISTS( --removes a table if it exists
	SELECT *
	FROM sys.tables
	WHERE name = N'ListSubscriber'
	)
	DROP TABLE ListSubscriber;

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'ListMail'
	)
	DROP TABLE ListMail;

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'UrlClick'
	)
	DROP TABLE UrlClick;

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'Mail'
	)
	DROP TABLE Mail;

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'Subscriber'
	)
	DROP TABLE Subscriber;

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'List'
	)
	DROP TABLE List;

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'GeoLocation'
	)
	DROP TABLE GeoLocation;

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'Url'
	)
	DROP TABLE Url;


--Step 3: Create Tables
---URL
CREATE TABLE Url
  (UrlID INT CONSTRAINT pk_url PRIMARY KEY,
  Name NVARCHAR(250),
  Url NTEXT
  );

---Subscriber
CREATE TABLE Subscriber
  (SubscriberID INT CONSTRAINT pk_subscriber PRIMARY KEY,
  Email NVARCHAR(200),
  UserID INT,
  Name NVARCHAR(250),
  Created_UNIX INT,
  Confirmed INT,
  Enabled INT,
  Accept INT,
  IP NVARCHAR(100),
  Html INT,
  [Key] NVARCHAR(250),
  ConfirmedDate_UNIX INT,
  ConfirmedIP NVARCHAR(100),
  LastOpenDate_UNIX INT,
  LastOpenIP NVARCHAR(100),
  LastClickDate_UNIX INT,
  LastSentDate_UNIX INT,
  Street NVARCHAR(250),
  Suite NVARCHAR(250),
  City NVARCHAR(250),
  StateField NVARCHAR(250),
  State NVARCHAR(250),
  Province NVARCHAR(250),
  Phone NVARCHAR(250),
  Mobile NVARCHAR(250),
  LeadSource NVARCHAR(250),
  FirstName NVARCHAR(250),
  LastName NVARCHAR(250),
  BehaviorType NVARCHAR(250),
  GATemp NVARCHAR(250),
  Webpage NVARCHAR(250),
  Wesite NVARCHAR(250),
  Newsletter NVARCHAR(250),
  GuideRequest NVARCHAR(250),
  Country NVARCHAR(250),
  ZIP NVARCHAR(250),
  HowHeard NVARCHAR(250),
  HowHeardOther NVARCHAR(250),
  ArrivalDate NVARCHAR(250),
  ContactUs NVARCHAR(250),
  [Source] NVARCHAR(250)
  );

--GeoLocation
CREATE TABLE GeoLocation
  (GeoLocationID INT CONSTRAINT pk_geolocation PRIMARY KEY,
  IP NVARCHAR(255) UNIQUE,
  CountryCode NVARCHAR(2),
  CountryName NVARCHAR(50),
  RegionCode NVARCHAR(3),
  RegionName NVARCHAR(50),
  City NVARCHAR(50),
  ZIP NVARCHAR(15),
  TimeZone NVARCHAR(50),
  Latitude DECIMAL(20,10),
  Longitude DECIMAL(20,10),
  MetroCode NVARCHAR(10)
  );

---List
CREATE TABLE List
  (Name NVARCHAR(250),
  Description NTEXT,
  Ordering INT,
  ListID INT CONSTRAINT pk_list PRIMARY KEY,
  Published INT,
  UserID INT,
  Alias NVARCHAR(250),
  Color NVARCHAR(30),
  Visible INT,
  WebMailID INT,
  UnsubMailID INT,
  [Type] NVARCHAR(50),
  AccessSub NVARCHAR(250),
  AccessManage NVARCHAR(250),
  Languages NVARCHAR(250),
  StartRule NVARCHAR(50),
  Category NVARCHAR(250)
  );

---Mail
CREATE TABLE Mail
  (MailID INT CONSTRAINT pk_mail PRIMARY KEY,
  [Subject] NVARCHAR(250),
  Published INT,
  SentDate_UNIX INT,
  Created_UNIX INT,
  FromName NVARCHAR(250),
  FromEmail NVARCHAR(250),
  ReplyName NVARCHAR(250),
  ReplyEmail NVARCHAR(250),
  [Type] NVARCHAR(50),
  Alias NVARCHAR(250),
  Attach NTEXT,
  [Key] NVARCHAR(200),
  SentBy NVARCHAR(250),
  );

---UrlClick
CREATE TABLE UrlClick
  (UrlID INT CONSTRAINT fk_urlclick_url FOREIGN KEY REFERENCES Url(UrlID),
  MailID INT CONSTRAINT fk_urlclick_mail FOREIGN KEY REFERENCES Mail(MailID),
  SubscriberID INT, --throwing error CONSTRAINT fk_urlclick_subscriber FOREIGN KEY REFERENCES Subscriber(SubscriberID),
  Click INT,
  ClickDate_UNIX INT,
  IP NVARCHAR(255), --based on Sub so error as well CONSTRAINT fk_urlclick_geolocation FOREIGN KEY REFERENCES GeoLocation(IP)
  );

---ListMail
CREATE TABLE ListMail
  (ListID INT CONSTRAINT fk_listmail_list FOREIGN KEY REFERENCES List(ListID),
  MailID INT CONSTRAINT fk_listmail_mail FOREIGN KEY REFERENCES Mail(MailID)
  );

---ListSub
CREATE TABLE ListSubscriber
  (ListID INT CONSTRAINT fk_listsubscriber_list FOREIGN KEY REFERENCES List(ListID),
  SubscriberID INT, --throwing bizarre error too CONSTRAINT fk_listsubscriber_subscriber FOREIGN KEY REFERENCES Subscriber(SubscriberID),
  SubscribeDate_UNIX INT,
  UnsubscribeDate_UNIX INT,
  Status INT
  );
GO


--Step 4: Bulk Load the Data
DECLARE
	@data_path NVARCHAR(256);
SELECT @data_path = '\\Mac\Home\Documents\GitHub\RaleighInfo3300Repo\BuildAlamosa\'; --Change this!

---Url
EXECUTE (N'BULK INSERT Url FROM ''' + @data_path + N'Url.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');

---GeoLocation
EXECUTE (N'BULK INSERT GeoLocation FROM ''' + @data_path + N'GeoLocation.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');

---List
EXECUTE (N'BULK INSERT List FROM ''' + @data_path + N'List.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');

---Subscriber
EXECUTE (N'BULK INSERT Subscriber FROM ''' + @data_path + N'Subscriber2.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');

---Mail
EXECUTE (N'BULK INSERT Mail FROM ''' + @data_path + N'Mail2.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');

---UrlClick
EXECUTE (N'BULK INSERT UrlClick FROM ''' + @data_path + N'UrlClick.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');

---ListMail
EXECUTE (N'BULK INSERT ListMail FROM ''' + @data_path + N'ListMail.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');

---ListSubscriber
EXECUTE (N'BULK INSERT ListSubscriber FROM ''' + @data_path + N'ListSubscriber.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');

---List Table Names & Row Counts
GO
SET NOCOUNT ON
SELECT 'Url' "Table",		COUNT(*) "Rows"	FROM Url			UNION
SELECT 'GeoLocation',		COUNT(*)		FROM GeoLocation	UNION
SELECT 'List',				COUNT(*)		FROM List			UNION
SELECT 'Subscriber',        COUNT(*)		FROM Subscriber		UNION
SELECT 'Mail',				COUNT(*)		FROM Mail			UNION
SELECT 'UrlClick',			COUNT(*)		FROM UrlClick		UNION
SELECT 'ListMail',			COUNT(*)		FROM ListMail		UNION
SELECT 'ListSubscriber',	COUNT(*)		FROM ListSubscriber
ORDER BY 1;
SET NOCOUNT OFF
GO


--Step 5: Converting UNIX Timestamp Int to Date Time
---Function to Convert from https://stackoverflow.com/questions/2904256/how-can-i-convert-bigint-unix-timestamp-to-datetime-in-sql-server
USE Alamosa
GO
IF OBJECT_ID(N'dbo.fn_ConvertToDateTime', N'FN') IS NOT NULL
DROP FUNCTION dbo.fn_ConvertToDateTime;
GO
CREATE FUNCTION dbo.fn_ConvertToDateTime (@Datetime BIGINT)
RETURNS DATETIME
AS
BEGIN
    DECLARE @LocalTimeOffset BIGINT
           ,@AdjustedLocalDatetime BIGINT;
    SET @LocalTimeOffset = DATEDIFF(second,GETDATE(),GETUTCDATE())
    SET @AdjustedLocalDatetime = @Datetime - @LocalTimeOffset
    RETURN (SELECT DATEADD(second,@AdjustedLocalDatetime, CAST('1970-01-01 00:00:00' AS datetime)))
END;
GO

---Actual  Conversion
USE Alamosa
GO
ALTER TABLE Subscriber
ADD Created AS dbo.fn_ConvertToDateTime(Created_UNIX),
	ConfirmedDate AS dbo.fn_ConvertToDateTime(ConfirmedDate_UNIX),
	LastOpenDate AS dbo.fn_ConvertToDateTime(LastOpenDate_UNIX),
	LastClickDate AS dbo.fn_ConvertToDateTime(LastClickDate_UNIX),
	LastSentDate AS dbo.fn_ConvertToDateTime(LastSentDate_UNIX);

ALTER TABLE Mail
ADD SentDate AS dbo.fn_ConvertToDateTime(SentDate_UNIX),
	Created AS dbo.fn_ConvertToDateTime(Created_UNIX);

ALTER TABLE UrlClick
ADD ClickDate AS dbo.fn_ConvertToDateTime(ClickDate_UNIX);

ALTER TABLE ListSubscriber
ADD SubscribeDate AS dbo.fn_ConvertToDateTime(SubscribeDate_UNIX),
	UnsubscribeDate AS dbo.fn_ConvertToDateTime(UnsubscribeDate_UNIX);
GO