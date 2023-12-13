-- cleaning data in sql queries --
SELECT *
FROM [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]

-----------------------------------------------------------------------------------

-- standardize date format --

SELECT saledateconverted ,saledate
FROM [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]


UPDATE [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
SET saledate = CONVERT(date,Saledate)

ALTER TABLE [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
ADD saledateconverted date;

UPDATE [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning] 
SET saledateconverted = CONVERT(date,Saledate)

-------------------------------------------------------------------------------------------

-- populate property address data --

SELECT *
FROM [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
--WHERE PropertyAddress is null
ORDER BY ParcelID


SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress ,
    ISNULL(a.PropertyAddress ,b.PropertyAddress)
FROM [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning] a
JOIN [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning] b
ON a.parcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress ,b.PropertyAddress)
FROM [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning] a
JOIN [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning] b
ON a.parcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

-------------------------------------------------------------------------------------

-- breaking out address into individual columns (Address , City, State)

SELECT PropertyAddress
FROM [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
-- WHERE property is null
-- order by ParcelID

SELECT 
SUBSTRING(PropertyAddress ,1,CHARINDEX(',',PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress ,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address

FROM [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]




ALTER TABLE [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
ADD PropertySplitAddress nvarchar(255);

UPDATE [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
SET PropertySplitAddress = SUBSTRING(PropertyAddress ,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
ADD PropertySplitCity nvarchar(255);

UPDATE [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
SET PropertySplitCity = SUBSTRING(PropertyAddress ,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) 


SELECT*
FROM [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]


-- breaking out owner address column --

SELECT OwnerAddress
FROM [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.') , 3)
,PARSENAME(REPLACE(OwnerAddress,',','.') , 2)
,PARSENAME(REPLACE(OwnerAddress,',','.') , 1)
FROM [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]


ALTER TABLE [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
ADD OwnerSplitAddress nvarchar(255);

UPDATE [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.') , 3)


ALTER TABLE [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
ADD OwnerSplitCity nvarchar(255);

UPDATE [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.') , 2)


ALTER TABLE [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
ADD OwnerSplitState nvarchar(255);

UPDATE [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
SET  OwnerSplitState  = PARSENAME(REPLACE(OwnerAddress,',','.') , 1)

SELECT *
FROM [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]

----------------------------------------------------------------------------------------------------

-- change 0 and 1 to Yes and No in " sold as vacant" field --

SELECT DISTINCT(SoldAsvacant) , COUNT(SoldAsVacant)
FROM [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
    CASE WHEN SoldAsVacant = 0 THEN 'No'
         WHEN SoldAsVacant = 1 THEN 'Yes'
         ELSE CAST(SoldAsVacant AS VARCHAR(255)) -- Change the data type as needed
    END 
FROM [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning];

ALTER TABLE [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
ALTER COLUMN SoldAsVacant NVARCHAR(3); -- Adjust the length as needed

UPDATE [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 0 THEN 'No'
                        WHEN SoldAsVacant = 1 THEN 'Yes'
                        ELSE CAST(SoldAsVacant AS NVARCHAR(255)) -- Change the length as needed
                   END;

----------------------------------------------------------------------------------------------------------------

-- remove duplicates --
WITH RowNumCTE AS (
SELECT*,
     ROW_NUMBER()OVER(
	 PARTITION BY ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY 
				     UniqueID
					 ) row_num

FROM [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
--ORDER BY ParcelID
)
SELECT*
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

------------------------------------------------------------------------

-- delete unused columns --

SELECT *
FROM [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]

ALTER TABLE [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
DROP COLUMN OwnerAddress , TaxDistrict , PropertyAddress

ALTER TABLE [Practice_portfolio].[dbo].[Nashville Housing Data for Data Cleaning]
DROP COLUMN SaleDate