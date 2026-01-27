package com.sanaiclub.portfolio.dao;

import com.sanaiclub.portfolio.model.dto.FreelancerProfileBasicSaveRequestDTO;
import com.sanaiclub.portfolio.model.dto.FreelancerProfileBasicViewDTO;
import com.sanaiclub.portfolio.model.vo.FreelancerPortfolioVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface FreelancerProfileBasicMapper {

    FreelancerProfileBasicViewDTO selectBasicProfile(@Param("userId") Integer userId);

    int updateBasicProfile(FreelancerProfileBasicSaveRequestDTO dto);
    int insertBasicProfile(FreelancerProfileBasicSaveRequestDTO dto);

    // users.profile_image_url
    String selectProfileImageUrl(@Param("userId") Integer userId);
    int updateProfileImageUrl(@Param("userId") Integer userId, @Param("url") String url);
    int clearProfileImageUrl(@Param("userId") Integer userId);

    // portfolio (latest 1)
    FreelancerPortfolioVO selectLatestPortfolio(@Param("userId") Integer userId);
    FreelancerPortfolioVO selectPortfolioById(@Param("portfolioId") Integer portfolioId);

    int insertPortfolio(FreelancerPortfolioVO vo);
    int updatePortfolio(FreelancerPortfolioVO vo);
    int deletePortfolio(@Param("portfolioId") Integer portfolioId, @Param("userId") Integer userId);


    // 인터페이스 안에 추가
    List<FreelancerPortfolioVO> selectPublicPortfolios(@Param("userId") Integer userId);
}
