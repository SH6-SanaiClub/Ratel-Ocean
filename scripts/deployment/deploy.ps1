# ================================
# RatelOcean 프로젝트 배포 스크립트
# ================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RatelOcean 프로젝트 배포 시작" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 변수 설정
$TOMCAT_HOME = "C:\program\apache-tomcat-9.0.112"
$PROJECT_DIR = (Resolve-Path "$PSScriptRoot\..\..").Path
$WAR_FILE = "$PROJECT_DIR\target\ratelocean.war"
$WEBAPPS_DIR = "$TOMCAT_HOME\webapps"
$APP_NAME = "ratelocean"

# 1. WAR 파일 확인
Write-Host "[1/4] WAR 파일 확인..." -ForegroundColor Yellow
if (-Not (Test-Path $WAR_FILE)) {
    Write-Host "❌ 오류: WAR 파일을 찾을 수 없습니다: $WAR_FILE" -ForegroundColor Red
    Write-Host "Maven 빌드를 먼저 실행하세요: mvn clean package" -ForegroundColor Red
    exit 1
}
Write-Host "✅ WAR 파일 존재 확인: $WAR_FILE" -ForegroundColor Green

# 2. 기존 배포 정리
Write-Host "`n[2/4] 기존 배포 정리..." -ForegroundColor Yellow
if (Test-Path "$WEBAPPS_DIR\$APP_NAME") {
    Write-Host "   기존 폴더 삭제: $WEBAPPS_DIR\$APP_NAME" -ForegroundColor Gray
    Remove-Item -Path "$WEBAPPS_DIR\$APP_NAME" -Recurse -Force -ErrorAction SilentlyContinue
}
if (Test-Path "$WEBAPPS_DIR\$APP_NAME.war") {
    Write-Host "   기존 WAR 삭제: $WEBAPPS_DIR\$APP_NAME.war" -ForegroundColor Gray
    Remove-Item -Path "$WEBAPPS_DIR\$APP_NAME.war" -Force -ErrorAction SilentlyContinue
}
Write-Host "✅ 기존 배포 정리 완료" -ForegroundColor Green

# 3. WAR 파일 복사
Write-Host "`n[3/4] WAR 파일 배포..." -ForegroundColor Yellow
Copy-Item -Path $WAR_FILE -Destination "$WEBAPPS_DIR\$APP_NAME.war" -Force
Write-Host "✅ WAR 파일 복사 완료: $WEBAPPS_DIR\$APP_NAME.war" -ForegroundColor Green

# 4. 완료 메시지
Write-Host "`n[4/4] 배포 완료!" -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  배포가 성공적으로 완료되었습니다!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 다음 단계:" -ForegroundColor Yellow
Write-Host "   1. Tomcat 시작: .\start.ps1" -ForegroundColor White
Write-Host "   2. 브라우저에서 접속: http://localhost:9999/ratelocean" -ForegroundColor White
Write-Host ""
