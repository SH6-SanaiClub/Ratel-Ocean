# 프리랜서 회원가입 테스트 가이드

## 구현 완료 사항

### 1. 백엔드 구현
- ✅ **UserMapper.java**: 회원 관련 DB 쿼리 인터페이스
  - `insertUser()`: 신규 회원 등록
  - `countByEmail()`: 이메일 중복 확인
  - `countByLoginId()`: 로그인 ID 중복 확인

- ✅ **UserMapper.xml**: MyBatis SQL 매핑
  - INSERT, SELECT 쿼리 구현

- ✅ **UserService.java**: 회원가입 비즈니스 로직
  - 중복 검증
  - 회원 등록 처리
  - 생년월일 파싱

- ✅ **UserController.java**: 회원가입 요청 처리
  - `GET /join/select-role.do`: 역할 선택 페이지
  - `POST /join/select-role.do`: 역할 저장
  - `GET /join/signup.do`: 회원정보 입력 페이지
  - `POST /join/signup.do`: 회원가입 처리
  - `GET /join/check-email`: 이메일 중복 확인 API
  - `GET /join/check-loginid`: 로그인 ID 중복 확인 API

### 2. 프론트엔드 구현
- ✅ **selectRole.jsp**: 역할 선택 페이지 (프리랜서/클라이언트)
- ✅ **signup.jsp**: 회원정보 입력 페이지
- ✅ **signup.js**: 유효성 검증 및 AJAX 처리
- ✅ **select-role.css**: 역할 선택 페이지 스타일
- ✅ **signup-mockup.css**: 회원가입 페이지 스타일

## 테스트 시나리오

### 시나리오 1: 프리랜서 회원가입 (정상 케이스)

1. **역할 선택**
   ```
   URL: http://localhost:8080/join/select-role.do
   동작: 프리랜서 버튼 클릭
   ```

2. **회원정보 입력**
   ```
   URL: http://localhost:8080/join/signup.do (자동 리다이렉트)
   
   입력 데이터:
   - 로그인 ID: freelancer001
   - 이메일: freelancer@test.com
   - 비밀번호: password123
   - 비밀번호 확인: password123
   - 이름: 홍길동
   - 전화번호: 010-1234-5678
   - 생년월일: 1990.01.01
   ```

3. **중복 확인**
   - 로그인 ID "중복확인" 버튼 클릭 → "✓ 사용 가능한 ID입니다." 확인
   - 이메일 "중복확인" 버튼 클릭 → "✓ 사용 가능한 이메일입니다." 확인

4. **전화번호 인증 (Mock)**
   - "인증번호 전송" 버튼 클릭
   - 인증번호 입력: `123456`
   - "확인" 버튼 클릭 → "✓ 인증이 완료되었습니다." 확인

5. **회원가입 완료**
   - "다음으로" 버튼 클릭
   - 자동 로그인 처리
   - 프리랜서 대시보드로 리다이렉트: `/freelancer/dashboard`

### 시나리오 2: 이메일 중복 (실패 케이스)

1. 위와 동일하게 진행하되, 이미 등록된 이메일 사용
2. "중복확인" 버튼 클릭 시 → "이미 사용 중인 이메일입니다." 메시지 표시
3. 다른 이메일로 변경 후 진행

### 시나리오 3: 로그인 ID 중복 (실패 케이스)

1. 위와 동일하게 진행하되, 이미 등록된 로그인 ID 사용
2. "중복확인" 버튼 클릭 시 → "이미 사용 중인 ID입니다." 메시지 표시
3. 다른 ID로 변경 후 진행

## 데이터베이스 확인

회원가입 성공 후 DB를 확인하여 데이터가 올바르게 저장되었는지 확인:

```sql
-- 회원 정보 확인
SELECT * FROM users WHERE email = 'freelancer@test.com';

-- 결과 예시:
-- user_id: 1
-- login_id: freelancer001
-- email: freelancer@test.com
-- password: password123 (실제로는 암호화 필요)
-- user_type: FREELANCER
-- name: 홍길동
-- phone: 010-1234-5678
-- birth_date: 1990-01-01
-- status: ACTIVE
-- created_at: 2026-01-17 XX:XX:XX
-- updated_at: 2026-01-17 XX:XX:XX
```

## 프로젝트 빌드 및 실행

### 1. 프로젝트 빌드
```bash
cd c:\Users\김재환\Desktop\Latelocean\Latelocean
mvn clean package
```

### 2. Tomcat 서버 시작
```bash
# scripts/deployment/start.bat 실행
# 또는
mvn tomcat7:run
```

### 3. 브라우저에서 테스트
```
http://localhost:8080/join/select-role.do
```

## 주의사항

1. **데이터베이스 연결 확인**
   - `src/main/resources/db.properties` 파일의 DB 접속 정보 확인

2. **비밀번호 암호화**
   - 현재는 평문으로 저장됨 (테스트용)
   - 실제 운영 시 BCrypt 등으로 암호화 필요

3. **전화번호 인증**
   - 현재는 Mock 구현 (123456 고정)
   - 실제 운영 시 SMS API 연동 필요

4. **세션 관리**
   - 회원가입 성공 시 자동 로그인 처리됨
   - 세션에 사용자 정보 저장: `loginUser`, `userId`, `userType`, `userName`

## 다음 단계 (향후 개선)

1. **비밀번호 암호화**: BCrypt 적용
2. **전화번호 인증**: 실제 SMS API 연동
3. **이메일 인증**: 이메일 발송 및 인증 링크
4. **프로필 이미지**: 파일 업로드 기능
5. **유효성 검증 강화**: 
   - 비밀번호 복잡도 체크
   - 전화번호 형식 검증
   - 생년월일 유효성 검증
6. **에러 처리**: 사용자 친화적 에러 메시지
7. **클라이언트 회원가입**: 추가 필드 구현

## 문제 해결

### 빌드 오류
```bash
mvn clean install -U
```

### 페이지가 로드되지 않음
- Tomcat 서버 실행 확인
- 포트 충돌 확인 (8080)
- 로그 확인: `logs/` 디렉토리

### DB 연결 오류
- MySQL 서버 실행 확인
- db.properties 접속 정보 확인
- 방화벽/포트 확인

### CSS/JS 로드 안됨
- 파일 경로 확인
- 브라우저 캐시 삭제 (Ctrl+Shift+R)

---

**테스트 완료!** 이제 개발 환경에서 프리랜서 회원가입 기능을 테스트할 수 있습니다. 🎉
