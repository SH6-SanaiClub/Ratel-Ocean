import mysql.connector

connection = mysql.connector.connect(
    host="192.168.0.56",
    port=3306,
    user="remote_user",
    password="0000",
    database="sanai"
)

cursor = connection.cursor()

# projects 테이블의 ENUM 값 확인
cursor.execute("""
SELECT COLUMN_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'sanai' 
AND TABLE_NAME = 'projects' 
AND COLUMN_NAME = 'project_status'
""")
print("project_status ENUM 값:")
print(cursor.fetchone()[0])

# contracts 테이블의 ENUM 값 확인
cursor.execute("""
SELECT COLUMN_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'sanai' 
AND TABLE_NAME = 'contracts' 
AND COLUMN_NAME = 'contract_status'
""")
print("\ncontract_status ENUM 값:")
print(cursor.fetchone()[0])

# payment_method ENUM 값 확인
cursor.execute("""
SELECT COLUMN_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'sanai' 
AND TABLE_NAME IN ('projects', 'contracts')
AND COLUMN_NAME = 'payment_method'
LIMIT 1
""")
print("\npayment_method ENUM 값:")
print(cursor.fetchone()[0])

cursor.close()
connection.close()
