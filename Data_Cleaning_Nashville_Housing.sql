-- Cleaning Data in SQL Queries

select * from PortfolioProject.dbo.NashvilleHousing

-------------------------

--Standardize Date format
select SaleDate, CONVERT(date, saledate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate= CONVERT(date, saledate)

alter table NashvilleHousing
add SaleDateConverted date;

Update NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate)

select SaleDateConverted, CONVERT(date, saledate)
from PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------
--Populate Property address data

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelId, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
-- <> is not equal to
where a.PropertyAddress is null


UPDATE a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-----------------------------------------------------------
--breaking out address into individual columns(address, city, state)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select 
substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress nvarchar(255);


Update PortfolioProject.dbo.NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) 

alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitCity nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousing


select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select
PARSENAME(replace(OwnerAddress, ',', '.'),3),
PARSENAME(replace(OwnerAddress, ',', '.'),2),
PARSENAME(replace(OwnerAddress, ',', '.'),1)  
from PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress nvarchar(255);
Update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'),3)

alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitCity nvarchar(255);
update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'),2)


alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitState nvarchar(255);
update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'),1) 

----------------------------------------------------------
--change Y & N to yes and no in "sold as vacant" field
select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
else SoldAsVacant
end
from PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
else SoldAsVacant
end

------------------------------------------------------------------
-- Remove duplicates
with RowNumCTE AS(
select *,
ROW_NUMBER() over (
partition by ParcelId, PropertyAddress, SalePrice, SaleDate, LegalReference
order by  UniqueID) row_num
from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)

Select * from RowNumCTE
where row_num>1
order by PropertyAddress

----------------------------------------------------------------
--Delete unused columns
select * 
from PortfolioProject.dbo.NashvilleHousing
alter table PortfolioProject.dbo.NashvilleHousing 
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject.dbo.NashvilleHousing 
drop column SaleDate



