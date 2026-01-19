# ================================
# RatelOcean Tomcat Start Script
# ================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RatelOcean Tomcat server start" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 변수 설정
$TOMCAT_HOME = "C:\program\apache-tomcat-9.0.112"
$CATALINA_BAT = "$TOMCAT_HOME\bin\catalina.bat"
$PORT = 9999

# 1. Tomcat 확인
Write-Host "[1/3] Checking Tomcat installation..." -ForegroundColor Yellow
if (-Not (Test-Path $CATALINA_BAT)) {
    Write-Host "ERROR: Tomcat not found: $TOMCAT_HOME" -ForegroundColor Red
    exit 1
}
Write-Host "OK: Tomcat found: $TOMCAT_HOME" -ForegroundColor Green

# 2. 포트 사용 중 확인
Write-Host "`n[2/3] Checking port $PORT..." -ForegroundColor Yellow
$portInUse = netstat -ano | Select-String ":$PORT " | Select-String "LISTENING"
if ($portInUse) {
    Write-Host "WARNING: Port $PORT is in use. Stopping process..." -ForegroundColor Yellow
    $procId = ($portInUse -split '\s+')[-1]
    Write-Host "Stopping process (PID: $procId)..." -ForegroundColor Gray
    Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Write-Host "OK: Process stopped" -ForegroundColor Green
} else {
    Write-Host "OK: Port $PORT is available" -ForegroundColor Green
}

# 3. Tomcat 시작
Write-Host "`n[3/3] Starting Tomcat server..." -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Tomcat started (Ctrl+C to stop)" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "URL:" -ForegroundColor Yellow
Write-Host "   http://localhost:$PORT/ratelocean" -ForegroundColor White
Write-Host ""
Write-Host "Pages:" -ForegroundColor Yellow
Write-Host "   - Main: http://localhost:$PORT/ratelocean/" -ForegroundColor White
Write-Host "   - Login: http://localhost:$PORT/ratelocean/login.jsp" -ForegroundColor White
Write-Host "   - Queue: http://localhost:$PORT/ratelocean/queue" -ForegroundColor White
Write-Host ""
Write-Host "Starting server... (about 10-20 seconds)" -ForegroundColor Gray
Write-Host "----------------------------------------" -ForegroundColor Cyan
Write-Host ""

# Tomcat 시작 (콘솔 모드)
Set-Location $TOMCAT_HOME\bin
& cmd /c "catalina.bat run"
