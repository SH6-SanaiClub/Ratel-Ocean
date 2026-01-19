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

try:
    cursor = conn.cursor()
    
    # ========================================
    # 1. 데이터베이스 기본 정보
    # ========================================
    print("=" * 100)
    print("📊 SANAI DATABASE - 전체 정보 조회")
    print("=" * 100)
    
    cursor.execute("SELECT DATABASE()")
    db_name = cursor.fetchone()[0]
    print(f"\n현재 데이터베이스: {db_name}")
    
    cursor.execute("SELECT VERSION()")
    version = cursor.fetchone()[0]
    print(f"MySQL 버전: {version}")
    
    # ========================================
    # 2. 테이블 목록 및 상세 정보
    # ========================================
    cursor.execute("SHOW TABLES")
    tables = [row[0] for row in cursor.fetchall()]
    print(f"\n총 테이블 개수: {len(tables)}개")
    
    print("\n" + "=" * 100)
    print("📋 테이블별 상세 정보")
    print("=" * 100)
    
    for table_name in sorted(tables):
        print(f"\n{'='*100}")
        print(f"🔹 테이블: {table_name.upper()}")
        print(f"{'='*100}")
        
        # 테이블 구조
        cursor.execute(f"DESCRIBE {table_name}")
        columns = cursor.fetchall()
        
        print("\n📌 컬럼 정보:")
        print("-" * 100)
        print(f"{'컬럼명':<30} {'타입':<25} {'NULL':<10} {'KEY':<10} {'DEFAULT':<20} {'EXTRA':<20}")
        print("-" * 100)
        
        for col in columns:
            field, type_, null, key, default, extra = col
            default_str = str(default) if default is not None else ""
            print(f"{field:<30} {type_:<25} {null:<10} {key:<10} {default_str:<20} {extra:<20}")
        
        # 레코드 수
        cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
        count = cursor.fetchone()[0]
        print(f"\n📊 레코드 수: {count}건")
        
        # 테이블 상태 정보
        cursor.execute(f"SHOW TABLE STATUS LIKE '{table_name}'")
        status = cursor.fetchone()
        if status:
            engine = status[1]
            collation = status[14]
            print(f"⚙️  엔진: {engine}, 콜레이션: {collation}")
    
    # ========================================
    # 3. 외래키(Foreign Key) 제약조건
    # ========================================
    print("\n\n" + "=" * 100)
    print("🔗 외래키(FOREIGN KEY) 제약조건")
    print("=" * 100)
    
    cursor.execute("""
        SELECT 
            CONSTRAINT_NAME,
            TABLE_NAME,
            COLUMN_NAME,
            REFERENCED_TABLE_NAME,
            REFERENCED_COLUMN_NAME
        FROM information_schema.KEY_COLUMN_USAGE
        WHERE TABLE_SCHEMA = 'sanai'
        AND REFERENCED_TABLE_NAME IS NOT NULL
        ORDER BY TABLE_NAME, CONSTRAINT_NAME
    """)
    
    fk_constraints = cursor.fetchall()
    
    if fk_constraints:
        print(f"\n총 {len(fk_constraints)}개의 외래키 제약조건\n")
        current_table = None
        for fk in fk_constraints:
            constraint_name, table_name, column_name, ref_table, ref_column = fk
            if current_table != table_name:
                if current_table is not None:
                    print()
                print(f"📌 {table_name}:")
                current_table = table_name
            print(f"   {constraint_name}: {column_name} -> {ref_table}({ref_column})")
    else:
        print("\n외래키 제약조건이 없습니다.")
    
    # ========================================
    # 4. 인덱스 정보
    # ========================================
    print("\n\n" + "=" * 100)
    print("🔍 인덱스 정보")
    print("=" * 100)
    
    for table_name in sorted(tables):
        cursor.execute(f"SHOW INDEX FROM {table_name}")
        indexes = cursor.fetchall()
        
        if indexes:
            print(f"\n📌 {table_name}:")
            index_dict = {}
            for idx in indexes:
                index_name = idx[2]
                column_name = idx[4]
                non_unique = idx[1]
                
                if index_name not in index_dict:
                    index_dict[index_name] = {
                        'columns': [],
                        'unique': not non_unique
                    }
                index_dict[index_name]['columns'].append(column_name)
            
            for idx_name, idx_info in index_dict.items():
                unique_str = "UNIQUE" if idx_info['unique'] else "INDEX"
                columns_str = ", ".join(idx_info['columns'])
                print(f"   {unique_str}: {idx_name} ({columns_str})")
    
    # ========================================
    # 5. 트리거(Trigger) 정보
    # ========================================
    print("\n\n" + "=" * 100)
    print("⚡ 트리거(TRIGGER) 정보")
    print("=" * 100)
    
    cursor.execute("SHOW TRIGGERS")
    triggers = cursor.fetchall()
    
    if triggers:
        print(f"\n총 {len(triggers)}개의 트리거\n")
        for trigger in triggers:
            trigger_name = trigger[0]
            event = trigger[1]  # INSERT, UPDATE, DELETE
            table = trigger[2]
            statement = trigger[3]
            timing = trigger[4]  # BEFORE, AFTER
            
            print(f"📌 트리거명: {trigger_name}")
            print(f"   테이블: {table}")
            print(f"   이벤트: {timing} {event}")
            print(f"   실행문: {statement[:100]}..." if len(statement) > 100 else f"   실행문: {statement}")
            print()
    else:
        print("\n트리거가 없습니다.")
    
    # ========================================
    # 6. ENUM 타입 정보
    # ========================================
    print("\n" + "=" * 100)
    print("📝 ENUM 타입 컬럼 정보")
    print("=" * 100)
    
    cursor.execute("""
        SELECT 
            TABLE_NAME,
            COLUMN_NAME,
            COLUMN_TYPE
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = 'sanai'
        AND DATA_TYPE = 'enum'
        ORDER BY TABLE_NAME, COLUMN_NAME
    """)
    
    enum_columns = cursor.fetchall()
    
    if enum_columns:
        print(f"\n총 {len(enum_columns)}개의 ENUM 컬럼\n")
        for enum_col in enum_columns:
            table, column, col_type = enum_col
            print(f"📌 {table}.{column}")
            print(f"   타입: {col_type}")
            print()
    else:
        print("\nENUM 타입 컬럼이 없습니다.")
    
    # ========================================
    # 7. 뷰(View) 정보
    # ========================================
    print("\n" + "=" * 100)
    print("👁️  뷰(VIEW) 정보")
    print("=" * 100)
    
    cursor.execute("SHOW FULL TABLES WHERE Table_type = 'VIEW'")
    views = cursor.fetchall()
    
    if views:
        print(f"\n총 {len(views)}개의 뷰\n")
        for view in views:
            view_name = view[0]
            cursor.execute(f"SHOW CREATE VIEW {view_name}")
            view_def = cursor.fetchone()
            print(f"📌 뷰명: {view_name}")
            print(f"   정의: {view_def[1][:100]}..." if len(view_def[1]) > 100 else f"   정의: {view_def[1]}")
            print()
    else:
        print("\n뷰가 없습니다.")
    
    # ========================================
    # 8. 스토어드 프로시저 정보
    # ========================================
    print("\n" + "=" * 100)
    print("⚙️  스토어드 프로시저 정보")
    print("=" * 100)
    
    cursor.execute("SHOW PROCEDURE STATUS WHERE Db = 'sanai'")
    procedures = cursor.fetchall()
    
    if procedures:
        print(f"\n총 {len(procedures)}개의 프로시저\n")
        for proc in procedures:
            proc_name = proc[1]
            print(f"📌 프로시저명: {proc_name}")
    else:
        print("\n스토어드 프로시저가 없습니다.")
    
    # ========================================
    # 9. 데이터베이스 요약 통계
    # ========================================
    print("\n\n" + "=" * 100)
    print("📊 데이터베이스 요약 통계")
    print("=" * 100)
    
    total_records = 0
    for table_name in tables:
        cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
        count = cursor.fetchone()[0]
        total_records += count
    
    print(f"\n총 테이블 수: {len(tables)}개")
    print(f"총 레코드 수: {total_records:,}건")
    print(f"외래키 제약조건: {len(fk_constraints)}개")
    print(f"트리거: {len(triggers)}개")
    print(f"ENUM 컬럼: {len(enum_columns)}개")
    print(f"뷰: {len(views)}개")
    print(f"스토어드 프로시저: {len(procedures)}개")
    
    print("\n" + "=" * 100)
    print("✅ 데이터베이스 전체 조회 완료!")
    print("=" * 100)

finally:
    cursor.close()
    conn.close()
