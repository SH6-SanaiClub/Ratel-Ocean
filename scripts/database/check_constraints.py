import mysql.connector

connection = mysql.connector.connect(
    host="192.168.0.56",
    port=3306,
    user="remote_user",
    password="0000",
    database="sanai"
)

cursor = connection.cursor()

# contracts 테이블의 체크 제약 확인
cursor.execute("""
SELECT CONSTRAINT_NAME, CHECK_CLAUSE 
FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS 
WHERE CONSTRAINT_SCHEMA = 'sanai' 
AND TABLE_NAME = 'contracts'
AND CONSTRAINT_NAME LIKE '%rating%'
""")

print("contracts 테이블의 rating 체크 제약:")
print("="*60)
for row in cursor.fetchall():
    print(f"{row[0]}: {row[1]}")

cursor.close()
connection.close()
