import pymysql

conn = pymysql.connect(
    host='192.168.0.56',
    port=3306,
    user='remote_user',
    password='0000',
    database='sanai',
    charset='utf8mb4'
)

try:
    cursor = conn.cursor()
    
    cursor.execute("SHOW TABLES")
    tables = [row[0] for row in cursor.fetchall()]
    
    print("=" * 100)
    print(f"📊 SANAI DATABASE - 총 {len(tables)}개 테이블")
    print("=" * 100)
    
    for table_name in tables:
        print(f"\n🔹 {table_name.upper()}")
        print("-" * 100)
        
        cursor.execute(f"DESCRIBE {table_name}")
        columns = cursor.fetchall()
        
        for col in columns:
            field, type_, null, key, default, extra = col
            key_info = f" {key}" if key else ""
            null_info = "NULL" if null == "YES" else "NOT NULL"
            default_info = f" DEFAULT {default}" if default else ""
            extra_info = f" {extra}" if extra else ""
            
            print(f"  {field:<30} {type_:<25} {null_info:<10}{key_info}{default_info}{extra_info}")
        
        cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
        count = cursor.fetchone()[0]
        print(f"  [레코드: {count}건]")
    
    print("\n" + "=" * 100)
    
finally:
    cursor.close()
    conn.close()
