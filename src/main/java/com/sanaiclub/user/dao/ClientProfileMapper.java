package com.sanaiclub.user.dao;

import com.sanaiclub.user.model.vo.ClientProfileVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * 클라이언트 프로필 DAO
 * ═══════════════════════════════════════════════════════════════════════
 *
 * [역할]
 * - client_profiles 테이블 CRUD
 *
 */
@Mapper
public interface ClientProfileMapper {

    /**
     * 클라이언트 프로필 등록
     *
     * @param profile 등록할 프로필 정보
     * @return 등록된 행 수
     */
    int insertClientProfile(ClientProfileVO profile);

    /**
     * 클라이언트 ID로 프로필 조회
     *
     * @param clientId 클라이언트 PK (= userId)
     * @return 클라이언트 프로필 (없으면 null)
     */
    ClientProfileVO findByClientId(@Param("clientId") Integer clientId);

    /**
     * 클라이언트 프로필 수정
     *
     * @param profile 수정할 프로필 정보
     * @return 수정된 행 수
     */
    int updateClientProfile(ClientProfileVO profile);

    /**
     * 회사 ID로 연결된 클라이언트 수 조회
     * - 회사 삭제 전 체크용
     *
     * @param companyId 회사 PK
     * @return 연결된 클라이언트 수
     */
    int countByCompanyId(@Param("companyId") Integer companyId);
}