create schema Assignment;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- changing the date format for every table
alter table `bajaj`add format_date date;
update `bajaj` set format_date = str_to_date(date, '%d-%M-%Y');

alter table `tcs`add format_date date;
update `tcs` set format_date = str_to_date(date, '%d-%M-%Y');

alter table `infosys`add format_date date;
update `infosys` set format_date = str_to_date(date, '%d-%M-%Y');

alter table `hero`add format_date date;
update `hero` set format_date = str_to_date(date, '%d-%M-%Y');

alter table `eicher`add format_date date;
update `eicher` set format_date = str_to_date(date, '%d-%M-%Y');

alter table `tvs`add format_date date;
update `tvs` set format_date = str_to_date(date, '%d-%M-%Y');

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TASK 1: Create a new tables named 'bajaj1, infosys1 etc' containing the date, close price, 20 Day MA and 50 Day MA. (This has to be done for all 6 stocks)

-- Creating a new table named 'bajaj1' containing the date, close price, 20 Day MA and 50 Day MA.
drop table if exists `bajaj1`;
CREATE TABLE bajaj1 AS
SELECT format_date as `Date`, `Close Price` as ClosePrice, 
AVG(`Close Price`) OVER ( order by `Date` rows between 19 preceding and current row) AS `20_Day_MA` ,
AVG(`Close Price`) OVER ( order by `Date` rows between 49 preceding and current row) AS `50_Day_MA`
FROM  `bajaj`;

-- Creating a new table named 'eicher1' containing the date, close price, 20 Day MA and 50 Day MA.
drop table if exists `eicher1`;
CREATE TABLE eicher1 AS
SELECT format_date `Date`, `Close Price` as ClosePrice, 
AVG(`Close Price`) OVER ( order by `Date` rows between 19 preceding and current row) AS `20_Day_MA` ,
AVG(`Close Price`) OVER ( order by `Date` rows between 49 preceding and current row) AS `50_Day_MA`
FROM  `eicher`;

-- Creating a new table named 'infosys1' containing the date, close price, 20 Day MA and 50 Day MA.
drop table if exists `infosys1`;
CREATE TABLE infosys1 AS
SELECT format_date `Date`, `Close Price` as ClosePrice, 
AVG(`Close Price`) OVER ( order by `Date` rows between 19 preceding and current row) AS `20_Day_MA` ,
AVG(`Close Price`) OVER ( order by `Date` rows between 49 preceding and current row) AS `50_Day_MA`
FROM  `infosys`;

-- Creating a new table named 'hero1' containing the date, close price, 20 Day MA and 50 Day MA.
drop table if exists `hero1`;
CREATE TABLE hero1 AS
SELECT format_date `Date`, `Close Price` as ClosePrice, 
AVG(`Close Price`) OVER ( order by `Date` rows between 19 preceding and current row) AS `20_Day_MA` ,
AVG(`Close Price`) OVER ( order by `Date` rows between 49 preceding and current row) AS `50_Day_MA`
FROM  `hero`;

-- Creating a new table named 'tcs1' containing the date, close price, 20 Day MA and 50 Day MA.
drop table if exists `tcs1`;
CREATE TABLE tcs1 AS
SELECT format_date `Date`, `Close Price` as ClosePrice, 
AVG(`Close Price`) OVER ( order by `Date` rows between 19 preceding and current row) AS `20_Day_MA` ,
AVG(`Close Price`) OVER ( order by `Date` rows between 49 preceding and current row) AS `50_Day_MA`
FROM  `tcs`;

-- Creating a new table named 'tvs1' containing the date, close price, 20 Day MA and 50 Day MA.
drop table if exists `tvs1`;
CREATE TABLE tvs1 AS
SELECT format_date as `Date`, `Close Price` as ClosePrice, 
AVG(`Close Price`) OVER ( order by `Date` rows between 19 preceding and current row) AS `20_Day_MA` ,
AVG(`Close Price`) OVER ( order by `Date` rows between 49 preceding and current row) AS `50_Day_MA`
FROM  `tvs`;

-- Making first 19 rows NULL as moving average can't be calculated
 update bajaj1 set `20_Day_MA` = NULL limit 19;
 update eicher1 set `20_Day_MA` = NULL limit 19;
 update hero1 set `20_Day_MA` = NULL limit 19;
 update infosys1 set `20_Day_MA` = NULL limit 19;
 update tcs1 set `20_Day_MA` = NULL limit 19;
 update tvs1 set `20_Day_MA` = NULL limit 19;

-- Making first 49 rows NULL as moving average can't be calculated
 update bajaj1 set `50_Day_MA` = NULL limit 49;
 update eicher1 set `50_Day_MA` = NULL limit 49;
 update hero1 set `50_Day_MA` = NULL limit 49;
 update infosys1 set `50_Day_MA` = NULL limit 49;
 update tcs1 set `50_Day_MA` = NULL limit 49;
 update tvs1 set `50_Day_MA` = NULL limit 49;
 
-- checking the table contents
select * from bajaj1;
select * from eicher1;
select * from tvs1;
select * from tcs1;
select * from hero1;
select * from infosys1;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- TASK 2 : Creating a master table containing the date and close price of all the six stocks
drop table if exists `master_stock`;
create table master_stock
select baj.format_date as Date , baj.`Close Price` as Bajaj , tcs.`Close Price` as TCS , 
tvs.`Close Price` as TVS , inf.`Close Price` as Infosys , eic.`Close Price` as Eicher , her.`Close Price` as Hero
from `bajaj` baj
inner join `tcs` tcs on tcs.format_date = baj.format_date
inner join `tvs` tvs on tvs.format_date = baj.format_date
inner join `infosys` inf on inf.format_date = baj.format_date
inner join `eicher` eic on eic.format_date = baj.format_date
inner join `hero` her on her.format_date = baj.format_date ;
select * from master_stock;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- TASK 3 : Using the tables created in Part(1) to generate buy and sell signal.
-- Steps involved are :-
-- 1)When the 20_Day_MA is greater than the 50_Day_MA, it is a signal to BUY, as it indicates that the trend goes high.
-- 2)When the 20_Day_MA is less than the 50_Day_MA, it is a signal to BUY, as it indicates that the trend is going low.
-- 3)When the signal is neither buy nor sell, it is classified as hold.

-- Creating table bajaj2 
drop table if exists `bajaj2`;
create table bajaj2
select `Date`,`ClosePrice`,
case 
when `50_Day_MA` is NULL then 'NA'
when `20_Day_MA`>`50_Day_MA` and ((lag(`20_Day_MA`,1) over(order by `Date`))<(lag(`50_Day_MA`,1) over(order by `Date`))) then 'BUY'
when `20_Day_MA`<`50_Day_MA` and ((lag(`20_Day_MA`,1) over(order by `Date`))>(lag(`50_Day_MA`,1) over(order by `Date`))) then 'SELL'
else 'HOLD' 
end as `Signal`
from bajaj1 ;
select * from bajaj2;

-- Creating table eicher2 
drop table if exists `eicher2`;
create table eicher2
select `Date`,`ClosePrice`,
case 
when `50_Day_MA` is NULL then 'NA'
when `20_Day_MA`>`50_Day_MA` and ((lag(`20_Day_MA`,1) over(order by `Date`))<(lag(`50_Day_MA`,1) over(order by `Date`))) then 'BUY'
when `20_Day_MA`<`50_Day_MA` and ((lag(`20_Day_MA`,1) over(order by `Date`))>(lag(`50_Day_MA`,1) over(order by `Date`))) then 'SELL'
else 'HOLD' 
end as `Signal`
from eicher1 ;
select * from eicher2;

-- Creating table Hero2
drop table if exists `Hero2`;
create table Hero2
select `Date`,`ClosePrice`,
case 
when `50_Day_MA` is NULL then 'NA'
when `20_Day_MA`>`50_Day_MA` and ((lag(`20_Day_MA`,1) over(order by `Date`))<(lag(`50_Day_MA`,1) over(order by `Date`))) then 'BUY'
when `20_Day_MA`<`50_Day_MA` and ((lag(`20_Day_MA`,1) over(order by `Date`))>(lag(`50_Day_MA`,1) over(order by `Date`))) then 'SELL'
else 'HOLD' 
end as `Signal`
from Hero1 ;
select * from Hero2;

-- Creating table Infosys2
drop table if exists `Infosys2`;
create table Infosys2
select `Date`,`ClosePrice`,
case 
when `50_Day_MA` is NULL then 'NA'
when `20_Day_MA`>`50_Day_MA` and ((lag(`20_Day_MA`,1) over(order by `Date`))<(lag(`50_Day_MA`,1) over(order by `Date`))) then 'BUY'
when `20_Day_MA`<`50_Day_MA` and ((lag(`20_Day_MA`,1) over(order by `Date`))>(lag(`50_Day_MA`,1) over(order by `Date`))) then 'SELL'
else 'HOLD' 
end as `Signal`
from Infosys1 ;
select * from Infosys2;

-- Creating table TCS2
drop table if exists `TCS2`;
create table TCS2
select `Date`,`ClosePrice`,
case 
when `50_Day_MA` is NULL then 'NA'
when `20_Day_MA`>`50_Day_MA` and ((lag(`20_Day_MA`,1) over(order by `Date`))<(lag(`50_Day_MA`,1) over(order by `Date`))) then 'BUY'
when `20_Day_MA`<`50_Day_MA` and ((lag(`20_Day_MA`,1) over(order by `Date`))>(lag(`50_Day_MA`,1) over(order by `Date`))) then 'SELL'
else 'HOLD' 
end as `Signal`
from TCS1 ;
select * from TCS2;

-- Creating table TVS2
drop table if exists `TVS2`;
create table TVS2
select `Date`,`ClosePrice`,
case 
when `50_Day_MA` is NULL then 'NA'
when `20_Day_MA`>`50_Day_MA` and ((lag(`20_Day_MA`,1) over(order by `Date`))<(lag(`50_Day_MA`,1) over(order by `Date`))) then 'BUY'
when `20_Day_MA`<`50_Day_MA` and ((lag(`20_Day_MA`,1) over(order by `Date`))>(lag(`50_Day_MA`,1) over(order by `Date`))) then 'SELL'
else 'HOLD' 
end as `Signal`
from TVS1;
select * from TVS2;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- TASK 4 :  Create a User defined function, that takes the date as input and returns the signal for that particular day (Buy/Sell/Hold) for the Bajaj stock

delimiter $$
create function get_signal( Signal_date char(20))
returns char(20)
deterministic 
begin
return (select `Signal` from bajaj2 where `Date` = Signal_date);
END $$
delimiter ;

SELECT generate_signal('2016-06-30') AS signal_generated; 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- TASK 5 : Analysis

select * from bajaj2;
select count(*) from bajaj2 where `Signal`='SELL';
select count(*) from bajaj2 where `Signal`='buy';
select count(*) from bajaj2 where `Signal`='hold';

-- getting the trend
select (select `Close price` from bajaj  order by `Date` desc limit 1) - (select `Close price` from bajaj order by `Date`  limit 1) as 'Trend';
select (select `Close price` from tcs  order by `Date` desc limit 1) - (select `Close price` from tcs  order by `Date`  limit 1) as 'Trend';
select (select `Close price` from eicher  order by `Date` desc limit 1) - (select `Close price` from eicher order by `Date`  limit 1) as 'Trend';
select (select `Close price` from tvs  order by `Date` desc limit 1) - (select `Close price` from tvs  order by `Date`  limit 1) as 'Trend';
select (select `Close price` from hero  order by `Date` desc limit 1) - (select `Close price` from hero  order by `Date`  limit 1) as 'Trend';
select (select `Close price` from infosys  order by `Date` desc limit 1) - (select `Close price` from infosys  order by `Date`  limit 1) as 'Trend';
 















