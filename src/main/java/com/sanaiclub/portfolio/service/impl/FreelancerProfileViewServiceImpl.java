package com.sanaiclub.portfolio.service.impl;

import com.sanaiclub.portfolio.dao.FreelancerCareerMapper;
import com.sanaiclub.portfolio.dao.FreelancerProfileBasicMapper;
import com.sanaiclub.portfolio.dao.FreelancerProjectExperienceMapper;
import com.sanaiclub.portfolio.dao.FreelancerSkillMapper;
import com.sanaiclub.portfolio.model.dto.FreelancerProfileBasicViewDTO;
import com.sanaiclub.portfolio.model.dto.FreelancerProfileViewDTO;
import com.sanaiclub.portfolio.model.dto.MyStackItemDTO;
import com.sanaiclub.user.dao.UserMapper;
import com.sanaiclub.user.model.vo.UserVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class FreelancerProfileViewServiceImpl implements com.sanaiclub.portfolio.service.FreelancerProfileViewService {

    private final UserMapper userMapper;
    private final FreelancerProfileBasicMapper freelancerProfileBasicMapper;
    private final FreelancerSkillMapper freelancerSkillMapper;
    private final FreelancerCareerMapper freelancerCareerMapper;
    private final FreelancerProjectExperienceMapper freelancerProjectExperienceMapper;

    @Override
    public FreelancerProfileViewDTO getProfile(Integer profileUserId, Integer viewerUserId) {

        UserVO user = userMapper.findByUserId(profileUserId);
        FreelancerProfileBasicViewDTO basic = freelancerProfileBasicMapper.selectBasicProfile(profileUserId);

        // stacks
        List<MyStackItemDTO> skills = freelancerSkillMapper.selectMyStacks(profileUserId, "SKILL");
        if (skills != null) {
            skills.sort(
                    Comparator.comparing(MyStackItemDTO::getStackYear, Comparator.nullsLast(Comparator.reverseOrder()))
                            .thenComparing(MyStackItemDTO::getStackLevel, Comparator.nullsLast(Comparator.reverseOrder()))
                            .thenComparing(MyStackItemDTO::getStackName, Comparator.nullsLast(String::compareToIgnoreCase))
            );
        }

        List<MyStackItemDTO> positions = freelancerSkillMapper.selectMyStacks(profileUserId, "POSITION");

        return FreelancerProfileViewDTO.builder()
                .userId(profileUserId)

                .loginId(user != null ? user.getLoginId() : null)
                .email(user != null ? user.getEmail() : null)
                .profileImageUrl(user != null ? user.getProfileImageUrl() : null)

                .nickname(basic != null ? basic.getNickname() : null)
                .introduction(basic != null ? basic.getIntroduction() : null)
                .githubUrl(basic != null ? basic.getGithubUrl() : null)
                .websiteUrl(basic != null ? basic.getWebsiteUrl() : null)

                .schoolName(basic != null ? basic.getSchoolName() : null)
                .major(basic != null ? basic.getMajor() : null)
                .degree(basic != null ? basic.getDegree() : null)
                .gradStatus(basic != null ? basic.getGradStatus() : null)

                .skills(skills)
                .positions(positions)

                .careers(freelancerCareerMapper.selectByFreelancerId(profileUserId))
                .projectExperiences(freelancerProjectExperienceMapper.selectByFreelancerId(profileUserId))

                .publicPortfolios(freelancerProfileBasicMapper.selectPublicPortfolios(profileUserId))

                .owner(viewerUserId != null && viewerUserId.equals(profileUserId))
                .build();
    }
}
