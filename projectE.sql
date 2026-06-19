CREATE DATABASE IF NOT EXISTS ec_chenni1;
USE ec_chenni1;

CREATE TABLE Branches (
    branch_id    INT AUTO_INCREMENT PRIMARY KEY,
    branch_name  VARCHAR(100) NOT NULL,
    city         VARCHAR(50)  NOT NULL,
    state        VARCHAR(50)  NOT NULL,
    ifsc_code    VARCHAR(20)  UNIQUE NOT NULL,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Employees (
    employee_id   INT AUTO_INCREMENT PRIMARY KEY,
    branch_id     INT NOT NULL,
    full_name     VARCHAR(100) NOT NULL,
    designation   VARCHAR(50)  NOT NULL,
    email         VARCHAR(100) UNIQUE NOT NULL,
    phone         VARCHAR(15),
    joined_at     DATE NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES Branches(branch_id)
);

CREATE TABLE Customers (
    customer_id  INT AUTO_INCREMENT PRIMARY KEY,
    full_name    VARCHAR(100) NOT NULL,
    email        VARCHAR(100) UNIQUE NOT NULL,
    phone        VARCHAR(15),
    city         VARCHAR(50),
    branch_id    INT,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (branch_id) REFERENCES Branches(branch_id)
);

CREATE TABLE Accounts (
    account_id    INT AUTO_INCREMENT PRIMARY KEY,
    customer_id   INT NOT NULL,
    account_type  ENUM('Savings','Current','Loan','FD') NOT NULL,
    balance       DECIMAL(15,2) DEFAULT 0.00,
    status        ENUM('Active','Inactive','Closed') DEFAULT 'Active',
    opened_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Transactions (
    txn_id       INT AUTO_INCREMENT PRIMARY KEY,
    account_id   INT NOT NULL,
    txn_type     ENUM('Deposit','Withdrawal','Transfer','EMI_Payment') NOT NULL,
    amount       DECIMAL(15,2) NOT NULL,
    remarks      VARCHAR(200),
    txn_date     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES Accounts(account_id)
);

CREATE TABLE Loans (
    loan_id         INT AUTO_INCREMENT PRIMARY KEY,
    customer_id     INT NOT NULL,
    branch_id       INT NOT NULL,
    loan_type       ENUM('Home','Car','Personal','Business','Education') NOT NULL,
    principal       DECIMAL(15,2) NOT NULL,
    interest_rate   DECIMAL(5,2)  NOT NULL,
    tenure_months   INT NOT NULL,
    emi_amount      DECIMAL(15,2) NOT NULL,
    disbursed_date  DATE NOT NULL,
    status          ENUM('Active','Closed','NPA') DEFAULT 'Active',
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (branch_id)   REFERENCES Branches(branch_id)
);


CREATE TABLE LoanEMISchedule (
    emi_id          INT AUTO_INCREMENT PRIMARY KEY,
    loan_id         INT NOT NULL,
    due_date        DATE NOT NULL,
    emi_amount      DECIMAL(15,2) NOT NULL,
    paid_amount     DECIMAL(15,2) DEFAULT 0.00,
    payment_date    DATE,
    dpd             INT DEFAULT 0,
    status          ENUM('Pending','Paid','Overdue') DEFAULT 'Pending',
    FOREIGN KEY (loan_id) REFERENCES Loans(loan_id)
);


CREATE TABLE Cards (
    card_id       INT AUTO_INCREMENT PRIMARY KEY,
    customer_id   INT NOT NULL,
    card_type     ENUM('Debit','Credit') NOT NULL,
    card_number   VARCHAR(20) UNIQUE NOT NULL,
    expiry_date   DATE NOT NULL,
    credit_limit  DECIMAL(15,2) DEFAULT 0.00,
    status        ENUM('Active','Blocked','Expired') DEFAULT 'Active',
    issued_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE CIBIL_Score (
    cibil_id      INT AUTO_INCREMENT PRIMARY KEY,
    customer_id   INT NOT NULL,
    score         INT NOT NULL CHECK (score BETWEEN 300 AND 900),
    checked_date  DATE NOT NULL,
    remarks       VARCHAR(200),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE NPA_Tracker (
    npa_id        INT AUTO_INCREMENT PRIMARY KEY,
    loan_id       INT NOT NULL,
    customer_id   INT NOT NULL,
    dpd_days      INT NOT NULL,
    npa_category  ENUM('Standard','Sub-Standard','Doubtful','Loss') NOT NULL,
    flagged_date  DATE NOT NULL,
    remarks       VARCHAR(200),
    FOREIGN KEY (loan_id)     REFERENCES Loans(loan_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);


CREATE TABLE CollectionLog (
    collection_id   INT AUTO_INCREMENT PRIMARY KEY,
    loan_id         INT NOT NULL,
    customer_id     INT NOT NULL,
    employee_id     INT NOT NULL,
    contact_date    DATE NOT NULL,
    amount_collected DECIMAL(15,2) DEFAULT 0.00,
    contact_mode    ENUM('Call','Visit','Email','SMS') NOT NULL,
    outcome         ENUM('PTP','Paid','No Response','Refused') NOT NULL,
    notes           VARCHAR(300),
    FOREIGN KEY (loan_id)     REFERENCES Loans(loan_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

CREATE TABLE Audit_Log (
    log_id       INT AUTO_INCREMENT PRIMARY KEY,
    table_name   VARCHAR(50)  NOT NULL,
    action_type  ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    record_id    INT,
    old_value    TEXT,
    new_value    TEXT,
    changed_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO Branches (branch_name, city, state, ifsc_code) VALUES
('Guindy Main Branch',       'Chennai',   'Tamil Nadu', 'CHOL0001001'),
('Koramangala Branch',       'Bangalore', 'Karnataka',  'CHOL0002001'),
('Banjara Hills Branch',     'Hyderabad', 'Telangana',  'CHOL0003001'),
('Connaught Place Branch',   'Delhi',     'Delhi',      'CHOL0004001'),
('Tamarai Tech Park Branch', 'Chennai',   'Tamil Nadu', 'CHOL0001002');

INSERT INTO Employees (branch_id, full_name, designation, email, phone, joined_at) VALUES
(1, 'Arun Selvam',    'Branch Manager',       'arun.selvam@chola.com',    '9000000001', '2020-06-01'),
(1, 'Priya Nair',     'Data Analyst',         'priya.nair@chola.com',     '9000000002', '2022-03-15'),
(2, 'Karthik Raj',    'Loan Officer',         'karthik.raj@chola.com',    '9000000003', '2021-08-10'),
(3, 'Sneha Reddy',    'Collections Agent',    'sneha.reddy@chola.com',    '9000000004', '2023-01-20'),
(5, 'Vikram Anand',   'Senior Analyst',       'vikram.anand@chola.com',   '9000000005', '2019-11-05');

INSERT INTO Customers (full_name, email, phone, city, branch_id) VALUES
('Elan B',        'elan@gmail.com',     '9876543210', 'Chennai',   1),
('Ravi Kumar',    'ravi@gmail.com',     '9123456789', 'Bangalore', 2),
('Meena Devi',    'meena@gmail.com',    '9234567890', 'Hyderabad', 3),
('Suresh Babu',   'suresh@gmail.com',   '9345678901', 'Chennai',   1),
('Anita Sharma',  'anita@gmail.com',    '9456789012', 'Delhi',     4),
('Rajesh Pillai', 'rajesh@gmail.com',   '9567890123', 'Chennai',   5),
('Divya Menon',   'divya@gmail.com',    '9678901234', 'Bangalore', 2);

INSERT INTO Accounts (customer_id, account_type, balance, status) VALUES
(1, 'Savings',  50000.00,  'Active'),
(2, 'Current',  120000.00, 'Active'),
(3, 'Savings',  35000.00,  'Active'),
(4, 'FD',       200000.00, 'Active'),
(5, 'Savings',  15000.00,  'Active'),
(6, 'Loan',     0.00,      'Active'),
(7, 'Savings',  75000.00,  'Inactive');

INSERT INTO Transactions (account_id, txn_type, amount, remarks) VALUES
(1, 'Deposit',     10000.00, 'Salary credit'),
(1, 'Withdrawal',   5000.00, 'ATM withdrawal'),
(2, 'Transfer',    20000.00, 'NEFT transfer'),
(3, 'Deposit',      5000.00, 'Cash deposit'),
(4, 'Transfer',     2000.00, 'UPI transfer'),
(5, 'EMI_Payment',  8500.00, 'Car loan EMI'),
(6, 'Deposit',     15000.00, 'Business receipt');

INSERT INTO Loans (customer_id, branch_id, loan_type, principal, interest_rate, tenure_months, emi_amount, disbursed_date, status) VALUES
(1, 1, 'Car',      500000.00, 9.5,  48, 12500.00, '2023-01-15', 'Active'),
(2, 2, 'Home',    2500000.00, 8.5, 240, 21800.00, '2022-06-01', 'Active'),
(3, 3, 'Personal',  150000.00, 12.0, 24,  7050.00, '2023-09-10', 'NPA'),
(4, 1, 'Business',  800000.00, 10.5, 60, 17200.00, '2021-03-20', 'Active'),
(5, 4, 'Education', 300000.00, 9.0,  36,  9540.00, '2023-07-01', 'Active');

INSERT INTO LoanEMISchedule (loan_id, due_date, emi_amount, paid_amount, payment_date, dpd, status) VALUES
(1, '2024-01-15', 12500.00, 12500.00, '2024-01-14', 0,  'Paid'),
(1, '2024-02-15', 12500.00, 12500.00, '2024-02-15', 0,  'Paid'),
(1, '2024-03-15', 12500.00,     0.00, NULL,          45, 'Overdue'),
(2, '2024-01-01', 21800.00, 21800.00, '2024-01-01', 0,  'Paid'),
(3, '2024-01-10',  7050.00,     0.00, NULL,          95, 'Overdue'),
(3, '2024-02-10',  7050.00,     0.00, NULL,          64, 'Overdue'),
(4, '2024-03-20', 17200.00, 17200.00, '2024-03-19', 0,  'Paid'),
(5, '2024-02-01',  9540.00,  9540.00, '2024-02-03', 2,  'Paid');

INSERT INTO Cards (customer_id, card_type, card_number, expiry_date, credit_limit, status) VALUES
(1, 'Debit',  '4111111111111111', '2027-12-31',      0.00, 'Active'),
(2, 'Credit', '5222222222222222', '2026-06-30', 100000.00, 'Active'),
(3, 'Debit',  '4333333333333333', '2025-11-30',      0.00, 'Expired'),
(4, 'Credit', '5444444444444444', '2028-03-31', 150000.00, 'Active'),
(5, 'Debit',  '4555555555555555', '2027-08-31',      0.00, 'Blocked');

INSERT INTO CIBIL_Score (customer_id, score, checked_date, remarks) VALUES
(1, 780, '2024-01-10', 'Good score — eligible for loans'),
(2, 820, '2024-01-15', 'Excellent score'),
(3, 580, '2024-02-01', 'Low score — NPA history'),
(4, 750, '2024-01-20', 'Good score'),
(5, 700, '2024-02-10', 'Average score — monitor'),
(6, 690, '2024-03-01', 'Below average'),
(7, 810, '2024-03-05', 'Excellent score');

INSERT INTO NPA_Tracker (loan_id, customer_id, dpd_days, npa_category, flagged_date, remarks) VALUES
(3, 3, 95,  'Sub-Standard', '2024-02-15', 'EMI overdue 90+ days'),
(3, 3, 125, 'Doubtful',     '2024-03-20', 'No response to collection calls');

INSERT INTO CollectionLog (loan_id, customer_id, employee_id, contact_date, amount_collected, contact_mode, outcome, notes) VALUES
(3, 3, 4, '2024-02-20', 0.00,    'Call',  'PTP',         'Customer promised to pay by March 1'),
(3, 3, 4, '2024-03-05', 0.00,    'Visit', 'No Response', 'Not available at home'),
(3, 3, 4, '2024-03-15', 7050.00, 'Call',  'Paid',        'Partial payment received'),
(1, 1, 2, '2024-03-20', 0.00,    'SMS',   'PTP',         'EMI reminder sent');

DELIMITER $$
CREATE TRIGGER trg_customer_insert
AFTER INSERT ON Customers
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Log (table_name, action_type, record_id, new_value)
    VALUES ('Customers', 'INSERT', NEW.customer_id,
            CONCAT('Name:', NEW.full_name, ' | Email:', NEW.email, ' | City:', NEW.city));
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_customer_update
AFTER UPDATE ON Customers
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Log (table_name, action_type, record_id, old_value, new_value)
    VALUES ('Customers', 'UPDATE', NEW.customer_id,
            CONCAT('Name:', OLD.full_name, ' | Email:', OLD.email, ' | City:', OLD.city),
            CONCAT('Name:', NEW.full_name, ' | Email:', NEW.email, ' | City:', NEW.city));
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_customer_delete
BEFORE DELETE ON Customers
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Log (table_name, action_type, record_id, old_value)
    VALUES ('Customers', 'DELETE', OLD.customer_id,
            CONCAT('Name:', OLD.full_name, ' | Email:', OLD.email));
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_account_update
AFTER UPDATE ON Accounts
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Log (table_name, action_type, record_id, old_value, new_value)
    VALUES ('Accounts', 'UPDATE', NEW.account_id,
            CONCAT('Balance:', OLD.balance, ' | Status:', OLD.status),
            CONCAT('Balance:', NEW.balance, ' | Status:', NEW.status));
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_transaction_insert
AFTER INSERT ON Transactions
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Log (table_name, action_type, record_id, new_value)
    VALUES ('Transactions', 'INSERT', NEW.txn_id,
            CONCAT('Type:', NEW.txn_type, ' | Amount:', NEW.amount, ' | Remarks:', NEW.remarks));
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_loan_status_update
AFTER UPDATE ON Loans
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO Audit_Log (table_name, action_type, record_id, old_value, new_value)
        VALUES ('Loans', 'UPDATE', NEW.loan_id,
                CONCAT('Status:', OLD.status),
                CONCAT('Status:', NEW.status));
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_emi_payment_update
AFTER UPDATE ON LoanEMISchedule
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Log (table_name, action_type, record_id, old_value, new_value)
    VALUES ('LoanEMISchedule', 'UPDATE', NEW.emi_id,
            CONCAT('Status:', OLD.status, ' | Paid:', OLD.paid_amount, ' | DPD:', OLD.dpd),
            CONCAT('Status:', NEW.status, ' | Paid:', NEW.paid_amount, ' | DPD:', NEW.dpd));
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_audit_report(IN tbl_name VARCHAR(50))
BEGIN
    SELECT log_id, table_name, action_type, record_id,
           old_value, new_value, changed_at
    FROM Audit_Log
    WHERE table_name = tbl_name
    ORDER BY changed_at DESC;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_audit_by_date(IN from_date DATE, IN to_date DATE)
BEGIN
    SELECT log_id, table_name, action_type, record_id,
           old_value, new_value, changed_at
    FROM Audit_Log
    WHERE DATE(changed_at) BETWEEN from_date AND to_date
    ORDER BY changed_at DESC;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_action_summary()
BEGIN
    SELECT table_name,
           action_type,
           COUNT(*) AS total_actions
    FROM Audit_Log
    GROUP BY table_name, action_type
    ORDER BY table_name, action_type;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_npa_report()
BEGIN
    SELECT c.customer_id, c.full_name, c.phone,
           l.loan_id, l.loan_type, l.principal,
           n.dpd_days, n.npa_category, n.flagged_date, n.remarks
    FROM NPA_Tracker n
    JOIN Loans    l ON n.loan_id     = l.loan_id
    JOIN Customers c ON n.customer_id = c.customer_id
    ORDER BY n.dpd_days DESC;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_collection_efficiency()
BEGIN
    SELECT e.employee_id, e.full_name, e.designation,
           COUNT(cl.collection_id)      AS total_contacts,
           SUM(cl.amount_collected)     AS total_collected,
           SUM(CASE WHEN cl.outcome = 'Paid' THEN 1 ELSE 0 END) AS successful_collections
    FROM CollectionLog cl
    JOIN Employees e ON cl.employee_id = e.employee_id
    GROUP BY e.employee_id, e.full_name, e.designation
    ORDER BY total_collected DESC;
END$$
DELIMITER ;


-- 1. Retrieve all customers
SELECT * FROM Customers;

-- 2. Retrieve all accounts
SELECT * FROM Accounts;

-- 3. Retrieve all transactions
SELECT * FROM Transactions;

-- 4. Retrieve all branches
SELECT * FROM Branches;

-- 5. Retrieve all employees
SELECT * FROM Employees;

-- 6. Retrieve all loans
SELECT * FROM Loans;

-- 7. Retrieve all active loans
SELECT * FROM Loans WHERE status = 'Active';

-- 8. Retrieve all NPA loans
SELECT * FROM Loans WHERE status = 'NPA';

-- 9. Retrieve all customers in Chennai
SELECT * FROM Customers WHERE city = 'Chennai';

-- 10. Retrieve all overdue EMIs
SELECT * FROM LoanEMISchedule WHERE status = 'Overdue';

-- 11. Retrieve all blocked or expired cards
SELECT * FROM Cards WHERE status IN ('Blocked','Expired');

-- 12. Retrieve CIBIL scores below 650 (risky customers)
SELECT * FROM CIBIL_Score WHERE score < 650;

-- 13. Retrieve all audit logs for Customers table
SELECT * FROM Audit_Log WHERE table_name = 'Customers';

-- 14. Retrieve all deposit transactions
SELECT * FROM Transactions WHERE txn_type = 'Deposit';

-- 15. Retrieve all collection logs with outcome = Paid
SELECT * FROM CollectionLog WHERE outcome = 'Paid';

-- 16. Count total customers per city
SELECT city, COUNT(*) AS total_customers
FROM Customers
GROUP BY city;

-- 17. Retrieve EMI schedule with DPD > 30
SELECT * FROM LoanEMISchedule WHERE dpd > 30;

-- 18. Retrieve all credit cards
SELECT * FROM Cards WHERE card_type = 'Credit';

-- 19. Retrieve all NPA tracker records flagged in 2024
SELECT * FROM NPA_Tracker WHERE YEAR(flagged_date) = 2024;

-- 20. Retrieve total balance per account type
SELECT account_type, SUM(balance) AS total_balance
FROM Accounts
GROUP BY account_type;


-- 1. Customer name with their account balance and type
SELECT c.full_name, a.account_type, a.balance, a.status
FROM Customers c
JOIN Accounts a ON c.customer_id = a.customer_id;

-- 2. Customers with their loan details
SELECT c.full_name, l.loan_type, l.principal, l.emi_amount, l.status
FROM Customers c
JOIN Loans l ON c.customer_id = l.customer_id;

-- 3. Overdue EMIs with customer name and loan type
SELECT c.full_name, l.loan_type, e.due_date, e.dpd, e.status
FROM LoanEMISchedule e
JOIN Loans l    ON e.loan_id     = l.loan_id
JOIN Customers c ON l.customer_id = c.customer_id
WHERE e.status = 'Overdue'
ORDER BY e.dpd DESC;

-- 4. Employees with their branch name and city
SELECT e.full_name, e.designation, b.branch_name, b.city
FROM Employees e
JOIN Branches b ON e.branch_id = b.branch_id;

-- 5. Total loan amount disbursed per branch
SELECT b.branch_name, COUNT(l.loan_id) AS total_loans,
       SUM(l.principal) AS total_disbursed
FROM Loans l
JOIN Branches b ON l.branch_id = b.branch_id
GROUP BY b.branch_name;

-- 6. Customers with CIBIL score and loan status
SELECT c.full_name, cs.score, l.loan_type, l.status
FROM Customers c
JOIN CIBIL_Score cs ON c.customer_id = cs.customer_id
JOIN Loans       l  ON c.customer_id = l.customer_id;

-- 7. NPA customers with collection history
SELECT c.full_name, n.npa_category, n.dpd_days,
       cl.contact_mode, cl.outcome, cl.amount_collected
FROM NPA_Tracker n
JOIN Customers   c  ON n.customer_id  = c.customer_id
JOIN CollectionLog cl ON n.customer_id = cl.customer_id;

-- 8. Average CIBIL score per city
SELECT c.city, ROUND(AVG(cs.score),2) AS avg_cibil
FROM Customers c
JOIN CIBIL_Score cs ON c.customer_id = cs.customer_id
GROUP BY c.city
ORDER BY avg_cibil DESC;

-- 9. Transactions above 10000 with account and customer details
SELECT c.full_name, a.account_type, t.txn_type, t.amount, t.remarks
FROM Transactions t
JOIN Accounts   a ON t.account_id  = a.account_id
JOIN Customers  c ON a.customer_id = c.customer_id
WHERE t.amount > 10000;

-- 10. Loan wise EMI payment summary
SELECT l.loan_id, l.loan_type, c.full_name,
       COUNT(e.emi_id)          AS total_emis,
       SUM(e.paid_amount)       AS total_paid,
       SUM(e.emi_amount - e.paid_amount) AS outstanding
FROM LoanEMISchedule e
JOIN Loans     l ON e.loan_id     = l.loan_id
JOIN Customers c ON l.customer_id = c.customer_id
GROUP BY l.loan_id, l.loan_type, c.full_name;

-- 11. Customers with no loans
SELECT c.customer_id, c.full_name, c.city
FROM Customers c
LEFT JOIN Loans l ON c.customer_id = l.customer_id
WHERE l.loan_id IS NULL;

-- 12. Branch wise active loan count
SELECT b.branch_name, COUNT(l.loan_id) AS active_loans
FROM Branches b
LEFT JOIN Loans l ON b.branch_id = l.branch_id AND l.status = 'Active'
GROUP BY b.branch_name;

-- 13. Total amount collected per collection agent
SELECT e.full_name, SUM(cl.amount_collected) AS total_collected
FROM CollectionLog cl
JOIN Employees e ON cl.employee_id = e.employee_id
GROUP BY e.full_name;

-- 14. All audit log changes in last 30 days
SELECT * FROM Audit_Log
WHERE changed_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY changed_at DESC;

-- 15. Cards expiring in 2025
SELECT c.full_name, ca.card_type, ca.card_number, ca.expiry_date
FROM Cards ca
JOIN Customers c ON ca.customer_id = c.customer_id
WHERE YEAR(ca.expiry_date) = 2025;


-- 1. Rank customers by CIBIL score using window function
SELECT c.full_name, cs.score,
       RANK() OVER (ORDER BY cs.score DESC) AS cibil_rank
FROM CIBIL_Score cs
JOIN Customers c ON cs.customer_id = c.customer_id;

-- 2. Running total of transactions per account
SELECT t.txn_id, c.full_name, t.txn_type, t.amount,
       SUM(t.amount) OVER (PARTITION BY t.account_id ORDER BY t.txn_date) AS running_total
FROM Transactions t
JOIN Accounts  a ON t.account_id  = a.account_id
JOIN Customers c ON a.customer_id = c.customer_id;

-- 3. CTE: Find customers with both NPA loan and low CIBIL score
WITH NPA_Customers AS (
    SELECT DISTINCT customer_id FROM Loans WHERE status = 'NPA'
),
Low_CIBIL AS (
    SELECT customer_id FROM CIBIL_Score WHERE score < 650
)
SELECT c.full_name, c.city, cs.score
FROM Customers c
JOIN NPA_Customers nc ON c.customer_id = nc.customer_id
JOIN Low_CIBIL     lc ON c.customer_id = lc.customer_id
JOIN CIBIL_Score   cs ON c.customer_id = cs.customer_id;

-- 4. Find duplicate emails in Customers (data quality check)
SELECT email, COUNT(*) AS count
FROM Customers
GROUP BY email
HAVING COUNT(*) > 1;

-- 5. Top branch by total loan amount using subquery
SELECT branch_name, total_disbursed
FROM (
    SELECT b.branch_name, SUM(l.principal) AS total_disbursed
    FROM Loans l
    JOIN Branches b ON l.branch_id = b.branch_id
    GROUP BY b.branch_name
) AS branch_summary
ORDER BY total_disbursed DESC
LIMIT 1;

-- 6. Customers whose EMI DPD is more than 60 days (potential NPA)
SELECT DISTINCT c.full_name, c.phone, l.loan_type, e.dpd
FROM LoanEMISchedule e
JOIN Loans     l ON e.loan_id     = l.loan_id
JOIN Customers c ON l.customer_id = c.customer_id
WHERE e.dpd > 60
ORDER BY e.dpd DESC;

-- 7. Month wise transaction volume
SELECT DATE_FORMAT(txn_date, '%Y-%m') AS txn_month,
       COUNT(*) AS total_txns,
       SUM(amount) AS total_amount
FROM Transactions
GROUP BY txn_month
ORDER BY txn_month;

-- 8. Audit log count by action type using CASE
SELECT
    SUM(CASE WHEN action_type = 'INSERT' THEN 1 ELSE 0 END) AS inserts,
    SUM(CASE WHEN action_type = 'UPDATE' THEN 1 ELSE 0 END) AS updates,
    SUM(CASE WHEN action_type = 'DELETE' THEN 1 ELSE 0 END) AS deletes
FROM Audit_Log;

-- 9. Employee who handled the most collection contacts
SELECT e.full_name, COUNT(cl.collection_id) AS total_contacts
FROM CollectionLog cl
JOIN Employees e ON cl.employee_id = e.employee_id
GROUP BY e.full_name
ORDER BY total_contacts DESC
LIMIT 1;

-- 10. Loan portfolio health summary
SELECT
    SUM(CASE WHEN status = 'Active'  THEN principal ELSE 0 END) AS active_portfolio,
    SUM(CASE WHEN status = 'NPA'     THEN principal ELSE 0 END) AS npa_portfolio,
    SUM(CASE WHEN status = 'Closed'  THEN principal ELSE 0 END) AS closed_portfolio,
    ROUND(SUM(CASE WHEN status = 'NPA' THEN principal ELSE 0 END) /
          SUM(principal) * 100, 2)                               AS npa_ratio_pct
FROM Loans;


CALL sp_audit_report('Customers');
CALL sp_audit_by_date('2024-01-01', '2026-12-31');
CALL sp_action_summary();
CALL sp_npa_report();
CALL sp_collection_efficiency();
