/*
 
 Cleaning Data in SQL Queries
 
 */
 
 SELECT *
 FROM PortfolioProject.dbo.NashvilleHousing
 
 --Standardize Date Format
 
 SELECT SaleDateConverted, CONVERT(Date,SaleDate)
 FROM PortfolioProject.dbo.NashvilleHousing;
 
 ALTER TABLE PortfolioProject.NashvilleHousing
 ADD SaleDateConverted Date;
 
 UPDATE PortfolioProject..NashvilleHousing
 SET SaleDateConverted = CONVERT(Date,SaleDate);
 
 
 
 --Populate Property Address Data
 
 
 
 SELECT *
 FROM PortfolioProject..NashvilleHousing
 --WHERE PropertyAddress is null
 ORDER BY ParcelID ;
 
 SELECT a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
 FROM PortfolioProject..NashvilleHousing a
 JOIN PortfolioProject..NashvilleHousing b
   ON a.ParcelID = b.ParcelID
   AND a.[UniqueID ]<> b.[UniqueID ]
 WHERE a.PropertyAddress is null;
 
 UPDATE a
 SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
 FROM PortfolioProject..NashvilleHousing a
 JOIN PortfolioProject..NashvilleHousing b
   ON a.ParcelID = b.ParcelID
   AND a.[UniqueID ]<> b.[UniqueID ]
 WHERE a.PropertyAddress is null;
 
 
 --Breaking out Address into Individual Columns (Address, City, State)
 
 
 SELECT PropertyAddress
 FROM PortfolioProject..NashvilleHousing;
 
 
 SELECT
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
 , SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
 FROM PortfolioProject..NashvilleHousing;
 
 ALTER TABLE PortfolioProject..NashvilleHousing
 ADD PropertySplitAddress Nvarchar(255);
 
 
 UPDATE PortfolioProject..NashvilleHousing
 SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);
 
 
 ALTER TABLE PortfolioProject..NashvilleHousing
 ADD PropertySplitCity Nvarchar(255);
 
 
 UPDATE PortfolioProject..NashvilleHousing
 SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));
 
 
 
 
 
 
 
 
 
 
 
 
 SELECT OwnerAddress
 FROM PortfolioProject..NashvilleHousing;
 
 SELECT
 PARSENAME(REPLACE(OwnerAddress,',','.'),3)
 ,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
 ,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
 FROM PortfolioProject..NashvilleHousing;
 
 
 ALTER TABLE PortfolioProject..NashvilleHousing
 ADD OwnerSplitAddress Nvarchar(255);
 
 UPDATE NashvilleHousing
 SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);
 
 ALTER TABLE PortfolioProject..NashvilleHousing
 ADD OwnerSplitCity Nvarchar(255);
 
 UPDATE NashvilleHousing
 SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);
 
 ALTER TABLE NashvilleHousing
 ADD OwnerSplitState Nvarchar(255);
 
 UPDATE NashvilleHousing
 SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);
 
 
 
 
 
 -- Change Y and N to Yes and no in "Sold as Vacant" field
 
 SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
 FROM PortfolioProject..NashvilleHousing
 GROUP BY SoldAsVacant 
 ORDER BY 2
 
 
 SELECT SoldAsVacant,
 CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
 	 WHEN SoldAsVacant = 'N' THEN 'No'
 	 ELSE SoldAsVacant
 	 END
 FROM PortfolioProject..NashvilleHousing
 
 UPDATE NashvilleHousing
 SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
 						WHEN SoldAsVacant = 'N' THEN 'No'
 						ELSE SoldAsVacant
 						END;
 
 
 
 
 
 --Remove Duplicates
 WITH RowNumCTE AS(
 SELECT *,
 ROW_NUMBER() OVER (
 	PARTITION BY ParcelID,
 				 PropertyAddress,
 				 SalePrice,
 				 SaleDate,
 				 LegalReference
 				 ORDER BY
 				    UniqueID
 					) row_num
 
 
 FROM PortfolioProject..NashvilleHousing
 )
 
 
 DELETE
 FROM RowNumCTE
 WHERE row_num > 1;
 
 
 --Delete Unused Columns
 
 SELECT *
 FROM PortfolioProject..NashvilleHousing;
 
 
 ALTER TABLE NashvilleHousing
 DROP Column OwnerAddress, TaxDistrict, PropertyAddress;
 
 ALTER TABLE NashvilleHousing
 DROP Column SaleDate;
 
 
 
 SELECT * 
 FROM PortfolioProject..NashvilleHousing
 
 
 
 --Renaming Columns
 
 
 
 
 
 EXEC sp_rename 'NashvilleHousing.SaleDateConverted','SalesDate','COLUMN',
 EXEC sp_rename 'NashvilleHousing.PropertySplitAddress','PropertyAddress','COLUMN',
 EXEC sp_rename 'NashvilleHousing.PropertySplitCity','PropertyCity','COLUMN',
 EXEC sp_rename 'NashvilleHousing.OwnerSplitAddress','OwnerAddress','COLUMN',
 EXEC sp_rename 'NashvilleHousing.OwnerSplitCity','OwnerCity','COLUMN',
 EXEC sp_rename 'NashvilleHousing.OwnerSplitState','OwnerState','COLUMN'