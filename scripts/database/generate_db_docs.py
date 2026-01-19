import pymysql
from datetime import datetime

# DB 연결
conn = pymysql.connect(
    host='192.168.0.56',
    port=3306,
    user='remote_user',
    password='0000',
    database='sanai',
    charset='utf8mb4'
)

output = []

def add_line(text=""):
    output.append(text)

try:
    cursor = conn.cursor()
    
    # 헤더
    add_line("# SANAI DATABASE 전체 스키마 문서")
    add_line()
    add_line(f"**생성일시**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    add_line()
    
    # 데이터베이스 기본 정보
    cursor.execute("SELECT DATABASE()")
    db_name = cursor.fetchone()[0]
    
    cursor.execute("SELECT VERSION()")
    version = cursor.fetchone()[0]
    
    add_line("## 📊 데이터베이스 기본 정보")
    add_line()
    add_line(f"- **데이터베이스명**: {db_name}")
    add_line(f"- **MySQL 버전**: {version}")
    add_line(f"- **문자셋**: utf8mb4")
    add_line()
    
    # 테이블 목록
    cursor.execute("SHOW TABLES")
    tables = sorted([row[0] for row in cursor.fetchall()])
    
    add_line(f"- **총 테이블 수**: {len(tables)}개")
    add_line()
    
    # 요약 통계
    total_records = 0
    table_stats = []
    for table_name in tables:
        cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
        count = cursor.fetchone()[0]
        total_records += count
        table_stats.append((table_name, count))
    
    add_line(f"- **총 레코드 수**: {total_records:,}건")
    add_line()
    
    # 목차
    add_line("---")
    add_line()
    add_line("## 📑 목차")
    add_line()
    add_line("1. [테이블 목록 및 레코드 수](#테이블-목록-및-레코드-수)")
    add_line("2. [테이블별 상세 스키마](#테이블별-상세-스키마)")
    add_line("3. [외래키 제약조건](#외래키-제약조건)")
    add_line("4. [인덱스 정보](#인덱스-정보)")
    add_line("5. [트리거 정보](#트리거-정보)")
    add_line("6. [ENUM 타입 정보](#enum-타입-정보)")
    add_line("7. [데이터베이스 ERD 관계](#데이터베이스-erd-관계)")
    add_line()
    add_line("---")
    add_line()
    
    # 1. 테이블 목록
    add_line("## 테이블 목록 및 레코드 수")
    add_line()
    add_line("| 번호 | 테이블명 | 레코드 수 | 설명 |")
    add_line("|------|----------|-----------|------|")
    
    table_descriptions = {
        'accounts': '은행 계좌 정보',
        'admins': '관리자 계정',
        'chat_rooms': '채팅방',
        'client_profiles': '클라이언트 프로필',
        'companies': '기업 정보',
        'contract_milestones': '계약 마일스톤',
        'contracts': '계약 정보',
        'freelancer_careers': '프리랜서 경력',
        'freelancer_portfolios': '프리랜서 포트폴리오',
        'freelancer_profiles': '프리랜서 프로필',
        'freelancer_project_experiences': '프리랜서 프로젝트 경험',
        'freelancer_skills': '프리랜서 기술',
        'freelancer_wallets': '프리랜서 지갑',
        'messages': '채팅 메시지',
        'milestone_histories': '마일스톤 변경 이력',
        'project_applications': '프로젝트 지원서',
        'project_bookmarks': '프로젝트 북마크',
        'project_freelancer_stacks': '지원서별 기술스택',
        'project_stacks': '프로젝트 요구 기술',
        'projects': '프로젝트 정보',
        'queue_matchings': '큐 매칭 정보',
        'queue_stacks': '큐 기술스택',
        'queues': '프리랜서 대기 큐',
        'stacks': '기술 스택 마스터',
        'users': '사용자 정보',
        'wallet_histories': '지갑 입출금 이력'
    }
    
    for idx, (table_name, count) in enumerate(table_stats, 1):
        desc = table_descriptions.get(table_name, '')
        add_line(f"| {idx} | `{table_name}` | {count} | {desc} |")
    
    add_line()
    add_line("---")
    add_line()
    
    # 2. 테이블별 상세 스키마
    add_line("## 테이블별 상세 스키마")
    add_line()
    
    for table_name in tables:
        add_line(f"### 📋 {table_name}")
        add_line()
        
        # 테이블 설명
        if table_name in table_descriptions:
            add_line(f"**설명**: {table_descriptions[table_name]}")
            add_line()
        
        # 컬럼 정보
        cursor.execute(f"DESCRIBE {table_name}")
        columns = cursor.fetchall()
        
        add_line("| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |")
        add_line("|--------|------|------|-----|---------|-------|")
        
        for col in columns:
            field, type_, null, key, default, extra = col
            default_str = str(default) if default is not None else ""
            add_line(f"| `{field}` | {type_} | {null} | {key} | {default_str} | {extra} |")
        
        # 레코드 수
        cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
        count = cursor.fetchone()[0]
        
        # 테이블 상태
        cursor.execute(f"SHOW TABLE STATUS LIKE '{table_name}'")
        status = cursor.fetchone()
        if status:
            engine = status[1]
            collation = status[14]
            add_line()
            add_line(f"**통계**: 레코드 {count}건 | 엔진: {engine} | 콜레이션: {collation}")
        
        add_line()
        add_line("---")
        add_line()
    
    # 3. 외래키 제약조건
    add_line("## 외래키 제약조건")
    add_line()
    
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
        add_line("| 제약조건명 | 테이블 | 컬럼 | 참조 테이블 | 참조 컬럼 |")
        add_line("|-----------|--------|------|------------|----------|")
        
        for fk in fk_constraints:
            constraint_name, table_name, column_name, ref_table, ref_column = fk
            add_line(f"| `{constraint_name}` | `{table_name}` | `{column_name}` | `{ref_table}` | `{ref_column}` |")
    
    add_line()
    add_line(f"**총 {len(fk_constraints)}개의 외래키 제약조건**")
    add_line()
    add_line("---")
    add_line()
    
    # 4. 인덱스 정보
    add_line("## 인덱스 정보")
    add_line()
    
    for table_name in tables:
        cursor.execute(f"SHOW INDEX FROM {table_name}")
        indexes = cursor.fetchall()
        
        if indexes:
            add_line(f"### {table_name}")
            add_line()
            
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
                unique_str = "🔑 UNIQUE" if idx_info['unique'] else "📇 INDEX"
                columns_str = ", ".join(idx_info['columns'])
                add_line(f"- {unique_str}: `{idx_name}` ({columns_str})")
            
            add_line()
    
    add_line("---")
    add_line()
    
    # 5. 트리거 정보
    add_line("## 트리거 정보")
    add_line()
    
    cursor.execute("SHOW TRIGGERS")
    triggers = cursor.fetchall()
    
    if triggers:
        for trigger in triggers:
            trigger_name = trigger[0]
            event = trigger[1]
            table = trigger[2]
            statement = trigger[3]
            timing = trigger[4]
            
            add_line(f"### ⚡ {trigger_name}")
            add_line()
            add_line(f"- **테이블**: `{table}`")
            add_line(f"- **이벤트**: {timing} {event}")
            add_line(f"- **실행문**:")
            add_line()
            add_line("```sql")
            add_line(statement)
            add_line("```")
            add_line()
    else:
        add_line("트리거가 없습니다.")
        add_line()
    
    add_line(f"**총 {len(triggers)}개의 트리거**")
    add_line()
    add_line("---")
    add_line()
    
    # 6. ENUM 타입 정보
    add_line("## ENUM 타입 정보")
    add_line()
    
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
        current_table = None
        for enum_col in enum_columns:
            table, column, col_type = enum_col
            
            if current_table != table:
                if current_table is not None:
                    add_line()
                add_line(f"### {table}")
                add_line()
                current_table = table
            
            add_line(f"- **{column}**: {col_type}")
    
    add_line()
    add_line(f"**총 {len(enum_columns)}개의 ENUM 컬럼**")
    add_line()
    add_line("---")
    add_line()
    
    # 7. ERD 관계 설명
    add_line("## 데이터베이스 ERD 관계")
    add_line()
    add_line("### 핵심 엔티티 관계")
    add_line()
    add_line("```")
    add_line("users (사용자)")
    add_line("├── freelancer_profiles (프리랜서 프로필)")
    add_line("│   ├── freelancer_careers (경력)")
    add_line("│   ├── freelancer_portfolios (포트폴리오)")
    add_line("│   ├── freelancer_project_experiences (프로젝트 경험)")
    add_line("│   ├── freelancer_skills (보유 기술)")
    add_line("│   ├── freelancer_wallets (지갑)")
    add_line("│   │   └── wallet_histories (입출금 이력)")
    add_line("│   └── queues (대기 큐)")
    add_line("│       └── queue_stacks (큐 기술스택)")
    add_line("│")
    add_line("├── client_profiles (클라이언트 프로필)")
    add_line("│   └── companies (소속 기업)")
    add_line("│")
    add_line("└── accounts (계좌 정보)")
    add_line()
    add_line("projects (프로젝트)")
    add_line("├── project_stacks (요구 기술)")
    add_line("├── project_applications (지원서)")
    add_line("│   └── project_freelancer_stacks (지원자 기술)")
    add_line("├── project_bookmarks (북마크)")
    add_line("├── queue_matchings (큐 매칭)")
    add_line("└── chat_rooms (채팅방)")
    add_line("    └── messages (메시지)")
    add_line()
    add_line("contracts (계약)")
    add_line("└── contract_milestones (마일스톤)")
    add_line("    └── milestone_histories (변경 이력)")
    add_line("```")
    add_line()
    add_line("---")
    add_line()
    
    # 통계 요약
    add_line("## 📊 통계 요약")
    add_line()
    add_line(f"- 총 테이블: **{len(tables)}개**")
    add_line(f"- 총 레코드: **{total_records:,}건**")
    add_line(f"- 외래키: **{len(fk_constraints)}개**")
    add_line(f"- 트리거: **{len(triggers)}개**")
    add_line(f"- ENUM 컬럼: **{len(enum_columns)}개**")
    add_line()
    add_line("---")
    add_line()
    add_line("*문서 끝*")
    
    # 파일로 저장
    with open('SANAI_DATABASE_SCHEMA.md', 'w', encoding='utf-8') as f:
        f.write('\n'.join(output))
    
    print("✅ SANAI_DATABASE_SCHEMA.md 파일이 생성되었습니다!")
    print(f"📄 총 {len(output)}줄")
    print(f"📊 테이블 {len(tables)}개, 레코드 {total_records:,}건")

finally:
    cursor.close()
    conn.close()
