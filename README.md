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

<details>
  <summary>Show SQL query</summary>

```sql
---using CTE to create a temporary table contains value of ride_length
with ride_length as (select started_at, ended_at,
			((DATE_PART('Day', ended_at - started_at)) * 24 * 60 * 60) + 
			((DATE_PART('Hour', ended_at - started_at)) * 60 * 60) + 
			(DATE_PART('Minute', ended_at - started_at)) * 60 + 
			(DATE_PART('Second', ended_at - started_at)) as ride_duration
		from cyclistic_data)
 
select *
from ride_length
where started_at > ended_at

select started_at, ended_at, ride_duration
from ride_length
where  ride_length < 0 or ride_length > 86400

select started_at, ended_at, ride_duration
from ride_length
where  ride_duration < 60
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
with ride_mode as (
	select ride_id, (case when date_part('Hour',started_at) in (0,1,2,3,4,5,6,7,8,9,10,11) then 'morning'
				when date_part('Hour',started_at) in (12,13,14,15,16,17) then 'afternoon'
				when date_part('Hour',started_at) in (18,19,20,21,22,23) then 'evening'
				end) as pod,
			(case when date_part('Month',started_at) in (11, 12, 1) then 'winter'
				when date_part('Month',started_at) in (2, 3, 4) then 'spring'
				when date_part('Month',started_at) in (5, 6, 7) then 'summer'
				when date_part('Month',started_at) in (8, 9, 10) then 'autumn'
				end) as ss,
			to_char(started_at, 'day') as dow,
			date_part('Month', started_at) as month,
			date_part('Hour', started_at) as hour
	from cyclistic_data)

select count(cyclistic_data.ride_id) as num_of_ride,
	mode() within group (order by rideable_type) as mode_rideable_type,
	mode() within group (order by member_casual) as mode_member_casual,
	mode() within group (order by start_station_name) as mode_start_station_name,
	mode() within group (order by end_station_name) as mode_end_station_name,
	mode() within group (order by ride_mode.pod) as mode_pod,
	mode() within group (order by ride_mode.ss) as mode_ss,
	mode() within group (order by ride_mode.dow) as mode_dow,
	mode() within group (order by ride_mode.month) as mode_month,
	mode() within group (order by ride_mode.hour) as mode_hour
from cyclistic_data
left join ride_mode
on cyclistic_data.ride_id = ride_mode.ride_id
```
</details>

![Screenshot (280)](https://github.com/viet-nguyend/cyclistic_data_project/assets/142729978/ea36c2a7-0320-42e1-8f6c-633301bae1ed)

Based on the image above, we can infer the following:

- Members did more bike rides than casual members
- The most preferred bike type is an classic bike
- Streeter Dr and Grand Ave is the favorite start and end station
- The peak season is Autumn season
- The peak month is July
- The peak day is Saturday
- The peak part of day is Afternoon and the peak hour is 5 PM

<details>
  <summary>Show SQL query</summary>

```sql
with ride_length as (
select ride_id,
	((DATE_PART('Day', ended_at - started_at)) * 24 * 60) + 
	((DATE_PART('Hour', ended_at - started_at)) * 60) + 
	(DATE_PART('Minute', ended_at - started_at)) as ride_length_min
from cyclistic_data)

select count(ride_id) as num_of_ride,
		avg(ride_length_min) as avg_ride_length,
		stddev_samp(ride_length_min) as std,
		max(ride_length_min) as max,
		min(ride_length_min) as min,
		(select distinct percentile_cont(0.25) within group (order by ride_length_min) as percentile_25 from ride_length),
  		(select distinct percentile_cont(0.50) within group (order by ride_length_min) as percentile_50 from ride_length),
  		(select distinct percentile_cont(0.75) within group (order by ride_length_min) as percentile_75 from ride_length)
from ride_length
```

</details>

![Screenshot (284)](https://github.com/viet-nguyend/cyclistic_data_project/assets/142729978/83e9c3f2-e9fc-48a3-80e4-f889eeefcd3c)

Based on the image above, we can infer that:

- The average ride duration is 18.97 minutes, which says that most riders use the service for short trips.
- The shortest ride duration is 1 minute and the longest ride duration is 1438 which is almost 24 hours.
- Based on the percentile data, most of the rides in this annual dataset fall below 20 minutes, which further supports the first statement.

### Rides distribution

<details>
  <summary>Show SQL query</summary>

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
</details>

![Screenshot (256)](https://github.com/viet-nguyend/cyclistic_data_project/assets/142729978/89fe9ec2-a6ad-4e1d-9f65-816ecd72817c)

The table indicates that members have a higher number of rides compared to casual riders, which can be attributed to the additional benefits and improved services available to members. Interestingly, the average ride duration for casual riders surpasses that of members.

- Rides distribution by types and member_casual

<details>
  <summary>Show SQL query</summary>

```sql
with ride_distribution as (
select ride_id, member_casual, rideable_type, 
	((DATE_PART('Day', ended_at - started_at)) * 24 * 60) + 
	((DATE_PART('Hour', ended_at - started_at)) * 60) + 
	(DATE_PART('Minute', ended_at - started_at)) as ride_length_min
from cyclistic_data)

select count(ride_id) as num_of_ride, member_casual, rideable_type, avg(ride_length_min)
from ride_distribution
group by member_casual, rideable_type
order by count(ride_id) desc
```
</details>

![Screenshot (257)](https://github.com/viet-nguyend/cyclistic_data_project/assets/142729978/4f51f1ba-85bf-4d37-9fb3-20c2fd11ff9e)

Based on the table, we can infer that members exclusively utilized classic bikes and electric bikes. Furthermore, a consistent pattern emerges where members completed more rides than casual riders, while the average ride duration for casual riders consistently exceeded that of members. Notably, docked bikes exhibited the highest average usage duration. To gain deeper insights into the behavior and preferences of members and casual users, further analysis will be conducted.

- Rides distribution by hours and days

<details>
  <summary>Show SQL query</summary>

```sql
select member_casual,
	to_char(started_at,'day') as day_of_week,
	date_part('Hour', started_at) as hour,
	count(ride_id) as num_of_ride
from cyclistic_data
where member_casual = 'member'
group by member_casual, day_of_week, hour
order by count(ride_id) desc


select member_casual,
	to_char(started_at,'day') as day_of_week,
	date_part('Hour', started_at) as hour,
	count(ride_id) as num_of_ride
from cyclistic_data
where member_casual = 'casual'
group by member_casual, day_of_week, hour
order by count(ride_id) desc
```
</details>

![Screenshot (261)](https://github.com/viet-nguyend/cyclistic_data_project/assets/142729978/fff5fcae-8dcb-49bb-9660-f3ba416c234d)

<details>
  <summary>Show SQL query</summary>

```sql
with ride_distribution as (select ride_id, member_casual, to_char(started_at,'day') as day_of_week,
				(((DATE_PART('Day', ended_at - started_at)) * 24 * 60) + 
				((DATE_PART('Hour', ended_at - started_at)) * 60) +
				(DATE_PART('Minute', ended_at - started_at))) as ride_length_min
			from cyclistic_data)

select member_casual,
	day_of_week,
	count(ride_id) as num_of_ride,
	avg(ride_length_min) as avg_ride_length
from ride_distribution
where member_casual = 'member'
group by member_casual, day_of_week
order by count(ride_id) desc


with ride_distribution as (select ride_id, member_casual, to_char(started_at,'day') as day_of_week,
				(((DATE_PART('Day', ended_at - started_at)) * 24 * 60) + 
				((DATE_PART('Hour', ended_at - started_at)) * 60) +
				(DATE_PART('Minute', ended_at - started_at))) as ride_length_min
			from cyclistic_data)

select member_casual,
	day_of_week,
	count(ride_id) as num_of_ride,
	avg(ride_length_min) as avg_ride_length
from ride_distribution
where member_casual = 'casual'
group by member_casual, day_of_week
order by count(ride_id) desc
```
</details>

![Screenshot (265)](https://github.com/viet-nguyend/cyclistic_data_project/assets/142729978/1334f702-01f7-4a9e-bcd9-60eb23d4f78b)

Member: According to the table, most rides are on weekday from Monday to Friday, usually in the afternoon from 4 pm and in the morning from 7 pm, which are rush hours when people start and end their day. The number of rides starts increasing from Monday and reaches its peak on Wednesday, and then consitently decrease from Thursday to Sunday. Regarding the average time of bike usage of members, the average duration members using bikes shows relatively similar from Monday to Thursday, approximately 11 minutes, whereas on the weekend the average time members spend cycling increase gradually from 12 minutes on Friday to 14 minutes on Sunday. This suggests that members mainly use bicycles as a mean of transporation for work and school, because most rides are usually at rush hours on weekday. On the contrary to the number of rides and the average duration on weekday, the average time for using bikes on the weekend shows a rise but the number or rides decrease, which indicates that the purpose of bike usage by member on the weekend are for recreational activities.

Casual: In contrast to members, the number of rides by casual riders is considerably lower from Monday to Thursday, mostly below 300,000 rides. However, during the weekend, it experiences a significant increase, surpassing 450,000 rides. Furthermore, most rides typically commence in the afternoon, between 12 pm and 5 pm.Regarding the average cycling duration of casual users, it begins to rise noticeably on Thursday and continues to increase, reaching its peak at 31 minutes on Sunday, which is also the highest duration for bike usage among casual riders. With both the higher number of rides and longer average ride times during the weekend, it can be inferred that casual riders use bikes for relaxation and recreational activities during this time.

In summary, member and casual riders tend to ride in the afternoon and evening. While most of the rides done by member is on weekday, the figure for casual riders shows the opposite with most of the rides done on the weekend. 

- Rides distributrion by month

<details>
  <summary>Show SQL query</summary>
	
```sql
with ride_distribution as (select ride_id, member_casual, date_part('month', started_at) as month,
				(((DATE_PART('Day', ended_at - started_at)) * 24 * 60) + 
				((DATE_PART('Hour', ended_at - started_at)) * 60) +
				(DATE_PART('Minute', ended_at - started_at))) as ride_length_min
			from cyclistic_data)

select month,
		member_casual,
		count(ride_id) as num_of_ride,
		avg(ride_length_min) as avg_ride_length
from ride_distribution
where member_casual = 'member'
group by member_casual, month
order by month


with ride_distribution as (select ride_id, member_casual, date_part('month', started_at) as month,
				(((DATE_PART('Day', ended_at - started_at)) * 24 * 60) + 
				((DATE_PART('Hour', ended_at - started_at)) * 60) +
				(DATE_PART('Minute', ended_at - started_at))) as ride_length_min
			from cyclistic_data)

select month,
		member_casual,
		count(ride_id) as num_of_ride,
		avg(ride_length_min) as avg_ride_length
from ride_distribution
where member_casual = 'casual'
group by member_casual, month
order by month
```
</details>

![Screenshot (268)](https://github.com/viet-nguyend/cyclistic_data_project/assets/142729978/2b6972bb-265d-4580-aab4-3d45c5a77b3f)

Member: From the table, it's evident that the number of rides by members begins to increase in February, peaks in August, and then gradually decreases until January. The average usage duration appears to follow a similar pattern to the number of rides. This suggests that members prefer to ride during the summer months, enjoying the pleasant and comfortable weather, while they tend to avoid riding in the winter or during cold temperature periods

Casual: Like members, both fall and summer stand out as the two seasons with the highest number of rides. However, the average duration of each month shows significant fluctuations with a wider range than that of members

In general, both member and casual riders prefer to ride in the summer and fall.

- Top bike station

member

<details>
  <summary>Show SQL query</summary>

```sql
select member_casual,
		start_station_name,
		count(ride_id) as num_of_ride
from cyclistic_data
where member_casual = 'member'
group by member_casual, start_station_name
order by count(ride_id) desc

select member_casual,
		end_station_name,
		count(ride_id) as num_of_ride
from cyclistic_data
where member_casual = 'member'
group by member_casual, end_station_name
order by count(ride_id) desc
```
</details>

![Screenshot (275)](https://github.com/viet-nguyend/cyclistic_data_project/assets/142729978/8d6b70ad-3204-4e84-9454-8129837a687d)

According to the table, start and end station Kingsbury St & Kinzie St has the most rides, and almost all of the ride has the same start and end station, which explains that most of the trip that members took are round trips. 

casual ride

<details>
  <summary>Show SQL query</summary>

```sql
select member_casual,
		start_station_name,
		count(ride_id) as num_of_ride
from cyclistic_data
where member_casual = 'casual'
group by member_casual, start_station_name
order by count(ride_id) desc

select member_casual,
		end_station_name,
		count(ride_id) as num_of_ride
from cyclistic_data
where member_casual = 'casual'
group by member_casual, end_station_name
order by count(ride_id) desc
```
</details>

![Screenshot (278)](https://github.com/viet-nguyend/cyclistic_data_project/assets/142729978/984e1981-66a6-453d-89dd-eaaa1f28be7d)

For casual riders, most rides started and ended at the same station, Streeter Dr & Grand Ave. This is similar to member, which mean that most of the rides done by casual riders are round trips.

## Share

In this phase, we will create visualizations and share our key findings.

[Dashboard](https://public.tableau.com/views/Data_16953905192160/Dashboard1?:language=en-US&:display_count=n&:origin=viz_share_link)

### Key insight

1. The number of rides done by members accounts for the majority of the total rides at 56.20%, compared to casual users, who account for 43.80%.
2. Members mostly use the service as a means of transportation to work or school, usually riding on weekdays at rush hours between 7 am to 8 am and 4 pm to 6 pm.
3. Casual users predominantly ride in the afternoon between 2 pm and 6 pm every day of the week, with the highest frequency occurring during the weekend. They primarily use the service for recreational activities and relaxation.
4. Both members and casual users prefer to ride during the warm season, with July being the preferred month for members and August being the preferred month for casual users.
5. While the number of rides by members is consistently higher than that of casual users, the average usage time for casual users is twice as long as that of members.
6. Both members and casual users spend more time using the service on the weekend compared to weekdays.
7. Docked bike is the least preferred bike type by both members and casual riders, while classic bike is the most preferred.
8. Members' top start stations and end stations are the same, and this is also true for casual riders.
   
## Act

In this phase, I will use the insight to recommend some marketing strategy to convert casual riders to members, and retain existing members

### Recommendations

1. Offer casual riders a limited-time membership trial at a reduced cost or for free. This allows them to experience the benefits of membership without a long-term commitment.
2. Create seasonal membership packages that align with riders' preferences. For instance, offer discounted summer memberships during peak riding months.
3. Implement dynamic pricing based on demand. Charge higher rates for peak weekend hours and lower rates for less popular times to incentivize membership
4. Create seasonal promotions targeting casual riders during peak riding seasons. Highlight the benefits of membership in these promotions.
5. Place marketing materials near popular bike stations, such as posters or QR codes that lead to membership sign-up pages.
6. Provide ongoing incentives for members who renew their memberships, such as lower renewal fees, extended membership durations, or exclusive rewards.
7. Offer exclusive services or features to members, such as priority access to bikes, faster unlocking, or bike reservations during peak times.
8. Implement a loyalty program for existing members, rewarding them for their continued membership. Offer points, discounts, or free rides for referring new members or for consistent usage.
