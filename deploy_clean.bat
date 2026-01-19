@echo off
setlocal enabledelayedexpansion

chcp 65001 > nul

echo ===== Ratelocean 배포 스크립트 =====
echo.

rem 1. Java 프로세스 종료
echo [1/5] Java 프로세스 종료 중...
taskkill /F /IM java.exe >nul 2>&1
timeout /t 2 /nobreak > nul

rem 2. Tomcat 디렉토리 정리
echo [2/5] Tomcat 작업 디렉토리 정리 중...
rmdir /s /q "C:\program\apache-tomcat-9.0.112\webapps\ratelocean" >nul 2>&1
del /q "C:\program\apache-tomcat-9.0.112\webapps\ratelocean.war" >nul 2>&1
rmdir /s /q "C:\program\apache-tomcat-9.0.112\work" >nul 2>&1
rmdir /s /q "C:\program\apache-tomcat-9.0.112\temp" >nul 2>&1

rem 3. WAR 파일 복사
echo [3/5] WAR 파일 복사 중...
if exist "c:\Users\fzaca\Desktop\Latelocean\target\ratelocean.war" (
    copy /Y "c:\Users\fzaca\Desktop\Latelocean\target\ratelocean.war" "C:\program\apache-tomcat-9.0.112\webapps\"
    echo     WAR 파일 복사 완료
) else (
    echo     ERROR: WAR 파일을 찾을 수 없습니다!
    exit /b 1
)

rem 4. Tomcat 시작
echo [4/5] Tomcat 시작 중...
cd /d "C:\program\apache-tomcat-9.0.112\bin"
start "" startup.bat
timeout /t 3 /nobreak > nul

rem 5. 서버 상태 확인
echo [5/5] 서버 상태 확인 중...
timeout /t 3 /nobreak > nul

tasklist | find "java.exe" >nul
if %errorlevel% equ 0 (
    echo.
    echo ===== 배포 완료 =====
    echo 서버는 http://localhost:9999/ratelocean 에서 실행 중입니다.
) else (
    echo.
    echo ERROR: Java 프로세스가 시작되지 않았습니다!
)

pause
