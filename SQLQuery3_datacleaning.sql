-- Selecting everything from the database
select * from portfolio_datacleaning.dbo.Sheet1$

--standardizing the date column

select SaleDate from portfolio_datacleaning.dbo.Sheet1$

select SaleDateConverted, CONVERT (date, SaleDate)  
from portfolio_datacleaning.dbo.Sheet1$ 

Update portfolio_datacleaning.dbo.Sheet1$
Set SaleDateConverted = CONVERT(date, Saledate)

select * from portfolio_datacleaning.dbo.Sheet1$

--filling missing values from property address

Select * from portfolio_datacleaning.dbo.Sheet1$
where PropertyAddress is not null

-- noticed that the parcelID is correlated to the property address

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from portfolio_datacleaning.dbo.Sheet1$ a
JOIN portfolio_datacleaning.dbo.Sheet1$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Replacing the null values and updating the table
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
from portfolio_datacleaning.dbo.Sheet1$ a
JOIN portfolio_datacleaning.dbo.Sheet1$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
from portfolio_datacleaning.dbo.Sheet1$ a
JOIN portfolio_datacleaning.dbo.Sheet1$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
Select * from portfolio_datacleaning.dbo.Sheet1$
where PropertyAddress is null

--Separating the values in the property address column
Select PropertyAddress from portfolio_datacleaning.dbo.Sheet1$

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) 
from portfolio_datacleaning.dbo.Sheet1$

ALTER TABLE portfolio_datacleaning.dbo.Sheet1$
ADD PropertysplitAddress Nvarchar(255);

ALTER TABLE portfolio_datacleaning.dbo.Sheet1$
ADD PropertysplitCity Nvarchar(255);


Update portfolio_datacleaning.dbo.Sheet1$
Set PropertysplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
select * from  portfolio_datacleaning.dbo.Sheet1$

Update portfolio_datacleaning.dbo.Sheet1$
Set PropertysplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))
select * from  portfolio_datacleaning.dbo.Sheet1$

--separating values in the owner address column using parsename method(Its easier)
Select 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

from portfolio_datacleaning.dbo.Sheet1$

ALTER TABLE portfolio_datacleaning.dbo.Sheet1$
ADD OwnersplitAddress Nvarchar(255);
select * from  portfolio_datacleaning.dbo.Sheet1$

Update portfolio_datacleaning.dbo.Sheet1$
Set OwnersplitAddress =PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)


ALTER TABLE portfolio_datacleaning.dbo.Sheet1$
ADD OwnersplitCity Nvarchar(255);

Update portfolio_datacleaning.dbo.Sheet1$
Set OwnersplitCity =PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE portfolio_datacleaning.dbo.Sheet1$
ADD OwnersplitState Nvarchar(255);

Update portfolio_datacleaning.dbo.Sheet1$
Set OwnersplitState =PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
select * from  portfolio_datacleaning.dbo.Sheet1$


--Change Y and N to Yes and No in Sold as vacant field
select distinct(SoldAsVacant),Count(SoldAsVacant)
from portfolio_datacleaning.dbo.Sheet1$
group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'	
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
from  portfolio_datacleaning.dbo.Sheet1$

Update portfolio_datacleaning.dbo.Sheet1$
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'	
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

select distinct(SoldAsVacant),Count(SoldAsVacant)
from portfolio_datacleaning.dbo.Sheet1$
group by SoldAsVacant
Order by 2

--deleting duplicates(am going to use CTE temp tables to pull this off)
With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY
		UniqueID
		)row_num

From portfolio_datacleaning.dbo.Sheet1$
--order by ParcelID
)
delete 
from RowNumCTE
where row_num > 1
--order by ParcelID

--dropping unnececary columns
ALTER TABLE portfolio_datacleaning.dbo.Sheet1$
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress

select * 
from portfolio_datacleaning.dbo.Sheet1$