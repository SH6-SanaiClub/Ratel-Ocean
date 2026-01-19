@echo off
echo ========================================
echo   Java 11 빠른 설치
echo ========================================
echo.
echo Java가 설치되어 있지 않아 Tomcat을 실행할 수 없습니다.
echo.
echo 지금 Java 11을 다운로드하여 설치하시겠습니까?
echo.
pause

echo.
echo 다운로드 페이지를 엽니다...
start https://adoptium.net/temurin/releases/?version=11

echo.
echo ========================================
echo   설치 가이드
echo ========================================
echo.
echo 1. 브라우저에서 열린 페이지에서:
echo    - Operating System: Windows
echo    - Architecture: x64
echo    - Package Type: JDK
echo    - .msi 파일 다운로드
echo.
echo 2. 다운로드한 .msi 파일 실행
echo.
echo 3. 설치 옵션에서 반드시 체크:
echo    [v] Set JAVA_HOME variable
echo    [v] Add to PATH
echo    [v] JavaSoft (Oracle) registry keys
echo.
echo 4. 설치 완료 후 이 창으로 돌아오세요
echo.
pause

echo.
echo 설치가 완료되었습니까?
pause

echo.
echo Java 버전 확인 중...
java -version

echo.
echo 확인되면 다음 명령을 실행하세요:
echo   start.bat
echo.
pause
