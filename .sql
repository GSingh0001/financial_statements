USE H_Accounting;

## Balance Sheet Stored Procedure
DROP PROCEDURE IF EXISTS `gsingh3_sp`;

DELIMITER $$
CREATE PROCEDURE `gsingh3_sp`(varCalendarYear SMALLINT)
BEGIN

    SELECT 
        sc.statement_section,
        FORMAT(COALESCE(current_year.total_debit, 0), 2) AS total_debit,
        FORMAT(COALESCE(current_year.total_credit, 0), 2) AS total_credit,
        FORMAT(COALESCE(current_year.total, 0), 2) AS total,
        FORMAT(COALESCE(((COALESCE(current_year.total, 0) - COALESCE(last_year.total, 0)) / NULLIF(COALESCE(last_year.total, 0), 0)) * 100, 0), 2) AS PChange
    FROM 
        statement_section sc
    LEFT JOIN (
        SELECT 
            a.balance_sheet_section_id, sum(coalesce(i.debit, 0)) as total_debit,
			sum(coalesce(i.credit, 0)) as total_credit,
            SUM(CASE 
                WHEN sc.debit_is_positive = 1 THEN coalesce(i.debit, 0) - coalesce(i.credit, 0)
                ELSE coalesce(i.credit, 0) - coalesce(i.debit, 0)
            END) AS total
        FROM 
            account a
        INNER JOIN 
            journal_entry_line_item i ON a.account_id = i.account_id
        INNER JOIN 
            journal_entry e ON i.journal_entry_id = e.journal_entry_id
        INNER JOIN 
            statement_section sc ON a.balance_sheet_section_id = sc.statement_section_id
        WHERE 
            e.cancelled = 0 AND YEAR(e.entry_date) = varCalendarYear
        GROUP BY 
            a.balance_sheet_section_id
    ) AS current_year ON sc.statement_section_id = current_year.balance_sheet_section_id
    LEFT JOIN (
        SELECT 
            a.balance_sheet_section_id,
            SUM(CASE 
                WHEN sc.debit_is_positive = 1 THEN coalesce(i.debit, 0) - coalesce(i.credit, 0)
                ELSE coalesce(i.credit, 0) - coalesce(i.debit, 0)
            END) AS total
        FROM 
            account a
        INNER JOIN 
            journal_entry_line_item i ON a.account_id = i.account_id
        INNER JOIN 
            journal_entry e ON i.journal_entry_id = e.journal_entry_id
        INNER JOIN 
            statement_section sc ON a.balance_sheet_section_id = sc.statement_section_id
        WHERE 
            e.cancelled = 0 AND YEAR(e.entry_date) = varCalendarYear - 1
        GROUP BY 
            a.balance_sheet_section_id
    ) AS last_year ON sc.statement_section_id = last_year.balance_sheet_section_id
    WHERE 
        sc.is_balance_sheet_section = 1 AND sc.company_id = 1
    ORDER BY 
        sc.statement_section_order;

END $$
DELIMITER ;

CALL `gsingh3_sp`(2019);

-- -----------

USE H_Accounting;

				   
## PNL Stored Procedure
DROP PROCEDURE IF EXISTS `phawes_t10_sp`;

DELIMITER $$
CREATE PROCEDURE `phawes_t10_sp`(varCalendarYear SMALLINT)
BEGIN
    DECLARE varRevenueThisYear DOUBLE;
    DECLARE varRevenueLastYear DOUBLE;
    DECLARE varCogsThisYear DOUBLE;
    DECLARE varCogsLastYear DOUBLE;
    DECLARE varRetThisYear DOUBLE;
    DECLARE varRetLastYear DOUBLE;
    DECLARE varGexpThisYear DOUBLE;
    DECLARE varGexpLastYear DOUBLE;
    DECLARE varSexpThisYear DOUBLE;
    DECLARE varSexpLastYear DOUBLE;
    DECLARE varOexpThisYear DOUBLE;
    DECLARE varOexpLastYear DOUBLE;
    DECLARE varOiThisYear DOUBLE;
    DECLARE varOiLastYear DOUBLE;
    DECLARE varInctaxThisYear DOUBLE;
    DECLARE varInctaxLastYear DOUBLE;
    DECLARE varOthtaxThisYear DOUBLE;
    DECLARE varOthtaxLastYear DOUBLE;
	
    -- CURRENT YEAR ---
    -- REVENUES
    SELECT SUM(jeli.credit) INTO varRevenueThisYear
    FROM journal_entry_line_item AS jeli
    INNER JOIN account AS ac ON ac.account_id = jeli.account_id
    INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
    INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
    WHERE ss.statement_section_code IN ("REV")
      AND YEAR(je.entry_date) = varCalendarYear;

    -- COGS
    SELECT SUM(jeli.debit) INTO varCogsThisYear
    FROM journal_entry_line_item AS jeli
    INNER JOIN account AS ac ON ac.account_id = jeli.account_id
    INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
    INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
    WHERE ss.statement_section_code IN ("COGS")
      AND YEAR(je.entry_date) = varCalendarYear;
      
    -- RET
    SELECT SUM(jeli.debit) INTO varRetThisYear
    FROM journal_entry_line_item AS jeli
    INNER JOIN `account` AS ac ON ac.account_id = jeli.account_id
    INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
    INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
    WHERE ss.statement_section_code IN ("RET")
      AND YEAR(je.entry_date) = varCalendarYear;

    -- GEXP
    SELECT SUM(jeli.debit) INTO varGexpThisYear
    FROM journal_entry_line_item AS jeli
    INNER JOIN account AS ac ON ac.account_id = jeli.account_id
    INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
    INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
    WHERE ss.statement_section_code IN ("GEXP")
      AND YEAR(je.entry_date) = varCalendarYear;

    -- SEXP
    SELECT SUM(jeli.debit) INTO varSexpThisYear
    FROM journal_entry_line_item AS jeli
    INNER JOIN account AS ac ON ac.account_id = jeli.account_id
    INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
    INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
    WHERE ss.statement_section_code IN ("SEXP")
      AND YEAR(je.entry_date) = varCalendarYear;

    -- OEXP
    SELECT SUM(jeli.debit) INTO varOexpThisYear
    FROM journal_entry_line_item AS jeli
    INNER JOIN account AS ac ON ac.account_id = jeli.account_id
    INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
    INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
    WHERE ss.statement_section_code IN ("OEXP")
      AND YEAR(je.entry_date) = varCalendarYear;

    -- OI
    SELECT SUM(jeli.credit) INTO varOiThisYear
    FROM journal_entry_line_item AS jeli
    INNER JOIN account AS ac ON ac.account_id = jeli.account_id
    INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
    INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
    WHERE ss.statement_section_code IN ("OI")
      AND YEAR(je.entry_date) = varCalendarYear;

    -- INCTAX
    SELECT SUM(jeli.credit) INTO varInctaxThisYear
    FROM journal_entry_line_item AS jeli
    INNER JOIN account AS ac ON ac.account_id = jeli.account_id
    INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
    INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
    WHERE ss.statement_section_code IN ("INCTAX")
      AND YEAR(je.entry_date) = varCalendarYear;

    -- OTHTAX
    SELECT SUM(jeli.debit) INTO varOthtaxThisYear
    FROM journal_entry_line_item AS jeli
    INNER JOIN account AS ac ON ac.account_id = jeli.account_id
    INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
    INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
    WHERE ss.statement_section_code IN ("OTHTAX")
      AND YEAR(je.entry_date) = varCalendarYear;

    -- LAST YEAR ---
    -- REVENUES
    SELECT SUM(jeli.credit) INTO varRevenueLastYear
    FROM journal_entry_line_item AS jeli
    INNER JOIN account AS ac ON ac.account_id = jeli.account_id
    INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
    INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
    WHERE ss.statement_section_code IN ("REV")
      AND YEAR(je.entry_date) = varCalendarYear-1;

    -- COGS
    SELECT SUM(jeli.debit) INTO varCogsLastYear
    FROM journal_entry_line_item AS jeli
    INNER JOIN account AS ac ON ac.account_id = jeli.account_id
    INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
    INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
    WHERE ss.statement_section_code IN ("COGS")
      AND YEAR(je.entry_date) = varCalendarYear-1;
      
    -- RET
    SELECT SUM(jeli.debit) INTO varRetLastYear
    FROM journal_entry_line_item AS jeli
    INNER JOIN account AS ac ON ac.account_id = jeli.account_id
    INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
    INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
    WHERE ss.statement_section_code IN ("RET")
      AND YEAR(je.entry_date) = varCalendarYear-1;

    -- GEXP
    SELECT SUM(jeli.debit) INTO varGexpLastYear
    FROM journal_entry_line_item AS jeli
    INNER JOIN account AS ac ON ac.account_id = jeli.account_id
    INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
    INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
    WHERE ss.statement_section_code IN ("GEXP")
      AND YEAR(je.entry_date) = varCalendarYear-1;

    -- SEXP
    SELECT SUM(jeli.debit) INTO varSexpLastYear
    FROM journal_entry_line_item AS jeli
    INNER JOIN account AS ac ON ac.account_id = jeli.account_id
    INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
    INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
    WHERE ss.statement_section_code IN ("SEXP")
      AND YEAR(je.entry_date) = varCalendarYear-1;

    -- OEXP
    SELECT SUM(jeli.debit) INTO varOexpLastYear
    FROM journal_entry_line_item AS jeli
    INNER JOIN account AS ac ON ac.account_id = jeli.account_id
    INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
    INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
    WHERE ss.statement_section_code IN ("OEXP")
      AND YEAR(je.entry_date) = varCalendarYear-1;

    -- OI
    SELECT SUM(jeli.credit) INTO varOiLastYear
    FROM journal_entry_line_item AS jeli
    INNER JOIN account AS ac ON ac.account_id = jeli.account_id
    INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
    INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
    WHERE ss.statement_section_code IN ("OI")
      AND YEAR(je.entry_date) = varCalendarYear-1;

    -- INCTAX
    SELECT SUM(jeli.credit) INTO varInctaxLastYear
    FROM journal_entry_line_item AS jeli
    INNER JOIN account AS ac ON ac.account_id = jeli.account_id
    INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
    INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
    WHERE ss.statement_section_code IN ("INCTAX")
      AND YEAR(je.entry_date) = varCalendarYear-1;

    -- OTHTAX
    SELECT SUM(jeli.debit) INTO varOthtaxLastYear
    FROM journal_entry_line_item AS jeli
    INNER JOIN account AS ac ON ac.account_id = jeli.account_id
    INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
    INNER JOIN statement_section AS ss ON ss.statement_section_id = ac.profit_loss_section_id
    WHERE ss.statement_section_code IN ("OTHTAX")
      AND YEAR(je.entry_date) = varCalendarYear-1;


    -- DROP TMP TABLE, TO INSERT THE VALUES INTO THE TMP FORMATTED
    DROP TABLE IF EXISTS phawes_tmp;

    -- CREATE TMP TABLE AND INSERT VALUES FOR CURRENT AND LAST YEAR FOR EACH VARIABLE
-- CREATE TMP TABLE AND INSERT VALUES FOR CURRENT AND LAST YEAR FOR EACH VARIABLE
CREATE TABLE phawes_tmp AS 
SELECT CAST("Revenue" AS CHAR(50)) AS "Category", FORMAT(varRevenueThisYear, 1) AS "Current Year", FORMAT(varRevenueLastYear, 1) AS "Last Year", FORMAT((varRevenueThisYear / varRevenueLastYear - 1) * 100, 1) AS "% Change";
    -- Repeat INSERT INTO for COGS, RET, GEXP, SEXP, OEXP, OI, INCTAX, OTHTAX
	    -- INSERT FOR COGS
    INSERT INTO phawes_tmp
    SELECT "COGS", FORMAT(varCogsThisYear, 1) AS "Current Year", FORMAT(varCogsLastYear, 1) AS "Last Year", FORMAT((varCogsThisYear / varCogsLastYear - 1) * 100, 1) AS "% Change";
	
    
  #      -- GROSS PROFIT
   INSERT INTO phawes_tmp
   SELECT "Gross Profit", FORMAT(varRevenueThisYear-varCogsThisYear, 1) AS "Current Year", FORMAT(varRevenueLastYear-varCogsLastYear, 1) AS "Last Year", FORMAT(((varRevenueThisYear-varCogsThisYear) / (varRevenueLastYear-varCogsLastYear) - 1) * 100, 1) AS "% Change";

    -- INSERT FOR LINE
    INSERT INTO phawes_tmp VALUES ('','','','');

    -- INSERT FOR RET
    INSERT INTO phawes_tmp
    SELECT "Return_Refund_Discount", FORMAT(varRetThisYear, 1) AS "Current Year", FORMAT(varRetLastYear, 1) AS "Last Year", FORMAT((varRetThisYear / varRetLastYear - 1) * 100, 1) AS "% Change";

    -- INSERT FOR GEXP
    INSERT INTO phawes_tmp
    SELECT "General_Expense", FORMAT(varGexpThisYear, 1) AS "Current Year", FORMAT(varGexpLastYear, 1) AS "Last Year", FORMAT((varGexpThisYear / varGexpLastYear - 1) * 100, 1) AS "% Change";

    -- INSERT FOR SEXP
    INSERT INTO phawes_tmp
    SELECT "Selling_Expense", FORMAT(varSexpThisYear, 1) AS "Current Year", FORMAT(varSexpLastYear, 1) AS "Last Year", FORMAT((varSexpThisYear / varSexpLastYear - 1) * 100, 1) AS "% Change";

    -- INSERT FOR OEXP
    INSERT INTO phawes_tmp
    SELECT "Other_Expense", FORMAT(varOexpThisYear, 1) AS "Current Year", FORMAT(varOexpLastYear, 1) AS "Last Year", FORMAT((varOexpThisYear / varOexpLastYear - 1) * 100, 1) AS "% Change";

-- INSERT FOR TOTAL OPERATING EXPENSES
	INSERT INTO phawes_tmp
	SELECT "Total Operating Expenses", 
		   varSexpThisYear + varOexpThisYear AS "Current Year", 
		   varSexpLastYear + varOexpLastYear AS "Last Year", 
		   -- Assuming we are still calculating the percentage change for total operating expenses.
		   -- If not needed, replace with NULL or appropriate default value.
		   FORMAT(((varRetThisYear + varGexpThisYear + varSexpThisYear + varOexpThisYear) - (varRetLastYear + varGexpLastYear + varSexpLastYear + varOexpLastYear)) / (varRetLastYear + varGexpLastYear + varSexpLastYear + varOexpLastYear) * 100, 1) AS "% Change";


	-- INSERT FOR LINE
    INSERT INTO phawes_tmp VALUES ('','','','');
    
    -- INSERT FOR OI
    INSERT INTO phawes_tmp
    SELECT "Other_Income", FORMAT(varOiThisYear, 1) AS "Current Year", FORMAT(varOiLastYear, 1) AS "Last Year", FORMAT((varOiThisYear / varOiLastYear - 1) * 100, 1) AS "% Change";

    -- INSERT FOR INCTAX
    INSERT INTO phawes_tmp
    SELECT "Income_Tax", FORMAT(varInctaxThisYear, 1) AS "Current Year", FORMAT(varInctaxLastYear, 1) AS "Last Year", FORMAT((varInctaxThisYear / varInctaxLastYear - 1) * 100, 1) AS "% Change";

    -- INSERT FOR OTHTAX
    INSERT INTO phawes_tmp
    SELECT "Other_Tax", FORMAT(varOthtaxThisYear, 1) AS "Current Year", FORMAT(varOthtaxLastYear, 1) AS "Last Year", FORMAT((varOthtaxThisYear / varOthtaxLastYear - 1) * 100, 1) AS "% Change";
    
    -- INSERT FOR Net Income
	INSERT INTO phawes_tmp
	SELECT "Net_Income", 
		   varOiThisYear + varInctaxThisYear + varOthtaxThisYear AS "Current Year", 
		   varOiLastYear + varInctaxLastYear + varOthtaxLastYear AS "Last Year", 
		   -- Assuming we are still calculating the percentage change for total operating expenses.
		   -- If not needed, replace with NULL or appropriate default value.
		   FORMAT(((varOiThisYear + varInctaxThisYear + varOthtaxThisYear) - (varOiLastYear + varInctaxLastYear + varOthtaxLastYear)) / (varOiLastYear + varInctaxLastYear + varOthtaxLastYear) * 100, 1) AS "% Change";


    UPDATE phawes_tmp SET 
    `Current Year` = 0
    WHERE `Current Year` IS NULL;
    
    UPDATE phawes_tmp SET 
    `Last Year` = 0                        
    WHERE `Last Year` IS NULL;
    
    UPDATE phawes_tmp SET 
    `% Change` = 0
    WHERE `% Change` IS NULL;
    
    -- SELECT FINAL RESULTS FROM TMP TABLE
    SELECT * FROM phawes_tmp;
END $$
DELIMITER ;

CALL phawes_t10_sp(2020);


