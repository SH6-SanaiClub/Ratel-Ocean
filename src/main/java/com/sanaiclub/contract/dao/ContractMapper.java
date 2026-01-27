package com.sanaiclub.contract.dao;

import com.sanaiclub.contract.model.dto.ContractResponseDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.sanaiclub.contract.model.vo.ContractVO;
import com.sanaiclub.contract.model.dto.ContractDetailDTO;

import java.util.List;


@Mapper
public interface ContractMapper {

    /**
     * 새 계약 생성
     */
    int insertContract(@Param("contract") ContractVO contract, @Param("contractId") java.util.Map<String, Object> resultMap);

    /**
     * 계약 ID로 계약 정보 조회
     */
    ContractVO selectContractById(
            @Param("contractId") Integer contractId
    );

    /**
     * 계약 상태 변경
     */
    int updateContractStatus(
            @Param("contractId") Integer contractId,
            @Param("contractStatus") String contractStatus,
            @Param("rejectReason") String rejectReason
    );

    /**
     * 원본 계약서 파일 경로 업데이트
     */
    int updateOriginContractUrl(
        @Param("contractId") Integer contractId,
        @Param("originContractUrl") String originContractUrl
    );
    
    /**
     * 경로 패턴으로 계약서 파일 경로 목록 조회
     */
    List<String> selectOriginContractUrlsByPathPattern(
        @Param("pathPattern") String pathPattern
    );
    
    /**
     * 경로 패턴으로 기존 계약 조회 (프로젝트 조인 버전)
     */
    ContractVO selectContractByPathPattern(
        @Param("clientId") Integer clientId,
        @Param("projectId") Integer projectId,
        @Param("freelancerId") Integer freelancerId
    );
    
    /**
     * 계약 정보 전체 업데이트
     */
    int updateContract(@Param("contract") ContractVO contract);
    
    /**
     * 클라이언트의 계약 목록 조회
     */
    List<ContractVO> selectContractsByClientPathPattern(
        @Param("pathPattern") String pathPattern
    );
    
    /**
     * 모든 계약 목록 조회
     */
    List<ContractVO> selectAllContracts();
    
    /**
     * 계약 상세 정보 조회 (다중 테이블 조인)
     */
    ContractDetailDTO selectContractDetailWithJoin(@Param("contractId") Integer contractId);
    
    /**
     * 프로젝트 ID로 프로젝트 정보 조회 (contract 도메인에서 사용)
     */
    com.sanaiclub.project.model.vo.ProjectsVO selectProjectById(@Param("projectId") Integer projectId);
    
    /**
     * 클라이언트 ID로 프로젝트 목록 조회 (contract 도메인에서 사용)
     */
    List<com.sanaiclub.project.model.vo.ProjectsVO> selectProjectsByClientId(@Param("clientId") Integer clientId);
    
    /**
     * 프로젝트에 지원한 프리랜서 목록 조회 (contract 도메인에서 사용)
     */
    List<java.util.Map<String, Object>> selectFreelancersByProjectId(@Param("projectId") Integer projectId);

    /**
     * 계약 결제 상태 업데이트
     */
    int updatePaymentStatus(@Param("contractId") Integer contractId,
                            @Param("paymentStatus") String paymentStatus);

    /**
     * 클라이언트 아이디로 계약 모두 조회
     */
    List<ContractResponseDTO> selectContractsByClientId(Integer clientId);
}
