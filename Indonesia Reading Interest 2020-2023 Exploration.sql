Select *
from indonesia_reading;

# DATA CLEANING AND PREPARATION
-- Changing name of the column
Alter table indonesia_reading
rename column ï»¿Provinsi to Province;

-- Checking missing values
Select 
	SUM(CASE WHEN Province IS NULL THEN 1 ELSE 0 END) AS NULL_Province,
    SUM(CASE WHEN Year IS NULL THEN 1 ELSE 0 END) AS NULL_Year,
    SUM(CASE WHEN `Reading Frequency per week` IS NULL THEN 1 ELSE 0 END) AS NULL_ReadingFrequency,
    SUM(CASE WHEN `Number of Readings per Quarter` IS NULL THEN 1 ELSE 0 END) AS NULL_NumReadings,
    SUM(CASE WHEN `Daily Reading Duration (in minutes)` IS NULL THEN 1 ELSE 0 END) AS NULL_DailyReading,
    SUM(CASE WHEN `Internet Access Frequency per Week` IS NULL THEN 1 ELSE 0 END) AS NULL_InternetAccess,
    SUM(CASE WHEN `Daily Internet Duration (in minutes)` IS NULL THEN 1 ELSE 0 END) AS NULL_Internet_Dur,
    SUM(CASE WHEN `Tingkat Kegemaran Membaca (Reading Interest)` IS NULL THEN 1 ELSE 0 END) AS NULL_Ri,
    SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS NULL_Category
from indonesia_reading;

-- Drop Indonesia From Province Column
Delete from indonesia_reading
Where Province = 'Indonesia';

# DESCCRIPTIVE STATISTICS
Select 
	ROUND(AVG(`Reading Frequency per week`),2) as avg_RF,
	MIN(`Reading Frequency per week`) as min_RF,
	MAX(`Reading Frequency per week`) as max_RF,
	
	ROUND(AVG(`Number of Readings per Quarter`),2) as avg_NR,
	MIN(`Number of Readings per Quarter`) as min_NR,
	MAX(`Number of Readings per Quarter`) as max_NR,
    
    ROUND(AVG(`Daily Reading Duration (in minutes)`),2) as avg_DRD,
	MIN(`Daily Reading Duration (in minutes)`) as min_DRD,
	MAX(`Daily Reading Duration (in minutes)`) as max_DRD,
    
	ROUND(AVG(`Internet Access Frequency per Week`),2) AS avg_IAF,
    MIN(`Internet Access Frequency per Week`) AS min_IAF,
    MAX(`Internet Access Frequency per Week`) AS max_IAF,

    ROUND(AVG(`Daily Internet Duration (in minutes)`),2) AS avg_DID,
    MIN(`Daily Internet Duration (in minutes)`) AS min_DID,
    MAX(`Daily Internet Duration (in minutes)`) AS max_DID,

    ROUND(AVG(`Tingkat Kegemaran Membaca (Reading Interest)`),2) AS avg_TGM,
    MIN(`Tingkat Kegemaran Membaca (Reading Interest)`) AS min_TGM,
    MAX(`Tingkat Kegemaran Membaca (Reading Interest)`) AS max_TGM
    
from indonesia_reading;

# ANNUAL TRENDS IN READING INTEREST
-- Calculate Average Tingkat Kegemaran Membaca per Year
Select Year, 
	ROUND(AVG(`Tingkat Kegemaran Membaca (Reading Interest)`),2) AS avg_TGM
From indonesia_reading
Group by Year
Order by Year;

-- Calculates the average Daily Reading Duration and Daily Internet Duration for each year.
Select Year, 
	ROUND(AVG(`Daily Reading Duration (in minutes)`), 2) AS avg_reading_duration,
    ROUND(AVG(`Daily Internet Duration (in minutes)`), 2) AS avg_internet_duration
From indonesia_reading
Group by Year
Order by Year;

# REGIONAL COMPARISONS
Select Province,
	ROUND(AVG(`Reading Frequency per week`),2) as avg_RF,
    ROUND(AVG(`Daily Reading Duration (in minutes)`),2) as avg_DRD,
    ROUND(AVG(`Tingkat Kegemaran Membaca (Reading Interest)`),2) AS avg_TGM
From indonesia_reading
Group by Province
Order by avg_TGM DESC;

# CORRELATION BETWEEN INTERNET AND READING
Select Year, Province,
	ROUND(AVG(`Daily Internet Duration (in minutes)`),2) AS avg_DID,
	ROUND(AVG(`Daily Reading Duration (in minutes)`),2) as avg_DRD
From indonesia_reading
Group by Year, Province;

# READING INTEREST LEVEL (TGM) Categorization
Select Province,
	CASE
		WHEN ROUND(AVG(`Tingkat Kegemaran Membaca (Reading Interest)`),2) BETWEEN 0 AND 20 THEN 'Very Low'
        WHEN ROUND(AVG(`Tingkat Kegemaran Membaca (Reading Interest)`),2) BETWEEN 20.1 AND 40 THEN 'Low'
        WHEN ROUND(AVG(`Tingkat Kegemaran Membaca (Reading Interest)`),2) BETWEEN 40.1 AND 60 THEN 'Moderate'
        WHEN ROUND(AVG(`Tingkat Kegemaran Membaca (Reading Interest)`),2) BETWEEN 60.1 AND 80 THEN 'High'
		ELSE 'Very High'
	END AS TGM_Category, ROUND(AVG(`Tingkat Kegemaran Membaca (Reading Interest)`), 2) AS avg_TGM
From indonesia_reading
Group by Province
Order by avg_TGM Desc;

# YEAR OVER YEAR PERCETAGE CHANGE IN THE TGM SCORE FOR EACH PROVINCE 
Select Province, Year,
	ROUND((TGM_Current - TGM_Previous)/(TGM_Previous)*100,2) as Percent_Change
From(
	Select
		Province, Year, 
		ROUND(AVG(`Tingkat Kegemaran Membaca (Reading Interest)`),2) as TGM_Current,
		LAG(ROUND(AVG(`Tingkat Kegemaran Membaca (Reading Interest)`),2)) OVER (PARTITION BY Province ORDER BY Year) as TGM_Previous
	From indonesia_reading
	Group by Province, Year
	) as Changes
Where TGM_Previous is not null
Order by Percent_Change DESC;

# TOP & BOTTOM PROVINCES BASED ON TGM
SELECT `Province`, `Year`,
       AVG(`Tingkat Kegemaran Membaca (Reading Interest)`) AS avg_TGM
FROM indonesia_reading
WHERE Year = 2021
GROUP BY `Province`, `Year`
ORDER BY avg_TGM DESC
LIMIT 5;

SELECT `Province`, Year,
       AVG(`Tingkat Kegemaran Membaca (Reading Interest)`) AS avg_TGM
FROM indonesia_reading
WHERE Year = 2021
GROUP BY `Province`, Year
ORDER BY avg_TGM ASC
LIMIT 5;

# TGM CATEGORY DISTRIBUTION OVER TIME
SELECT `Year`, `Category`, COUNT(*) AS count_per_category
FROM indonesia_reading
GROUP BY `Year`, `Category`
ORDER BY `Year`, count_per_category DESC;

# Provinces with the Most Significant Improvement in TGM
WITH province_growth AS (
    SELECT `Province`, `Year`, 
           Round(AVG(`Tingkat Kegemaran Membaca (Reading Interest)`),2) AS avg_TGM,
           LAG(AVG(`Tingkat Kegemaran Membaca (Reading Interest)`)) 
           OVER (PARTITION BY `Province` ORDER BY `Year`) AS prev_year_TGM
    FROM indonesia_reading
    GROUP BY `Province`, `Year`
)
SELECT `Province`, `Year`, avg_TGM, 
       round((avg_TGM - prev_year_TGM),2) AS TGM_increase
FROM province_growth
WHERE prev_year_TGM IS NOT NULL
ORDER BY TGM_increase DESC
LIMIT 5;
