import mysql.connector

connection = mysql.connector.connect(
    host="192.168.0.56",
    port=3306,
    user="remote_user",
    password="0000",
    database="sanai"
)

cursor = connection.cursor()

# 수정된 SQL 직접 테스트
sql = """
SELECT 
    c.contract_id,
    p.client_id,
    pa.freelancer_id,
    c.contract_start_date,
    c.contract_end_date,
    c.total_budget,
    c.client_rating,
    c.client_experience,
    c.client_is_renewal_intended,
    c.freelancer_rating,
    c.freelancer_experience,
    p.title AS project_title
FROM contracts c
LEFT JOIN project_applications pa ON c.contract_id = pa.application_id
LEFT JOIN projects p ON pa.project_id = p.project_id
WHERE c.contract_id = 7
"""

cursor.execute(sql)
result = cursor.fetchone()

if result:
    print("✅ SQL 실행 성공!")
    print(f"contract_id: {result[0]}")
    print(f"client_id: {result[1]}")
    print(f"freelancer_id: {result[2]}")
    print(f"project_title: {result[11]}")
else:
    print("❌ 결과 없음")

cursor.close()
connection.close()
