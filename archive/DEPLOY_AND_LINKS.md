# 🚀 Tomcat 배포 및 실행 가능한 링크 목록

## 📦 빌드 완료

WAR 파일 위치:
```
C:\Users\fzaca\Desktop\Latelocean\target\ratelocean.war
```

---

## 🔧 Tomcat 배포 방법

### 1단계: Tomcat 경로 찾기
```powershell
# 일반적인 Tomcat 경로들
C:\apache-tomcat-9.0.112
C:\Program Files\Apache Tomcat 9.0.112
C:\tomcat
```

또는 환경 변수 확인:
```powershell
$env:CATALINA_HOME
```

### 2단계: 기존 Tomcat 종료
```powershell
# 방법 1: 프로세스 종료
Stop-Process -Name "java" -Force -ErrorAction SilentlyContinue

# 방법 2: Tomcat shutdown 스크립트
& "<TOMCAT_HOME>\bin\shutdown.bat"

# 방법 3: 서비스 종료 (서비스로 설치된 경우)
Stop-Service -Name "Tomcat9"
```

### 3단계: WAR 파일 배포
```powershell
# WAR 파일을 Tomcat webapps 폴더에 복사
Copy-Item "C:\Users\fzaca\Desktop\Latelocean\target\ratelocean.war" "<TOMCAT_HOME>\webapps\" -Force
```

### 4단계: Tomcat 시작
```powershell
# 방법 1: startup 스크립트
& "<TOMCAT_HOME>\bin\startup.bat"

# 방법 2: catalina 스크립트
& "<TOMCAT_HOME>\bin\catalina.bat" run

# 방법 3: 서비스 시작 (서비스로 설치된 경우)
Start-Service -Name "Tomcat9"
```

### 5단계: 배포 확인
```powershell
# 10초 대기 (자동 배포 시간)
Start-Sleep -Seconds 10

# 웹 브라우저 열기
Start-Process "http://localhost:9999/ratelocean"
```

---

## 🌐 실행 가능한 링크 목록

### 🏠 홈 & 인증

```
http://localhost:9999/ratelocean/
http://localhost:9999/ratelocean/home
http://localhost:9999/ratelocean/login
http://localhost:9999/ratelocean/signup
```

---

### 📊 대시보드

#### 프리랜서 대시보드
```
http://localhost:9999/ratelocean/dashboard
```

#### 클라이언트 대시보드
```
http://localhost:9999/ratelocean/client-dashboard
```

---

### 💼 프로젝트 & 계약

#### 프로젝트 관리
```
http://localhost:9999/ratelocean/project/dashboard
```

#### 계약서 작성 (1단계)
```
http://localhost:9999/ratelocean/contract/first
```

#### 계약서 AI 검토 (2단계)
```
http://localhost:9999/ratelocean/contract/second
```

---

### 🌟 계약 리뷰 작성 (새로 추가!)

#### 클라이언트 → 프리랜서 리뷰
```
http://localhost:9999/ratelocean/review/client?contractId=1
http://localhost:9999/ratelocean/review/client?contractId=2
http://localhost:9999/ratelocean/review/client?contractId=3
```

#### 프리랜서 → 클라이언트 리뷰
```
http://localhost:9999/ratelocean/review/freelancer?contractId=1
http://localhost:9999/ratelocean/review/freelancer?contractId=2
http://localhost:9999/ratelocean/review/freelancer?contractId=3
```

---

### 🎯 기회큐 & 경력

```
http://localhost:9999/ratelocean/opportunity-queue/freelancer
http://localhost:9999/ratelocean/freelancer/career
```

---

### 💰 금융

```
http://localhost:9999/ratelocean/payment/method/add
http://localhost:9999/ratelocean/payment/history
```

---

### 🔗 REST API

#### 기술 스택 API
```
http://localhost:9999/ratelocean/api/stacks/positions
http://localhost:9999/ratelocean/api/stacks/skills
http://localhost:9999/ratelocean/api/stacks/all
```

**API 응답 예시:**
```json
// GET /api/stacks/positions
[
  {"stack_id": 1, "stack_name": "백엔드 개발", "stack_type": "POSITION"},
  {"stack_id": 2, "stack_name": "프론트엔드 개발", "stack_type": "POSITION"}
]

// GET /api/stacks/skills
[
  {"stack_id": 9, "stack_name": "Java", "stack_type": "SKILL"},
  {"stack_id": 10, "stack_name": "Spring", "stack_type": "SKILL"}
]
```

---

## 📝 테스트 데이터 삽입

### MySQL 접속 정보
```
Host: 192.168.0.56
Port: 3306
Database: sanai
Username: root
```

### 테스트 데이터 삽입 (선택)
```bash
mysql -h 192.168.0.56 -u root -p sanai < test_data.sql
```

또는 PowerShell에서:
```powershell
# MySQL 클라이언트 경로 (환경에 따라 다름)
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -h 192.168.0.56 -u root -p sanai -e "source C:\Users\fzaca\Desktop\Latelocean\test_data.sql"
```

---

## 🧪 리뷰 시스템 테스트 시나리오

### 시나리오 1: 새 리뷰 작성
```
1. 접속: http://localhost:9999/ratelocean/review/client?contractId=1
2. 별점: 8.5점 선택
3. 재계약 의사: "재계약 원함" 선택
4. 리뷰 작성: "훌륭한 프리랜서였습니다."
5. 제출 → 성공 메시지
```

### 시나리오 2: 중복 작성 방지
```
1. 접속: http://localhost:9999/ratelocean/review/client?contractId=3
2. "이미 리뷰를 작성하셨습니다" 메시지 확인
```

### 시나리오 3: 프리랜서 리뷰
```
1. 접속: http://localhost:9999/ratelocean/review/freelancer?contractId=2
2. 별점: 9.0점 선택
3. 리뷰 작성: "좋은 클라이언트였습니다."
4. 제출 → 성공 메시지
```

---

## 🛠️ 문제 해결

### Tomcat이 실행되지 않는 경우

#### 1. 포트 충돌 확인
```powershell
netstat -ano | Select-String ":9999"
```

#### 2. 포트 사용 중인 프로세스 종료
```powershell
$processId = (netstat -ano | Select-String ":9999" | Select-Object -First 1).ToString().Split()[-1]
Stop-Process -Id $processId -Force
```

#### 3. Tomcat 로그 확인
```
<TOMCAT_HOME>\logs\catalina.out
<TOMCAT_HOME>\logs\catalina.2026-01-15.log
```

#### 4. WAR 배포 확인
```powershell
# webapps 폴더에 ratelocean 폴더가 생성되었는지 확인
Test-Path "<TOMCAT_HOME>\webapps\ratelocean"
```

---

## 📱 브라우저에서 테스트

### Chrome DevTools로 API 테스트
```javascript
// F12 → Console

// 1. 기술 스택 조회
fetch('http://localhost:9999/ratelocean/api/stacks/all')
  .then(res => res.json())
  .then(data => console.table(data));

// 2. 프로젝트 대시보드 접속
location.href = 'http://localhost:9999/ratelocean/dashboard';

// 3. 리뷰 작성 페이지
location.href = 'http://localhost:9999/ratelocean/review/client?contractId=1';
```

---

## 🎨 주요 페이지 미리보기

### 클라이언트 리뷰 페이지
- 브랜드 컬러: #1F7A8C (틸 블루)
- 별점 슬라이더: 0.0 ~ 10.0 (0.5 단위)
- 재계약 의사: YES/NO 라디오 버튼
- 공개 리뷰: 최대 500자

### 프리랜서 리뷰 페이지
- 클라이언트 페이지와 동일
- **재계약 의사 항목 없음**

---

## 📞 빠른 실행 명령어 모음

```powershell
# 1. 전체 프로세스 (Tomcat 경로를 찾은 경우)
$TOMCAT_HOME = "C:\apache-tomcat-9.0.112"  # 실제 경로로 변경

# Tomcat 종료
Stop-Process -Name "java" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# WAR 배포
Copy-Item "C:\Users\fzaca\Desktop\Latelocean\target\ratelocean.war" "$TOMCAT_HOME\webapps\" -Force

# Tomcat 시작
& "$TOMCAT_HOME\bin\startup.bat"

# 브라우저 열기
Start-Sleep -Seconds 10
Start-Process "http://localhost:9999/ratelocean/review/client?contractId=1"
```

---

## ✅ 체크리스트

- [ ] Tomcat 설치 경로 확인
- [ ] 기존 Tomcat 프로세스 종료
- [ ] WAR 파일 webapps 폴더에 복사
- [ ] Tomcat 시작
- [ ] http://localhost:9999/ratelocean 접속 확인
- [ ] 테스트 데이터 삽입 (선택)
- [ ] 리뷰 작성 페이지 테스트

---

**배포 일시**: 2026-01-15  
**빌드 파일**: ratelocean.war  
**포트**: 9999  
**컨텍스트**: /ratelocean
