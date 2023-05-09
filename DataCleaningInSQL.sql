/*

	CLEANING DATA IN SQL QUERIES

*/

Select *
From PortfolioProjects..NashvilleHousing

--------------------------------------------------------------------

-- STANDARDIZE DATE FORMAT

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProjects..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--------------------------------------------------------------------

-- POPULATE PROPERTY ADDRESS DATA
-- Since some ID have NULL Address, we populate those taking from other IDs that have the same ParcelID

Select *
From PortfolioProjects..NashvilleHousing
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a -- if you have a join in the update you have to specify the alias
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------

-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

Select PropertyAddress
From PortfolioProjects..NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProjects..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

Select *
From PortfolioProjects..NashvilleHousing

Select OwnerAddress
From PortfolioProjects..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as City,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) as State
From PortfolioProjects..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From PortfolioProjects..NashvilleHousing

--------------------------------------------------------------------

-- CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProjects..NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
CASE when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 else SoldAsVacant
	 end
From PortfolioProjects..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant=CASE when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 else SoldAsVacant
	 end

--------------------------------------------------------------------

-- REMOVE DUPLICATES

WITH RowNumCTE as (
Select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
From PortfolioProjects..NashvilleHousing
)

DELETE
From RowNumCTE
where row_num > 1

--------------------------------------------------------------------

-- DELETE UNUSED COLUMNS

Select *
From PortfolioProjects..NashvilleHousing

ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN SaleDate