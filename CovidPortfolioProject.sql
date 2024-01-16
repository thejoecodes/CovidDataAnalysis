--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject..CovidDeaths$
--ORDER BY 1, 2

--Total cases vs Total Deaths

SELECT location, total_cases, total_deaths, (CONVERT(DECIMAL(10,2), total_deaths) / CONVERT(DECIMAL(10,2),total_cases) )*100 as DeathPecentage
FROM PortfolioProject..CovidDeaths$
--WHERE location = 'Kenya' AND total_cases IS NOT NULL
ORDER BY 4 DESC

--Total cases vs Population

SELECT location, total_cases, population, (CONVERT(DECIMAL(18,2), total_cases) / CONVERT(DECIMAL(18,2),population) )*100 as InfectionRate
FROM PortfolioProject..CovidDeaths$
--WHERE location = 'Kenya' AND 
WHERE total_cases IS NOT NULL
ORDER BY 4 DESC

--Total deaths vs Population

SELECT location, population, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX((CONVERT(DECIMAL(18,2), total_deaths) / CONVERT(DECIMAL(18,2),population)))*100 as DeathhRate
FROM PortfolioProject..CovidDeaths$
--WHERE location = 'Kenya' AND total_deaths IS NOT NULL
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestDeathCount DESC

--Countries with the highest death count

SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

--CONTINENT LEVEL DATA

--Continent with the highest death count

SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCount, 
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY HighestDeathCount DESC

-- Death Rate per Continent

SELECT Continent, MAX(cast(population as int)) as Population, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX((CONVERT(DECIMAL(18,2), total_deaths) / CONVERT(DECIMAL(18,2),population)))*100 as DeathRate
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY DeathRate

--GLOBAL DATA

--World Population

With tmp as(SELECT Continent, MAX(population) as Population, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX((CONVERT(DECIMAL(18,2), total_deaths) / CONVERT(DECIMAL(18,2),population)))*100 as DeathRate
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent)
Select SUM(Population)
FROM tmp

-- World Data

SELECT date, SUM(cast(ISNULL(new_cases,0) as int)) as NewCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int)) /  SUM(cast(ISNULL(new_cases,0) as int)))*100 as DeathRate
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--JOINS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(DECIMAL(18),vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)as TotalRollingVacs
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL and vac.new_vaccinations IS NOT NULL
--GROUP BY dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations
ORDER BY dea.location, dea.population

--CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalRollingVacs)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(DECIMAL(18),vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)as TotalRollingVacs
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL and vac.new_vaccinations IS NOT NULL
--GROUP BY dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations
--ORDER BY dea.location, dea.population
)
SELECT *, (TotalRollingVacs/Population)*100 as VacRate
FROM PopvsVac


