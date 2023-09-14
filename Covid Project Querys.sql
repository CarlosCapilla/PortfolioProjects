SELECT *
FROM [Portfolio Project]..CovidDeaths$
Where continent is not null
order by 3,4

--select * 
--from [Portfolio Project]..CovidVaccinations$
--order by 3,4

--Select data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, [ population]
FROM [Portfolio Project]..CovidDeaths$
order by 1,2


-- Looking at the total cases vs Total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeatPercentage
FROM [Portfolio Project]..CovidDeaths$
Where Location = 'United States'
order by 1,2


--Looking at total Cases vs Population
--Shows what percentage of population got covid
SELECT location, date, total_cases, [ population], (total_cases/[ population])*100 as DeatPercentage
FROM [Portfolio Project]..CovidDeaths$
Where Location = 'Spain'
order by 1,2


--Looking at countries with highest Infection Rate compared to population
SELECT location, MAX(total_cases), [ population], MAX((total_cases/[ population]))*100 as Poplationinfected
FROM [Portfolio Project]..CovidDeaths$
group by [ population], location
order by Poplationinfected DESC


--Showing the countries with the highest death count per Population
SELECT Location, MAX(cast(total_deaths as int)) as totaldeathcount
FROM [Portfolio Project]..CovidDeaths$
Where continent is not null
group by location
order by totaldeathcount DESC


--Let's break things down by continent
--Showing the continents with the biggest death counts 


SELECT location, MAX(cast(total_deaths as int)) as totaldeathcount
FROM [Portfolio Project]..CovidDeaths$
Where continent is  null
group by location
order by totaldeathcount DESC

SELECT continent, MAX(cast(total_deaths as int)) as totaldeathcount
FROM [Portfolio Project]..CovidDeaths$
Where continent is  not null
group by continent
order by totaldeathcount DESC



-- GLOBAL NUMBERS 

SELECT  SUM(new_cases) as totalcases, Sum(cast(new_deaths as int)) as totaldeaths,
 sum(cast(New_deaths as int))/Sum(new_cases)*100 as DeatPercentage
FROM [Portfolio Project]..CovidDeaths$
--Where Location = 'United States'
Where continent is not null
--group by date 
order by 1,2


--Looking at total population vs vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.[ population], vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
as VACSPERCOUNTRY
FROM [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--USE CTE 

with PopvsVac(continent, location, date, population, New_vaccinations, VACSPERCOUNTRY)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.[ population], vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
as VACSPERCOUNTRY
FROM [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)

Select *, (VACSPERCOUNTRY/population)*100
From PopvsVac


--TEMP TABLE

DROP Table if exists #percentpopulationvaccinated
Create table #Percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
VACSPERCOUNTRY numeric
)



Insert into #Percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.[ population], vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date)
as VACSPERCOUNTRY
FROM [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

Select *, (VACSPERCOUNTRY/population)*100
From #Percentpopulationvaccinated



--Create View to store data for later visualization

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.[ population], vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
as VACSPERCOUNTRY
FROM [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


Select *
From PercentPopulationVaccinated


--Creating a temp table for the vaccinated people in spain

Drop table if exists #poblacionvacunada
create table #PoblacionVacunada
(Continent nvarchar(255),
location nvarchar(255),
date datetime,
population decimal,
new_vaccinations decimal,
Nºdevacunados decimal
)

Insert into #PoblacionVacunada
SELECT dea.continent, dea.location, dea.date, dea.[ population], vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
as Nºdevacunados
FROM [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null and dea.location = 'Spain'
order by 2,3

Select *, (Nºdevacunados/population)*100 as '% de vacunados'
from #PoblacionVacunada 



