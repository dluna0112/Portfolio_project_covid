--Select observations to be used.
SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM Portfolio_project_1.dbo.covid_deaths
WHERE continent is not NULL
ORDER BY Location,date


-- Filtered by Country

-- Display death rate by location and date
SELECT Location,date, total_cases,total_deaths, ROUND((total_deaths/ total_cases) *100,2) AS percent_of_deaths
FROM Portfolio_project_1.dbo.covid_deaths
WHERE continent is not NULL
ORDER BY Location,date 


--Display percent of infected population
SELECT Location,date, population, total_cases, ROUND((total_cases/ population) *100,2) AS percent_of_infected
FROM Portfolio_project_1.dbo.covid_deaths
WHERE continent is not NULL
ORDER BY Location, Date DESC

--Display the highest infection count and percentage per location
SELECT Location,population,Max(total_cases) AS infected_citizens, Max((total_cases/population))*100 AS percent_population_infected
FROM Portfolio_project_1.dbo.covid_deaths
WHERE continent is not NULL
GROUP BY Location,population
ORDER BY percent_population_infected DESC

--Display top 10 country's with the highest infection count
SELECT TOP 10 Location,population, MAX(total_cases) AS infected_citizens,MAX((total_cases/population))*100 As percent_population_infected
FROM Portfolio_project_1.dbo.covid_deaths
WHERE continent is not NULL
Group BY Location,population
Order BY percent_population_infected DESC

--Display top 10 country's with the lowest infection  count
SELECT TOP 10 Location,population, MAX(total_cases) AS infected_citizens,MAX((total_cases/population))*100 As percent_population_infected
FROM Portfolio_project_1.dbo.covid_deaths
WHERE continent is not NULL
Group BY Location,population
Having MAX(total_cases) is not NUll
Order BY percent_population_infected 

--Display total deaths by country.
SELECT Location,Max(total_cases)as total_case,Max(Cast(total_deaths as int)) as death_count
FROM Portfolio_project_1.dbo.covid_deaths
WHERE continent is not NULL
GROUP BY Location
ORDER BY death_count DESC


-- Filtered by Continent

--Display total deaths by continent
SELECT Location, Max(total_cases)as total_cases, Max(Cast(total_deaths as int)) as death_count
FROM Portfolio_project_1.dbo.covid_deaths
WHERE continent is NULL and location != 'World'
GROUP BY location
ORDER BY death_count DESC


-- Filtered Globally

--Display deaths by date

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS death_count, SUM(CAST(new_deaths as int))/SUM(new_cases)* 100 as death_percentage
FROM Portfolio_project_1.dbo.covid_deaths
WHERE continent is not NUll
GROUP BY date
Order BY date 


--Look at total population and vaccines

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION by deaths.location ORDER BY deaths.location,deaths.date) AS rolling_vacc
FROM Portfolio_project_1.dbo.covid_deaths AS deaths
JOIN Portfolio_project_1.dbo.covid_vaccinations AS vacc
	ON deaths.Location =vacc.location 
	and deaths.date = vacc.date
WHERE deaths.continent is not NULL
ORDER BY  deaths.location, deaths.date DESC


--USE CTE
-- Allows us to use created column in a query

With popvsvacc (continent,location,date,population,new_vaccinations,rolling_vacc)
AS
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION by deaths.location ORDER BY deaths.location,deaths.date) AS rolling_vacc
FROM Portfolio_project_1.dbo.covid_deaths AS deaths
JOIN Portfolio_project_1.dbo.covid_vaccinations AS vacc 
	ON deaths.Location =vacc.location 
	and deaths.date = vacc.date
WHERE deaths.continent is not null)
Select *, (rolling_vacc/population)*100 AS percent_population_vaccinated
From popvsvacc


