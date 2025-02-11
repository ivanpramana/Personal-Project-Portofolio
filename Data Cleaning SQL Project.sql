# CLEANING DATA IN SQL QUERIES
SELECT *
FROM nashville;

# Mengubah Kolom SaleDate dari Text menjadi Date
UPDATE nashville
SET SaleDate = STR_TO_DATE(SaleDate, '%M %d, %Y');

# Mengisi nilai "NULL" di PropertyAddress dengan nilai ParcelID yang sama
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress,b.PropertyAddress)
FROM nashville a
JOIN nashville b
	ON a.ParcelID = b.ParcelID
    AND a.ï»¿UniqueID != b.ï»¿UniqueID 
Where a.PropertyAddress is null;

UPDATE nashville a
JOIN nashville b
  ON a.ParcelID = b.ParcelID
  AND a.ï»¿UniqueID != b.ï»¿UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

# Memotong dan Memisahkan Address dan City dalam Kolom PropertyAddress
select PropertyAddress
from nashville;

select 
SUBSTRING(PropertyAddress,1,LOCATE(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,LOCATE(',',PropertyAddress)+1) as City
from nashville
;

ALTER TABLE nashville
ADD Address VARCHAR(100), 
ADD City VARCHAR(100)
;

UPDATE nashville
SET Address = SUBSTRING(PropertyAddress,1,LOCATE(',',PropertyAddress)-1);

UPDATE nashville
SET City = SUBSTRING(PropertyAddress,LOCATE(',',PropertyAddress)+1);

# Memotong dan Memisahkan Address, City dan State dalam Kolom OwnerAddress

SELECT OwnerAddress, 
substring_index(OwnerAddress, ',', 1),
substring_index(substring_index(OwnerAddress, ',', -2), ',',1),
substring_index(OwnerAddress, ',', -1)
From nashville;

ALTER TABLE nashville
ADD OwnerAddressSplit Varchar(100);
UPDATE nashville
SET OwnerAddressSplit = substring_index(OwnerAddress, ',', 1);

ALTER TABLE nashville
ADD OwnerCitySplit Varchar(100);
UPDATE nashville
SET OwnerCitySplit = substring_index(substring_index(OwnerAddress, ',', -2), ',',1);

ALTER TABLE nashville
ADD OwnerStateSplit Varchar(100);
UPDATE nashville
SET OwnerStateSplit = substring_index(OwnerAddress, ',', -1);

# Change "N", "Y" into "No" and "Yes" using Case When
SELECT distinct SoldAsVacant, count(SoldAsVacant)
from nashville
group by SoldAsVacant
order by 2;

select SoldAsVacant,
CASE
	when SoldAsVacant = "Y" then "Yes"
	when SoldAsVacant = "N" then "No"
    else SoldAsVacant
    end
from nashville
;

UPDATE nashville
SET SoldAsVacant = CASE
	when SoldAsVacant = "Y" then "Yes"
	when SoldAsVacant = "N" then "No"
    else SoldAsVacant
    end;
    

# Remove Duplicates
ALTER TABLE nashville CHANGE COLUMN `ï»¿UniqueID` UniqueID INT;

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
                    
From nashville
order by ParcelID
;

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

From nashville
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;

WITH RowNumCTE AS (
    SELECT 
        UniqueID,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) row_num
    FROM nashville
)
DELETE n
FROM nashville n
JOIN RowNumCTE r ON n.UniqueID = r.UniqueID
WHERE r.row_num > 1;

# Delete Unused Columns
Select *
From nashville

;
ALTER TABLE nashville
DROP COLUMN OwnerAddressSplit
;

    

