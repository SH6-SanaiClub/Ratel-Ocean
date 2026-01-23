package com.sanaiclub.contract.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.sanaiclub.contract.model.vo.ContractVO;
import com.sanaiclub.contract.model.vo.ContractMilestoneVO;

import java.util.List;

@Mapper
public interface ContractDao {

    int insertContract(@Param("contract") ContractVO contract, @Param("contractId") java.util.Map<String, Object> resultMap);

    int insertMilestone(
            @Param("contractId") Integer contractId,
            @Param("step") Integer step,
            @Param("title") String title,
            @Param("description") String description,
            @Param("amount") Long amount
    );

    ContractVO selectContractById(
            @Param("contractId") Integer contractId
    );

    List<ContractMilestoneVO> selectMilestonesByContractId(
            @Param("contractId") Integer contractId
    );

    int updateContractStatus(
            @Param("contractId") Integer contractId,
            @Param("contractStatus") String contractStatus,
            @Param("rejectReason") String rejectReason
    );

    /**
     * PDF 경로를 contracts.origin_contract_url에 업데이트
     */
    int updateOriginContractUrl(
        @Param("contractId") Integer contractId,
        @Param("originContractUrl") String originContractUrl
    );
    
    /**
     * 특정 프로젝트 폴더 패턴과 일치하는 확정된 계약의 origin_contract_url 목록 조회
     * 경로 패턴: contracts/{clientId}/{projectId}/%
     */
    List<String> selectOriginContractUrlsByPathPattern(
        @Param("pathPattern") String pathPattern
    );
    
    /**
     * 같은 프로젝트/프리랜서 조합의 기존 계약 조회
     * origin_contract_url 패턴으로 찾기: contracts/{clientId}/{projectId}/{freelancerId}/%
     * 가장 최근 계약 반환
     */
    ContractVO selectContractByPathPattern(
        @Param("clientId") Integer clientId,
        @Param("projectId") Integer projectId,
        @Param("freelancerId") Integer freelancerId
    );
    
    /**
     * 계약 정보 업데이트 (기존 계약 수정)
     */
    int updateContract(@Param("contract") ContractVO contract);
    
    /**
     * 계약의 마일스톤 삭제
     */
    int deleteMilestonesByContractId(
        @Param("contractId") Integer contractId
    );
    
    /**
     * 클라이언트의 계약 목록 조회 (origin_contract_url 패턴으로)
     * 경로 패턴: contracts/{clientId}/%
     */
    List<ContractVO> selectContractsByClientPathPattern(
        @Param("pathPattern") String pathPattern
    );
    
    /**
     * 모든 계약 목록 조회 (프리랜서용 - 모든 계약 표시)
     */
    List<ContractVO> selectAllContracts();
}
