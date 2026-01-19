package com.sanaiclub.user.service;

import com.sanaiclub.user.model.dto.CompanyRegistrationDTO;
import com.sanaiclub.user.model.vo.ClientType;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * 클라이언트 회원가입 서비스
 * ═══════════════════════════════════════════════════════════════════════
 *
 * [역할]
 * - 클라이언트 프로필 등록
 * - 회사 정보 등록 (법인인 경우)
 * - 트랜잭션 관리
 *
 */
public interface ClientJoinService {

    /**
     * 클라이언트 프로필 등록 (개인)
     * - user 테이블 이미 INSERT 완료 상태
     * - client_profiles 테이블만 INSERT
     *
     * @param userId 사용자 PK
     * @param clientType 클라이언트 유형
     * @return 성공 여부
     */
    boolean registerClientProfile(Integer userId, ClientType clientType);

    /**
     * 클라이언트 프로필 등록 (법인)
     * - user 테이블 이미 INSERT 완료 상태
     * - companies 테이블 INSERT
     * - client_profiles 테이블 INSERT (companyId 포함)
     * - 트랜잭션으로 묶어서 처리
     *
     * @param userId 사용자 PK
     * @param companyDTO 회사 정보
     * @return 성공 여부
     */
    boolean registerClientProfileWithCompany(Integer userId, CompanyRegistrationDTO companyDTO);

    /**
     * 사업자번호 중복 확인
     *
     * @param businessNumber 사업자번호
     * @return 중복이면 true
     */
    boolean isBusinessNumberDuplicate(String businessNumber);

    /**
     * 사업자번호 진위확인
     *
     * @param businessNumber 사업자번호
     * @return 유효하면 true
     */
    boolean verifyBusinessNumber(String businessNumber);
}