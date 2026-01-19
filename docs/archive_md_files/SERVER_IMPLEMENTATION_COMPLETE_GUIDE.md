# 🎉 서버 구현 완료 - 통합 테스트 가이드

## 📋 목차
1. [구현 완료 사항](#구현-완료-사항)
2. [아키텍처 개요](#아키텍처-개요)
3. [단계별 테스트 가이드](#단계별-테스트-가이드)
4. [API 명세](#api-명세)
5. [자주 묻는 질문](#자주-묻는-질문)
6. [트러블슈팅](#트러블슈팅)

---

## 구현 완료 사항

### ✅ 완료된 구성요소

#### 1. **DTO 클래스** (Data Transfer Objects)
- **SkillInput.java** - 기술 스택 입력 데이터 매핑
  ```
  필드: stackId, stackName, stackLevel, stackYear
  목적: 클라이언트에서 전송한 기술 스택 JSON을 Java 객체로 변환
  ```

#### 2. **Mapper 계층** (Database Access)
- **FreelancerMapper.java** (Interface)
  ```
  메서드: insertFreelancerSkill(), deleteFreelancerSkills()
  ```
- **FreelancerMapper.xml** (SQL Mapping)
  ```sql
  INSERT INTO freelancer_skills (freelancer_id, stack_id, stack_level, stack_year)
  DELETE FROM freelancer_skills WHERE freelancer_id = ?
  ```

#### 3. **Service 계층** (Business Logic)
- **FreelancerService.java**
  ```java
  메서드:
  - completeProfile() : 프로필 완성 처리 + 기술 스택 저장
  - saveProfile() : 새 프로필 생성
  - getProfile() : 프로필 조회
  - isNicknameDuplicate() : 닉네임 중복 확인
  ```
  특징: @Transactional로 트랜잭션 관리

#### 4. **Controller 계층** (Request Handling)
- **FreelancerController.java**
  ```
  GET  /freelancer/complete-profile.do → 프로필 완성 페이지 표시
  POST /freelancer/complete-profile.do → 프로필 데이터 저장
  GET  /freelancer/dashboard → 대시보드 표시 (기존)
  ```

#### 5. **View 계층** (이미 완성)
- **complete-profile.jsp**
  ```
  - 폼 검증: validateForm()
  - 데이터 직렬화: handleProfileSubmit()
  - skills_json으로 기술 스택 전송
  ```

---

## 아키텍처 개요

### 전체 흐름도

```
클라이언트 (Client Side)
    ↓
[회원가입] signup.jsp
    ↓
[기본정보 입력] → UserController.processSignup()
                ↓
            UserService.registerFreelancer()
                ↓
            [users, freelancer_profiles, accounts, wallets 생성]
    ↓
    ↓ [프리랜서만 접근]
    ↓
[프로필 완성] complete-profile.jsp
    ↓
[추가정보 + 기술스택 입력] → FreelancerController.completeProfile() (POST)
                          ↓
                      FreelancerService.completeProfile()
                          ↓
                      [freelancer_profiles, freelancer_skills 업데이트]
    ↓
[대시보드] /freelancer/dashboard
```

### 데이터베이스 구조

```
users (회원 정보)
├─ user_id (PK)
├─ login_id
├─ email
├─ password
├─ name
├─ phone
├─ birth_date
├─ user_type (freelancer/client)
└─ status

freelancer_profiles (프리랜서 상세 프로필)
├─ user_id (FK to users)
├─ nickname
├─ introduction
├─ github_url
├─ website_url
├─ school_name
├─ major
├─ degree
├─ grad_status
└─ is_profile_complete

freelancer_skills (프리랜서 기술 스택) ⭐ NEW
├─ freelancer_stack_id (PK, auto-increment)
├─ freelancer_id (FK to users)
├─ stack_id (FK to stacks)
├─ stack_level (1-5)
└─ stack_year (경력년수)

stacks (기술 마스터)
├─ stack_id (PK)
├─ stack_name
└─ stack_category
```

---

## 단계별 테스트 가이드

### 📌 전제 조건
1. MySQL 서버 실행 중
2. Spring 애플리케이션 실행 중
3. 데이터베이스 `sanai` 존재
4. `freelancer_skills` 테이블 존재 ✅ (확인 필요)

### 🧪 테스트 시나리오

#### **시나리오 1: 정상 회원가입 → 프로필 완성**

##### Step 1: 회원가입 페이지 접속
```
URL: http://localhost:9999/ratelocean/join/select-role.do
액션: "프리랜서" 버튼 클릭
```

##### Step 2: 기본 정보 입력
```
URL: http://localhost:9999/ratelocean/join/signup.do
입력 데이터:
- 로그인 ID: test_freelancer_001
- 이메일: freelancer.test@example.com
- 비밀번호: TestPassword123!
- 이름: 테스트 프리랜서
- 전화: 010-1111-2222
- 생년월일: 1995.05.15
- 닉네임: (다음 단계에서 입력, 여기선 제외 가능)
- GitHub: (선택사항)
- 웹사이트: (선택사항)
- 은행: 국민은행
- 계좌번호: 12345678901234
- 예금주: 테스트프리랜서

액션: "다음으로" 버튼 클릭
```

**예상 결과:**
```
✅ 검증 통과
✅ users 테이블에 신규 사용자 삽입
✅ freelancer_profiles 테이블에 프로필 생성
✅ accounts 테이블에 계좌 정보 저장
✅ freelancer_wallets 테이블에 지갑 생성
✅ 세션 설정 (userId, userType=freelancer)
✅ /freelancer/complete-profile.do로 자동 리다이렉트
```

##### Step 3: 프로필 완성 페이지 접속
```
URL: http://localhost:9999/ratelocean/freelancer/complete-profile.do
```

**예상 결과:**
```
✅ 프로필 완성 페이지 표시
✅ 기본정보 입력 필드 표시
✅ 기술 스택 선택 모달 표시
✅ 계좌 정보 표시 (기본정보 입력 시 저장된 것)
```

##### Step 4: 기술 스택 선택
```
액션: "🔍 기술 스택 선택 (모달)" 버튼 클릭
```

**모달 화면:**
```
1. "개발 영역" 필터 (선택사항)
   - 백엔드, 프론트엔드, 데이터베이스, DevOps 등

2. 기술 검색/선택
   - "java" 검색 → Java 선택
   - "react" 검색 → React 선택
   - "mysql" 검색 → MySQL 선택

3. "적용" 버튼 클릭
```

**예상 결과:**
```
✅ 선택된 기술 태그 표시:
   ┌─────────────────┬──────────────┐
   │ Java   Lv.3 1년 │ ✕ (제거 가능) │
   │ React  Lv.3 1년 │ ✕            │
   │ MySQL  Lv.3 1년 │ ✕            │
   └─────────────────┴──────────────┘

✅ 기술 상세 조정 가능 (Lv.3 → Lv.4, 1년 → 5년)
```

##### Step 5: 추가 정보 입력
```
입력 필드:
- 닉네임: dev_freelancer_test
- 자기소개: "풀스택 개발자입니다. Java와 React를 주로 사용합니다."
- GitHub URL: https://github.com/testuser
- 웹사이트 URL: https://testuser.portfolio.com
- 학교명: 한국대학교
- 전공: 컴퓨터공학
- 학위: 학사
- 졸업 상태: 졸업
```

##### Step 6: 프로필 완성 제출
```
액션: "프로필 완성하기" 버튼 클릭
```

**폼 검증:**
```
✅ 닉네임 입력됨
✅ 자기소개 입력됨
✅ 기술 스택 최소 1개 이상 선택됨
✅ 은행, 계좌, 예금주 입력됨
```

**백엔드 처리:**
```
1. FreelancerController.completeProfile() 호출
   ↓
2. 폼 데이터 파싱
   - nickname, introduction, school_name, major, degree, grad_status
   - skills_json 파싱
   ↓
3. FreelancerService.completeProfile() 호출
   ↓
4. DB 업데이트
   - freelancer_profiles 업데이트
     UPDATE freelancer_profiles
     SET nickname='dev_freelancer_test',
         introduction='풀스택...',
         school_name='한국대학교',
         ...
     WHERE user_id=1
   
   - freelancer_skills 삭제 및 재삽입
     DELETE FROM freelancer_skills WHERE freelancer_id=1
     
     INSERT INTO freelancer_skills
     (freelancer_id, stack_id, stack_level, stack_year)
     VALUES
     (1, 5, 4, 5),    -- Java, Lv.4, 5년
     (1, 8, 3, 2),    -- React, Lv.3, 2년
     (1, 12, 3, 3)    -- MySQL, Lv.3, 3년
   ↓
5. 리다이렉트
   → /freelancer/dashboard
```

**예상 결과:**
```
✅ 프로필 저장 완료
✅ 기술 스택 저장 완료
✅ 대시보드로 자동 리다이렉트
✅ 성공 메시지 표시 (선택사항)
✅ 프로필이 "완성" 상태로 변경
```

---

#### **시나리오 2: 기술 스택 미선택 (검증 실패)**

```
Step 1: 기술 스택 선택 없이 "프로필 완성하기" 클릭

예상 결과:
❌ 폼 검증 실패
❌ 오류 메시지: "기술 스택을 최소 1개 이상 선택해주세요."
❌ 페이지 유지 (폼 값 유지)
✅ 기술 스택 섹션으로 자동 스크롤
```

---

#### **시나리오 3: 기술 스택 변경**

```
Step 1: 이미 선택한 기술 스택 모달 재오픈
Step 2: "🔍 기술 스택 선택 (모달)" 버튼 재클릭

예상 결과:
✅ 이전 선택값 유지 (파란색 표시)
✅ 새로운 기술 추가 가능 ("Python" 추가)
✅ 기존 기술 제거 가능 ("MySQL" 제거)
✅ "적용" 버튼으로 변경사항 반영
```

---

## API 명세

### 🔗 엔드포인트 1: 프로필 완성 페이지 조회

```http
GET /freelancer/complete-profile.do
```

**요청:**
```
GET /ratelocean/freelancer/complete-profile.do HTTP/1.1
Host: localhost:9999
Cookie: JSESSIONID=...
```

**응답 (200 OK):**
```html
<!-- complete-profile.jsp 페이지 렌더링 -->
<form id="profile-form" method="post" 
      action="/ratelocean/freelancer/complete-profile.do" 
      onsubmit="return handleProfileSubmit(event)">
  ...
</form>
```

**에러 응답 (302 Redirect):**
```
프리랜서가 아닌 사용자 또는 미인증 사용자
→ GET /ratelocean/join/select-role.do (리다이렉트)
```

---

### 🔗 엔드포인트 2: 프로필 완성 처리

```http
POST /freelancer/complete-profile.do
```

**요청:**
```http
POST /ratelocean/freelancer/complete-profile.do HTTP/1.1
Host: localhost:9999
Content-Type: application/x-www-form-urlencoded
Cookie: JSESSIONID=...

nickname=dev_freelancer_test
&introduction=풀스택+개발자입니다...
&school_name=한국대학교
&major=컴퓨터공학
&degree=학사
&grad_status=졸업
&github_url=https://github.com/testuser
&website_url=https://testuser.com
&bank_name=국민은행
&account_number=12345678901234
&account_holder=테스트프리랜서
&skills_json=[
  {"id":5,"name":"Java","level":4,"years":5},
  {"id":8,"name":"React","level":3,"years":2},
  {"id":12,"name":"MySQL","level":3,"years":3}
]
```

**응답 (302 Redirect):**
```
✅ 성공: 302 → GET /ratelocean/freelancer/dashboard
   + Flash Message: "프로필이 완성되었습니다!"

❌ 실패: 302 → GET /ratelocean/freelancer/complete-profile.do
   + Flash Message: "프로필 저장 중 오류가 발생했습니다."
   + 폼 값 유지
```

---

## 자주 묻는 질문

### Q1: skills_json 형식이 뭔가요?
**A:** JSON 배열 형식으로 다음과 같이 구성됩니다:
```json
[
  {
    "id": 5,           // stacks 테이블의 stack_id
    "name": "Java",    // 기술명 (선택사항)
    "level": 4,        // 숙련도 (1-5)
    "years": 5         // 경력년수 (정수 또는 소수)
  },
  {
    "id": 8,
    "name": "React",
    "level": 3,
    "years": 2
  }
]
```

### Q2: "닉네임 중복" 오류는 어디서 처리되나요?
**A:** 현재 `FreelancerService.isNicknameDuplicate()` 메서드가 준비되어 있지만, 
컨트롤러에서 검증하지 않습니다. 필요시 다음과 같이 추가하세요:
```java
if (freelancerService.isNicknameDuplicate(nickname)) {
    redirectAttributes.addFlashAttribute("error", "이미 사용 중인 닉네임입니다.");
    return "redirect:/freelancer/complete-profile.do";
}
```

### Q3: 기술 스택을 나중에 변경할 수 있나요?
**A:** 현재는 프로필 완성 시점에서만 저장됩니다. 수정 기능을 추가하려면:
1. `FreelancerService.updateProfile()` 메서드 확장
2. 기술 스택 수정 엔드포인트 추가
3. 대시보드에서 수정 버튼 추가

---

## 트러블슈팅

### ❌ 문제 1: 프로필 완성 페이지 접속 시 회원가입 페이지로 리다이렉트

**원인:**
- 세션에 `userId` 없음
- 세션에 `userType` 없음 또는 `userType != "freelancer"`

**해결:**
1. 먼저 회원가입 완료 (Step 1-2)
2. 자동 리다이렉트 확인
3. 브라우저 개발자 도구 > Application > Cookies > JSESSIONID 확인

---

### ❌ 문제 2: 프로필 저장 후 대시보드로 리다이렉트되지 않음

**원인:**
- 기술 스택 JSON 파싱 실패
- 데이터베이스 저장 실패
- 트랜잭션 롤백

**해결:**
1. 브라우저 개발자 도구 > Network > complete-profile.do 확인
2. `skills_json` 파라미터 내용 확인
3. 서버 로그 확인 (`error` 또는 `exception`)
4. MySQL 로그 확인

---

### ❌ 문제 3: "기술 스택 JSON 파싱 실패" 에러

**원인:**
- skills_json이 공백이거나 유효하지 않은 JSON
- 클라이언트에서 선택된 기술이 없음

**해결:**
1. 최소 1개 이상의 기술 스택 선택
2. JavaScript 콘솔 확인 (`console.log(selectedSkills)`)
3. FormData 확인

```javascript
// 브라우저 콘솔에서 디버깅
const form = document.getElementById('profile-form');
const formData = new FormData(form);
for (const [key, value] of formData) {
    console.log(`${key}: ${value}`);
}
```

---

### ❌ 문제 4: freelancer_skills 테이블에 데이터가 저장되지 않음

**원인:**
- `insertFreelancerSkill()` 메서드 호출 실패
- MyBatis XML 매핑 오류

**해결:**
1. 데이터베이스 테이블 확인:
```sql
DESCRIBE freelancer_skills;
SELECT * FROM freelancer_skills;
```

2. Mapper XML 확인:
```xml
<!-- FreelancerMapper.xml에서 다음 쿼리 확인 -->
<insert id="insertFreelancerSkill">
    INSERT INTO freelancer_skills (freelancer_id, stack_id, stack_level, stack_year)
    VALUES (#{freelancerId}, #{skill.stackId}, #{skill.stackLevel}, #{skill.stackYear})
</insert>
```

3. 서버 로그에서 SQL 확인 (MyBatis logging level=DEBUG)

---

### ❌ 문제 5: "닉네임" 필수 입력인데 빈값으로 저장

**원인:**
- 클라이언트 폼 검증 실패
- 서버 검증 없음

**해결:**
1. JSP 폼에서 `required` 속성 확인
2. JavaScript validateForm() 함수 확인
3. 서버에 검증 추가:
```java
if (nickname == null || nickname.trim().isEmpty()) {
    redirectAttributes.addFlashAttribute("error", "닉네임을 입력해주세요.");
    return "redirect:/freelancer/complete-profile.do";
}
```

---

## 📊 데이터 검증 체크리스트

프로필 완성 후 데이터베이스를 확인하려면:

```sql
-- 1. 사용자 조회
SELECT * FROM users WHERE login_id = 'test_freelancer_001';
-- 결과: user_id=1, user_type='freelancer'

-- 2. 프로필 확인
SELECT * FROM freelancer_profiles WHERE user_id = 1;
-- 결과: nickname='dev_freelancer_test', is_profile_complete=1

-- 3. 기술 스택 확인
SELECT fs.*, s.stack_name 
FROM freelancer_skills fs
JOIN stacks s ON fs.stack_id = s.stack_id
WHERE fs.freelancer_id = 1;
-- 결과: 3개 행 (Java, React, MySQL)

-- 4. 계좌 정보 확인
SELECT * FROM accounts WHERE user_id = 1;
-- 결과: account_number='12345678901234'

-- 5. 지갑 확인
SELECT * FROM freelancer_wallets WHERE freelancer_id = 1;
-- 결과: balance=0, total_earned=0
```

---

## 🚀 다음 단계

### 단기 (1주일)
- [ ] 통합 테스트 수행
- [ ] 데이터베이스 데이터 검증
- [ ] 에러 케이스 테스트

### 중기 (2-3주일)
- [ ] 프로필 수정 기능 구현
- [ ] 기술 스택 변경 기능 추가
- [ ] 프로필 조회 API 추가

### 장기 (1개월+)
- [ ] 경력 정보 저장 기능
- [ ] 프로젝트 경험 저장 기능
- [ ] 포트폴리오 링크 관리

---

## 📞 지원

문제가 발생하면:
1. 이 문서의 [트러블슈팅](#트러블슈팅) 섹션 확인
2. 서버 로그 확인
3. 데이터베이스 로그 확인
4. 개발팀 문의

---

**문서 버전:** 1.0  
**작성일:** 2024  
**마지막 업데이트:** 2024

