SELECT TOP 5 *
FROM portfolio_project..[CovidDeaths.xlsx - CovidDeaths];

SELECT TOP 5 *
FROM portfolio_project..CovidVaccinations;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolio_project..[CovidDeaths.xlsx - CovidDeaths]
ORDER BY location, date;

SELECT location, date, total_cases, total_deaths, 
	ROUND(CAST(total_deaths AS FLOAT) / total_cases, 2) AS death_rate
FROM portfolio_project..[CovidDeaths.xlsx - CovidDeaths]
ORDER BY 4 DESC;

SELECT TOP 10 location, population, MAX(total_cases) as maxtotalcases, 
	MAX(CAST(total_cases * 100.0 AS FLOAT) / population) AS maxcovideperc
FROM portfolio_project..[CovidDeaths.xlsx - CovidDeaths]
GROUP BY location, population
ORDER BY maxcovideperc DESC;

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
	(CAST(SUM(new_deaths)AS FLOAT) / SUM(new_cases)) *100 AS deathperc
FROM portfolio_project..[CovidDeaths.xlsx - CovidDeaths]
WHERE continent IS NOT NULL
order BY 1,2;

SELECT continent, MAX(CAST(total_deaths AS int)) AS maxtotaldeath
FROM portfolio_project..[CovidDeaths.xlsx - CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY continent
HAVING MAX(CAST(total_deaths AS int)) IS NOT NULL
ORDER BY maxtotaldeath desc; 


SELECT location, MAX(CAST(total_deaths AS int)) AS maxtotaldeath
FROM portfolio_project..[CovidDeaths.xlsx - CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY location
HAVING MAX(CAST(total_deaths AS int)) IS NOT NULL
ORDER BY maxtotaldeath desc; 


SELECT *
FROM portfolio_project..[CovidDeaths.xlsx - CovidDeaths] AS dea
JOIN portfolio_project..CovidVaccinations AS vac
ON dea.location = vac.location
	AND dea.date = vac.date;


WITH popvsvac (continent, location, date, population, new_vaccination, rollvacc)
AS
(
SELECT dea.continent, dea.location, dea.date, 
	dea.population, vac.new_vaccinations, 
	SUM(VAC.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollvacc
FROM portfolio_project..[CovidDeaths.xlsx - CovidDeaths] AS dea
JOIN portfolio_project..CovidVaccinations AS vac
ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (CAST(rollvacc AS float) / population) * 100 AS rollvacperc
FROM popvsvac


DROP TABLE IF EXISTS population_vacc
CREATE TABLE population_vacc
(
continent varchar(50),
location varchar(50),
date date,
population numeric,
new_vaccinations numeric,
rollvacc numeric
);
INSERT INTO population_vacc
SELECT dea.continent, dea.location, dea.date, 
	dea.population, vac.new_vaccinations, 
	SUM(VAC.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollvacc
FROM portfolio_project..[CovidDeaths.xlsx - CovidDeaths] AS dea
JOIN portfolio_project..CovidVaccinations AS vac
ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
SELECT *, (CAST(rollvacc AS float) / population) * 100 AS rollvacperc
FROM population_vacc;

CREATE VIEW vaccpercentage AS 
SELECT dea.continent, dea.location, dea.date, 
	dea.population, vac.new_vaccinations, 
	SUM(VAC.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollvacc
FROM portfolio_project..[CovidDeaths.xlsx - CovidDeaths] AS dea
JOIN portfolio_project..CovidVaccinations AS vac
ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;