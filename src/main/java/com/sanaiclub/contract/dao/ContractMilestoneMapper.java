package com.sanaiclub.contract.dao;

import com.sanaiclub.contract.model.vo.ContractMilestoneVO;
import com.sanaiclub.contract.model.vo.MilestoneStatus;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;


@Mapper
public interface ContractMilestoneMapper {

    /**
     * 마일스톤 등록
     */
    int insertMilestone(
            @Param("contractId") Integer contractId,
            @Param("step") Integer step,
            @Param("title") String title,
            @Param("description") String description,
            @Param("amount") Long amount
    );

    /**
     * 계약 ID로 마일스톤 목록 조회
     */
    List<ContractMilestoneVO> selectMilestonesByContractId(
            @Param("contractId") Integer contractId
    );

    /**
     * 계약의 모든 마일스톤 삭제
     */
    int deleteMilestonesByContractId(
            @Param("contractId") Integer contractId
    );


    ContractMilestoneVO selectMilestoneById(@Param("milestoneId") Integer milestoneId);

    List<ContractMilestoneVO> selectMilestonesByStatus(
            @Param("contractId") Integer contractId,
            @Param("status") MilestoneStatus status
    );

    int updateMilestoneStatus(
            @Param("milestoneId") Integer milestoneId,
            @Param("status") MilestoneStatus status
    );

}
