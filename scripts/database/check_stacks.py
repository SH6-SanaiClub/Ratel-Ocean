import pymysql

conn = pymysql.connect(
    host='192.168.0.56',
    port=3306,
    user='remote_user',
    password='0000',
    database='sanai',
    charset='utf8mb4'
)

cur = conn.cursor()

print('=' * 60)
print('=== stacks 테이블 구조 ===')
print('=' * 60)
cur.execute('DESCRIBE stacks')
for row in cur.fetchall():
    field, type_, null, key, default, extra = row
    print(f'{field:20} {type_:20} {null:5} {key:5} {str(default) if default else "":10}')

print('\n' + '=' * 60)
print('=== stacks 샘플 데이터 (최대 30개) ===')
print('=' * 60)
cur.execute('SELECT * FROM stacks LIMIT 30')
rows = cur.fetchall()
if rows:
    for r in rows:
        print(r)
else:
    print('데이터 없음')

cur.execute('SELECT COUNT(*) FROM stacks')
count = cur.fetchone()[0]
print(f'\n총 레코드 수: {count}')

print('\n' + '=' * 60)
print('=== freelancer_skills 테이블 구조 ===')
print('=' * 60)
cur.execute('DESCRIBE freelancer_skills')
for row in cur.fetchall():
    field, type_, null, key, default, extra = row
    print(f'{field:20} {type_:20} {null:5} {key:5} {str(default) if default else "":10}')

print('\n' + '=' * 60)
print('=== project_stacks 테이블 구조 ===')
print('=' * 60)
cur.execute('DESCRIBE project_stacks')
for row in cur.fetchall():
    field, type_, null, key, default, extra = row
    print(f'{field:20} {type_:20} {null:5} {key:5} {str(default) if default else "":10}')

conn.close()
