SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT location,date,total_cases,new_cases,total_deaths,population
--FROM PortfolioProject..CovidDeaths$
--ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--SHows likelihood of dying if you contract covid in your country
SELECT location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like'%states%'
ORDER BY 1,2

--Looking at Death Percentage by Country
SELECT location,date,population,total_cases,(total_cases/population)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like'%states%'
WHERE continent is not null
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population
SELECT location,population,MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location like'%states%'
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with Highest Death Count Per Population
SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like'%states%'
WHERE continent is not null
GROUP BY location,population
ORDER BY TotalDeathCount DESC

--BREAKING DOWN BY CONTINENT
SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like'%states%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC


--Showing Continents with the Highest Death Count
SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like'%states%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT date,SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage --,total_deaths,(total_cases/population)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like'%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Total World Cases
SELECT SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage --,total_deaths,(total_cases/population)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like'%states%'
WHERE continent is not null
ORDER BY 1,2


--Looking at Total Population vs Vaccinations 

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
new_vaccinations_total numeric
)

INSERT INTO #PercentPopulationVaccinated 

	SELECT cd.continent, cd.location, cd.date, cd.population,cv.new_vaccinations,
	   SUM(CAST(cv.new_vaccinations AS int)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS new_vaccinations_total
	  FROM PortfolioProject..CovidDeaths$ cd
       JOIN PortfolioProject..CovidVaccinations$ cv
         ON cd.location = cv.location
        AND cd.date = cv.date
	WHERE cd.continent is not null
   --ORDER BY 2,3
   
SELECT *, (new_vaccinations_total/population)*100
FROM #PercentPopulationVaccinated



--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS

	SELECT cd.continent, cd.location, cd.date, cd.population,cv.new_vaccinations,
	   SUM(CAST(cv.new_vaccinations AS int)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS new_vaccinations_total
	  FROM PortfolioProject..CovidDeaths$ cd
       JOIN PortfolioProject..CovidVaccinations$ cv
         ON cd.location = cv.location
        AND cd.date = cv.date
	WHERE cd.continent is not null
   --ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated



