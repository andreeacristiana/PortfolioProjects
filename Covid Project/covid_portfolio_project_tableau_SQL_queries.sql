-- total death worldwide and death percentage
select 
sum(new_cases) as total_cases,
sum(cast(new_deaths as int)) as TotalDeaths,
sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from pp..coviddeaths
where continent is not null
order by 1,2


-- total deaths by location
select
location,
sum(cast(new_deaths as int)) as TotalDeaths
from pp..coviddeaths
where continent is null
and location not in ('World','European Union','International','High Income','Low Income','Lower middle income','Upper middle income')
group by location
order by TotalDeaths desc


-- highest infestation rate by location
select
location,
population,
max(total_cases) as HighestInfestation,
max((total_cases/population)) * 100 PercentPopulationInfected
from pp..coviddeaths
group by location, population
order by PercentPopulationInfected desc


--highest infestation rate by date
select
location,
population,
date,
max(total_cases) as HighestInfestation,
max((total_cases/population)) * 100 PercentPopulationInfected
from pp..coviddeaths
group by location, population, date
order by PercentPopulationInfected desc