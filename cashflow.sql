USE H_Accounting;
SELECT YEAR(entry_date),MONTH(entry_date), ROUND(SUM(COALESCE(credit,0))-SUM(COALESCE(debit,0)),2) AS cashflow
FROM journal_entry
JOIN journal_entry_line_item USING(journal_entry_id)
JOIN account USING(account_id)
WHERE account LIKE '%CASH%'
GROUP BY YEAR(entry_date), MONTH(entry_date);