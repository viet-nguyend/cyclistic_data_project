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


-- Check for invalid value
select distinct rideable_type
from cyclistic_data;

select distinct member_casual 
from cyclistic_data;

select 
	max(length(ride_id)) AS max_length, 
	min(length(ride_id)) AS min_length	   
from cyclistic_data;

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

When checking for ride duration, I found that there are rides with negative ride duration, this indicates that the ride ended earlier than it started, which is not possible. At the same time, I would also check for rides with a ride duration of over 24 hours (86400 seconds), because it is considered a lost or stolen bike arcording to this article [link](https://help.divvybikes.com/hc/en-us/articles/360033484791-What-if-I-keep-a-bike-out-too-long-) 

First, I will create a column that will hold the value of the difference between the started_at datetime and the ended_at datetime. 

<details>
  <summary>Show SQL query</summary>

```sql
ALTER TABLE cyclistic_data
ADD ride_length DECIMAL;

UPDATE cyclistic_data
SET ride_length =  ((DATE_PART('Day', ended_at - started_at)) * 24 * 60 * 60) + 
 ((DATE_PART('Hour', ended_at - started_at)) * 60 * 60) + 
 (DATE_PART('Minute', ended_at - started_at)) * 60 + 
 (DATE_PART('Second', ended_at - started_at))
 
select *
from cyclistic_data
where started_at > ended_at

select started_at, ended_at, ride_length
from cyclistic_data
where  ride_length < 0 or ride_length > 86400

select started_at, ended_at,
 ((DATE_PART('Day', ended_at - started_at)) * 24 * 60 * 60) + 
 ((DATE_PART('Hour', ended_at - started_at)) * 60 * 60) + 
 (DATE_PART('Minute', ended_at - started_at)) * 60 + 
 (DATE_PART('Second', ended_at - started_at))
from cyclistic_data
where  
 ((DATE_PART('Day', ended_at - started_at)) * 24 * 60 * 60) + 
 ((DATE_PART('Hour', ended_at - started_at)) * 60 * 60) + 
 (DATE_PART('Minute', ended_at - started_at)) * 60 + 
 (DATE_PART('Second', ended_at - started_at)) > 86400
```
</details>


Upon checking the database, I noticed that there are rows with start_station_name having the same value as start_station_id, this could also happen to column end_station_name and end_station_id

![Screenshot (223)](https://github.com/viet-nguyend/cyclist_data/assets/142729978/6b85a379-4f05-4841-bb21-5ddafcb7e902)

![Screenshot (225)](https://github.com/viet-nguyend/cyclist_data/assets/142729978/248c5409-3477-435c-8c18-dd0a26c7a431)

As I tried to find station_ids that match station_names, I noticed there are some stations that are invalid, which should be removed.

```
'Bissell St & Armitage Ave - Charging'
'DIVVY CASSETTE REPAIR MOBILE STATION'
'Hastings WH 2'
'Lincoln Ave & Roscoe St - Charging'
'Pawel Bialowas - Test- PBSC charging station'
'Throop/Hastings Mobile Station'
'Wilton Ave & Diversey Pkwy - Charging'
'Base - 2132 W Hubbard Warehouse'
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

---Remove rows where started_at > ended_at or ride duration is larger than 86400 
delete
from cyclistic_data
where
	((DATE_PART('Day', ended_at - started_at)) * 24 * 60 * 60) + 
	((DATE_PART('Hour', ended_at - started_at)) * 60 * 60) + 
	(DATE_PART('Minute', ended_at - started_at)) * 60 + 
	(DATE_PART('Second', ended_at - started_at)) < 0
   or
	((DATE_PART('Day', ended_at - started_at)) * 24 * 60 * 60) + 
	((DATE_PART('Hour', ended_at - started_at)) * 60 * 60) + 
	(DATE_PART('Minute', ended_at - started_at)) * 60 + 
	(DATE_PART('Second', ended_at - started_at)) > 86400


---delete unvalid station
delete
from cyclistic_data
where start_station_name in ('Bissell St & Armitage Ave - Charging'
				'DIVVY CASSETTE REPAIR MOBILE STATION'
				'Hastings WH 2'
				'Lincoln Ave & Roscoe St - Charging'
				'Pawel Bialowas - Test- PBSC charging station'
				'Throop/Hastings Mobile Station'
				'Wilton Ave & Diversey Pkwy - Charging'
				'Base - 2132 W Hubbard Warehouse')

delete
from cyclistic_data
where end_station_name in ('Bissell St & Armitage Ave - Charging'
				'DIVVY CASSETTE REPAIR MOBILE STATION'
				'Hastings WH 2'
				'Lincoln Ave & Roscoe St - Charging'
				'Pawel Bialowas - Test- PBSC charging station'
				'Throop/Hastings Mobile Station'
				'Wilton Ave & Diversey Pkwy - Charging'
				'Base - 2132 W Hubbard Warehouse')



---update station_name 351 to "Mulligan Ave & Wellington Ave".
UPDATE cyclistic_data
SET start_station_name = 'Mulligan Ave & Wellington Ave'
WHERE start_station_id ='351' AND start_station_name = '351'

UPDATE cyclistic_data
SET end_station_name = 'Mulligan Ave & Wellington Ave'
WHERE end_station_id ='351' AND end_station_name = '351'
---
```
</details>

## Analyze

In this phase, we will do descriptive statistics, perform calculations, and analyze data to find patterns, relationships, and trends. 

### Descriptive Statistics

We will first look at the modes of our rider types, bike types, stations, and temporal columns.

<details>
  <summary>Show SQL query</summary>
	
```sql
with part_of_day as (
	select ride_id, (case when date_part('Hour',started_at) in (0,1,2,3,4,5,6,7,8,9,10,11) then 'morning'
				when date_part('Hour',started_at) in (12,13,14,15,16,17) then 'afternoon'
				when date_part('Hour',started_at) in (18,19,20,21,22,23) then 'evening'
			end) as pod
	from cyclistic_data),

 season as (
	select ride_id, (case when date_part('Month',started_at) in (11, 12, 1) then 'winter'
			when date_part('Month',started_at) in (2, 3, 4) then 'spring'
			when date_part('Month',started_at) in (5, 6, 7) then 'summer'
			when date_part('Month',started_at) in (8, 9, 10) then 'autumn'
		end) as ss
	from cyclistic_data),
	
 day_of_week as (
 	select ride_id, to_char(started_at, 'day') as dow
	from cyclistic_data),
 
 ride_month as (
 	select ride_id, date_part('Month', started_at) as month
 	from cyclistic_data),
	
 ride_hour as (
 	select ride_id, date_part('Hour', started_at) as hour
 	from cyclistic_data)

select mode() within group (order by rideable_type) as mode_rideable_type,
	mode() within group (order by member_casual) as mode_member_casual,
	mode() within group (order by start_station_name) as mode_start_station_name,
	mode() within group (order by end_station_name) as mode_end_station_name,
	mode() within group (order by part_of_day.pod) as mode_pod,
	mode() within group (order by season.ss) as mode_ss,
	mode() within group (order by day_of_week.dow) as mode_dow,
	mode() within group (order by ride_month.month) as mode_month,
	mode() within group (order by ride_hour.hour) as mode_hour
from cyclistic_data
left join part_of_day
on cyclistic_data.ride_id = part_of_day.ride_id
left join season
on cyclistic_data.ride_id = season.ride_id
left join day_of_week
on cyclistic_data.ride_id = day_of_week.ride_id
left join ride_month
on cyclistic_data.ride_id = ride_month.ride_id
left join ride_hour
on cyclistic_data.ride_id = ride_hour.ride_id
```
</details>

![Screenshot (228)](https://github.com/viet-nguyend/cyclist_data/assets/142729978/b5a1ce3b-dc3a-4407-b912-25784bee8a63)

----need to fix this imediately

Based on the image above, we can infer the following:

• Members did more bike rides than casual members

• The most preferred bike type is an electric bike

• Streeter Dr and Grand Ave is the favorite start and end station

• The peak season is Summer season

• The peak month is July

• The peak day is Saturday

• The peak part of day is Afternoon and the peak hour is 5 PM

<details>
  <summary>Show SQL query</summary>

```sql
with ride_length as (
select ((DATE_PART('Day', ended_at - started_at)) * 24 * 60) + 
	((DATE_PART('Hour', ended_at - started_at)) * 60) + 
	(DATE_PART('Minute', ended_at - started_at)) as ride_length_min
from cyclistic_data)

select count(ride_length_min),
		avg(ride_length_min) as avg_ride_length,
		stddev_samp(ride_length_min) as std,
		max(ride_length_min) as max,
		min(ride_length_min) as min,
		(select distinct percentile_cont(0.25) within group (order by ride_length_min) as percentile_25 from ride_length),
  		(select distinct percentile_cont(0.50) within group (order by ride_length_min) as percentile_50 from ride_length),
  		(select distinct percentile_cont(0.75) within group (order by ride_length_min) as percentile_75 from ride_length),
  		(select distinct percentile_cont(0.95) within group (order by ride_length_min) as percentile_95 from ride_length)
from ride_length
```

</details>

the image is wrong, have not delete where started_at > ended_at, this is only for reference

![Screenshot (229)](https://github.com/viet-nguyend/cyclist_data/assets/142729978/460a12ab-05d0-4e53-8b1d-964ed87e61bb)

Also fix this

Based on the image above, we can infer that:

• The average ride duration is 16.21 minutes, which says that most riders use the service for short trips.

• The shortest ride duration is 1 minute and the longest ride duration is 1439.93 which is almost 24 hours.

• Based on the percentile data, most of the rides in this annual dataset fall below 20 minutes, which further supports the first statement.

### Rides distribution

```sql
with ride_length as (
select ride_id, member_casual, ((DATE_PART('Day', ended_at - started_at)) * 24 * 60) + 
	((DATE_PART('Hour', ended_at - started_at)) * 60) + 
	(DATE_PART('Minute', ended_at - started_at)) as ride_length_min
from cyclistic_data)

select member_casual, count(ride_id), avg(ride_length_min)
from ride_length
group by member_casual
```

analyze the result to get insight

rides distribution by types and member_casual

```sql
with ride_length as (
select ride_id, member_casual, rideable_type, ((DATE_PART('Day', ended_at - started_at)) * 24 * 60) + 
	((DATE_PART('Hour', ended_at - started_at)) * 60) + 
	(DATE_PART('Minute', ended_at - started_at)) as ride_length_min
from cyclistic_data)

select member_casual, rideable_type, count(ride_id), avg(ride_length_min)
from ride_length
group by member_casual, rideable_type
```

![Screenshot (231)](https://github.com/viet-nguyend/cyclist_data/assets/142729978/4706c917-53b1-4127-885c-04ac0f734351)

also analyze to get insight

rides by hours and days

```sql
with ride_distribution as (
 	select ride_id, date_part('Hour', started_at) as hour, to_char(started_at, 'day') as dow
 	from cyclistic_data)

select count(cyclistic_data.ride_id),
		member_casual,
		ride_distribution.dow,
		ride_distribution.hour
from cyclistic_data
left join ride_distribution
on cyclistic_data.ride_id = ride_distribution.ride_id
where member_casual = 'member'
group by member_casual, ride_distribution.dow, ride_distribution.hour
order by count(cyclistic_data.ride_id) desc

with ride_distribution as (
 	select ride_id, date_part('Hour', started_at) as hour, to_char(started_at, 'day') as dow
 	from cyclistic_data)

select count(cyclistic_data.ride_id),
		member_casual,
		ride_distribution.dow,
		ride_distribution.hour
from cyclistic_data
left join ride_distribution
on cyclistic_data.ride_id = ride_distribution.ride_id
where member_casual = 'casual'
group by member_casual, ride_distribution.dow, ride_distribution.hour
order by count(cyclistic_data.ride_id) desc
```

![Screenshot (235)](https://github.com/viet-nguyend/cyclist_data/assets/142729978/21816539-405f-44e7-819b-298b04ef8688)


```sql
with ride_distribution as (select ride_id, to_char(started_at,'day') as day_of_week,
				(((DATE_PART('Day', ended_at - started_at)) * 24 * 60) + 
				((DATE_PART('Hour', ended_at - started_at)) * 60) +
				(DATE_PART('Minute', ended_at - started_at))) as ride_length_min
			from cyclistic_data)

select member_casual,
	ride_distribution.day_of_week,
	count(cyclistic_data.ride_id),
	avg(ride_distribution.ride_length_min) as avg_ride_length
from cyclistic_data
left join ride_distribution
on cyclistic_data.ride_id = ride_distribution.ride_id
where member_casual = 'member'
group by member_casual, ride_distribution.day_of_week
order by count(cyclistic_data.ride_id) desc

with ride_distribution as (select ride_id, to_char(started_at,'day') as day_of_week,
				(((DATE_PART('Day', ended_at - started_at)) * 24 * 60) + 
				((DATE_PART('Hour', ended_at - started_at)) * 60) +
				(DATE_PART('Minute', ended_at - started_at))) as ride_length_min
			from cyclistic_data)

select member_casual,
	ride_distribution.day_of_week,
	count(cyclistic_data.ride_id),
	avg(ride_distribution.ride_length_min) as avg_ride_length
from cyclistic_data
left join ride_distribution
on cyclistic_data.ride_id = ride_distribution.ride_id
where member_casual = 'casual'
group by member_casual, ride_distribution.day_of_week
order by count(cyclistic_data.ride_id) desc

```

![Screenshot (238)](https://github.com/viet-nguyend/cyclist_data/assets/142729978/5aed97e6-3c0f-400c-84c7-1980f896b44d)

Ride by month

```sql
with ride_distribution as (select ride_id,
				(((DATE_PART('Day', ended_at - started_at)) * 24 * 60) + 
				((DATE_PART('Hour', ended_at - started_at)) * 60) +
				(DATE_PART('Minute', ended_at - started_at))) as ride_length_min
			from cyclistic_data)

select date_part('month', started_at) as month,
		member_casual,
		count(cyclistic_data.ride_id),
		avg(ride_length_min) as avg_ride_length
from cyclistic_data
left join ride_distribution
on cyclistic_data.ride_id = ride_distribution.ride_id
where member_casual = 'member'
group by member_casual, date_part('month', started_at)

with ride_distribution as (select ride_id,
				(((DATE_PART('Day', ended_at - started_at)) * 24 * 60) + 
				((DATE_PART('Hour', ended_at - started_at)) * 60) +
				(DATE_PART('Minute', ended_at - started_at))) as ride_length_min
			from cyclistic_data)

select date_part('month', started_at) as month,
		member_casual,
		count(cyclistic_data.ride_id),
		avg(ride_length_min) as avg_ride_length
from cyclistic_data
left join ride_distribution
on cyclistic_data.ride_id = ride_distribution.ride_id
where member_casual = 'casual'
group by member_casual, date_part('month', started_at)
```

![Screenshot (241)](https://github.com/viet-nguyend/cyclist_data/assets/142729978/717a8626-8da3-44cf-a7f7-ac6934d2790d)

- Top bike station

member

```sql
select member_casual,
		start_station_name,
		count(ride_id)
from cyclistic_data
where member_casual = 'member'
group by member_casual, start_station_name
order by count(ride_id) desc

select member_casual,
		end_station_name,
		count(ride_id)
from cyclistic_data
where member_casual = 'member'
group by member_casual, end_station_name
order by count(ride_id) desc
```

![Screenshot (244)](https://github.com/viet-nguyend/cyclist_data/assets/142729978/537dff7f-4550-466b-9d45-122056699bbe)

casual ride

```sql
select member_casual,
		start_station_name,
		count(ride_id)
from cyclistic_data
where member_casual = 'casual'
group by member_casual, start_station_name
order by count(ride_id) desc

select member_casual,
		end_station_name,
		count(ride_id)
from cyclistic_data
where member_casual = 'casual'
group by member_casual, end_station_name
order by count(ride_id) desc
```

![Screenshot (247)](https://github.com/viet-nguyend/cyclist_data/assets/142729978/4fa7b38e-9df1-489e-901a-f2adfac7717b)

