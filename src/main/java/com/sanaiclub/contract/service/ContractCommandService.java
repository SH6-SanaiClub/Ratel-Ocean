package com.sanaiclub.contract.service;

import com.sanaiclub.contract.model.vo.ContractVO;
import com.sanaiclub.contract.model.vo.ContractMilestoneVO;
import com.sanaiclub.contract.model.dto.ContractCreateRequestDTO;
import com.sanaiclub.contract.model.dto.ContractUpdateRequestDTO;
import com.sanaiclub.contract.model.dto.ContractMilestoneRequestDTO;
import com.sanaiclub.contract.model.enums.ContractStatus;
import com.sanaiclub.contract.model.enums.MilestoneStatus;
import com.sanaiclub.contract.dao.ContractMapper;
import com.sanaiclub.contract.dao.ContractMilestoneMapper;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/** 계약 명령 전용 서비스 */
@Service
public class ContractCommandService {
    
    private static final Logger logger = LoggerFactory.getLogger(ContractCommandService.class);
    
    private final ContractMapper contractMapper;
    private final ContractMilestoneMapper contractMilestoneMapper;
    
    public ContractCommandService(
            ContractMapper contractMapper,
            ContractMilestoneMapper contractMilestoneMapper
    ) {
        this.contractMapper = contractMapper;
        this.contractMilestoneMapper = contractMilestoneMapper;
    }
    
    /** 계약 생성 */
    @Transactional
    public Integer createContract(ContractCreateRequestDTO dto) {
        // 계약 상태 설정: DTO에 상태가 없으면 기본값 WAITING 사용
        ContractStatus contractStatus = dto.getContractStatus() != null 
            ? dto.getContractStatus() 
            : ContractStatus.WAITING;
        
        // 계약 체결 시각 설정: 현재 시간을 문자열로 변환
        String contractedAt = java.time.LocalDateTime.now()
            .toString()
            .substring(0, 19)
            .replace('T', ' ');
        
        // ContractVO 객체 생성
        ContractVO contract = ContractVO.builder()
            .contractStartDate(dto.getContractStartDate())
            .contractEndDate(dto.getContractEndDate())
            .totalBudget(dto.getTotalBudget())
            .paymentMethod(dto.getPaymentMethod())
            .contractStatus(contractStatus)
            .originContractUrl(dto.getOriginContractUrl())
            .contractedAt(contractedAt)
            .build();
        
        logger.debug("계약 생성 - originContractUrl: {}, freelancerId: {}", 
                dto.getOriginContractUrl(), dto.getFreelancerId());
        
        // 계약 정보 저장
        java.util.Map<String, Object> resultMap = new java.util.HashMap<>();
        contractMapper.insertContract(contract, resultMap);
        
        // 생성된 계약 ID 추출
        Integer contractId = contract.getContractId();
        
        if (contractId == null) {
            logger.error("계약 생성 실패: contractId가 null입니다. contract: {}, resultMap: {}", contract, resultMap);
            throw new IllegalStateException("계약 생성 실패: contractId를 가져올 수 없습니다.");
        }
        
        logger.debug("계약 생성 성공: contractId={}, paymentMethod={}, milestones 수={}", 
                contractId, 
                dto.getPaymentMethod(),
                dto.getMilestones() != null ? dto.getMilestones().size() : 0);
        
        // 마일스톤 저장 (조건부)
        if (dto.getMilestones() != null && !dto.getMilestones().isEmpty() && contractId != null) {
            logger.debug("마일스톤 저장 시작: contractId={}, 마일스톤 수={}", contractId, dto.getMilestones().size());
            int savedCount = 0;
            for (ContractMilestoneRequestDTO milestoneDto : dto.getMilestones()) {
                try {
                    contractMilestoneMapper.insertMilestone(
                        contractId,
                        milestoneDto.getStep(),
                        milestoneDto.getTitle(),
                        milestoneDto.getDescription(),
                        milestoneDto.getAmount()
                    );
                    savedCount++;
                    logger.debug("마일스톤 저장 성공: contractId={}, step={}, title={}, amount={}", 
                            contractId, milestoneDto.getStep(), milestoneDto.getTitle(), milestoneDto.getAmount());
                } catch (Exception e) {
                    logger.error("마일스톤 저장 실패: contractId={}, step={}, title={}", 
                            contractId, milestoneDto.getStep(), milestoneDto.getTitle(), e);
                    throw new IllegalStateException("마일스톤 저장 실패: " + e.getMessage(), e);
                }
            }
            logger.info("마일스톤 저장 완료: contractId={}, 저장된 마일스톤 수={}/{}", 
                    contractId, savedCount, dto.getMilestones().size());
        } else {
            if (dto.getMilestones() == null) {
                logger.debug("마일스톤 저장 건너뜀: milestones가 null입니다. paymentMethod={}", dto.getPaymentMethod());
            } else if (dto.getMilestones().isEmpty()) {
                logger.debug("마일스톤 저장 건너뜀: milestones가 비어있습니다. paymentMethod={}", dto.getPaymentMethod());
            } else if (contractId == null) {
                logger.error("마일스톤 저장 건너뜀: contractId가 null입니다!");
            }
        }
        
        return contractId;
    }
    
    /** 계약 정보 업데이트. 기존 마일스톤 삭제 후 새 마일스톤으로 교체. */
    @Transactional
    public void updateContract(ContractUpdateRequestDTO dto) {
        // 계약 상태 설정
        ContractStatus contractStatus = dto.getContractStatus() != null 
            ? dto.getContractStatus() 
            : ContractStatus.WAITING;
        
        // 기존 계약 조회
        ContractVO existingContract = contractMapper.selectContractById(dto.getContractId());
        if (existingContract == null) {
            throw new IllegalStateException("계약을 찾을 수 없습니다: " + dto.getContractId());
        }
        
        // DTO → VO 변환 (기존 값 유지)
        ContractVO contract = ContractVO.builder()
            .contractId(dto.getContractId())
            .contractStartDate(dto.getContractStartDate())
            .contractEndDate(dto.getContractEndDate())
            .totalBudget(dto.getTotalBudget())
            .paymentMethod(dto.getPaymentMethod())
            .contractStatus(contractStatus)
            .originContractUrl(dto.getOriginContractUrl())
            .platformContractUrl(existingContract.getPlatformContractUrl())
            .aiReportUrl(existingContract.getAiReportUrl())
            .contractedAt(existingContract.getContractedAt())
            .completedAt(existingContract.getCompletedAt())
            .cancelReason(existingContract.getCancelReason())
            .clientRating(existingContract.getClientRating())
            .clientExperience(existingContract.getClientExperience())
            .clientIsRenewalIntended(existingContract.getClientIsRenewalIntended())
            .freelancerRating(existingContract.getFreelancerRating())
            .freelancerExperience(existingContract.getFreelancerExperience())
            .build();
        
        // 기존 마일스톤 삭제
        contractMilestoneMapper.deleteMilestonesByContractId(dto.getContractId());
        
        // 계약 정보 업데이트
        contractMapper.updateContract(contract);
        
        // 새로운 마일스톤 추가
        if (dto.getMilestones() != null && !dto.getMilestones().isEmpty()) {
            for (ContractMilestoneRequestDTO milestoneDto : dto.getMilestones()) {
                contractMilestoneMapper.insertMilestone(
                    dto.getContractId(),
                    milestoneDto.getStep(),
                    milestoneDto.getTitle(),
                    milestoneDto.getDescription(),
                    milestoneDto.getAmount()
                );
            }
        }
    }
    
    /** 계약 수락. WAITING → SIGNED. */
    @Transactional
    public void acceptContract(Integer contractId, Integer freelancerId) {
        contractMapper.updateContractStatus(contractId, ContractStatus.SIGNED.name(), null);
    }
    
    /** 계약 거절. WAITING → TERMINATED, 거절 사유 저장. */
    @Transactional
    public void rejectContract(Integer contractId, Integer freelancerId, String reason) {
        String prefixedReason = (reason != null && !reason.trim().isEmpty()) 
            ? (reason.startsWith("[거절] ") ? reason : "[거절] " + reason)
            : "[거절] 사유 없음";
        contractMapper.updateContractStatus(contractId, ContractStatus.TERMINATED.name(), prefixedReason);
    }
    
    /** 계약 결제 완료. SIGNED → PAID, 에스크로 확보. */
    @Transactional
    public void finalizeContract(Integer contractId) {
        contractMapper.updateContractStatus(contractId, ContractStatus.PAID.name(), null);
    }
    
    /** 계약 정산 완료. PAID → COMPLETED. */
    @Transactional
    public void completeContract(Integer contractId) {
        contractMapper.updateContractStatus(contractId, ContractStatus.COMPLETED.name(), null);
    }
    
    /** 계약 취소. → TERMINATED, 취소 사유 저장. */
    @Transactional
    public void cancelContract(Integer contractId, String reason) {
        String prefixedReason = (reason != null && !reason.trim().isEmpty()) 
            ? (reason.startsWith("[취소] ") ? reason : "[취소] " + reason)
            : "[취소] 사유 없음";
        contractMapper.updateContractStatus(contractId, ContractStatus.TERMINATED.name(), prefixedReason);
    }
    
    /** 프리랜서 지급 요청. 마일스톤: WAITING → REQUESTED, 일시지급: cancel_reason에 "[지급요청]" 저장. */
    @Transactional
    public int requestPayment(Integer contractId, Integer step) {
        // 계약 상태 확인
        ContractVO contract = contractMapper.selectContractById(contractId);
        if (contract == null) {
            throw new IllegalArgumentException("계약을 찾을 수 없습니다: " + contractId);
        }
        if (contract.getContractStatus() != ContractStatus.PAID 
                && contract.getContractStatus() != ContractStatus.COMPLETED) {
            throw new IllegalStateException("결제 완료 또는 정산 완료된 계약만 지급 요청할 수 있습니다. 현재 상태: " + contract.getContractStatus());
        }
        
        // 일시지급인 경우: cancel_reason에 "[지급요청]" 저장
        if ("FIXED".equals(contract.getPaymentMethod()) || "FULL".equals(contract.getPaymentMethod()) || contract.getPaymentMethod() == null) {
            List<ContractMilestoneVO> milestones = contractMilestoneMapper.selectMilestonesByContractId(contractId);
            if (milestones == null || milestones.isEmpty()) {
                contractMapper.updateContractStatus(contractId, ContractStatus.PAID.name(), "[지급요청]");
                logger.info("일시지급 요청: contractId={}", contractId);
                return 1;
            }
        }
        
        // 마일스톤 방식: 마일스톤 상태 업데이트: WAITING → REQUESTED
        return contractMilestoneMapper.updateMilestoneStatus(contractId, step, MilestoneStatus.REQUESTED.name());
    }
    
    /** 클라이언트 지급 수락. 마일스톤: REQUESTED → DEPOSITED, 일시지급: PAID → COMPLETED. */
    @Transactional
    public int approvePayment(Integer contractId, Integer step) {
        // 계약 상태 확인
        ContractVO contract = contractMapper.selectContractById(contractId);
        if (contract == null) {
            throw new IllegalArgumentException("계약을 찾을 수 없습니다: " + contractId);
        }
        if (contract.getContractStatus() != ContractStatus.PAID 
                && contract.getContractStatus() != ContractStatus.COMPLETED) {
            throw new IllegalStateException("결제 완료 또는 정산 완료된 계약만 지급 수락할 수 있습니다. 현재 상태: " + contract.getContractStatus());
        }
        
        // 일시지급이고 cancel_reason이 "[지급요청]"인 경우
        if (("FIXED".equals(contract.getPaymentMethod()) || "FULL".equals(contract.getPaymentMethod()) || contract.getPaymentMethod() == null)
                && "[지급요청]".equals(contract.getCancelReason())) {
            contractMapper.updateContractStatus(contractId, ContractStatus.COMPLETED.name(), null);
            contractMapper.updateCancelReason(contractId, null);
            logger.info("일시지급 수락: contractId={}", contractId);
            return 1;
        }
        
        // 마일스톤 상태 업데이트: REQUESTED → DEPOSITED
        if (step == null) {
            // 모든 REQUESTED 마일스톤을 DEPOSITED로 변경
            List<ContractMilestoneVO> milestones = contractMilestoneMapper.selectMilestonesByContractId(contractId);
            int count = 0;
            
            for (ContractMilestoneVO milestone : milestones) {
                if (milestone.getStatus() == MilestoneStatus.REQUESTED) {
                    contractMilestoneMapper.updateMilestoneStatus(contractId, milestone.getStep(), MilestoneStatus.DEPOSITED.name());
                    count++;
                }
            }
            
            // 모든 마일스톤이 DEPOSITED 또는 PAID인지 확인
            boolean allDepositedOrPaid = true;
            for (ContractMilestoneVO milestone : milestones) {
                MilestoneStatus status = milestone.getStatus();
                if (status != MilestoneStatus.DEPOSITED && status != MilestoneStatus.PAID) {
                    allDepositedOrPaid = false;
                    break;
                }
            }
            
            // 모든 마일스톤이 DEPOSITED 또는 PAID면 COMPLETED로 변경
            if (allDepositedOrPaid && !milestones.isEmpty()) {
                contractMapper.updateContractStatus(contractId, ContractStatus.COMPLETED.name(), null);
            }
            
            return count;
        } else {
            // 특정 마일스톤만 DEPOSITED로 변경
            int updated = contractMilestoneMapper.updateMilestoneStatus(contractId, step, MilestoneStatus.DEPOSITED.name());
            
            // 모든 마일스톤이 DEPOSITED 또는 PAID인지 확인
            List<ContractMilestoneVO> allMilestones = contractMilestoneMapper.selectMilestonesByContractId(contractId);
            boolean allDepositedOrPaid = true;
            for (ContractMilestoneVO milestone : allMilestones) {
                MilestoneStatus status = milestone.getStatus();
                if (status != MilestoneStatus.DEPOSITED && status != MilestoneStatus.PAID) {
                    allDepositedOrPaid = false;
                    break;
                }
            }
            
            // 모든 마일스톤이 DEPOSITED 또는 PAID면 COMPLETED로 변경
            if (allDepositedOrPaid && !allMilestones.isEmpty()) {
                contractMapper.updateContractStatus(contractId, ContractStatus.COMPLETED.name(), null);
            }
            
            return updated;
        }
    }
    
    /** 클라이언트 지급 거부. 마일스톤: REQUESTED → WAITING, 일시지급: cancel_reason null로 초기화. */
    @Transactional
    public int rejectPayment(Integer contractId, Integer step) {
        // 계약 상태 확인
        ContractVO contract = contractMapper.selectContractById(contractId);
        if (contract == null) {
            throw new IllegalArgumentException("계약을 찾을 수 없습니다: " + contractId);
        }
        if (contract.getContractStatus() != ContractStatus.PAID 
                && contract.getContractStatus() != ContractStatus.COMPLETED) {
            throw new IllegalStateException("결제 완료 또는 정산 완료된 계약만 지급 거부할 수 있습니다. 현재 상태: " + contract.getContractStatus());
        }
        
        // 일시지급이고 cancel_reason이 "[지급요청]"인 경우
        if (("FIXED".equals(contract.getPaymentMethod()) || "FULL".equals(contract.getPaymentMethod()) || contract.getPaymentMethod() == null)
                && "[지급요청]".equals(contract.getCancelReason())) {
            contractMapper.updateCancelReason(contractId, null);
            logger.info("일시지급 거부: contractId={}, cancel_reason을 null로 설정", contractId);
            return 1;
        }
        
        // 마일스톤 상태 업데이트: REQUESTED → WAITING
        if (step == null) {
            // 모든 REQUESTED 마일스톤을 WAITING으로 변경
            List<ContractMilestoneVO> milestones = contractMilestoneMapper.selectMilestonesByContractId(contractId);
            int count = 0;
            
            for (ContractMilestoneVO milestone : milestones) {
                if (milestone.getStatus() == MilestoneStatus.REQUESTED) {
                    contractMilestoneMapper.updateMilestoneStatus(contractId, milestone.getStep(), MilestoneStatus.WAITING.name());
                    count++;
                }
            }
            
            return count;
        } else {
            // 특정 마일스톤만 WAITING으로 변경
            return contractMilestoneMapper.updateMilestoneStatus(contractId, step, MilestoneStatus.WAITING.name());
        }
    }
    
    /** 마일스톤 지급 완료 처리. DEPOSITED → PAID, 모든 마일스톤 완료 시 계약 상태 COMPLETED로 변경. */
    @Transactional
    public int completeMilestonePayment(Integer contractId, Integer step) {
        // 마일스톤 상태 업데이트: DEPOSITED → PAID
        int updatedCount;
        if (step == null) {
            // 모든 DEPOSITED 마일스톤을 PAID로 변경
            List<ContractMilestoneVO> milestones = contractMilestoneMapper.selectMilestonesByContractId(contractId);
            updatedCount = 0;
            for (ContractMilestoneVO milestone : milestones) {
                if (milestone.getStatus() == MilestoneStatus.DEPOSITED) {
                    contractMilestoneMapper.updateMilestoneStatus(contractId, milestone.getStep(), MilestoneStatus.PAID.name());
                    updatedCount++;
                }
            }
        } else {
            updatedCount = contractMilestoneMapper.updateMilestoneStatus(contractId, step, MilestoneStatus.PAID.name());
        }
        
        // 모든 마일스톤이 PAID인지 확인
        List<ContractMilestoneVO> allMilestones = contractMilestoneMapper.selectMilestonesByContractId(contractId);
        boolean allPaid = true;
        for (ContractMilestoneVO milestone : allMilestones) {
            if (milestone.getStatus() != MilestoneStatus.PAID) {
                allPaid = false;
                break;
            }
        }
        
        // 모든 마일스톤이 PAID면 계약 상태를 COMPLETED로 변경
        if (allPaid && !allMilestones.isEmpty()) {
            contractMapper.updateContractStatus(contractId, ContractStatus.COMPLETED.name(), null);
        }
        
        return updatedCount;
    }
    
    /** 원본 계약서 파일 경로 업데이트. */
    @Transactional
    public void updateOriginContractUrl(Integer contractId, String originContractUrl) {
        contractMapper.updateOriginContractUrl(contractId, originContractUrl);
    }
    
    /** 마일스톤 계약 상태 자동 업데이트. 모든 마일스톤이 DEPOSITED/PAID면 PAID → COMPLETED. */
    @Transactional
    public void autoUpdateContractStatusIfAllMilestonesCompleted(Integer contractId) {
        ContractVO contract = contractMapper.selectContractById(contractId);
        if (contract == null || contract.getContractStatus() != ContractStatus.PAID) {
            return; // 계약이 없거나 PAID 상태가 아니면 처리하지 않음
        }
        
        List<ContractMilestoneVO> milestones = contractMilestoneMapper.selectMilestonesByContractId(contractId);
        if (milestones == null || milestones.isEmpty()) {
            return; // 마일스톤이 없으면 처리하지 않음 (일시지급 계약)
        }
        
        // 모든 마일스톤이 DEPOSITED 또는 PAID인지 확인
        boolean allDepositedOrPaid = true;
        for (ContractMilestoneVO milestone : milestones) {
            MilestoneStatus status = milestone.getStatus();
            if (status != MilestoneStatus.DEPOSITED && status != MilestoneStatus.PAID) {
                allDepositedOrPaid = false;
                break;
            }
        }
        
        // 모든 마일스톤이 완료되었으면 계약 상태를 COMPLETED로 변경
        if (allDepositedOrPaid) {
            contractMapper.updateContractStatus(contractId, ContractStatus.COMPLETED.name(), null);
            logger.info("마일스톤 계약 상태 자동 업데이트: contractId={}, PAID → COMPLETED (모든 마일스톤 입금 완료)", contractId);
        }
    }
}
