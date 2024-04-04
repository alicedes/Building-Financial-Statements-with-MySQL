USE H_Accounting;

DROP PROCEDURE IF EXISTS `P&L_Statement_gp4`;

DELIMITER //
CREATE PROCEDURE `P&L_Statement_gp4` (IN yearasked SMALLINT)
BEGIN
    DECLARE rev DOUBLE DEFAULT 0;
    DECLARE varcogs DOUBLE DEFAULT 0;
    DECLARE gp DOUBLE DEFAULT 0;
    DECLARE rrd DOUBLE DEFAULT 0;
    DECLARE adminexp DOUBLE DEFAULT 0;
    DECLARE sellexp DOUBLE DEFAULT 0;
    DECLARE othexp DOUBLE DEFAULT 0;
    DECLARE opexp DOUBLE DEFAULT 0;
    DECLARE othinc DOUBLE DEFAULT 0;
    DECLARE ebit DOUBLE DEFAULT 0;
    DECLARE inctax DOUBLE DEFAULT 0;
    DECLARE othtax DOUBLE DEFAULT 0;
    DECLARE netinc DOUBLE DEFAULT 0;
    DECLARE revnxt DOUBLE DEFAULT 0;
    DECLARE cogsnxt DOUBLE DEFAULT 0;
    DECLARE gpnxt DOUBLE DEFAULT 0;
    DECLARE rrdnxt DOUBLE DEFAULT 0;
    DECLARE adminexpnxt DOUBLE DEFAULT 0;
    DECLARE sellexpnxt DOUBLE DEFAULT 0;
    DECLARE othexpnxt DOUBLE DEFAULT 0;
    DECLARE opexpnxt DOUBLE DEFAULT 0;
    DECLARE othincnxt DOUBLE DEFAULT 0;
    DECLARE ebitnxt DOUBLE DEFAULT 0;
    DECLARE inctaxnxt DOUBLE DEFAULT 0;
    DECLARE othtaxnxt DOUBLE DEFAULT 0;
    DECLARE netincnxt DOUBLE DEFAULT 0;
    -- Assign values to variables
DROP VIEW IF EXISTS adestrait_view;
CREATE VIEW adestrait_view AS
	SELECT 
    DISTINCT YEAR(entry_date) AS year,
    COALESCE(
        (SELECT ROUND(SUM(COALESCE(credit, 0))/1000, 2) 
         FROM journal_entry_line_item AS jeli 
         JOIN `account` AS a USING(account_id) 
         JOIN journal_entry AS je USING(journal_entry_id) 
         WHERE account_code LIKE '401%' 
         AND YEAR(je.entry_date) = year
         GROUP BY YEAR(entry_date)), 0) AS Revenue,

    COALESCE(
        (SELECT ROUND(SUM(COALESCE(debit, 0))/1000, 2) 
         FROM journal_entry_line_item AS jeli 
         JOIN `account` AS a USING(account_id) 
         JOIN journal_entry AS je USING(journal_entry_id) 
         WHERE account_code LIKE '501%' 
         AND YEAR(je.entry_date) = year
         GROUP BY YEAR(entry_date)), 0) AS COGS,

    COALESCE(
        (SELECT COALESCE(SUM(credit), SUM(debit), 0)  
         FROM journal_entry_line_item AS jeli 
         JOIN `account` AS a USING(account_id) 
         JOIN journal_entry AS je USING(journal_entry_id) 
         JOIN statement_section AS st ON a.profit_loss_section_id = st.statement_section_id 
         WHERE statement_section_code = 'RET' 
         AND cancelled = 0
         AND YEAR(je.entry_date) = year
         GROUP BY YEAR(entry_date)), 0) AS Return_Refund_Discount,

    COALESCE(
        (SELECT ROUND(SUM(COALESCE(jeli.credit, 0) - COALESCE(jeli.debit, 0)) / 1000, 2) 
         FROM journal_entry_line_item AS jeli 
         JOIN `account` AS a USING(account_id) 
         JOIN journal_entry AS je USING(journal_entry_id) 
         JOIN statement_section AS st ON a.profit_loss_section_id = st.statement_section_id 
         WHERE statement_section LIKE 'ADMIN%' 
         AND YEAR(je.entry_date) = year
         GROUP BY YEAR(entry_date)), 0) AS Administrative_Expenses,

    COALESCE(
        (SELECT ROUND(SUM(COALESCE(debit, 0)) / 1000 , 2)  
         FROM journal_entry_line_item AS jeli  
         JOIN `account` AS a USING(account_id)  
         JOIN journal_entry AS je USING(journal_entry_id)  
         WHERE account_code LIKE '601%'  
         AND YEAR(je.entry_date) = year
         GROUP BY YEAR(entry_date)), 0) AS Selling_Expenses,

    COALESCE(
        (SELECT ROUND(SUM(COALESCE(debit, 0)) / 1000, 2)  
         FROM journal_entry_line_item AS jeli 
         JOIN `account` AS a USING(account_id) 
         JOIN journal_entry AS je USING(journal_entry_id) 
         WHERE a.account_code LIKE '701%' 
         AND YEAR(je.entry_date) = year
         GROUP BY YEAR(entry_date)), 0) AS Other_Expenses,

    COALESCE(
        (SELECT COALESCE(SUM(COALESCE(jeli.credit, 0)) - SUM(COALESCE(jeli.debit, 0)), 0)  
         FROM account AS ac 
         JOIN journal_entry_line_item AS jeli ON ac.account_id = jeli.account_id 
         JOIN journal_entry AS je ON jeli.journal_entry_id = je.journal_entry_id 
         JOIN statement_section AS st ON ac.profit_loss_section_id = st.statement_section_id 
         WHERE st.statement_section_code LIKE '%Other Income%' 
         AND YEAR(je.entry_date) = year
         GROUP BY YEAR(entry_date)), 0) AS Other_Income,

    COALESCE(
        (SELECT COALESCE(SUM(COALESCE(credit, 0)) / 1000, 0) 
         FROM journal_entry_line_item AS jeli 
         JOIN account AS a USING(account_id) 
         JOIN journal_entry AS je USING(journal_entry_id) 
         WHERE account_code LIKE '611%' 
         AND YEAR(je.entry_date) = year
         GROUP BY YEAR(entry_date)), 0) AS Income_Tax,

    COALESCE(
        (SELECT SUM(COALESCE(debit, 0)) 
         FROM journal_entry_line_item AS jeli 
         JOIN `account` AS a USING(account_id) 
         JOIN journal_entry AS je USING(journal_entry_id) 
         WHERE account_code LIKE '601-58-007' 
         AND YEAR(je.entry_date) = year
         GROUP BY YEAR(entry_date)), 0) AS Other_Tax

		FROM journal_entry
		WHERE YEAR(entry_date) <> 2002
		AND YEAR(entry_date) <> 2014;
        
	SELECT Revenue, 
		   COGS, 
           ROUND(Revenue-COGS,2), 
           Return_Refund_Discount,
           Administrative_Expenses, 
           Selling_Expenses, 
           Other_Expenses,
           Return_Refund_Discount + Administrative_Expenses + Selling_Expenses + Other_Expenses,
           Other_Income,
           ROUND((Revenue-COGS) - (Return_Refund_Discount + Administrative_Expenses + Selling_Expenses + Other_Expenses) + Other_Income,2),
           Income_Tax,
           Other_Tax,
           ROUND((Revenue-COGS) - (Return_Refund_Discount + Administrative_Expenses + Selling_Expenses + Other_Expenses) + Other_Income - Income_Tax - Other_Tax,2)
    INTO rev, varcogs, gp, rrd, adminexp, sellexp, othexp, opexp, othinc, ebit, inctax, othtax, netinc
    FROM adestrait_view
    WHERE `year` = yearasked;
	SELECT Revenue, COGS, ROUND(Revenue-COGS,2), Return_Refund_Discount,
           Administrative_Expenses, Selling_Expenses, Other_Expenses,
           Return_Refund_Discount + Administrative_Expenses + Selling_Expenses + Other_Expenses,
           Other_Income,
           ROUND((Revenue-COGS) - (Return_Refund_Discount + Administrative_Expenses + Selling_Expenses + Other_Expenses) + Other_Income,2),
           Income_Tax,
           Other_Tax,
           ROUND((Revenue-COGS) - (Return_Refund_Discount + Administrative_Expenses + Selling_Expenses + Other_Expenses) + Other_Income - Income_Tax - Other_Tax,2)
    INTO revnxt, cogsnxt, gpnxt, rrdnxt, adminexpnxt, sellexpnxt, othexpnxt, opexpnxt, othincnxt, ebitnxt, inctaxnxt, othtaxnxt, netincnxt
    FROM adestrait_view
    WHERE `year` = yearasked +1;
    SELECT rev, varcogs, gp, rrd, adminexp, sellexp, othexp, opexp, othinc, ebit, inctax, othtax, netinc;

END //
DELIMITER ;

-- Call the procedure
CALL `P&L_Statement_gp4`(2019);
