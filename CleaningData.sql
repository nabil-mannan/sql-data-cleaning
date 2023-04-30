-- Cleaning Data usig SQL queries


SELECT *
FROM dbo.NashvilleHousing

-- Standardizing date

ALTER TABLE NashvilleHousing
ADD SaleDateNew date;

UPDATE NashvilleHousing
SET SaleDateNew = CONVERT(date, SaleDate)

SELECT SaleDateNew
FROM dbo.NashvilleHousing


-- Finding and Populating missing property address data


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

SELECT ParcelID, PropertyAddress
FROM dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID


-- Dividing property address into separate columns, address, city


SELECT PropertyAddress, 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD NewPropertyAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET NewPropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD NewPropertyCity NVARCHAR(255)

UPDATE NashvilleHousing
SET NewPropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


-- Splitting owner address into three column, address, city, state


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD NewOwnerAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET NewOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD NewOwnerCity NVARCHAR(255)

UPDATE NashvilleHousing
SET NewOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD NewOwnerState NVARCHAR(255)

UPDATE NashvilleHousing
SET NewOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Changing values in 'Sold as Vacant' column


SELECT DISTINCT(SoldAsVacant)
FROM dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =
CASE 
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END
FROM dbo.NashvilleHousing


-- Finding and removing duplicates


WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference,
				 BuildingValue
				 ORDER BY 
					UniqueID
					) row_num

FROM dbo.NashvilleHousing
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1


-- Removing unused columns

SELECT *
FROM dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict

