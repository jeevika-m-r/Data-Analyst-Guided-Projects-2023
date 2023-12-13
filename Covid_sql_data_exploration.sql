SELECT *
FROM Practice_portfolio..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM Practice_portfolio..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Practice_portfolio..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking at Total cases vs Total deaths
-- shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_deaths,total_cases ,
     (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM Practice_portfolio..CovidDeaths
WHERE location = 'India'
AND continent is not null
ORDER BY 1,2;



--Looking at Total cases vs population
--shows what percentage of population got covid

SELECT location, date, population, total_cases, 
    (NULLIF(CONVERT(float, total_cases), 0) / CONVERT(float, population)) * 100 AS PercentPopulationInfected
FROM Practice_portfolio..CovidDeaths
--WHERE location = 'India'
--WHERE continent is not null
ORDER BY 1, 2


--Looking at countries with highest infection rate compared to population

SELECT
    location,
    population,
    MAX(total_cases) AS Highest_Infection_Count,
    (NULLIF(CONVERT(float, MAX(total_cases)), 0) / CONVERT(float, population)) * 100 AS PercentPopulationInfected
FROM Practice_portfolio..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--showing countries with Highest Death Count Per Population

SELECT location, MAX(CAST(total_deaths AS int)) AS Total_death_Count
FROM Practice_portfolio..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY Total_death_Count DESC

--Showing Continents with Highest Death Count Per Population

SELECT continent, MAX(CAST(total_deaths AS int)) AS Total_death_Count
FROM Practice_portfolio..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY Total_death_Count DESC

--Global Numbers classified based on date

SELECT  date, SUM(new_cases) AS total_cases , SUM(CONVERT(float,new_deaths)) AS total_deaths , 
      SUM(CONVERT(float,new_deaths))/SUM(new_cases)*100 AS death_percentage
FROM Practice_portfolio..CovidDeaths
--WHERE location = 'India'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

-- Global Covid data

SELECT  SUM(new_cases) AS total_cases , SUM(CONVERT(float,new_deaths)) AS total_deaths , 
      SUM(CONVERT(float,new_deaths))/SUM(new_cases)*100 AS death_percentage
FROM Practice_portfolio..CovidDeaths
--WHERE location = 'India'
WHERE continent is not null
ORDER BY 1,2;

-- total population vs total vaccinations

SELECT dea.continent , dea.location, dea.date ,dea.population,vac.new_vaccinations,
   SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER By dea.location
      ,dea.date) AS rolling_people_vaccinated
FROM Practice_portfolio..CovidDeaths dea
JOIN Practice_portfolio..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER by 2,3

--using CTE 

with PopvsVac (continent,location, date,population,new_vaccinations,rolling_people_vaccinated)
as
(
SELECT dea.continent , dea.location, dea.date ,dea.population,vac.new_vaccinations,
   SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER By dea.location
      ,dea.date) AS rolling_people_vaccinated
FROM Practice_portfolio..CovidDeaths dea
JOIN Practice_portfolio..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT * , (CONVERT(float,rolling_people_vaccinated )/ CONVERT(float,population))*100 AS percentage_vaccinated
FROM PopvsVac


--TEMP tables
DROP TABLE #peoplevaccinated

CREATE TABLE #peoplevaccinated
( 
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
INSERT INTO #peoplevaccinated
SELECT dea.continent , dea.location, dea.date ,dea.population,vac.new_vaccinations,
   SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER By dea.location
      ,dea.date) AS rolling_people_vaccinated
FROM Practice_portfolio..CovidDeaths dea
JOIN Practice_portfolio..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
--WHERE dea.continent is not null

SELECT * , (CONVERT(float,rolling_people_vaccinated )/ CONVERT(float,population))*100 AS percentage_vaccinated
FROM #peoplevaccinated


--creating view

create view percentage_vaccinated as
SELECT dea.continent , dea.location, dea.date ,dea.population,vac.new_vaccinations,
   SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER By dea.location
      ,dea.date) AS rolling_people_vaccinated
FROM Practice_portfolio..CovidDeaths dea
JOIN Practice_portfolio..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null
 

