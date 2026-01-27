package com.sanaiclub.portfolio.dao;

import com.sanaiclub.portfolio.model.dto.MyStackItemDTO;
import com.sanaiclub.portfolio.model.vo.FreelancerSkillVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface FreelancerSkillMapper {

    List<MyStackItemDTO> selectMyStacks(
            @Param("freelancerId") Integer freelancerId,
            @Param("category") String category
    );

    int deleteMyStacks(
            @Param("freelancerId") Integer freelancerId,
            @Param("category") String category
    );

    int insertBatch(
            @Param("freelancerId") Integer freelancerId,
            @Param("list") List<FreelancerSkillVO> list
    );
}
