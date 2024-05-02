Select *
From PortofolioProject..CovidDeaths
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortofolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortofolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

-- Total Cases vs Population
Select location, date, population, total_cases , (cast(total_cases as float)/cast(population as float))*100 as PercentagePopulationInfected
From PortofolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select location, population, Max(total_cases) as HighestInfectionCount, Max((cast(total_cases as float)/cast(population as float)))*100 as PercentagePopulationInfected
From PortofolioProject..CovidDeaths
Group by location, population
order by PercentagePopulationInfected desc

Select location, population,date, Max(total_cases) as HighestInfectionCount, Max((cast(total_cases as float)/cast(population as float)))*100 as PercentagePopulationInfected
From PortofolioProject..CovidDeaths
Group by location, population, date
order by PercentagePopulationInfected desc

-- Countries with Highest Death Count per Population
Select location,  max(cast(total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
Where continent is null
and location not in('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 
'Low income')
Group by location
order by TotalDeathCount desc

-- Showing continent with the highest death count per population
Select continent,  max(cast(total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS 
Select
           Sum(new_cases) as total_cases,
		   Sum(cast(new_deaths as int)) as total_deaths,
		   CASE
		       WHEN Sum(new_cases) = 0 Then null
			   ELSE Sum(cast(new_deaths as int))/Sum(new_cases)*100
			   END as DeathPercentage
From PortofolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Total Population vs Vaccinations 
With PopvsVac(continent, location, date, population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast( vac.new_vaccinations as bigint)) over (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated /population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
--order by  2, 3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast( vac.new_vaccinations as bigint)) over (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated /population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by  2, 3
Select *, (RollingPeopleVaccinated/population)*100
From  #PercentPopulationVaccinated

USE PortofolioProject;
DROP VIEW IF EXISTS PercentPopulationVaccinated;

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast( vac.new_vaccinations as bigint)) over (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated /population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
     --order by  2, 3
	 
Select * 
From PercentPopulationVaccinated