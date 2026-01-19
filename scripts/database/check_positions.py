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
print('=== 개발 영역 (POSITION) ===')
print('=' * 60)
cur.execute('SELECT * FROM stacks WHERE category="POSITION" ORDER BY stack_name')
rows = cur.fetchall()
for r in rows:
    print(r)

print(f'\n총 {len(rows)}개')

conn.close()
