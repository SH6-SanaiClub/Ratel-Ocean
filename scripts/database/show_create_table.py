import mysql.connector

connection = mysql.connector.connect(
    host="192.168.0.56",
    port=3306,
    user="remote_user",
    password="0000",
    database="sanai"
)

cursor = connection.cursor()

# contracts 테이블의 CREATE TABLE 문 확인
cursor.execute("SHOW CREATE TABLE contracts")
result = cursor.fetchone()

print("contracts 테이블 구조:")
print("="*60)
print(result[1])

cursor.close()
connection.close()
