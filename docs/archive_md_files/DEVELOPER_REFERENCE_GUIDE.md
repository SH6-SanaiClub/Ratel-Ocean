# 🔧 서버 구현 - 개발자 빠른 참조 가이드

## 📂 파일 구조

```
src/main/java/com/sanaiclub/domain/
├── freelancer/
│   ├── controller/
│   │   └── FreelancerController.java          ✅ [NEW] 프로필 완성 처리
│   ├── service/
│   │   └── FreelancerService.java             ✅ [NEW] 비즈니스 로직
│   ├── mapper/
│   │   └── FreelancerMapper.java              ✅ [UPDATED] 기술 스택 메서드 추가
│   └── dto/
│       ├── FreelancerProfile.java             (기존)
│       └── SkillInput.java                    ✅ [NEW] 기술 스택 입력

src/main/resources/mybatis/mappers/freelancer/
└── FreelancerMapper.xml                       ✅ [UPDATED] SQL 쿼리 추가

src/main/webapp/WEB-INF/views/freelancer/
└── complete-profile.jsp                       (기존 - handleProfileSubmit() 포함)
```

---

## 🔑 핵심 클래스 요약

### 1️⃣ SkillInput.java (DTO)

**목적:** 클라이언트의 skills_json을 Java 객체로 변환

**필드:**
```java
Long stackId          // stacks 테이블 ID
String stackName      // 기술명 (선택사항)
Integer stackLevel    // 숙련도 (1-5)
Integer stackYear     // 경력년수
```

**생성자:**
```java
new SkillInput(5, 4, 5)                    // stackId, level, years
new SkillInput(5, "Java", 4, 5)            // stackId, name, level, years
```

---

### 2️⃣ FreelancerService.java (Service)

**용도:** 프리랜서 프로필 관련 비즈니스 로직

**주요 메서드:**

#### `completeProfile()`
```java
public boolean completeProfile(
    Long freelancerId,           // userId
    FreelancerProfile profile,   // 프로필 정보
    List<SkillInput> skills      // 기술 스택 리스트
)
```

**동작:**
1. `freelancer_profiles` 테이블 업데이트
2. `freelancer_skills` 테이블 기존 데이터 삭제
3. `freelancer_skills` 테이블에 새 데이터 삽입
4. @Transactional로 트랜잭션 관리

**사용 예:**
```java
FreelancerProfile profile = new FreelancerProfile();
profile.setUserId(userId);
profile.setNickname("dev_test");
profile.setIntroduction("개발자입니다");
profile.setSchoolName("대학교");
// ...

List<SkillInput> skills = Arrays.asList(
    new SkillInput(5L, 4, 5),    // Java
    new SkillInput(8L, 3, 2)     // React
);

boolean success = freelancerService.completeProfile(userId, profile, skills);
```

---

#### `getProfile()`
```java
public FreelancerProfile getProfile(Long userId)
```
**반환:** 사용자의 프로필 정보 (없으면 null)

---

#### `isNicknameDuplicate()`
```java
public boolean isNicknameDuplicate(String nickname)
```
**반환:** true = 중복, false = 미중복

---

### 3️⃣ FreelancerMapper.java (Mapper Interface)

**용도:** 데이터베이스 접근 메서드 정의

**새로 추가된 메서드:**

```java
// 기술 스택 저장
int insertFreelancerSkill(
    @Param("freelancerId") Long freelancerId,
    @Param("skill") SkillInput skill
);

// 기존 기술 스택 삭제
int deleteFreelancerSkills(@Param("freelancerId") Long freelancerId);
```

---

### 4️⃣ FreelancerController.java (Controller)

**용도:** HTTP 요청 처리

**새로 추가된 핸들러:**

#### `GET /complete-profile.do` - 페이지 조회
```java
@GetMapping("/complete-profile.do")
public String showCompleteProfilePage(HttpSession session, Model model)
```

**처리:**
1. 세션에서 userId, userType 확인
2. 프리랜서만 접근 가능 (다른 사용자는 회원가입 페이지로 리다이렉트)
3. 프로필 정보 조회 후 모델에 추가
4. JSP 페이지 렌더링

**반환:** `freelancer/complete-profile`

---

#### `POST /complete-profile.do` - 데이터 저장
```java
@PostMapping("/complete-profile.do")
public String completeProfile(
    @RequestParam String nickname,
    @RequestParam(required=false) String introduction,
    @RequestParam(required=false) String school_name,
    @RequestParam(required=false) String major,
    @RequestParam(required=false) String degree,
    @RequestParam(required=false) String grad_status,
    @RequestParam(required=false) String github_url,
    @RequestParam(required=false) String website_url,
    @RequestParam(required=false) String bank_name,
    @RequestParam(required=false) String account_number,
    @RequestParam(required=false) String account_holder,
    @RequestParam(required=false) String skills_json,
    HttpSession session,
    RedirectAttributes redirectAttributes
)
```

**처리 흐름:**
```
1. 세션 검증 (프리랜서만)
2. 파라미터 → FreelancerProfile 객체 변환
   - snake_case → camelCase 매핑
   - school_name → schoolName
   - grad_status → gradStatus
   - github_url → githubUrl
   - website_url → websiteUrl

3. skills_json 파싱 → List<SkillInput>
   JSON 예:
   [
     {"id":5,"name":"Java","level":4,"years":5},
     {"id":8,"name":"React","level":3,"years":2}
   ]

4. FreelancerService.completeProfile() 호출
   ↓ 성공
   → redirect: /freelancer/dashboard
   → Flash: "프로필이 완성되었습니다!"
   
   ↓ 실패
   → redirect: /freelancer/complete-profile.do
   → Flash: "오류: ..."
```

**반환:**
- 성공: Redirect to `/freelancer/dashboard`
- 실패: Redirect to `/freelancer/complete-profile.do`

---

## 🔄 데이터 흐름

### 클라이언트 → 서버 전송

```
HTML Form
├─ nickname: "dev_test"
├─ introduction: "개발자입니다"
├─ school_name: "대학교"
├─ major: "컴퓨터공학"
├─ degree: "학사"
├─ grad_status: "졸업"
├─ github_url: "https://..."
├─ website_url: "https://..."
├─ bank_name: "국민은행"
├─ account_number: "12345678901234"
├─ account_holder: "홍길동"
└─ skills_json: "[JSON STRING]"  ← JavaScript에서 JSON.stringify()
```

### 파라미터 매핑

```
HTTP Request Parameter     →  Java Variable
─────────────────────────────────────────
nickname                   →  @RequestParam String nickname
school_name                →  @RequestParam String school_name
grad_status                →  @RequestParam String grad_status
github_url                 →  @RequestParam String github_url
website_url                →  @RequestParam String website_url
skills_json                →  @RequestParam String skills_json
```

### 객체 변환

```
@RequestParam              →  FreelancerProfile 필드
──────────────────────────────────────────
nickname                   →  profile.nickname
school_name                →  profile.schoolName (변환!)
grad_status                →  profile.gradStatus (변환!)
github_url                 →  profile.githubUrl (변환!)
website_url                →  profile.websiteUrl (변환!)
```

### JSON 파싱

```javascript
// 클라이언트 (JavaScript)
const selectedSkills = [
  { id: 5, name: "Java", level: 4, years: 5 },
  { id: 8, name: "React", level: 3, years: 2 }
];

// 폼 제출 시 JSON 문자열로 변환
skillsJsonInput.value = JSON.stringify(selectedSkills);
// → "[{"id":5,"name":"Java",...}]"
```

```java
// 서버 (Java)
private List<SkillInput> parseSkillsJson(String skillsJson) {
    // "[{"id":5,...}]" → List<SkillInput>
    List<SkillInput> skills = objectMapper.readValue(
        skillsJson,
        new TypeReference<List<SkillInput>>() {}
    );
    return skills;
}
```

### 데이터베이스 저장

```sql
-- 1. freelancer_profiles 업데이트
UPDATE freelancer_profiles
SET nickname='dev_test',
    introduction='개발자입니다',
    school_name='대학교',
    major='컴퓨터공학',
    degree='학사',
    grad_status='졸업',
    github_url='https://...',
    website_url='https://...',
    is_profile_complete=1
WHERE user_id=1;

-- 2. freelancer_skills 삭제
DELETE FROM freelancer_skills WHERE freelancer_id=1;

-- 3. freelancer_skills 재삽입 (for each skill in skills)
INSERT INTO freelancer_skills
(freelancer_id, stack_id, stack_level, stack_year)
VALUES
(1, 5, 4, 5),    -- Java
(1, 8, 3, 2);    -- React
```

---

## 🧪 테스트 코드 예제

### 통합 테스트 (Integration Test)

```java
@RunWith(SpringRunner.class)
@SpringBootTest
public class FreelancerProfileIntegrationTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private FreelancerService freelancerService;
    
    @Test
    public void testCompleteProfile() throws Exception {
        // 1. 프리랜서 회원가입
        User user = userService.registerFreelancer(
            "test_user", "test@example.com", "password", 
            "홍길동", "010-1234-5678", "1995.05.15",
            "nickname", "intro", null, null,
            "국민은행", "123456", "홍길동"
        );
        
        // 2. 프로필 완성 요청
        MockHttpSession session = new MockHttpSession();
        session.setAttribute("userId", user.getUserId());
        session.setAttribute("userType", "freelancer");
        
        String skillsJson = "[" +
            "{\"id\":5,\"name\":\"Java\",\"level\":4,\"years\":5}," +
            "{\"id\":8,\"name\":\"React\",\"level\":3,\"years\":2}" +
            "]";
        
        mockMvc.perform(
            post("/freelancer/complete-profile.do")
                .session(session)
                .param("nickname", "dev_test")
                .param("introduction", "개발자입니다")
                .param("school_name", "대학교")
                .param("major", "컴공")
                .param("degree", "학사")
                .param("grad_status", "졸업")
                .param("skills_json", skillsJson)
        )
        .andExpect(status().is3xxRedirection())
        .andExpect(redirectedUrl("/freelancer/dashboard"));
        
        // 3. 데이터 검증
        FreelancerProfile profile = freelancerService.getProfile(user.getUserId());
        assertThat(profile.getNickname()).isEqualTo("dev_test");
        assertThat(profile.getIsProfileComplete()).isTrue();
    }
}
```

---

## 🔍 디버깅 팁

### 1. 로그 추가

```java
// FreelancerController
@PostMapping("/complete-profile.do")
public String completeProfile(...) {
    System.out.println("📝 프로필 저장 요청:");
    System.out.println("  - nickname: " + nickname);
    System.out.println("  - skills_json: " + skills_json);
    
    List<SkillInput> skills = parseSkillsJson(skills_json);
    System.out.println("  - parsed skills count: " + skills.size());
    
    boolean success = freelancerService.completeProfile(userId, profile, skills);
    System.out.println("  - result: " + (success ? "✅ SUCCESS" : "❌ FAILURE"));
    
    // ...
}
```

### 2. 데이터 검증 쿼리

```sql
-- 프로필이 저장되었는지 확인
SELECT * FROM freelancer_profiles WHERE user_id = 1;

-- 기술 스택이 저장되었는지 확인
SELECT fs.freelancer_id, fs.stack_id, s.stack_name, 
       fs.stack_level, fs.stack_year
FROM freelancer_skills fs
JOIN stacks s ON fs.stack_id = s.stack_id
WHERE fs.freelancer_id = 1;
```

### 3. 브라우저 디버깅

```javascript
// 폼 제출 전 로그 확인
function handleProfileSubmit(event) {
    event.preventDefault();
    
    console.log("📝 폼 제출 데이터:");
    const form = document.getElementById('profile-form');
    const formData = new FormData(form);
    
    for (const [key, value] of formData) {
        console.log(`  ${key}: ${value.substring(0, 50)}...`);
    }
    
    // 기술 스택 확인
    console.log("🔧 선택된 기술 스택:");
    console.table(selectedSkills);
    
    // 폼 제출
    form.submit();
}
```

---

## 📋 체크리스트

배포 전 확인:

- [ ] FreelancerService.java 컴파일 성공
- [ ] FreelancerController.java 컴파일 성공
- [ ] SkillInput.java 컴파일 성공
- [ ] FreelancerMapper.java 컴파일 성공
- [ ] FreelancerMapper.xml SQL 유효
- [ ] freelancer_skills 테이블 존재
- [ ] GET /freelancer/complete-profile.do 접근 가능
- [ ] POST /freelancer/complete-profile.do 데이터 저장
- [ ] freelancer_skills 테이블 데이터 확인
- [ ] 데이터 검증 쿼리 실행
- [ ] 대시보드 리다이렉트 확인

---

## 📞 문제 해결

| 증상 | 원인 | 해결 |
|------|------|------|
| 컴파일 에러 | 임포트 누락 | IDE의 자동 임포트 사용 |
| 404 에러 | 매핑 경로 오류 | URL 정확히 입력 |
| 500 에러 | 데이터베이스 오류 | 로그 확인, 테이블 확인 |
| 세션 오류 | userId 없음 | 회원가입 완료 후 진행 |
| JSON 파싱 오류 | 유효하지 않은 JSON | 기술 스택 최소 1개 선택 |

---

**버전:** 1.0  
**작성일:** 2024  
**용도:** 개발팀 참조

