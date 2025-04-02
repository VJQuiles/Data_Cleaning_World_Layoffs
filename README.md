Data Cleaning for Layoffs Dataset
This project involves cleaning and transforming a dataset of layoffs to make it ready for analysis. The main tasks are:

Removing Duplicates: Identifying and eliminating duplicate rows.

Standardizing Data: Cleaning up inconsistencies in text, date formats, and numeric columns.

Handling Null Values: Updating or removing rows with missing data.

Removing Unnecessary Rows and Columns: Cleaning out irrelevant or redundant data.

Steps Involved

1. Remove Duplicates
   Create a staging table.

Identify duplicates using ROW_NUMBER() and remove them.

2. Standardize Data
   Clean and trim spaces from string values.

   Standardize industry names (e.g., consolidate variations like 'Crypto' into one).

   Convert date fields into a consistent format.

3. Handle Null Values
   Fill in missing industry values based on the company's previous entry.

   Remove rows where key columns have NULL values.

4. Remove Unnecessary Rows and Columns
   Delete rows with irrelevant or missing data.

   Drop columns like row_num used for intermediate steps.
     
