"""
계약 리뷰 시스템 - 테스트 데이터 삽입 스크립트
DB에 테스트 데이터를 삽입하여 리뷰 페이지를 실제로 테스트할 수 있게 합니다.
"""

import mysql.connector
from mysql.connector import Error
from datetime import datetime

def create_connection():
    """MySQL 데이터베이스 연결"""
    try:
        connection = mysql.connector.connect(
            host='192.168.0.56',
            port=3306,
            database='sanai',
            user='remote_user',
            password='0000',
            charset='utf8mb4',
            collation='utf8mb4_general_ci'
        )
        if connection.is_connected():
            print("✅ MySQL 데이터베이스 연결 성공")
            return connection
    except Error as e:
        print(f"❌ 데이터베이스 연결 실패: {e}")
        return None

def check_existing_data(connection):
    """기존 테스트 데이터 확인"""
    cursor = connection.cursor(dictionary=True)
    
    # projects 확인
    cursor.execute("SELECT COUNT(*) as count FROM projects")
    project_count = cursor.fetchone()['count']
    
    # contracts 확인
    cursor.execute("SELECT COUNT(*) as count FROM contracts")
    contract_count = cursor.fetchone()['count']
    
    print(f"\n📊 현재 DB 상태:")
    print(f"   - Projects: {project_count}개")
    print(f"   - Contracts: {contract_count}개")
    
    cursor.close()
    return project_count, contract_count

def insert_test_data(connection):
    """테스트 데이터 삽입"""
    cursor = connection.cursor()
    
    try:
        # 1. 사용자 데이터 삽입 (프로젝트/계약보다 먼저)
        print("\n👤 테스트 사용자 데이터 삽입 중...")
        users_sql = """
        INSERT INTO users (
            user_id, login_id, email, password, user_type, name, phone, birth_date,
            status, created_at
        ) VALUES
        (1, 'client1', 'client1@test.com', 'password123', 'CLIENT', '김클라이언트', '010-1111-1111', '1990-01-01', 'ACTIVE', NOW()),
        (2, 'client2', 'client2@test.com', 'password123', 'CLIENT', '박클라이언트', '010-2222-2222', '1985-05-15', 'ACTIVE', NOW()),
        (3, 'freelancer1', 'freelancer1@test.com', 'password123', 'FREELANCER', '이프리랜서', '010-3333-3333', '1992-03-20', 'ACTIVE', NOW()),
        (4, 'freelancer2', 'freelancer2@test.com', 'password123', 'FREELANCER', '최프리랜서', '010-4444-4444', '1988-07-10', 'ACTIVE', NOW())
        ON DUPLICATE KEY UPDATE user_id=user_id
        """
        cursor.execute(users_sql)
        print(f"   ✅ 사용자 {cursor.rowcount}명 확인/삽입 완료")
        
        # 2. 프로젝트 데이터 삽입
        print("\n📝 프로젝트 데이터 삽입 중...")
        projects_sql = """
        INSERT INTO projects (
            client_id, title, description, budget,
            start_date, deadline_date, est_duration, communicate_method, payment_method,
            max_revision_count, project_status, is_public, created_at
        ) VALUES
        (1, '웹사이트 리뉴얼 프로젝트', '기존 웹사이트를 모던한 디자인으로 리뉴얼', 6000000,
         '2025-01-01', '2025-03-31', '3개월', 'CHAT', 'MILESTONE', 3, 'CLOSED', 1, NOW()),
        (1, '모바일 앱 개발', 'iOS/Android 하이브리드 앱 개발', 12000000,
         '2025-02-01', '2025-06-30', '5개월', 'CHAT', 'FULL', 5, 'IN_PROGRESS', 1, NOW()),
        (2, '백엔드 API 구축', 'RESTful API 서버 구축 및 배포', 10000000,
         '2024-10-01', '2024-12-31', '3개월', 'CHAT', 'MILESTONE', 3, 'CLOSED', 1, NOW())
        """
        cursor.execute(projects_sql)
        print(f"   ✅ 프로젝트 {cursor.rowcount}개 삽입 완료")
        
        # 최근 삽입된 project_id들 가져오기
        cursor.execute("SELECT project_id FROM projects ORDER BY project_id DESC LIMIT 3")
        project_ids = [row[0] for row in cursor.fetchall()]
        project_ids.reverse()  # 오래된 순서로
        
        # 3. 프로젝트 지원(project_applications) 데이터 삽입
        print("\n📝 프로젝트 지원 데이터 삽입 중...")
        applications_sql = f"""
        INSERT INTO project_applications (
            project_id, freelancer_id, is_contracted, applied_at
        ) VALUES
        ({project_ids[0]}, 3, 1, NOW()),
        ({project_ids[1]}, 3, 1, NOW()),
        ({project_ids[2]}, 4, 1, NOW())
        """
        cursor.execute(applications_sql)
        print(f"   ✅ 지원 {cursor.rowcount}개 삽입 완료")
        
        # 최근 삽입된 application_id들 가져오기
        cursor.execute("SELECT application_id FROM project_applications ORDER BY application_id DESC LIMIT 3")
        application_ids = [row[0] for row in cursor.fetchall()]
        application_ids.reverse()  # 오래된 순서로
        
        # 4. 계약 데이터 삽입
        print("\n📝 계약 데이터 삽입 중...")
        
        # 4. 계약 데이터 삽입
        print("\n📝 계약 데이터 삽입 중...")
        
        # 계약 1: 리뷰 미작성
        contract1_sql = f"""
        INSERT INTO contracts (
            contract_id, total_budget, payment_method,
            contract_start_date, contract_end_date, contract_status,
            contracted_at,
            client_rating, client_experience, client_is_renewal_intended,
            freelancer_rating, freelancer_experience
        ) VALUES
        ({application_ids[0]}, 6000000, 'MILESTONE',
         '2025-01-01', '2025-03-31', 'COMPLETED',
         NOW(),
         NULL, NULL, NULL, NULL, NULL)
        """
        cursor.execute(contract1_sql)
        print(f"   ✅ 계약 1 삽입 완료 (리뷰 미작성, contract_id={application_ids[0]})")
        
        # 계약 2: 클라이언트만 작성
        contract2_sql = f"""
        INSERT INTO contracts (
            contract_id, total_budget, payment_method,
            contract_start_date, contract_end_date, contract_status,
            contracted_at,
            client_rating, client_experience, client_is_renewal_intended,
            freelancer_rating, freelancer_experience
        ) VALUES
        ({application_ids[1]}, 12000000, 'FULL',
         '2025-02-01', '2025-06-30', 'COMPLETED',
         NOW(),
         5, '매우 훌륭한 프리랜서입니다. 의사소통이 원활하고 품질이 우수합니다.', 1,
         NULL, NULL)
        """
        cursor.execute(contract2_sql)
        print(f"   ✅ 계약 2 삽입 완료 (클라이언트 리뷰만 작성, contract_id={application_ids[1]})")
        
        # 계약 3: 양쪽 모두 작성
        contract3_sql = f"""
        INSERT INTO contracts (
            contract_id, total_budget, payment_method,
            contract_start_date, contract_end_date, contract_status,
            contracted_at,
            client_rating, client_experience, client_is_renewal_intended,
            freelancer_rating, freelancer_experience
        ) VALUES
        ({application_ids[2]}, 10000000, 'MILESTONE',
         '2024-10-01', '2024-12-31', 'COMPLETED',
         NOW(),
         4, '좋은 프리랜서였습니다. 다만 일정이 조금 늦어진 점이 아쉽습니다.', 0,
         5, '정말 좋은 클라이언트였습니다. 의사소통도 명확하고 대금 지급도 신속했습니다.')
        """
        cursor.execute(contract3_sql)
        print(f"   ✅ 계약 3 삽입 완료 (양쪽 모두 작성, contract_id={application_ids[2]})")
        
        # 커밋
        connection.commit()
        print("\n✅ 모든 테스트 데이터 삽입 완료")
        
        return application_ids[0]  # 첫 번째 계약 ID 반환 (리뷰 미작성 상태)
        
    except Error as e:
        print(f"\n❌ 데이터 삽입 실패: {e}")
        connection.rollback()
        return None
    finally:
        cursor.close()

def verify_data(connection, first_contract_id):
    """삽입된 데이터 검증"""
    cursor = connection.cursor()
    
    print("\n" + "="*70)
    print("📊 삽입된 테스트 데이터 확인")
    print("="*70)
    
    sql = f"""
    SELECT 
        c.contract_id,
        p.title AS project_title,
        p.client_id,
        c.total_budget,
        c.client_rating,
        c.freelancer_rating
    FROM contracts c
    LEFT JOIN project_applications pa ON c.contract_id = pa.application_id
    LEFT JOIN projects p ON pa.project_id = p.project_id
    WHERE c.contract_id >= {first_contract_id}
    ORDER BY c.contract_id
    """
    
    cursor.execute(sql)
    results = cursor.fetchall()
    
    contract_ids = []
    for row in results:
        contract_ids.append(row[0])
        print(f"\n계약 ID: {row[0]}")
        print(f"프로젝트: {row[1]}")
        print(f"클라이언트 ID: {row[2]}")
        print(f"계약금액: {row[3]:,}원")
        print(f"클라이언트 리뷰: {'✅ 작성 완료' if row[4] is not None else '❌ 미작성'}")
        print(f"프리랜서 리뷰: {'✅ 작성 완료' if row[5] is not None else '❌ 미작성'}")
    
    cursor.close()
    return contract_ids

def main():
    print("\n" + "="*70)
    print("🚀 계약 리뷰 시스템 - 테스트 데이터 준비")
    print("="*70)
    
    # DB 연결
    connection = create_connection()
    if not connection:
        print("\n❌ DB 연결 실패. 종료합니다.")
        return
    
    try:
        # 기존 데이터 확인
        project_count, contract_count = check_existing_data(connection)
        
        # 사용자 확인
        if project_count > 0 or contract_count > 0:
            print(f"\n⚠️  이미 데이터가 존재합니다. 테스트 데이터를 추가할까요?")
            response = input("계속하려면 'yes' 입력: ")
            if response.lower() != 'yes':
                print("❌ 작업 취소")
                return
        
        # 테스트 데이터 삽입
        first_contract_id = insert_test_data(connection)
        
        if not first_contract_id:
            print("\n❌ 테스트 데이터 삽입 실패")
            return
        
        # 검증
        contract_ids = verify_data(connection, first_contract_id)
        
        if contract_ids:
            print("\n" + "="*70)
            print("✅ 테스트 준비 완료! 아래 링크로 접속하세요:")
            print("="*70)
            
            for i, cid in enumerate(contract_ids):
                print(f"\n【계약 {i+1}】 Contract ID: {cid}")
                print(f"   클라이언트 리뷰: http://localhost:9999/review/client?contractId={cid}")
                print(f"   프리랜서 리뷰: http://localhost:9999/review/freelancer?contractId={cid}")
            
            print("\n" + "="*70)
        
    except Exception as e:
        print(f"\n❌ 오류 발생: {e}")
        import traceback
        traceback.print_exc()
    finally:
        if connection.is_connected():
            connection.close()
            print("\n✅ DB 연결 종료")

if __name__ == "__main__":
    main()
