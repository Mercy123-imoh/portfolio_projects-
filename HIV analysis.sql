Select * from art_coverage_by_country_clean; 
select * from no_of_people_living_with_hiv_by_country_clean;
select * from no_of_deaths_by_country_clean; 

-- looking at maximum cases vs maximum deaths 
-- this shows the likelihood of dying if you contracting HIV in your country 

select deaths.Country, deaths.Year, art.Estimated_number_of_people_living_with_HIV_max, deaths.count_max as max_no_of_deaths, 
(deaths.count_max/art.Estimated_number_of_people_living_with_HIV_max)* 100 as death_percentage
from art_coverage_by_country_clean as art
join no_of_deaths_by_country_clean as deaths
on art.Country = deaths.Country 
where deaths.Country = "Nigeria"
order by deaths.Country , deaths.Year;

-- looking at maximum cases vs population 
-- shows what population of people got HIV 

select deaths.Country, deaths.Year, Population,  art.Estimated_number_of_people_living_with_HIV_max, 
(art.Estimated_number_of_people_living_with_HIV_max/Population)* 100 as percent_population_infected
from art_coverage_by_country_clean as art
join no_of_deaths_by_country_clean as deaths
on art.Country = deaths.Country 
-- where deaths.Country = "Nigeria"
order by deaths.Country , deaths.Year;


-- looking at countries with highest infection rate compared to population

select deaths.Country, Population,  max(art.Estimated_number_of_people_living_with_HIV_max), 
max((art.Estimated_number_of_people_living_with_HIV_max/Population))* 100 as percent_population_infected
from art_coverage_by_country_clean as art
join no_of_deaths_by_country_clean as deaths
on art.Country = deaths.Country 
-- where deaths.Country = "Nigeria"
group by deaths.Country, Population
order by percent_population_infected desc;


-- countries with the highest death count per population 

select deaths.Country, max(deaths.count_max) as max_no_of_deaths 
from art_coverage_by_country_clean as art
join no_of_deaths_by_country_clean as deaths
on art.Country = deaths.Country 
-- where deaths.Country = "Nigeria"
group by deaths.Country
order by max_no_of_deaths desc;


-- let's break it down by who region 
-- showing continents with the higest death count 

select art.WHO_Region, max(deaths.count_max) as max_no_of_deaths 
from art_coverage_by_country_clean as art
join no_of_deaths_by_country_clean as deaths
on art.Country = deaths.Country 
-- where deaths.Country = "Nigeria"
group by art.WHO_Region
order by max_no_of_deaths desc; 

-- global numbers 

select 
	sum(art.Estimated_number_of_people_living_with_HIV_max) as total_cases ,
	sum(deaths.count_max) as total_deaths, 
	(sum(deaths.count_max)/sum(art.Estimated_number_of_people_living_with_HIV_max))* 100 as death_percentage
from art_coverage_by_country_clean as art
join no_of_deaths_by_country_clean as deaths
on art.Country = deaths.Country; 

-- using cte 

with popvsart 
as 
(
select deaths.Country, art.WHO_Region, deaths.Year, art.Population, art.Reported_number_of_people_receiving_ART, 
	sum(art.Reported_number_of_people_receiving_ART) over
	(partition by deaths.Country order by deaths.Country, deaths.Year ) as rolling_people_vaccinated
from art_coverage_by_country_clean as art
join no_of_deaths_by_country_clean as deaths
on art.Country = deaths.Country 
)
select *, (rolling_people_vaccinated/Population)*100 as percentage_no_of_people_recieving_art_per_population 
from popvsart; 


-- create view 

create view percent_population_vaccinated as
select deaths.Country, art.WHO_Region, deaths.Year, art.Population, art.Reported_number_of_people_receiving_ART, 
	sum(art.Reported_number_of_people_receiving_ART) over
	(partition by deaths.Country order by deaths.Country, deaths.Year ) as rolling_people_vaccinated
from art_coverage_by_country_clean as art
join no_of_deaths_by_country_clean as deaths
on art.Country = deaths.Country




 
