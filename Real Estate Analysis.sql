select * from realestate_dataset;

-- What is the average price for homes in each city?
select city,round(avg(price),2) as avg_price from realestate_dataset
group by city
order by avg_price;
-- this shows that avg price of homes in San Francisco are cheapest as compared to other cities

-- Find the top 5 most expensive properties and their listing agents.
select MLS_ID,Listing_Agent from realestate_dataset
order by price desc
limit 5;

-- Identify the property type with the highest average price.
select Property_type,round(avg(price)) as Property_wise_avg_price from realestate_dataset
group by Property_type;

-- Find the average area (Sqft) for properties with 3+ bedrooms.
select cast((substr(Bedrooms,1,1)) as Unsigned) as no_of_beds,round(avg(area)) as avg_area_size from realestate_dataset
group by no_of_beds
having no_of_beds>=3
order by no_of_beds;

-- Find the average area (Sqft) for properties with 3+ bedrooms.
select round(avg(area)) as avg_area from realestate_dataset
where cast((substr(Bedrooms,1,1)) as Unsigned)=3;

-- Identify the largest homes (by area) in each state.
select State, max(area) from realestate_dataset
group by state;

-- Identify the smallest homes (by area) in each state.
select State, min(area) from realestate_dataset
group by state;

-- Identify listing agents with the shortest average days on market.
select listing_agent,round(avg(Days_on_market)) as avg_days_on_market from realestate_dataset
group by Listing_Agent
order by avg_days_on_market;
-- This shows that Emily Davis is better listing agent than others as properties listed by her remains for less no. of days in market

-- Determine which year-built range (e.g., 1950–1970, 1971–1990) has the highest-priced properties.
with cte as(SELECT
*,CASE 
        WHEN Year_Built BETWEEN 1950 AND 1970 THEN '1950-1970'
        WHEN Year_Built BETWEEN 1971 AND 1990 THEN '1971-1990'
        WHEN Year_Built BETWEEN 1991 AND 2010 THEN '1991-2010'
        WHEN Year_Built >= 2011 THEN '2011-Present'
        ELSE 'Before 1950'
    END AS Year_Range from realestate_dataset)
select Year_Range, round(avg(price)) as avg_price
from cte
group by Year_Range
order by avg_price desc
limit 1;

-- find the count of properties sold by each listing agent 
select listing_agent,count(*) from realestate_dataset
where Status="Sold"
group by listing_agent;

-- For each listing agent find the count of properties which are having status "For Sale"
select listing_agent,count(*) from realestate_dataset
where Status="For Sale"
group by listing_agent;

-- For each listing agent find the count of properties which are having status "pending"
select listing_agent,count(*) from realestate_dataset
where Status="Pending"
group by listing_agent;

-- Identify the zip codes with the most expensive homes on average.
select Zipcode,round(avg(price)) as avg_price_in_zipcode from realestate_dataset
group by Zipcode
order by avg_price_in_zipcode desc
limit 5;

-- City with highest average price per square foot
select City, 
       round(avg(Price / Area), 2) AS avg_price_per_sqft
from realestate_dataset
group by City
order by avg_price_per_sqft desc
limit 1;


-- Average price by lot size ranges
select 
    case 
        when Lot_Size < 2500 then '<2500 sqft'
        when Lot_Size between 2500 and 5000 then '2500-5000 sqft'
        when Lot_Size between 5001 and 10000 then '5001-10000 sqft'
        else '>10000 sqft'
   end as Lot_Size_Range,
    round(avg(Price), 2) as avg_price
from realestate_dataset
group by Lot_Size_Range
order by Lot_Size_Range;


-- Compare average price of new vs old homes
select 
    case 
        when Year_Built > 2010 then 'Built After 2010'
        when Year_Built <= 1990 then 'Built Before 1990'
        else 'Built 1991-2010'
    end as Year_Group,
    round(avg(Price), 2) as avg_price
from realestate_dataset
group by Year_Group
order by avg_price desc;

-- Most common property type per city
select city, property_type, count(*) as count_per_type
from realestate_dataset
group by city, property_type
order by city, count_per_type desc;

-- High-demand properties which got sold in 3 days of listing and whose price are greater than avg price in that city
with city_avg as(
select city,avg(price) as avg_city_price from realestate_dataset
group by city
)
select r.MLS_ID,r.city,r.price,r.days_on_market,r.listing_agent from realestate_dataset r
join city_avg c
on r.city=c.city
where status="Sold" and days_on_market<=3 and r.price>c.avg_city_price
order by r.days_on_market;
