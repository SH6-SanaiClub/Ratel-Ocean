# 🎯 프리랜서 프로필 완성 페이지 - 기술 스택 모달 구현 가이드

## 📋 개요

프리랜서 프로필 완성 페이지에서 **기술 스택 선택을 모달로 개선**했습니다.

### 개선 사항

| 항목 | 이전 | 현재 |
|------|------|------|
| **기술 입력 방식** | 수동 텍스트 입력 | 모달 기반 선택 |
| **데이터 소스** | 자유 입력 (오타/중복 가능) | DB 등록 기술만 선택 |
| **검색/필터** | 없음 | 검색, 알파벳 필터 |
| **사용자 경험** | 매번 기술명 입력 필요 | 클릭으로 빠른 선택 |
| **데이터 일관성** | 낮음 | 높음 |

---

## 🚀 페이지 구조

### URL
```
http://localhost:9999/ratelocean/freelancer/complete-profile
```

### 페이지 흐름
```
1️⃣ 역할 선택 (selectRole.jsp)
   ↓
2️⃣ 기본 정보 입력 (signup.jsp) - 세션에만 저장
   ↓
3️⃣ 프로필 완성 (complete-profile.jsp) ← ⭐ 여기
   ├─ 기본 프로필 (닉네임, 자기소개)
   ├─ 학력 정보
   ├─ 경력 사항
   ├─ 프로젝트 경험
   ├─ 포트폴리오
   ├─ 🆕 기술 스택 (모달)
   └─ 계좌 정보
   ↓
4️⃣ DB 저장 및 로그인
```

---

## 🎨 기술 스택 섹션 상세

### 1. 선택 영역 (Display Area)

**모습**: 태그 형태로 선택된 기술 표시

```
┌─────────────────────────────────────────────────────┐
│ Java     Lv.4 • 5년  ✕                              │
│ React    Lv.3 • 2년  ✕                              │
│ AWS      Lv.2 • 1년  ✕                              │
└─────────────────────────────────────────────────────┘
```

**특징**:
- 기술명, 숙련도(1-5), 경력 년수 표시
- 우측 × 버튼으로 개별 기술 제거 가능
- 시각적으로 눈에 띄는 청록색 디자인

### 2. 모달 열기 버튼

```
┌─────────────────────────────────────────────┐
│ 🔍 기술 스택 선택 (모달)                    │
└─────────────────────────────────────────────┘
```

**클릭 시**:
- 기술 스택 모달 열림
- 개발 영역 목록 (백엔드, 프론트엔드 등)
- 기술 스택 목록 (Java, React, MySQL 등)
- 검색 및 알파벳 필터

### 3. 상세 입력 폼

**모달에서 기술을 선택하면**:

```
┌────────────────────────────────────────────┐
│ Java 기술명              disabled          │
├────────────────────────────────────────────┤
│ 숙련도 (1-5)    경력 (년)      [삭제]     │
│ [3 - 중급]      5             버튼        │
├────────────────────────────────────────────┤
│ React 기술명             disabled          │
├────────────────────────────────────────────┤
│ 숙련도 (1-5)    경력 (년)      [삭제]     │
│ [3 - 중급]      2             버튼        │
└────────────────────────────────────────────┘
```

**기능**:
- 기술명: 고정값 (disabled)
- 숙련도: 1-5 단계 선택 (기본값: 3)
- 경력: 년 수 입력 (기본값: 1)
- 삭제: 해당 기술 제거

---

## 📱 사용자 시나리오

### 시나리오 1: 정상 프로필 완성

#### Step 1: 역할 선택 → 기본 정보 입력
```
http://localhost:9999/ratelocean/join/select-role.do
↓
[프리랜서] 버튼 클릭
↓
http://localhost:9999/ratelocean/join/signup.do
↓
기본 정보 입력:
- 로그인 ID: freelancer_test_001
- 이메일: freelancer@test.com
- 비밀번호: Password123!
- 이름: 홍길동
- 전화: 010-1234-5678
- 생년월일: 1995.05.15
↓
[다음으로] 버튼
```

#### Step 2: 프로필 완성 페이지 접속
```
http://localhost:9999/ratelocean/freelancer/complete-profile
```

#### Step 3: 기술 스택 선택
```
1. "🔍 기술 스택 선택 (모달)" 버튼 클릭
   ↓
2. 모달 팝업 표시
   ├─ 개발 영역: [백엔드] [프론트엔드] [데이터베이스] ...
   └─ 기술 스택:
      ├─ 검색창: "java" 입력
      ├─ 알파벳 필터: [전체] [A-C] [D-F] ...
      └─ 결과: Java, JavaScript, Jenkins 표시
   
3. 기술 선택
   - "Java" 클릭 → 선택됨 (파란색)
   - "React" 검색 후 선택
   - "MySQL" 검색 후 선택
   
4. "적용" 버튼 클릭
   ↓
5. 모달 닫힘, 선택된 기술 태그 표시:
   Java    Lv.3 • 1년  ✕
   React   Lv.3 • 1년  ✕
   MySQL   Lv.3 • 1년  ✕

6. 상세 정보 입력
   - Java:   Lv.4 (중상급) + 5년 경력
   - React:  Lv.3 (중급) + 2년 경력
   - MySQL:  Lv.3 (중급) + 3년 경력
```

#### Step 4: 나머지 프로필 입력
```
- 닉네임: dev_hong
- 자기소개: "풀스택 개발자입니다. ..."
- 학교명: 서울대학교
- 전공: 컴퓨터공학
- 경력: 회사 경력 추가 (2개)
- 프로젝트: 진행했던 프로젝트 (3개)
- 포트폴리오: GitHub, 포트폴리오 사이트 링크
- 계좌: 국민은행, 123456789, 홍길동
```

#### Step 5: 제출
```
[프로필 완성하기] 버튼 클릭
↓
검증:
✅ 닉네임 입력됨
✅ 자기소개 입력됨
✅ 기술 스택 최소 1개 이상 선택됨
✅ 계좌 정보 입력됨
↓
DB 저장:
- users 테이블: 회원 정보
- freelancer_profiles 테이블: 프로필
- freelancer_careers 테이블: 경력
- freelancer_project_experiences 테이블: 프로젝트
- freelancer_portfolios 테이블: 포트폴리오
- freelancer_skills 테이블: 기술 스택 (✨ 중요)
- accounts 테이블: 계좌 정보
- freelancer_wallets 테이블: 지갑
↓
✅ 자동 로그인
↓
프리랜서 대시보드로 리다이렉트
```

### 시나리오 2: 기술 스택 미선택 (실패)

```
[프로필 완성하기] 버튼 클릭

❌ 검증 실패: "기술 스택을 최소 1개 이상 선택해주세요."

💡 자동 스크롤: 기술 스택 섹션으로 이동
```

### 시나리오 3: 기술 선택 후 변경

```
1. "🔍 기술 스택 선택 (모달)" 버튼 재클릭
2. 이전 선택값 유지:
   ✓ Java (이미 선택됨 - 파란색)
   ✓ React (이미 선택됨 - 파란색)
   ✓ MySQL (이미 선택됨 - 파란색)
3. 새로운 기술 추가:
   - "Python" 클릭
4. 기술 제거:
   - "MySQL" 클릭 (선택 해제)
5. "적용" 클릭
6. 태그 자동 업데이트
```

---

## 💾 DB 저장 구조

### 기술 스택 데이터 저장 (`freelancer_skills` 테이블)

```
freelancer_id | stack_id | stack_level | stack_year | created_at
──────────────────────────────────────────────────────────────────
1             | 5        | 4           | 5          | 2026-01-17
1             | 8        | 3           | 2          | 2026-01-17
1             | 12       | 3           | 3          | 2026-01-17
```

### 매핑

- `stack_id`: stacks 테이블의 ID (Java=5, React=8, MySQL=12)
- `stack_level`: 숙련도 (1-5)
- `stack_year`: 경력 (년)

---

## 🔧 기술 상세

### 백엔드 (Spring MVC)

#### Controller
```
POST /freelancer/complete-profile.do

요청 파라미터:
- nickname (required)
- introduction (required)
- github_url (optional)
- website_url (optional)
- school_name, major, degree, grad_status (optional)
- careers[] (repeater - optional)
- experiences[] (repeater - optional)
- portfolios[] (repeater - optional)
- skills[] (repeater - REQUIRED)
  └─ skills[0].stack_name (기술명)
  └─ skills[0].stack_level (숙련도)
  └─ skills[0].stack_year (경력)
- bank_name (required)
- account_number (required)
- account_holder (required)
```

#### Service
```java
@Transactional
public void completeFreelancerProfile(
    String nickname,
    String introduction,
    ...
    List<FreelancerSkill> skills
) {
    // 1. 프리랜서 프로필 저장
    // 2. 경력, 프로젝트, 포트폴리오 저장
    // 3. 🆕 기술 스택 저장 (freelancer_skills)
    //    - stack_id (stacks 테이블 조인)
    //    - stack_level
    //    - stack_year
    // 4. 계좌 정보 저장
}
```

### 프론트엔드 (JavaScript)

#### 모달 통합
```javascript
// 모달 열기
function openSkillModal() {
    // 기존 선택값 전달
    const preselectedStacks = selectedSkills.map(s => ({
        id: s.id,
        name: s.name
    }));
    
    // 모달 콜백
    openTechStackModal(callback, [], preselectedStacks);
}

// 선택 반영
function renderSelectedSkills() {
    // 1. 태그 형태로 표시
    // 2. 상세 입력 폼 생성
    // 3. 숨겨진 input으로 폼 제출 시 전송
}
```

#### 폼 검증
```javascript
function validateForm() {
    // 기술 스택 필수 검증
    if (selectedSkills.length === 0) {
        alert('기술 스택을 최소 1개 이상 선택해주세요.');
        return false;
    }
    
    // 필수 필드 검증
    // ...
    
    return true;
}
```

---

## ✅ 검증 체크리스트

### 프론트엔드
- [ ] 모달 버튼 표시됨
- [ ] 모달 클릭 시 기술 스택 모달 열림
- [ ] 기술 검색 작동
- [ ] 알파벳 필터 작동
- [ ] 기술 선택/해제 가능
- [ ] 적용 버튼 클릭 시 태그 표시
- [ ] 태그의 X 버튼으로 기술 제거
- [ ] 숙련도, 경력 입력 필드 생성됨
- [ ] 기술 제거 버튼 작동
- [ ] 폼 제출 시 검증 실행
- [ ] 기술 미선택 시 에러 메시지 표시

### 백엔드
- [ ] `/freelancer/complete-profile.do` POST 요청 처리
- [ ] `skills[]` 파라미터 받음
- [ ] 기술 정보 파싱 (`stack_name`, `stack_level`, `stack_year`)
- [ ] `stacks` 테이블에서 `stack_id` 조회
- [ ] `freelancer_skills` 테이블에 저장
- [ ] 트랜잭션 처리
- [ ] 에러 핸들링

### 데이터베이스
- [ ] `stacks` 테이블에 기술 데이터 존재
- [ ] `freelancer_skills` 테이블에 데이터 저장됨
- [ ] `stack_level`, `stack_year` 값 정상 저장됨

---

## 🧪 테스트 SQL

### 기술 데이터 확인
```sql
-- 등록된 기술 스택
SELECT stack_id, stack_name, category FROM stacks ORDER BY stack_name;

-- 프리랜서 기술
SELECT 
    fs.freelancer_id,
    s.stack_name,
    fs.stack_level,
    fs.stack_year
FROM freelancer_skills fs
JOIN stacks s ON fs.stack_id = s.stack_id
WHERE fs.freelancer_id = (SELECT user_id FROM users WHERE login_id = 'freelancer_test_001')
ORDER BY s.stack_name;
```

### 전체 프로필 확인
```sql
-- 프리랜서 정보
SELECT * FROM users WHERE login_id = 'freelancer_test_001';

-- 프로필
SELECT * FROM freelancer_profiles WHERE user_id = 1;

-- 경력
SELECT * FROM freelancer_careers WHERE freelancer_id = 1;

-- 프로젝트 경험
SELECT * FROM freelancer_project_experiences WHERE freelancer_id = 1;

-- 포트폴리오
SELECT * FROM freelancer_portfolios WHERE freelancer_id = 1;

-- 기술 스택
SELECT * FROM freelancer_skills WHERE freelancer_id = 1;

-- 계좌
SELECT * FROM accounts WHERE user_id = 1;

-- 지갑
SELECT * FROM freelancer_wallets WHERE freelancer_id = 1;
```

---

## 🎁 추가 기능 (Future)

- [ ] 기술 검색 자동완성 (autocomplete)
- [ ] 최근 선택 기술 저장 (로컬스토리지)
- [ ] 추천 기술 스택 (AI 기반)
- [ ] 기술별 평균 숙련도 표시
- [ ] 벤치마크: 같은 포지션의 다른 프리랜서 기술 비교

---

## 📞 문제 해결

### Q: 모달 버튼이 클릭되지 않습니다
**A**: jQuery와 `tech-stack-modal.js` 파일이 로드되었는지 확인하세요.

```html
<!-- complete-profile.jsp 하단 -->
<%@ include file="/WEB-INF/views/common/tech-stack-modal.jsp" %>
<script src="/ratelocean/resources/js/tech-stack-modal.js"></script>
```

### Q: 모달에서 기술이 표시되지 않습니다
**A**: API 엔드포인트 확인
```
GET /ratelocean/api/stacks/skills
```

### Q: 폼 제출 시 기술 정보가 전송되지 않습니다
**A**: 콘솔에서 `selectedSkills` 확인
```javascript
console.log(selectedSkills);
```

---

## 📚 관련 파일

| 파일 | 설명 |
|------|------|
| `complete-profile.jsp` | 프로필 완성 페이지 (메인) |
| `tech-stack-modal.jsp` | 기술 스택 모달 (공통 컴포넌트) |
| `tech-stack-modal.js` | 모달 JavaScript (공통 로직) |
| `StackController.java` | 기술 API 제공 |
| `UserController.java` | 프로필 저장 처리 |

---

**마지막 업데이트**: 2026-01-17
**상태**: ✅ 완성
