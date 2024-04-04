
SELECT 

    ROUND((SELECT SUM(COALESCE(credit, 0)) / 1000 

           FROM journal_entry_line_item AS jeli 

           JOIN `account` AS a USING(account_id) 

           JOIN journal_entry AS je USING(journal_entry_id) 

           WHERE account_code LIKE '401%' 

           AND YEAR(entry_date) = 2019), 2) AS Revenue_2019, 

    ROUND((SELECT SUM(COALESCE(debit, 0)) / 1000 

           FROM journal_entry_line_item AS jeli 

           JOIN `account` AS a USING(account_id) 

           JOIN journal_entry AS je USING(journal_entry_id) 

           WHERE account_code LIKE '501%' 

           AND YEAR(entry_date) = 2019), 2) AS COGS_2019, 

    ROUND((SELECT SUM(COALESCE(credit, 0)) / 1000 

           FROM journal_entry_line_item AS jeli 

           JOIN `account` AS a USING(account_id) 

           JOIN journal_entry AS je USING(journal_entry_id) 

           WHERE account_code LIKE '401%' 

           AND YEAR(entry_date) = 2019) - 

          (SELECT SUM(COALESCE(debit, 0)) / 1000 

           FROM journal_entry_line_item AS jeli 

           JOIN `account` AS a USING(account_id) 

           JOIN journal_entry AS je USING(journal_entry_id) 

           WHERE account_code LIKE '501%' 

           AND YEAR(entry_date) = 2019), 2) AS Gross_Profit,
           
           
           ROUND((SELECT SUM(COALESCE(debit, 0)) / 1000 

           FROM journal_entry_line_item AS jeli 

           JOIN `account` AS a USING(account_id) 

           JOIN journal_entry AS je USING(journal_entry_id) 

           WHERE account_code LIKE '601%' 

           AND YEAR(entry_date) = 2019), 2) AS Selling_Expenses_2019,
           
           ROUND((SELECT SUM(COALESCE(debit, 0)) / 1000 

           FROM journal_entry_line_item AS jeli 

           JOIN `account` AS a USING(account_id) 

           JOIN journal_entry AS je USING(journal_entry_id) 

           WHERE account_code LIKE '701%' 

           AND YEAR(entry_date) = 2019), 2) AS Other_Expenses_2019,
           
           (ROUND((SELECT SUM(COALESCE(debit, 0)) / 1000 

           FROM journal_entry_line_item AS jeli 

           JOIN `account` AS a USING(account_id) 

           JOIN journal_entry AS je USING(journal_entry_id) 

           WHERE account_code LIKE '601%' 

           AND YEAR(entry_date) = 2019), 2) + 
           ROUND((SELECT SUM(COALESCE(debit, 0)) / 1000 

           FROM journal_entry_line_item AS jeli 

           JOIN `account` AS a USING(account_id) 

           JOIN journal_entry AS je USING(journal_entry_id) 

           WHERE account_code LIKE '701%'

           AND YEAR(entry_date) = 2019), 2)) AS Total_Expenses_2019,
           
           ROUND((SELECT SUM(COALESCE(credit, 0)) / 1000 

           FROM journal_entry_line_item AS jeli 

           JOIN `account` AS a USING(account_id) 

           JOIN journal_entry AS je USING(journal_entry_id) 

           WHERE account_code LIKE '401%' 

           AND YEAR(entry_date) = 2019) - 

          (SELECT SUM(COALESCE(debit, 0)) / 1000 

           FROM journal_entry_line_item AS jeli 

           JOIN `account` AS a USING(account_id) 

           JOIN journal_entry AS je USING(journal_entry_id) 

           WHERE account_code LIKE '501%' 

           AND YEAR(entry_date) = 2019), 2) - (ROUND((SELECT SUM(COALESCE(debit, 0)) / 1000 

           FROM journal_entry_line_item AS jeli 

           JOIN `account` AS a USING(account_id) 

           JOIN journal_entry AS je USING(journal_entry_id) 

           WHERE account_code LIKE '601%' 

           AND YEAR(entry_date) = 2019), 2) + 
           ROUND((SELECT SUM(COALESCE(debit, 0)) / 1000 

           FROM journal_entry_line_item AS jeli 

           JOIN `account` AS a USING(account_id) 

           JOIN journal_entry AS je USING(journal_entry_id) 

           WHERE account_code LIKE '701%'

           AND YEAR(entry_date) = 2019), 2)) AS EBIT,
           
           ROUND((SELECT SUM(COALESCE(debit, 0)) / 1000 

           FROM journal_entry_line_item AS jeli 

           JOIN `account` AS a USING(account_id) 

           JOIN journal_entry AS je USING(journal_entry_id) 

           WHERE account_code LIKE '611%' 

           AND YEAR(entry_date) = 2019), 2) AS Income_Tax_2019
;