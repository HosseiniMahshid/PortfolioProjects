USE PortfolioProject


/*
Cleaning Data in SQL Queries
*/


SELECT *
FROM NashvilleHousing


--- Standardize Data Format

SELECT SaleDate, Convert(Date, SaleDate)
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SaleDate = Convert(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = Convert(Date, SaleDate)


SELECT SaleDateConverted, Convert(Date, SaleDate)
FROM NashvilleHousing



--- Populate Property Address data


SELECT *
FROM NashvilleHousing
ORDER BY ParcelID

SELECT PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress IS NULL



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID =  b.ParcelID
	AND a.UniqueID <> b.UniqueID
	Where a.PropertyAddress IS NULL


	UPDATE a
	SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
	FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID =  b.ParcelID
	AND a.UniqueID <> b.UniqueID
	Where a.PropertyAddress IS NULL


--  Breaking Out Address into Individual Columns(Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress,  1, CHARINDEX(',', PropertyAddress)-1) As Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

FROM NashvilleHousing



ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET  PropertySplitAddress = SUBSTRING(PropertyAddress,  1, CHARINDEX(',', PropertyAddress)-1)




ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);


UPDATE NashvilleHousing
SET  PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



SELECT OwnerAddress
FROM NashvilleHousing


-- Using ParseName

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),  3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),  2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),  1)
FROM NashvilleHousing




ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET  OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),  3)




ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);


UPDATE NashvilleHousing
SET  OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),  2)




ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);


UPDATE NashvilleHousing
SET  OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),  1)




----- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END



	------ Removing Duplicates

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 )row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


DELETE 
FROM RowNumCTE
WHERE row_num > 1





------ Deleting Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OWnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

SELECT  * 
FROM NashvilleHousing






