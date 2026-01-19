package com.sanaiclub.domain.contract.mapper;

import com.sanaiclub.domain.contract.dto.ContractReviewDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 *  ContractReviewMapper - 계약 리뷰 데이터 접근 인터페이스
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * 
 * [역할]
 * contracts 테이블의 리뷰 관련 컬럼에 대한 CRUD 작업을 담당합니다.
 * 
 * [DB 테이블]
 * - contracts (계약 기본 정보 + 리뷰 데이터)
 * - projects (JOIN: 프로젝트 제목 조회용)
 * 
 * [주요 책임]
 * 1. 리뷰 작성 가능 여부 확인 (중복 방지)
 * 2. 계약 정보 및 기존 리뷰 조회
 * 3. 클라이언트 리뷰 저장
 * 4. 프리랜서 리뷰 저장
 * 
 * [보안 고려사항]
 * - contractId와 userId의 소유권 검증은 Service 레이어에서 수행
 * - Mapper는 순수 데이터 접근만 담당
 * 
 * @author Ratel Ocean Team
 * @since 2026-01-15
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 */
@Mapper
public interface ContractReviewMapper {
    
    /**
     * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     * 계약 정보 및 리뷰 상태 조회
     * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     * 
     * [사용 목적]
     * - 리뷰 작성 화면에서 계약 요약 정보 표시
     * - 이미 작성된 리뷰가 있는지 확인 (중복 방지)
     * 
     * [반환값]
     * - contractId가 존재하지 않으면 null
     * - 존재하면 계약 기본 정보 + 리뷰 데이터 전체 반환
     * 
     * [JOIN 정보]
     * - contracts LEFT JOIN projects ON contracts.project_id = projects.project_id
     * - 프로젝트 제목을 화면에 표시하기 위함
     * 
     * @param contractId 계약 ID
     * @return 계약 정보 + 리뷰 데이터 (없으면 null)
     */
    ContractReviewDTO selectContractWithReview(@Param("contractId") Long contractId);
    
    /**
     * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     * 클라이언트 리뷰 저장 (UPDATE)
     * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     * 
     * [업데이트 대상 컬럼]
     * - client_rating (INT 0~20)
     * - client_experience (TEXT, 최대 500자)
     * - client_is_renewal_intended (TINYINT(1), true/false)
     * 
     * [중요!]
     * - 이미 client_rating이 NULL이 아니면 Service에서 거부해야 함
     * - 이 메서드는 무조건 UPDATE 수행 (중복 체크는 Service 책임)
     * 
     * [트랜잭션]
     * - Service 레이어에서 @Transactional 처리
     * 
     * @param contractId 계약 ID
     * @param clientRating DB 저장값 (0~20)
     * @param clientExperience 공개 리뷰 텍스트
     * @param clientIsRenewalIntended 재계약 의사 (true/false)
     * @return 업데이트된 행 수 (성공 시 1, 실패 시 0)
     */
    int updateClientReview(
        @Param("contractId") Long contractId,
        @Param("clientRating") Integer clientRating,
        @Param("clientExperience") String clientExperience,
        @Param("clientIsRenewalIntended") Boolean clientIsRenewalIntended
    );
    
    /**
     * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     * 프리랜서 리뷰 저장 (UPDATE)
     * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     * 
     * [업데이트 대상 컬럼]
     * - freelancer_rating (INT 0~20)
     * - freelancer_experience (TEXT, 최대 500자)
     * 
     * [클라이언트와의 차이점]
     * - 재계약 의사(client_is_renewal_intended) 항목 없음
     * - 프리랜서는 별점과 리뷰만 작성
     * 
     * [중요!]
     * - 이미 freelancer_rating이 NULL이 아니면 Service에서 거부해야 함
     * - 이 메서드는 무조건 UPDATE 수행 (중복 체크는 Service 책임)
     * 
     * [트랜잭션]
     * - Service 레이어에서 @Transactional 처리
     * 
     * @param contractId 계약 ID
     * @param freelancerRating DB 저장값 (0~20)
     * @param freelancerExperience 공개 리뷰 텍스트
     * @return 업데이트된 행 수 (성공 시 1, 실패 시 0)
     */
    int updateFreelancerReview(
        @Param("contractId") Long contractId,
        @Param("freelancerRating") Integer freelancerRating,
        @Param("freelancerExperience") String freelancerExperience
    );
}
