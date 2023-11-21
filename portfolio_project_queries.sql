SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4;

-- Select data that will be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
ORDER BY 1, 2;

--Looking at TOTAL CASES vs TOTAL DEATHS
--Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases * 100) AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
ORDER BY 1, 2;

-- Looking at TOTAL CASES vs POPULATION
-- Shows what percentage of population got covid
SELECT location, date, population, total_cases, (total_cases / population * 100) AS percent_population_infected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT null
ORDER BY 1, 2;

-- Looking at countries with HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases / population * 100)) AS percent_population_infected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT null
GROUP BY location, population
ORDER BY percent_population_infected DESC;

-- Shows countries with highest death count per population
SELECT location, MAX(cast(total_deaths as INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT null
GROUP BY location, population
ORDER BY total_death_count DESC;

-- Shows continents with the highest death count per population
SELECT location, MAX(cast(total_deaths as INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS null
GROUP BY location
ORDER BY total_death_count DESC;

-- Global Numbers on daily basis
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, (SUM(cast(new_deaths AS INT)) / SUM(new_cases) * 100) AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
GROUP BY date
ORDER BY 1, 2;

-- Global Numbers on total
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, (SUM(cast(new_deaths AS INT)) / SUM(new_cases) * 100) AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
ORDER BY 1, 2;



SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date;

-- TOTAL POPULATION vs VACCINATIONS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT null
ORDER BY 2, 3;

-- USE CTE
With PopVsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT null
-- ORDER BY 2, 3
)

SELECT *, (rolling_people_vaccinated / population) * 100
FROM PopVsVac



--USE TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(225),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
rolling_people_vaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT null
-- ORDER BY 2, 3;

SELECT *, (rolling_people_vaccinated / population) * 100
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualisation
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
-- ORDER BY 2, 3;

SELECT *
FROM PercentPopulationVaccinated