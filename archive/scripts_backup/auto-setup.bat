@echo off
chcp 65001 > nul
echo ========================================
echo   RatelOcean 완전 자동 세팅
echo ========================================
echo.

echo 실행 옵션을 선택하세요:
echo.
echo 1. 로컬 MySQL로 실행 (권장 - 완전한 로컬 환경)
echo 2. 원격 MySQL로 실행 (192.168.0.56 - 빠른 테스트)
echo.
set /p OPTION="선택 (1-2): "

if "%OPTION%"=="2" goto remote_setup

:local_setup
echo.
echo ========================================
echo   로컬 MySQL 환경 구축
echo ========================================
echo.

echo [1/5] MySQL 설치 확인...
sc query MySQL80 >nul 2>&1
if errorlevel 1 (
    echo ❌ MySQL이 설치되지 않았습니다.
    echo.
    echo MySQL 설치 방법:
    echo   Option A: install-mysql.bat 실행
    echo   Option B: https://dev.mysql.com/downloads/mysql/
    echo.
    set /p INSTALL="지금 설치 페이지를 여시겠습니까? (y/N): "
    if /i "%INSTALL%"=="y" (
        start https://dev.mysql.com/downloads/mysql/
        echo.
        echo 설치를 완료한 후 이 스크립트를 다시 실행하세요.
        pause
        exit /b 1
    ) else (
        echo.
        echo MySQL을 설치한 후 다시 실행하세요.
        pause
        exit /b 1
    )
)
echo ✅ MySQL 설치됨

echo.
echo [2/5] MySQL 서비스 시작...
net start MySQL80 2>nul
echo ✅ MySQL 서비스 확인

echo.
echo [3/5] 데이터베이스 설정...
echo.
echo MySQL Root 비밀번호를 입력하세요 (기본값: 0000):
set /p ROOT_PASS="Root 비밀번호: "
if "%ROOT_PASS%"=="" set ROOT_PASS=0000

call setup-database.bat
if errorlevel 1 (
    echo ❌ 데이터베이스 설정 실패
    pause
    exit /b 1
)

echo.
echo [4/5] localhost로 설정 변경...
call update-db-config.bat

echo.
echo [5/5] 서버 시작...
call start.bat
goto end

:remote_setup
echo.
echo ========================================
echo   원격 MySQL 환경 (192.168.0.56)
echo ========================================
echo.

echo [1/3] 원격 서버 연결 테스트...
ping -n 1 192.168.0.56 >nul 2>&1
if errorlevel 1 (
    echo ❌ 192.168.0.56 서버에 접근할 수 없습니다.
    echo    네트워크 연결을 확인하세요.
    echo.
    set /p CONTINUE="계속하시겠습니까? (y/N): "
    if /i not "%CONTINUE%"=="y" (
        exit /b 1
    )
) else (
    echo ✅ 원격 서버 접근 가능
)

echo.
echo [2/3] 원격 DB 설정 확인...
echo    db.properties가 이미 192.168.0.56으로 설정되어 있어야 합니다.
type src\main\resources\db.properties | findstr "db.url" | findstr "192.168.0.56"
if errorlevel 1 (
    echo ⚠️  db.properties가 localhost로 되어 있습니다.
    echo    원격 서버 주소로 복원합니다...
    
    powershell -Command "(Get-Content 'src\main\resources\db.properties') -replace 'localhost', '192.168.0.56' | Set-Content 'src\main\resources\db.properties'"
    if exist "target\classes\db.properties" (
        powershell -Command "(Get-Content 'target\classes\db.properties') -replace 'localhost', '192.168.0.56' | Set-Content 'target\classes\db.properties'"
    )
    echo ✅ 원격 서버로 변경 완료
) else (
    echo ✅ 이미 원격 서버로 설정됨
)

echo.
echo [3/3] 서버 시작...
call start.bat
goto end

:end
echo.
echo ========================================
echo   세팅 완료!
echo ========================================
pause
