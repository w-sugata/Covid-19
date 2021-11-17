-- Convert empty cells into NULL
SET SQL_SAFE_UPDATES = 0;
UPDATE CovidDeaths set continent = NULL where continent = ''
SET SQL_SAFE_UPDATES = 1;

SELECT *
FROM CovidDeaths
-- WHERE continent is not NULL
ORDER BY 3,4

-- SELECT *
-- FROM CovidVaccinations
-- ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%Japan%'

-- Total Cases vs Population
SELECT location, date, population, total_cases, (total_cases/population)*100 as CasesPerCapita
FROM CovidDeaths
WHERE location like '%Japan%'

-- Countries with Highest Infection Rate Compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as CasesPerCapita
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY CasesPerCapita DESC

-- Countries with Highest Death Count per Population 
SELECT location, MAX(cast(total_deaths as double)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Continents with Highest Death Count per Population 
SELECT location, MAX(cast(total_deaths as double)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Global numbers per day
SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, (SUM(new_deaths)/SUM(new_cases)) *100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not NULL 
GROUP BY date
ORDER BY 1,2

-- Global total numbers
SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, (SUM(new_deaths)/SUM(new_cases)) *100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not NULL 

-- Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, (SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date)) as RollingPeopleVaccinated,(RollingPeopleVaccinated/population
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

-- Percentage of Vaccinations
WITH PopVSVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, (SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date)) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not NULL
-- ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as VaccinationPercentage
FROM PopVSVac
