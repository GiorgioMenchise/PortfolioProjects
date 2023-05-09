Select *
From	PortfolioProjects..CovidDeaths
order by 3,4

--Select *
--From	PortfolioProjects..CovidVaccinations
--order by 3,4

-- SELECT DATA THAT WE ARE GOING TO BE USING

Select Location, date, total_cases, new_cases, total_deaths, population
From	PortfolioProjects..CovidDeaths
order by 1,2


-- LOOKING AT THE TOTAL CASES VS TOTAL DEATH
-- show likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From	PortfolioProjects..CovidDeaths
Where location like '%italy%'
order by 1,2


-- LOOKING AT THE TOTAL CASES VS THE POPULATION
-- shows what percentage of population got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
From	PortfolioProjects..CovidDeaths
Where location like '%italy%'
order by 1,2


-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionPercentage
From	PortfolioProjects..CovidDeaths
Group by Location, population
order by InfectionPercentage desc


-- SHOWING THE COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION
-- casted the total deaths since in the table the data type was nvarchar

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From	PortfolioProjects..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From	PortfolioProjects..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- SHOWING THE CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From	PortfolioProjects..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
where continent is not null
--group by date 
order by 1,2


-- JOINING COVIDDEATHS AND COVIDVACCINATION TABLES 

Select *
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date

-- LOOKING TOTAL POPULATION VS VACCINATIONS

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated, 
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3


-- USE CTE
-- We can use now the past query to make further calculations

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationRatio
From PopvsVac


-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated --Useful for possible alteration of Temp Table
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationRatio
From #PercentPopulationVaccinated



-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

Create View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated