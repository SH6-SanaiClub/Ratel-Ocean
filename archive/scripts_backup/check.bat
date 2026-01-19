@echo off
chcp 65001 > nul
echo ========================================
echo   RatelOcean 실행 환경 체크
echo ========================================
echo.

set ALL_OK=1

REM Java 체크
echo [1/5] Java 설치 확인...
java -version >nul 2>&1
if errorlevel 1 (
    echo ❌ Java가 설치되지 않았거나 PATH에 등록되지 않았습니다.
    set ALL_OK=0
) else (
    java -version 2>&1 | findstr "version" 
    echo ✅ Java 확인 완료
)

echo.
REM Tomcat 체크
echo [2/5] Tomcat 설치 확인...
set TOMCAT_HOME=C:\program\apache-tomcat-9.0.112
if not exist "%TOMCAT_HOME%\bin\catalina.bat" (
    echo ❌ Tomcat을 찾을 수 없습니다: %TOMCAT_HOME%
    set ALL_OK=0
) else (
    echo ✅ Tomcat 확인: %TOMCAT_HOME%
)

echo.
REM WAR 파일 체크
echo [3/5] WAR 파일 확인...
set WAR_FILE=%~dp0target\ratelocean.war
if not exist "%WAR_FILE%" (
    echo ❌ WAR 파일을 찾을 수 없습니다: %WAR_FILE%
    echo    Maven 빌드가 필요합니다: mvn clean package
    set ALL_OK=0
) else (
    for %%F in ("%WAR_FILE%") do echo ✅ WAR 파일 확인: %%~zF bytes
)

echo.
REM 데이터베이스 연결 체크
echo [4/5] 데이터베이스 설정 확인...
set DB_PROPS=%~dp0src\main\resources\db.properties
if not exist "%DB_PROPS%" (
    echo ❌ DB 설정 파일을 찾을 수 없습니다: %DB_PROPS%
    set ALL_OK=0
) else (
    echo ✅ DB 설정 파일 확인
    findstr "db.url" "%DB_PROPS%" 2>nul
)

echo.
REM 네트워크 체크
echo [5/5] 데이터베이스 서버 연결 확인...
ping -n 1 -w 1000 192.168.0.56 >nul 2>&1
if errorlevel 1 (
    echo ⚠️  경고: 192.168.0.56에 접근할 수 없습니다.
    echo    MySQL 서버가 실행 중인지, 네트워크 연결을 확인하세요.
) else (
    echo ✅ 데이터베이스 서버 응답 확인
)

echo.
echo ========================================
if %ALL_OK%==1 (
    echo   ✅ 모든 체크 통과!
    echo ========================================
    echo.
    echo 🚀 실행 준비가 완료되었습니다!
    echo.
    echo 다음 명령으로 서버를 시작하세요:
    echo    start.bat
    echo.
    echo 또는 전체 재배포:
    echo    redeploy.bat
) else (
    echo   ❌ 일부 체크 실패
    echo ========================================
    echo.
    echo 위의 오류를 해결한 후 다시 시도하세요.
)
echo.
pause
