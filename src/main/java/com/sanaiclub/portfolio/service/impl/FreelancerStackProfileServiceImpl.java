package com.sanaiclub.portfolio.service.impl;

import com.sanaiclub.portfolio.dao.FreelancerSkillMapper;
import com.sanaiclub.portfolio.dao.StackOptionMapper;
import com.sanaiclub.portfolio.model.dto.MyStackItemDTO;
import com.sanaiclub.portfolio.model.vo.FreelancerSkillVO;
import com.sanaiclub.portfolio.service.FreelancerStackProfileService;
import com.sanaiclub.project.model.dto.StackDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.sanaiclub.portfolio.model.dto.FreelancerStackSaveRequestDTO;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class FreelancerStackProfileServiceImpl implements FreelancerStackProfileService {

    private final FreelancerSkillMapper freelancerSkillMapper;
    private final StackOptionMapper stackOptionMapper;

    @Override
    public List<StackDTO> getSkillOptions() {
        return stackOptionMapper.findByCategory("SKILL");
    }

    @Override
    public List<StackDTO> getPositionOptions() {
        return stackOptionMapper.findByCategory("POSITION");
    }

    @Override
    public List<MyStackItemDTO> getMySkills(Integer freelancerId) {
        return freelancerSkillMapper.selectMyStacks(freelancerId, "SKILL");
    }

    @Override
    public List<MyStackItemDTO> getMyPositions(Integer freelancerId) {
        return freelancerSkillMapper.selectMyStacks(freelancerId, "POSITION");
    }

    @Override
    @Transactional
    public void save(Integer freelancerId, String category, List<MyStackItemDTO> stacks) {

        // category 검증
        String cat = (category == null) ? "" : category.trim().toUpperCase();
        if (!"SKILL".equals(cat) && !"POSITION".equals(cat)) {
            throw new IllegalArgumentException("Invalid category: " + category);
        }

        // null이면 빈 리스트
        if (stacks == null) stacks = List.of();

        // 중복 stackId 제거 (중복 들어오면 unique 터짐)
        // + 값 기본 보정
        List<FreelancerSkillVO> voList = new ArrayList<>();
        Set<Integer> seen = new HashSet<>();

        for (MyStackItemDTO dto : stacks) {
            if (dto == null || dto.getStackId() == null) continue;

            Integer stackId = dto.getStackId();
            if (seen.contains(stackId)) continue; // 중복 방지
            seen.add(stackId);

            int level = (dto.getStackLevel() == null) ? 1 : dto.getStackLevel();
            int year  = (dto.getStackYear() == null) ? 0 : dto.getStackYear();

            // DB check constraint(1~5) 안전 보정
            if (level < 1) level = 1;
            if (level > 5) level = 5;
            if (year < 0) year = 0;

            voList.add(FreelancerSkillVO.builder()
                    .freelancerId(freelancerId)
                    .stackId(stackId)
                    .stackLevel(level)
                    .stackYear(year)
                    .build());
        }

        // 기존값 삭제 (카테고리 단위)
        freelancerSkillMapper.deleteMyStacks(freelancerId, cat);

        // 새로 insert (없으면 여기서 종료)
        if (voList.isEmpty()) return;

        freelancerSkillMapper.insertBatch(freelancerId, voList);
    }
}