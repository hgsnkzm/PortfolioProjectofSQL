SELECT *
From CovidData
ORDER BY 3, 4
;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidData
WHERE continent is not NULL
order by 1, 2
;

-- Looking at toatl cases vs total deaths
--Shows liklihood of dying if you contract covid  your country

SELECT location, date, total_deaths, total_cases, population, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidData
WHERE location LIKE "%states%"
and continent is not NULL
order by 1, 2
;

-- Looking at total cases vs population

SELECT location, date, total_cases, population, (total_cases/population)*100 as TotalCaesPercentage
FROM CovidData
WHERE location LIKE "Japan"
and continent is not NULL
order by 1, 2
;

-- Looking at countries with the highest Infection Rate compared to Popylation

SELECT location, date, MAX(total_cases), population, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidData
WHERE continent is not NULL
group by Location, population
order by PercentPopulationInfected DESC
;

-- Showing countries with highest death count per poppulation

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount, population, MAX((total_deaths/population))*100 as DeathperPopulation
FROM CovidData
WHERE continent is not NULL
group by Location
order by TotalDeathCount DESC
;

-- Breaking things down in continent

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount, population, MAX((total_deaths/population))*100 as DeathperPopulation
FROM CovidData
WHERE continent is NULL
group by location
order by TotalDeathCount DESC
;

-- Global Numbers

SELECT date, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths,  (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
FROM CovidData
WHERE continent is not null
group by date
order by 1, 2
;


-- Looking at total population vs vaccinations
-- Looking at running total of new vaccinations of each countries

select continent,  location, date, population, new_vaccinations
, sum(new_vaccinations) OVER (PARTITION BY location ORDER BY location, date) as RunningTottalOfNewVaccinations
--, (RunningTottalOfNewVaccinations/population)*100
from CovidData
where continent is not null 
order by 2, 3
;

-- Showing running total of new vaccinations per population by using CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RunningTottalOfNewVaccinations)
as
(
select continent,  location, date, population, new_vaccinations
, sum(new_vaccinations) OVER (PARTITION BY location ORDER BY location, date) as RunningTottalOfNewVaccinations
--, (RunningTottalOfNewVaccinations/population)*100
from CovidData
where continent is not null 
--order by 2, 3
)
SELECT *, (RunningTottalOfNewVaccinations/population)*100 as 
FROM PopvsVac
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