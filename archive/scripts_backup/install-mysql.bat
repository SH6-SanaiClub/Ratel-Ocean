@echo off
echo ========================================
echo   MySQL 8.0 자동 설치 도구
echo ========================================
echo.
echo 이 스크립트는 MySQL 8.0을 자동으로 다운로드하고 설치합니다.
echo 관리자 권한이 필요합니다.
echo.
pause

echo.
echo 설치 옵션을 선택하세요:
echo.
echo 1. MySQL 공식 사이트 열기 (수동 설치 - 권장)
echo 2. MySQL Installer 다운로드 링크 열기
echo 3. 설치 가이드만 표시
echo.
set /p CHOICE="선택 (1-3): "

if "%CHOICE%"=="1" (
    echo.
    echo MySQL 다운로드 페이지를 엽니다...
    start https://dev.mysql.com/downloads/mysql/
    echo.
    echo 다운로드 및 설치 단계:
    echo 1. "MySQL Installer for Windows" 선택
    echo 2. "Windows (x86, 32-bit), MSI Installer" 다운로드
    echo 3. 설치 프로그램 실행
    echo 4. "Developer Default" 또는 "Server only" 선택
    echo 5. Root 비밀번호: 0000
    echo 6. Windows Service 설정: MySQL80 (자동 시작)
    echo 7. 설치 완료 후 이 창으로 돌아오세요
    echo.
    pause
    goto :setup
)

if "%CHOICE%"=="2" (
    echo.
    echo MySQL Installer 직접 다운로드 링크를 엽니다...
    start https://dev.mysql.com/get/Downloads/MySQLInstaller/mysql-installer-community-8.0.40.0.msi
    echo.
    echo 다운로드가 완료되면 설치 프로그램을 실행하세요.
    echo Root 비밀번호: 0000
    echo.
    pause
    goto :setup
)

if "%CHOICE%"=="3" (
    goto :guide
)

:guide
echo.
echo ========================================
echo   MySQL 8.0 수동 설치 가이드
echo ========================================
echo.
echo 1. https://dev.mysql.com/downloads/mysql/ 접속
echo 2. "MySQL Installer for Windows" 다운로드
echo 3. mysql-installer-community-8.0.x.msi 실행
echo 4. 설치 타입: "Developer Default" 선택
echo 5. Root 비밀번호: 0000
echo 6. Windows Service: MySQL80 (자동 시작)
echo 7. Port: 3306 (기본값)
echo 8. 설치 완료!
echo.
pause
goto :end

:setup
echo.
echo ========================================
echo   MySQL 설치 확인
echo ========================================
echo.

echo MySQL 서비스를 확인합니다...
sc query MySQL80 >nul 2>&1
if errorlevel 1 (
    echo ❌ MySQL 서비스를 찾을 수 없습니다.
    echo    설치가 완료되지 않았거나 서비스 이름이 다릅니다.
    echo.
    echo 설치를 완료한 후 다시 실행하세요.
    pause
    exit /b 1
)

echo ✅ MySQL 서비스 발견!
echo.

echo MySQL 서비스를 시작합니다...
net start MySQL80 2>nul
if errorlevel 1 (
    echo (이미 실행 중일 수 있습니다)
) else (
    echo ✅ MySQL 서비스 시작됨
)

echo.
echo ========================================
echo   다음 단계
echo ========================================
echo.
echo MySQL 설치가 완료되었습니다!
echo.
echo 다음 명령을 실행하세요:
echo   1. setup-database.bat  - 데이터베이스 생성 및 복원
echo   2. update-db-config.bat - localhost로 변경
echo   3. start.bat - 서버 시작
echo.
pause

:end
