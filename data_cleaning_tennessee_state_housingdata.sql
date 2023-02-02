/** Tennessee state housing data cleaning **/

SELECT *
FROM tennessee;

/* Since a parcel ID is unique for a property, I  can take this as a reference and
populate the property address.I need to populate the addresses where the 
property address is null based on the parcel id.*/

--base query for populating address

SELECT a.parcelid
     , a.propertyaddress
	 , b.parcelid
	 , b.propertyaddress
	 , COALESCE(a.propertyaddress, b.propertyaddress)
FROM tennessee a
JOIN tennessee b
ON a.parcelid=b.parcelid
AND a.uniqueid <> b.uniqueid
WHERE  a.propertyaddress IS NULL;

--main query for populating address

UPDATE tennessee a
SET propertyaddress =  COALESCE(a.propertyaddress, b.propertyaddress)
from tennessee b
WHERE a.parcelid=b.parcelid
AND a.uniqueid <> b.uniqueid
AND  a.propertyaddress IS NULL;


/* Bifurcate property address into columns (address, city and state) */

SELECT propertyaddress
FROM tennessee

-- here the delimiter(is something that seperates the values in cell) is " , "
-- So i can seperate the address and city basis the delimiter "comma"

-- base query 

SELECT propertyaddress
    , SUBSTRING(propertyaddress , 1 , POSITION(',' IN propertyaddress )-1) AS address
	-- POSITION(',' IN propertyaddress) comma_position
	-- eliminating "comma" from address by substracting1 charcater from substring
	, SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress )+1, length(propertyaddress) ) AS City
FROM tennessee;

-- Main query - adding new columns in the table i.e is bifurcated propertyaddress

ALTER TABLE tennessee
ADD propertyaddress2 VARCHAR(255);

UPDATE  tennessee
SET propertyaddress2 =  SUBSTRING(propertyaddress , 1 , POSITION(',' IN propertyaddress )-1) 

ALTER TABLE tennessee
ADD propertycity VARCHAR(255);

UPDATE  tennessee
SET propertycity = SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress )+1, length(propertyaddress) );


/* standardise the date formart */

SELECT saledate
     , CAST(saledate AS DATE)
FROM tennessee;

ALTER TABLE tennessee
ADD saledate2 DATE;

UPDATE  tennessee
SET saledate2 =  CAST(saledate AS DATE);

/* Bifurcate owner address into columns (address, city and state) */

-- base query

select owneraddress
      , SPLIT_PART(owneraddress,',',1)
	  , SPLIT_PART(owneraddress,',',2)
	  , SPLIT_PART(owneraddress,',',3)
from tennessee;

-- main queries

-- address

ALTER TABLE tennessee
ADD owneraddress2 VARCHAR(255);

UPDATE  tennessee
SET owneraddress2 =  SPLIT_PART(owneraddress,',',1) ;

--city

ALTER TABLE tennessee
ADD ownercity VARCHAR(255);

UPDATE  tennessee
SET ownercity =  SPLIT_PART(owneraddress,',',2) ;

-- state 

ALTER TABLE tennessee
ADD ownerstate VARCHAR(255);

UPDATE  tennessee
SET ownerstate =  SPLIT_PART(owneraddress,',',3) ;

/* update "Y and N" to  'Yes and No' in soldasvacant column*/

-- base queries

SELECT DISTINCT soldasvacant
      , COUNT(soldasvacant)
from tennessee
group by 1
order by 2;

-- base 2

select soldasvacant
     , case when soldasvacant = 'Y' THEN 'Yes'
	        when soldasvacant = 'N' THEN 'No'
			ELSE soldasvacant
			END
FROM tennessee

-- main query

UPDATE tennessee
SET soldasvacant = case when soldasvacant = 'Y' THEN 'Yes'
	        when soldasvacant = 'N' THEN 'No'
			ELSE soldasvacant
			END;
			
/*REMOVE  duplicates FROM THE TABLE */

-- base query to find duplicate values


SELECT  uniqueid
from 
(
SELECT *
        , ROW_NUMBER() OVER( 
			PARTITION BY uniqueid
		           , parcelid
		           , propertyaddress
		           , saledate
		           , saleprice
		    ORDER BY parcelid )
            AS row_num
FROM tennessee ) t
WHERE t.row_num > 1

-- main query to delete Duplicates values

DELETE FROM tennessee
WHERE uniqueid IN
(
SELECT  uniqueid
FROM 
(SELECT *
        , ROW_NUMBER() OVER( 
			PARTITION BY uniqueid
		           , parcelid
		           , propertyaddress
		           , saledate
		           , saleprice
		    ORDER BY parcelid )
            AS row_num
FROM tennessee ) t
WHERE t.row_num > 1);

-- Drop columns which are not required

select * from tennessee

ALTER TABLE tennessee
DROP COLUMN propertyaddress,
DROP COLUMN owneraddress,
DROP COLUMN saledate;

--rename columns

select * from tennessee;

alter table tennessee
RENAME COLUMN saledate2 to saledate;

alter table tennessee
RENAME COLUMN propertyaddress2 to propertyaddresssplit;

alter table tennessee
RENAME COLUMN owneraddress2 to owneraddresssplit;


-- 

select * from tennessee
order by 1
