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
