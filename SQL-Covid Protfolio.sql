SELECT *FROM CovidDeaths
ORDER BY 3,4



--SELECT *
--FROM CovidVaccination$
--ORDER BY 3,4


--- Select Data that are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2



-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like'%states%'
ORDER BY 1,2


-- Looking at Total Cases vs Population

SELECT location, date, total_cases, population, (total_cases/ population)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like'%states%'
ORDER BY 1,2


-- Looking at countries with Highest infection rate compared to Population

SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/ population))*100 AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC




-- Showing Countries with Highest Death Count per Population


SELECT location, MAX(Cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Breaking things down by Continent


SELECT location, MAX(Cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC





-- Showing the Continents with the highest death count per population

SELECT continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- Global Numbers


SELECT date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


SELECT  SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2



-- Joining Two tables and Looking at Total Population and Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations))OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPoepleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccination$ vac
	ON dea.location = vac.location
	AND dea.date  = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3



-- USE CTE

WITH PopvsVac( continent, location, date, population, RollingPoepleVaccinated, new_vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations))OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPoepleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccination$ vac
	ON dea.location = vac.location
	AND dea.date  = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT*, (RollingPoepleVaccinated/ population)*100
From PopvsVac



--- Using Temp Table to make the query more efficient, so I can use my table multiple times during my query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPoepleVaccinated numeric
)
INSERT INTO	#PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations))OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPoepleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccination$ vac
	ON dea.location = vac.location
	AND dea.date  = vac.date
WHERE dea.continent IS NOT NULL

 SELECT * , (RollingPoepleVaccinated/population)*100
 FROM #PercentPopulationVaccinated



 -- CREATING a View TO STORE DATA FOR LATER VISUALIZATIONS

 CREATE VIEW PercentPopulationVaccinated AS	
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations))OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPoepleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccination$ vac
	ON dea.location = vac.location
	AND dea.date  = vac.date
WHERE dea.continent IS NOT NULL






SELECT * 
FROM PercentPopulationVaccinated
