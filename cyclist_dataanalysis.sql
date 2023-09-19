---Using data from May, 2021 to April, 2022
create table bike_one(
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

--- create a new table contains the data of twelve months
---using UNION
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
----result: 5757551 rows

---- Data exploration
--view table
select *
from cyclistic_data
----check for duplicates in ride_id column
select ride_id,
count(*)
from cyclist_data
group by ride_id
having count(*)>1
----result: 0 rows

---check for nulls
select *
from cyclist_data
where started_at is null or ended_at is null

select count(*)
from cyclist_data
where member_casual is null

select count(*)
from cyclist_data
where start_station_id is null or start_station_name is null


select count(*)
from cyclist_data
where end_station_id is null or end_station_name is null


select count(*)
from cyclist_data
where start_lat is null or start_lng is null

select count(*)
from cyclist_data
where end_lat is null or end_lng is null


select count(*)
from cyclist_data
where rideable_type is null


---check for inaccurate data (started_at > ended_at)
select cast(started_at as date) as start,
cast(ended_at as date) as end
from cyclist_data
where cast(ended_at as date) < cast(started_at as date)
--- 0 rows
select started_at,
ended_at 
from cyclist_data
where started_at > ended_at
--- 140 rows 

---check for longtitude and latitude range
SELECT
MIN(end_lng),MAX(end_lat),
MIN(end_lat),MAX(end_lat), 
MIN(start_lng),MAX(start_lng),
MIN(start_lat),MAX(start_lat)
FROM cyclistic_data;

--- DATA EXPLORING
---numbers of rideable_type
select rideable_type, count(*)
from cyclist_data
group by rideable_type


----numbers of casual members and anual members
select member_casual, count(*)
from cyclist_data
group by member_casual


---- numbers of round trips
select start_station_id,
end_station_id,
rideable_type,
member_casual,
 count (*) as num_round_trips
from cyclist_data
where start_station_id = end_station_id
group by start_station_id, end_station_id, rideable_type, member_casual
order by num_round_trips desc


--- data cleaning
delete
from cyclist_data
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

--===> DELETE 1141803, remain 4615748 rows

delete from cyclist_data
where started_at >= ended_at

----====> 652

////
select rideable_type, member_casual, count(*)
from cyclist_data
group by rideable_type, member_casual
order by count(*) desc

---delete station name with multiple ids
select start_station_name, start_station_id, count(*)
from cyclistic_data
where start_station_name = 'Lakefront Trail & Bryn Mawr Ave'
group by start_station_id, start_station_name

delete 
from cyclist_data
where start_station_name = 'Lakefront Trail & Bryn Mawr Ave'
--- DELETE 15281
delete
from cyclist_data
where start_station_name = 'Loomis St & 89th St'
--- DELETE 108
--- delete station id with multiple names
delete
from cyclist_data
where start_station_id = '351'
--- DELETE 85

---numbers of hours
select extract(hour from started_at) as hour, member_casual, count(*)
from cyclist_data
group by extract(hour from started_at), member_casual
order by extract(hour from started_at)

---what time with the most participants
select member_casual,
		--- time
		date_part('hour',started_at) as hour_start,
		--- daylight
		(case when date_part('hour',started_at) in (0,1,2,3,4,5,6,7,8,9,10,11) then 'morning'
			when date_part('hour',started_at) in (12,13,14,15,16,17) then 'afternoon'
			when date_part('hour',started_at) in (18,19,20,21,22,23) then 'evening'
		end) as daylight,
		--- day 
		date_part('day',started_at) as day_start,
		--- weekday
		
		--- month
		date_part('month',started_at) as month_start,
		--- season
		(case when date_part('month',started_at) in (12,1,2) then 'winter'
			when date_part('month',started_at) in (3,4,5) then 'spring'
			when date_part('month',started_at) in (6,7,8) then 'summer'
			when date_part('month',started_at) in (9,10,11) then 'autumn'
		end) as season, 
		count(*) as num_rides
from cyclist_data
group by date_part('hour',started_at),
		date_part('day',started_at),
		date_part('month',started_at),
		member_casual
order by date_part('hour',started_at),
		date_part('day',started_at),
		date_part('month',started_at)
--- day of week	
select extract(dow from started_at), to_char(started_at, 'Day'), member_casual,count(*)
from cyclist_data
group by  extract(dow from started_at),
to_char(started_at, 'Day'),
member_casual
order by extract(dow from started_at) desc

---datediff of rides
select started_at, ended_at,
 (DATE_PART('Day', ended_at - started_at)) * 24 + ---Date Difference in Days
 (DATE_PART('Hour', ended_at - started_at)) * 60 + ---Date Difference in Hours
 (DATE_PART('Minute', ended_at - started_at)) * 60 + ---Date Difference in Minute
 (DATE_PART('Second', ended_at - started_at)) ---Date Difference in Seconds
from cyclistic_data
where  
(DATE_PART('Day', ended_at - started_at)) * 24 + 
(DATE_PART('Hour', ended_at - started_at)) * 60 +
(DATE_PART('Minute', ended_at - started_at)) * 60 +
(DATE_PART('Second', ended_at - started_at)) < 0
---- 112 rows affected 




select
from cyclistic_data
where start_station_name = 'Bissell St & Armitage Ave - Charging'
	or start_station_name = 'DIVVY CASSETTE REPAIR MOBILE STATION'
	or start_station_name =	'Hastings WH 2'
	or start_station_name =	'Lincoln Ave & Roscoe St - Charging'
	or start_station_name =	'Pawel Bialowas - Test- PBSC charging station'
	or start_station_name =	'Throop/Hastings Mobile Station'
	or start_station_name =	'Wilton Ave & Diversey Pkwy - Charging'
	or start_station_name =	'Base - 2132 W Hubbard Warehouse'
---341 rows


from cyclistic_data
where end_station_name = 'Bissell St & Armitage Ave - Charging'
	or end_station_name = 'DIVVY CASSETTE REPAIR MOBILE STATION'
	or end_station_name =	'Hastings WH 2'
	or end_station_name =	'Lincoln Ave & Roscoe St - Charging'
	or end_station_name =	'Pawel Bialowas - Test- PBSC charging station'
	or end_station_name =	'Throop/Hastings Mobile Station'
	or end_station_name =	'Wilton Ave & Diversey Pkwy - Charging'
	or end_station_name =	'Base - 2132 W Hubbard Warehouse'
---353 rows
