
Select *
From portfolioproject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From portfolioproject..CovidVaccinations
--order by 3,4

-- Select the data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From portfolioproject..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract COVID in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolioproject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID (in the states)
Select Location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
From portfolioproject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as InfectedPercentage
From portfolioproject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location, population
order by InfectedPercentage desc

-- showing the countries with highest death count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portfolioproject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- breaking things down by continent

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portfolioproject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Numbers arent accurate - NA numbers don't include canada, etc.

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portfolioproject..CovidDeaths
--Where location like '%states%'
Where continent is null
Group by location
order by TotalDeathCount desc

--looks accurate


-- global numbers 


Select date, SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From portfolioproject..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by date
order by 1,2



-- looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RollingPeopleVaccinated
From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- using CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date) 
as RollingPeopleVaccinated
From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- temp table 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255),
Date datetime,
Population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date) 
as RollingPeopleVaccinated
From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- create view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date) 
as RollingPeopleVaccinated
From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated

