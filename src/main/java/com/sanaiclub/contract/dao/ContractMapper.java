package com.sanaiclub.contract.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.sanaiclub.contract.model.vo.ContractVO;
import com.sanaiclub.contract.model.dto.ContractDetailDTO;

import java.util.List;

/** 계약 데이터 접근 인터페이스. Service 계층에서만 호출. */
@Mapper
public interface ContractMapper {

    /** 새 계약 생성. INSERT 후 생성된 contract_id를 resultMap에 반환. */
    int insertContract(@Param("contract") ContractVO contract, @Param("resultMap") java.util.Map<String, Object> resultMap, @Param("contractId") Integer contractId);

    /** 계약 ID로 계약 정보 조회. */
    ContractVO selectContractById(
            @Param("contractId") Integer contractId
    );

    /** 계약 상태 변경. 필요시 취소 사유도 함께 업데이트. */
    int updateContractStatus(
            @Param("contractId") Integer contractId,
            @Param("contractStatus") String contractStatus,
            @Param("rejectReason") String rejectReason
    );
    
    /** 계약 취소 사유만 업데이트. 상태 변경 없음. */
    int updateCancelReason(
            @Param("contractId") Integer contractId,
            @Param("cancelReason") String cancelReason
    );

    /** 원본 계약서 파일 경로 업데이트. */
    int updateOriginContractUrl(
            @Param("contractId") Integer contractId,
            @Param("originContractUrl") String originContractUrl
    );

    /** 경로 패턴으로 계약서 파일 경로 목록 조회. TERMINATED 제외. */
    List<String> selectOriginContractUrlsByPathPattern(
            @Param("pathPattern") String pathPattern
    );

    /** 경로 패턴으로 기존 계약 조회. 프로젝트 조인, 최신 1개만 반환. */
    ContractVO selectContractByPathPattern(
            @Param("clientId") Integer clientId,
            @Param("projectId") Integer projectId,
            @Param("freelancerId") Integer freelancerId
    );

    /** 계약 정보 전체 업데이트. */
    int updateContract(@Param("contract") ContractVO contract);

    /** 클라이언트의 계약 목록 조회. origin_contract_url 패턴으로 필터링. */
    List<ContractVO> selectContractsByClientPathPattern(
            @Param("pathPattern") String pathPattern
    );

    /** 모든 계약 목록 조회. 최신순 정렬. */
    List<ContractVO> selectAllContracts();

    /** 계약 목록 조회. 프로젝트 및 상대방 정보 포함. */
    List<java.util.Map<String, Object>> selectAllContractsWithDetails();

    /** 계약 단건 조회. 프로젝트 및 상대방 정보 포함. */
    java.util.Map<String, Object> selectContractWithDetailsById(Integer contractId);

    /** 계약 상세 정보 조회. 프로젝트, 클라이언트, 프리랜서, 회사 정보 포함. */
    ContractDetailDTO selectContractDetailWithJoin(@Param("contractId") Integer contractId);

    /** 클라이언트의 계약 목록 조회. 프로젝트, 상대방 정보, 마일스톤 집계 포함. */
    List<java.util.Map<String, Object>> selectContractsByClientIdWithDetails(@Param("clientId") Integer clientId);

    /** 프리랜서의 계약 목록 조회. 프로젝트, 상대방 정보, 마일스톤 집계 포함. */
    List<java.util.Map<String, Object>> selectContractsByFreelancerIdWithDetails(@Param("freelancerId") Integer freelancerId);

    /**
     * 계약 ID로 클라이언트 ID 조회
     */
    Integer selectClientIdByContractId(@Param("contractId") Integer contractId);


    /** projectId와 freelancerId로 application_id 조회 */
    Integer selectApplicationIdByProjectAndFreelancer(
            @Param("projectId") Integer projectId,
            @Param("freelancerId") Integer freelancerId
    );
}