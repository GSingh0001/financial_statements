# Financial Data Analysis Procedures

## Overview
This repository contains stored procedures for analyzing financial data within the `H_Accounting` database. These procedures focus on generating balance sheets and profit and loss statements for a specified calendar year, providing a comprehensive overview of a company's financial performance.

## Project Details
**Institution:** Hult International Business School  
**Course:** Data Management & SQL - DAT-5486 - BMBAN1  
**Professor:** Prof. Luis Escamilla  
**Author:** Ganga Singh
**Date:** 11-14-2023

## Executive Summary
This project includes two main stored procedures:

1. **Balance Sheet Procedure (`gsingh3_sp`):**
   - Generates a balance sheet for a specified year.
   - Calculates total debits, total credits, net totals, and percentage change from the previous year for each statement section.
   
2. **Profit and Loss Statement Procedure (`phawes_t10_sp`):**
   - Produces a profit and loss statement for a specified year.
   - Computes revenues, costs of goods sold (COGS), returns, general expenses, selling expenses, other expenses, other income, income tax, other tax, and net income.
   - Includes a temporary table to format and present the results.

## Project Components
- **Balance Sheet Procedure:** `gsingh3_sp`
- **Profit and Loss Statement Procedure:** `phawes_t10_sp`
- **SQL Query File:** 

## Procedures
### Balance Sheet Procedure (`gsingh3_sp`)
The `gsingh3_sp` stored procedure generates a balance sheet for a given calendar year. It includes the following key features:
- Calculates total debits, total credits, and net totals for each statement section.
- Computes the percentage change in net totals from the previous year.
- Organizes the results by statement section order.

**Usage:**
```sql
CALL `gsingh3_sp`(2019);
