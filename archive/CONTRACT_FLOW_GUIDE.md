# 🎯 Spring MVC 계약 시스템 - 구현 가이드

## 📑 목차

1. [개요](#개요)
2. [아키텍처](#아키텍처)
3. [플로우](#플로우)
4. [3개 JSP 페이지](#3개-jsp-페이지)
5. [Controller 메서드](#controller-메서드)
6. [테스트 방법](#테스트-방법)
7. [주의사항](#주의사항)

---

## 개요

이 프로젝트는 **Spring MVC2 레거시 패턴**을 엄격히 준수하여 계약 관리 시스템을 구현합니다.

### 핵심 원칙

```
Controller (HTTP) → Service (로직) → DAO/Mapper (DB) → View (JSP)
```

- **Step 1-2**: DB 저장 없음 (메모리 기반)
- **Step 3**: 유일한 DB INSERT 지점
- **모든 비즈니스 로직**: Service 계층에 위임
- **JSP**: 순수 View 역할만 수행

---

## 아키텍처

### 디렉터리 구조

```
src/main/
├── java/com/sanaiclub/
│   └── domain/contract/
│       ├── controller/
│       │   └── ContractController.java ← HTTP 요청/응답만 담당
│       ├── service/
│       │   ├── ContractService.java (interface)
│       │   ├── ContractServiceImpl.java
│       │   ├── AIInsightService.java (interface)
│       │   ├── MockAIInsightServiceImpl.java
│       │   ├── PDFProcessingService.java (interface)
│       │   └── PDFProcessingServiceImpl.java
│       ├── dto/
│       │   ├── ContractDTO.java
│       │   ├── ContractInitDTO.java
│       │   ├── ContractConfirmDTO.java
│       │   ├── ContractMilestoneDTO.java
│       │   └── AIContractInsightDTO.java
│       └── mapper/
│           ├── ContractMapper.java (interface)
│           ├── ContractMapper.xml
│           ├── ContractMilestoneMapper.java (interface)
│           └── ContractMilestoneMapper.xml
└── webapp/
    └── WEB-INF/views/contract/
        ├── contract-start.jsp ← Step 1
        ├── contract-review.jsp ← Step 2
        └── contract-confirm.jsp ← Step 3
```

### 계층별 책임

| 계층 | 파일 | 책임 |
|------|------|------|
| **Controller** | `ContractController.java` | HTTP 요청/응답, Model 전달, 에러 처리 |
| **Service** | `ContractService*`, `AIInsightService*`, `PDFProcessingService*` | 비즈니스 로직, PDF 처리, AI 호출, DB 저장 |
| **DAO/Mapper** | `ContractMapper*`, `ContractMilestoneMapper*` | SQL 실행, DB 조작 |
| **View** | `contract-*.jsp` | 사용자 인터페이스, 폼 렌더링, 결과 표시 |
| **DTO** | `*DTO.java` | 데이터 전달 객체, 객체 매핑 |

---

## 플로우

### 3단계 계약 생성 프로세스

```
┌─────────────────────────────────────────────────────────────────────────┐
│ 🚀 START: 사용자가 계약 링크 클릭                                       │
└─────────────────┬───────────────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ 1️⃣  계약 시작 페이지 (contract-start.jsp)                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│ [URL] GET /contract/start?projectId=123&freelancerId=456              │
│                                                                         │
│ [Controller] ContractController.initializeContract()                   │
│   ├─ ProjectService에서 프로젝트 정보 조회                             │
│   ├─ FreelancerService에서 프리랜서 정보 조회                          │
│   └─ Model에 추가: projectInfo, freelancerInfo                         │
│                                                                         │
│ [View] contract-start.jsp                                              │
│   ├─ 프로젝트명, 설명, 예산 표시                                       │
│   ├─ 프리랜서명, 경력, 이메일 표시                                     │
│   ├─ PDF 파일 업로드 폼 (드래그-드롭 지원)                            │
│   └─ 제출 버튼: "다음 단계 (AI 분석)"                                  │
│                                                                         │
│ [DB] 저장 없음 (메모리만 사용)                                          │
│                                                                         │
│ [폼 제출]                                                               │
│ <form method="POST" action="/contract/analyze">                        │
│   <input name="pdf" type="file" />                                     │
│   <input name="projectId" type="hidden" value="123" />               │
│   <input name="freelancerId" type="hidden" value="456" />            │
│ </form>                                                                │
│                                                                         │
└─────────────────┬───────────────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ 2️⃣  계약 검토 페이지 - AI 분석 결과 (contract-review.jsp)              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│ [URL] POST /contract/analyze                                           │
│                                                                         │
│ [Controller] ContractController.analyzeContract()                      │
│   ├─ 1단계: 입력값 검증 (PDF 존재 여부, 파일 형식 확인)               │
│   ├─ 2단계: PDF를 임시 파일로 저장                                     │
│   ├─ 3단계: 프로젝트 정보 조회                                         │
│   ├─ 4단계: ContractService.analyzeWithAI() 호출                      │
│   │         (Service 내부에서 모든 로직 처리)                          │
│   └─ 5단계: 결과를 Model에 추가 (aiInsight, projectId, ...)           │
│                                                                         │
│ [Service] ContractService.analyzeWithAI()                             │
│   ├─ PDFProcessingService.extractText() → PDF 텍스트 추출             │
│   ├─ AIInsightService.analyzeContract() → Mock AI 호출               │
│   │   결과: AIContractInsightDTO                                       │
│   │   ├─ proposedStartDate, proposedEndDate                          │
│   │   ├─ proposedBudget                                               │
│   │   ├─ proposedMilestones[] (4개 마일스톤, 20/25/30/25%)           │
│   │   ├─ riskFactors[] (3개)                                          │
│   │   ├─ warningPoints[] (5개)                                        │
│   │   ├─ reviewPoints[] (6개)                                         │
│   │   └─ confidenceScore = 0.85                                       │
│   └─ AIContractInsightDTO 반환                                         │
│                                                                         │
│ [View] contract-review.jsp (2열 레이아웃)                              │
│   ├─ 왼쪽: 편집 폼                                                     │
│   │   ├─ 계약 시작일 <input type="date" />                           │
│   │   ├─ 계약 종료일 <input type="date" />                           │
│   │   ├─ 계약액 <input type="number" />                             │
│   │   ├─ 결제 방식 <select> (일괄/마일스톤/월별)                     │
│   │   └─ 마일스톤 테이블 (각 행: 이름, 금액, 예정일)                 │
│   │                                                                     │
│   ├─ 오른쪽: AI 분석 결과 표시                                        │
│   │   ├─ 제안 계약액                                                  │
│   │   ├─ 제안 기간                                                    │
│   │   ├─ 리스크 요소 (3개)                                            │
│   │   ├─ 경고 항목 (5개)                                              │
│   │   ├─ 검토 항목 (6개)                                              │
│   │   └─ AI 신뢰도 (85%)                                              │
│   │                                                                     │
│   └─ 제출 버튼: "다음 단계 (계약 확정)"                               │
│                                                                         │
│ [DB] 저장 없음 (메모리에만 데이터 보관)                                │
│                                                                         │
│ [폼 제출]                                                               │
│ <form method="POST" action="/contract/confirm">                        │
│   <input name="projectId" type="hidden" />                            │
│   <input name="freelancerId" type="hidden" />                         │
│   <input name="contractStartDate" type="date" />                      │
│   <input name="contractEndDate" type="date" />                        │
│   <input name="totalBudget" type="number" />                          │
│   <input name="paymentMethod" type="hidden" />                        │
│   <input name="milestones[0].name" type="text" />                     │
│   <input name="milestones[0].amount" type="number" />                 │
│   ... (반복)                                                            │
│ </form>                                                                │
│                                                                         │
└─────────────────┬───────────────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ 3️⃣  계약 확정 완료 페이지 (contract-confirm.jsp)                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│ [URL] POST /contract/confirm                                           │
│                                                                         │
│ [Controller] ContractController.confirmContract()                      │
│   ├─ 1단계: 입력값 검증                                                │
│   │   ├─ contractBudget > 0?                                          │
│   │   ├─ paymentMethod 지정됨?                                        │
│   │   └─ 마일스톤 총액 = contractBudget?                              │
│   ├─ 2단계: ContractService.confirmContract() 호출                     │
│   └─ 3단계: 반환된 contractId를 Model에 추가                           │
│                                                                         │
│ [Service] ContractService.confirmContract()                           │
│   ├─ 전체 유효성 검증                                                  │
│   ├─ ContractDTO 생성                                                  │
│   ├─ ContractMapper.insert() → contracts 테이블에 INSERT             │
│   │   (application_id, total_budget, payment_method, 날짜, 상태)     │
│   ├─ 자동 생성된 contract_id 받기                                      │
│   ├─ 각 마일스톤마다 ContractMilestoneDTO 생성                         │
│   ├─ ContractMilestoneMapper.batchInsert()                           │
│   │   → contract_milestones 테이블에 BATCH INSERT                    │
│   └─ contract_id 반환                                                  │
│                                                                         │
│ [View] contract-confirm.jsp                                            │
│   ├─ 성공 메시지 (✅ 계약 확정 완료)                                   │
│   ├─ 계약 ID 표시: #${contractId}                                     │
│   ├─ 계약 정보 요약                                                    │
│   │   ├─ 계약 ID                                                      │
│   │   ├─ 프로젝트                                                     │
│   │   ├─ 계약액                                                      │
│   │   ├─ 결제 방식                                                    │
│   │   ├─ 마일스톤 개수                                                │
│   │   └─ 확정 시간                                                    │
│   ├─ 다음 단계 (안내문)                                                │
│   │   ├─ 계약 ID 보관                                                 │
│   │   ├─ 마일스톤 계획 확인                                            │
│   │   ├─ 선금 입금 확인                                                │
│   │   └─ 마일스톤 추적                                                 │
│   └─ 버튼: "계약 관리로 이동", "계약 인쇄"                             │
│                                                                         │
│ [DB] ✅ contracts 테이블에 INSERT ✅                                     │
│      ✅ contract_milestones 테이블에 INSERT ✅                          │
│                                                                         │
└─────────────────┬───────────────────────────────────────────────────────┘
                  │
                  ▼
            🎉 END: 계약 완료
```

---

## 3개 JSP 페이지

### 1️⃣ contract-start.jsp (Step 1)

**위치**: `/WEB-INF/views/contract/contract-start.jsp`

**목적**: 프로젝트 공지 표시 + PDF 업로드 폼

**주요 요소**:
- 프로젝트명, 설명, 예산 표시
- 프리랜서명, 경력, 이메일 표시
- PDF 드래그-드롭 업로드
- 파일 검증 (확장자, 크기)
- 제출 버튼

**폼 데이터**:
```html
<form method="POST" action="/contract/analyze" enctype="multipart/form-data">
  <input type="hidden" name="projectId" value="${projectInfo.projectId}" />
  <input type="hidden" name="freelancerId" value="${freelancerId}" />
  <input type="file" name="pdf" accept=".pdf" />
  <button type="submit">다음 단계 (AI 분석)</button>
</form>
```

**JavaScript**:
- `handleFileSelect()` - 파일 선택 처리
- `handleDragOver()`, `handleDragLeave()` - 드래그 이벤트
- `handleDrop()` - 드롭 처리
- `validateForm()` - 폼 제출 전 검증

---

### 2️⃣ contract-review.jsp (Step 2)

**위치**: `/WEB-INF/views/contract/contract-review.jsp`

**목적**: AI 분석 결과 표시 + 계약 정보 편집

**레이아웃**: 2열 (데스크톱), 1열 (모바일)

**왼쪽 (편집 폼)**:
```
- 계약 시작일 <input type="date" name="contractStartDate" />
- 계약 종료일 <input type="date" name="contractEndDate" />
- 계약액 <input type="number" name="totalBudget" />
- 결제 방식 <select name="paymentMethod">
- 마일스톤 테이블 (동적 생성)
  └─ milestones[0].name, milestones[0].amount, milestones[0].dueDate
  └─ milestones[1].name, ...
```

**오른쪽 (AI 결과)**:
```
- 제안 계약액
- 제안 기간
- 리스크 요소 (배열 렌더링)
- 경고 항목 (배열 렌더링)
- 검토 항목 (배열 렌더링)
- AI 신뢰도
```

**JavaScript**:
- `updateMilestoneTotal()` - 마일스톤 총액 실시간 계산
- `validateForm()` - 계약액과 마일스톤 총액 일치 확인

**JSTL**:
```jsp
<c:forEach items="${insight.proposedMilestones}" var="milestone" varStatus="status">
  <input name="milestones[${status.index}].name" value="${milestone.name}" />
  <input name="milestones[${status.index}].amount" value="${milestone.amount}" />
  <input name="milestones[${status.index}].dueDate" value="${milestone.dueDate}" />
</c:forEach>
```

---

### 3️⃣ contract-confirm.jsp (Step 3)

**위치**: `/WEB-INF/views/contract/contract-confirm.jsp`

**목적**: 계약 확정 완료 메시지 + 계약 ID 표시

**주요 요소**:
- 성공 메시지 (✅ 계약 확정 완료)
- 계약 ID 표시 (큰 폰트, 신호등 초록색)
- 계약 정보 요약 (ID, 프로젝트, 금액, 기간)
- 다음 단계 안내
- 버튼: "계약 관리로 이동", "계약 인쇄"

**데이터**:
```jsp
<%= ${contractId} %>      <!-- 생성된 계약 ID -->
<%= ${projectId} %>        <!-- 프로젝트 ID -->
<%= ${totalBudget} %>      <!-- 총 계약액 -->
<%= ${contractedAt} %>     <!-- 확정 시간 -->
<%= ${milestonesCount} %>  <!-- 마일스톤 개수 -->
```

---

## Controller 메서드

### 메서드 1: GET /contract/start

```java
@GetMapping("/start")
public String initializeContract(
    @RequestParam Long projectId,
    @RequestParam Long freelancerId,
    Model model
)
```

**목적**: Step 1 페이지 표시

**로직**:
1. projectId, freelancerId 수신
2. ProjectService에서 프로젝트 정보 조회
3. FreelancerService에서 프리랜서 정보 조회
4. Model에 추가
5. `contract-start.jsp` 반환

**Model 속성**:
- `projectInfo` (ProjectDTO)
- `freelancerId` (Long)
- `freelancerName` (String)
- `freelancerEmail` (String)
- `freelancerExperience` (Integer)
- `maxFileSize` (Integer)
- `allowedFormat` (String)

**에러 처리**:
- projectId/freelancerId 없음 → 400
- 프로젝트 없음 → 404
- 예외 발생 → 500

---

### 메서드 2: POST /contract/analyze

```java
@PostMapping("/analyze")
public String analyzeContract(
    @RequestParam MultipartFile pdf,
    @RequestParam Long projectId,
    @RequestParam Long freelancerId,
    Model model
)
```

**목적**: Step 2 페이지 표시 (AI 분석 결과)

**로직**:
1. PDF 파일 검증 (존재, 확장자, 크기)
2. 임시 파일로 저장
3. 프로젝트 정보 조회
4. `ContractService.analyzeWithAI()` 호출
5. 결과를 Model에 추가
6. `contract-review.jsp` 반환

**Service 계층**에서 실제 처리:
```java
AIContractInsightDTO insight = contractService.analyzeWithAI(
    tempPdf,
    filename,
    projectDTO,
    freelancerName
);
```

**Model 속성**:
- `insight` (AIContractInsightDTO)
- `projectId` (Long)
- `freelancerId` (Long)
- `projectTitle` (String)
- `pdfFilename` (String)

**에러 처리**:
- PDF 파일 없음 → contract-start.jsp로 복귀
- PDF가 아닌 파일 → contract-start.jsp로 복귀
- AI 분석 실패 → 500

---

### 메서드 3: POST /contract/confirm

```java
@PostMapping("/confirm")
public String confirmContract(
    @ModelAttribute ContractConfirmDTO confirmDTO,
    Model model
)
```

**목적**: Step 3 페이지 표시 (계약 완료 메시지)

**로직**:
1. 입력값 검증
   - totalBudget > 0?
   - paymentMethod 지정됨?
2. `ContractService.confirmContract()` 호출
   - **이 단계에서 DB INSERT 실행**
3. 반환된 contractId를 Model에 추가
4. `contract-confirm.jsp` 반환

**Service 계층**에서 실제 처리:
```java
Long contractId = contractService.confirmContract(confirmDTO);
// → ContractMapper.insert() → contracts 테이블에 INSERT
// → ContractMilestoneMapper.batchInsert() → milestones 테이블에 INSERT
```

**Model 속성**:
- `contractId` (Long)
- `projectId` (Long)
- `totalBudget` (Long)
- `paymentMethod` (String)
- `contractedAt` (LocalDateTime)
- `milestonesCount` (Integer)

**에러 처리**:
- 유효성 검증 실패 → contract-review.jsp로 복귀
- DB INSERT 실패 → 500

---

## 테스트 방법

### 1️⃣ Spring 서버 실행

```bash
# Tomcat 시작
${TOMCAT_HOME}/bin/startup.bat

# 또는 IDE에서 Run as Server
```

### 2️⃣ Step 1 - 계약 시작

```
브라우저 URL:
http://localhost:9999/ratelocean/contract/start?projectId=1&freelancerId=1
```

**검증 항목**:
- ✓ 프로젝트 정보 표시
- ✓ 프리랜서 정보 표시
- ✓ PDF 업로드 폼 렌더링
- ✓ 드래그-드롭 동작

**테스트 PDF**: 아무 PDF 파일 업로드

---

### 3️⃣ Step 2 - 계약 검토

PDF를 선택하면 자동으로 POST /contract/analyze 호출

**검증 항목**:
- ✓ PDF 텍스트 추출
- ✓ Mock AI 분석 실행
- ✓ AIContractInsightDTO 생성
- ✓ 왼쪽: 편집 폼 표시
- ✓ 오른쪽: AI 결과 표시
- ✓ 마일스톤 합계 실시간 계산
- ✓ 필드 수정 가능

**샘플 데이터**:
- 계약액: 50,000,000원
- 마일스톤: 4개 (20%, 25%, 30%, 25%)

---

### 4️⃣ Step 3 - 계약 확정

필요시 필드 수정 후 "다음 단계" 버튼 클릭

**검증 항목**:
- ✓ 유효성 검증 (계약액 > 0)
- ✓ 마일스톤 합계 = 계약액 확인
- ✓ contracts 테이블에 INSERT
- ✓ contract_milestones 테이블에 INSERT
- ✓ contractId 반환
- ✓ 성공 메시지 표시
- ✓ 계약 ID 표시

---

## 주의사항

### 🚨 협업 시 중요

#### 1. Model 속성명 일치

**Controller에서 추가**:
```java
model.addAttribute("insight", aiInsight);
model.addAttribute("projectId", projectId);
```

**JSP에서 사용**:
```jsp
${insight.proposedBudget}
${projectId}
```

> ⚠️ 속성명이 다르면 `null` 에러 발생

---

#### 2. 폼 필드명 일치

**JSP에서 생성**:
```html
<input name="milestones[0].name" value="${milestone.name}" />
<input name="milestones[0].amount" value="${milestone.amount}" />
```

**DTO에서 수신**:
```java
List<ContractMilestoneDTO> milestones; // 자동 바인딩
```

> ⚠️ 필드명이 다르면 데이터 바인딩 실패

---

#### 3. Service 계층 위임

**Controller에서 해야 할 일**:
- HTTP 요청/응답
- Model 전달
- 기본 입력값 검증

**Service에서 해야 할 일**:
- PDF 처리
- AI 호출
- 비즈니스 로직
- DB 저장

```java
// ❌ 나쁜 예: Controller에서 직접 처리
@PostMapping("/analyze")
public String analyzeContract(...) {
    // SQL 실행, PDF 처리 등을 여기서 하면 안 됨
    pdfService.extract();
    aiService.analyze();
    contractMapper.insert();
}

// ✅ 좋은 예: Service로 위임
@PostMapping("/analyze")
public String analyzeContract(...) {
    AIContractInsightDTO insight = contractService.analyzeWithAI(...);
    // Service가 모든 처리를 담당
}
```

---

#### 4. DB 저장 시점

- **Step 1**: DB 저장 ❌
- **Step 2**: DB 저장 ❌
- **Step 3**: DB 저장 ✅ (유일한 지점)

```java
// Step 1-2: 메모리만 사용
AIContractInsightDTO insight = aiService.analyze(...); // 메모리

// Step 3: DB 저장
Long contractId = contractService.confirmContract(confirmDTO); // DB INSERT
```

---

#### 5. 에러 처리 전략

| 상황 | 처리 | 반환 |
|------|------|------|
| 입력값 없음 | 메시지 표시 | 이전 페이지 |
| 파일 형식 오류 | 메시지 표시 | contract-start.jsp |
| 유효성 검증 실패 | 메시지 표시 | contract-review.jsp |
| DB INSERT 실패 | 에러 페이지 | error/500 |

```java
// ✅ 올바른 에러 처리
try {
    // 로직
    return "contract-review";
} catch (IllegalArgumentException e) {
    model.addAttribute("error", e.getMessage());
    return "contract-review"; // 사용자가 수정할 수 있게 같은 페이지
} catch (Exception e) {
    model.addAttribute("error", "예상치 못한 오류");
    return "error/500"; // 복구 불가능한 오류
}
```

---

#### 6. 로깅

각 Controller 메서드 시작에 로깅 추가:

```java
System.out.println("┌─────────────────────────────────────────────────────┐");
System.out.println("│ [ContractController] POST /contract/analyze 요청     │");
System.out.println("├─────────────────────────────────────────────────────┤");
System.out.println("│ · PDF: " + pdfFile.getOriginalFilename());
System.out.println("│ · projectId: " + projectId);
System.out.println("└─────────────────────────────────────────────────────┘");
```

> 이렇게 하면 서버 로그에서 각 단계의 진행 상황을 명확히 파악 가능

---

### 📋 체크리스트

### Step 1 페이지 검증

- [ ] GET /contract/start 요청 가능
- [ ] 프로젝트 정보 표시됨
- [ ] 프리랜서 정보 표시됨
- [ ] PDF 드래그-드롭 작동
- [ ] PDF 파일 선택 가능
- [ ] 파일 크기/형식 검증

### Step 2 페이지 검증

- [ ] POST /contract/analyze 요청 가능
- [ ] PDF 텍스트 추출 성공
- [ ] Mock AI 분석 실행
- [ ] AI 결과 표시됨
- [ ] 편집 폼 렌더링됨
- [ ] 마일스톤 테이블 생성됨
- [ ] 필드 수정 가능
- [ ] 마일스톤 합계 실시간 계산
- [ ] 유효성 검증 작동 (합계 불일치 시 경고)

### Step 3 페이지 검증

- [ ] POST /contract/confirm 요청 가능
- [ ] 입력값 검증 (계약액 > 0, 합계 일치)
- [ ] contracts 테이블에 INSERT
- [ ] contract_milestones 테이블에 INSERT
- [ ] contractId 생성됨
- [ ] 성공 메시지 표시
- [ ] 다음 단계 안내 표시
- [ ] 버튼 작동 (관리자 페이지, 인쇄)

---

## 주요 파일 일람

| 파일 | 라인수 | 설명 |
|------|--------|------|
| `ContractController.java` | 450+ | HTTP 컨트롤러 (3개 메서드) |
| `contract-start.jsp` | 350+ | Step 1 페이지 |
| `contract-review.jsp` | 350+ | Step 2 페이지 |
| `contract-confirm.jsp` | 280+ | Step 3 페이지 |
| `ContractService.java` | 150+ | 서비스 인터페이스 |
| `ContractServiceImpl.java` | 280+ | 서비스 구현 |
| `AIInsightService.java` | 50+ | AI 인터페이스 |
| `MockAIInsightServiceImpl.java` | 260+ | Mock AI 구현 |
| `PDFProcessingService.java` | 75+ | PDF 인터페이스 |
| `PDFProcessingServiceImpl.java` | 160+ | PDF 구현 |

**총 코드량**: ~2,500+ 라인 (주석 포함 ~3,500 라인)

---

## 결론

이 문서는 **협업자가 시스템을 이해하고 유지보수/확장할 수 있도록** 설계되었습니다.

**핵심 원칙**:
1. **Controller**: HTTP만 담당
2. **Service**: 비즈니스 로직 담당
3. **JSP**: 순수 View 담당
4. **Step 1-2**: 메모리 기반
5. **Step 3**: DB 저장

이를 따르면 코드는 **깔끔하고**, **테스트하기 쉽고**, **확장하기 쉬워집니다**.

**문의사항**:
- Controller 경로 문제: `@RequestMapping` 확인
- Model 데이터 표시 안 됨: JSP에서 `${속성명}` 확인
- 폼 제출 안 됨: HTML form의 action, method, input name 확인
- DB 저장 안 됨: ContractMapper의 SQL, MyBatis 설정 확인

Happy Coding! 🚀
