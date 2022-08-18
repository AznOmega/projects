/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

--Examine Data in SQL
SELECT *
FROM CovidExplorationProject..['WorldCovidDeathData']
ORDER BY 3,4

--SELECT *
--FROM CovidExplorationProject..['WorldCovidVaxData']
--ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidExplorationProject..['WorldCovidDeathData']
WHERE continent is not null 
ORDER BY 1,2;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in the United States

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidExplorationProject..['WorldCovidDeathData']
WHERE location like '%states%' and continent is not null --code can be changed slightly to view another country's death percentage
ORDER BY 2;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
FROM CovidExplorationProject..['WorldCovidDeathData']
WHERE location like '%states%' and continent is not null --code can be changed slightly to view another country's death percentage
ORDER BY 2;

-- Countries w/ Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM CovidExplorationProject..['WorldCovidDeathData']
--Where location like '%states%' --code can be changed slightly to view a specific country's numbers
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


-- Countries with Highest Death Count per Population

SELECT location, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
FROM CovidExplorationProject..['WorldCovidDeathData']
--Where location like '%states%'  --code can be changed slightly to view a specific country's numbers
Where continent is not null 
Group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
FROM CovidExplorationProject..['WorldCovidDeathData']
--Where location like '%states%'
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(New_Cases)*100 as DeathPercentage
FROM CovidExplorationProject..['WorldCovidDeathData']
--Where location like '%states%'
WHERE continent is not null 
--Group By date
ORDER by 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidExplorationProject..['WorldCovidDeathData'] dea
JOIN CovidExplorationProject..['WorldCovidVaxData'] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

;WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidExplorationProject..['WorldCovidDeathData'] dea
JOIN CovidExplorationProject..['WorldCovidVaxData'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidExplorationProject..['WorldCovidDeathData'] dea
JOIN CovidExplorationProject..['WorldCovidVaxData'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated
GO



-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidExplorationProject..['WorldCovidDeathData'] dea
JOIN CovidExplorationProject..['WorldCovidVaxData'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
