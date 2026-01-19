@echo off
chcp 65001 > nul
echo ========================================
echo   RatelOcean Tomcat 서버 시작
echo ========================================
echo.

set TOMCAT_HOME=C:\program\apache-tomcat-9.0.112
set CATALINA_BAT=%TOMCAT_HOME%\bin\catalina.bat
set PORT=9999

echo [1/3] Tomcat 설치 확인...
if not exist "%CATALINA_BAT%" (
    echo ❌ 오류: Tomcat을 찾을 수 없습니다
    echo    경로: %TOMCAT_HOME%
    pause
    exit /b 1
)
echo ✅ Tomcat 확인: %TOMCAT_HOME%

echo.
echo [2/3] 포트 %PORT% 확인...
netstat -ano | findstr ":%PORT% " | findstr "LISTENING" > nul
if not errorlevel 1 (
    echo ⚠️  경고: 포트 %PORT% 가 이미 사용 중입니다.
    echo.
    set /p CONFIRM="   강제로 종료하고 계속하시겠습니까? (y/N): "
    if /i not "%CONFIRM%"=="y" (
        echo ❌ 사용자가 취소했습니다.
        pause
        exit /b 1
    )
    echo    기존 프로세스 종료 중...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%PORT% " ^| findstr "LISTENING"') do (
        taskkill /PID %%a /F > nul 2>&1
    )
    timeout /t 2 /nobreak > nul
    echo ✅ 프로세스 종료 완료
) else (
    echo ✅ 포트 %PORT% 사용 가능
)

echo.
echo [3/3] Tomcat 서버 시작 중...
echo.
echo ========================================
echo   Tomcat 시작됨 (Ctrl+C로 종료)
echo ========================================
echo.
echo 🌐 접속 URL:
echo    http://localhost:%PORT%/ratelocean
echo.
echo 📋 주요 페이지:
echo    - 메인: http://localhost:%PORT%/ratelocean/
echo    - 로그인: http://localhost:%PORT%/ratelocean/login.jsp
echo    - 큐: http://localhost:%PORT%/ratelocean/queue
echo.
echo ⏳ 서버 시작 중... (약 10-20초 소요)
echo ----------------------------------------
echo.

cd /d %TOMCAT_HOME%\bin
call catalina.bat run
