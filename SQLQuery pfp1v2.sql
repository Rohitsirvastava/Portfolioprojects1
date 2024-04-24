--Select * from [covid deaths]
--select * from covidVaccination

--deathpercent

Select  location, date, total_cases, total_deaths, CONVERT (NUMERIC(18,2), total_deaths)/ CONVERT (NUMERIC(18,2),total_cases)*100 AS DEATHPERCENT
from master..[covid deaths]
order by 1,2

--totalcase percent

Select  location, date, total_cases, population, CONVERT (NUMERIC(18,2), total_cases)/population *100 
from master..[covid deaths]
where location like '%india%'
order by 1,2

--highest infection rate

Select  location, population, max(total_cases) as highestinfection, max(CONVERT (NUMERIC(18,2), total_cases)/population *100) as hi
from master..[covid deaths]
--where location like '%india%'
group by location, population
order by hi desc

 --highest death cont 

 Select  location, population, max(cast(total_deaths as int)) as highestdeath --max(CONVERT (NUMERIC(18,2), total_deaths)/population *100) as hd
from master..[covid deaths]
--where location  
group by location, population
order by highestdeath desc


--break down by continent total death

Select Continent , max(cast(total_deaths as int)) as highestdeath
from master..[covid deaths]
where continent is not null
group by continent
order by highestdeath desc

Select location , max(cast(total_deaths as int)) as highestdeath
from master..[covid deaths]
where location is not null
group by location
order by highestdeath desc


--global numbers

select date, sum(new_cases) as 'totalcase on date', sum(new_deaths) as 'totaldeath on date'
from  master..[covid deaths]
where continent is not null
group by date
order by 'totalcase on date' desc, 'totaldeath on date'



--total population vs total vaccination 

select de.continent, de.location, de.date, de.population, vc.new_vaccinations, sum(convert(bigint,vc.new_vaccinations)) over (partition by de.location order by de.location, de.date) tvc
from master..[covid deaths] de
join master..covidVaccination vc
on de.location = vc.location
and de.date = vc.date
where de.continent is not null and vc.new_vaccinations is not null
order by 1,2,3


--use CTE

With popvsvac (continent, location, DATE, POPULATION, tvc, new_vaccinations)
as
(
select de.continent, de.location, de.date, de.population, vc.new_vaccinations, sum(convert(bigint,vc.new_vaccinations)) over (partition by de.location order by de.location, de.date) tvc
from master..[covid deaths] de
join master..covidVaccination vc
on de.location = vc.location
and de.date = vc.date
where de.continent is not null 
--order by 1,2,3
)

select *, (tvc/POPULATION)*100
from popvsvac


--temp table

drop table if exists  #percentpopulationvaccinated
create table #percentpopulationvaccinated
(continent  varchar (50),
location varchar (50),
date datetime,
population numeric,
new_vaccinations numeric,
tvc numeric
)


insert into #percentpopulationvaccinated
select de.continent, de.location, de.date, de.population, vc.new_vaccinations, sum(convert(bigint,vc.new_vaccinations)) over (partition by de.location order by de.location, de.date) tvc
from master..[covid deaths] de
join master..covidVaccination vc
on de.location = vc.location
and de.date = vc.date
--where de.continent is not null 
--order by 1,2,3

select *, (tvc/POPULATION)*100
from #percentpopulationvaccinated


--create view

create view percentpopulationvaccinated as

select de.continent, de.location, de.date, de.population, vc.new_vaccinations, sum(convert(bigint,vc.new_vaccinations)) over (partition by de.location order by de.location, de.date) tvc
from master..[covid deaths] de
join master..covidVaccination vc
on de.location = vc.location
and de.date = vc.date
where de.continent is not null 
--order by 1,2,3


select *
from percentpopulationvaccinated





