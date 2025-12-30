/* =========================================================
   Nashville Housing Data Cleaning 
   1) Create a new separate for cleaning and analysis
   2) Clean, standardize, and prepare data for analysis/visualization
   ========================================================= */

/* =========================================================
   create a new separate table 
	1) prevent changing raw table/data
   ========================================================= */
-- drop table if exist
DROP TABLE IF EXISTS portfolio_project..NashvilleHousing_Analysis;

-- create new table and copy original data from raw table
SELECT *
INTO portfolio_project..NashvilleHousing_Analysis
FROM portfolio_project..NashvilleHousing;

-- preview data, schema, datatypes
SELECT *
FROM portfolio_project..NashvilleHousing_Analysis;

/* =========================================================
   data standardization: date
   ========================================================= */
-- check SaleDate column and convert into date datatype
SELECT SaleDate, CONVERT(date, SaleDate)
FROM portfolio_project..NashvilleHousing_Analysis;

-- update SaleDate to date datatype
UPDATE portfolio_project..NashvilleHousing_Analysis
SET SaleDate = CONVERT(date, SaleDate);

/* =========================================================
   identify and populate missing addresses
   ========================================================= */

-- check rows with propertyaddress is null
SELECT *
FROM portfolio_project..NashvilleHousing_Analysis
where propertyaddress is null;

-- using self join to find candidates to fill address
-- rows with same ParcelID but different UniqueID, and one with address, another is null
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolio_project..NashvilleHousing_Analysis a
JOIN portfolio_project..NashvilleHousing_Analysis b
ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- updating table: using the matched addresses to fill null PropertyAddress
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolio_project..NashvilleHousing_Analysis a
JOIN portfolio_project..NashvilleHousing_Analysis b
ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

/* =========================================================
   explore PropertyAddress formatting
   ========================================================= */
-- check PropertyAddress column format
SELECT DISTINCT PropertyAddress
FROM portfolio_project..NashvilleHousing_Analysis;

-- using SUBSTRING to divide address and city by comma position
SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS city
FROM portfolio_project..NashvilleHousing_Analysis;

-- add new column: PropertySplitAddress
ALTER TABLE portfolio_project..NashvilleHousing_Analysis
ADD PropertySplitAddress Varchar(255);

-- populate PropertySplitAddress with splitted (street) address
UPDATE portfolio_project..NashvilleHousing_Analysis
SET  PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

-- add new column: PropertySplitCity
ALTER TABLE portfolio_project..NashvilleHousing_Analysis
ADD PropertySplitCity Varchar(255);

-- populate PropertySplitCity with splitted (city) address
UPDATe portfolio_project..NashvilleHousing_Analysis
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

/* =========================================================
   split OwnerAddress into Address, City, State
   ========================================================= */
-- overview OwnerAddress format
SELECT OwnerAddress
FROM portfolio_project..NashvilleHousing_Analysis;

-- first REPLACE comma to dot, then using PARSENAME to extract address/city/state from OwnerAddress
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM portfolio_project..NashvilleHousing_Analysis;

-- add new column: OwnerSplitAdderss
ALTER TABLE portfolio_project..NashvilleHousing_Analysis
ADD OwnerSplitAddress Varchar(255);

-- populate OwnerSplitAddress
UPDATE portfolio_project..NashvilleHousing_Analysis
SET  OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

-- add new column: OwnerSplitCity
ALTER TABLE portfolio_project..NashvilleHousing_Analysis
ADD OwnerSplitCity Varchar(255);

-- populate OwnerSplitCity
UPDATE portfolio_project..NashvilleHousing_Analysis
SET  OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

-- add new column: OwnerSplitState
ALTER TABLE portfolio_project..NashvilleHousing_Analysis
ADD OwnerSplitState Varchar(255);

-- populate OwnerSplitState
UPDATE portfolio_project..NashvilleHousing_Analysis
SET  OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

/* =========================================================
   identify duplicate records using CTE (flag duplicates)
   ========================================================= */
WITH CTE AS(
SELECT *,
	-- define duplicate as same ParcelID, PropertyAdderss, SaleDate and LegalReference
	ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SaleDate, LegalReference
	ORDER BY UniqueID
	) AS row_num
FROM portfolio_project..NashvilleHousing_Analysis
)
SELECT *
FROM CTE
WHERE row_num > 1; -- identify duplicates

/* =========================================================
   drop unuseful columns (only in analysis table)
   ========================================================= */
-- drop raw columns that are standardized
ALTER TABLE portfolio_project..NashvilleHousing_Analysis
DROP COLUMN OwnerAddress, SaleDate;

/* =========================================================
   standardized address by LTRIM leading spaces 
   ========================================================= */
-- preview trimmed adress values
SELECT LTRIM(PropertyAddress), LTRIM(PropertySplitAddress), LTRIM(PropertySplitCity)
FROM portfolio_project..NashvilleHousing_Analysis;

-- update trimmed PropertyAddress
UPDATE portfolio_project..NashvilleHousing_Analysis
SET PropertyAddress =  LTRIM(PropertyAddress);

-- update trimmed PropertySplitAddress
UPDATE portfolio_project..NashvilleHousing_Analysis
SET PropertySplitAddress =  LTRIM(PropertySplitAddress);

-- update trimmed PropertySplitCity
UPDATE portfolio_project..NashvilleHousing_Analysis
SET PropertySplitCity =  LTRIM(PropertySplitCity);
