@echo off
chcp 65001 > nul
cls
echo ========================================
echo   RatelOcean 한 번에 실행하기
echo ========================================
echo.
echo MySQL이 아직 설치되지 않았습니다.
echo 빠르게 실행하는 방법을 선택하세요:
echo.
echo ========================================
echo   옵션 1: MySQL 빠른 설치 (권장)
echo ========================================
echo   - MySQL 공식 사이트에서 다운로드
echo   - 설치 시간: 약 10-15분
echo   - 완전한 로컬 개발 환경 구축
echo.
echo ========================================
echo   옵션 2: 원격 DB 사용 (빠른 테스트)
echo ========================================
echo   - 192.168.0.56 MySQL 서버 사용
echo   - 즉시 실행 가능 (네트워크 연결 필요)
echo   - 현재 원격 서버 접근 불가능 상태
echo.
echo ========================================
echo.

set /p CHOICE="선택 (1 또는 2): "

if "%CHOICE%"=="2" goto remote
if "%CHOICE%"=="1" goto local
echo 잘못된 선택입니다.
pause
exit /b 1

:local
cls
echo ========================================
echo   MySQL 8.0 설치 - 단계별 가이드
echo ========================================
echo.
echo 1단계: MySQL Installer 다운로드
echo ----------------------------------------
echo.
echo 다음 링크가 브라우저에서 열립니다:
echo https://dev.mysql.com/downloads/mysql/
echo.
pause
start https://dev.mysql.com/downloads/mysql/
echo.
echo 2단계: 다운로드 및 설치
echo ----------------------------------------
echo.
echo 페이지에서:
echo   1. "Go to Download Page" 클릭
echo   2. "Windows (x86, 32-bit), MSI Installer" 선택
echo   3. "No thanks, just start my download" 클릭
echo   4. 다운로드된 mysql-installer-community-x.x.x.msi 실행
echo.
echo 3단계: 설치 옵션 선택
echo ----------------------------------------
echo   Setup Type: "Developer Default" 선택
echo   MySQL Server Config:
echo     - Type: Development Computer
echo     - Port: 3306
echo     - Root Password: 0000
echo     - Windows Service: MySQL80 (자동 시작)
echo.
echo 설치를 완료한 후 Enter를 누르세요...
pause >nul
echo.

echo 4단계: MySQL 설치 확인
echo ----------------------------------------
sc query MySQL80 >nul 2>&1
if errorlevel 1 (
    echo ❌ MySQL 서비스를 찾을 수 없습니다.
    echo.
    echo 다음을 확인하세요:
    echo   1. 설치가 완료되었는가?
    echo   2. Windows Service로 설치했는가?
    echo   3. 서비스 이름이 MySQL80인가?
    echo.
    echo services.msc를 열어 MySQL 서비스를 확인하세요.
    start services.msc
    echo.
    pause
    exit /b 1
)

echo ✅ MySQL 설치 확인 완료
echo.

echo 5단계: MySQL 서비스 시작
echo ----------------------------------------
net start MySQL80 2>nul
echo ✅ MySQL 서비스 실행 중
echo.

echo 6단계: 데이터베이스 자동 생성
echo ----------------------------------------
call setup-database.bat
if errorlevel 1 (
    echo ❌ 데이터베이스 생성 실패
    pause
    exit /b 1
)

echo.
echo 7단계: localhost로 설정 변경
echo ----------------------------------------
call update-db-config.bat

echo.
echo 8단계: 서버 시작
echo ----------------------------------------
call start.bat
goto end

:remote
cls
echo ========================================
echo   원격 MySQL 사용 (192.168.0.56)
echo ========================================
echo.

echo 원격 서버 연결 테스트 중...
ping -n 1 192.168.0.56 >nul 2>&1
if errorlevel 1 (
    echo.
    echo ❌ 192.168.0.56 서버에 접근할 수 없습니다.
    echo.
    echo 가능한 원인:
    echo   - 서버가 꺼져 있음
    echo   - 네트워크 연결 안 됨
    echo   - 방화벽 차단
    echo.
    echo 로컬 MySQL 설치를 권장합니다.
    set /p RETRY="옵션 1 (로컬 설치)로 다시 시도하시겠습니까? (y/N): "
    if /i "%RETRY%"=="y" goto local
    pause
    exit /b 1
)

echo ✅ 원격 서버 접근 가능
echo.

echo db.properties 확인 중...
type src\main\resources\db.properties | findstr "db.url" | findstr "localhost" >nul
if not errorlevel 1 (
    echo 원격 서버로 변경 중...
    powershell -Command "(Get-Content 'src\main\resources\db.properties') -replace 'localhost', '192.168.0.56' | Set-Content 'src\main\resources\db.properties'"
    if exist "target\classes\db.properties" (
        powershell -Command "(Get-Content 'target\classes\db.properties') -replace 'localhost', '192.168.0.56' | Set-Content 'target\classes\db.properties'"
    )
    echo ✅ 원격 서버로 변경 완료
) else (
    echo ✅ 이미 원격 서버로 설정됨
)

echo.
echo 서버 시작 중...
call start.bat

:end
echo.
echo ========================================
echo   완료!
echo ========================================
echo.
pause
