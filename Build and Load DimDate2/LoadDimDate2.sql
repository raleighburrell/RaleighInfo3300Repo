-- Load a Date Dimension (DimDate) adapted by Amy Phillips
USE AdventureWorksDW2014

-- Specify start date and end date here
-- Value of start date must be less than your end date 

DECLARE @StartDate DATETIME = '01/01/2010' -- Starting value of date range
DECLARE @EndDate DATETIME = '9/19/2017' -- End Value of date range

-- Temporary variables to hold the values during processing of each date of year
DECLARE
	@DayOfWeekInMonth INT,
	@DayOfWeekInYear INT,
	@DayOfQuarter INT,
	@WeekOfMonth INT,
	@CurrentYear INT,
	@CurrentMonth INT,
	@CurrentQuarter INT

-- Table data type to store the day of week count for the month and year
DECLARE @DayOfWeek TABLE (DOW INT, MonthCount INT, QuarterCount INT, YearCount INT)

INSERT INTO @DayOfWeek VALUES (1, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (2, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (3, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (4, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (5, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (6, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (7, 0, 0, 0)

-- Extract and assign various parts of values from current date to variable

DECLARE @CurrentDate AS DATETIME = @StartDate
SET @CurrentMonth = DATEPART(MM, @CurrentDate)
SET @CurrentYear = DATEPART(YY, @CurrentDate)
SET @CurrentQuarter = DATEPART(QQ, @CurrentDate)

-- Proceed only if start date(current date ) is less than end date you specified above

WHILE @CurrentDate < @EndDate
BEGIN
 
-- Begin day of week logic

	/*Check for change in month of the current date if month changed then change variable value*/
	IF @CurrentMonth <> DATEPART(MM, @CurrentDate) 
	BEGIN
		UPDATE @DayOfWeek
		SET MonthCount = 0
		SET @CurrentMonth = DATEPART(MM, @CurrentDate)
	END

	/* Check for change in quarter of the current date if quarter changed then change variable value*/

	IF @CurrentQuarter <> DATEPART(QQ, @CurrentDate)
	BEGIN
		UPDATE @DayOfWeek
		SET QuarterCount = 0
		SET @CurrentQuarter = DATEPART(QQ, @CurrentDate)
	END
       
	/* Check for Change in Year of the Current date if Year changed then change variable value*/
	
	IF @CurrentYear <> DATEPART(YY, @CurrentDate)
	BEGIN
		UPDATE @DayOfWeek
		SET YearCount = 0
		SET @CurrentYear = DATEPART(YY, @CurrentDate)
	END
	
-- Set values in table data type created above from variables 

	UPDATE @DayOfWeek
	SET 
		MonthCount = MonthCount + 1,
		QuarterCount = QuarterCount + 1,
		YearCount = YearCount + 1
	WHERE DOW = DATEPART(DW, @CurrentDate)

	SELECT
		@DayOfWeekInMonth = MonthCount,
		@DayOfQuarter = QuarterCount,
		@DayOfWeekInYear = YearCount
	FROM @DayOfWeek
	WHERE DOW = DATEPART(DW, @CurrentDate)
	
-- End day of week logic

	/* Populate your dimension table with values*/
	
	INSERT INTO [dbo].[DimDate2]
	SELECT
		
		CONVERT (char(8),@CurrentDate,112) AS DateSK,
		@CurrentDate AS Date,
		CONVERT (char(10),@CurrentDate,101) AS FullDate,
		DATEPART(DD, @CurrentDate) AS DayOfMonth,
		DATENAME(DW, @CurrentDate) AS DayName,
		DATEPART(DW, @CurrentDate) AS DayOfWeek,
		@DayOfWeekInMonth AS DayOfWeekInMonth,
		@DayOfWeekInYear AS DayOfWeekInYear,
		@DayOfQuarter AS DayOfQuarter,
		DATEPART(DY, @CurrentDate) AS DayOfYear,
		DATEPART(WW, @CurrentDate) + 1 - DATEPART(WW, CONVERT(VARCHAR, 
		DATEPART(MM, @CurrentDate)) + '/1/' + CONVERT(VARCHAR, 
		DATEPART(YY, @CurrentDate))) AS WeekOfMonth,
		(DATEDIFF(DD, DATEADD(QQ, DATEDIFF(QQ, 0, @CurrentDate), 0), 
		@CurrentDate) / 7) + 1 AS WeekOfQuarter,
		DATEPART(WW, @CurrentDate) AS WeekOfYear,
		DATEPART(MM, @CurrentDate) AS Month,
		DATENAME(MM, @CurrentDate) AS MonthName,
		CASE
			WHEN DATEPART(MM, @CurrentDate) IN (1, 4, 7, 10) THEN 1
			WHEN DATEPART(MM, @CurrentDate) IN (2, 5, 8, 11) THEN 2
			WHEN DATEPART(MM, @CurrentDate) IN (3, 6, 9, 12) THEN 3
			END AS MonthOfQuarter,
		'Q' + CONVERT(VARCHAR, DATEPART(QQ, @CurrentDate)) AS Quarter,
		CASE DATEPART(QQ, @CurrentDate)
			WHEN 1 THEN 'First'
			WHEN 2 THEN 'Second'
			WHEN 3 THEN 'Third'
			WHEN 4 THEN 'Fourth'
			END AS QuarterName,
		DATEPART(YEAR, @CurrentDate) AS Year,
		'CY ' + CONVERT(VARCHAR, DATEPART(YEAR, @CurrentDate)) AS YearName,
		LEFT(DATENAME(MM, @CurrentDate), 3) + '-' + CONVERT(VARCHAR, 
		DATEPART(YY, @CurrentDate)) AS MonthYear,
		RIGHT('0' + CONVERT(VARCHAR, DATEPART(MM, @CurrentDate)),2) + 
		CONVERT(VARCHAR, DATEPART(YY, @CurrentDate)) AS MMYYYY,
		CONVERT(DATETIME, CONVERT(DATE, DATEADD(DD, - (DATEPART(DD, 
		@CurrentDate) - 1), @CurrentDate))) AS FirstDayOfMonth,
		CONVERT(DATETIME, CONVERT(DATE, DATEADD(DD, - (DATEPART(DD, 
		(DATEADD(MM, 1, @CurrentDate)))), DATEADD(MM, 1, 
		@CurrentDate)))) AS LastDayOfMonth,
		DATEADD(QQ, DATEDIFF(QQ, 0, @CurrentDate), 0) AS FirstDayOfQuarter,
		DATEADD(QQ, DATEDIFF(QQ, -1, @CurrentDate), -1) AS LastDayOfQuarter,
		CONVERT(DATETIME, '01/01/' + CONVERT(VARCHAR, DATEPART(YY, 
		@CurrentDate))) AS FirstDayOfYear,
		CONVERT(DATETIME, '12/31/' + CONVERT(VARCHAR, DATEPART(YY, 
		@CurrentDate))) AS LastDayOfYear,
		NULL AS IsHoliday,
		CASE DATEPART(DW, @CurrentDate)
			WHEN 1 THEN 0
			WHEN 2 THEN 1
			WHEN 3 THEN 1
			WHEN 4 THEN 1
			WHEN 5 THEN 1
			WHEN 6 THEN 1
			WHEN 7 THEN 0
			END AS IsWeekday,
		NULL AS Holiday,
		 CASE
			WHEN DATEPART(MM, @CurrentDate) IN (12,1,2) THEN 'Winter'
			WHEN DATEPART(MM, @CurrentDate) IN (3,4,5) THEN 'Spring'
			WHEN DATEPART(MM, @CurrentDate) IN (6,7,8) THEN 'Summer'
			WHEN DATEPART(MM, @CurrentDate) IN (9,10,11) THEN 'Fall'
			END AS Season

	SET @CurrentDate = DATEADD(DD, 1, @CurrentDate)
END

--Update values of holiday as per USA Govt. Declaration for National Holiday

	-- THANKSGIVING - Fourth THURSDAY in November
	UPDATE [dbo].[DimDate2]
		SET Holiday = 'Thanksgiving Day'
	WHERE
		[Month] = 11 
		AND [DayName] = 'Thursday' 
		AND DayOfWeekInMonth = 4

	-- CHRISTMAS
	UPDATE [dbo].[DimDate2]
		SET Holiday = 'Christmas Day'
		
	WHERE [Month] = 12 AND [DayOfMonth]  = 25

	-- 4th of July
	UPDATE [dbo].[DimDate2]
		SET Holiday = 'Independance Day'
	WHERE [Month] = 7 AND [DayOfMonth] = 4

	-- New Years Day
	UPDATE [dbo].[DimDate2]
		SET Holiday = 'New Year''s Day'
	WHERE [Month] = 1 AND [DayOfMonth] = 1

	-- Memorial Day - Last Monday in May
	UPDATE [dbo].[DimDate2]
		SET Holiday = 'Memorial Day'
	FROM [dbo].[DimDate2]
	WHERE DateSK IN 
		(
		SELECT
			MAX(DateSK)
		FROM [dbo].[DimDate2]
		WHERE
			[MonthName] = 'May'
			AND [DayName]  = 'Monday'
		GROUP BY
			[Year],
			[Month]
		)

	-- Labor Day - First Monday in September
	UPDATE [dbo].[DimDate2]
		SET Holiday = 'Labor Day'
	FROM [dbo].[DimDate2]
	WHERE DateSK IN 
		(
		SELECT
			MIN(DateSK)
		FROM [dbo].[DimDate2]
		WHERE
			[MonthName] = 'September'
			AND [DayName] = 'Monday'
		GROUP BY
			[Year],
			[Month]
		)

	-- Valentine's Day
	UPDATE [dbo].[DimDate2]
		SET Holiday = 'Valentine''s Day'
	WHERE
		[Month] = 2 
		AND [DayOfMonth] = 14

	-- Saint Patrick's Day
	UPDATE [dbo].[DimDate2]
		SET Holiday = 'Saint Patrick''s Day'
	WHERE
		[Month] = 3
		AND [DayOfMonth] = 17

	-- Martin Luthor King Day - Third Monday in January starting in 1983
	UPDATE [dbo].[DimDate2]
		SET Holiday = 'Martin Luthor King Jr Day'
	WHERE
		[Month] = 1
		AND [DayName]  = 'Monday'
		AND [Year] >= 1983
		AND DayOfWeekInMonth = 3

	-- President's Day - Third Monday in February
	UPDATE [dbo].[DimDate2]
		SET Holiday = 'President''s Day'
	WHERE
		[Month] = 2
		AND [DayName] = 'Monday'
		AND DayOfWeekInMonth = 3

	-- Mother's Day - Second Sunday of May
	UPDATE [dbo].[DimDate2]
		SET Holiday = 'Mother''s Day'
	WHERE
		[Month] = 5
		AND [DayName] = 'Sunday'
		AND DayOfWeekInMonth = 2

	-- Father's Day - Third Sunday of June
	UPDATE [dbo].[DimDate2]
		SET Holiday = 'Father''s Day'
	WHERE
		[Month] = 6
		AND [DayName] = 'Sunday'
		AND DayOfWeekInMonth = 3

	-- Halloween 10/31*/
	UPDATE [dbo].[DimDate2]
		SET Holiday = 'Halloween'
	WHERE
		[Month] = 10
		AND [DayOfMonth] = 31

	-- Election Day - The first Tuesday after the first Monday in November
	BEGIN
	DECLARE @Holidays TABLE (ID INT IDENTITY(1,1), 
	DateID int, Week TINYINT, YEAR CHAR(4), DAY CHAR(2))

		INSERT INTO @Holidays(DateID, [Year],[Day])
		SELECT
			DateSK,
			[Year],
			[DayOfMonth] 
		FROM [dbo].[DimDate2]
		WHERE
			[Month] = 11
			AND [DayName] = 'Monday'
		ORDER BY
			YEAR,
			DayOfMonth 

		DECLARE @CNTR INT, @POS INT, @STARTYEAR INT, @ENDYEAR INT, @MINDAY INT

		SELECT
			@CURRENTYEAR = MIN([Year]),
			@STARTYEAR = MIN([Year]),
			@ENDYEAR = MAX([Year])
		FROM @Holidays

		WHILE @CURRENTYEAR <= @ENDYEAR
		BEGIN
			SELECT @CNTR = COUNT([Year])
			FROM @Holidays
			WHERE [Year] = @CURRENTYEAR

			SET @POS = 1

			WHILE @POS <= @CNTR
			BEGIN
				SELECT @MINDAY = MIN(DAY)
				FROM @Holidays
				WHERE
					[Year] = @CURRENTYEAR
					AND [Week] IS NULL

				UPDATE @Holidays
					SET [Week] = @POS
				WHERE
					[Year] = @CURRENTYEAR
					AND [Day] = @MINDAY

				SELECT @POS = @POS + 1
			END

			SELECT @CURRENTYEAR = @CURRENTYEAR + 1
		END

		UPDATE [dbo].[DimDate2]
			SET Holiday  = 'Election Day'				
		FROM [dbo].[DimDate2] DT
			JOIN @Holidays HL ON (HL.DateID + 1) = DT.DateSK
		WHERE
			[Week] = 1
	END
	-- Set flag for USA holidays in Dimension
	UPDATE [dbo].[DimDate2]
	SET IsHoliday = 
		CASE	WHEN Holiday IS NULL THEN 0 
			WHEN Holiday IS NOT NULL THEN 1 
	END

/*****************************************************************************************/

SELECT * FROM [dbo].[DimDate2]
