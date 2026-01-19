@echo off
chcp 65001 > nul
echo ===== 배포 상태 확인 =====
echo.
echo [1/4] Java 프로세스 확인
tasklist | find "java.exe"
echo.

echo [2/4] webapps 디렉토리 확인
dir "C:\program\apache-tomcat-9.0.112\webapps" | find "ratelocean"
echo.

echo [3/4] 서버 포트 확인
netstat -ano | find ":9999"
echo.

echo [4/4] Tomcat 로그 확인 (최근 10줄)
if exist "C:\program\apache-tomcat-9.0.112\logs\catalina.out" (
  type "C:\program\apache-tomcat-9.0.112\logs\catalina.out" | find /V ""
) else (
  echo catalina.out 파일 없음
)
