# ================================
# RatelOcean Tomcat 중지 스크립트
# ================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RatelOcean Tomcat 서버 중지" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$PORT = 9999

# 포트로 프로세스 찾기
Write-Host "포트 $PORT 에서 실행 중인 프로세스 확인..." -ForegroundColor Yellow
$portInUse = netstat -ano | Select-String ":$PORT " | Select-String "LISTENING"

if ($portInUse) {
    $pid = ($portInUse -split '\s+')[-1]
    Write-Host "발견된 프로세스 PID: $pid" -ForegroundColor Gray
    Write-Host "프로세스 종료 중..." -ForegroundColor Yellow
    Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Write-Host "✅ Tomcat 서버가 중지되었습니다." -ForegroundColor Green
} else {
    Write-Host "⚠️  포트 $PORT 에서 실행 중인 프로세스를 찾을 수 없습니다." -ForegroundColor Yellow
    Write-Host "   Tomcat이 이미 중지되었거나 다른 포트를 사용 중입니다." -ForegroundColor Gray
}

Write-Host ""
