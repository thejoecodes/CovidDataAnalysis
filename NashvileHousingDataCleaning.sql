--=====================================================================--
/*
DATA CLEANING IN SQL by @thejoecodes
*/
--=====================================================================--

--Select everything in the NashvileHousing Table in the NashvileHousing Database

SELECT *
FROM NashvileHousing.dbo.NashvileHousing

--=====================================================================--

--Standardizing Sale Date

SELECT SaleDateStd, CONVERT(Date, SaleDate) as SaleDateStd
FROM NashvileHousing.dbo.NashvileHousing

--Creates a new column SaleDateStd in the NashvileHousing Table
ALTER TABLE NashvileHousing.dbo.NashvileHousing
ADD SaleDateStd Date;

--Populate the column with the Standard Date format
UPDATE NashvileHousing.dbo.NashvileHousing
SET SaleDateStd = CONVERT(Date, SaleDate)

--=====================================================================--

--Property Address
SELECT PropertyAddress
FROM NashvileHousing.dbo.NashvileHousing
WHERE PropertyAddress IS NULL

SELECT PropertyAddress
FROM NashvileHousing.dbo.NashvileHousing
WHERE PropertyAddress IS NULL

--Finding Properties with the same Parcel ID

SELECT Nash1.ParcelID, Nash1.PropertyAddress, Nash2.ParcelID, Nash2.PropertyAddress, ISNULL(Nash1.PropertyAddress, Nash2.PropertyAddress)
FROM NashvileHousing..NashvileHousing Nash1
JOIN NashvileHousing..NashvileHousing Nash2
ON Nash1.ParcelID = Nash2.ParcelID
AND Nash1.[UniqueID ] <> Nash2.[UniqueID ]
WHERE Nash1.PropertyAddress IS NULL

--Updating the Nulls in Property Address

UPDATE Nash1
SET PropertyAddress = ISNULL(Nash1.PropertyAddress, Nash2.PropertyAddress)
FROM NashvileHousing..NashvileHousing Nash1
JOIN NashvileHousing..NashvileHousing Nash2
ON Nash1.ParcelID = Nash2.ParcelID
AND Nash1.[UniqueID ] <> Nash2.[UniqueID ]
WHERE Nash1.PropertyAddress IS NULL

--=====================================================================--

--Breaking PropertyAddress into Individual Columns

SELECT PropertyAddress
FROM NashvileHousing.dbo.NashvileHousing

--Separating the addresses from the delimiter using SUBSTRING
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM NashvileHousing.dbo.NashvileHousing

--Altering the table to add the Address and City seperately  

--Address
ALTER TABLE NashvileHousing.dbo.NashvileHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvileHousing.dbo.NashvileHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

--City
ALTER TABLE NashvileHousing.dbo.NashvileHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvileHousing.dbo.NashvileHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

--Results
SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM NashvileHousing.dbo.NashvileHousing

--Seperating Owner Address using PARSENAME
 SELECT OwnerAddress
 FROM NashvileHousing.dbo.NashvileHousing

 SELECT
 PARSENAME(REPLACE(OwnerAddress,',','.'),3) as OwnerSplitAddress,
 PARSENAME(REPLACE(OwnerAddress,',','.'),2) as OwnerSplitCity,
 PARSENAME(REPLACE(OwnerAddress,',','.'),1) as OwnerSplitState
 FROM NashvileHousing.dbo.NashvileHousing

 --Altering and Updating Table to add the new columns
 
 --Address
ALTER TABLE NashvileHousing.dbo.NashvileHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvileHousing.dbo.NashvileHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

--City
ALTER TABLE NashvileHousing.dbo.NashvileHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE NashvileHousing.dbo.NashvileHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

--State
ALTER TABLE NashvileHousing.dbo.NashvileHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvileHousing.dbo.NashvileHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Results
SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM NashvileHousing.dbo.NashvileHousing

--Selecting Y and N, Yes and NO in SoldAsVacant

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) as TotalCount
FROM NashvileHousing.dbo.NashvileHousing
GROUP BY SoldAsVacant
ORDER BY 2

--Changing the N's to No and Y's to Yes
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'N' THEN 'No'
     WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 ELSE SoldAsVacant
	 END
FROM NashvileHousing.dbo.NashvileHousing

--Updating Table
UPDATE NashvileHousing.dbo.NashvileHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
     WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 ELSE SoldAsVacant
	 END

--=====================================================================--

--Removing Duplicates
WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID) row_num
				
FROM NashvileHousing.dbo.NashvileHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1

--Delete Duplicates

WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID) row_num
				
FROM NashvileHousing.dbo.NashvileHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
