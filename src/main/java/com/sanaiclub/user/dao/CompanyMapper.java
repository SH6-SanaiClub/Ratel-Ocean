package com.sanaiclub.user.dao;

import com.sanaiclub.user.model.vo.CompanyVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * 회사 정보 DAO
 * ═══════════════════════════════════════════════════════════════════════
 *
 * [역할]
 * - companies 테이블 CRUD
 *
 */
@Mapper
public interface CompanyMapper {

    /**
     * 회사 정보 등록
     *
     * @param company 등록할 회사 정보
     * @return 등록된 행 수
     */
    int insertCompany(CompanyVO company);

    /**
     * 회사 ID로 조회
     *
     * @param companyId 회사 PK
     * @return 회사 정보 (없으면 null)
     */
    CompanyVO findByCompanyId(@Param("companyId") Integer companyId);

    /**
     * 사업자등록번호로 조회
     * - 중복 체크용
     *
     * @param businessNumber 사업자등록번호
     * @return 회사 정보 (없으면 null)
     */
    CompanyVO findByBusinessNumber(@Param("businessNumber") String businessNumber);

    /**
     * 사업자등록번호 중복 확인
     *
     * @param businessNumber 사업자등록번호
     * @return 존재하면 1, 없으면 0
     */
    int checkBusinessNumber(@Param("businessNumber") String businessNumber);

    /**
     * 회사 정보 수정
     *
     * @param company 수정할 회사 정보
     * @return 수정된 행 수
     */
    int updateCompany(CompanyVO company);

    /**
     * 사업자 인증 상태 업데이트
     *
     * @param companyId 회사 PK
     * @param verified 인증 여부
     * @return 수정된 행 수
     */
    int updateVerificationStatus(@Param("companyId") Integer companyId,
                                 @Param("verified") Boolean verified);
}