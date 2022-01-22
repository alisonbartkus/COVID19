Select *
From COVID19Project..CovidDeaths$
Where continent is not null
Order by 3,4

--Let's analyze COVID infection and deaths by country

--Looking at Total Cases vs Total Deaths
--Shows percentage of those who died after contracting COVID (by country)
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From COVID19Project..CovidDeaths$
Where continent is not null
--Where location like '%states%'
Order by 1,2

--Looking at Total Cases vs Population
--Shows percentage of poulation that were infected with COVID (by country)
Select Location, date, population, total_cases, (total_cases/population)*100 as infection_percentage
From COVID19Project..CovidDeaths$
Where continent is not null
--Where location like '%states%'
Order by 1,2

--Looking at Highest Infection Count compared to Population
--Shows the highest percentage of the population that were infected (by country)
Select Location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as infection_percentage
From COVID19Project..CovidDeaths$
Where continent is not null
--Where location like '%states%'
Group by Location, population
Order by infection_percentage desc

--Looking at Highest Death Count
--Shows the highest death count by country
Select Location, MAX(cast(total_deaths as int)) as total_death_count
From COVID19Project..CovidDeaths$
Where continent is not null
--Where location like '%states%'
Group by Location
Order by total_death_count desc

--Let's analyze COVID infection and deaths by continent

--Looking at Total Cases vs Total Deaths
--Shows percentage of those who died after contracting COVID (by continent)
Select continent, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From COVID19Project..CovidDeaths$
Where continent is not null
Group by continent
Order by death_percentage desc

--Looking at Total Cases vs Population
--Shows percentage of poulation that were infected with COVID (by country)
Select continent, date, population, total_cases, (total_cases/population)*100 as infection_percentage
From COVID19Project..CovidDeaths$
Where continent is not null
Group by continent
Order by infection_percentage desc

--Looking at Highest Infection Count compared to Population
--Shows the highest percentage of the population that were infected (by country)
Select continent, population, MAX((total_cases/population))*100 as infection_percentage
From COVID19Project..CovidDeaths$
Where continent is not null
Group by continent, population
Order by infection_percentage desc

--(1)Looking at Continents with the Highest Death Count
--This does not accurately represent the data but will result in a cleaner visualization with drill-down effect.
--See (2) below for Accurate Representation
Select continent, MAX(cast(total_deaths as int)) as total_death_count
From COVID19Project..CovidDeaths$
Where continent is not null
--Where location like '%states%'
Group by continent
Order by total_death_count desc

--(2) Accurate Representation
--Difficulty using this for Tableau drill-down analysis
Select location, MAX(cast(total_deaths as int)) as total_death_count
From COVID19Project..CovidDeaths$
Where continent is null
--Where location like '%states%'
Group by location
Order by total_death_count desc


--Let's analyze COVID infection and deaths globally

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From COVID19Project..CovidDeaths$
Where continent is not null
Group by date
Order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From COVID19Project..CovidDeaths$
Where continent is not null
--Group by date
Order by 1,2

--Let's analyze total COVID vaccination in the Total Population 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingCount_Vaccinations
, (RollingCount_Vaccinations/population)*100
From COVID19Project..CovidDeaths$ dea
Join COVID19Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

--USE CTE for Percent of Population Vaccinated

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingCount_Vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingCount_Vaccinations
From COVID19Project..CovidDeaths$ dea
Join COVID19Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingCount_Vaccinations/Population)*100
From PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingCount_Vaccinations numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingCount_Vaccinations
From COVID19Project..CovidDeaths$ dea
Join COVID19Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingCount_Vaccinations/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

USE COVID19Project

GO

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingCount_Vaccinations
From COVID19Project..CovidDeaths$ dea
Join COVID19Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null