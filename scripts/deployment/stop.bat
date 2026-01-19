@echo off
chcp 65001 > nul
echo ========================================
echo   RatelOcean Tomcat 서버 중지
echo ========================================
echo.

set PORT=9999

echo 포트 %PORT% 에서 실행 중인 프로세스 확인...
netstat -ano | findstr ":%PORT% " | findstr "LISTENING" > nul
if errorlevel 1 (
    echo ⚠️  포트 %PORT% 에서 실행 중인 프로세스를 찾을 수 없습니다.
    echo    Tomcat이 이미 중지되었거나 다른 포트를 사용 중입니다.
    echo.
    pause
    exit /b 0
)

echo 프로세스 종료 중...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%PORT% " ^| findstr "LISTENING"') do (
    echo    PID: %%a 종료 중...
    taskkill /PID %%a /F > nul 2>&1
)
timeout /t 2 /nobreak > nul
echo ✅ Tomcat 서버가 중지되었습니다.
echo.
pause
