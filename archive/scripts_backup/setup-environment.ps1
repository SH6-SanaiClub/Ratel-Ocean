# ================================
# RatelOcean 완전한 로컬 개발 환경 설치
# ================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RatelOcean 로컬 개발 환경 구축" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 관리자 권한 확인
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "⚠️  경고: 관리자 권한으로 실행하는 것을 권장합니다." -ForegroundColor Yellow
    Write-Host "   일부 설치가 실패할 수 있습니다." -ForegroundColor Gray
    Write-Host ""
}

# 변수 설정
$DUMP_FILE = "C:\program\sanaidump.sql"
$PROJECT_DIR = "C:\Users\김재환\Desktop\Latelocean\Latelocean"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  1단계: 필수 소프트웨어 확인" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# MySQL 확인
Write-Host "[1/3] MySQL 확인..." -ForegroundColor Yellow
$mysqlService = Get-Service -Name "*mysql*" -ErrorAction SilentlyContinue
$mysqlPath = where.exe mysql 2>$null

if ($mysqlService -or $mysqlPath) {
    Write-Host "✅ MySQL 이미 설치됨" -ForegroundColor Green
    if ($mysqlService) {
        Write-Host "   서비스 이름: $($mysqlService.Name)" -ForegroundColor Gray
        Write-Host "   상태: $($mysqlService.Status)" -ForegroundColor Gray
    }
} else {
    Write-Host "❌ MySQL이 설치되지 않았습니다." -ForegroundColor Red
    Write-Host ""
    Write-Host "📥 MySQL 8.0 설치 방법:" -ForegroundColor Yellow
    Write-Host "   1. https://dev.mysql.com/downloads/mysql/ 방문" -ForegroundColor White
    Write-Host "   2. 'MySQL Community Server 8.0' 다운로드" -ForegroundColor White
    Write-Host "   3. Windows Installer (mysql-installer-community-8.0.x.msi) 실행" -ForegroundColor White
    Write-Host "   4. 'Developer Default' 또는 'Server only' 선택" -ForegroundColor White
    Write-Host "   5. Root 비밀번호를 '0000'으로 설정 (프로젝트 설정과 일치)" -ForegroundColor White
    Write-Host ""
    Write-Host "⚡ 빠른 설치 (Chocolatey 사용):" -ForegroundColor Yellow
    Write-Host "   choco install mysql" -ForegroundColor White
    Write-Host ""
    $response = Read-Host "MySQL 설치를 완료했습니까? (y/N)"
    if ($response -ne "y" -and $response -ne "Y") {
        Write-Host "MySQL을 먼저 설치하고 다시 실행하세요." -ForegroundColor Red
        exit 1
    }
}

# Java 확인
Write-Host "`n[2/3] Java JDK 11 확인..." -ForegroundColor Yellow
$javaVersion = java -version 2>&1 | Select-String "version"
if ($javaVersion) {
    Write-Host "✅ Java 설치됨: $javaVersion" -ForegroundColor Green
} else {
    Write-Host "⚠️  Java가 PATH에 없습니다." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📥 Java JDK 11 설치 방법:" -ForegroundColor Yellow
    Write-Host "   1. https://adoptium.net/ 방문" -ForegroundColor White
    Write-Host "   2. 'Temurin 11 (LTS)' 다운로드" -ForegroundColor White
    Write-Host "   3. 설치 시 'Set JAVA_HOME' 옵션 체크" -ForegroundColor White
    Write-Host "   4. 설치 시 'Add to PATH' 옵션 체크" -ForegroundColor White
    Write-Host ""
    Write-Host "⚡ 빠른 설치 (Chocolatey 사용):" -ForegroundColor Yellow
    Write-Host "   choco install temurin11" -ForegroundColor White
    Write-Host ""
    Write-Host "Tomcat에 Java가 포함되어 있어 실행은 가능하지만," -ForegroundColor Gray
    Write-Host "Maven 빌드를 위해 Java 11 설치를 권장합니다." -ForegroundColor Gray
}

# Maven 확인
Write-Host "`n[3/3] Maven 확인..." -ForegroundColor Yellow
$mavenVersion = mvn -version 2>&1 | Select-String "Apache Maven"
if ($mavenVersion) {
    Write-Host "✅ Maven 설치됨: $mavenVersion" -ForegroundColor Green
} else {
    Write-Host "⚠️  Maven이 설치되지 않았습니다." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📥 Maven 3.x 설치 방법:" -ForegroundColor Yellow
    Write-Host "   1. https://maven.apache.org/download.cgi 방문" -ForegroundColor White
    Write-Host "   2. Binary zip archive 다운로드" -ForegroundColor White
    Write-Host "   3. C:\Program Files\ 에 압축 해제" -ForegroundColor White
    Write-Host "   4. 환경 변수 PATH에 추가: C:\Program Files\apache-maven-3.x\bin" -ForegroundColor White
    Write-Host ""
    Write-Host "⚡ 빠른 설치 (Chocolatey 사용):" -ForegroundColor Yellow
    Write-Host "   choco install maven" -ForegroundColor White
    Write-Host ""
    Write-Host "Maven이 없어도 기존 빌드된 WAR 파일로 실행 가능합니다." -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  2단계: 데이터베이스 설정" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 덤프 파일 확인
Write-Host "[1/4] 덤프 파일 확인..." -ForegroundColor Yellow
if (Test-Path $DUMP_FILE) {
    $dumpSize = (Get-Item $DUMP_FILE).Length
    Write-Host "✅ 덤프 파일 발견: $DUMP_FILE ($dumpSize bytes)" -ForegroundColor Green
} else {
    Write-Host "❌ 덤프 파일을 찾을 수 없습니다: $DUMP_FILE" -ForegroundColor Red
    Write-Host "   덤프 파일이 해당 위치에 있는지 확인하세요." -ForegroundColor Gray
    exit 1
}

Write-Host "`n[2/4] MySQL 서비스 시작..." -ForegroundColor Yellow
$mysqlService = Get-Service -Name "*mysql*" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($mysqlService) {
    if ($mysqlService.Status -ne "Running") {
        Write-Host "   MySQL 서비스 시작 중..." -ForegroundColor Gray
        try {
            Start-Service $mysqlService.Name -ErrorAction Stop
            Write-Host "✅ MySQL 서비스 시작됨" -ForegroundColor Green
        } catch {
            Write-Host "⚠️  MySQL 서비스 시작 실패. 관리자 권한이 필요할 수 있습니다." -ForegroundColor Yellow
            Write-Host "   수동으로 시작: services.msc에서 MySQL 서비스 시작" -ForegroundColor Gray
        }
    } else {
        Write-Host "✅ MySQL 서비스 이미 실행 중" -ForegroundColor Green
    }
} else {
    Write-Host "⚠️  MySQL 서비스를 찾을 수 없습니다." -ForegroundColor Yellow
}

Write-Host "`n[3/4] 데이터베이스 및 사용자 생성..." -ForegroundColor Yellow
Write-Host ""
Write-Host "다음 MySQL 명령을 실행하세요:" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Cyan
Write-Host "mysql -u root -p" -ForegroundColor White
Write-Host ""
Write-Host "그 다음:" -ForegroundColor Gray
Write-Host "CREATE DATABASE IF NOT EXISTS sanai CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" -ForegroundColor White
Write-Host "CREATE USER IF NOT EXISTS 'remote_user'@'localhost' IDENTIFIED BY '0000';" -ForegroundColor White
Write-Host "GRANT ALL PRIVILEGES ON sanai.* TO 'remote_user'@'localhost';" -ForegroundColor White
Write-Host "FLUSH PRIVILEGES;" -ForegroundColor White
Write-Host "EXIT;" -ForegroundColor White
Write-Host "----------------------------------------" -ForegroundColor Cyan
Write-Host ""

Write-Host "`n[4/4] 덤프 파일 복원..." -ForegroundColor Yellow
Write-Host ""
Write-Host "데이터베이스를 생성한 후 다음 명령으로 덤프 복원:" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Cyan
Write-Host "mysql -u root -p sanai < $DUMP_FILE" -ForegroundColor White
Write-Host "----------------------------------------" -ForegroundColor Cyan
Write-Host ""

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  3단계: 프로젝트 설정 변경" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "db.properties 파일을 localhost로 변경해야 합니다." -ForegroundColor Yellow
Write-Host "파일 위치: $PROJECT_DIR\src\main\resources\db.properties" -ForegroundColor Gray
Write-Host ""
Write-Host "변경 내용:" -ForegroundColor Yellow
Write-Host "  원본: db.url=jdbc:mysql://192.168.0.56:3306/sanai..." -ForegroundColor Red
Write-Host "  변경: db.url=jdbc:mysql://localhost:3306/sanai..." -ForegroundColor Green
Write-Host ""

$response = Read-Host "자동으로 db.properties를 변경하시겠습니까? (Y/n)"
if ($response -ne "n" -and $response -ne "N") {
    Write-Host "db.properties 업데이트 중..." -ForegroundColor Yellow
    # 이 부분은 별도 스크립트에서 처리
    Write-Host "✅ 별도 스크립트로 업데이트하세요: .\update-db-config.ps1" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  완료!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 다음 단계:" -ForegroundColor Yellow
Write-Host "1. MySQL이 설치되지 않았다면 설치" -ForegroundColor White
Write-Host "2. MySQL에서 데이터베이스 생성 및 덤프 복원 (위의 명령 사용)" -ForegroundColor White
Write-Host "3. .\update-db-config.ps1 실행 (localhost로 변경)" -ForegroundColor White
Write-Host "4. .\start.bat 실행" -ForegroundColor White
Write-Host ""
