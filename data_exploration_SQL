
/* ========================================================================
	quick datasets overview: checking schema, datatypes, nulls
======================================================================== */
	
-- preview first 5 rows from CovidDeaths table to confirm import data
SELECT TOP 5 *
FROM portfolio_project..[CovidDeaths.xlsx - CovidDeaths];

-- preview first 5 rows from CovidVaccination table
SELECT TOP 5 *
FROM portfolio_project..CovidVaccinations;

/* ========================================================================
	basic column selection and sort
======================================================================== */

-- select key fields to observe trends by time
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolio_project..[CovidDeaths.xlsx - CovidDeaths]
ORDER BY location, date;

/* ========================================================================
	calculate death rates
======================================================================== */

-- calculate deaths rate by total_deaths/totalcases and round to 2 decimal
SELECT location, date, total_cases, total_deaths, 
	ROUND((CAST(total_deaths AS FLOAT) / NULLIF(total_cases, 0)), 2) AS death_rate
FROM portfolio_project..[CovidDeaths.xlsx - CovidDeaths]
ORDER BY 4 DESC; -- order by total deaths

/* ========================================================================
	calculate highest infection rate by location
======================================================================== */
-- for each location, find
	-- (1) maximum total infection cases
	-- (2) infection percentage by calculating (total_cases / population) * 100.0
SELECT TOP 10 location, population, MAX(total_cases) as maxtotalcases, 
	MAX(CAST(total_cases * 100.0 AS FLOAT) / population) AS maxcovidperc
FROM portfolio_project..[CovidDeaths.xlsx - CovidDeaths]
GROUP BY location, population
ORDER BY maxcovidperc DESC; -- showing 10 locations with highest infection rate

/* =========================================================================
    calculate global totals using daily new values
========================================================================= */
-- aggregate global new cases and deaths
-- calculate deathperc (global) by new_deaths / new_cases *100.0
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
	(CAST(SUM(new_deaths)AS FLOAT) / SUM(new_cases)) *100.0 AS deathperc
FROM portfolio_project..[CovidDeaths.xlsx - CovidDeaths]
WHERE continent IS NOT NULL; -- prevent double calculating continent & global summary

/* =========================================================================
    maximum deaths by continent and country
========================================================================= */
-- find and order by maximum total deaths by continent
SELECT continent, MAX(CAST(total_deaths AS int)) AS maxtotaldeath
FROM portfolio_project..[CovidDeaths.xlsx - CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY continent
HAVING MAX(CAST(total_deaths AS int)) IS NOT NULL
ORDER BY maxtotaldeath desc; 

-- find and order by maximum total deaths by country(location)
SELECT location, MAX(CAST(total_deaths AS int)) AS maxtotaldeath
FROM portfolio_project..[CovidDeaths.xlsx - CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY location
HAVING MAX(CAST(total_deaths AS int)) IS NOT NULL
ORDER BY maxtotaldeath desc; 


/* =========================================================================
    join deaths and vaccination tables
========================================================================= */

-- join tables on location and date
SELECT *
FROM portfolio_project..[CovidDeaths.xlsx - CovidDeaths] AS dea
JOIN portfolio_project..CovidVaccinations AS vac
ON dea.location = vac.location
	AND dea.date = vac.date;


/* =========================================================================
    CTE: rolling population vs vaccination rate 
========================================================================= */
-- using CTE to calculate cumulative vaccination by location
WITH popvsvac (continent, location, date, population, new_vaccination, rollvacc) -- create temp table for partition
AS
(
SELECT dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(VAC.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollvacc 
		-- using window function: calculate daily cumulative vaccination by location
FROM portfolio_project..[CovidDeaths.xlsx - CovidDeaths] AS dea
JOIN portfolio_project..CovidVaccinations AS vac
ON dea.location = vac.location 
	AND dea.date = vac.date -- join two tables
WHERE dea.continent IS NOT NULL -- exclude summary raw
--ORDER BY 2, 3 
)
SELECT *, (CAST(rollvacc AS float) / population) * 100 AS rollvacperc -- calculate cumulative vaccination percentage
FROM popvsvac;

/* =========================================================================
    create physical table to store results
========================================================================= */
-- drop table if it already exist
DROP TABLE IF EXISTS population_vacc
-- create new table
CREATE TABLE population_vacc
(
continent varchar(50),
location varchar(50),
date date,
population numeric,
new_vaccinations numeric,
rollvacc numeric
);
-- insert calculated data 
INSERT INTO population_vacc
SELECT dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(VAC.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollvacc
FROM portfolio_project..[CovidDeaths.xlsx - CovidDeaths] AS dea
JOIN portfolio_project..CovidVaccinations AS vac
ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- query table and calculate vaccination rate by rollvac/population *100
SELECT *, (CAST(rollvacc AS float) / population) * 100 AS rollvacperc
FROM population_vacc;

/* =========================================================================
    create view for reuse
========================================================================= */
-- create view for storing query definition, join, and rolling calculation
CREATE VIEW vaccpercentage AS 
SELECT dea.continent, dea.location, dea.date, 
	dea.population, vac.new_vaccinations, 
	SUM(VAC.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollvacc
FROM portfolio_project..[CovidDeaths.xlsx - CovidDeaths] AS dea
JOIN portfolio_project..CovidVaccinations AS vac
ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
