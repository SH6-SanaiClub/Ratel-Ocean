# RatelOcean (율해양) 프로젝트

## 📋 프로젝트 개요

**RatelOcean**은 클라이언트와 프리랜서를 연결하는 프로젝트 매칭 플랫폼입니다.
클라이언트는 프로젝트를 등록하고, 프리랜서는 자신의 역량에 맞는 프로젝트에 지원할 수 있습니다.

### 주요 기능
- ✅ **프로젝트 등록** (5단계 폼, 파일 업로드, 기술스택 모달 선택)
- ✅ **프로젝트 목록 조회** (대시보드, 클라이언트 내 프로젝트, 프리랜서 검색)
- ✅ **사용자 인증** (로그인, 세션 관리, 권한 검증)
- ✅ **계약 관리** (AI 기반 계약서 분석 - Ollama 통합)
- ✅ **리뷰 시스템** (클라이언트 ↔ 프리랜서 상호 평가)

---

## 🛠️ 기술 스택

### Backend
- **Java 11** (Eclipse Temurin)
- **Spring Framework 5.3.39** (Spring MVC)
- **MyBatis 3.5.16** (SQL Mapper)
- **Apache Tomcat 9.0.112**
- **MySQL 8.0.33**

### Frontend
- **JSP** + **JSTL 1.2**
- **jQuery 3.6.0**
- **Font Awesome 6.7.2**

### Build Tool
- **Maven 3.9.6**

### AI Integration
- **Ollama** (로컬 LLM 서버)
- **llama3.2:3b-instruct-fp16** (계약서 분석 모델)

---

## 📂 프로젝트 구조

```
Latelocean/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/sanaiclub/
│   │   │       ├── domain/
│   │   │       │   ├── project/          # 프로젝트 도메인
│   │   │       │   │   ├── controller/   # ProjectController
│   │   │       │   │   ├── service/      # ProjectService
│   │   │       │   │   ├── dao/          # ProjectMapper, StackMapper
│   │   │       │   │   ├── vo/           # ProjectVO, ProjectStackVO
│   │   │       │   │   └── dto/          # ProjectCreateRequestDTO, ProjectDashboardDTO
│   │   │       │   ├── contract/         # 계약 도메인
│   │   │       │   ├── freelancer/       # 프리랜서 도메인
│   │   │       │   ├── user/             # 사용자 도메인
│   │   │       │   └── wallet/           # 지갑 도메인
│   │   ├── resources/
│   │   │   ├── mybatis/
│   │   │   │   ├── mappers/
│   │   │   │   │   ├── project/         # ProjectMapper.xml, StackMapper.xml
│   │   │   │   │   ├── contract/
│   │   │   │   │   ├── freelancer/
│   │   │   │   │   ├── user/
│   │   │   │   │   └── wallet/
│   │   │   │   └── mybatis-config.xml
│   │   │   └── application.properties
│   │   └── webapp/
│   │       ├── WEB-INF/
│   │       │   ├── views/
│   │       │   │   ├── project/          # create.jsp (5단계 등록 폼)
│   │       │   │   ├── client/           # my-projects.jsp
│   │       │   │   ├── freelancer/
│   │       │   │   └── contract/
│   │       │   ├── spring/
│   │       │   │   ├── root-context.xml  # 데이터소스, MyBatis 설정
│   │       │   │   └── appServlet/
│   │       │   │       └── servlet-context.xml
│   │       │   └── web.xml
│   │       └── resources/
│   │           ├── css/
│   │           ├── js/
│   │           └── upload/
│   │               └── project/          # 기획서 파일 업로드 경로
├── pom.xml
└── README.md
```

---

## 🚀 개발 환경 설정

### 1. 필수 소프트웨어 설치

#### Java 11 설치
```powershell
# Eclipse Temurin 11 다운로드
# https://adoptium.net/temurin/releases/?version=11

# 설치 후 JAVA_HOME 설정
$env:JAVA_HOME="C:\program\jdk-11.0.22+7"
```

#### MySQL 8.0 설치
```powershell
# MySQL Installer 다운로드
# https://dev.mysql.com/downloads/installer/

# 설치 시 설정:
# - Port: 3306
# - Root Password: sanai1234
# - Character Set: utf8mb4
```

#### Maven 3.9.6 설치
```powershell
# Maven 다운로드
# https://maven.apache.org/download.cgi

# 압축 해제 후 PATH 추가
$env:PATH="C:\Program\apache-maven-3.9.6\bin;$env:PATH"
```

#### Tomcat 9.0.112 설치
```powershell
# Tomcat 다운로드
# https://tomcat.apache.org/download-90.cgi

# 압축 해제: C:\program\apache-tomcat-9.0.112
```

---

### 2. 데이터베이스 설정

#### MySQL 접속 및 데이터베이스 생성
```sql
-- MySQL 접속
mysql -u root -p
-- Password: sanai1234

-- 데이터베이스 생성
CREATE DATABASE sanai CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 사용자 생성 (선택 사항)
CREATE USER 'sanai_user'@'localhost' IDENTIFIED BY 'sanai1234';
GRANT ALL PRIVILEGES ON sanai.* TO 'sanai_user'@'localhost';
FLUSH PRIVILEGES;
```

#### 테이블 생성 스크립트 실행
```powershell
# scripts/database/ 폴더의 SQL 파일 실행
mysql -u root -p sanai < scripts/database/schema.sql
mysql -u root -p sanai < scripts/database/test_data.sql
```

---

### 3. 프로젝트 빌드 및 배포

#### Maven 빌드
```powershell
# 프로젝트 루트 디렉토리에서 실행
cd C:\Users\김재환\Desktop\Latelocean\Latelocean

# JAVA_HOME 설정 후 빌드
$env:JAVA_HOME="C:\program\jdk-11.0.22+7"
C:\Program\apache-maven-3.9.6\bin\mvn.cmd clean package -DskipTests
```

#### WAR 파일 배포
```powershell
# target/ratelocean.war를 Tomcat webapps로 복사
Copy-Item "target\ratelocean.war" -Destination "C:\program\apache-tomcat-9.0.112\webapps\" -Force
```

#### Tomcat 서버 시작
```powershell
# Tomcat 시작
cd C:\program\apache-tomcat-9.0.112\bin
.\startup.bat
```

---

### 4. 애플리케이션 접속

#### 웹 브라우저 접속
- **메인 페이지**: http://localhost:9999/ratelocean/
- **로그인**: http://localhost:9999/ratelocean/login
- **프로젝트 등록**: http://localhost:9999/ratelocean/project/create
- **클라이언트 내 프로젝트**: http://localhost:9999/ratelocean/client/my-projects
- **대시보드**: http://localhost:9999/ratelocean/project/dashboard

#### 테스트 계정
```
클라이언트 계정:
- 이메일: client@test.com
- 비밀번호: test1234

프리랜서 계정:
- 이메일: freelancer@test.com
- 비밀번호: test1234
```

---

## 📝 주요 기능 상세

### 1. 프로젝트 등록 (5단계 폼)

**경로**: `/project/create`

#### Step 1: 프로젝트 개요
- 프로젝트 제목 (필수, 최대 200자)
- 프로젝트 상세 설명 (필수, TEXT)
- 기획서 파일 업로드 (선택, 최대 5GB)

#### Step 2: 개발 영역 및 기술 스택
- 모달 방식으로 개발 영역(POSITION) 선택
- 기술 스택(SKILL) 다중 선택
- 각 스택마다 요구 레벨(1~5)과 경력(년) 지정

#### Step 3: 예산 및 일정
- 프로젝트 예산 (콤마 포함 입력, 협의 가능 체크박스)
- 예상 진행 기간 (1개월 이내, 1~3개월, 3~6개월)
- 프로젝트 시작일 (계약 후 즉시 또는 구체적 날짜)

#### Step 4: 진행 방식
- 소통 방식 (온라인/오프라인)
- 대금 지급 방식 (일괄 지급/분할 지급)
- 무상 수정 횟수 (0~3회)

#### Step 5: 미리보기
- 입력한 모든 정보를 확인하고 수정 가능
- "등록 완료" 버튼 클릭 시 `/client/my-projects`로 이동

---

### 2. 프로젝트 목록 조회

#### 클라이언트 내 프로젝트 목록
- **경로**: `/client/my-projects`
- 로그인한 클라이언트가 등록한 프로젝트 목록
- 최신순 정렬 (ORDER BY created_at DESC)
- 카드 형태로 프로젝트 정보 표시:
  - 프로젝트 제목
  - 예상 진행 기간
  - 예산
  - 개발 영역 및 기술 스택 (레벨, 경력 포함)
  - 지원자 수
  - D-Day (마감일까지 남은 일수)

#### 대시보드 (전체 프로젝트 목록)
- **경로**: `/project/dashboard`
- 모든 공개 프로젝트 목록 (is_public = 1)
- 프리랜서가 지원할 수 있는 프로젝트 검색

---

## 🔧 주요 클래스 및 메서드 설명

### ProjectController.java

#### createProcess (POST /project/create)
```java
/**
 * 프로젝트 등록 처리
 * 
 * 1. 세션에서 로그인한 클라이언트 ID 추출 및 권한 검증
 * 2. ProjectService.createProject() 호출 (트랜잭션)
 * 3. 성공 시 /client/my-projects로 리다이렉트
 * 4. 실패 시 /project/create?error=true로 리다이렉트
 */
```

#### clientMyProjects (GET /client/my-projects)
```java
/**
 * 클라이언트 내 프로젝트 목록 조회
 * 
 * 1. 세션에서 userId 추출
 * 2. projectService.findProjectsByClientId(userId) 호출
 * 3. Model에 projectList 추가
 * 4. client/my-projects.jsp 렌더링
 */
```

---

### ProjectService.java

#### createProject
```java
/**
 * 프로젝트 생성 (트랜잭션)
 * 
 * Step 1: ProjectVO 생성 및 필드 매핑
 * - 예산 String → Integer 변환 (콤마 제거)
 * - 시작일/마감일 자동 계산
 * - 기본값 적용 (communicateMethod, paymentMethod 등)
 * 
 * Step 2: 기획서 파일 업로드 (선택 사항)
 * - UUID 파일명 생성으로 중복 방지
 * - src/main/webapp/resources/upload/project/ 경로에 저장
 * 
 * Step 3: projects 테이블에 INSERT
 * - useGeneratedKeys로 자동 생성된 project_id 반환
 * 
 * Step 4: project_stacks 테이블에 INSERT
 * - 모달에서 선택한 개발 영역 + 기술 스택
 * - stackIds, stackLevels, stackYears가 인덱스 순서로 매칭
 * 
 * @return 생성된 프로젝트 ID
 */
```

---

### ProjectMapper.xml

#### insertProject
```xml
<!-- 
  projects 테이블에 프로젝트 기본 정보 삽입
  
  useGeneratedKeys="true": AUTO_INCREMENT로 생성된 project_id 반환
  keyProperty="projectId": 생성된 ID를 ProjectVO의 projectId 필드에 할당
-->
```

#### insertProjectStack
```xml
<!-- 
  project_stacks 테이블에 프로젝트-스택 매핑 정보 삽입
  
  각 스택마다 개별적으로 INSERT 수행됨
  Service 계층에서 반복 호출하여 다중 스택 삽입
-->
```

---

## 🐛 트러블슈팅

### 1. ClassCastException: Long cannot be cast to Integer

**증상**: 프로젝트 등록 시 `?error=true`로 리다이렉트

**원인**: 
- HTML 폼에서 전송된 `stackIds`, `stackLevels`, `stackYears`가 String 타입
- DTO에서 `List<Integer>`로 받으려다 타입 캐스팅 에러 발생

**해결**:
```java
// ProjectCreateRequestDTO.java
private List<String> stackIds;     // Integer → String
private List<String> stackLevels;  // Integer → String
private List<String> stackYears;   // Integer → String

// ProjectService.java
for (int i = 0; i < stackIdsStr.size(); i++) {
    try {
        Integer stackId = Integer.parseInt(stackIdsStr.get(i));
        Integer stackLevel = Integer.parseInt(stackLevelsStr.get(i));
        Integer stackYear = Integer.parseInt(stackYearsStr.get(i));
        // ... INSERT 로직
    } catch (NumberFormatException e) {
        // 변환 실패 시 로그 출력 및 건너뛰기
    }
}
```

---

### 2. NULL 값으로 인한 DB 제약 조건 위반

**증상**: 프로젝트 등록 시 SQL 예외 발생

**원인**:
- 사용자가 선택하지 않은 필드(communicateMethod, paymentMethod 등)가 NULL로 전달됨
- DB 테이블의 NOT NULL 제약 조건에 위배

**해결**:
```java
// ProjectService.java
String communicateMethod = request.getCommunicateMethod();
if (communicateMethod == null || communicateMethod.trim().isEmpty()) {
    communicateMethod = "ONLINE"; // 기본값 설정
}
projectVO.setCommunicateMethod(communicateMethod);
```

---

### 3. 한글 문자로 인한 HTTP 헤더 인코딩 오류

**증상**: `IllegalArgumentException: Invalid character found in the HTTP protocol`

**원인**:
- 리다이렉트 URL에 한글 메시지 포함 시 HTTP 헤더 인코딩 문제 발생
- 예: `redirect:/project/create?error=프로젝트 등록 실패`

**해결**:
```java
// 에러 메시지를 파라미터로 전달하지 않고 error=true만 사용
return "redirect:/project/create?error=true";

// JSP에서 error 파라미터를 감지하여 사전 정의된 메시지 표시
<c:if test="${param.error == 'true'}">
    <div class="error-message">프로젝트 등록 중 오류가 발생했습니다.</div>
</c:if>
```

---

## 📦 배포 및 압축

### 프로젝트 압축 전 정리

```powershell
# 불필요한 파일 삭제
cd C:\Users\김재환\Desktop\Latelocean\Latelocean

# target 폴더 삭제 (빌드 결과물, 재생성 가능)
Remove-Item -Path "target" -Recurse -Force

# logs 폴더 삭제 (실행 로그, 불필요)
Remove-Item -Path "logs" -Recurse -Force

# .md 파일 아카이브로 이동
Move-Item -Path "*.md" -Destination "docs\archive_md_files\" -Force
```

### 프로젝트 압축
```powershell
# 7-Zip 사용
Compress-Archive -Path "C:\Users\김재환\Desktop\Latelocean\Latelocean" -DestinationPath "C:\Users\김재환\Desktop\Latelocean_backup.zip"

# 또는 Explorer에서 우클릭 → "보내기" → "압축(ZIP) 폴더"
```

---

## 📌 주의사항

### 1. 데이터베이스 연결 정보
- **위치**: `src/main/webapp/WEB-INF/spring/root-context.xml`
- **수정 필요 항목**:
  - `jdbc:mysql://localhost:3306/sanai`
  - `username`: root
  - `password`: sanai1234

### 2. 파일 업로드 경로
- **현재 경로**: `c:\\Users\\김재환\\Desktop\\Latelocean\\Latelocean\\src\\main\\webapp\\resources\\upload\\project\\`
- **다른 PC에서 실행 시**: `ProjectService.java`의 `UPLOAD_DIR` 상수를 환경에 맞게 수정

### 3. Tomcat 포트 설정
- **기본 포트**: 9999
- **변경 방법**: `C:\program\apache-tomcat-9.0.112\conf\server.xml`의 Connector port 수정

---

## 👨‍💻 개발자 정보

- **프로젝트명**: RatelOcean (율해양)
- **개발 기간**: 2026년 1월
- **개발자**: 신한DS 금융 SW 아카데미 팀
- **주요 담당**:
  - 프로젝트 등록 UI/UX: 이은희
  - 백엔드 로직 및 MyBatis 매핑: 이은희
  - 계약 관리 및 AI 통합: 팀원 협업

---

## 📄 라이선스

이 프로젝트는 교육 목적으로 제작되었으며, 상업적 사용을 금지합니다.

---

## 📞 문의

프로젝트 관련 문의사항이 있으시면 팀 리더에게 연락해주세요.

---

**마지막 업데이트**: 2026년 1월 18일
