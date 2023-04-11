select * from `covid_data.covid_deaths`
where continent is not null
order by 3,4

select * from `covid_data.covid_vac`
where continent is not null
order by 3,4
--data used in analysis ^^^^^


-- total cases vs total deaths
-- shows likelihood of dying if one contracts covid in their country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from `covid_data.covid_deaths`
where continent is not null
order by 1,2

-- total cases vs population
-- total percent of population that contracted covid
select continent, date, population, total_cases, (total_cases/population)*100 as InfectedPercent
from `covid_data.covid_deaths`
order by 1,2

-- infection rate:population
select continent, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercent
from `covid_data.covid_deaths`
group by continent, population
order by InfectedPercent desc


-- death count:population
select Location,MAX(total_deaths) as TotalDeathCount
from `covid_data.covid_deaths`
where continent is not null
group by Location
order by TotalDeathCount desc

-- death count:population continents
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from `covid_data.covid_deaths`
where continent is not null
group by location
order by TotalDeathCount desc

-- breaking down by continent instead of country
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from `covid_data.covid_deaths`
where continent is null
group by location
order by TotalDeathCount desc

-- global numbers
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from `covid_data.covid_deaths`
where continent is not null
--group by date
order by 1,2


-- total population:vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
from covid_data.covid_vac vac
join covid_data.covid_deaths dea
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- cte
with PopsvsVac as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
from covid_data.covid_vac vac
join covid_data.covid_deaths dea
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)  
select *, (RollingPeopleVaccinated/population)
from PopsvsVac