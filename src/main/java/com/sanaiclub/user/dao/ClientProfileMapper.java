package com.sanaiclub.user.dao;

import com.sanaiclub.user.model.vo.ClientProfileVO;
import com.sanaiclub.user.model.vo.ClientType;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ClientProfileMapper {

    /**
     * 클라이언트 프로필 등록
     *
     * @param userId     사용자 PK (= client_id)
     * @param companyId  회사 PK (법인만, 개인은 null)
     * @param clientType 클라이언트 유형 (PERSONAL / CORPORATION)
     * @return 등록된 행 수
     */
    int insertClientProfile(@Param("userId") Integer userId,
                            @Param("companyId") Integer companyId,
                            @Param("clientType") ClientType clientType);

    /**
     * 클라이언트 프로필 조회
     *
     * @param clientId 클라이언트 PK (= user_id)
     * @return 프로필 정보 (없으면 null)
     */
    ClientProfileVO findByUserId(@Param("clientId") Integer clientId);

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