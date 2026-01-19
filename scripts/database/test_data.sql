-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 계약 리뷰 테스트 데이터
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 
-- [목적]
-- 계약 리뷰 작성 기능을 테스트하기 위한 샘플 데이터 생성
-- 
-- [삽입 데이터]
-- 1. contracts 테이블: 3개의 샘플 계약
--    - 계약 1: client_id=1, freelancer_id=2, 리뷰 미작성
--    - 계약 2: client_id=1, freelancer_id=3, 클라이언트만 작성
--    - 계약 3: client_id=2, freelancer_id=2, 양쪽 작성 완료
-- 
-- 2. projects 테이블: 3개의 샘플 프로젝트
-- 
-- [주의사항]
-- - 실제 운영 환경에서는 사용하지 마세요
-- - 테스트 완료 후 데이터를 삭제하세요
-- 
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

USE sanai;

-- ━━━━ 프로젝트 테스트 데이터 ━━━━
INSERT INTO projects (
    client_id, title, description, budget_min, budget_max,
    start_date, end_date, status, created_at
) VALUES
(1, '웹사이트 리뉴얼 프로젝트', '기존 웹사이트를 모던한 디자인으로 리뉴얼', 5000000, 7000000,
 '2025-01-01', '2025-03-31', 'COMPLETED', NOW()),
(1, '모바일 앱 개발', 'iOS/Android 하이브리드 앱 개발', 10000000, 15000000,
 '2025-02-01', '2025-06-30', 'IN_PROGRESS', NOW()),
(2, '백엔드 API 구축', 'RESTful API 서버 구축 및 배포', 8000000, 12000000,
 '2024-10-01', '2024-12-31', 'COMPLETED', NOW());

-- ━━━━ 계약 테스트 데이터 ━━━━

-- 계약 1: 리뷰 미작성 (테스트용)
INSERT INTO contracts (
    project_id, client_id, freelancer_id, contract_amount,
    start_date, end_date, status, payment_status, created_at,
    -- 리뷰 컬럼은 모두 NULL
    client_rating, client_experience, client_is_renewal_intended,
    freelancer_rating, freelancer_experience
) VALUES
(1, 1, 2, 6000000,
 '2025-01-01', '2025-03-31', 'COMPLETED', 'PAID', NOW(),
 NULL, NULL, NULL, NULL, NULL);

-- 계약 2: 클라이언트만 작성 (프리랜서 리뷰 테스트용)
INSERT INTO contracts (
    project_id, client_id, freelancer_id, contract_amount,
    start_date, end_date, status, payment_status, created_at,
    -- 클라이언트 리뷰만 작성됨
    client_rating, client_experience, client_is_renewal_intended,
    freelancer_rating, freelancer_experience
) VALUES
(2, 1, 3, 12000000,
 '2025-02-01', '2025-06-30', 'COMPLETED', 'PAID', NOW(),
 18, '매우 훌륭한 프리랜서입니다. 의사소통이 원활하고 품질이 우수합니다.', 1,
 NULL, NULL);

-- 계약 3: 양쪽 모두 작성 (중복 방지 테스트용)
INSERT INTO contracts (
    project_id, client_id, freelancer_id, contract_amount,
    start_date, end_date, status, payment_status, created_at,
    -- 양쪽 모두 리뷰 작성 완료
    client_rating, client_experience, client_is_renewal_intended,
    freelancer_rating, freelancer_experience
) VALUES
(3, 2, 2, 10000000,
 '2024-10-01', '2024-12-31', 'COMPLETED', 'PAID', NOW(),
 16, '좋은 프리랜서였습니다. 다만 일정이 조금 늦어진 점이 아쉽습니다.', 0,
 20, '정말 좋은 클라이언트였습니다. 의사소통도 명확하고 대금 지급도 신속했습니다.');

-- ━━━━ 데이터 확인 ━━━━
SELECT 
    c.contract_id,
    p.title AS project_title,
    c.client_id,
    c.freelancer_id,
    c.client_rating,
    c.freelancer_rating,
    CASE 
        WHEN c.client_rating IS NULL THEN '클라이언트 리뷰 미작성'
        ELSE '클라이언트 리뷰 작성 완료'
    END AS client_review_status,
    CASE 
        WHEN c.freelancer_rating IS NULL THEN '프리랜서 리뷰 미작성'
        ELSE '프리랜서 리뷰 작성 완료'
    END AS freelancer_review_status
FROM contracts c
LEFT JOIN projects p ON c.project_id = p.project_id
ORDER BY c.contract_id;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 테스트 URL (Tomcat 재시작 후 접속)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- 클라이언트 리뷰 작성 (계약 1):
-- http://localhost:9999/ratelocean/review/client?contractId=1
--
-- 프리랜서 리뷰 작성 (계약 2):
-- http://localhost:9999/ratelocean/review/freelancer?contractId=2
--
-- 중복 방지 테스트 (계약 3):
-- http://localhost:9999/ratelocean/review/client?contractId=3
-- http://localhost:9999/ratelocean/review/freelancer?contractId=3
--
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- 테스트 완료 후 데이터 삭제 (필요 시 실행)
-- DELETE FROM contracts WHERE contract_id IN (1, 2, 3);
-- DELETE FROM projects WHERE project_id IN (1, 2, 3);
