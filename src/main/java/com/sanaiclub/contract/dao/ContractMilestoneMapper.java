package com.sanaiclub.contract.dao;

import com.sanaiclub.contract.model.vo.ContractMilestoneVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/** 계약 마일스톤 데이터 접근 인터페이스. Service 계층에서만 호출. */
@Mapper
public interface ContractMilestoneMapper {

    /** 마일스톤 등록. 계약 생성/수정 시 사용. */
    int insertMilestone(
            @Param("contractId") Integer contractId,
            @Param("step") Integer step,
            @Param("title") String title,
            @Param("description") String description,
            @Param("amount") Long amount
    );

    /** 계약 ID로 마일스톤 목록 조회. step 오름차순 정렬. */
    List<ContractMilestoneVO> selectMilestonesByContractId(
            @Param("contractId") Integer contractId
    );

    /** 계약의 모든 마일스톤 삭제. 계약 수정 시 사용. */
    int deleteMilestonesByContractId(
            @Param("contractId") Integer contractId
    );

    /** 마일스톤 상태 업데이트. step이 null이면 모든 WAITING 마일스톤 변경. */
    int updateMilestoneStatus(
            @Param("contractId") Integer contractId,
            @Param("step") Integer step,
            @Param("status") String status
    );

    /** 마일스톤 ID로 마일스톤 조회. */
    ContractMilestoneVO selectMilestoneById(@Param("milestoneId") Integer milestoneId);

    /** 마일스톤 ID로 마일스톤 상태 업데이트. */
    int updateMilestoneStatusById(
            @Param("milestoneId") Integer milestoneId,
            @Param("status") String status
    );
}
