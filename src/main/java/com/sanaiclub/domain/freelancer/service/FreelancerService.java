package com.sanaiclub.domain.freelancer.service;

import com.sanaiclub.domain.freelancer.dto.FreelancerProfile;
import com.sanaiclub.domain.freelancer.dto.SkillInput;
import com.sanaiclub.domain.freelancer.mapper.FreelancerMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

/**
 * FreelancerService - 프리랜서 프로필 관련 비즈니스 로직
 * 
 * 역할:
 * - 프리랜서 프로필 조회
 * - 프로필 완성 처리 (기술 스택 저장)
 * - 기술 스택 관리
 */
@Service
public class FreelancerService {
    
    @Autowired
    private FreelancerMapper freelancerMapper;
    
    /**
     * 프리랜서 프로필 조회
     * 
     * @param userId 사용자 ID
     * @return FreelancerProfile 프로필 정보
     */
    public FreelancerProfile getProfile(Long userId) {
        return freelancerMapper.findByUserId(userId);
    }
    
    /**
     * 프리랜서 프로필 완성
     * - 프로필 정보 업데이트
     * - 기술 스택 저장
     * 
     * @param freelancerId 프리랜서 ID (= userId)
     * @param profile 프로필 정보
     * @param skills 기술 스택 리스트
     * @return 성공 여부
     */
    @Transactional
    public boolean completeProfile(Long freelancerId, FreelancerProfile profile, List<SkillInput> skills) {
        try {
            // 1. 프로필 업데이트
            freelancerMapper.updateFreelancerProfile(profile);
            
            // 2. 기존 기술 스택 삭제 (있을 경우)
            freelancerMapper.deleteFreelancerSkills(freelancerId);
            
            // 3. 새로운 기술 스택 저장
            if (skills != null && !skills.isEmpty()) {
                for (SkillInput skill : skills) {
                    freelancerMapper.insertFreelancerSkill(freelancerId, skill);
                }
            }
            
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 닉네임 중복 확인
     * 
     * @param nickname 닉네임
     * @return 중복 여부 (true: 중복, false: 미중복)
     */
    public boolean isNicknameDuplicate(String nickname) {
        return freelancerMapper.countByNickname(nickname) > 0;
    }
    
    /**
     * 프리랜서 프로필 저장 (기술 스택 포함)
     * 새로운 프로필 생성
     * 
     * @param profile 프로필 정보
     * @param skills 기술 스택 리스트
     * @return 성공 여부
     */
    @Transactional
    public boolean saveProfile(FreelancerProfile profile, List<SkillInput> skills) {
        try {
            // 1. 프로필 생성
            freelancerMapper.insertFreelancerProfile(profile);
            
            // 2. 기술 스택 저장
            if (skills != null && !skills.isEmpty()) {
                for (SkillInput skill : skills) {
                    freelancerMapper.insertFreelancerSkill(profile.getUserId(), skill);
                }
            }
            
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 전체 기술 스택 목록 조회
     * 모달에서 사용할 스택 데이터 반환
     * 
     * @return List<Map<String, Object>> 스택 목록
     *   - stack_id: 스택 ID
     *   - stack_name: 스택 이름
     *   - category: SKILL 또는 POSITION
     */
    public List<Map<String, Object>> getAllStacks() {
        return freelancerMapper.findAllStacks();
    }
}
