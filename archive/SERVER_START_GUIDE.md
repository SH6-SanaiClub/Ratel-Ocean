# 🚀 Tomcat 서버 시작 가이드

## 현재 상황
- ✅ 프로젝트 빌드 완료 (`target/ratelocean` 생성됨)
- ✅ Eclipse Tomcat webapps에 배포 완료
- ⏳ Tomcat 서버 시작 필요

## Eclipse STS에서 Tomcat 시작하는 방법

### 방법 1: Servers 탭에서 시작
1. **Eclipse 하단의 "Servers" 탭** 클릭
2. **"Tomcat v9.0 Server"** 또는 유사한 서버 이름 우클릭
3. **"Start"** 클릭
4. 콘솔에서 "Server started on port 9999" 확인

### 방법 2: Run 메뉴에서 시작
1. **메뉴: Run → Run on Server**
2. Tomcat 서버 선택
3. **"Always use this server"** 체크
4. **"Finish"** 클릭

### 방법 3: 키보드 단축키
1. **"Ctrl + Alt + X"** 또는 **"Alt + Shift + X"** → **"S"**
2. 서버 시작

---

## 시작 후 확인
```
URL: http://localhost:9999/ratelocean/queue
```

### 테스트 체크리스트
- [ ] 페이지 로드됨
- [ ] 좌측에 "🤖 자동 추천 큐" 보임
- [ ] 우측에 "🎯 조건 큐" 보임
- [ ] "새로운 조건 큐 생성" 카드 보임
- [ ] **"새로운 조건 큐 생성" 클릭 → 폼이 아래에서 슬라이드 인**
- [ ] 취소 버튼 → 폼이 사라짐
- [ ] 필수 필드 입력 안 하고 제출 → 경고창

---

## 주의사항
- 포트 9999가 이미 사용 중이면 에러 발생 (다른 애플리케이션 종료 필요)
- 처음 시작 시 배포에 시간이 걸릴 수 있음 (10-30초)
- 콘솔에 에러가 없어야 정상

---

## 문제 발생 시
### 콘솔에 "Port 9999 already in use" 에러
```powershell
netstat -ano | findstr "9999"
# PID 찾은 후
taskkill /PID <PID> /F
```

### 페이지가 로드되지 않음
1. 브라우저 **F12 → Console** 열기
2. JavaScript 에러 확인
3. 브라우저 **Ctrl + Shift + R** (하드 새로고침)

### 여전히 이전 버전이 보임
1. Eclipse: **Project → Clean**
2. Servers 탭: 우클릭 → **Clean**
3. 서버 재시작
