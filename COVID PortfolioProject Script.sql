SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4
--SELECT * FROM PortfolioProject..CovidVaccinations ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases VS Total Deaths
-- Shows likelihood of dying if you contract COVID in Italy

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percent
FROM PortfolioProject..CovidDeaths
WHERE location = 'Italy' AND WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases VS Population
-- Shows what percentage of the population got COVID in Italy

SELECT location, date, population, total_cases, (total_cases/population)*100 AS percent_population_infected
FROM PortfolioProject..CovidDeaths
WHERE location = 'Italy' AND WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to the population

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_population_infected DESC

-- Showing countries with highest death count by population

SELECT location, MAX(CAST(Total_deaths AS int)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

-- Let's break things down by continent
--Showing continents with the highest death count per population

SELECT location, MAX(CAST(Total_deaths AS int)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC

-- Global Numbers

SELECT date, SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percent
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percent
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at total population VS total vaccination
-- Use CTE
WITH popVSvac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
AS
(
SELECt d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(int,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated 
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent IS NOT NULL
)

SELECT *, (Rolling_People_Vaccinated/Population)*100
FROM popVSvac

-- Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
NewVaccination NUMERIC,
RollingPeopleVaccinated NUMERIC,
)

INSERT INTO #PercentPopulationVaccinated

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(int,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated 
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating views for later visualisatiions

CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(int,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated 
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated