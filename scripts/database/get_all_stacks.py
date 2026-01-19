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
cur.execute('SELECT stack_id, stack_name, category FROM stacks ORDER BY category, stack_name')
rows = cur.fetchall()

skills = [r for r in rows if r[2] == 'SKILL']
positions = [r for r in rows if r[2] == 'POSITION']

print(f'총 {len(rows)}개 기술 스택')
print(f'SKILL: {len(skills)}개')
print(f'POSITION: {len(positions)}개')

print('\n=== POSITION 목록 ===')
for p in positions:
    print(f'{p[0]:3} {p[1]:30} {p[2]}')

print('\n=== SKILL 샘플 (처음 20개) ===')
for s in skills[:20]:
    print(f'{s[0]:3} {s[1]:30} {s[2]}')

conn.close()
