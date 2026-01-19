package com.sanaiclub.domain.freelancer.mapper;

import com.sanaiclub.domain.freelancer.dto.FreelancerProfile;
import com.sanaiclub.domain.freelancer.dto.SkillInput;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * FreelancerProfile Mapper Interface
 */
@Mapper
public interface FreelancerMapper {
    
    /**
     * 프리랜서 프로필 생성
     */
    int insertFreelancerProfile(FreelancerProfile profile);
    
    /**
     * 프리랜서 프로필 업데이트 (학력 정보 포함)
     */
    int updateFreelancerProfile(FreelancerProfile profile);
    
    /**
     * 닉네임 중복 확인
     */
    int countByNickname(@Param("nickname") String nickname);
    
    /**
     * user_id로 프로필 조회
     */
    FreelancerProfile findByUserId(@Param("userId") Long userId);
    
    /**
     * 프리랜서 기술 스택 저장
     * freelancer_skills 테이블에 insert
     */
    int insertFreelancerSkill(@Param("freelancerId") Long freelancerId, 
                             @Param("skill") SkillInput skill);
    
    /**
     * 프리랜서 기술 스택 삭제
     * 프로필 업데이트 시 기존 기술 스택 삭제
     */
    int deleteFreelancerSkills(@Param("freelancerId") Long freelancerId);
    
    /**
     * 전체 기술 스택 목록 조회
     * - stack_id, stack_name, category 반환
     * - SKILL 카테고리만 필터링 (선택사항)
     */
    List<Map<String, Object>> findAllStacks();
}
