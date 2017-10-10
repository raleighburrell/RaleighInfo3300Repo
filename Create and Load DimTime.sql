-- Create DimTime written by Amy Phillips 
USE AdventureWorksDW2014
GO
CREATE TABLE [dbo].[DimTime]
	(
	TimeSK [int] IDENTITY(1,1) NOT NULL CONSTRAINT [PK_dim_Time] PRIMARY KEY,
	Time CHAR(8) NOT NULL,
	Hour CHAR(2) NOT NULL,
	MilitaryHour CHAR(2) NOT NULL,
	Minute CHAR(2) NOT NULL,
	Second CHAR(2) NOT NULL,
	AmPm CHAR(2) NOT NULL,
	StandardTime CHAR(11) NULL
	);

--------------------------------------------------------------------------------------------------------
PRINT CONVERT(VARCHAR,GETDATE(),113)--USED FOR CHECKING RUN TIME.

SET NOCOUNT ON
--Load time data for every second of a day
DECLARE @Time DATETIME

SET @TIME = CONVERT(VARCHAR,'12:00:00 AM',108)

TRUNCATE TABLE DimTime

WHILE @TIME <= '11:59:59 PM'
	BEGIN
	INSERT INTO dbo.DimTime([Time], [Hour], [MilitaryHour], [Minute], [Second], [AmPm])
	SELECT CONVERT(VARCHAR,@TIME,108) [Time], 
		CASE 
			WHEN DATEPART(HOUR,@Time) > 12 
		THEN DATEPART(HOUR,@Time) - 12
			ELSE DATEPART(HOUR,@Time) 
		END AS [Hour],
	CAST(SUBSTRING(CONVERT(VARCHAR,@TIME,108),1,2) AS INT) [MilitaryHour],
	DATEPART(MINUTE,@Time) [Minute],
	DATEPART(SECOND,@Time) [Second],
	CASE 
		WHEN DATEPART(HOUR,@Time) >= 12 THEN 'PM'
	ELSE 'AM'
	END AS [AmPm]

 SELECT @TIME = DATEADD(second,1,@Time)
 END

UPDATE DimTime
SET [HOUR] = '0' + [HOUR]
WHERE LEN([HOUR]) = 1

UPDATE DimTime
SET [MINUTE] = '0' + [MINUTE]
WHERE LEN([MINUTE]) = 1

UPDATE DimTime
SET [SECOND] = '0' + [SECOND]
WHERE LEN([SECOND]) = 1

UPDATE DimTime
SET [MilitaryHour] = '0' + [MilitaryHour]
WHERE LEN([MilitaryHour]) = 1

UPDATE DimTime
SET StandardTime = [Hour] + ':' + [Minute] + ':' + [Second] + ' ' + AmPm
WHERE StandardTime IS NULL
AND HOUR <> '00'

UPDATE DimTime
SET StandardTime = '12' + ':' + [Minute] + ':' + [Second] + ' ' + AmPm
WHERE [HOUR] = '00'

SELECT * FROM [dbo].[DimTime]
