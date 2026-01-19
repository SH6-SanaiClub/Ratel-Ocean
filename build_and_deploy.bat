@echo off
setlocal enabledelayedexpansion

chcp 65001 > nul

echo.
echo ===== 재빌드 및 배포 시작 =====
echo.

rem 1. Maven 빌드
echo [1/6] Maven 빌드 중...
cd /d c:\Users\fzaca\Desktop\Latelocean
call c:\dev\apache-maven-3.9.12\bin\mvn.cmd clean package -DskipTests

if %errorlevel% neq 0 (
    echo ERROR: Maven 빌드 실패!
    pause
    exit /b 1
)
echo [완료] Maven 빌드 성공
echo.

rem 2. Java 프로세스 종료
echo [2/6] Java 프로세스 종료 중...
taskkill /F /IM java.exe >nul 2>&1
timeout /t 2 /nobreak > nul
echo [완료] Java 프로세스 종료
echo.

rem 3. Tomcat 디렉토리 정리
echo [3/6] Tomcat 작업 디렉토리 정리 중...
rmdir /s /q "C:\program\apache-tomcat-9.0.112\webapps\ratelocean" >nul 2>&1
del /q "C:\program\apache-tomcat-9.0.112\webapps\ratelocean.war" >nul 2>&1
rmdir /s /q "C:\program\apache-tomcat-9.0.112\work" >nul 2>&1
rmdir /s /q "C:\program\apache-tomcat-9.0.112\temp" >nul 2>&1
echo [완료] Tomcat 정리 완료
echo.

rem 4. WAR 파일 복사
echo [4/6] WAR 파일 복사 중...
if exist "c:\Users\fzaca\Desktop\Latelocean\target\ratelocean.war" (
    copy /Y "c:\Users\fzaca\Desktop\Latelocean\target\ratelocean.war" "C:\program\apache-tomcat-9.0.112\webapps\"
    echo [완료] WAR 파일 복사 완료
) else (
    echo ERROR: WAR 파일을 찾을 수 없습니다!
    pause
    exit /b 1
)
echo.

rem 5. Tomcat 시작
echo [5/6] Tomcat 시작 중...
cd /d "C:\program\apache-tomcat-9.0.112\bin"
start "" startup.bat
timeout /t 3 /nobreak > nul
echo [완료] Tomcat 시작
echo.

rem 6. 서버 상태 확인
echo [6/6] 서버 상태 확인 중...
timeout /t 3 /nobreak > nul

tasklist | find "java.exe" >nul
if %errorlevel% equ 0 (
    echo.
    echo ===== 재빌드 및 배포 완료 =====
    echo.
    echo 서버는 http://localhost:9999/ratelocean 에서 실행 중입니다.
    echo.
) else (
    echo.
    echo ERROR: Java 프로세스가 시작되지 않았습니다!
    echo.
)

pause
