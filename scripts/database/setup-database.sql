-- ================================
-- RatelOcean 데이터베이스 설정 스크립트
-- MySQL Workbench에서 실행하세요
-- ================================

-- 1단계: 데이터베이스 생성
CREATE DATABASE IF NOT EXISTS sanai 
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

-- 2단계: 사용자 생성 (localhost 접근용)
CREATE USER IF NOT EXISTS 'remote_user'@'localhost' 
  IDENTIFIED BY '0000';

-- 3단계: 권한 부여
GRANT ALL PRIVILEGES ON sanai.* 
  TO 'remote_user'@'localhost';

-- 4단계: 권한 적용
FLUSH PRIVILEGES;

-- 5단계: 데이터베이스 선택
USE sanai;

-- 6단계: 테이블 확인 (덤프 복원 후)
-- SHOW TABLES;

-- ================================
-- 완료!
-- ================================
-- 다음 단계:
-- 1. 이 스크립트를 MySQL Workbench에서 실행
-- 2. C:\program\sanaidump.sql 파일을 열어서 실행
-- 3. update-db-config.bat 실행
-- 4. start.bat 실행
