import pandas as pd
import mysql.connector
from mysql.connector import Error
from datetime import datetime

config = {
    'host': 'localhost',
    'user': 'root',
    'password': '1234',
    'database': 'bank_loan_db'
}

CSV_PATH = r'E:\excel practice\financial_loan.csv'

def convert_date(val):
    if pd.isnull(val) or val == '' or val is None:
        return None
    try:
        return datetime.strptime(str(val).strip(), '%d-%m-%Y').strftime('%Y-%m-%d')
    except:
        try:
            return datetime.strptime(str(val).strip(), '%Y-%m-%d').strftime('%Y-%m-%d')
        except:
            return None

try:
    print("Reading CSV file...")
    df = pd.read_csv(CSV_PATH, dtype=str)  # read ALL columns as string
    print("CSV loaded - " + str(len(df)) + " rows")
    print("Raw issue_date sample: " + str(df['issue_date'].head(3).tolist()))

    # Convert dates manually
    date_columns = ['issue_date', 'last_credit_pull_date', 'last_payment_date', 'next_payment_date']
    for col in date_columns:
        df[col] = df[col].apply(convert_date)

    print("Dates after conversion: " + str(df['issue_date'].head(3).tolist()))

    # Check December count before inserting
    dec_check = df['issue_date'].apply(lambda x: x is not None and x[5:7] == '12').sum()
    print("December rows in dataframe: " + str(dec_check))

    # Convert numeric columns
    int_columns = ['id', 'member_id', 'annual_income', 'loan_amount', 'total_acc', 'total_payment']
    for col in int_columns:
        df[col] = pd.to_numeric(df[col], errors='coerce').fillna(0).astype(int)

    float_columns = ['dti', 'installment', 'int_rate']
    for col in float_columns:
        df[col] = pd.to_numeric(df[col], errors='coerce').fillna(0.0).astype(float)

    # String columns - replace NaN with None
    str_columns = ['address_state', 'application_type', 'emp_length', 'emp_title',
                   'grade', 'home_ownership', 'loan_status', 'purpose', 'sub_grade',
                   'term', 'verification_status']
    for col in str_columns:
        df[col] = df[col].where(pd.notnull(df[col]), None)

    df['term'] = df['term'].str.strip()

    print("Connecting to MySQL...")
    conn = mysql.connector.connect(**config)
    cursor = conn.cursor()
    print("Connected to MySQL")

    cursor.execute("DROP TABLE IF EXISTS financial_loan")
    cursor.execute("""
        CREATE TABLE financial_loan (
            id                    BIGINT NOT NULL,
            address_state         VARCHAR(10),
            application_type      VARCHAR(50),
            emp_length            VARCHAR(20),
            emp_title             VARCHAR(100),
            grade                 VARCHAR(5),
            home_ownership        VARCHAR(20),
            issue_date            DATE,
            last_credit_pull_date DATE,
            last_payment_date     DATE,
            loan_status           VARCHAR(50),
            next_payment_date     DATE,
            member_id             BIGINT,
            purpose               VARCHAR(100),
            sub_grade             VARCHAR(10),
            term                  VARCHAR(20),
            verification_status   VARCHAR(50),
            annual_income         BIGINT,
            dti                   DECIMAL(10,4),
            installment           DECIMAL(10,2),
            int_rate              DECIMAL(6,4),
            loan_amount           BIGINT,
            total_acc             INT,
            total_payment         BIGINT,
            PRIMARY KEY (id)
        )
    """)
    print("Table created")

    insert_query = """
        INSERT INTO financial_loan (
            id, address_state, application_type, emp_length, emp_title,
            grade, home_ownership, issue_date, last_credit_pull_date,
            last_payment_date, loan_status, next_payment_date, member_id,
            purpose, sub_grade, term, verification_status, annual_income,
            dti, installment, int_rate, loan_amount, total_acc, total_payment
        ) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
    """

    BATCH_SIZE = 1000
    total = len(df)
    for i in range(0, total, BATCH_SIZE):
        batch = df.iloc[i:i+BATCH_SIZE]
        rows = []
        for row in batch.itertuples(index=False):
            rows.append((
                int(row.id),
                row.address_state,
                row.application_type,
                row.emp_length,
                row.emp_title,
                row.grade,
                row.home_ownership,
                row.issue_date,
                row.last_credit_pull_date,
                row.last_payment_date,
                row.loan_status,
                row.next_payment_date,
                int(row.member_id),
                row.purpose,
                row.sub_grade,
                row.term,
                row.verification_status,
                int(row.annual_income),
                float(row.dti),
                float(row.installment),
                float(row.int_rate),
                int(row.loan_amount),
                int(row.total_acc),
                int(row.total_payment)
            ))
        cursor.executemany(insert_query, rows)
        conn.commit()
        print("Inserted " + str(min(i+BATCH_SIZE, total)) + "/" + str(total) + " rows")

    print("All " + str(total) + " rows inserted!")

    cursor.execute("SELECT COUNT(*) FROM financial_loan")
    print("Total rows in MySQL: " + str(cursor.fetchone()[0]))

    cursor.execute("SELECT COUNT(*) FROM financial_loan WHERE MONTH(issue_date) = 12")
    print("December loans: " + str(cursor.fetchone()[0]) + " (should be 4314)")

    cursor.execute("SELECT issue_date FROM financial_loan LIMIT 3")
    print("Sample dates in MySQL: " + str(cursor.fetchall()))

except Error as e:
    print("MySQL Error: " + str(e))
except FileNotFoundError:
    print("CSV file not found: " + CSV_PATH)
except Exception as e:
    print("Error: " + str(e))
finally:
    if 'conn' in locals() and conn.is_connected():
        cursor.close()
        conn.close()
        print("MySQL connection closed")