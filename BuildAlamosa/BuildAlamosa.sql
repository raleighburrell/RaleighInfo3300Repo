--Created by Raleigh Burrell on September 29th
--Version 1
--Buil Alamosa Database
--
-- Replace <data_path> with the full path to this file 
-- Ensure it ends with a backslash. 
-- E.g., C:\MyDatabases\ See line 16
--

--Step 1: Create Databse
IF NOT EXISTS(SELECT * FROM sys.databases  --only adds if it doesn't exist
	WHERE name = N'Alamosa')
	CREATE DATABASE Alamosa
GO
USE Alamosa

DECLARE
	@data_path NVARCHAR(256);
SELECT @data_path = '\\Mac\Home\Documents\DU YR 3\INFO 3300\Project\Alamosa Tourism\BuildAlamosa\'; --Change this!


--Step 2: Delete Existing Tables
IF EXISTS( --removes a table if it exists
	SELECT * 
	FROM sys.tables
	WHERE name = N'ListSubscriber'
	)
	DROP TABLE ListSubscriber;

IF EXISTS( --removes a table if it exists
	SELECT * 
	FROM sys.tables
	WHERE name = N'ListMail'
	)
	DROP TABLE ListMail;

IF EXISTS( --removes a table if it exists
	SELECT * 
	FROM sys.tables
	WHERE name = N'UrlClick'
	)
	DROP TABLE UrlClick;

IF EXISTS( --removes a table if it exists
	SELECT * 
	FROM sys.tables
	WHERE name = N'Mail'
	)
	DROP TABLE Mail;

IF EXISTS( --removes a table if it exists
	SELECT * 
	FROM sys.tables
	WHERE name = N'Subscriber'
	)
	DROP TABLE Subscriber;

IF EXISTS( --removes a table if it exists
	SELECT * 
	FROM sys.tables
	WHERE name = N'List'
	)
	DROP TABLE List;

IF EXISTS( --removes a table if it exists
	SELECT * 
	FROM sys.tables
	WHERE name = N'GeoLocation'
	)
	DROP TABLE GeoLocation;

IF EXISTS( --removes a table if it exists
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
  Created DATETIME,
  Confirmed INT,
  Enabled INT,
  Accept INT,
  IP NVARCHAR(100),
  Html INT,
  [Key] NVARCHAR(250),
  ConfirmedDate DATETIME,
  ConfirmedIP NVARCHAR(100),
  LastOpenDate DATETIME,
  LastOpenIP NVARCHAR(100),
  LastClickDate DATETIME,
  LastSentDate DATETIME,
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
  Source NVARCHAR(250)
  );

--GeoLocation
CREATE TABLE GeoLocation
  (GeoLocationID INT CONSTRAINT pk_geolocation PRIMARY KEY,
  SubscriberID INT CONSTRAINT fk_geolocation_subscriber FOREIGN KEY REFERENCES Subscriber(SubscriberID),
  [Type] NVARCHAR(255),
  IP NVARCHAR(255),
  Created DATETIME,
  Latitude DECIMAL(9,6),
  Longitude DECIMAL(9,6),
  PostalCode NVARCHAR(255),
  Country NVARCHAR(255),
  CountryCode NVARCHAR(255),
  State NVARCHAR(255),
  StateCode NVARCHAR(255),
  City NVARCHAR(255),
  Continent NVARCHAR(255),
  TimeZone NVARCHAR(255)
  );

---List
CREATE TABLE List
  (ListID INT CONSTRAINT pk_list PRIMARY KEY,
  Name NVARCHAR(250),
  Description NTEXT,
  Ordering INT,
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
  TemplateID INT CONSTRAINT fk_mail_template FOREIGN KEY REFERENCES Template(TemplateID),
  Subject NTEXT,
  Body NTEXT,
  AltBody NTEXT,
  Published INT,
  SentDate DATETIME,
  Created DATETIME,
  FromName NVARCHAR(250),
  FromEmail NVARCHAR(250),
  ReplyName NVARCHAR(250),
  ReplyEmail NVARCHAR(250),
  [Type] NVARCHAR(50),
  Visible INT,
  UserID INT,
  Alias NVARCHAR(250),
  Attach NTEXT,
  Html INT,
  [Key] NVARCHAR(200),
  Frequency NVARCHAR(50),
  Params NTEXT,
  SentBy INT,
  MetaKey NTEXT,
  MetaDesc NTEXT,
  Filter NTEXT,
  Language NVARCHAR(50),
  ABTesting NVARCHAR(250),
  Thumb NVARCHAR(250),
  Summary NTEXT,
  FavIcon NTEXT,
  BCCAddresses NVARCHAR(250)
  );

---UrlClick
CREATE TABLE UrlClick
  (UrlID INT CONSTRAINT fk_urlclick_url FOREIGN KEY REFERENCES Url(UrlID),
  MailID INT CONSTRAINT fk_urlclick_mail FOREIGN KEY REFERENCES Mail(MailID),
  SubscriberID INT CONSTRAINT fk_urlclick_subscriber FOREIGN KEY REFERENCES Subscriber(SubscriberID),
  Click INT,
  [Date] DATETIME,
  IP NVARCHAR(100)
  );

---ListMail
CREATE TABLE ListMail
  (ListID INT CONSTRAINT fk_listmail_list FOREIGN KEY REFERENCES List(ListID),
  MailID INT CONSTRAINT fk_listmail_mail FOREIGN KEY REFERENCES Mail(MailID)
  );

---ListSub
CREATE TABLE ListSubscriber
  (ListID INT CONSTRAINT fk_listsubscriber_list FOREIGN KEY REFERENCES List(ListID),
  SubscriberID INT CONSTRAINT fk_listsubscriber_subscriber FOREIGN KEY REFERENCES Subscriber(SubscriberID),
  SuscribeDate DATETIME,
  UnsuscriberDate DATETIME,
  Status INT
  );


--Step 4: Bulk Load the Data
---Template
EXECUTE (N'BULK INSERT Template FROM ''' + @data_path + N'Template.csv''
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

---Tag
EXECUTE (N'BULK INSERT Tag FROM ''' + @data_path + N'Tag.csv''
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
EXECUTE (N'BULK INSERT Subscriber FROM ''' + @data_path + N'Subscriber.csv''
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
EXECUTE (N'BULK INSERT Mail FROM ''' + @data_path + N'Mail.csv''
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

---TagMail
EXECUTE (N'BULK INSERT TagMail FROM ''' + @data_path + N'TagMail.csv''
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


--List Table Names & Row Counts
GO
SET NOCOUNT ON
SELECT 'Template' "Table",	COUNT(*) "Rows"	FROM Template		UNION
SELECT 'Tag',				COUNT(*)		FROM Tag			UNION
SELECT 'Url',				COUNT(*)		FROM Url			UNION
SELECT 'GeoLocation',		COUNT(*)		FROM GeoLocation	UNION
SELECT 'List',				COUNT(*)		FROM List			UNION
SELECT 'Subscriber',        COUNT(*)		FROM Subscriber		UNION
SELECT 'Mail',				COUNT(*)		FROM Mail			UNION
SELECT 'TagMail',			COUNT(*)		FROM TagMail		UNION
SELECT 'UrlClick',			COUNT(*)		FROM UrlClick		UNION
SELECT 'ListMail',			COUNT(*)		FROM ListMail		UNION
SELECT 'ListSubscriber',	COUNT(*)		FROM ListSubscriber
ORDER BY 1;
SET NOCOUNT OFF
GO