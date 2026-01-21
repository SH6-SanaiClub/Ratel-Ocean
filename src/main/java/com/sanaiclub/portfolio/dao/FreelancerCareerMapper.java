package com.sanaiclub.portfolio.dao;

import com.sanaiclub.portfolio.model.vo.FreelancerCareerVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface FreelancerCareerMapper {
    List<FreelancerCareerVO> selectByFreelancerId(@Param("freelancerId") Integer freelancerId);

    int insertCareer(FreelancerCareerVO vo);

    int updateCareer(FreelancerCareerVO vo);

    int deleteCareer(@Param("careerId") Long careerId,
                     @Param("freelancerId") Integer freelancerId);
}
