# ================================
# RatelOcean Redeploy Script
# (Stop - Deploy - Start)
# ================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RatelOcean Full Redeploy" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Stop server
Write-Host "[1/3] Stopping Tomcat server..." -ForegroundColor Yellow
$stopPath = Join-Path $PSScriptRoot 'stop.ps1'
& $stopPath

# 2. Deploy WAR
Write-Host "`n[2/3] Deploying WAR file..." -ForegroundColor Yellow
$deployPath = Join-Path $PSScriptRoot 'deploy.ps1'
& $deployPath

# 3. Start server
Write-Host "`n[3/3] Starting Tomcat server..." -ForegroundColor Yellow
Write-Host ""
$startPath = Join-Path $PSScriptRoot 'start.ps1'
& $startPath
