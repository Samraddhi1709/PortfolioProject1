Select*
From PortfolioProject..CovidDeaths
Order By 3,4

--Select*
--From PortfolioProject..CovidVaccinations
--Order By 3,4

--Looking at %death of your country
Select Location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location='India'
Order By 1,2


--Total case vs Population
Select Location, date,total_cases, population, (total_cases/population)*100 as caseVSpoplation
From PortfolioProject..CovidDeaths
where location='India'
Order By 1,2


--looking at the maximum totl cases per countries alomg with max cases vs population infected percentage
Select Location,population,Max(total_cases) as MaxCasesCount, max(total_cases/population)*100 as MaxcaseVSpoplation
From PortfolioProject..CovidDeaths
Group By Location, population
Order By MaxcaseVSpoplation desc


--looking at the maximum deaths per countries
Select Location,Max(cast(total_deaths as INT)) as MaxDeathCount     --cast as int is used to chage the datatype from navchar to int
From PortfolioProject..CovidDeaths
Group By location
Order By MaxDeathCount desc   --this is also giving continents answers along with the contries so in need to remove them we check the data 
                              -- and we find that when location is a continnent then there the value of continent coln is null


Select Location,Max(cast(total_deaths as INT)) as MaxDeathCount   
From PortfolioProject..CovidDeaths
Where continent is not null     --will not include the continents
Group By location
Order By MaxDeathCount desc  
                            
							--LET'S BREAK THINGS BY CONTINENTS

--Showing continents with highest death count per population

Select continent,Max(cast(total_deaths as INT)) as MaxDeathCount   
From PortfolioProject..CovidDeaths
Where continent is not null     
Group By continent
Order By MaxDeathCount desc  

Select Location,Max(cast(total_deaths as INT)) as MaxDeathCount   
From PortfolioProject..CovidDeaths
Where continent is null     --will include only the continents
Group By location
Order By MaxDeathCount desc  


--TAKING THINGS GLOBALLY

--Deaths count per day globally

Select date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2

Select date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date,total_cases,total_deaths
Order By 1,2

Select date, sum(new_cases) as Total_newcase, SUM(cast(new_deaths as INT)) as Total_newdeaths,(SUM(cast(new_deaths as INT))/sum(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Having sum(new_cases)> 0
Order By 1

--JOINING BOTH TABLES
Select*
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  ON dea.location=vac.location
  AND dea.date=vac.date

--Looking at total new vaccinations and population

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  ON dea.location=vac.location
  AND dea.date=vac.date
  Where dea.continent is not null
  order by 2,3

  --Looking at total new vaccinations count with date and location

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,dea.date ) as VaccineCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  ON dea.location=vac.location
  AND dea.date=vac.date
  Where dea.continent is not null
  GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  order by 2,3



  --CREATING CME  BECAUSE I NEED  TO KNOW THE VACCINECOUNT VS POPULATION % SO FOR THAT FIRST I NEED TO STORE LL THE NEWVACCINR AND THEN ONLY I CAN USE ANY FUNCTION

  With VACCvsPOP( continent, location,date,population,new_vaccinations, VaccineCount)
  as (
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.date ) as VaccineCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  ON dea.location=vac.location
  AND dea.date=vac.date
  Where dea.continent is not null
  GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  )
  Select *, (VaccineCount/population)*100 as vacVSpop
  From VACCvsPOP

  -- Doing same thing by creating temp table

  DROP TABLE IF EXISTS #PercentagePeopleVaciinated
 CREATE TAble #PercentagePeopleVaciinated
 ( continent nvarchar(250),
 location nvarchar(250),
 date datetime,
 population numeric,
 new_vaccinations int, 
 VaccineCount int
 )

  INSERT INTO #PercentagePeopleVaciinated

  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.date ) as VaccineCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  ON dea.location=vac.location
  AND dea.date=vac.date
  Where dea.continent is not null
  GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  ORDER BY 2,3

  Select *, (VaccineCount/population)*100 as vacVSpop
  From #PercentagePeopleVaciinated

  --CREATING VIEWS TO STORE DATA FOR VISULIZATIONS
USE PortfolioProject
GO
Create view PercentagePeopleVaciinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
--sum(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.date ) as VaccineCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  ON dea.location=vac.location
  AND dea.date=vac.date
  Where dea.continent is not null
  GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  --ORDER BY 2,3