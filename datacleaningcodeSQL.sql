SELECT *
FROM portfolio_project..NashvilleHousing;

SELECT SaleDate, CONVERT(date, SaleDate)
FROM portfolio_project..NashvilleHousing;

UPDATE portfolio_project..NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate);

SELECT *
FROM portfolio_project..NashvilleHousing
where propertyaddress is null;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolio_project..NashvilleHousing a
JOIN portfolio_project..NashvilleHousing b
ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolio_project..NashvilleHousing a
JOIN portfolio_project..NashvilleHousing b
ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID;

SELECT DISTINCT PropertyAddress
FROM portfolio_project..NashvilleHousing;

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS city
FROM portfolio_project..NashvilleHousing;

ALTER TABLE portfolio_project..NashvilleHousing
ADD PropertySplitAddress Varchar(255);

UPDATE portfolio_project..NashvilleHousing
SET  PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE portfolio_project..NashvilleHousing
ADD PropertySplitCity Varchar(255);

UPDATe portfolio_project..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

SELECT OwnerAddress
FROM portfolio_project..NashvilleHousing;

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM portfolio_project..NashvilleHousing;

ALTER TABLE portfolio_project..NashvilleHousing
ADD OwnerSplitAddress Varchar(255);

UPDATE portfolio_project..NashvilleHousing
SET  OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE portfolio_project..NashvilleHousing
ADD OwnerSplitCity Varchar(255);

UPDATE portfolio_project..NashvilleHousing
SET  OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE portfolio_project..NashvilleHousing
ADD OwnerSplitState Varchar(255);

UPDATE portfolio_project..NashvilleHousing
SET  OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


WITH CTE AS(
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SaleDate, LegalReference
	ORDER BY UniqueID
	) AS row_num
FROM portfolio_project..NashvilleHousing
)
SELECT *
FROM CTE
WHERE row_num > 1; 

ALTER TABLE portfolio_project..NashvilleHousing
DROP COLUMN OwnerAddress, SaleDate;

SELECT LTRIM(PropertyAddress), LTRIM(PropertySplitAddress), LTRIM(PropertySplitCity)
FROM portfolio_project..NashvilleHousing;

UPDATE portfolio_project..NashvilleHousing
SET PropertyAddress =  LTRIM(PropertyAddress);

UPDATE portfolio_project..NashvilleHousing
SET PropertySplitAddress =  LTRIM(PropertyAddress);

UPDATE portfolio_project..NashvilleHousing
SET PropertySplitCity =  LTRIM(PropertyAddress);