@echo off
chcp 65001 > nul
echo ========================================
echo   MySQL 데이터베이스 자동 설정
echo ========================================
echo.

set DUMP_FILE=C:\program\sanaidump.sql
set DB_NAME=sanai
set DB_USER=remote_user
set DB_PASS=0000
set ROOT_PASS=0000

echo MySQL Root 비밀번호를 입력하세요:
set /p ROOT_PASS="Root 비밀번호 (기본값: 0000): " || set ROOT_PASS=0000
echo.

echo [1/4] 덤프 파일 확인...
if not exist "%DUMP_FILE%" (
    echo ❌ 덤프 파일을 찾을 수 없습니다: %DUMP_FILE%
    pause
    exit /b 1
)
echo ✅ 덤프 파일 확인

echo.
echo [2/4] 데이터베이스 생성...
mysql -u root -p%ROOT_PASS% -e "CREATE DATABASE IF NOT EXISTS %DB_NAME% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>nul
if errorlevel 1 (
    echo ❌ 데이터베이스 생성 실패
    echo    MySQL이 설치되어 있고 실행 중인지 확인하세요.
    echo    Root 비밀번호가 올바른지 확인하세요.
    pause
    exit /b 1
)
echo ✅ 데이터베이스 생성 완료

echo.
echo [3/4] 사용자 생성 및 권한 부여...
mysql -u root -p%ROOT_PASS% -e "CREATE USER IF NOT EXISTS '%DB_USER%'@'localhost' IDENTIFIED BY '%DB_PASS%';" 2>nul
mysql -u root -p%ROOT_PASS% -e "GRANT ALL PRIVILEGES ON %DB_NAME%.* TO '%DB_USER%'@'localhost';" 2>nul
mysql -u root -p%ROOT_PASS% -e "FLUSH PRIVILEGES;" 2>nul
if errorlevel 1 (
    echo ❌ 사용자 생성 실패
    pause
    exit /b 1
)
echo ✅ 사용자 생성 및 권한 부여 완료

echo.
echo [4/4] 덤프 파일 복원...
echo    이 작업은 몇 초 걸릴 수 있습니다...
mysql -u root -p%ROOT_PASS% %DB_NAME% < "%DUMP_FILE%" 2>nul
if errorlevel 1 (
    echo ❌ 덤프 복원 실패
    pause
    exit /b 1
)
echo ✅ 덤프 파일 복원 완료

echo.
echo ========================================
echo   데이터베이스 설정 완료!
echo ========================================
echo.
echo 📊 데이터베이스 정보:
echo    Host: localhost:3306
echo    Database: %DB_NAME%
echo    User: %DB_USER%
echo    Password: %DB_PASS%
echo.
echo 테이블 확인:
mysql -u root -p%ROOT_PASS% -e "USE %DB_NAME%; SHOW TABLES;" 2>nul
echo.
echo 다음 단계:
echo    1. update-db-config.bat 실행 (localhost로 변경)
echo    2. start.bat 실행
echo.
pause
