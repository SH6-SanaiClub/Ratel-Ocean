package com.sanaiclub.project.dao;

import com.sanaiclub.project.model.dto.ClientReviewDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ClientReviewMapper {
    // 리뷰 대상(계약 및 프리랜서) 정보 조회
    ClientReviewDTO selectReviewTargetInfo(@Param("projectId") Integer projectId);

    // 리뷰 저장 (UPDATE)
    void updateContractReview(ClientReviewDTO reviewDTO);
}