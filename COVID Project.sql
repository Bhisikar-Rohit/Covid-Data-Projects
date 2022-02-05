Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage      
From PortfolioProject..CovidDeaths
Where location like '%India%'
and continent is not null
Order by 1,2


--Looking at Total Cases vs Population 
--Shows what percentage of population got Covid

Select Location, date,  population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected      
From PortfolioProject..CovidDeaths
Where location like '%India%'
Order by 1,2


--Looking at Countries with Higest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected   
From PortfolioProject..CovidDeaths
--Where location like '%India%'
Group by Location, population
Order by PercentagePopulationInfected desc


-- Showing Countries with Higest Death Count per Population 

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%India%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT



-- Showing continents with the highest death count per population

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%India%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc



--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, Sum(Cast(new_deaths as int)) as total_deaths, Sum(Cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage      
From PortfolioProject..CovidDeaths
--Where location like '%India%'
Where continent is not null
--Group by date
Order by 1,2

--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
order by 2, 3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3
)
select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABlE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Locatoin nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric 
)


Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
--Where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to Store data for later visualizations


CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *
From PercentPopulationVaccinated

