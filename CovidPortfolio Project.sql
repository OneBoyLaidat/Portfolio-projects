--Covid 19 Data Exploration-- 

--Skills used: Joins, Aggregate Functions, Converting Data Types, Temp Tables, CTE's, Windows Functions, Creating Views**

                      --THE DAILY DEATH RATE PER INFECTED RATIO-- 
-- Shows you the chances of dieing from COVID if you got infected in different locations in Africa--
SELECT location,CAST(date AS date) clean_date,total_deaths, total_cases,(total_deaths*1.0/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent='Africa'
ORDER BY 1,2;


                --INFECTED POPULATION PERCENTAGE--
-- Shows you the percantage of the population that got infected with COVID in different locations in ASIA-- 
SELECT location, MAX(total_cases) total_case,MAX(population) total_population, ((MAX(total_cases)*1.0)/MAX(population))*100 AS Infected_population
FROM CovidDeaths
WHERE continent='Asia'
GROUP BY location
ORDER BY 1;

                 --DEATH TO POPULATION PERCENTAGE--
-- Shows the percentage of the total population that died of COVID in EUROPE--
SELECT location, MAX(total_deaths) total_deaths,MAX(population) total_population, ((MAX(total_deaths)*1.0)/MAX(population))*100 AS Infected_population
FROM CovidDeaths
WHERE continent='Europe'
GROUP BY location
ORDER BY 1;

                      -- Infection RATE Compared to populatiion--
--Shows countries with the highest infection rate compared to population--
SELECT dea.location,dea.population, MAX(dea.total_cases) Total_infected,(MAX(dea.total_cases*1.0)/dea.population)*100 AS infection_rate
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.location IS NOT NULL
GROUP BY dea.location,dea.population
ORDER BY (MAX(dea.total_cases*1.0)/dea.population)*100  DESC;


                 --VACCINATION RATIO PER COUNTRY--
-- The percentage of the fully vaccinated people per location--
SELECT dea.location,dea.population, MAX(vac.people_fully_vaccinated) Total_fully_vaccinated,(CAST(MAX(vac.people_fully_vaccinated) AS int)*1.0/dea.population)*100 AS fully_vaccinated_ratio
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.location IS NOT NULL
GROUP BY dea.location,dea.population
ORDER BY (CAST(MAX(vac.people_fully_vaccinated) AS int)*1.0/dea.population)*100 DESC;

                     
					 
					 
					 
					 --USING TEMP TABLES--
---- The percentage of the fully vaccinated people per location--

DROP TABLE if exists #fully_vaccinated_people
CREATE TABLE #fully_vaccinated_people
(
Location nvarchar(255),
date datetime,
Population numeric,
Total_fully_vaccinated numeric
)

INSERT INTO #fully_vaccinated_people
SELECT dea.location locations,dea.date date,dea.population total_population, CAST(MAX(vac.people_fully_vaccinated) AS int) Total_fully_vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location AND dea.date=vac.date
GROUP BY dea.location, dea.population,dea.date

SELECT location,MAX(Total_fully_vaccinated/Population)*100 AS fully_vaccinated_percentage 
FROM #fully_vaccinated_people
GROUP BY location
ORDER BY MAX(Total_fully_vaccinated/Population)*100 DESC;

                      
					  
					  
					  --USING CTE--
---- To find the African country with the highest percentage of fully vaccinated people--

WITH FullyVaccinatedPopulation AS (
                                   SELECT dea.location locations,dea.continent continent,dea.date date,dea.population total_population, CAST(MAX(vac.people_fully_vaccinated) AS int) Total_fully_vaccinated
                                   FROM CovidDeaths dea
                                   JOIN CovidVaccinations vac
                                   ON dea.location=vac.location AND dea.date=vac.date
                                   GROUP BY dea.location, dea.population,dea.date,dea.continent
                                   )
SELECT locations,continent, total_population,MAX((Total_fully_vaccinated*1.0)/total_population)*100 AS fully_vaccinated_percentage 
FROM FullyVaccinatedPopulation
GROUP BY locations,continent, total_population
HAVING continent='Africa' AND (MAX((Total_fully_vaccinated*1.0)/total_population)*100)>50





         -- Creating View to store data for later visualizations--

Create View PercentageFullyVaccinatedPopulation as
SELECT dea.location,dea.population, MAX(vac.people_fully_vaccinated) Total_fully_vaccinated,(CAST(MAX(vac.people_fully_vaccinated) AS int)*1.0/dea.population)*100 AS fully_vaccinated_ratio
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.location IS NOT NULL
GROUP BY dea.location,dea.population;