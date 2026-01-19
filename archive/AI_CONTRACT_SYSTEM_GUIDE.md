# 🚀 AI 계약 시스템 구현 가이드

> **작성일**: 2025-01-16  
> **상태**: Phase 2 완료 (테스트 페이지 구현 완료)  
> **다음 단계**: Phase 3 (MyBatis Mapper 통합, DB 저장 검증)

---

## 📋 목차

1. [시스템 개요](#시스템-개요)
2. [구현 완료 사항](#구현-완료-사항)
3. [테스트 방법](#테스트-방법)
4. [파일 구조](#파일-구조)
5. [기술 스택](#기술-스택)
6. [주요 설계 결정](#주요-설계-결정)
7. [다음 단계](#다음-단계)

---

## 시스템 개요

### 목표
**AI 기반 계약 초안 자동 생성 및 사용자 검토/확정 시스템**

라테오션 플랫폼에서 프리랜서-클라이언트 간 계약 과정을 **AI가 보조**하되, **최종 결정권은 사용자**에게 유지하는 시스템입니다.

### 핵심 원칙

✓ **AI는 조언만 제공** - 계약 결정은 사용자가 함  
✓ **메모리 기반 처리** - AI 결과는 DB 저장 X (사용자 확정 전까지)  
✓ **단계별 명확한 분리** - 초기화 → 분석 → 검토 → 확정 → 리포트  
✓ **Mock AI 테스트 지원** - DeepSeek API 없이도 완전히 작동  
✓ **DB 무결성 보장** - 확정 시에만 transactions/milestones 저장  

---

## 구현 완료 사항

### ✅ Phase 1: AI 서비스 계층 (완료)

| 파일 | 역할 | 상태 |
|------|------|------|
| `AIInsightService.java` | AI 서비스 인터페이스 | ✅ |
| `MockAIInsightServiceImpl.java` | Mock AI 구현 (테스트용) | ✅ |
| `AIContractInsightDTO.java` | AI 결과 DTO | ✅ |
| `ContractMilestoneDTO.java` | 마일스톤 DTO | ✅ |

**기능**:
- Mock AI가 4단계 마일스톤 자동 생성
- 위험 요소, 경고 포인트, 검토 항목 제공
- 실제 DeepSeek과 동일한 인터페이스

### ✅ Phase 2: PDF & 서비스 계층 (완료)

| 파일 | 역할 | 상태 |
|------|------|------|
| `PDFProcessingService.java` | PDF 처리 인터페이스 | ✅ |
| `PDFProcessingServiceImpl.java` | PDFBox 기반 구현 | ✅ |
| `ContractService.java` | 비즈니스 로직 인터페이스 | ✅ |
| `ContractServiceImpl.java` | 비즈니스 로직 구현 | ✅ |

**기능**:
- PDF에서 텍스트만 추출 (이미지 무시)
- 파일을 임시 디렉토리에 저장
- AI 분석 결과를 메모리에만 보관
- 계약 확정 시에만 DB INSERT

### ✅ Phase 2: 데이터 계층 (완료)

| 파일 | 역할 | 상태 |
|------|------|------|
| `ContractMapper.xml` | contracts 테이블 SQL | ✅ |
| `ContractMilestoneMapper.xml` | contract_milestones SQL | ✅ |
| `ContractMapper.java` | 인터페이스 | ✅ |
| `ContractMilestoneMapper.java` | 인터페이스 | ✅ |
| `ContractDTO.java` | DTO | ✅ |

**기능**:
- INSERT, SELECT, UPDATE, DELETE (배치 포함)
- 상태 관리 (SIGNED → IN_PROGRESS → COMPLETED)
- 예산 검증

### ✅ Phase 2: 컨트롤러 (완료)

| 파일 | 메서드 | 상태 |
|------|--------|------|
| `ContractController.java` | GET /contract/init | ✅ |
|  | POST /contract/analyze | ✅ |
|  | POST /contract/confirm | ✅ |
|  | GET /contract/test-flow | ✅ |

### ✅ Phase 2: JSP 페이지 (완료)

| 페이지 | 목적 | 상태 |
|--------|------|------|
| `contract-init.jsp` | 프로젝트 정보 + PDF 업로드 | ✅ |
| `contract-review.jsp` | AI 결과 검토 + 수정 | ✅ |
| `contract-complete.jsp` | 계약 확정 완료 | ✅ |
| `test-contract-flow.jsp` | 전체 테스트 페이지 | ✅ |

---

## 테스트 방법

### 🧪 테스트 페이지 접근

```
URL: http://192.168.0.56:9999/ratelocean/contract/test-flow
```

### 📝 테스트 시나리오

#### **Step 1: 초기화**
```
1. 프로젝트 선택: "라테오션 플랫폼 구축"
2. 프리랜서 선택: "홍길동 (5년 경력)"
3. [✓ Step 1: 초기화] 버튼 클릭
```

**예상 결과**:
```
✓ Step 1 완료: 초기화
  - 프로젝트 ID: 1
  - 프리랜서 ID: 1
```

#### **Step 2: AI 분석**
```
1. [🤖 Step 2: AI로 분석] 버튼 클릭
```

**예상 결과**:
- 우측에 AI 분석 결과 표시
- 계약 정보:
  - 시작일: 2025-02-01
  - 종료일: 2025-05-01
  - 예산: 45,000,000원
  - 마일스톤: 4개

- 위험 요소 3개 표시
- 경고 포인트 5개 표시
- 검토 항목 6개 표시

#### **Step 3: 검토 및 수정**
```
1. "계약 총액" 필드에서 값 수정 (선택)
2. "결제 방식" 확인 (마일스톤/일시금)
3. [✓ Step 3: 검토 완료] 버튼 클릭
```

**예상 결과**:
```
✓ Step 3 완료: 검토 완료
  - 최종 계약액: 45,000,000원
  - 결제 방식: MILESTONE
```

#### **Step 4: 계약 확정 (DB 저장)**
```
1. [✓✓ Step 4: 계약 확정 (DB 저장)] 버튼 클릭
```

**예상 결과**:
```
✓ Step 4 완료: 계약 확정 완료
  - 계약 ID: 123456
  - 저장된 테이블:
    • contracts (1행)
    • contract_milestones (4행)

✓ 계약 확정 완료!
계약 ID: #123456
DB에 contracts 및 contract_milestones 테이블에 데이터가 저장되었습니다.
```

---

## 파일 구조

### 서비스 계층

```
src/main/java/com/sanaiclub/domain/contract/
├── service/
│   ├── AIInsightService.java          [I] AI 서비스 인터페이스
│   ├── MockAIInsightServiceImpl.java   [C] Mock AI 구현
│   ├── PDFProcessingService.java      [I] PDF 처리 인터페이스
│   ├── PDFProcessingServiceImpl.java   [C] PDFBox 구현
│   ├── ContractService.java           [I] 비즈니스 로직 인터페이스
│   └── ContractServiceImpl.java        [C] 비즈니스 로직 구현
├── controller/
│   └── ContractController.java         [C] HTTP 엔드포인트
├── mapper/
│   ├── ContractMapper.java            [I] DB 매퍼
│   └── ContractMilestoneMapper.java   [I] DB 매퍼
└── dto/
    ├── AIContractInsightDTO.java       AI 결과 DTO
    ├── ContractInitDTO.java            초기 정보 DTO
    ├── ContractConfirmDTO.java         확정 DTO
    ├── ContractDTO.java                DB DTO
    └── ContractMilestoneDTO.java       마일스톤 DTO
```

### 데이터 계층

```
src/main/resources/mybatis/mappers/contract/
├── ContractMapper.xml                  SQL: contracts 테이블
└── ContractMilestoneMapper.xml         SQL: contract_milestones 테이블
```

### 뷰 계층

```
src/main/webapp/WEB-INF/views/contract/
├── contract-init.jsp                   프로젝트 정보 + PDF 업로드
├── contract-review.jsp                 AI 결과 검토 + 수정
├── contract-complete.jsp               계약 확정 완료
└── test-contract-flow.jsp              ⭐ 통합 테스트 페이지
```

---

## 기술 스택

### 백엔드

- **언어**: Java 17
- **프레임워크**: Spring MVC 5.3
- **DB**: MySQL 8.0 (sanai database)
- **ORM**: MyBatis 3.5
- **PDF**: Apache PDFBox 2.x
- **빌드**: Maven
- **톰캣**: Apache Tomcat 9.0.112 (Port 9999)

### 프론트엔드

- **HTML5**, **CSS3**, **Vanilla JavaScript**
- **마크업**: JSP with JSTL
- **스타일**: CSS Grid, Flexbox

---

## 주요 설계 결정

### 1️⃣ 인터페이스 기반 AI 서비스

```java
// 하나의 인터페이스로 Mock과 실제 AI를 교체 가능
public interface AIInsightService {
    AIContractInsightDTO analyzeContract(...);
}

// Mock (테스트용)
@Service
public class MockAIInsightServiceImpl implements AIInsightService { ... }

// DeepSeek (프로덕션용, 향후)
@Service
public class DeepSeekAIInsightServiceImpl implements AIInsightService { ... }
```

**이점**:
- 컨트롤러/서비스는 AI 구현체를 모름
- 테스트 중에는 Mock AI 사용
- 프로덕션에서는 @ConditionalOnProperty로 자동 선택

### 2️⃣ 메모리 기반 처리

```
사용자 입력
  ↓ (Step 1)
[메모리] ContractInitDTO
  ↓ (Step 2)
[메모리] PDF 텍스트 + AIContractInsightDTO
  ↓ (Step 3)
[메모리] 사용자 수정 정보 + ContractConfirmDTO
  ↓ (Step 4)
[DB] INSERT contracts + contract_milestones
```

**이점**:
- AI 실패 시 DB 손상 없음
- 사용자가 언제든 이전 단계로 돌아갈 수 있음
- 전체 검토 후 확정할 수 있음

### 3️⃣ PDF 텍스트만 처리

```java
// PDF 파일 경로 저장 (텍스트 X)
contracts.origin_contract_url = "/uploads/contracts/20250116_143025_contract.pdf"

// 텍스트는 메모리에만
String pdfText = pdfService.extractText(file);
AIContractInsightDTO insight = aiService.analyzeContract(pdfText, ...);
// insight는 DB 저장 X
```

**이점**:
- 저장 공간 절감 (텍스트는 변수, PDF는 파일)
- AI 재분석 필요 시 PDF 재처리 가능
- 프라이버시 보호 (계약 텍스트 DB 저장 X)

### 4️⃣ 단계별 명확한 검증

```java
// Step 1: 프로젝트/프리랜서 존재 검증
if (initDTO == null) return error;

// Step 2: PDF 처리 및 AI 분석
if (pdfText == null) fallback to default;

// Step 3: 사용자 수정 정보 준비 (검증 없음)

// Step 4: 최종 검증 후 DB 저장
if (!validateMilestoneBudget(...)) throw exception;
contractMapper.insert(contract); // 유일한 DB 저장 지점
```

---

## 다음 단계

### 🔄 Phase 3: MyBatis 통합 (예정)

```
1. ContractMapper 구현 (인터페이스 → MyBatis XML)
2. ContractMilestoneMapper 구현
3. ContractServiceImpl에서 DB 호출
4. 트랜잭션 처리 (실패 시 rollback)
```

### 🔌 Phase 4: DeepSeek API 통합 (예정)

```java
@Service
@ConditionalOnProperty(name = "ai.service.type", havingValue = "deepseek")
public class DeepSeekAIInsightServiceImpl implements AIInsightService {
    @Value("${DEEPSEEK_API_KEY}")
    private String apiKey;
    
    @Override
    public AIContractInsightDTO analyzeContract(...) {
        // DeepSeek API 호출
        String prompt = buildPrompt(pdfText, projectDTO, freelancerInfo);
        String response = deepseekClient.chat(prompt, apiKey);
        return parseResponse(response);
    }
}
```

### 📊 Phase 5: AI 리포트 생성 (예정)

```java
@PostMapping("/contract/{contractId}/generate-report")
public String generateAIReport(@PathVariable Long contractId) {
    // 1. 계약 정보 조회
    ContractDTO contract = contractMapper.selectById(contractId);
    
    // 2. AI에 리포트 요청
    String report = aiService.generateReport(contract);
    
    // 3. 리포트를 PDF로 저장
    String reportUrl = reportService.savePDF(report);
    
    // 4. contracts.ai_report_url 업데이트
    contractMapper.updateAIReportUrl(contractId, reportUrl);
}
```

### 🔐 Phase 6: 권한 & 감시 (예정)

```java
// 클라이언트만 계약 생성 가능
@GetMapping("/contract/init")
@PreAuthorize("hasRole('CLIENT')")
public String getContractInit(...) { ... }

// 계약 생성 이력 기록
@EventListener
public void logContractCreation(ContractCreatedEvent event) {
    auditLog.save("CONTRACT_CREATED", event.getContractId(), 
                  SecurityContextHolder.getContext().getAuthentication().getName());
}
```

---

## 📌 주요 마일스톤

| 날짜 | 내용 | 상태 |
|------|------|------|
| 2025-01-13 | Phase 1: AI 서비스 설계 | ✅ |
| 2025-01-14 | Phase 2: PDF 처리 + 비즈니스 로직 | ✅ |
| 2025-01-15 | Phase 2: 컨트롤러 + JSP | ✅ |
| 2025-01-16 | Phase 2: 테스트 페이지 | ✅ |
| 2025-01-17 | Phase 3: DB 통합 테스트 | ⏳ |
| 2025-01-20 | Phase 4: DeepSeek 통합 | ⏳ |

---

## 🤔 FAQ

### Q: AI가 틀린 계약 정보를 생성하면?
**A**: 사용자가 contract-review.jsp에서 모든 필드를 수정할 수 있습니다. AI는 조언만 제공합니다.

### Q: Mock AI 없이 실제 DeepSeek만 사용하려면?
**A**: Phase 4에서 `@ConditionalOnProperty`를 사용해 설정으로 전환할 수 있습니다.

### Q: 마일스톤이 없는 일시금 계약도 가능한가?
**A**: 네, `paymentMethod="LUMPSUM"`으로 선택하면 마일스톤 입력을 건너뜁니다.

### Q: PDF 텍스트를 DB에 저장하지 않는 이유?
**A**: 프라이버시 보호 + 계약 내용 변경 추적 불가능 + 저장 공간 절감. 필요시 contract-review.jsp에서 별도 저장.

### Q: 계약 확정 후 수정 가능한가?
**A**: 현재 설계상 불가능합니다. Phase 6에서 계약 수정 승인 프로세스 추가 예정.

---

## 📚 참고 자료

### 관련 테이블 (SANAI DB)

```sql
-- 계약 테이블
CREATE TABLE contracts (
    contract_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    application_id BIGINT NOT NULL UNIQUE,
    total_budget BIGINT NOT NULL,
    payment_method ENUM('LUMPSUM', 'MILESTONE'),
    contract_start_date DATE,
    contract_end_date DATE,
    contract_status ENUM('SIGNED', 'IN_PROGRESS', 'COMPLETED', 'TERMINATED'),
    origin_contract_url VARCHAR(500),
    ai_report_url VARCHAR(500),
    contracted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 마일스톤 테이블
CREATE TABLE contract_milestones (
    milestone_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    contract_id BIGINT NOT NULL,
    step_order INT NOT NULL,
    milestone_name VARCHAR(200),
    amount BIGINT NOT NULL,
    due_date DATE,
    status ENUM('WAITING', 'DEPOSITED', 'REQUESTED', 'PAID', 'CANCELED'),
    FOREIGN KEY (contract_id) REFERENCES contracts(contract_id)
);
```

---

## 🎓 학습 포인트

### 1. 인터페이스 기반 설계
- AI 서비스를 인터페이스로 정의
- Mock과 실제 구현을 교체 가능하게 설계

### 2. 메모리 기반 비즈니스 로직
- 사용자 확정 전까지 DB 저장 X
- 에러 복구 가능한 구조

### 3. 다단계 폼 처리
- JSP with JSTL 사용
- JavaScript로 단계별 UI 관리
- 서버에서 상태 추적

### 4. PDF 처리
- PDFBox로 텍스트 추출
- 임시 파일 관리
- 에러 처리 (암호화, 손상된 파일 등)

### 5. 데이터베이스 설계
- 마일스톤 배치 INSERT
- 예산 검증 (정확히 일치)
- 상태 관리 (enum)

---

**작성자**: AI Assistant  
**마지막 수정**: 2025-01-16  
**버전**: Phase 2.1 (테스트 페이지 완성)

