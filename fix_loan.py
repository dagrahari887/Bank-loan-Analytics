import pandas as pd

df = pd.read_csv(r'E:\excel practice\financial_loan.csv', encoding='latin-1')

print("Total rows:", len(df))
print("Columns:", list(df.columns))

# Fix all 4 date columns
date_cols = ['issue_date', 'last_credit_pull_date', 
             'last_payment_date', 'next_payment_date']

for col in date_cols:
    df[col] = pd.to_datetime(df[col], 
              format='mixed', dayfirst=True).dt.strftime('%Y-%m-%d')

# Fix empty emp_title
df['emp_title'] = df['emp_title'].fillna('Unknown')

# Fix term column - remove leading space
df['term'] = df['term'].str.strip()

# Fix int_rate - convert to percentage
df['int_rate'] = (df['int_rate'] * 100).round(2)

print("\nSample fixed dates:")
print(df[['issue_date', 'last_credit_pull_date', 
          'last_payment_date', 'next_payment_date']].head(5))
print("\nNull values remaining:", df.isnull().sum().sum())
print("Total rows:", len(df))

df.to_csv(r'E:\excel practice\financial_loan_clean.csv', index=False)
print("\nDone! File saved as financial_loan_clean.csv")