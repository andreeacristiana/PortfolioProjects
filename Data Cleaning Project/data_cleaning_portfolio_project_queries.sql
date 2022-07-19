select *
from pp..NashvilleHousing


-- STANDARDIZING THE DATE FORMAT
select
saledate,
convert(date, saledate) -- what I want the date to look like
from pp..nashvillehousing

update nashvillehousing
set saledateconverted = convert(date, saledate)

alter table nashvillehousing
add saledateconverted date;  -- added a column with the new desired date format

-- POPULATING PROPERTYADDRESS FROM NULL TO DATA

select *
from pp..nashvillehousing
where propertyaddress is null

select a.parcelid,
a.propertyaddress,
b. parcelid,
b.propertyaddress,
isnull(a.propertyaddress, b.propertyaddress) -- changing the NULL values to the correct address
from pp..nashvillehousing a
join pp..nashvillehousing b
	on a.parcelid = b.parcelid
	and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

update a  -- updating the table with the correct data
set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
from pp..nashvillehousing a
join pp..nashvillehousing b
	on a.parcelid = b.parcelid
	and a.uniqueid <> b.uniqueid
where a.propertyaddress is null


-- BREAKING THE ADDRESS INTO SEPARATE COLUMNS
-- 1 propertyaddress
select propertyaddress
from pp..nashvillehousing

select
substring(propertyaddress,1,charindex(',',propertyaddress)-1) as StreetAddress,-- charindex for determining the position of the delimiter
substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress))  as CityAddress -- +1 to start in the next position after the delimiter
from pp..nashvillehousing

alter table nashvillehousing
add StreetAddress nvarchar(255),
	City nvarchar(255);

update nashvillehousing
set StreetAddress = substring(propertyaddress,1,charindex(',',propertyaddress)-1),
	City = substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress))

select *
from pp..nashvillehousing

-- 2 owneraddress
select owneraddress
from pp..nashvillehousing

select
parsename(replace(owneraddress,',','.'),3), --1 is the first batch that it was separated into (from right to left) 
parsename(replace(owneraddress,',','.'),2),
parsename(replace(owneraddress,',','.'),1)
from pp..nashvillehousing

alter table nashvillehousing
add OwnerStreetAddress nvarchar(255),
	OwnerCity nvarchar(255),
	OwnerState nvarchar(255);

update nashvillehousing
set OwnerStreetAddress = parsename(replace(owneraddress,',','.'),3),
	OwnerCity = parsename(replace(owneraddress,',','.'),2),
	OwnerState = parsename(replace(owneraddress,',','.'),1);

select *
from nashvillehousing


-- CHANGING Y AND N TO Yes AND No IN SOLDASVACANT
select distinct(soldasvacant), --noticing I have 'N' and 'Y' as well as 'Yes' and 'No'
count(soldasvacant)
from pp..nashvillehousing
group by soldasvacant
order by 2 desc

select soldasvacant,
case when soldasvacant = 'Y' then 'Yes'
	 when soldasvacant = 'N' then 'No'
	 else soldasvacant
	 end
from pp..nashvillehousing

update nashvillehousing
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
						when soldasvacant = 'N' then 'No'
						else soldasvacant
						end;

-- REMOVING DUPLICATES
with rownumcte as (
select *,
row_number() over (
partition by parcelid,
			 propertyaddress,
			saleprice,
			saledate,
			legalreference
			order by uniqueid) row_num
from pp..nashvillehousing
)
delete
from rownumcte
where row_num > 1;


--	DELETE UNUSED COLUMNS
select *
from nashvillehousing

alter table nashvillehousing
drop column owneraddress, taxdistrict, propertyaddress, saledate;
