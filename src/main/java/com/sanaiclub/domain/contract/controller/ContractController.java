package com.sanaiclub.domain.contract.controller;

import com.sanaiclub.domain.contract.dto.*;
import com.sanaiclub.domain.contract.service.ContractService;
import com.sanaiclub.domain.contract.service.PDFProcessingService;
import com.sanaiclub.domain.contract.service.ai.AIInsightService;
import com.sanaiclub.domain.project.dto.ProjectDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * ═══════════════════════════════════════════════════════════════════════════════════════════
 * ContractController - Spring MVC 계약 관리 컨트롤러
 * ═══════════════════════════════════════════════════════════════════════════════════════════
 * 
 * [목표]
 * Spring MVC2 레거시 패턴을 따르며, 계약 생성의 3단계 플로우를 HTTP 요청으로 처리합니다.
 * 이 컨트롤러는 Controller → Service → View 단방향 흐름만 처리하며,
 * 복잡한 로직은 모두 Service 계층으로 위임합니다.
 * 
 * [플로우 경로]
 * ┌─────────────────────────────────────────────────────────────────────────────────────┐
 * │ 1️⃣ 계약 시작 페이지                                                                │
 * │    경로: GET /contract/start                                                        │
 * │    컨트롤러: initializeContract()                                                    │
 * │    · 프로젝트 공지 조회 및 표시                                                      │
 * │    · PDF 업로드 Form 제공                                                           │
 * │    · View: contract-start.jsp                                                       │
 * │    · DB 저장: 없음                                                                   │
 * │                                                                                     │
 * │ 2️⃣ 계약 검토 페이지 (AI 분석 결과)                                                │
 * │    경로: POST /contract/analyze                                                    │
 * │    컨트롤러: analyzeContract()                                                       │
 * │    · PDF 파일 처리 (텍스트 추출)                                                    │
 * │    · Mock AI 호출 (또는 DeepSeek AI)                                               │
 * │    · 계약 초안 데이터 생성                                                           │
 * │    · 모든 필드 수정 가능 상태로 표시                                                 │
 * │    · View: contract-review.jsp                                                     │
 * │    · DB 저장: 없음                                                                   │
 * │                                                                                     │
 * │ 3️⃣ 계약 확정 완료 페이지                                                            │
 * │    경로: POST /contract/confirm                                                    │
 * │    컨트롤러: confirmContract()                                                       │
 * │    · 사용자가 수정한 계약 정보 수신                                                  │
 * │    · DB INSERT 실행 (contracts, contract_milestones)                              │
 * │    · 계약 ID 생성 및 확인 메시지 표시                                               │
 * │    · View: contract-confirm.jsp                                                    │
 * │    · DB 저장: contracts + contract_milestones 테이블에 INSERT ✓                    │
 * └─────────────────────────────────────────────────────────────────────────────────────┘
 * 
 * [핵심 설계 원칙]
 * 1. Controller는 HTTP 요청/응답과 Model 전달만 담당
 * 2. 모든 비즈니스 로직은 Service 계층에 위임
 * 3. JSP는 순수 View 역할만 수행 (최소한의 JavaScript)
 * 4. Step 1-2는 DB 저장하지 않음 (메모리 기반)
 * 5. Step 3에서만 DB INSERT 실행
 * 6. 각 메서드는 단일 책임 원칙(SRP) 준수
 * 7. 에러 발생 시 이전 단계로 복귀 가능하게 설계
 * 
 * [에러 처리 전략]
 * - 프로젝트/프리랜서 없음: 404 또는 에러 페이지
 * - PDF 파일 없음/읽기 실패: 에러 메시지 + 재업로드 요청
 * - AI 분석 실패: MockAI로 자동 폴백
 * - 유효성 검증 실패: 수정 페이지로 다시 이동
 * - DB INSERT 실패: 500 에러 페이지
 * 
 * [테스트 방법]
 * 1. 브라우저에서 GET /contract/start 접속
 * 2. 프로젝트 공지 확인 후 PDF 파일 업로드
 * 3. POST /contract/analyze로 자동 제출
 * 4. AI 분석 결과 검토 및 필드 수정 (선택사항)
 * 5. POST /contract/confirm으로 계약 확정
 * 6. contract-confirm.jsp에서 계약 ID 확인 및 저장 완료 메시지 표시
 */
@Controller
@RequestMapping("/contract")
public class ContractController {
    
    // ════════════════════════════════════════════════════════════════════════════════
    // 의존성 주입 (Dependency Injection)
    // ════════════════════════════════════════════════════════════════════════════════
    
    @Autowired
    private ContractService contractService;
    
    @Autowired
    private PDFProcessingService pdfProcessingService;
    
    @Autowired
    private AIInsightService aiInsightService;
    
    
    // ════════════════════════════════════════════════════════════════════════════════
    // Step 1: 계약 시작 페이지 - 프로젝트 공지 & PDF 업로드
    // ════════════════════════════════════════════════════════════════════════════════
    
    /**
     * [메서드 이름]
     * initializeContract()
     * 
     * [목적]
     * 계약 생성 프로세스의 첫 번째 페이지를 사용자에게 제공합니다.
     * 프로젝트 공지사항을 표시하고, PDF 파일을 업로드받을 폼을 제공합니다.
     * 
     * [요청]
     * GET /contract/start
     * 매개변수 (Query String):
     *   - projectId (Long): 프로젝트 ID
     *   - freelancerId (Long): 프리랜서 ID
     * 
     * [응답]
     * - View: contract-start.jsp (PDF 업로드 폼)
     * - Model: projectInfo, freelancerInfo, uploadSettings
     * 
     * [중요]
     * - 이 단계에서는 DB 저장 없음
     * - 다음 단계: POST /contract/analyze
     * - 폼 제출: <form action="/contract/analyze" method="POST">
     * 
     * [에러 처리]
     * - projectId 또는 freelancerId 없음 → 400 Bad Request
     * - 프로젝트 없음 → 404 Not Found
     * 
     * [협업 주의사항]
     * - Model에 담는 속성명은 JSP에서 사용되므로 변경 시 contract-start.jsp도 수정해야 함
     * - projectInfo.getTitle(), projectInfo.getDescription() 등으로 접근
     * - 프로젝트 정보는 DB에서 조회하거나 테스트 데이터 사용 가능
     */
    @GetMapping("/start")
    public String initializeContract(
            @RequestParam(value = "projectId", required = true) Long projectId,
            @RequestParam(value = "freelancerId", required = true) Long freelancerId,
            Model model
    ) {
        System.out.println("┌─────────────────────────────────────────────────────────┐");
        System.out.println("│ [ContractController] GET /contract/start 요청             │");
        System.out.println("├─────────────────────────────────────────────────────────┤");
        System.out.println("│ · projectId: " + projectId);
        System.out.println("│ · freelancerId: " + freelancerId);
        System.out.println("└─────────────────────────────────────────────────────────┘");
        
        try {
            // ══════════════════════════════════════════════════════════════════════════
            // 1단계: 프로젝트 정보 조회
            // ══════════════════════════════════════════════════════════════════════════
            // TODO: 실제로는 ProjectService를 통해 DB에서 조회
            ProjectDTO projectInfo = new ProjectDTO();
            projectInfo.setProjectId(projectId);
            projectInfo.setTitle("[라테오션 프로젝트] 프리랜서 매칭 플랫폼");
            projectInfo.setDescription("사용자-프리랜서 매칭, 계약 관리, 결제 시스템을 갖춘 종합 플랫폼");
            projectInfo.setBudget(new BigDecimal("50000000")); // 5천만 원
            projectInfo.setCreatedAt(LocalDateTime.now());
            
            // ══════════════════════════════════════════════════════════════════════════
            // 2단계: 프리랜서 정보 조회
            // ══════════════════════════════════════════════════════════════════════════
            // TODO: 실제로는 FreelancerService를 통해 DB에서 조회
            String freelancerName = "[테스트] 홍길동";
            String freelancerEmail = "freelancer@lateocean.com";
            Integer freelancerExperience = 5; // 5년 경력
            
            // ══════════════════════════════════════════════════════════════════════════
            // 3단계: Model에 데이터 추가
            // ══════════════════════════════════════════════════════════════════════════
            model.addAttribute("projectInfo", projectInfo);
            model.addAttribute("freelancerId", freelancerId);
            model.addAttribute("freelancerName", freelancerName);
            model.addAttribute("freelancerEmail", freelancerEmail);
            model.addAttribute("freelancerExperience", freelancerExperience);
            
            // 파일 업로드 설정
            model.addAttribute("maxFileSize", 50 * 1024 * 1024); // 50MB
            model.addAttribute("allowedFormat", "pdf");
            model.addAttribute("allowedMimeType", "application/pdf");
            
            System.out.println("[ContractController] /start 응답: contract-start.jsp");
            return "contract/contract-start";
            
        } catch (Exception e) {
            System.out.println("[ContractController] /start 오류: " + e.getMessage());
            e.printStackTrace();
            model.addAttribute("error", "프로젝트 조회 실패: " + e.getMessage());
            return "error/500";
        }
    }
    
    
    // ════════════════════════════════════════════════════════════════════════════════
    // Step 2: 계약 검토 페이지 - PDF 분석 & AI 인사이트
    // ════════════════════════════════════════════════════════════════════════════════
    
    /**
     * [메서드 이름]
     * analyzeContract()
     * 
     * [목적]
     * 사용자가 업로드한 PDF 파일을 분석하고, AI를 통해 계약 초안을 생성합니다.
     * 생성된 계약 정보는 사용자가 편집할 수 있도록 제시합니다.
     * 
     * [요청]
     * POST /contract/analyze
     * Content-Type: multipart/form-data
     * 폼 데이터:
     *   - pdf (MultipartFile): 업로드된 PDF 파일
     *   - projectId (Long): 프로젝트 ID
     *   - freelancerId (Long): 프리랜서 ID
     * 
     * [응답]
     * - View: contract-review.jsp (AI 분석 결과 및 편집 폼)
     * - Model: aiInsight, projectInfo, editableFields
     * 
     * [중요]
     * - PDF 텍스트는 메모리에만 저장됨 (DB 저장 안 함)
     * - AI 생성 결과는 "제안"이며, 사용자가 모든 필드를 수정 가능
     * - Mock AI 또는 실제 DeepSeek AI를 선택적으로 사용
     * - 다음 단계: POST /contract/confirm
     * 
     * [처리 순서]
     * 1. PDF 파일 임시 저장 (temp 디렉터리)
     * 2. PDFProcessingService로 텍스트 추출
     * 3. ProjectDTO 조회 (또는 수신 데이터 사용)
     * 4. AIInsightService.analyzeContract() 호출
     * 5. 결과를 Model에 추가
     * 6. contract-review.jsp로 렌더링
     * 
     * [에러 처리]
     * - PDF 파일 없음: 사용자 메시지 + contract-start.jsp 재표시
     * - PDF 읽기 실패: 메시지 + 재업로드 유도
     * - AI 분석 실패: MockAI로 폴백
     * 
     * [협업 주의사항]
     * - pdFile.transferTo(tempFile)로 임시 저장
     * - pdfProcessingService.extractText(tempFile)로 텍스트 추출
     * - contractService.analyzeWithAI()가 모든 분석 로직 담당
     * - Model에 담는 속성: insight, projectId, freelancerId
     */
    @PostMapping("/analyze")
    public String analyzeContract(
            @RequestParam(value = "pdf", required = true) MultipartFile pdfFile,
            @RequestParam(value = "projectId", required = true) Long projectId,
            @RequestParam(value = "freelancerId", required = true) Long freelancerId,
            Model model
    ) {
        System.out.println("┌─────────────────────────────────────────────────────────┐");
        System.out.println("│ [ContractController] POST /contract/analyze 요청         │");
        System.out.println("├─────────────────────────────────────────────────────────┤");
        System.out.println("│ · PDF 파일: " + pdfFile.getOriginalFilename());
        System.out.println("│ · 파일 크기: " + (pdfFile.getSize() / 1024) + " KB");
        System.out.println("│ · projectId: " + projectId);
        System.out.println("│ · freelancerId: " + freelancerId);
        System.out.println("└─────────────────────────────────────────────────────────┘");
        
        try {
            // ══════════════════════════════════════════════════════════════════════════
            // 1단계: 입력값 검증
            // ══════════════════════════════════════════════════════════════════════════
            if (pdfFile.isEmpty()) {
                System.out.println("[ContractController] 에러: PDF 파일이 없습니다.");
                model.addAttribute("error", "PDF 파일이 선택되지 않았습니다.");
                return "contract/contract-start"; // 이전 단계로 돌아가기
            }
            
            if (!pdfFile.getOriginalFilename().toLowerCase().endsWith(".pdf")) {
                System.out.println("[ContractController] 에러: PDF가 아닌 파일");
                model.addAttribute("error", "PDF 파일만 업로드 가능합니다.");
                return "contract/contract-start";
            }
            
            // ══════════════════════════════════════════════════════════════════════════
            // 2단계: 프로젝트 정보 조회
            // ══════════════════════════════════════════════════════════════════════════
            // TODO: 실제로는 ProjectService를 통해 DB에서 조회
            ProjectDTO projectDTO = new ProjectDTO();
            projectDTO.setProjectId(projectId);
            projectDTO.setTitle("[라테오션] 프리랜서 매칭 플랫폼");
            projectDTO.setDescription("사용자-프리랜서 매칭, 계약 관리, 결제 시스템");
            projectDTO.setBudget(new BigDecimal("50000000"));
            
            // ══════════════════════════════════════════════════════════════════════════
            // 3단계: ContractService를 통해 AI 분석 실행
            // ══════════════════════════════════════════════════════════════════════════
            // Service는 다음을 수행:
            // - PDF를 임시 파일로 저장
            // - 텍스트 추출
            // - AIInsightService 호출
            // - AIContractInsightDTO 반환
            
            File tempPdf = File.createTempFile("contract_", ".pdf");
            pdfFile.transferTo(tempPdf);
            System.out.println("[ContractController] 임시 PDF 저장: " + tempPdf.getAbsolutePath());
            
            AIContractInsightDTO aiInsight = contractService.analyzeWithAI(
                tempPdf,
                pdfFile.getOriginalFilename(),
                projectDTO,
                "[테스트] 홍길동" // 프리랜서 이름
            );
            
            if (aiInsight == null) {
                System.out.println("[ContractController] 에러: AI 분석 결과 null");
                model.addAttribute("error", "AI 분석 실패. 다시 시도해주세요.");
                model.addAttribute("projectId", projectId);
                model.addAttribute("freelancerId", freelancerId);
                return "contract/contract-start";
            }
            
            // ══════════════════════════════════════════════════════════════════════════
            // 4단계: Model에 데이터 추가
            // ══════════════════════════════════════════════════════════════════════════
            model.addAttribute("insight", aiInsight);
            model.addAttribute("projectId", projectId);
            model.addAttribute("freelancerId", freelancerId);
            model.addAttribute("projectTitle", projectDTO.getTitle());
            model.addAttribute("projectBudget", projectDTO.getBudget());
            model.addAttribute("pdfFilename", pdfFile.getOriginalFilename());
            
            System.out.println("[ContractController] /analyze 완료 → contract-review.jsp");
            return "contract/contract-review";
            
        } catch (Exception e) {
            System.out.println("[ContractController] /analyze 예외: " + e.getMessage());
            e.printStackTrace();
            model.addAttribute("error", "PDF 분석 실패: " + e.getMessage());
            return "error/500";
        }
    }
    
    
    // ════════════════════════════════════════════════════════════════════════════════
    // Step 3: 계약 확정 & DB 저장
    // ════════════════════════════════════════════════════════════════════════════════
    
    /**
     * [메서드 이름]
     * confirmContract()
     * 
     * [목적]
     * 사용자가 검토/편집한 계약 정보를 데이터베이스에 저장하고, 계약 완료 페이지를 표시합니다.
     * 이것이 유일하게 DB에 INSERT를 수행하는 메서드입니다.
     * 
     * [요청]
     * POST /contract/confirm
     * Content-Type: application/x-www-form-urlencoded 또는 multipart/form-data
     * 폼 데이터:
     *   - projectId (Long)
     *   - freelancerId (Long)
     *   - contractStartDate (String: yyyy-MM-dd)
     *   - contractEndDate (String: yyyy-MM-dd)
     *   - totalBudget (Long)
     *   - paymentMethod (String)
     *   - milestones[0].name, milestones[0].amount, milestones[0].dueDate
     *   - milestones[1].name, ... (반복)
     * 
     * [응답]
     * - View: contract-confirm.jsp (성공 메시지)
     * - Model: contractId, projectId, totalBudget, contractedAt
     * 
     * [중요]
     * - 이 메서드는 유일한 DB 저장 지점
     * - @Transactional로 원자성 보장
     * - 유효성 검증은 Service 계층에서 수행
     * - 실패 시 이전 단계로 복귀 불가능 (이미 DB에 저장됨)
     * 
     * [처리 순서]
     * 1. ContractConfirmDTO로 요청 매개변수 수신
     * 2. contractService.confirmContract() 호출
     * 3. Service 내에서:
     *    - 유효성 검증 (예: 총액 > 0)
     *    - ContractDTO 생성
     *    - ContractMapper.insert() 실행 (contracts 테이블)
     *    - contract_id 반환
     *    - 각 마일스톤마다 ContractMilestoneDTO 생성
     *    - ContractMilestoneMapper.batchInsert() 실행
     * 4. 반환된 contract_id를 Model에 추가
     * 5. contract-confirm.jsp로 렌더링
     * 
     * [에러 처리]
     * - 유효성 검증 실패: 400 Bad Request + contract-review.jsp로 복귀
     * - DB INSERT 실패: 500 Internal Server Error
     * - 마일스톤 예산 초과: 경고 메시지 표시 (수정 필요)
     * 
     * [협업 주의사항]
     * - ContractConfirmDTO 필드명과 JSP form input name 일치 필수
     * - milestones는 List<ContractMilestoneDTO>로 자동 바인딩
     * - Spring form binding: <input name="milestones[0].name" />
     * - contractService.confirmContract()가 모든 DB 작업 담당
     * - 데이터 조회/편집 후에는 반드시 contract-confirm.jsp 호출
     */
    @PostMapping("/confirm")
    public String confirmContract(
            @ModelAttribute ContractConfirmDTO confirmDTO,
            Model model
    ) {
        System.out.println("┌─────────────────────────────────────────────────────────┐");
        System.out.println("│ [ContractController] POST /contract/confirm 요청         │");
        System.out.println("├─────────────────────────────────────────────────────────┤");
        System.out.println("│ · projectId: " + confirmDTO.getProjectId());
        System.out.println("│ · totalBudget: " + confirmDTO.getTotalBudget());
        System.out.println("│ · paymentMethod: " + confirmDTO.getPaymentMethod());
        System.out.println("│ · milestones 개수: " + 
            (confirmDTO.getMilestones() != null ? confirmDTO.getMilestones().size() : 0));
        System.out.println("└─────────────────────────────────────────────────────────┘");
        
        try {
            // ══════════════════════════════════════════════════════════════════════════
            // 1단계: 입력값 검증
            // ══════════════════════════════════════════════════════════════════════════
            if (confirmDTO.getTotalBudget() == null || confirmDTO.getTotalBudget() <= 0) {
                System.out.println("[ContractController] 에러: 계약액 유효성 검증 실패");
                model.addAttribute("error", "계약액이 0보다 커야 합니다.");
                model.addAttribute("insight", confirmDTO);
                return "contract/contract-review"; // 수정 페이지로 복귀
            }
            
            if (confirmDTO.getPaymentMethod() == null || confirmDTO.getPaymentMethod().isEmpty()) {
                System.out.println("[ContractController] 에러: 결제 방식 필수");
                model.addAttribute("error", "결제 방식을 선택해주세요.");
                model.addAttribute("insight", confirmDTO);
                return "contract/contract-review";
            }
            
            // ══════════════════════════════════════════════════════════════════════════
            // 2단계: 계약 확정 및 DB 저장
            // ══════════════════════════════════════════════════════════════════════════
            // ContractService.confirmContract()는 다음을 수행:
            // - 전체 유효성 검증
            // - ContractMapper를 통해 contracts 테이블에 INSERT
            // - contract_id 자동 생성
            // - ContractMilestoneMapper를 통해 milestones 테이블에 BATCH INSERT
            // - contract_id 반환
            
            Long contractId = contractService.confirmContract(confirmDTO);
            
            if (contractId == null || contractId <= 0) {
                System.out.println("[ContractController] 에러: 계약 저장 실패");
                model.addAttribute("error", "계약 저장에 실패했습니다.");
                return "error/500";
            }
            
            // ══════════════════════════════════════════════════════════════════════════
            // 3단계: 성공 응답
            // ══════════════════════════════════════════════════════════════════════════
            model.addAttribute("contractId", contractId);
            model.addAttribute("projectId", confirmDTO.getProjectId());
            model.addAttribute("totalBudget", confirmDTO.getTotalBudget());
            model.addAttribute("paymentMethod", confirmDTO.getPaymentMethod());
            model.addAttribute("contractedAt", LocalDateTime.now());
            model.addAttribute("milestonesCount", 
                confirmDTO.getMilestones() != null ? confirmDTO.getMilestones().size() : 0);
            
            System.out.println("[ContractController] /confirm 완료 → contract-confirm.jsp");
            System.out.println("  · 생성된 계약 ID: " + contractId);
            return "contract/contract-confirm";
            
        } catch (IllegalArgumentException e) {
            System.out.println("[ContractController] 유효성 검증 실패: " + e.getMessage());
            model.addAttribute("error", e.getMessage());
            model.addAttribute("insight", confirmDTO);
            return "contract/contract-review"; // 수정 페이지로 복귀
            
        } catch (Exception e) {
            System.out.println("[ContractController] /confirm 예외: " + e.getMessage());
            e.printStackTrace();
            model.addAttribute("error", "계약 저장 실패: " + e.getMessage());
            return "error/500";
        }
    }
}
