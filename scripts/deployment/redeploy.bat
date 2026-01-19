@echo off
chcp 65001 > nul
echo ========================================
echo   RatelOcean 전체 재배포
echo ========================================
echo.

echo [1/3] Tomcat 서버 중지...
call stop.bat

echo.
echo [2/3] WAR 파일 재배포...
call deploy.bat

echo.
echo [3/3] Tomcat 서버 시작...
call start.bat
