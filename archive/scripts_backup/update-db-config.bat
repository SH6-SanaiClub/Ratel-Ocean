@echo off
chcp 65001 > nul
echo ========================================
echo   db.properties를 localhost로 변경
echo ========================================
echo.

set DB_PROPS=src\main\resources\db.properties
set DB_PROPS_TARGET=target\classes\db.properties

if not exist "%DB_PROPS%" (
    echo ❌ db.properties 파일을 찾을 수 없습니다: %DB_PROPS%
    pause
    exit /b 1
)

echo [1/2] 백업 생성...
copy "%DB_PROPS%" "%DB_PROPS%.backup.%date:~0,4%%date:~5,2%%date:~8,2%" >nul
echo ✅ 백업 완료: %DB_PROPS%.backup.*

echo.
echo [2/2] localhost로 변경...
powershell -Command "(Get-Content '%DB_PROPS%') -replace '192\.168\.0\.56', 'localhost' | Set-Content '%DB_PROPS%'"

if exist "%DB_PROPS_TARGET%" (
    powershell -Command "(Get-Content '%DB_PROPS_TARGET%') -replace '192\.168\.0\.56', 'localhost' | Set-Content '%DB_PROPS_TARGET%'"
    echo ✅ target 폴더도 업데이트됨
)

echo ✅ db.properties 업데이트 완료
echo.
echo 변경 내용:
echo   db.url=jdbc:mysql://localhost:3306/sanai...
echo.
echo 확인:
type "%DB_PROPS%" | findstr "db.url"
echo.
echo ========================================
echo   완료!
echo ========================================
pause
