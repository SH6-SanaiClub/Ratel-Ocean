@echo off
chcp 65001 > nul
echo ========================================
echo   MySQL Workbench로 데이터베이스 설정
echo ========================================
echo.
echo MySQL Workbench를 사용하여 데이터베이스를 설정합니다.
echo.

echo [1/4] MySQL Workbench 실행...
echo.
echo Workbench를 실행합니다...
start "" "C:\Program Files\MySQL\MySQL Workbench 8.0 CE\MySQLWorkbench.exe" 2>nul
if errorlevel 1 (
    echo ⚠️  Workbench를 자동으로 열 수 없습니다.
    echo    수동으로 MySQL Workbench를 실행하세요.
)
timeout /t 3 /nobreak >nul
echo.

echo [2/4] 연결 및 데이터베이스 생성 가이드
echo ========================================
echo.
echo MySQL Workbench에서:
echo.
echo 1️⃣ Local instance 연결:
echo    - "Local instance MySQL80" 또는 "localhost" 클릭
echo    - Root 비밀번호 입력 (설치 시 설정한 비밀번호)
echo.
echo 2️⃣ 스크립트 실행:
echo    - File → Open SQL Script... (Ctrl+O)
echo    - 이 파일 선택: 
echo      %~dp0setup-database.sql
echo    - Execute (번개 아이콘 클릭 또는 Ctrl+Shift+Enter)
echo.
echo 3️⃣ 덤프 파일 복원:
echo    - File → Open SQL Script... (Ctrl+O)
echo    - 이 파일 선택:
echo      C:\program\sanaidump.sql
echo    - Execute (번개 아이콘 클릭 또는 Ctrl+Shift+Enter)
echo.
echo 4️⃣ 확인:
echo    - 좌측 Schemas에서 "sanai" 데이터베이스 확인
echo    - sanai 확장 → Tables 확인
echo.
echo ========================================
echo.

pause

echo.
echo [3/4] 연결 테스트
echo ========================================
echo.
echo MySQL Workbench에서 다음 쿼리를 실행하여 확인:
echo.
echo   USE sanai;
echo   SHOW TABLES;
echo   SELECT COUNT(*) FROM users;  -- 사용자 테이블이 있다면
echo.
echo 테이블이 보이면 성공!
echo.

set /p DONE="데이터베이스 설정이 완료되었습니까? (y/N): "
if /i not "%DONE%"=="y" (
    echo.
    echo 설정을 완료한 후 다시 실행하세요.
    pause
    exit /b 1
)

echo.
echo [4/4] 프로젝트 설정 변경
echo ========================================
echo.
echo localhost로 변경합니다...
call update-db-config.bat

echo.
echo ========================================
echo   완료!
echo ========================================
echo.
echo 다음 단계:
echo   start.bat 실행
echo.
pause
