/*
Cleaning Data in SQL queries
*/
select * from NashVilleHousing

--Standrize Date Format
select SaleDate,CONVERT(date,SaleDate) as 'Standrized Date'
from NashVilleHousing


Alter Table NashVilleHousing
add SalesDateConverted Date;

Update NashVilleHousing
set SalesDateConverted=CONVERT(date,SaleDate)

select SalesDateConverted from NashVilleHousing


-- Populate Property Address Data

select * from NashvilleDataBase.dbo.NashVilleHousing

--Where PropertyAddress is null

order by ParcelID

Select a.ParcelID , a.PropertyAddress ,  b.ParcelID ,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleDataBase.dbo.NashVilleHousing a
Join  NashvilleDataBase.dbo.NashVilleHousing b
	On a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleDataBase.dbo.NashVilleHousing a
Join  NashvilleDataBase.dbo.NashVilleHousing b
	On a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking address into Seperated columns (Address,City,State)

Select propertyaddress
from NashVilleHousing


Select  SUBSTRING(PropertyAddress,1,CHARINDEX(',',propertyaddress)-1) as Street
,SUBSTRING(PropertyAddress,CHARINDEX(',',propertyaddress)+1,LEN(propertyaddress)) as City

from NashVilleHousing


Alter Table NashVilleHousing
add Street nvarchar(255);

Update NashVilleHousing
set Street = SUBSTRING(PropertyAddress,1,CHARINDEX(',',propertyaddress)-1)

Alter Table NashVilleHousing
add City nvarchar(255);

Update NashVilleHousing
Set City = SUBSTRING(PropertyAddress,CHARINDEX(',',propertyaddress)+1,LEN(propertyaddress))

-------------------------------------------------------------
--Let's break owner address too --
select OwnerAddress
from NashvilleDataBase.dbo.NashVilleHousing

Select  Parsename(replace(owneraddress,',','.'),3)
, Parsename(replace(owneraddress,',','.'),2)
, Parsename(replace(owneraddress,',','.'),1)
from NashvilleDataBase.dbo.NashVilleHousing


Alter Table NashVilleHousing
add OwnerStreet nvarchar(255);

Update NashVilleHousing
set OwnerStreet =   Parsename(replace(owneraddress,',','.'),3)

Alter Table NashVilleHousing
add OwnerCity nvarchar(255);

Update NashVilleHousing
set OwnerCity =   Parsename(replace(owneraddress,',','.'),2)

Alter Table NashVilleHousing
add OwnerState nvarchar(255);

Update NashVilleHousing
set OwnerState =    Parsename(replace(owneraddress,',','.'),1)

select * from NashVilleHousing

--Replace Y and N to Yes and No in SoldAsVacant field--

Select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from NashVilleHousing
group by SoldAsVacant
order by 2 desc

Select soldasvacant
,case when SoldAsVacant='Y' Then 'Yes'
	  when SoldAsVacant='N' Then 'No'
	  Else SoldAsVacant
	  end
from NashVilleHousing


Update NashVilleHousing
set SoldAsVacant = case when SoldAsVacant='Y' Then 'Yes'
	  when SoldAsVacant='N' Then 'No'
	  Else SoldAsVacant
	  end

--Remove Duplicates--
with rownumcte as (
select *,
		ROW_NUMBER() over(
		partition by ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						) row_num
				
from NashVilleHousing
)

select * from rownumcte
where row_num>1

/*delete from rownumcte
where row_num>1*/

-------------------------------------------------

--Delete Unused columns--

ALTER TABLE NashVilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

select * from NashVilleHousing

--Handling Missing values--


delete  from NashVilleHousing
where OwnerName is null


Select * from NashVilleHousing

-------------------------------------------------------
-- replace the missing value with the most repeated value (MODE) for the next columns --

update NashVilleHousing 
set YearBuilt = case when YearBuilt is null then (
		select top 1 YearBuilt
		from NashVilleHousing
		group by YearBuilt
		order by count(YearBuilt) desc)
		else YearBuilt
	  end


-------------------------------------------------------
update NashVilleHousing 
set Bedrooms = case when Bedrooms is null then (
		select top 1 Bedrooms
		from NashVilleHousing
		group by Bedrooms
		order by count(Bedrooms) desc)
		else Bedrooms
	  end
--------------------------------------------------------
update NashVilleHousing 

set FullBath = case when FullBath is null then (
		select top 1 FullBath
		from NashVilleHousing
		group by FullBath
		order by count(FullBath) desc)
		else FullBath
	  end

------------------------------------------------------------------

update NashVilleHousing 

set HalfBath = case when HalfBath is null then (
		select top 1 HalfBath
		from NashVilleHousing
		group by HalfBath
		order by count(HalfBath) desc)
		else HalfBath
	  end

select * from NashVilleHousing
where City<>OwnerCity

---------------------------------------------------------------

--The most landuse type used--

select distinct(landuse) , count(LandUse) as TheNumberofUsage
from NashVilleHousing
group by LandUse
order by TheNumberofUsage DESC

--SINGLE FAMILY IS THE MOST USED--

--Define how many people want new houses in the same city--

select 
	(count(case when city=ownercity then 1 end)*100.0)/COUNT(*) as percentage

from NashVilleHousing

--So 99.996% of the people buy new Houses the same city--

--Define how many people want new houses in the same street--

select 
	(count(case when Street=OwnerStreet then 1 end)*100.0)/COUNT(*) as percentage

from NashVilleHousing
--So 81.09% of the people buy new Houses the same street--


--Let's show each value in each column that might has relation with the highest sale price--

select top 1 *
from NashVilleHousing
order by SalePrice desc

--Result--

-- 20136	073 00 0 007.00	VACANT RESIDENTIAL LAND	12350000	20140818-0074498	No	CATHOLIC DIOCESE OF NASHVILLE	3	50000	0	50000	1950	3	2	0	2014-08-15	2812  MCGAVOCK PIKE	 NASHVILLE	2812  MCGAVOCK PIKE	 NASHVILLE	 TN --
