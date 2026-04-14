-- Select the database to use
USE bank_loan_db;

-- Create table to store loan data
CREATE TABLE financial_loan (
    id BIGINT NOT NULL,                      -- Unique loan ID (Primary Key)
    address_state VARCHAR(10),              -- State of borrower
    application_type VARCHAR(50),           -- Type of application
    emp_length VARCHAR(20),                 -- Employment duration
    emp_title VARCHAR(100),                 -- Job title
    grade VARCHAR(5),                       -- Loan grade
    home_ownership VARCHAR(20),             -- Ownership status
    issue_date DATE,                        -- Loan issue date
    last_credit_pull_date DATE,             -- Last credit check
    last_payment_date DATE,                 -- Last payment date
    loan_status VARCHAR(50),                -- Loan status
    next_payment_date DATE,                 -- Next due date
    member_id BIGINT,                       -- Member ID
    purpose VARCHAR(100),                   -- Purpose of loan
    sub_grade VARCHAR(10),                  -- Sub category of grade
    term VARCHAR(20),                       -- Loan term (e.g., 36 months)
    verification_status VARCHAR(50),        -- Income verification status
    annual_income BIGINT,                   -- Borrower's income
    dti DECIMAL(10, 2),                     -- Debt-to-income ratio
    installment DECIMAL(10, 2),             -- Monthly installment
    int_rate DECIMAL(6, 4),                 -- Interest rate
    loan_amount BIGINT,                     -- Loan amount funded
    total_acc INT,                          -- Total accounts
    total_payment BIGINT,                   -- Total payment received
    PRIMARY KEY (id)
);

-- Count total number of loan applications
SELECT COUNT(id) AS Total_Applications 
FROM financial_loan;

-- Count applications issued in December
SELECT COUNT(id) AS Total_Applications 
FROM financial_loan
WHERE MONTH(issue_date) = 12;

-- Count applications issued in November
SELECT COUNT(id) AS Total_Applications 
FROM financial_loan
WHERE MONTH(issue_date) = 11;

-- Total funded loan amount
SELECT SUM(loan_amount) AS Total_Funded_Amount 
FROM financial_loan;

-- Funded amount for December
SELECT SUM(loan_amount) AS Total_Funded_Amount 
FROM financial_loan
WHERE MONTH(issue_date) = 12;

-- Funded amount for November
SELECT SUM(loan_amount) AS Total_Funded_Amount 
FROM financial_loan
WHERE MONTH(issue_date) = 11;

-- Total amount collected from borrowers
SELECT SUM(total_payment) AS Total_Amount_Collected 
FROM financial_loan;

-- Amount collected in December
SELECT SUM(total_payment) AS Total_Amount_Collected 
FROM financial_loan
WHERE MONTH(issue_date) = 12;

-- Amount collected in November
SELECT SUM(total_payment) AS Total_Amount_Collected 
FROM financial_loan
WHERE MONTH(issue_date) = 11;

-- View all records
SELECT * FROM financial_loan;

-- Average interest rate (converted to percentage)
SELECT ROUND(AVG(int_rate)*100,2) AS Average_Interest_rate 
FROM financial_loan;

-- Month-To-Date (MTD) interest rate for Dec 2021
SELECT ROUND(AVG(int_rate)*100,2) AS MTD_Average_Interest_rate 
FROM financial_loan
WHERE MONTH(issue_date)=12 AND YEAR(issue_date)=2021;

-- Previous Month-To-Date (PMTD) interest rate for Nov 2021
SELECT ROUND(AVG(int_rate)*100,2) AS PMTD_Average_Interest_rate 
FROM financial_loan
WHERE MONTH(issue_date)=11 AND YEAR(issue_date)=2021;

-- Average Debt-to-Income ratio
SELECT ROUND(AVG(dti)*100,2) AS Average_dti 
FROM financial_loan;

-- DTI for December
SELECT ROUND(AVG(dti)*100,2) AS Average_dti 
FROM financial_loan
WHERE MONTH(issue_date)=12 AND YEAR(issue_date)=2021;

-- DTI for November
SELECT ROUND(AVG(dti)*100,2) AS Average_dti 
FROM financial_loan
WHERE MONTH(issue_date)=11 AND YEAR(issue_date)=2021;

-- GOOD LOAN PERCENTAGE (Fully Paid + Current loans)
SELECT 
    (COUNT(CASE 
        WHEN loan_status IN ('Fully Paid', 'Current') THEN id 
    END) * 100.0) / COUNT(id) AS Good_loan_percentage
FROM financial_loan;

-- Count of good loan applications
SELECT COUNT(id) AS Good_loan_applications 
FROM financial_loan 
WHERE loan_status IN('Fully Paid','Current');

-- Total funded amount for good loans
SELECT SUM(loan_amount) AS Good_loan_funded_amount 
FROM financial_loan 
WHERE loan_status IN('Fully Paid','Current');

-- Total received amount for good loans
SELECT SUM(total_payment) AS Good_loan_amount_received 
FROM financial_loan 
WHERE loan_status IN('Fully Paid','Current');

-- BAD LOAN PERCENTAGE (Charged Off loans)
SELECT 
    (COUNT(CASE 
        WHEN loan_status ="Charged Off" THEN id 
    END) * 100.0) / COUNT(id) AS Bad_loan_percentage
FROM financial_loan;

-- Count of bad loan applications
SELECT COUNT(id) AS bad_loan_applications 
FROM financial_loan 
WHERE loan_status = 'Charged Off';

-- Total funded for bad loans
SELECT SUM(loan_amount) AS bad_loan_amount 
FROM financial_loan 
WHERE loan_status ='Charged Off';

-- Total received for bad loans
SELECT SUM(total_payment) AS bad_loan_amount_received 
FROM financial_loan 
WHERE loan_status ='Charged Off';

-- Loan status summary (KPI dashboard style)
SELECT
    loan_status, 
    COUNT(id) AS LoanCount,
    SUM(loan_amount) AS Funded_Amount,
    SUM(total_payment) AS Amount_received,
    AVG(int_rate*100) AS Interest_rate,
    AVG(dti*100) AS DTI
FROM financial_loan 
GROUP BY loan_status;

-- Monthly loan summary (applications + funding + received)
SELECT
    MONTH(issue_date) AS Month_Number,
    MONTHNAME(issue_date) AS Month_Name,
    COUNT(id) AS Total_Loan_application,
    SUM(loan_amount) AS Total_funded_amount,
    SUM(total_payment) AS Total_received_amount
FROM financial_loan
GROUP BY MONTH(issue_date), MONTHNAME(issue_date)
ORDER BY MONTH(issue_date);

-- Loan distribution by state
SELECT 
    address_state,
    COUNT(id) AS Total_loan_application,
    SUM(loan_amount) AS Total_funded_amount,
    SUM(total_payment) AS Total_Received_amount
FROM financial_loan
GROUP BY address_state
ORDER BY address_state;

-- Loan distribution by term (e.g., 36 vs 60 months)
SELECT 
    term,
    COUNT(id) AS Total_loan_application,
    SUM(loan_amount) AS Total_funded_amount,
    SUM(total_payment) AS Total_Received_amount
FROM financial_loan
GROUP BY term
ORDER BY term;

-- Loan distribution by employment length
SELECT 
    emp_length,
    COUNT(id) AS Total_loan_application,
    SUM(loan_amount) AS Total_funded_amount,
    SUM(total_payment) AS Total_Received_amount
FROM financial_loan
GROUP BY emp_length
ORDER BY emp_length;

-- Loan purpose analysis
SELECT 
    purpose,
    COUNT(id) AS Total_loan_application,
    SUM(loan_amount) AS Total_funded_amount,
    SUM(total_payment) AS Total_Received_amount
FROM financial_loan
GROUP BY purpose
ORDER BY purpose;

-- Loan distribution by home ownership
SELECT 
    home_ownership,
    COUNT(id) AS Total_loan_application,
    SUM(loan_amount) AS Total_funded_amount,
    SUM(total_payment) AS Total_Received_amount
FROM financial_loan
GROUP BY home_ownership
ORDER BY COUNT(id) DESC;