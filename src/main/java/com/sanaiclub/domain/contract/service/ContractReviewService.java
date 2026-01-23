package com.sanaiclub.domain.contract.service;

import com.sanaiclub.domain.contract.dto.ContractReviewDTO;
import com.sanaiclub.domain.contract.mapper.ContractReviewMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 *  ContractReviewService - 계약 리뷰 비즈니스 로직
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * 
 * [역할]
 * 계약 리뷰 작성 및 조회와 관련된 비즈니스 로직을 처리합니다.
 * 
 * [핵심 책임]
 * 1. 리뷰 작성 권한 검증 (소유자 확인)
 * 2. 중복 작성 방지 (이미 작성한 리뷰는 재작성 불가)
 * 3. 입력값 검증 (별점 범위, 리뷰 길이 등)
 * 4. 별점 변환 로직 (화면 0~10점 → DB 0~20점)
 * 5. 트랜잭션 관리
 * 
 * [보안 규칙]
 * - 클라이언트는 자신이 발주한 계약에만 리뷰 작성 가능
 * - 프리랜서는 자신이 수주한 계약에만 리뷰 작성 가능
 * - contractId와 userId의 소유권을 DB에서 검증
 * 
 * [중복 방지 규칙]
 * - client_rating이 NULL이 아니면 → 클라이언트 리뷰 작성 완료
 * - freelancer_rating이 NULL이 아니면 → 프리랜서 리뷰 작성 완료
 * - 작성 완료된 리뷰는 수정 불가 (현재 정책)
 * 
 * [별점 변환]
 * - 화면 입력: 0.0 ~ 10.0 (0.5 단위)
 * - DB 저장: 0 ~ 20 (INT)
 * - DTO의 setXxxRatingFromDisplay() 메서드 사용
 * 
 * @author Ratel Ocean Team
 * @since 2026-01-15
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 */
@Service
public class ContractReviewService {
    
    private static final Logger logger = LoggerFactory.getLogger(ContractReviewService.class);
    
    @Autowired
    private ContractReviewMapper contractReviewMapper;
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 리뷰 조회
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /**
     * 계약 정보 및 리뷰 상태 조회
     * 
     * [사용 시나리오]
     * GET /review/client?contractId=1
     * GET /review/freelancer?contractId=1
     * → 리뷰 작성 화면에서 계약 요약 정보 표시
     * 
     * [반환값]
     * - contract_id가 존재하지 않으면 null
     * - 존재하면 계약 기본 정보 + 리뷰 데이터 반환
     * 
     * [보안 고려]
     * 현재는 contractId만으로 조회하지만,
     * 실제 운영에서는 userId와 소유권을 검증해야 합니다.
     * (Controller에서 세션 userId와 비교)
     * 
     * @param contractId 계약 ID
     * @return 계약 정보 + 리뷰 데이터 (없으면 null)
     */
    public ContractReviewDTO getContractWithReview(Long contractId) {
        logger.info("[리뷰 조회] contractId={}", contractId);
        
        if (contractId == null || contractId <= 0) {
            logger.warn("[리뷰 조회 실패] 유효하지 않은 contractId: {}", contractId);
            return null;
        }
        
        ContractReviewDTO contract = contractReviewMapper.selectContractWithReview(contractId);
        
        if (contract == null) {
            logger.warn("[리뷰 조회 실패] 존재하지 않는 계약: contractId={}", contractId);
            return null;
        }
        
        logger.info("[리뷰 조회 성공] contractId={}, clientReviewDone={}, freelancerReviewDone={}",
            contractId, contract.isClientReviewSubmitted(), contract.isFreelancerReviewSubmitted());
        
        return contract;
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 클라이언트 리뷰 작성
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /**
     * 클라이언트 → 프리랜서 리뷰 저장
     * 
     * [호출 시점]
     * POST /review/client
     * 클라이언트가 프리랜서를 평가할 때
     * 
     * [검증 항목]
     * 1. contractId 유효성
     * 2. 계약 존재 여부
     * 3. 소유권 확인 (clientId == userId) ← Controller에서 처리
     * 4. 중복 작성 방지 (client_rating이 NULL인지)
     * 5. 별점 범위 검증 (0.0 ~ 10.0)
     * 6. 리뷰 길이 검증 (최대 500자)
     * 
     * [트랜잭션]
     * UPDATE 실패 시 롤백
     * 
     * [예외 처리]
     * - IllegalArgumentException: 입력값 오류
     * - IllegalStateException: 중복 작성 시도
     * - RuntimeException: DB 오류
     * 
     * @param contractId 계약 ID
     * @param clientId 클라이언트 ID (소유권 확인용)
     * @param rating 별점 (0.0 ~ 10.0)
     * @param experience 공개 리뷰 텍스트
     * @param isRenewalIntended 재계약 의사 (true/false)
     * @throws IllegalArgumentException 입력값 오류
     * @throws IllegalStateException 이미 리뷰 작성 완료
     */
    @Transactional
    public void saveClientReview(
            Long contractId,
            Long clientId,
            Double rating,
            String experience,
            Boolean isRenewalIntended) {
        
        logger.info("[클라이언트 리뷰 저장 시작] contractId={}, clientId={}, rating={}", 
            contractId, clientId, rating);
        
        // ━━━━ 1단계: 입력값 검증 ━━━━
        validateClientReviewInput(contractId, clientId, rating, experience);
        
        // ━━━━ 2단계: 계약 조회 ━━━━
        ContractReviewDTO contract = contractReviewMapper.selectContractWithReview(contractId);
        if (contract == null) {
            logger.error("[리뷰 저장 실패] 존재하지 않는 계약: contractId={}", contractId);
            throw new IllegalArgumentException("존재하지 않는 계약입니다.");
        }
        
        // ━━━━ 3단계: 소유권 검증 ━━━━
        if (!contract.getClientId().equals(clientId)) {
            logger.error("[리뷰 저장 실패] 소유권 불일치: contractId={}, requestClientId={}, actualClientId={}",
                contractId, clientId, contract.getClientId());
            throw new IllegalArgumentException("이 계약에 대한 리뷰 작성 권한이 없습니다.");
        }
        
        // ━━━━ 4단계: 중복 작성 방지 ━━━━
        if (contract.isClientReviewSubmitted()) {
            logger.warn("[리뷰 저장 실패] 이미 작성 완료: contractId={}", contractId);
            throw new IllegalStateException("이미 리뷰를 작성하셨습니다. 수정은 불가능합니다.");
        }
        
        // ━━━━ 5단계: 별점 변환 (화면 0~10 → DB 0~20) ━━━━
        ContractReviewDTO dto = new ContractReviewDTO();
        dto.setClientRatingFromDisplay(rating);  // Double → Integer 변환
        
        Integer dbRating = dto.getClientRating();
        logger.info("[별점 변환] 화면 입력={}점 → DB 저장={}점", rating, dbRating);
        
        // ━━━━ 6단계: DB 업데이트 ━━━━
        int updated = contractReviewMapper.updateClientReview(
            contractId,
            dbRating,
            experience,
            isRenewalIntended
        );
        
        if (updated == 0) {
            logger.error("[리뷰 저장 실패] UPDATE 실패: contractId={}", contractId);
            throw new RuntimeException("리뷰 저장에 실패했습니다.");
        }
        
        logger.info("[클라이언트 리뷰 저장 성공] contractId={}, dbRating={}, renewalIntended={}",
            contractId, dbRating, isRenewalIntended);
    }
    
    /**
     * 클라이언트 리뷰 입력값 검증
     * 
     * [검증 항목]
     * - contractId: null 또는 0 이하 불가
     * - clientId: null 불가
     * - rating: 0.0 ~ 10.0 범위 + 0.5 단위
     * - experience: 최대 500자
     * 
     * @param contractId 계약 ID
     * @param clientId 클라이언트 ID
     * @param rating 별점
     * @param experience 리뷰 텍스트
     * @throws IllegalArgumentException 검증 실패 시
     */
    private void validateClientReviewInput(Long contractId, Long clientId, Double rating, String experience) {
        if (contractId == null || contractId <= 0) {
            throw new IllegalArgumentException("유효하지 않은 계약 ID입니다.");
        }
        
        if (clientId == null) {
            throw new IllegalArgumentException("클라이언트 ID가 필요합니다.");
        }
        
        // 별점 검증: 0.0 ~ 10.0, 0.5 단위
        if (rating == null || rating < 0.0 || rating > 10.0) {
            throw new IllegalArgumentException("별점은 0.0 ~ 10.0 사이여야 합니다.");
        }
        
        if (rating * 2 % 1 != 0) {
            throw new IllegalArgumentException("별점은 0.5 단위로만 입력 가능합니다.");
        }
        
        // 리뷰 길이 검증
        if (experience != null && experience.length() > 500) {
            throw new IllegalArgumentException("리뷰는 최대 500자까지 작성 가능합니다.");
        }
        
        logger.debug("[입력값 검증 통과] contractId={}, clientId={}, rating={}", contractId, clientId, rating);
    }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 프리랜서 리뷰 작성
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    /**
     * 프리랜서 → 클라이언트 리뷰 저장
     * 
     * [호출 시점]
     * POST /review/freelancer
     * 프리랜서가 클라이언트를 평가할 때
     * 
     * [클라이언트와의 차이]
     * - 재계약 의사(isRenewalIntended) 항목 없음
     * - 프리랜서는 별점과 리뷰만 작성
     * 
     * [검증 항목]
     * 1. contractId 유효성
     * 2. 계약 존재 여부
     * 3. 소유권 확인 (freelancerId == userId) ← Controller에서 처리
     * 4. 중복 작성 방지 (freelancer_rating이 NULL인지)
     * 5. 별점 범위 검증 (0.0 ~ 10.0)
     * 6. 리뷰 길이 검증 (최대 500자)
     * 
     * [트랜잭션]
     * UPDATE 실패 시 롤백
     * 
     * @param contractId 계약 ID
     * @param freelancerId 프리랜서 ID (소유권 확인용)
     * @param rating 별점 (0.0 ~ 10.0)
     * @param experience 공개 리뷰 텍스트
     * @throws IllegalArgumentException 입력값 오류
     * @throws IllegalStateException 이미 리뷰 작성 완료
     */
    @Transactional
    public void saveFreelancerReview(
            Long contractId,
            Long freelancerId,
            Double rating,
            String experience) {
        
        logger.info("[프리랜서 리뷰 저장 시작] contractId={}, freelancerId={}, rating={}", 
            contractId, freelancerId, rating);
        
        // ━━━━ 1단계: 입력값 검증 ━━━━
        validateFreelancerReviewInput(contractId, freelancerId, rating, experience);
        
        // ━━━━ 2단계: 계약 조회 ━━━━
        ContractReviewDTO contract = contractReviewMapper.selectContractWithReview(contractId);
        if (contract == null) {
            logger.error("[리뷰 저장 실패] 존재하지 않는 계약: contractId={}", contractId);
            throw new IllegalArgumentException("존재하지 않는 계약입니다.");
        }
        
        // ━━━━ 3단계: 소유권 검증 ━━━━
        if (!contract.getFreelancerId().equals(freelancerId)) {
            logger.error("[리뷰 저장 실패] 소유권 불일치: contractId={}, requestFreelancerId={}, actualFreelancerId={}",
                contractId, freelancerId, contract.getFreelancerId());
            throw new IllegalArgumentException("이 계약에 대한 리뷰 작성 권한이 없습니다.");
        }
        
        // ━━━━ 4단계: 중복 작성 방지 ━━━━
        if (contract.isFreelancerReviewSubmitted()) {
            logger.warn("[리뷰 저장 실패] 이미 작성 완료: contractId={}", contractId);
            throw new IllegalStateException("이미 리뷰를 작성하셨습니다. 수정은 불가능합니다.");
        }
        
        // ━━━━ 5단계: 별점 변환 (화면 0~10 → DB 0~20) ━━━━
        ContractReviewDTO dto = new ContractReviewDTO();
        dto.setFreelancerRatingFromDisplay(rating);
        
        Integer dbRating = dto.getFreelancerRating();
        logger.info("[별점 변환] 화면 입력={}점 → DB 저장={}점", rating, dbRating);
        
        // ━━━━ 6단계: DB 업데이트 ━━━━
        int updated = contractReviewMapper.updateFreelancerReview(
            contractId,
            dbRating,
            experience
        );
        
        if (updated == 0) {
            logger.error("[리뷰 저장 실패] UPDATE 실패: contractId={}", contractId);
            throw new RuntimeException("리뷰 저장에 실패했습니다.");
        }
        
        logger.info("[프리랜서 리뷰 저장 성공] contractId={}, dbRating={}", contractId, dbRating);
    }
    
    /**
     * 프리랜서 리뷰 입력값 검증
     * 
     * [검증 항목]
     * - contractId: null 또는 0 이하 불가
     * - freelancerId: null 불가
     * - rating: 0.0 ~ 10.0 범위 + 0.5 단위
     * - experience: 최대 500자
     * 
     * @param contractId 계약 ID
     * @param freelancerId 프리랜서 ID
     * @param rating 별점
     * @param experience 리뷰 텍스트
     * @throws IllegalArgumentException 검증 실패 시
     */
    private void validateFreelancerReviewInput(Long contractId, Long freelancerId, Double rating, String experience) {
        if (contractId == null || contractId <= 0) {
            throw new IllegalArgumentException("유효하지 않은 계약 ID입니다.");
        }
        
        if (freelancerId == null) {
            throw new IllegalArgumentException("프리랜서 ID가 필요합니다.");
        }
        
        // 별점 검증: 0.0 ~ 10.0, 0.5 단위
        if (rating == null || rating < 0.0 || rating > 10.0) {
            throw new IllegalArgumentException("별점은 0.0 ~ 10.0 사이여야 합니다.");
        }
        
        if (rating * 2 % 1 != 0) {
            throw new IllegalArgumentException("별점은 0.5 단위로만 입력 가능합니다.");
        }
        
        // 리뷰 길이 검증
        if (experience != null && experience.length() > 500) {
            throw new IllegalArgumentException("리뷰는 최대 500자까지 작성 가능합니다.");
        }
        
        logger.debug("[입력값 검증 통과] contractId={}, freelancerId={}, rating={}", contractId, freelancerId, rating);
    }
}
