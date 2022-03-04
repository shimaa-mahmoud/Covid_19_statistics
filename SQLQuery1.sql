-- WORKING ON THE COUNTRY LEVEL

-- what is the likelihood of dying if you contract covid-19 in Egypt
SELECT  location, date, total_cases, CAST(total_deaths AS INT) AS total_deaths, 
		ROUND(CAST(total_deaths AS INT) / total_cases * 100, 2) AS DeathRate
FROM     covid_19.dbo.CovidDeaths
WHERE   (location = 'Egypt') AND (continent IS NOT NULL)
ORDER BY location, date

-- what is the Percentage of population have covid over time 

--What are the countries with the highest infection rate to the population
SELECT  location, population, MAX(total_cases), MAX(ROUND(total_cases / population * 100, 2)) AS InfectectionRate
FROM     covid_19.dbo.CovidDeaths
WHERE   continent IS NOT NULL
Group By location, population
ORDER BY 4 DESC

--What are the highest death count for each country
SELECT  location, population, MAX(CASt(total_deaths AS INT)) AS death_Count
FROM     covid_19.dbo.CovidDeaths
WHERE   continent IS NOT NULL
Group By location, population
ORDER BY 3 DESC


-- WORKING ON THE CONTINENT LEVEL

-- Showing contintents with the highest death count 
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From covid_19..CovidDeaths
Where (continent is null) and (location in ('Europe', 'Asia','North America','South America','Africa','Oceania','World'))
Group by continent, location 
order by TotalDeathCount desc

-- Showing contintents with the highest infection count 
Select location, MAX(cast(total_cases as int)) as TotalDeathCount
From covid_19..CovidDeaths
Where (continent is null) and (location not in ('Europe', 'Asia','North America','South America','Africa','Oceania','World'))
Group by continent, location 
order by TotalDeathCount desc

-- showing the death rate per population based on the income
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount, MAX(population) as Population,
				Round(MAX(cast(total_deaths as int))/ MAX(population) * 100,2) as DeathRate
From covid_19..CovidDeaths
Where (continent is null) and (location in ('Upper middle income', 'High income','Lower middle income','Low income'))
Group by continent, location 
order by TotalDeathCount desc


-- GLOBAL NUMBERS
SELECT  SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, 
		SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS DeathPercentage
FROM     covid_19.dbo.CovidDeaths
WHERE   (continent IS NOT NULL)
ORDER BY total_cases, total_deaths 

-- Total Population vs Vaccinations

-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_19..CovidDeaths dea
Join covid_19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_19..CovidDeaths dea
Join covid_19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)

Select *, Round((RollingPeopleVaccinated/Population)*100 ,2) As VccinatedRate
From PopvsVac
order by 2,3



-- Creating View to store data for later visualizations

Create View PopulationVaccinatedPercentage as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_19..CovidDeaths dea
Join covid_19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
