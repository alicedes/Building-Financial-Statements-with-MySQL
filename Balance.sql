USE H_Accounting;

DROP PROCEDURE IF EXISTS balance_gp4;

DELIMITER \\
CREATE PROCEDURE balance_gp4(varYear SMALLINT)
BEGIN
    SELECT 'Current Assets' AS Balance_sheet,
		ROUND((SUM(CASE WHEN balance_sheet_section_id = 67 THEN COALESCE((credit), 0) ELSE 0 END) -
		SUM(CASE WHEN balance_sheet_section_id = 67 THEN COALESCE((debit), 0) ELSE 0 END) +
		SUM(CASE WHEN balance_sheet_section_id IN (63, 64, 65) THEN COALESCE((credit), 0) ELSE 0 END) -
		SUM(CASE WHEN balance_sheet_section_id IN (63, 64, 65) THEN COALESCE((debit), 0) ELSE 0 END))/1000, 3) AS Current_year
	FROM journal_entry_line_item
	JOIN H_Accounting.account USING (account_id) 
    JOIN journal_entry USING(journal_entry_id)
	WHERE YEAR(entry_date) <= varYear 
    AND cancelled = 0

-- liabilities
	UNION SELECT 'Current Liabilities' AS Balance_sheet,
		ROUND(SUM(CASE WHEN balance_sheet_section_id = 64 THEN COALESCE((credit), 0) ELSE 0 END)/1000 -
        SUM(CASE WHEN balance_sheet_section_id = 64 THEN COALESCE((debit), 0) ELSE 0 END)/1000, 3) AS Current_year
	FROM journal_entry_line_item
	JOIN H_Accounting.account USING (account_id) 
    JOIN journal_entry USING(journal_entry_id)
	WHERE YEAR(entry_date) <= varYear 
    AND cancelled = 0

-- Equity
	UNION SELECT 'Current Equity' AS Balance_sheet,
		ROUND(SUM(CASE WHEN balance_sheet_section_id = 67 THEN COALESCE((credit), 0) ELSE 0 END)/1000 -
        SUM(CASE WHEN balance_sheet_section_id = 67 THEN COALESCE((debit), 0) ELSE 0 END)/1000, 3) AS Current_year
	FROM journal_entry_line_item
	JOIN H_Accounting.account USING (account_id)  
    JOIN journal_entry USING(journal_entry_id)
	WHERE YEAR(entry_date) <= varYear 
    AND cancelled = 0;
END \\
DELIMITER ;

CALL balance_gp4(2019);