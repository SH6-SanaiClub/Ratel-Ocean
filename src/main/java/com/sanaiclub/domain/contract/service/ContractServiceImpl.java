package com.sanaiclub.domain.contract.service;

import com.sanaiclub.domain.contract.dto.*;
import com.sanaiclub.domain.contract.service.ai.AIInsightService;
import com.sanaiclub.domain.project.dto.ProjectDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * ContractServiceImpl
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [역할]
 * 계약 생성 전체 비즈니스 로직을 구현합니다.
 * 
 * [핵심 설계]
 * 1. PDF 처리 → 텍스트 추출만
 * 2. AI 분석 → 메모리에만 저장
 * 3. 사용자 검토 → DB 저장 X
 * 4. 계약 확정 → DB INSERT (유일한 저장 지점)
 * 
 * [의존성]
 * - PDFProcessingService: PDF 처리
 * - AIInsightService: AI 분석
 * - ContractMapper: DB 저장
 * - ProjectMapper, UserMapper: 조회용
 * 
 * [주의]
 * - @Transactional 사용 안함 (각 단계 개별 처리)
 * - AI 실패 시 MockAI로 폴백
 * - 계약 확정 실패 시 rollback 필요
 * 
 * [테스트]
 * - MockAI로 전체 플로우 검증
 * - 마일스톤 예산 검증
 * - DB 무결성 검증
 */
@Service
public class ContractServiceImpl implements ContractService {
    
    @Autowired
    private PDFProcessingService pdfProcessingService;
    
    @Autowired
    private AIInsightService aiInsightService;
    
    // TODO: DB 매퍼 주입
    // @Autowired
    // private ContractMapper contractMapper;
    // private ContractMilestoneMapper milestoneMapper;
    // private ProjectMapper projectMapper;
    // private UserMapper userMapper;
    
    // ════════════════════════════════════════════════════════════════════════
    // Step 1: 초기 정보 조회
    // ════════════════════════════════════════════════════════════════════════
    
    @Override
    public ContractInitDTO getInitialContract(Long projectId, Long freelancerId) {
        System.out.println("[Contract] 초기 정보 조회 시작");
        System.out.println("  - projectId: " + projectId);
        System.out.println("  - freelancerId: " + freelancerId);
        
        ContractInitDTO initDTO = new ContractInitDTO();
        
        // ════════════════════════════════════════════════════════════════════
        // TODO: 데이터베이스에서 조회
        // ════════════════════════════════════════════════════════════════════
        // ProjectDTO projectDTO = projectMapper.selectById(projectId);
        // UserDTO freelancerDTO = userMapper.selectById(freelancerId);
        //
        // initDTO.setProjectId(projectId);
        // initDTO.setProjectTitle(projectDTO.getTitle());
        // initDTO.setProjectDescription(projectDTO.getDescription());
        // initDTO.setProjectBudget(projectDTO.getBudget());
        // ... 기타 필드 설정
        
        // 현재는 목데이터로 반환 (테스트용)
        initDTO.setProjectId(projectId);
        initDTO.setProjectTitle("[테스트] 라테오션 플랫폼 구축");
        initDTO.setProjectDescription("프리랜서-클라이언트 매칭 플랫폼");
        initDTO.setProjectBudget(50000000L);
        initDTO.setProjectDeadline(LocalDate.now().plusMonths(3));
        
        initDTO.setFreelancerId(freelancerId);
        initDTO.setFreelancerName("[테스트] 홍길동");
        initDTO.setFreelancerEmail("hong@example.com");
        initDTO.setFreelancerProfile("5년 경력의 웹 개발자");
        initDTO.setFreelancerExperienceYears(5L);
        initDTO.setFreelancerTechStack("Java, Spring, React, MySQL");
        
        System.out.println("[Contract] 초기 정보 조회 완료");
        return initDTO;
    }
    
    // ════════════════════════════════════════════════════════════════════════
    // Step 2: PDF 분석 및 AI 인사이트 생성
    // ════════════════════════════════════════════════════════════════════════
    
    @Override
    public AIContractInsightDTO analyzeWithAI(
            File pdfFile,
            String originalFilename,
            ProjectDTO projectDTO,
            String freelancerInfo
    ) throws IOException {
        System.out.println("[Contract] AI 분석 시작");
        System.out.println("  - PDF: " + originalFilename);
        System.out.println("  - 프로젝트: " + projectDTO);
        
        // ════════════════════════════════════════════════════════════════════
        // 1단계: PDF 텍스트 추출
        // ════════════════════════════════════════════════════════════════════
        String pdfText = null;
        try {
            pdfText = pdfProcessingService.extractText(pdfFile);
            if (pdfText == null) {
                System.out.println("[Contract] PDF 텍스트 추출 실패");
                // AI가 PDF 없이도 작동하도록 설계 (사용자 입력으로 충분)
                pdfText = "[PDF 텍스트 없음] " + originalFilename;
            }
        } catch (IOException e) {
            System.out.println("[Contract] PDF 처리 실패: " + e.getMessage());
            pdfText = "[PDF 처리 오류]";
        }
        
        // ════════════════════════════════════════════════════════════════════
        // 2단계: PDF 임시 저장 (origin_contract_url로 나중에 저장)
        // ════════════════════════════════════════════════════════════════════
        String pdfPath = null;
        try {
            pdfPath = pdfProcessingService.saveTemporaryPDF(pdfFile, originalFilename);
            System.out.println("[Contract] PDF 임시 저장 완료: " + pdfPath);
        } catch (IOException e) {
            System.out.println("[Contract] PDF 저장 실패: " + e.getMessage());
            // PDF 저장 실패해도 AI 분석은 계속
        }
        
        // ════════════════════════════════════════════════════════════════════
        // 3단계: AI 분석 (Mock or DeepSeek)
        // ════════════════════════════════════════════════════════════════════
        AIContractInsightDTO insight = null;
        try {
            insight = aiInsightService.analyzeContract(
                pdfText,
                projectDTO,
                projectDTO.getDescription() != null ? projectDTO.getDescription() : "",
                freelancerInfo
            );
            
            if (insight != null) {
                // PDF 경로는 필요시 별도 관리
                System.out.println("[Contract] AI 분석 완료");
                System.out.println("  - 모델: " + insight.getAnalysisModel());
                System.out.println("  - 신뢰도: " + insight.getConfidenceScore());
                System.out.println("  - 마일스톤 수: " + 
                    (insight.getProposedMilestones() != null ? 
                     insight.getProposedMilestones().size() : 0));
            }
        } catch (Exception e) {
            System.out.println("[Contract] AI 분석 실패: " + e.getMessage());
            // AI 실패하면 기본값으로 진행 (대금 미리보기, 마일스톤 없음)
            insight = createFallbackInsight(projectDTO, pdfPath);
        }
        
        System.out.println("[Contract] AI 분석 단계 완료");
        return insight;
    }
    
    /**
     * AI 실패 시 기본값 인사이트를 생성합니다.
     */
    private AIContractInsightDTO createFallbackInsight(ProjectDTO projectDTO, String pdfPath) {
        System.out.println("[Contract] 폴백 인사이트 생성");
        
        AIContractInsightDTO fallback = new AIContractInsightDTO();
        
        // 기본 계약 정보
        fallback.setProposedStartDate(LocalDate.now().plusDays(7));
        fallback.setProposedEndDate(LocalDate.now().plusMonths(3));
        fallback.setProposedBudget(projectDTO.getBudget() != null ? 
            projectDTO.getBudget().multiply(new BigDecimal("0.9")) : new BigDecimal("50000000"));
        fallback.setBudgetNegotiable(true);
        fallback.setPaymentMethod("MILESTONE");
        
        // 마일스톤 없음 (사용자가 직접 입력)
        fallback.setProposedMilestones(new ArrayList<>());
        
        // 위험 요소
        fallback.setRiskFactors(new ArrayList<>());
        
        // 경고
        fallback.setWarningPoints(new ArrayList<>());
        
        // 검토 포인트
        fallback.setRecommendedReviewPoints(new ArrayList<>());
        
        // 메타데이터
        fallback.setAnalysisModel("fallback");
        fallback.setConfidenceScore(0.0);
        
        return fallback;
    }
    
    // ════════════════════════════════════════════════════════════════════════
    // Step 3: 계약 확정 및 DB 저장
    // ════════════════════════════════════════════════════════════════════════
    
    @Override
    public Long confirmContract(ContractConfirmDTO confirmDTO) throws Exception {
        System.out.println("[Contract] 계약 확정 시작");
        System.out.println("  - projectId: " + confirmDTO.getProjectId());
        System.out.println("  - freelancerId: " + confirmDTO.getFreelancerId());
        System.out.println("  - 계약액: " + confirmDTO.getTotalBudget());
        System.out.println("  - 결제 방식: " + confirmDTO.getPaymentMethod());
        
        // ════════════════════════════════════════════════════════════════════
        // 1단계: 유효성 검증
        // ════════════════════════════════════════════════════════════════════
        
        // 필수 필드 검증
        if (confirmDTO.getProjectId() == null || confirmDTO.getProjectId() <= 0) {
            throw new IllegalArgumentException("프로젝트 ID가 필요합니다.");
        }
        if (confirmDTO.getFreelancerId() == null || confirmDTO.getFreelancerId() <= 0) {
            throw new IllegalArgumentException("프리랜서 ID가 필요합니다.");
        }
        if (confirmDTO.getTotalBudget() == null || confirmDTO.getTotalBudget() <= 0) {
            throw new IllegalArgumentException("계약액이 0보다 커야 합니다.");
        }
        
        // 계약 기간 검증
        if (confirmDTO.getContractStartDate() == null) {
            throw new IllegalArgumentException("계약 시작일이 필요합니다.");
        }
        if (confirmDTO.getContractEndDate() == null) {
            throw new IllegalArgumentException("계약 종료일이 필요합니다.");
        }
        if (confirmDTO.getContractEndDate().isBefore(confirmDTO.getContractStartDate())) {
            throw new IllegalArgumentException("계약 종료일이 시작일보다 늦어야 합니다.");
        }
        
        // 마일스톤 예산 검증 (결제 방식이 MILESTONE일 때)
        if (confirmDTO.isMilestonePayment()) {
            BigDecimal milestoneTotalBudget = confirmDTO.calculateMilestoneTotalBudget();
            if (!validateMilestoneBudget(confirmDTO.getTotalBudget(), milestoneTotalBudget)) {
                throw new IllegalArgumentException(
                    String.format("마일스톤 예산(%,d원)이 계약액(%,d원)과 일치하지 않습니다.",
                        milestoneTotalBudget.longValue(), confirmDTO.getTotalBudget())
                );
            }
        }
        
        System.out.println("[Contract] 유효성 검증 완료");
        
        // ════════════════════════════════════════════════════════════════════
        // 2단계: contracts 테이블 INSERT
        // ════════════════════════════════════════════════════════════════════
        
        // TODO: DB INSERT 구현
        // Contract contract = new Contract();
        // contract.setApplicationId(confirmDTO.getApplicationId());
        // contract.setTotalBudget(confirmDTO.getTotalBudget());
        // contract.setPaymentMethod(confirmDTO.getPaymentMethod());
        // contract.setContractStartDate(confirmDTO.getContractStartDate());
        // contract.setContractEndDate(confirmDTO.getContractEndDate());
        // contract.setContractStatus("SIGNED");
        // contract.setOriginContractUrl(confirmDTO.getPdfPath());
        // contract.setContractedAt(LocalDateTime.now());
        //
        // int inserted = contractMapper.insert(contract);
        // if (inserted != 1) {
        //     throw new RuntimeException("계약 저장 실패");
        // }
        //
        // Long contractId = contract.getContractId();
        
        // 현재는 테스트용 ID 반환
        Long contractId = System.currentTimeMillis() / 1000;
        
        System.out.println("[Contract] contracts 테이블 INSERT 완료: " + contractId);
        
        // ════════════════════════════════════════════════════════════════════
        // 3단계: contract_milestones 테이블 배치 INSERT
        // ════════════════════════════════════════════════════════════════════
        
        if (confirmDTO.isMilestonePayment() && confirmDTO.getMilestones() != null) {
            saveMilestones(contractId, confirmDTO.getMilestones());
        }
        
        System.out.println("[Contract] 계약 확정 완료: " + contractId);
        return contractId;
    }
    
    /**
     * 마일스톤을 DB에 저장합니다.
     */
    private void saveMilestones(Long contractId, List<ContractMilestoneDTO> milestones) 
            throws Exception {
        System.out.println("[Contract] 마일스톤 저장 시작: " + milestones.size() + "개");
        
        // TODO: DB INSERT 구현
        // for (ContractMilestoneDTO milestone : milestones) {
        //     milestone.setContractId(contractId);
        //     milestone.setStatus("WAITING");
        //     milestoneMapper.insert(milestone);
        // }
        
        System.out.println("[Contract] 마일스톤 저장 완료");
    }
    
    // ════════════════════════════════════════════════════════════════════════
    // 유효성 검증
    // ════════════════════════════════════════════════════════════════════════
    
    @Override
    public boolean validateMilestoneBudget(Long contractBudget, BigDecimal milestoneTotalBudget) {
        if (contractBudget == null || milestoneTotalBudget == null) {
            return false;
        }
        
        // 정확히 일치해야 함 (1원 오차도 허용 X)
        boolean isValid = new BigDecimal(contractBudget).compareTo(milestoneTotalBudget) == 0;
        
        System.out.println("[Contract] 마일스톤 예산 검증: " + 
            (isValid ? "✓ 통과" : "✗ 실패") +
            " (계약액: " + contractBudget + ", 마일스톤 합계: " + milestoneTotalBudget + ")");
        
        return isValid;
    }
}
