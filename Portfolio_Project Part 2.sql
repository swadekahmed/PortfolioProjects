/*

Cleaning Data in SQL Queries

*/

Select *
From [Portfolio Project]..NashvilleHousing


---------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT (Date, SaleDate)
From [Portfolio Project].dbo.NashvilleHousing

Update [Portfolio Project].dbo.NashvilleHousing
SET SaleDate = CONVERT (Date, SaleDate)

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
Add SaleDateConverted Date;

Update [Portfolio Project].dbo.NashvilleHousing
SET SaleDateConverted = CONVERT (Date, SaleDate)



------------------------------------------------------------------

-- Populate Property Address Data

Select *
From [Portfolio Project].dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project].dbo.NashvilleHousing a
JOIN [Portfolio Project].dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project].dbo.NashvilleHousing a
JOIN [Portfolio Project].dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is null


---------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From [Portfolio Project].dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From [Portfolio Project].dbo.NashvilleHousing


ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update [Portfolio Project].dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update [Portfolio Project].dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From [Portfolio Project].dbo.NashvilleHousing




Select OwnerAddress
From [Portfolio Project].dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [Portfolio Project].dbo.NashvilleHousing


ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update [Portfolio Project].dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update [Portfolio Project].dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update [Portfolio Project].dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From [Portfolio Project].dbo.NashvilleHousing


-------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Project].dbo.NashvilleHousing
Group By SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [Portfolio Project].dbo.NashvilleHousing

Update [Portfolio Project].dbo.NashvilleHousing
SET SoldAsVacant =
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
				UniqueID
				) row_num

From [Portfolio Project].dbo.NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num >1
Order By PropertyAddress

SELECT *
From [Portfolio Project].dbo.NashvilleHousing


------------------------------------------------------------------

-- Delete Unused Columns


Select *
From [Portfolio Project].dbo.NashvilleHousing


ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN SaleDate