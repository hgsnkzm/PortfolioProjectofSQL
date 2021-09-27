-- 1. Looking at total cases vs total deaths in the world

SELECT sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercetage
From CovidData
Where continent is not NULL
Order by 1, 2
;


-- Looking at total cases vs population
-- 
-- SELECT location, date, total_cases, population, (total_cases/population)*100 as TotalCaesPercentage
-- FROM CovidData
-- WHERE location LIKE "Japan"
-- and continent is not NULL
-- order by 1, 2
-- ;

-- 2. Looking at total deaths of each continent

Select location, sum(new_deaths) as TotalDeathCount
From CovidData
Where continent is null And location not in ('World', 'European Union', 'International')
Group by location
Order by TotalDeathCount DESC
;


-- 3. Looking at countries with the highest Infection Count compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidData
WHERE continent is not NULL
group by location, population
order by PercentPopulationInfected DESC
;


-- Showing countries with highest death count per poppulation
-- 
-- SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount, population, MAX((total_deaths/population))*100 as DeathperPopulation
-- FROM CovidData
-- WHERE continent is not NULL
-- group by Location
-- order by TotalDeathCount DESC
-- ;

-- 4. The transition of the highest infection count of each country

Select location, population, date, Max(total_cases) as HighestInfectedCount, Max((total_cases/population))*100 as PercentPopulationInfected
From CovidData
Where continent is not Null
Group by location, population, date
Order by PercentPopulationInfected DESC
;

-- 5. Showing the running tottal of new deaths

SELECT location, population, date, new_cases, sum(new_cases) OVER (PARTITION BY location ORDER BY location, date) as RunningTotalOfNewCases
, new_deaths, sum(new_deaths) OVER (PARTITION BY location ORDER BY location, date) as RunningTotalOfNewDeaths
FROM CovidData
WHERE continent is not NULL
ORDER BY 1, 3
;

-- 5-a. Showing percentage of running total of new deaths per population

WITH PercentRunningTotalofNewDeatshs (location, population, date, new_cases, RunningTotalOfNewCases, new_deaths, RunningTotalOfNewDeaths)
as
(
SELECT location, population, date, new_cases, sum(new_cases) OVER (PARTITION BY location ORDER BY location, date) as RunningTotalOfNewCases
, new_deaths, sum(new_deaths) OVER (PARTITION BY location ORDER BY location, date) as RunningTotalOfNewDeaths
FROM CovidData
WHERE continent is not NULL
-- ORDER BY 1, 3
)
SELECT *, (RunningTotalOfNewCases/population)*100 as PercentRunningTotalOfNewCases, (RunningTotalOfNewDeaths/population)*100 as PercentRunningTotalOfNewDeaths
From PercentRunningTotalofNewDeatshs
;


-- Creating view to store data for lator visualizations

CREATE VIEW PercentPopulationVaccinated as
select continent,  location, date, population, new_vaccinations
, sum(new_vaccinations) OVER (PARTITION BY location ORDER BY location, date) as RunningTottalOfNewVaccinations
--, (RunningTottalOfNewVaccinations/population)*100
from CovidData
where continent is not null 
--order by 2, 3
;
