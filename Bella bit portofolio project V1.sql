-- LOOKING FOR AND DELETING BLANK ENTRIES
DELETE 
FROM BellaBit_CaseStudy..dailyActivity_mergedCSV
WHERE Id is null;

--LOOKING AT DAILY ACTIVITY TABLE
SELECT *
FROM BellaBit_CaseStudy..dailyActivity_mergedCSV

-- LOOKING FOR AND DELETING ENTRIES WITH ZERO VALUES
DELETE 
FROM BellaBit_CaseStudy..sleepDay_mergedCSV
WHERE Id= 0;

-- getting the exact number of users in the dataset
SELECT DISTINCT Id
FROM BellaBit_CaseStudy..dailyActivity_mergedCSV

-- THERE ARE 33 DISTINCT IDs THEREFORE 33 USERS

-- LOOKING AT THE TOTAL NUMBER OF DAYS  

SELECT DISTINCT ActivityDate
FROM BellaBit_CaseStudy..dailyActivity_mergedCSV

-- EXPLORING DATA

-- LOOKING AT TOTAL ACTIVE MINUETS BY USERS PER DAY 
SELECT Id,ActivityDate,VeryActiveMinutes,
   FairlyActiveMinutes, LightlyActiveMinutes, (VeryActiveMinutes+FairlyActiveMinutes+LightlyActiveMinutes) AS 
   TotalActiveMinuets
FROM BellaBit_CaseStudy..dailyActivity_mergedCSV
ORDER BY 1,2 ;

-- LOOKING AT MOST ACTIVE DAYS BY USERS

SELECT Id,ActivityDate,MAX(VeryActiveMinutes+FairlyActiveMinutes+LightlyActiveMinutes) AS MostActiveDays
FROM BellaBit_CaseStudy..dailyActivity_mergedCSV
GROUP BY Id,ActivityDate
ORDER BY MostActiveDays desc;

-- TOTAL TRACKED TIME PER A DAY IN HOURS 

SELECT Id,ActivityDate,VeryActiveMinutes,
   FairlyActiveMinutes, LightlyActiveMinutes, SedentaryMinutes, (VeryActiveMinutes+FairlyActiveMinutes+LightlyActiveMinutes+SedentaryMinutes)/60 AS 
   TotalTrackedHours
FROM BellaBit_CaseStudy..dailyActivity_mergedCSV
ORDER BY 1,2;

/* SINCE WE HAVE THE TOTAL NUMBER OF TRACKED HOURS FOR ALL THE USERS ON ANY GIVEN DAY, FOR A PERIOD OF 31 DAYS.
  WE CAN CALCULATE THE PERCENTAGE OF TRACKED TIME VS TOTAL TIME IN A DAY OR FOR THE WHOLE 31 DAYS. HENCEFORTH KNOW  
  THE NUMBER OF HOURS THAT THE USERS USED THIS PRODUCT ON A DAILY BASIS IN AVERAGE.    */


-- LOOKING AT TOTAL STEPS WALKED BY USERS PER DAY

SELECT Id,ActivityDay,StepTotal
FROM BellaBit_CaseStudy..dailySteps_mergedCSV

-- LOOKING AT HOW MAY USERS WE HAVE TOTAL STEPS DATA

SELECT COUNT(DISTINCT Id)
FROM BellaBit_CaseStudy..dailySteps_mergedCSV  -- WE HAVE A TOTAL OF 33 USERS IN THIS DATA

-- LOOKING AT THE TIME FRAME IN WHICH THIS DATA WAS COLLECTD

SELECT COUNT(DISTINCT ActivityDay)
FROM BellaBit_CaseStudy..dailySteps_mergedCSV  -- THIS DATA WAS COLLECTED FOR 31 DAYS PERIOD

-- LOOKING AT USERS SLEEP DATA

SELECT *
FROM BellaBit_CaseStudy..sleepDay_mergedCSV


--LOOKING AT THE NUMBER OF USERS IN THE SLEEP DATA

SELECT COUNT(DISTINCT Id)
FROM BellaBit_CaseStudy..sleepDay_mergedCSV   -- WE HAVE THE SLEEPING DATA OF 24 USERS


-- LOOKING AT THE RANGE OF DAYS THE SLEEPING DATA WAS TRACKED

SELECT COUNT(DISTINCT SleepDay)
FROM BellaBit_CaseStudy..sleepDay_mergedCSV   -- WE HAVE THE TIME RANGE OF 31 DAYS

--LOOKING AT TOTAL SLEEP RECORDS

SELECT Id, TotalSleepRecords
FROM BellaBit_CaseStudy..sleepDay_mergedCSV
ORDER BY TotalSleepRecords

-- LOOKING AT DURATION OF SLEEP

SELECT Id, SleepDay,TotalMinutesAsleep,TotalTimeInBed, (TotalTimeInBed-TotalMinutesAsleep) AS TotalTimeToFallAsleep
FROM BellaBit_CaseStudy..sleepDay_mergedCSV

-- LOOKING AT TIME IT TOOK TO FALL ASLEEP

SELECT Id, SleepDay, TotalMinutesAsleep, TotalTimeInBed, (TotalTimeInBed-TotalMinutesAsleep) as TotalTimeToFallAsleep
FROM BellaBit_CaseStudy..sleepDay_mergedCSV
GROUP BY Id, SleepDay,TotalMinutesAsleep, TotalTimeInBed
ORDER BY TotalTimeToFallAsleep desc

/* IN AVERAGE IT TAKES THE USERS ABOUT 40 MINUETS TO FALL ASLEEP ONCE THEY GO TO BED */

-- IF WE DEFINE NAPS AS SLEEP DURATION WHICH LASTS LESS THAT 30 MINUETS HOW MANY OF THE USERS TAKE NAPS AND HOW OFTEN

SELECT ID, SleepDay, TotalMinutesAsleep
FROM BellaBit_CaseStudy..sleepDay_mergedCSV
WHERE TotalMinutesAsleep <= 60

-- OF ALL THE 24 ONLY T USERS TOOK NAPS IN THE 31 DAYS PERIOD.

--IF WE DEFINE THE OPTIMUM SLEEP DURATION TO BE SEVEN HOURS A DAY HOW MANY USERS ARE GETING ENOUGH SLEEP A DAY

SELECT ID, SleepDay, TotalMinutesAsleep
FROM BellaBit_CaseStudy..sleepDay_mergedCSV
WHERE TotalMinutesAsleep >= 420
/* ONLY 21 OUT OF THE 24 PARTICIPANTS ARE GETTING MORE OR EQUAL TO  7 HOURS OF SLEEP DAYLY BASIS. */


/* JOINING THE DAILY ACTIVITY AND SLEEP DAY TABLES TO GET SOME INSIGHTS IN HOW ACTIVITY IMPACTS QUALITY AND DURATION OF SLEEP*/

-- looking at most active days VS duration of sleep
SELECT ACT.Id, ACT.ActivityDate, (ACT.VeryActiveMinutes+ACT.LightlyActiveMinutes+ACT.FairlyActiveMinutes) AS TotalActiveTime, SLP.TotalMinutesAsleep
FROM BellaBit_CaseStudy..dailyActivity_mergedCSV ACT
JOIN BellaBit_CaseStudy..sleepDay_mergedCSV SLP
   ON ACT.Id = SLP.Id
   AND ACT.ActivityDate = SLP.SleepDay
GROUP BY ACT.Id, ACT.ActivityDate,SLP.TotalMinutesAsleep, ACT.LightlyActiveMinutes, ACT.FairlyActiveMinutes, ACT.VeryActiveMinutes
ORDER BY TotalActiveTime desc

-- looking at most active days VS quality of sleep( as calculated by the difference between total time in bed and total time asleep)

SELECT ACT.Id, ACT.ActivityDate, (ACT.VeryActiveMinutes+ACT.LightlyActiveMinutes+ACT.FairlyActiveMinutes) AS TotalActiveTime, (SLP.TotalTimeInBed-SLP.TotalMinutesAsleep) AS QualityOfSleep
FROM BellaBit_CaseStudy..dailyActivity_mergedCSV ACT
JOIN BellaBit_CaseStudy..sleepDay_mergedCSV SLP
   ON ACT.Id = SLP.Id
   AND ACT.ActivityDate = SLP.SleepDay
GROUP BY ACT.Id, ACT.ActivityDate,SLP.TotalMinutesAsleep,TotalTimeInBed,ACT.LightlyActiveMinutes, ACT.FairlyActiveMinutes, ACT.VeryActiveMinutes
ORDER BY TotalActiveTime desc

-- LOOKING AT TOTAL STEPS VS QUALITY OF SLEEP( as calculated by the difference between total time in bed and total time asleep)

SELECT STP.Id,STP.ActivityDay, STP.StepTotal, (SLP.TotalTimeInBed-SLP.TotalMinutesAsleep) AS QualityOfSleep
FROM BellaBit_CaseStudy..dailySteps_mergedCSV STP
JOIN BellaBit_CaseStudy..sleepDay_mergedCSV SLP
   ON STP.Id = SLP.Id
   AND STP.ActivityDay = SLP.SleepDay
GROUP BY STP.ActivityDay, STP.Id, STP.StepTotal, SLP.TotalMinutesAsleep, SLP.TotalTimeInBed
ORDER BY QualityOfSleep DESC

-- creating views for data vizualization purposes


USE BellaBit_CaseStudy
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW TimeToFallAsleep AS (
   SELECT Id, SleepDay, TotalMinutesAsleep, TotalTimeInBed, (TotalTimeInBed-TotalMinutesAsleep) as TotalTimeToFallAsleep
FROM BellaBit_CaseStudy..sleepDay_mergedCSV
GROUP BY Id, SleepDay,TotalMinutesAsleep, TotalTimeInBed
--ORDER BY TotalTimeToFallAsleep desc
)

USE BellaBit_CaseStudy
SET ANSI_NULLS ON 
SET QUOTED_IDENTIFIER ON
CREATE VIEW ActivityAndSleep AS (
SELECT ACT.Id, ACT.ActivityDate, (ACT.VeryActiveMinutes+ACT.LightlyActiveMinutes+ACT.FairlyActiveMinutes) AS TotalActiveTime, SLP.TotalMinutesAsleep
FROM BellaBit_CaseStudy..dailyActivity_mergedCSV ACT
JOIN BellaBit_CaseStudy..sleepDay_mergedCSV SLP
   ON ACT.Id = SLP.Id
   AND ACT.ActivityDate = SLP.SleepDay
GROUP BY ACT.Id, ACT.ActivityDate,SLP.TotalMinutesAsleep, ACT.LightlyActiveMinutes, ACT.FairlyActiveMinutes, ACT.VeryActiveMinutes
--ORDER BY TotalActiveTime desc
)

USE BellaBit_CaseStudy
SET ANSI_NULLS ON 
SET QUOTED_IDENTIFIER ON
CREATE VIEW 

