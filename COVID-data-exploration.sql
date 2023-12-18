-- VIEWING COVID DEATHS DATA
SELECT *
FROM SQLProjects.dbo.CovidDeaths$ AS cd
ORDER BY location;

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM SQLProjects.dbo.CovidDeaths$
ORDER BY Location, date;

-- COMPARING TOTAL_CASES WITH TOTAL_DEATHS
-- SHOWS LIKELIHOOD OF SURVIVING COVID IN A LISTED COUNTRY
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_pct
FROM SQLProjects.dbo.CovidDeaths$
ORDER BY Location, date;

-- LET'S SEE THE CONDITION IN INDIA
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_pct
FROM SQLProjects.dbo.CovidDeaths$
WHERE location LIKE '%INDIA%'
ORDER BY Location, date;

-- LOOKING AT THE PERCENTAGE OF INFECTED PEOPLE(TOTAL_CASES VS POPULATION) IN INDIA
SELECT Location, date, Population, total_cases, (total_cases/Population)*100 AS infected_pct
FROM SQLProjects.dbo.CovidDeaths$
WHERE location LIKE '%INDIA%'
ORDER BY Location, date;

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATES
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population)*100) AS maxinfected_pct
FROM SQLProjects.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY maxinfected_pct DESC;

-- SHOWS DEATH COUNT PER COUNTRY
SELECT Location, MAX(total_deaths) AS DeathCount
FROM SQLProjects.dbo.CovidDeaths$
WHERE continent IS NOT NULL -- LOCATION HAS CONTINENT NAME AS CELL VALUES AND THIS REMOVES THEM
GROUP BY Location
ORDER BY DeathCount DESC;

-- WORKING WITH CONTINENTS
-- SHOWS DEATH COUNT PER CONTINENT
SELECT location, MAX(total_deaths) AS DeathCount
FROM SQLProjects.dbo.CovidDeaths$
WHERE continent IS NULL AND location NOT IN ('World', 'High income', 'Upper middle income', 'European Union', 'Lower middle income', 'Low income', 'Oceania')
-- WHERE LOCATION NOT IN ('World', 'High income', 'Upper middle income', 'European Union', 'Lower middle income', 'Low income', 'Oceania')
GROUP BY location
ORDER BY DeathCount DESC;

-- GLOBAL NUMBERS
-- RISE OF COVID ON A DAILY BASIS WORLDWIDE
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
CASE
    WHEN SUM(new_cases) = 0 THEN 0
    WHEN SUM(new_cases) > 0 THEN SUM(new_deaths)/SUM(new_cases)*100
END AS death_pct
FROM SQLProjects.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- TOTAL CASES AND DEATHS TILL DATE
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
CASE
    WHEN SUM(new_cases) = 0 THEN 0
    WHEN SUM(new_cases) > 0 THEN SUM(new_deaths)/SUM(new_cases)*100
END AS death_pct
FROM SQLProjects.dbo.CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2;

SELECT *
FROM SQLProjects.dbo.CovidDeaths$;

-- JOIN BOTH THE TABLES
SELECT *
FROM SQLProjects.dbo.CovidDeaths$ dea
JOIN SQLProjects.dbo.CovidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date;

-- TOTAL POPULATION VS VACCINATION
WITH PopvsVac(continent, location, date, population, new_vaccination, VaccinatedRolingCount)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, CAST(vac.new_vaccinations AS bigint),
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinatedRollingCount
FROM SQLProjects.dbo.CovidDeaths$ dea
JOIN SQLProjects.dbo.CovidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE DEA.continent IS NOT NULL
)
SELECT *, (VaccinatedRolingCount/population)*100 AS vaccinated_pct
FROM PopvsVac;

-- USING TEMP TABLE TO PERFORM CALCULATION ON PARTITION BY IN PREVIOUS QUERY
DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM SQLProjects.dbo.CovidDeaths$ dea
JOIN SQLProjects.dbo.CovidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3;

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated;

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM SQLProjects.dbo.CovidDeaths$ dea
JOIN SQLProjects.dbo.CovidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;



-- VIEW FOR PERCENT POPULATION VACCINATED TEMP TABLE
CREATE VIEW ViewPercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM SQLProjects.dbo.CovidDeaths$ dea
JOIN SQLProjects.dbo.CovidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


--ALL VIEWS
-- VIEW FOR COMPARING TOTAL CASES WITH TOTAL DEATHS
CREATE VIEW ViewCompareTotalCasesDeaths AS
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_pct
FROM SQLProjects.dbo.CovidDeaths$


-- VIEW FOR CONDITIONS IN INDIA
CREATE VIEW ViewIndiaConditions AS
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_pct
FROM SQLProjects.dbo.CovidDeaths$
WHERE location LIKE '%INDIA%'

-- VIEW FOR PERCENTAGE OF INFECTED PEOPLE IN INDIA
CREATE VIEW ViewInfectedPctIndia AS
SELECT Location, date, Population, total_cases, (total_cases/Population)*100 AS infected_pct
FROM SQLProjects.dbo.CovidDeaths$
WHERE location LIKE '%INDIA%'

-- VIEW FOR COUNTRIES WITH HIGHEST INFECTION RATES
CREATE VIEW ViewHighestInfectionRates AS
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population)*100) AS maxinfected_pct
FROM SQLProjects.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY Location, Population

-- VIEW FOR DEATH COUNT PER COUNTRY
CREATE VIEW ViewDeathCountPerCountry AS
SELECT Location, MAX(total_deaths) AS DeathCount
FROM SQLProjects.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY Location

-- VIEW FOR DEATH COUNT PER CONTINENT
CREATE VIEW ViewDeathCountPerContinent AS
SELECT location, MAX(total_deaths) AS DeathCount
FROM SQLProjects.dbo.CovidDeaths$
WHERE continent IS NULL AND location NOT IN ('World', 'High income', 'Upper middle income', 'European Union', 'Lower middle income', 'Low income', 'Oceania')
GROUP BY location

-- VIEW FOR GLOBAL NUMBERS
CREATE VIEW ViewGlobalNumbers AS
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
CASE
    WHEN SUM(new_cases) = 0 THEN 0
    WHEN SUM(new_cases) > 0 THEN SUM(new_deaths)/SUM(new_cases)*100
END AS death_pct
FROM SQLProjects.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date

-- VIEW FOR TOTAL CASES AND DEATHS TILL DATE
CREATE VIEW ViewTotalCasesDeathsTillDate AS
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
CASE
    WHEN SUM(new_cases) = 0 THEN 0
    WHEN SUM(new_cases) > 0 THEN SUM(new_deaths)/SUM(new_cases)*100
END AS death_pct
FROM SQLProjects.dbo.CovidDeaths$
WHERE continent IS NOT NULL