# Contract V2 → V3 변경사항 상세 정리

## 📊 전체 통계
- **변경된 파일**: 28개
- **추가된 라인**: +743줄
- **삭제된 라인**: -456줄
- **순 증가**: +287줄
- **주요 커밋**: 8개

---

## 🔄 주요 커밋 내역

1. **2be87cf** - 계약관리 페이지 개선 및 사이드바 변경(마일스톤 책량)
2. **57514ba** - contract작성시 조회로직 합병
3. **7e10326** - 프로젝트, 프리랜서 조회 버그 픽스
4. **b3f3df5** - 불필요한 트랜잭션 로직 삭제 및 코드 경량화
5. **f920fe4** - Feat: 프로젝트 생성 기능 개선 - 스택 레벨/연차 기본값 설정 및 성공 페이지 라우팅 추가
6. **38f8868** - Update: ProjectCreateService modification
7. **40dacc6** - Feat: Contract v2 feature additions and fixes
8. **13f25e3** - Refactor: develop 코드 존중 contract v2 병합

---

## 📝 카테고리별 상세 변경사항

### 1. 계약 관리 페이지 및 사이드바 개선

#### 1.1 계약 분류 로직 대폭 개선 (`ContractService.classifyContractsForClientView`)

**변경 전 (V2)**:
- 단순 상태별 분류 (WAITING, SIGNED, PAID, COMPLETED, TERMINATED)
- PAID 상태를 "정산 대기" 또는 "완료 내역"으로만 구분
- 마일스톤 상태를 고려하지 않은 단순 분류

**변경 후 (V3)**:
- **5단계 세분화된 사이드바 카테고리**:
  1. ⏳ **전송됨** (WAITING) - 프로젝트 READY 상태
  2. ✅ **승인 완료** (SIGNED) - 프로젝트 READY, 결제 대기
  3. 💰 **진행 중** (IN_PROGRESS) - 프로젝트 IN_PROGRESS, 마일스톤 미완료
     - `IN_PROGRESS_DEPOSITED`: 모든 마일스톤 DEPOSITED (에스크로 입금 완료)
     - `IN_PROGRESS_REQUESTED`: REQUESTED 마일스톤 있음 (지급 요청 대기)
     - `IN_PROGRESS_PARTIAL`: 일부 마일스톤 PAID (일부 지급 완료)
  4. ✅ **완료 내역** (COMPLETED_HISTORY) - 프로젝트 CLOSED, 모든 마일스톤 완료
  5. ❌ **종료됨** (TERMINATED)

**주요 개선점**:
- 마일스톤 상태(`depositedMilestones`, `requestedMilestones`, `paidMilestones`)를 기반으로 세분화
- `isFullyCompleted()` 메서드로 완료 여부 정확히 판단
- `LinkedHashMap` 사용으로 사이드바 순서 보장

**코드 위치**: `ContractService.java` 731-845줄

---

#### 1.2 JSP UI 개선 (`contractManagement.jsp`)

**변경 사항**:
1. **사이드바 제목 단순화**:
   - "✅ 프리랜서 승인 완료 (지급 대기 중)" → "✅ 승인 완료"
   - 복잡한 조건문 제거, 명확한 카테고리명 사용

2. **마일스톤 집계 정보 표시 추가**:
   - PAID 상태일 때 마일스톤 집계 카드 표시
   - 전체/입금 완료/지급 요청/지급 완료 건수 시각화
   - 색상 코딩으로 상태 구분 (초록: 완료, 주황: 대기)

3. **마일스톤 상태별 힌트 메시지 추가**:
   - DEPOSITED: "💳 에스크로 입금 완료", "⏳ 프리랜서 지급 요청 대기 중"
   - WAITING: "⏳ 프리랜서 지급 요청 대기 중"
   - PAID: "✅ 지급 완료"
   - REQUESTED: 지급 수락/거부 버튼 표시

4. **상태 표시 메시지 개선**:
   - "✅ 최종 승인 대기" → "✅ 결제 완료"
   - 더 명확한 상태 설명 추가

**코드 위치**: `contractManagement.jsp` 211-627줄

---

### 2. 계약 작성 시 조회 로직 통합 및 개선

#### 2.1 ContractFormController 개선

**변경 사항**:

1. **에러 처리 강화**:
   ```java
   // 변경 전: 단순 null 체크
   if (projectId == null && freelancerId == null) {
       model.addAttribute("errorMessage", "프로젝트와 프리랜서를 모두 선택해주세요.");
   }
   
   // 변경 후: 세분화된 에러 메시지 + 기본 데이터 조회
   if (!model.containsAttribute("errorMessage")) {
       if (projectId == null && freelancerId == null) {
           model.addAttribute("errorMessage", "프로젝트와 프리랜서를 모두 선택해주세요.");
       } else if (projectId == null) {
           model.addAttribute("errorMessage", "프로젝트를 선택해주세요.");
       } else {
           model.addAttribute("errorMessage", "프리랜서를 선택해주세요.");
       }
   }
   ```

2. **에러 상황에서도 기본 데이터 조회**:
   - `prepareErrorViewData()` 메서드 활용
   - 에러 발생 시에도 가능한 데이터만 표시하여 UX 개선

3. **파라미터 추출 로직 개선**:
   - `extractProjectId()`, `extractFreelancerId()` 메서드 개선
   - trim() 처리 추가
   - 더 상세한 에러 메시지 제공

**코드 위치**: `ContractFormController.java` 89-150줄

---

#### 2.2 ContractService 조회 메서드 통합

**변경 사항**:

1. **`prepareErrorViewData()` 메서드 추가**:
   - 에러 상황에서도 기본 데이터 조회 가능
   - null 파라미터 허용

2. **프로젝트 조회 로직 변경**:
   ```java
   // 변경 전: ProjectDetailMapper.selectProjectById() 사용
   public ProjectsVO getProjectById(Integer projectId) {
       return projectDetailMapper.selectProjectById(projectId);
   }
   
   // 변경 후: ProjectDetailMapper.selectProjectDetail() 사용 (develop 코드 존중)
   public ProjectsVO getProjectById(Integer projectId) {
       ProjectDetailDTO projectDetail = projectDetailMapper.selectProjectDetail(projectId);
       if (projectDetail == null) {
           return null;
       }
       return projectDetail; // ProjectDetailDTO는 ProjectsVO를 상속
   }
   ```

3. **프로젝트 목록 조회 로직 변경**:
   ```java
   // 변경 전: ProjectDetailMapper 사용
   return projectDetailMapper.selectProjectsByClientId(clientId);
   
   // 변경 후: ContractMapper 사용 (develop 코드 침범 방지)
   List<ProjectsVO> projects = contractMapper.selectAllProjectsByClientId(clientId);
   ```

4. **프리랜서 목록 조회 로직 변경**:
   ```java
   // 변경 전: ProjectDetailMapper.selectFreelancersByProjectId() 사용
   return projectDetailMapper.selectFreelancersByProjectId(projectId);
   
   // 변경 후: ContractMapper.selectApplicantsByProjectId() 사용
   // project_applications 테이블 기반으로 조회
   // 응답 형식 맞추기 (id 필드 추가)
   ```

**코드 위치**: `ContractService.java` 54-132줄, 646-697줄

---

### 3. 프로젝트/프리랜서 조회 버그 픽스

#### 3.1 ContractMapper 확장

**추가된 메서드**:

1. **`updateProjectStatus()`**:
   - 프로젝트 상태 업데이트
   - payment 도메인에서 사용 (develop 코드 침범 방지)

2. **`selectAllProjectsByClientId()`**:
   - 클라이언트의 모든 프로젝트 목록 조회
   - 계약 여부와 관계없이 READY 상태만 반환

3. **`selectApplicantsByProjectId()`**:
   - 프로젝트에 지원한 프리랜서 목록 조회
   - `project_applications` 테이블 기반
   - PENDING, ACCEPTED 상태만 반환

**코드 위치**: `ContractMapper.java` 75-94줄, `contractMapper.xml` 520-577줄

---

#### 3.2 ProjectDetailMapper 정리

**제거된 메서드** (ContractMapper로 이동):
- `selectProjectById()` → ContractService에서 `selectProjectDetail()` 사용
- `selectProjectsByClientId()` → ContractMapper로 이동
- `selectFreelancersByProjectId()` → ContractMapper로 이동
- `updateProjectStatus()` → ContractMapper로 이동

**목적**: develop 코드 침범 방지, 도메인 경계 명확화

**코드 위치**: `ProjectDetailMapper.java` 전체

---

### 4. 트랜잭션 로직 제거 및 코드 경량화

#### 4.1 지급 관련 메서드 트랜잭션 제거

**변경 전 (V2)**:
```java
@Transactional
public int requestPayment(Integer contractId, Integer step) {
    // 복잡한 상태 검증
    // 트랜잭션 처리
    // 계약 상태 자동 업데이트
}
```

**변경 후 (V3)**:
```java
// @Transactional 제거
public int requestPayment(Integer contractId, Integer step) {
    // 상태 변경만 수행
    // 트랜잭션 처리 없음
}
```

**주요 변경사항**:

1. **`requestPayment()`**:
   - `@Transactional` 제거
   - 계약 상태 검증 제거 (PAID/COMPLETED 체크 제거)
   - 상태 변경만 수행 (WAITING → REQUESTED)

2. **`approvePayment()`**:
   - `@Transactional` 제거
   - 계약 상태 검증 제거
   - 상태 변경: REQUESTED → PAID (변경 전: REQUESTED → DEPOSITED)
   - **중요**: COMPLETED 자동 전환 로직 제거
   - 일시지급: cancel_reason null로 초기화만 수행

3. **`rejectPayment()`**:
   - `@Transactional` 제거
   - 계약 상태 검증 제거
   - 상태 변경: REQUESTED → DEPOSITED (변경 전: REQUESTED → WAITING)
   - 일시지급: cancel_reason null로 초기화만 수행

**영향**:
- 트랜잭션 오버헤드 감소
- 상태 변경 로직 단순화
- 계약 상태 자동 전환은 다른 레이어에서 처리

**코드 위치**: `ContractService.java` 928-1049줄

---

#### 4.2 불필요한 메서드 제거

**제거된 메서드**:

1. **`finalizeContract()`**:
   ```java
   // 제거됨: 단순히 계약 상태를 PAID로 변경하는 메서드
   public void finalizeContract(Integer contractId) {
       contractMapper.updateContractStatus(contractId, ContractStatus.PAID.name(), null);
   }
   ```

2. **`completeContract()`**:
   ```java
   // 제거됨: 계약 상태를 COMPLETED로 변경하는 메서드
   @Transactional
   public void completeContract(Integer contractId) {
       contractMapper.updateContractStatus(contractId, ContractStatus.COMPLETED.name(), null);
   }
   ```

**제거된 컨트롤러 엔드포인트**:
- `POST /client/contract/management/finalize` 제거
- `POST /client/contract/management/complete` 제거

**코드 위치**: `ContractService.java` 225-243줄 (제거), `ClientContractManagementController.java` 161-174줄 (제거)

---

### 5. 결제 처리 로직 개선

#### 5.1 PaymentServiceImpl 상세 로깅 추가

**변경 사항**:

1. **단계별 상세 로깅**:
   ```java
   logger.info("=== 결제 완료 처리 시작: impUid={} ===", request.getImpUid());
   logger.info("[1단계] 포트원 API 결제 정보 조회 시작");
   logger.info("[2단계] 계약 ID 추출 완료: contractId={}", contractId);
   logger.info("[3단계] 계약 정보 조회 완료: contractId={}, 현재 상태={}", ...);
   // ... 8단계까지 상세 로깅
   ```

2. **계약 상태 검증 추가**:
   ```java
   // 계약 상태 검증 (SIGNED 상태여야 결제 가능)
   if (!ContractStatus.SIGNED.equals(contract.getContractStatus())) {
       throw new IllegalStateException(
           String.format("결제 가능한 상태가 아닙니다. 현재 상태: %s (예상: SIGNED)", 
               contract.getContractStatus()));
   }
   ```

3. **마일스톤 상태 변경 로깅 강화**:
   - 각 마일스톤별 상태 변경 로깅
   - 업데이트된 마일스톤 개수 로깅

4. **DB 상태 변화 요약 로깅**:
   ```java
   logger.info("=== DB 상태 변화 요약 ===");
   logger.info("  - 결제 정보: INSERT 완료 (paymentId={})", payment.getPaymentId());
   logger.info("  - 마일스톤 상태: {}개 마일스톤 WAITING → DEPOSITED", milestones.size());
   logger.info("  - 계약 상태: SIGNED → PAID");
   logger.info("  - 프로젝트 상태: READY → IN_PROGRESS");
   ```

5. **프로젝트 상태 업데이트 로직 개선**:
   ```java
   // 변경 전: ProjectDetailMapper 사용
   projectDetailMapper.updateProjectStatus(...);
   
   // 변경 후: ContractMapper 사용 (develop 코드 침범 방지)
   contractMapper.updateProjectStatus(...);
   ```

**코드 위치**: `PaymentServiceImpl.java` 92-230줄

---

#### 5.2 PortoneApiClient 에러 처리 강화

**변경 사항**:

1. **URL 검증 추가**:
   ```java
   // URL 검증
   if (apiUrl == null || apiUrl.trim().isEmpty()) {
       logger.error("포트원 API URL이 설정되지 않았습니다.");
       throw new IllegalStateException("포트원 API URL 없음");
   }
   ```

2. **API Key/Secret 검증 추가**:
   ```java
   if (apiKey == null || apiKey.trim().isEmpty() || apiSecret == null || apiSecret.trim().isEmpty()) {
       logger.error("포트원 API 인증 정보가 설정되지 않았습니다.");
       throw new IllegalStateException("포트원 API 인증 정보 없음");
   }
   ```

3. **에러 응답 상세 처리**:
   - 401 Unauthorized 오류 시 더 명확한 메시지 제공
   - JSON 응답 파싱 시도
   - 에러 응답 본문 로깅

4. **URL 형식 검증**:
   ```java
   // URL 형식 검증 (프로토콜 포함 여부)
   if (!urlString.trim().startsWith("http://") && !urlString.trim().startsWith("https://")) {
       throw new IllegalArgumentException("URL 형식 오류: 프로토콜이 필요합니다.");
   }
   ```

**코드 위치**: `PortoneApiClient.java` 85-420줄

---

### 6. 프리랜서 계약 목록 UI 개선

#### 6.1 freelancerContractList.jsp 개선

**변경 사항**:

1. **PAID 상태 제목 표시 추가**:
   ```jsp
   <c:when test="${statusEntry.key eq 'PAID'}">
       <jsp:include page="includes/statusTitlePaidFreelancer.jsp"/>
   </c:when>
   ```

2. **마일스톤 집계 정보 표시** (클라이언트와 동일):
   - 전체/입금 완료/지급 요청/지급 완료 건수 시각화

3. **마일스톤 상태별 버튼 및 힌트 추가**:
   - **WAITING 상태**: 지급 요청 버튼 (결제 전)
   - **DEPOSITED 상태**: 지급 요청 버튼 + "💳 에스크로 입금 완료" 힌트
   - **REQUESTED 상태**: "⏳ 클라이언트 승인 대기 중" 힌트
   - **PAID 상태**: "✅ 지급 완료" 힌트

4. **상태 메시지 개선**:
   - "입금 완료" → "에스크로 입금 완료 - 지급 요청 가능"

**코드 위치**: `freelancerContractList.jsp` 202-650줄

---

### 7. ClientDashboardController 정리

#### 7.1 불필요한 의존성 제거

**변경 사항**:

1. **ClientDashboardService 의존성 제거**:
   ```java
   // 변경 전
   @RequiredArgsConstructor
   public class ClientDashboardController {
       private final ClientDashboardService clientDashboardService;
   }
   
   // 변경 후
   public class ClientDashboardController {
       // 의존성 제거
   }
   ```

2. **계약 관리 페이지 엔드포인트 제거**:
   - `GET /client/contracts` 엔드포인트 제거
   - 계약 관리는 `/client/contract/management`로 통합

**목적**: 코드 중복 제거, 책임 분리

**코드 위치**: `ClientDashboardController.java` 전체

---

### 8. 기타 변경사항

#### 8.1 한글 인코딩 처리 개선

**변경 사항**:
- `fixEncoding()` 메서드 강화 (이미 V2에 존재하지만 개선)
- 깨진 문자 감지 및 복구 로직 개선
- 30% 이상 깨진 문자면 빈 문자열 반환

**코드 위치**: `ContractService.java` 1058-1119줄

---

#### 8.2 Import 정리

**변경 사항**:
- `FreelancerProfileVO` import 제거 (사용하지 않음)
- `ProjectDetailDTO` import 추가
- `LinkedHashMap` import 추가

**코드 위치**: `ContractService.java` 1-26줄

---

#### 8.3 MyBatis Mapper XML 개선

**변경 사항**:
- 불필요한 공백 제거
- 주석 정리
- 새로운 쿼리 추가 (프로젝트 상태 업데이트, 프로젝트 목록 조회, 프리랜서 목록 조회)

**코드 위치**: `contractMapper.xml` 전체

---

#### 8.4 ProjectDetailMapper XML 정리

**변경 사항**:
- ContractMapper로 이동한 쿼리 제거
- `selectProjectDetail` 쿼리만 유지

**코드 위치**: `ProjectDetailMapper.xml` 전체

---

## 🔍 주요 아키텍처 변경사항

### 1. 도메인 경계 명확화

**변경 전**:
- Contract 도메인에서 ProjectDetailMapper 직접 사용
- develop 브랜치 코드 침범

**변경 후**:
- ContractMapper에 필요한 메서드 추가
- develop 브랜치 코드 존중
- 도메인 경계 명확화

### 2. 트랜잭션 책임 분리

**변경 전**:
- 지급 요청/수락/거부에서 트랜잭션 처리
- 계약 상태 자동 전환

**변경 후**:
- 상태 변경만 수행
- 트랜잭션은 상위 레이어에서 처리
- 단순하고 명확한 책임

### 3. 에러 처리 개선

**변경 전**:
- 단순 null 체크
- 에러 발생 시 데이터 미표시

**변경 후**:
- 세분화된 에러 메시지
- 에러 상황에서도 가능한 데이터 표시
- 더 나은 UX

---

## 📈 성능 및 코드 품질 개선

### 1. 코드 라인 수
- **삭제**: 456줄 (불필요한 코드 제거)
- **추가**: 743줄 (기능 개선 및 로깅)
- **순 증가**: 287줄

### 2. 복잡도 감소
- 트랜잭션 로직 제거로 메서드 복잡도 감소
- 단순한 상태 변경 로직으로 가독성 향상

### 3. 유지보수성 향상
- 도메인 경계 명확화
- 책임 분리
- 상세한 로깅으로 디버깅 용이

---

## 🎯 주요 개선 효과

1. **사용자 경험 개선**:
   - 계약 상태를 5단계로 세분화하여 명확한 상태 표시
   - 마일스톤 집계 정보 시각화
   - 에러 상황에서도 기본 데이터 표시

2. **코드 품질 향상**:
   - 도메인 경계 명확화
   - 불필요한 트랜잭션 제거
   - 에러 처리 강화

3. **유지보수성 향상**:
   - develop 브랜치 코드 존중
   - 상세한 로깅
   - 명확한 책임 분리

4. **성능 개선**:
   - 트랜잭션 오버헤드 감소
   - 불필요한 코드 제거

---

## 📌 주의사항

1. **지급 수락 로직 변경**:
   - V2: REQUESTED → DEPOSITED
   - V3: REQUESTED → PAID
   - **중요**: COMPLETED 자동 전환 로직 제거됨

2. **지급 거부 로직 변경**:
   - V2: REQUESTED → WAITING
   - V3: REQUESTED → DEPOSITED
   - 에스크로 시스템 특성 반영

3. **프로젝트 조회 로직 변경**:
   - ProjectDetailMapper → ContractMapper 사용
   - develop 브랜치 코드 침범 방지

4. **트랜잭션 제거**:
   - 지급 관련 메서드에서 `@Transactional` 제거
   - 상태 변경만 수행
   - 트랜잭션은 상위 레이어에서 처리 필요

---

## 🔗 관련 파일 목록

### Java 파일
1. `ContractService.java` - 주요 로직 개선
2. `ClientContractManagementController.java` - 불필요한 엔드포인트 제거
3. `ContractFormController.java` - 에러 처리 강화
4. `ContractMapper.java` - 새로운 메서드 추가
5. `PaymentServiceImpl.java` - 상세 로깅 추가
6. `PortoneApiClient.java` - 에러 처리 강화
7. `ProjectDetailMapper.java` - 메서드 제거
8. `ClientDashboardController.java` - 의존성 제거

### JSP 파일
1. `contractManagement.jsp` - UI 개선
2. `freelancerContractList.jsp` - UI 개선
3. `contractForm.jsp` - 에러 처리 개선

### XML 파일
1. `contractMapper.xml` - 새로운 쿼리 추가
2. `ProjectDetailMapper.xml` - 쿼리 제거

---

## 📝 결론

Contract V3는 V2 대비 다음과 같은 주요 개선을 이루었습니다:

1. **사용자 경험**: 계약 상태를 5단계로 세분화하여 명확한 상태 표시
2. **코드 품질**: 도메인 경계 명확화, 불필요한 코드 제거
3. **유지보수성**: develop 브랜치 코드 존중, 상세한 로깅
4. **성능**: 트랜잭션 오버헤드 감소

특히 계약 관리 페이지의 사이드바 개선과 마일스톤 집계 정보 시각화는 사용자가 계약 상태를 더 쉽게 이해할 수 있도록 도와줍니다.
