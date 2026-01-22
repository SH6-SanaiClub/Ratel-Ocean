package com.sanaiclub.user.dao;

import com.sanaiclub.user.model.dto.FreelancerProfileDTO;
import com.sanaiclub.user.model.vo.FreelancerProfileVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface FreelancerProfileMapper {

    /**
     * 프리랜서 프로필 등록
     *
     * @param userId 사용자 PK (= freelancer_id)
     * @param dto    프로필 정보
     * @return 등록된 행 수
     */
    int insertFreelancerProfile(@Param("userId") Integer userId,
                                @Param("dto") FreelancerProfileDTO dto);

    /**
     * 프리랜서 프로필 조회
     *
     * @param freelancerId 프리랜서 PK (= user_id)
     * @return 프로필 정보 (없으면 null)
     */
    FreelancerProfileVO findByUserId(@Param("freelancerId") Integer freelancerId);

    /**
     * 프리랜서 프로필 수정
     *
     * @param profile 수정할 프로필 정보
     * @return 수정된 행 수
     */
    int updateFreelancerProfile(FreelancerProfileVO profile);
}
