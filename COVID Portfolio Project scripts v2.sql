SELECT*
FROM [dbo].[CovidDeath]
ORDER BY 3,4

--SELECT*
--FROM [dbo].[CovidVaccinations]
--ORDER BY 3,4

-- Select Data that we are going to be using
SELECT [location], [date],[total_cases],[new_cases],[total_deaths],[population]
FROM [dbo].[CovidDeath]
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT [location], [date],[total_cases],[total_deaths],(CAST([total_deaths] AS FLOAT)/CAST([total_cases] AS FLOAT))*100 AS DeathPercentage 
FROM [dbo].[CovidDeath]
Where [location] like '%state'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT [location], [date],[total_cases],[population],(CAST([total_cases] AS FLOAT)/[population])*100 AS PercentPopulationInfected
FROM [dbo].[CovidDeath]
--Where [location] like '%states%'
ORDER BY 1,2

-- Looking at Countries with Higest Infection Rate vs Population 

SELECT [location],[population],MAX([total_cases]) AS HighestInfectionCount, 
MAX((CAST([total_cases] AS FLOAT)/[population]))*100 AS PercentPopulationInfected 
FROM [dbo].[CovidDeath]
--Where [location] like '%states%'
GROUP BY [location],[population]
ORDER BY PercentPopulationInfected DESC

-- Showing the countries with Highest Death Population 
SELECT [location],MAX(cast([total_deaths] as int)) AS TotalDeathCount 
FROM [dbo].[CovidDeath]
--Where [location] like '%states%'
WHERE [continent] IS NOT NULL
GROUP BY [location]
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT [continent],MAX(cast([total_deaths] as int)) AS TotalDeathCount 
FROM [dbo].[CovidDeath]
--Where [location] like '%states%'
WHERE [continent] IS NOT NULL
GROUP BY [continent]
ORDER BY TotalDeathCount DESC


-- Showing the continents with the Highest Death Count per Population
SELECT [continent],MAX(cast([total_deaths] as int)) AS TotalDeathCount 
FROM [dbo].[CovidDeath]
--Where [location] like '%states%'
WHERE [continent] IS NOT NULL
GROUP BY [continent]
ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT sum([new_cases]) As total_cases, sum([new_deaths]) AS total_deaths, SUM([new_deaths]) / NULLIF(SUM([new_cases]), 0) * 100 AS DeathPercentage 
FROM [dbo].[CovidDeath]
--Where [location] like '%states%'
Where continent IS NOT NULL
--group by [date]
ORDER BY 1,2


--Looking at Total Population vs Vaccinations

--USE CTE

With PopvsVac ([continent], [location], [date], [population],[new_vaccinations], RollingpeopleVaccinated)
AS
(
SELECT DEA.[continent], DEA.[location], DEA.[date], DEA.[population], VAC.[new_vaccinations],
SUM(CAST(VAC.[new_vaccinations] AS BIGINT)) OVER (PARTITION BY DEA.[location] ORDER BY DEA.[location], DEA.[date]) AS RollingpeopleVaccinated
--, (RollingpeopleVaccinated/[population])*100
FROM  [dbo].[CovidDeath] AS DEA
JOIN [dbo].[CovidVaccinations] AS VAC
	ON DEA.location=VAC.location
	AND DEA.date=VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT*, (RollingpeopleVaccinated/[population])*100
FROM PopvsVac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingpeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT DEA.[continent], DEA.[location], DEA.[date], DEA.[population], VAC.[new_vaccinations],
SUM(CAST(VAC.[new_vaccinations] AS BIGINT)) OVER (PARTITION BY DEA.[location] ORDER BY DEA.[location], DEA.[date]) AS RollingpeopleVaccinated
--, (RollingpeopleVaccinated/[population])*100
FROM  [dbo].[CovidDeath] AS DEA
JOIN [dbo].[CovidVaccinations] AS VAC
	ON DEA.location=VAC.location
	AND DEA.date=VAC.date
--WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3

SELECT*, (RollingpeopleVaccinated/[population])*100
FROM #PercentPopulationVaccinated


--Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as 
SELECT DEA.[continent], DEA.[location], DEA.[date], DEA.[population], VAC.[new_vaccinations],
SUM(CAST(VAC.[new_vaccinations] AS BIGINT)) OVER (PARTITION BY DEA.[location] ORDER BY DEA.[location], DEA.[date]) AS RollingpeopleVaccinated
--, (RollingpeopleVaccinated/[population])*100
FROM  [dbo].[CovidDeath] AS DEA
JOIN [dbo].[CovidVaccinations] AS VAC
	ON DEA.location=VAC.location
	AND DEA.date=VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3


SELECT*
FROM PercentPopulationVaccinated