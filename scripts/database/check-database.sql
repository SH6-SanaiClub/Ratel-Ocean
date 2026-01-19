-- ================================
-- RatelOcean 데이터베이스 설정 확인 스크립트
-- MySQL Workbench에서 실행하여 확인하세요
-- ================================

-- 1. 현재 데이터베이스 목록 확인
SHOW DATABASES;

-- 2. sanai 데이터베이스가 있는지 확인
SELECT SCHEMA_NAME 
FROM information_schema.SCHEMATA 
WHERE SCHEMA_NAME = 'sanai';

-- 3. sanai 데이터베이스 선택
USE sanai;

-- 4. 테이블 목록 확인
SHOW TABLES;

-- 5. 테이블 개수 확인
SELECT COUNT(*) AS 'Total Tables' 
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'sanai';

-- 6. 각 테이블의 데이터 개수 확인
SELECT 
    TABLE_NAME AS 'Table',
    TABLE_ROWS AS 'Rows'
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'sanai'
ORDER BY TABLE_NAME;

-- 7. remote_user 계정 확인
SELECT User, Host 
FROM mysql.user 
WHERE User = 'remote_user';

-- 8. remote_user 권한 확인
SHOW GRANTS FOR 'remote_user'@'localhost';

-- 9. 데이터베이스 문자셋 확인
SELECT 
    DEFAULT_CHARACTER_SET_NAME AS 'Charset',
    DEFAULT_COLLATION_NAME AS 'Collation'
FROM information_schema.SCHEMATA 
WHERE SCHEMA_NAME = 'sanai';

-- ================================
-- 예상 결과:
-- ================================
-- ✅ sanai 데이터베이스가 보여야 함
-- ✅ 테이블이 여러 개 보여야 함 (accounts, users, contracts 등)
-- ✅ remote_user@localhost 계정이 보여야 함
-- ✅ Charset: utf8mb4, Collation: utf8mb4_unicode_ci

-- ================================
-- 문제가 있다면:
-- ================================
-- ❌ sanai 데이터베이스가 없으면 → setup-database.sql 다시 실행
-- ❌ 테이블이 없으면 → sanaidump.sql 다시 실행
-- ❌ remote_user가 없으면 → setup-database.sql 다시 실행
