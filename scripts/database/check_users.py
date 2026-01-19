import mysql.connector

connection = mysql.connector.connect(
    host="192.168.0.56",
    port=3306,
    user="remote_user",
    password="0000",
    database="sanai"
)

cursor = connection.cursor()

# users 테이블에 있는 user_id들 확인
cursor.execute("SELECT user_id, login_id, user_type, name FROM users LIMIT 10")
users = cursor.fetchall()

print("현재 users 테이블의 데이터:")
print("="*60)
if users:
    for user in users:
        print(f"User ID: {user[0]}, Login: {user[1]}, Type: {user[2]}, Name: {user[3]}")
else:
    print("❌ users 테이블이 비어있습니다.")
    print("\n테스트용 사용자를 생성하시겠습니까?")

cursor.close()
connection.close()
