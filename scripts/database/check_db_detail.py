import pymysql

# DB 연결
conn = pymysql.connect(
    host='192.168.0.56',
    port=3306,
    user='remote_user',
    password='0000',
    database='sanai',
    charset='utf8mb4'
)
cursor = conn.cursor()

print("=" * 80)
print("contracts 테이블 구조")
print("=" * 80)
cursor.execute('DESCRIBE contracts')
columns = cursor.fetchall()
for col in columns:
    print(f"{col[0]:35} {col[1]:25} NULL:{col[2]:5} KEY:{col[3]:5} DEFAULT:{str(col[4])[:20]}")

print("\n" + "=" * 80)
print("contracts 샘플 데이터")
print("=" * 80)
cursor.execute('SELECT * FROM contracts LIMIT 3')
rows = cursor.fetchall()
print(f"총 {len(rows)}건 조회")
for row in rows:
    print(row)

print("\n" + "=" * 80)
print("contract_milestones 테이블 구조")
print("=" * 80)
cursor.execute('DESCRIBE contract_milestones')
columns = cursor.fetchall()
for col in columns:
    print(f"{col[0]:35} {col[1]:25} NULL:{col[2]:5} KEY:{col[3]:5} DEFAULT:{str(col[4])[:20]}")

print("\n" + "=" * 80)
print("contract_milestones 샘플 데이터")
print("=" * 80)
cursor.execute('SELECT * FROM contract_milestones LIMIT 5')
rows = cursor.fetchall()
print(f"총 {len(rows)}건 조회")
for row in rows:
    print(row)

print("\n" + "=" * 80)
print("projects 테이블 구조 및 샘플")
print("=" * 80)
cursor.execute('DESCRIBE projects')
columns = cursor.fetchall()
for col in columns:
    print(f"{col[0]:35} {col[1]:25} NULL:{col[2]:5} KEY:{col[3]:5}")

cursor.execute('SELECT project_id, title, budget, start_date, deadline_date, project_status FROM projects LIMIT 3')
rows = cursor.fetchall()
print(f"\n프로젝트 샘플 데이터 (총 {len(rows)}건):")
for row in rows:
    print(row)

print("\n" + "=" * 80)
print("users 테이블 구조 및 샘플")
print("=" * 80)
cursor.execute('DESCRIBE users')
columns = cursor.fetchall()
for col in columns:
    print(f"{col[0]:35} {col[1]:25} NULL:{col[2]:5} KEY:{col[3]:5}")

cursor.execute('SELECT user_id, login_id, name, email, user_type FROM users LIMIT 5')
rows = cursor.fetchall()
print(f"\n사용자 샘플 데이터 (총 {len(rows)}건):")
for row in rows:
    print(row)

print("\n" + "=" * 80)
print("freelancer_profiles 테이블 구조")
print("=" * 80)
cursor.execute('DESCRIBE freelancer_profiles')
columns = cursor.fetchall()
for col in columns:
    print(f"{col[0]:35} {col[1]:25} NULL:{col[2]:5} KEY:{col[3]:5}")

cursor.execute('SELECT user_id, nickname, introduction FROM freelancer_profiles LIMIT 3')
rows = cursor.fetchall()
print(f"\n프리랜서 프로필 샘플 (총 {len(rows)}건):")
for row in rows:
    print(row)

print("\n" + "=" * 80)
print("client_profiles 테이블 구조")
print("=" * 80)
cursor.execute('DESCRIBE client_profiles')
columns = cursor.fetchall()
for col in columns:
    print(f"{col[0]:35} {col[1]:25} NULL:{col[2]:5} KEY:{col[3]:5}")

cursor.execute('SELECT client_id, company_id, client_type FROM client_profiles LIMIT 3')
rows = cursor.fetchall()
print(f"\n클라이언트 프로필 샘플 (총 {len(rows)}건):")
for row in rows:
    print(row)

# contracts 테이블 ENUM 확인
print("\n" + "=" * 80)
print("contracts 테이블 ENUM 값 확인")
print("=" * 80)
cursor.execute("SHOW COLUMNS FROM contracts LIKE 'contract_status'")
status_col = cursor.fetchone()
print(f"contract_status: {status_col[1]}")

cursor.execute("SHOW COLUMNS FROM contracts LIKE 'payment_method'")
payment_col = cursor.fetchone()
print(f"payment_method: {payment_col[1]}")

# 테이블별 데이터 개수 확인
print("\n" + "=" * 80)
print("테이블별 데이터 개수")
print("=" * 80)
tables = ['contracts', 'contract_milestones', 'projects', 'users', 'freelancer_profiles', 'client_profiles']
for table in tables:
    cursor.execute(f"SELECT COUNT(*) FROM {table}")
    count = cursor.fetchone()[0]
    print(f"{table:30} : {count}건")

conn.close()
print("\n✅ DB 검토 완료!")
