@echo off
chcp 65001 > nul
echo ========================================
echo   RatelOcean 프로젝트 배포
echo ========================================
echo.

set TOMCAT_HOME=C:\program\apache-tomcat-9.0.112
set PROJECT_DIR=%~dp0
set WAR_FILE=%PROJECT_DIR%target\ratelocean.war
set WEBAPPS_DIR=%TOMCAT_HOME%\webapps
set APP_NAME=ratelocean

echo [1/4] WAR 파일 확인...
if not exist "%WAR_FILE%" (
    echo ❌ 오류: WAR 파일을 찾을 수 없습니다
    echo    경로: %WAR_FILE%
    pause
    exit /b 1
)
echo ✅ WAR 파일 존재 확인

echo.
echo [2/4] 기존 배포 정리...
if exist "%WEBAPPS_DIR%\%APP_NAME%" (
    echo    기존 폴더 삭제...
    rmdir /s /q "%WEBAPPS_DIR%\%APP_NAME%" 2>nul
)
if exist "%WEBAPPS_DIR%\%APP_NAME%.war" (
    echo    기존 WAR 삭제...
    del /q "%WEBAPPS_DIR%\%APP_NAME%.war" 2>nul
)
echo ✅ 기존 배포 정리 완료

echo.
echo [3/4] WAR 파일 배포...
copy /y "%WAR_FILE%" "%WEBAPPS_DIR%\%APP_NAME%.war" > nul
if errorlevel 1 (
    echo ❌ 오류: WAR 파일 복사 실패
    pause
    exit /b 1
)
echo ✅ WAR 파일 복사 완료

echo.
echo [4/4] 배포 완료!
echo.
echo ========================================
echo   배포가 성공적으로 완료되었습니다!
echo ========================================
echo.
echo 📋 다음 단계:
echo    1. Tomcat 시작: start.bat
echo    2. 브라우저 접속: http://localhost:9999/ratelocean
echo.
pause
