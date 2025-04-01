-- Data Cleaning

-- 1. Remove Duplicates
-- 2. Standardize the Data 
-- 3. Address Null Values(Blank Values)
-- 4. Remove Unneccsary Columns and Rows 


-- Prep for process by first creating a staging table, to ensure no issues are created with the raw data set

SELECT *
FROM layoffs
;

CREATE TABLE layoffs_statging
LIKE layoffs
;

INSERT layoffs_staging
SELECT * 
FROM layoffs
;

-- 1. Remove duplicates

-- Identify duplicates with unique row values (if row_num >=2, there are duplicates) 
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging
;

-- Use a CTE to help identify duplicates 
WITH duplicate_cte AS
(
SELECT  *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1
;

-- Since I can't delete the values in the table from the CTE in MySQL, I'll have to create a new staging table with the CTE so that then we can remove the duplicates
 
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2
;

INSERT INTO layoffs_staging2
SELECT  *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
;

DELETE  
FROM layoffs_staging2
WHERE row_num > 1
;

SELECT *
FROM layoffs_staging2
;


-- 2. Standardizing Data

-- Here I check each column and utilize string functions to help standardize the data and make it more readable

SELECT DISTINCT company
FROM layoffs_staging2
;

SELECT company, (TRIM(company)) 
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET company = TRIM(company)
;

SELECT DISTINCT location
FROM layoffs_staging2
;

SELECT DISTINCT industry
FROM layoffs_staging2
;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%'
;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'
;

SELECT DISTINCT total_laid_off
FROM layoffs_staging2
;

SELECT DISTINCT percentage_laid_off
FROM layoffs_staging2
;

SELECT DISTINCT `date`
FROM layoffs_staging2
;

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
;

SELECT `date`
FROM layoffs_staging2
;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT DISTINCT stage
FROM layoffs_staging2
;

SELECT DISTINCT country
FROM layoffs_staging2
;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1
;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'
;

SELECT DISTINCT funds_raised_millions
FROM layoffs_staging2
;

SELECT *
FROM layoffs_staging2
;

-- 3 Null Values 

SELECT * 
FROM layoff_staging2
;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = ''
;

SELECT *
FROM layoffs_staging2
WHERE industry is NULL 
OR industry = ''
;

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%'
;

-- Here I use a self join in order to populate blank industry values(Some companies appeared twice, once with an industry, once with a blank industry)

SELECT * 
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL
;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company 
SET t1.industry = t2.industry 
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL 
;


-- 4. Remove Unnecessary Row/Columns

-- Here I dropped the unique row indicator, and all of the null values in total_laid_off percent_laid_off - Not useful for the exploratory data analysis portion


DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

SELECT *
FROM layoffs_staging2
;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- code ref https://github.com/AlexTheAnalyst/MySQL-YouTube-Series/blob/main/Portfolio%20Project%20-%20Data%20Cleaning.sql
-- layoff table https://github.com/AlexTheAnalyst/MySQL-YouTube-Series/blob/main/layoffs.csv