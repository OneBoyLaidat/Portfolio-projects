--Data Cleaning With SQL--

SELECT*
FROM NashvilleHousing;

--------------------------------------------------------------------------

--Fill-in missing property address data--

--STEP 1-Query for missing data in PropertyAddress--
Select PropertyAddress
From NashvilleHousing
WHERE PropertyAddress IS NULL

--Step 2- Clean data by matching parcelID with PropertyAddress with a SELFJOIN to create a new column with the address--
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--Step 3- Update database with clean data--
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null



--Break out Property Address into useful coulumns(Address,City,State)--

--STEP 1-Query for PropertyAddress--
SELECT PropertyAddress
FROM NashvilleHousing



--STEP 2-Separate each data into useful bits--

SELECT  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS clean_address,
		PARSENAME(REPLACE(PropertyAddress,',','.'),1) AS clean_city
FROM NashvilleHousing


 
--STEP 3- Update your table with the new columns and data--

ALTER TABLE NashvilleHousing
Add Property_clean_address Nvarchar(255),
    Property_clean_city Nvarchar(255);

Update NashvilleHousing
      SET Property_clean_address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ),
          Property_clean_city = PARSENAME(REPLACE(PropertyAddress,',','.'),1);




--Break out Owners Address into useful coulumns(Address,City,State)--
--STEP 1-Query for OwnersAddress--
SELECT PropertyAddress
FROM NashvilleHousing

--STEP 2-Separate OwnersAddress into clean bits(Address,City,State)--
SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3) clean_address,
       PARSENAME(REPLACE(OwnerAddress,',','.'),2) clean_city,
	   PARSENAME(REPLACE(OwnerAddress,',','.'),1) clean_state
FROM NashvilleHousing


--STEP 3- Update your table with the new columns and data--

ALTER TABLE NashvilleHousing
Add Owner_clean_address Nvarchar(255),
    Owner_clean_city Nvarchar(255),
	Owner_clean_state Nvarchar(255);

Update NashvilleHousing
      SET Owner_clean_address = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
          Owner_clean_city = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
		  Owner_clean_state = PARSENAME(REPLACE(OwnerAddress,',','.'),1);


-----------------------------------------------------------------------------------
Select *
From NashvilleHousing
