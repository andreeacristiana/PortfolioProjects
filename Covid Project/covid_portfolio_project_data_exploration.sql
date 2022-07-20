select *
from pp..CovidDeaths
order by 3,4

-- select data I am going to work with
select location, date, total_cases, new_cases, total_deaths, population
from pp..coviddeaths
order by 1,2

-- total cases vs total deaths
-- shows the likelihood of dying from getting Covid
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from pp..coviddeaths
where location = 'Finland'
order by 1,2

-- total cases vs population
-- shows the percentage of population infected with Covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from pp..coviddeaths
where location = 'Finland'
order by 1,2

-- countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from pp..coviddeaths
group by location, population
order by PercentPopulationInfected desc

-- COUNTRIES with the highest death count per population
select location, max(cast(total_deaths as int)) as HighestDeathCount
from pp..coviddeaths
where continent is not null
group by location
order by HighestDeathCount desc

-- CONTINENTS with the highest death count per population
select location, max(cast(total_deaths as int)) as HighestDeathCount
from pp..coviddeaths
where continent is null
group by location
order by HighestDeathCount desc

-- GLOBAL numbers by date
select 
--date, 
sum(new_cases) as GlobalNewCases,
sum(cast(new_deaths as int)) as GlobalNewDeaths,
sum(cast(new_deaths as int))/sum(new_cases) * 100 as GlobalDeathPercentage
from pp..coviddeaths
where continent is not null
--group by date
order by 1,2

-- GLOBAL numbers
select  
sum(new_cases) as GlobalTotalCases,
sum(cast(new_deaths as bigint)) as GlobalTotalDeaths,
sum(cast(new_deaths as bigint))/sum(new_cases) * 100 as GlobalDeathPercentage
from pp..coviddeaths
where continent is not null
order by 1,2

------------------------

select *
from pp..covidvaccinations
order by 3,4

-- total population vs vaccination by date
select
d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location, d.date) as RollingVaccinated
from pp..coviddeaths d
join pp..covidvaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
order by 2,3

-- total population vs vaccination by location
select
v.location,
d.population,
sum(cast(v.new_vaccinations as bigint)) as PeopleVaccinated,
sum(cast(v.new_vaccinations as bigint))/d.population*100 as PercentageVaccinated
from pp..CovidVaccinations v
join pp..coviddeaths d
	on v.location = d.location
	and v.date = d.date
--and location = 'Afghanistan'
group by v.location, d.population
order by 1,2


-- adding the percentage of vaccinated population
select
d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location, d.date) as RollingVaccinated
--(RollingVaccinated/d.population)*100
from pp..coviddeaths d
join pp..covidvaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
order by 2,3

-- using CTE to determine the rolling vaccinated percentage of the population of each country
with popvsvac (continent, location, date, population, new_vaccinations, RollingVaccinated)
as
(
select
d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location, d.date) as RollingVaccinated
from pp..coviddeaths d
join pp..covidvaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
)
select *, (RollingVaccinated/population)*100 as PercentagePopulationVaccinated
from popvsvac

-- using TEMP TABLE
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinated numeric
)
insert into #percentpopulationvaccinated
select
d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location, d.date) as RollingVaccinated
from pp..coviddeaths d
join pp..covidvaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null

select *, (RollingVaccinated/population)*100 as PercentagePopulationVaccinated
from #percentpopulationvaccinated

-- creating VIEW to store data for later visualizations
create view percentpopulationvaccinated as
select
d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location, d.date) as RollingVaccinated
from pp..coviddeaths d
join pp..covidvaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null

select *, (RollingVaccinated/population)*100 as PercentagePopulationVaccinated
from percentpopulationvaccinated