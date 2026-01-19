@echo off
chcp 65001 > nul
echo ========================================
echo   RatelOcean 완전한 로컬 개발 환경 구축
echo ========================================
echo.

set DUMP_FILE=C:\program\sanaidump.sql
set DB_NAME=sanai
set DB_USER=remote_user
set DB_PASS=0000

echo ========================================
echo   필수 소프트웨어 설치 가이드
echo ========================================
echo.

echo 📥 1. MySQL 8.0 설치
echo    - https://dev.mysql.com/downloads/mysql/
echo    - MySQL Community Server 8.0 다운로드
echo    - Windows Installer 실행
echo    - Root 비밀번호: 0000
echo.

echo 📥 2. Java JDK 11 설치 (선택사항, Maven 빌드용)
echo    - https://adoptium.net/
echo    - Temurin 11 (LTS) 다운로드
echo    - 설치 시 'Set JAVA_HOME' 및 'Add to PATH' 체크
echo.

echo 📥 3. Maven 3.x 설치 (선택사항)
echo    - https://maven.apache.org/download.cgi
echo    - Binary zip archive 다운로드
echo    - C:\Program Files에 압축 해제
echo    - PATH 환경 변수에 bin 폴더 추가
echo.

pause
echo.

echo ========================================
echo   MySQL 데이터베이스 설정
echo ========================================
echo.

echo [1/3] 덤프 파일 확인...
if not exist "%DUMP_FILE%" (
    echo ❌ 덤프 파일을 찾을 수 없습니다: %DUMP_FILE%
    pause
    exit /b 1
)
echo ✅ 덤프 파일 확인: %DUMP_FILE%

echo.
echo [2/3] MySQL 서비스 확인...
sc query MySQL80 >nul 2>&1
if errorlevel 1 (
    echo ⚠️  MySQL 서비스를 찾을 수 없습니다.
    echo    MySQL을 먼저 설치하세요.
) else (
    echo ✅ MySQL 서비스 발견
    echo    서비스 시작 중...
    net start MySQL80 >nul 2>&1
    if errorlevel 1 (
        echo    (이미 실행 중이거나 시작됨)
    )
)

echo.
echo [3/3] 데이터베이스 설정 명령어
echo.
echo 다음 명령을 차례대로 실행하세요:
echo ========================================
echo.
echo 1. MySQL 접속:
echo    mysql -u root -p
echo    (비밀번호: 0000 입력)
echo.
echo 2. 데이터베이스 및 사용자 생성:
echo.
echo    CREATE DATABASE IF NOT EXISTS %DB_NAME% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
echo    CREATE USER IF NOT EXISTS '%DB_USER%'@'localhost' IDENTIFIED BY '%DB_PASS%';
echo    GRANT ALL PRIVILEGES ON %DB_NAME%.* TO '%DB_USER%'@'localhost';
echo    FLUSH PRIVILEGES;
echo    EXIT;
echo.
echo 3. 덤프 파일 복원:
echo    mysql -u root -p %DB_NAME% ^< %DUMP_FILE%
echo    (비밀번호: 0000 입력)
echo.
echo ========================================
echo.
echo 💡 팁: 위 명령을 복사해서 실행하세요.
echo.

pause
echo.

echo ========================================
echo   프로젝트 설정 변경
echo ========================================
echo.
echo db.properties를 localhost로 변경합니다...
echo 파일: src\main\resources\db.properties
echo.
echo 변경 내용:
echo   192.168.0.56 → localhost
echo.

echo 자동 업데이트를 실행하시겠습니까?
set /p CONFIRM="(Y/n): "
if /i "%CONFIRM%"=="n" (
    echo.
    echo 수동으로 변경하세요: src\main\resources\db.properties
    echo.
) else (
    echo.
    echo update-db-config.bat 스크립트를 실행하세요.
    echo.
)

echo ========================================
echo   설치 가이드 완료!
echo ========================================
echo.
echo 📋 체크리스트:
echo    □ MySQL 8.0 설치
echo    □ MySQL 서비스 시작
echo    □ sanai 데이터베이스 생성
echo    □ remote_user 계정 생성
echo    □ 덤프 파일 복원
echo    □ db.properties를 localhost로 변경
echo    □ Java 11 설치 (선택)
echo    □ Maven 설치 (선택)
echo.
echo 모든 작업 완료 후:
echo    start.bat 실행!
echo.
pause
