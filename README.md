# Cyclistic
Google Data Analytics Professional Certificate Capstone Project
### Scenario
I am a junior data analyst working in the marketing analyst team at Cyclistic, a bike-share company in Chicago. The director
of marketing believes the company’s future success depends on maximizing the number of annual memberships. Therefore,
my team wants to understand how casual riders and annual members use Cyclistic bikes differently. From these insights,
my team will design a new marketing strategy to convert casual riders into annual members. But first, Cyclistic executives
must approve my recommendations, so they must be backed up with compelling data insights and professional data
visualizations
### About Cyclistic
Cyclistic launched in 2016 and grown to a fleet of 5,824 bicycles that are geotracked and locked into a network of 692 stations across Chicago.

Until now, Cyclistic marketing strategy relied on building general awareness and appealing to broad consumer segments. There are different pricing plans which offers flexibility to the users. Pricing plans are as : single-ride passes, full-day passes, and annual memberships. Casual riders are customer who purchase single-ride and full-day passes whereas Cyclistic members are those who purchased annual memberships.

Financial analyst in Cyclistic has concluded that annual members are much more profitable than casual riders. Therefore, it is believe that the key to future growth was to maximize the number of annual members. It is also believe that it will be more beneficial to create a marketing campaign that targets casual members to become Cyclistic members.

For this case study, I will be using the Google Data Analytics Certificate processes to provide recommendation to the Director of Marketing.
## Ask

### Key Stakeholders
1. Lily Moreno: The director of marketing and responsible for the development of campaigns and initiatives to promote the bike-share program through email, social media, and other channels.

2. Cyclistic executive team: The team that will decide whether to approve the recommended marketing program.

3. Cyclistic marketing analytics team: A team of data analysts who are responsible for collecting, analyzing, and reporting data that helps guide Cyclistic marketing strategy.

### Business Task
Identify ride patterns to help us understand the difference between members and casual users, which will aid in designing a marketing strategy that aims to convert casual riders into members.

## Prepare
Given that Cyclistic is a fictional company, we will be using the data that has been made available by Motivate International Inc. (acquired by Lyft in 2018) under this [license](https://ride.divvybikes.com/data-license-agreement)
Data source: [Data for Cyclistic](https://divvy-tripdata.s3.amazonaws.com/index.html)

The data is organized monthly and broken down into multiple columns which are:
| Column | Description |
| ------ | ----------- |
| ride_id | The ID for each ride |
| rideable_type | The type of bike used |
| started_at | The date and time where the ride started |
| ended_at | The date and time where the ride ended |
| start_station_name |	Station name where the ride started |
| start_station_id |	Station ID where the ride started |
| end_station_name |	Station name where the ride ended |
| end_station_id |	Station ID where the ride ended |
| start_lat |	The latitude of the station where the ride started |
| start_lng |	The longitude of the station where the ride started |
| end_lat |	The latitude of the station where the ride ended |
| end_lng |The longitude of the station where the ride ended
| member_casual |	The membership type of the riders |

For this analysis, we will analyze historical data trip from May 2021 to April 2022.

## Process
In this phase, we will perform different cleaning and transformation procedures using any data analysis tools to ensure data integrity. 
### Data Analysis Tool
I am using PostgreSQL to store the data in database tables and perform SQL queries. 
### Creating database and storing the datasets into tables
<details>
  <summary>Show SQL query</summary>
	
```sql
create table bike_one_052021(
ride_id VARCHAR(100) primary key,
rideable_type VARCHAR(100),
started_at TIMESTAMP,
ended_at TIMESTAMP,
start_station_name VARCHAR(100),
start_station_id VARCHAR(60),
end_station_name VARCHAR(100),
end_station_id VARCHAR(60),
start_lat DECIMAL,
start_lng DECIMAL,
end_lat DECIMAL,
end_lng DECIMAL,
member_casual VARCHAR(20)
);
---Import table using COPY
COPY bike_one(
ride_id,
rideable_type,
started_at,
ended_at,
start_station_name,
start_station_id,
end_station_name,
end_station_id,
start_lat,
start_lng,
end_lat,
end_lng,
member_casual
)
FROM 'D:\Bike data\bike_one.csv'
DELIMITER ','
CSV HEADER;
---- Continue using the same queries to create tables and upload data for the next 11 months

----Then merge all the data from the past 12 months into a single table.
create table cyclistic_data as(
select *
from bike_one_052021
	
union
	
select *
from bike_two_062021
	
union
	
select *
from bike_three_072021
	
union

select *
from bike_four_082021

union

select *
from bike_five_092021

union

select *
from bike_six_102021

union

select *
from bike_seven_112021

union

select *
from bike_eight_122021

union

select *
from bike_nine_012022

union

select *
from bike_ten_022022

union

select *
from bike_eleven_032022

union

select *
from bike_twelve_042022);
---this creates a table with 5757551 rows
```
</details>


### Data Exploration and Inspection
<details>
  <summary>Show SQL query</summary>
	
```sql
--view table
select *
from cyclistic_data

---check for duplicates in ride_id column
select ride_id, count(*)
from cyclist_data
group by ride_id
having count(*)>1
--- 0 rows affected

---check for unique station_id
select start_station_name, count(distinct start_station_id)
from cyclistic_data
group by start_station_name
having count(distinct start_station_id) > 1

with unique_start_name as (
	select distinct start_station_name, start_station_id
	from cyclistic_data)
select start_station_name, start_station_id,
row_number() over(partition by start_station_name) as row_n
from unique_start_name
order by row_n desc


-- Check for invalid value
SELECT DISTINCT 
		rideable_type
FROM cyclistic_data;

SELECT DISTINCT 
		member_casual 
FROM cyclistic_data;

SELECT 
	MAX(LENGTH(ride_id)) AS max_length, 
	MIN(LENGTH(ride_id)) AS min_length	   
FROM cyclistic_data;

select *
from cyclistic_data
where started_at >= ended_at
---652 rows affected

select started_at, ended_at,
 (DATE_PART('Day', ended_at - started_at)) * 24 + 
 (DATE_PART('Hour', ended_at - started_at)) * 60 + 
 (DATE_PART('Minute', ended_at - started_at)) * 60 + 
 (DATE_PART('Second', ended_at - started_at))
from cyclistic_data
where  
(DATE_PART('Day', ended_at - started_at)) * 24 + 
(DATE_PART('Hour', ended_at - started_at)) * 60 +
(DATE_PART('Minute', ended_at - started_at)) * 60 +
(DATE_PART('Second', ended_at - started_at)) <= 0
--- 652 rows affected

---check for missing values
select *
from cyclistic_data
where ride_id is null
or rideable_type is null
or started_at is null
or ended_at is null
or start_station_name is null
or start_station_id is null
or end_station_name is null
or end_station_id is null
or start_lat is null
or start_lng is null
or end_lat is null
or end_lng is null
or member_casual is null
--- 1141803 rows affected
```
</details>

Upon checking the database, I noticed that there are rows with start_station_name having the same value as start_station_id, this could also happen to column end_station_name and end_station_id

![Screenshot (223)](https://github.com/viet-nguyend/cyclist_data/assets/142729978/6b85a379-4f05-4841-bb21-5ddafcb7e902)

![Screenshot (225)](https://github.com/viet-nguyend/cyclist_data/assets/142729978/248c5409-3477-435c-8c18-dd0a26c7a431)

As I tried to find station_ids that match station_names, I noticed there are some stations that are invalid, which should be removed.

```
"Bissell St & Armitage Ave - Charging"
"DIVVY CASSETTE REPAIR MOBILE STATION"
"Hastings WH 2"
"Lincoln Ave & Roscoe St - Charging"
"Pawel Bialowas - Test- PBSC charging station"
"Throop/Hastings Mobile Station"
"Wilton Ave & Diversey Pkwy - Charging"
```

There are no matching station_ids for station_names presented in the tables. However, I was able to find start_station_name for start_station_id "351", which is "Mulligan Ave & Wellington Ave".

### Data cleaning

<details>
  <summary>Show SQL query</summary>
	
```sql
---Delete from the table where rows contain NULL
delete
from cyclistic_data
where ride_id is null
or rideable_type is null
or started_at is null
or ended_at is null
or start_station_name is null
or start_station_id is null
or end_station_name is null
or end_station_id is null
or start_lat is null
or start_lng is null
or end_lat is null
or end_lng is null
or member_casual is null
--- 1141803 rows affected

---Delete rows where started_at >= ended_at
delete
from cyclistic_data
where started_at >= ended_at
---652 rows affected

</details>






