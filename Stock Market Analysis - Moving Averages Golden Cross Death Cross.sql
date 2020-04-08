use assignment;

-- Disable safe update mode option
SET SQL_SAFE_UPDATES = 0;

-- Converting `date` column in all tables from text to date format
-- First updating the `date` column to correct format and then altering the datatype
update `bajaj auto` set `date` = str_to_date(`date`,'%d-%M-%Y');
alter table `bajaj auto` modify column `date` date;

update `eicher motors` set `date` = str_to_date(`date`,'%d-%M-%Y');
alter table `eicher motors` modify column `date` date;

update `hero motocorp` set `date` = str_to_date(`date`,'%d-%M-%Y');
alter table `hero motocorp` modify column `date` date;

update `infosys` set `date` = str_to_date(`date`,'%d-%M-%Y');
alter table `infosys` modify column `date` date;

update `tcs` set `date` = str_to_date(`date`,'%d-%M-%Y');
alter table `tcs` modify column `date` date;

update `tvs motors` set `date` = str_to_date(`date`,'%d-%M-%Y');
alter table `tvs motors` modify column `date` date;

-- ************ # 1 ************
-- Creating new table `bajaj1` containing date, close price, 20 Day MA, 50 Day 50
-- Deleting initial 49 rows where moving averages will not make sense as it is not possible
-- to calculate the required moving averages and check for cross overs.

-- Please note: We could have also easily marked first 19 rows in 20 Day MA as null 
-- and first 49 rows in 50 Day MA as null 
-- However, since these rows are not needed there is no point in keeping them for the calculation

-- Repeating these steps for all the 6 stocks
Create table `bajaj1` as (select `date`,`close price`,
avg(`close price`) over (order by `date` asc ROWS 19 preceding) `20 Day MA`,
avg(`close price`) over (order by `date` asc ROWS 49 preceding) `50 Day MA`
from `bajaj auto`);
delete from `bajaj1` where `date` < (select max(`date`) from (select `date` from `bajaj1` order by `date` limit 50) a);

Create table `eicher1` as (select `date`,`close price`,
avg(`close price`) over (order by `date` asc ROWS 19 preceding) `20 Day MA`,
avg(`close price`) over (order by `date` asc ROWS 49 preceding) `50 Day MA`
from `eicher motors`);
delete from `eicher1` where `date` < (select max(`date`) from (select `date` from `eicher1` order by `date` limit 50) a);

Create table `hero1` as (select `date`,`close price`,
avg(`close price`) over (order by `date` asc ROWS 19 preceding) `20 Day MA`,
avg(`close price`) over (order by `date` asc ROWS 49 preceding) `50 Day MA`
from `hero motocorp`);
delete from `hero1` where `date` < (select max(`date`) from (select `date` from `hero1` order by `date` limit 50) a);

Create table `infosys1` as (select `date`,`close price`,
avg(`close price`) over (order by `date` asc ROWS 19 preceding) `20 Day MA`,
avg(`close price`) over (order by `date` asc ROWS 49 preceding) `50 Day MA`
from `infosys`);
delete from `infosys1` where `date` < (select max(`date`) from (select `date` from `infosys1` order by `date` limit 50) a);

Create table `tcs1` as (select `date`,`close price`,
avg(`close price`) over (order by `date` asc ROWS 19 preceding) `20 Day MA`,
avg(`close price`) over (order by `date` asc ROWS 49 preceding) `50 Day MA`
from `tcs`);
delete from `tcs1` where `date` < (select max(`date`) from (select `date` from `tcs1` order by `date` limit 50) a);

Create table `tvs1` as (select `date`,`close price`,
avg(`close price`) over (order by `date` asc ROWS 19 preceding) `20 Day MA`,
avg(`close price`) over (order by `date` asc ROWS 49 preceding) `50 Day MA`
from `tvs motors`);
delete from `tvs1` where `date` < (select max(`date`) from (select `date` from `tvs1` order by `date` limit 50) a);

-- ************ # 2 ************
-- Creating Master table with date and the close price of all six stocks
create table master as 
(select bajaj1.`date` `Date`, bajaj1.`close price` Bajaj, eicher1.`close price` Eicher,
hero1.`close price` Hero, infosys1.`close price` Infosys, tcs1.`close price` TCS, tvs1.`close price` TVS
from bajaj1 left join eicher1 on bajaj1.`date` = eicher1.`date` left join hero1 on bajaj1.`date`=hero1.`date`
left join infosys1 on bajaj1.`date`=infosys1.`date` left join tcs1 on bajaj1.`date`=tcs1.`date`
left join tvs1 on bajaj1.`date`=tvs1.`date`);

-- ************ # 3 ************
-- Creating tables to mark Buy, Sell or Hold signals for a stock
-- Repeating this for all the 6 stocks
create table bajaj2 as 
(select a.`date`, a.`close price`,
case 
	when a.`20 Day MA` < a.`50 Day MA` and b.`20 Day MA` > b.`50 Day MA` then 'Sell'
	when a.`20 Day MA` > a.`50 Day MA` and b.`20 Day MA` < b.`50 Day MA` then 'Buy'
    else 'Hold'
end `Signal`
from (select *, row_number() over (order by `date` desc) RNo from bajaj1) a
inner join (select *, row_number() over (order by `date` desc) RNo from bajaj1) b
on a.Rno = b.Rno - 1
order by `date` desc);

create table eicher2 as 
(select a.`date`, a.`close price`,
case 
	when a.`20 Day MA` < a.`50 Day MA` and b.`20 Day MA` > b.`50 Day MA` then 'Sell'
	when a.`20 Day MA` > a.`50 Day MA` and b.`20 Day MA` < b.`50 Day MA` then 'Buy'
    else 'Hold'
end `Signal`
from (select *, row_number() over (order by `date` desc) RNo from eicher1) a
inner join (select *, row_number() over (order by `date` desc) RNo from eicher1) b
on a.Rno = b.Rno - 1
order by `date` desc);

create table hero2 as 
(select a.`date`, a.`close price`,
case 
	when a.`20 Day MA` < a.`50 Day MA` and b.`20 Day MA` > b.`50 Day MA` then 'Sell'
	when a.`20 Day MA` > a.`50 Day MA` and b.`20 Day MA` < b.`50 Day MA` then 'Buy'
    else 'Hold'
end `Signal`
from (select *, row_number() over (order by `date` desc) RNo from hero1) a
inner join (select *, row_number() over (order by `date` desc) RNo from hero1) b
on a.Rno = b.Rno - 1
order by `date` desc);

create table infosys2 as 
(select a.`date`, a.`close price`,
case 
	when a.`20 Day MA` < a.`50 Day MA` and b.`20 Day MA` > b.`50 Day MA` then 'Sell'
	when a.`20 Day MA` > a.`50 Day MA` and b.`20 Day MA` < b.`50 Day MA` then 'Buy'
    else 'Hold'
end `Signal`
from (select *, row_number() over (order by `date` desc) RNo from infosys1) a
inner join (select *, row_number() over (order by `date` desc) RNo from infosys1) b
on a.Rno = b.Rno - 1
order by `date` desc);

create table tcs2 as 
(select a.`date`, a.`close price`,
case 
	when a.`20 Day MA` < a.`50 Day MA` and b.`20 Day MA` > b.`50 Day MA` then 'Sell'
	when a.`20 Day MA` > a.`50 Day MA` and b.`20 Day MA` < b.`50 Day MA` then 'Buy'
    else 'Hold'
end `Signal`
from (select *, row_number() over (order by `date` desc) RNo from tcs1) a
inner join (select *, row_number() over (order by `date` desc) RNo from tcs1) b
on a.Rno = b.Rno - 1
order by `date` desc);

create table tvs2 as 
(select a.`date`, a.`close price`,
case 
	when a.`20 Day MA` < a.`50 Day MA` and b.`20 Day MA` > b.`50 Day MA` then 'Sell'
	when a.`20 Day MA` > a.`50 Day MA` and b.`20 Day MA` < b.`50 Day MA` then 'Buy'
    else 'Hold'
end `Signal`
from (select *, row_number() over (order by `date` desc) RNo from tvs1) a
inner join (select *, row_number() over (order by `date` desc) RNo from tvs1) b
on a.Rno = b.Rno - 1
order by `date` desc);

-- ************ # 4 ************
-- Creating a function that takes date as input and returns the signal for that particular date
-- (Buy, Sell, Hold) for Bajaj stock
delimiter $$
create function getSignal (dt1 date)
returns char(4) deterministic
begin
	declare signal_value char(4);
	select `signal` into signal_value from bajaj2 where `date`=dt1;
    return signal_value;
END
$$

-- Testing Function with a date value
select getSignal('2016-10-14')
