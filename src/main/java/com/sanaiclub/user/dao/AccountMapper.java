package com.sanaiclub.user.dao;

import com.sanaiclub.user.model.vo.AccountVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface AccountMapper {

    /**
     * 계좌 정보 등록
     *
     * @param account 계좌 정보 (계좌번호는 암호화된 상태)
     * @return 등록된 행 수
     */
    int insertAccount(AccountVO account);

    /**
     * 사용자 ID로 계좌 정보 조회
     *
     * @param userId 사용자 PK
     * @return 계좌 정보 (없으면 null)
     */
    AccountVO findByUserId(@Param("userId") Integer userId);

    /**
     * 계좌 정보 수정
     *
     * @param account 수정할 계좌 정보
     * @return 수정된 행 수
     */
    int updateAccount(AccountVO account);

    /**
     * 계좌 정보 삭제
     *
     * @param accountId 계좌 PK
     * @return 삭제된 행 수
     */
    int deleteAccount(@Param("accountId") Long accountId);
}
