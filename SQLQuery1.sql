-- SELECTing the first 20 rows for inspection
SELECT top 20 * 
from Portfolio_Project..CovidDeaths
--limit 20
order by 3, 4

--Showing the deaths, new and total cases in India
SELECT location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project..CovidDeaths
where location = 'India'
order by 1, 2


--Calculating the percentage of population infected in India
SELECT location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
from Portfolio_Project..CovidDeaths
where location = 'India'
order by 1, 2



--Calculating the percentage of total population infected by Covid in the world by the end of 27/12/2021
SELECT location, population, max(cast(total_cases as int)) as max_cases, (max(cast(total_cases as int))/population)*100 as TotalInfectionPercentage
from Portfolio_Project..CovidDeaths
group by location, population
order by location



Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths
where continent is not null 
--Group By date
order by 1,2




--Calculating the percentage of total population infected by Covid in the world by the end of 27/12/2021
SELECT location, population, max(cast(total_cases as int)) as max_cases, (max(cast(total_cases as int))/population)*100 as TotalInfectionPercentage
from Portfolio_Project..CovidDeaths
--where continent is not null
group by location, population
order by TotalInfectionPercentage desc


SELECT location, population, date, max(cast(total_cases as int)) as max_cases, (max(cast(total_cases as int))/population)*100 as TotalInfectionPercentage
from Portfolio_Project..CovidDeaths
--where continent is not null
group by location, population, date
order by TotalInfectionPercentage desc


-- Calculating the percentage of total deaths at all the locations by covid in the world by the end of 27/12/2021
SELECT location, population, max(cast(total_deaths as int)) as deaths, (max(cast(total_deaths as int))/population)*100 as TotalDeathPercentage
from Portfolio_Project..CovidDeaths
where continent is not null
group by location, population
order by deaths desc
-- returns all the countries with highest deaths and their death percentage



-- Showing continents with the highest death count and death percentage per population
select location, population,  max(cast(total_deaths as int)) as deaths, (max(cast(total_deaths as int))/population)*100 as TotalDeathPercentage
from Portfolio_Project..CovidDeaths
where continent is null 
and location not in('world', 'upper middle income', 'high income', 'lower middle income', 'european union', 'low income', 'international')
group by location, population
order by deaths desc



select location, max(cast(total_deaths as int)) as deaths
from Portfolio_Project..CovidDeaths
where continent is null 
and location not in('world', 'upper middle income', 'high income', 'lower middle income', 'european union', 'low income', 'international')
group by location
order by deaths desc

--Showing countries with highest death count
select location, max(cast(total_deaths as int)) as deaths, population
from Portfolio_Project..CovidDeaths
where continent is not null
group by location, population
order by deaths desc



-- Showing cases and deaths around the world everyday
select cast(date as date) as date, sum(cast(total_cases as int)) as cases, sum(cast(total_deaths as int)) as deaths,  sum(cast(new_cases as int)) as new_cases, sum(cast(new_deaths as int)) as new_deaths
from Portfolio_Project..CovidDeaths
group by date
order by date



select dea.location, dea.date, dea.population, max(dea.total_cases), max(dea.total_deaths), max(vac.total_vaccinations), max(vac.people_fully_vaccinated), max(vac.people_vaccinated)
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where vac.total_vaccinations is not null
group by dea.location, dea.date
order by 1, 2, 3

--Population vs total vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION by dea.location order by dea.location, dea.date) as total_vaccinations
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- Using CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, Total_Vaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION by dea.location order by dea.location, dea.date) as total_vaccinations
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select*, (Total_Vaccinations/Population)*100 as vaccPercent
from PopVsVac




-- Temp table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Total_Vaccinations numeric
)

INSERT into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, ISNULL(vac.new_vaccinations, 0),
SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION by dea.location order by dea.location, dea.date) as total_vaccinations
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3


select*, (Total_Vaccinations/Population)*100 as vaccPercent
from #PercentPopulationVaccinated




