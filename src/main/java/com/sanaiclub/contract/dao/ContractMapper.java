package com.sanaiclub.contract.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.sanaiclub.contract.model.vo.ContractVO;
import com.sanaiclub.contract.model.dto.ContractDetailDTO;

import java.util.List;

/**
 * ============================================================================
 * ContractMapper - 계약(Contract) 데이터 접근 인터페이스
 * ============================================================================
 * 
 * [역할]
 * - contracts 테이블에 대한 데이터 접근 메서드를 정의
 * - MyBatis Mapper 인터페이스로, XML 파일(contractMapper.xml)과 연결
 * - Service 계층에서 호출하여 계약 관련 데이터베이스 작업 수행
 * 
 * [책임]
 * - SQL 쿼리 실행 (INSERT, SELECT, UPDATE)
 * - 파라미터 바인딩 및 결과 매핑
 * - 비즈니스 로직은 포함하지 않음 (순수 데이터 접근만)
 * 
 * [사용 계층]
 * - Service 계층(ContractService)에서만 호출
 * - Controller는 직접 호출하지 않음 (Service를 통해서만 접근)
 * 
 * [매핑 파일]
 * - src/main/resources/mybatis/mappers/contract/contractMapper.xml
 * - 각 메서드는 XML의 <insert>, <select>, <update> 태그와 매핑
 * 
 * [네이밍 규칙]
 * - insert*: 데이터 삽입
 * - select*: 데이터 조회
 * - update*: 데이터 수정
 * - delete*: 데이터 삭제 (현재 미사용)
 * 
 * ============================================================================
 */
@Mapper
public interface ContractMapper {

    /**
     * 새 계약 생성
     * 
     * [기능]
     * - 새로운 계약을 contracts 테이블에 INSERT
     * - INSERT 후 자동 생성된 contract_id를 반환
     * 
     * [파라미터]
     * @param contract 계약 정보를 담은 ContractVO 객체
     * @param resultMap INSERT 후 생성된 contract_id를 담을 Map (MyBatis가 자동 설정)
     * 
     * [반환값]
     * @return INSERT된 행의 개수 (보통 1)
     * 
     * [주의사항]
     * - contractId는 AUTO_INCREMENT이므로 INSERT 시 명시하지 않음
     * - resultMap의 "contractId" 키에 생성된 ID가 자동 할당됨
     * 
     * [호출 위치]
     * - ContractService.createContract()
     */
    int insertContract(@Param("contract") ContractVO contract, @Param("contractId") java.util.Map<String, Object> resultMap);

    /**
     * 계약 ID로 계약 정보 조회
     * 
     * [기능]
     * - 특정 계약 ID로 계약의 모든 정보를 조회
     * - 가장 기본적인 계약 조회 메서드
     * 
     * [파라미터]
     * @param contractId 조회할 계약의 ID (PK)
     * 
     * [반환값]
     * @return ContractVO 객체 (계약 정보), 없으면 null
     * 
     * [호출 위치]
     * - ContractService.getContractById()
     * - ContractFormController: 계약 상세 페이지
     */
    ContractVO selectContractById(
            @Param("contractId") Integer contractId
    );

    /**
     * 계약 상태 변경
     * 
     * [기능]
     * - 계약의 상태를 변경 (WAITING → SIGNED, SIGNED → TERMINATED 등)
     * - 필요시 취소 사유(cancel_reason)도 함께 업데이트
     * 
     * [파라미터]
     * @param contractId 상태를 변경할 계약의 ID
     * @param contractStatus 새로운 계약 상태 (WAITING, SIGNED, TERMINATED, COMPLETED)
     * @param rejectReason (선택) 거절/취소 사유, null 가능
     * 
     * [반환값]
     * @return UPDATE된 행의 개수 (보통 1)
     * 
     * [호출 위치]
     * - ContractService.acceptContract(): 계약 수락
     * - ContractService.rejectContract(): 계약 거절
     * - ContractService.finalizeContract(): 계약 완료
     * - ContractService.cancelContract(): 계약 취소
     */
    int updateContractStatus(
            @Param("contractId") Integer contractId,
            @Param("contractStatus") String contractStatus,
            @Param("rejectReason") String rejectReason
    );
    
    /**
     * 계약 취소 사유 업데이트
     * 
     * [기능]
     * - 계약의 cancel_reason만 업데이트
     * - 상태 변경 없이 취소 사유만 변경할 때 사용
     * 
     * [파라미터]
     * @param contractId 업데이트할 계약의 ID
     * @param cancelReason 취소 사유 (null 가능, null이면 cancel_reason을 NULL로 설정)
     * 
     * [반환값]
     * @return UPDATE된 행의 개수 (보통 1)
     * 
     * [호출 위치]
     * - ContractService.rejectPayment(): 일시지급 거부 시 cancel_reason을 null로 설정
     */
    int updateCancelReason(
            @Param("contractId") Integer contractId,
            @Param("cancelReason") String cancelReason
    );

    /**
     * 원본 계약서 파일 경로 업데이트
     * 
     * [기능]
     * - 계약서 PDF 파일이 업로드된 후, 해당 파일의 경로를 contracts 테이블에 저장
     * - origin_contract_url 컬럼 업데이트
     * 
     * [파라미터]
     * @param contractId 업데이트할 계약의 ID
     * @param originContractUrl 원본 계약서 파일의 저장 경로
     *                          예) "contracts/1/100/50/contract_20240101.pdf"
     * 
     * [반환값]
     * @return UPDATE된 행의 개수 (보통 1)
     * 
     * [호출 위치]
     * - ContractFileController: 파일 업로드 후 경로 저장
     */
    int updateOriginContractUrl(
        @Param("contractId") Integer contractId,
        @Param("originContractUrl") String originContractUrl
    );
    
    /**
     * 경로 패턴으로 계약서 파일 경로 목록 조회
     * 
     * [기능]
     * - 특정 경로 패턴과 일치하는 계약서 파일 경로들을 조회
     * - 확정된 계약(TERMINATED 제외)의 파일만 조회
     * 
     * [파라미터]
     * @param pathPattern LIKE 패턴 문자열
     *                    예) "contracts/1/100/%" → 클라이언트 1, 프로젝트 100의 모든 계약서
     * 
     * [반환값]
     * @return origin_contract_url 목록 (List<String>)
     * 
     * [호출 위치]
     * - ContractService.getContractByPathPattern(): 기존 계약 확인
     * - ContractFileService: 파일 중복 체크
     */
    List<String> selectOriginContractUrlsByPathPattern(
        @Param("pathPattern") String pathPattern
    );
    
    /**
     * 경로 패턴으로 기존 계약 조회 (프로젝트 조인 버전)
     * 
     * [기능]
     * - 특정 클라이언트/프로젝트/프리랜서 조합의 기존 계약을 조회
     * - origin_contract_url 패턴을 통해 계약을 찾음
     * - 프로젝트 정보와 조인하여 정확성 보장
     * - 가장 최근 계약 1개만 반환
     * 
     * [파라미터]
     * @param clientId 클라이언트 ID
     * @param projectId 프로젝트 ID
     * @param freelancerId 프리랜서 ID
     * 
     * [반환값]
     * @return ContractVO 객체 (기존 계약 정보), 없으면 null
     * 
     * [경로 패턴]
     * - origin_contract_url 형식: "contracts/{clientId}/{projectId}/{freelancerId}/{filename}"
     * 
     * [호출 위치]
     * - ContractService.getContractByPathPattern(): 기존 계약 확인
     * - ContractService.createContract(): 계약 생성 전 중복 확인
     * - ContractService.updateContract(): 계약 수정 전 기존 계약 조회
     */
    ContractVO selectContractByPathPattern(
        @Param("clientId") Integer clientId,
        @Param("projectId") Integer projectId,
        @Param("freelancerId") Integer freelancerId
    );
    
    /**
     * 계약 정보 전체 업데이트
     * 
     * [기능]
     * - 기존 계약의 모든 정보를 업데이트
     * - 계약 수정 시 사용
     * 
     * [파라미터]
     * @param contract 수정할 계약 정보를 담은 ContractVO 객체
     *                 contractId 필드는 필수 (업데이트 대상 식별)
     * 
     * [반환값]
     * @return UPDATE된 행의 개수 (보통 1)
     * 
     * [주의사항]
     * - 모든 컬럼을 업데이트하므로, 일부만 변경하려면 Service 계층에서 기존 값 유지 필요
     * 
     * [호출 위치]
     * - ContractService.updateContract(): 계약 수정
     * - ContractService.finalizeContract(): 계약 완료 (평점 등록 포함)
     */
    int updateContract(@Param("contract") ContractVO contract);
    
    /**
     * 클라이언트의 계약 목록 조회
     * 
     * [기능]
     * - 특정 클라이언트의 모든 계약 목록을 조회
     * - origin_contract_url 패턴을 통해 클라이언트의 계약들을 필터링
     * 
     * [파라미터]
     * @param pathPattern LIKE 패턴 문자열
     *                    예) "contracts/1/%" → 클라이언트 ID가 1인 모든 계약
     * 
     * [반환값]
     * @return 계약 목록 (List<ContractVO>), 최신순 정렬
     * 
     * [호출 위치]
     * - ClientContractManagementController: 클라이언트 계약 목록
     * - ContractService: 클라이언트별 계약 통계
     */
    List<ContractVO> selectContractsByClientPathPattern(
        @Param("pathPattern") String pathPattern
    );
    
    /**
     * 모든 계약 목록 조회
     * 
     * [기능]
     * - 시스템의 모든 계약 목록을 조회
     * - 주로 프리랜서가 자신과 관련된 모든 계약을 볼 때 사용
     * 
     * [파라미터]
     * - 없음 (모든 계약 조회)
     * 
     * [반환값]
     * @return 모든 계약 목록 (List<ContractVO>), 최신순 정렬
     * 
     * [주의사항]
     * - 대량의 데이터가 있을 경우 성능 고려 필요 (페이징 고려)
     * 
     * [호출 위치]
     * - FreelancerContractController: 프리랜서 계약 목록
     * - 관리자 페이지: 전체 계약 조회
     */
    List<ContractVO> selectAllContracts();
    
    /**
     * 계약 목록 조회 (프로젝트 및 상대방 정보 포함)
     * 
     * [기능]
     * - 모든 계약 목록을 조회하되, 프로젝트 이름과 상대방 이름을 함께 조회
     * - LEFT JOIN을 사용하여 프로젝트, 프리랜서, 클라이언트 정보 포함
     * - 사이드바 표시용으로 최적화
     * 
     * [반환값]
     * @return 계약 목록 (List<Map<String, Object>>)
     *         - contract: ContractVO
     *         - projectTitle: 프로젝트 이름
     *         - freelancerName: 프리랜서 이름
     *         - clientName: 클라이언트 이름
     * 
     * [호출 위치]
     * - ContractService: 계약 목록 조회 시
     */
    List<java.util.Map<String, Object>> selectAllContractsWithDetails();
    
    /**
     * 계약 단건 조회 (프로젝트 및 상대방 정보 포함)
     * 
     * [기능]
     * - 계약 ID로 단건 조회하되, 프로젝트 이름과 상대방 이름을 함께 조회
     * - LEFT JOIN을 사용하여 프로젝트, 프리랜서, 클라이언트 정보 포함
     * 
     * [반환값]
     * @return 계약 정보 (Map<String, Object>)
     *         - contractId, contractStartDate 등 Contract 정보
     *         - projectTitle: 프로젝트 이름
     *         - freelancerName: 프리랜서 이름
     *         - clientName: 클라이언트 이름
     * 
     * [호출 위치]
     * - ContractService: 계약 단건 조회 시
     */
    java.util.Map<String, Object> selectContractWithDetailsById(Integer contractId);
    
    /**
     * 계약 상세 정보 조회 (다중 테이블 조인)
     * 
     * [기능]
     * - 계약 ID로 계약의 상세 정보를 조회하되, 관련된 모든 정보를 함께 조회
     * - 계약뿐만 아니라 프로젝트, 클라이언트, 프리랜서, 회사 정보까지 포함
     * 
     * [파라미터]
     * @param contractId 조회할 계약의 ID
     * 
     * [반환값]
     * @return ContractDetailDTO 객체 (계약 상세 정보)
     *         - contract: 계약 정보
     *         - project: 프로젝트 정보
     *         - freelancerUser: 프리랜서 사용자 정보
     *         - freelancerProfile: 프리랜서 프로필
     *         - clientUser: 클라이언트 사용자 정보
     *         - clientProfile: 클라이언트 프로필
     *         - company: 회사 정보
     * 
     * [주의사항]
     * - LEFT JOIN을 사용하므로, 관련 정보가 없어도 계약 정보는 반환됨
     * - origin_contract_url이 NULL이거나 형식이 맞지 않으면 조인 실패 (NULL 반환)
     * 
     * [호출 위치]
     * - ContractService.getContractDetail(): 계약 상세 정보 조회
     * - ContractFormController: 계약 상세 페이지
     * - ContractApiController: API로 상세 정보 요청
     */
    ContractDetailDTO selectContractDetailWithJoin(@Param("contractId") Integer contractId);
    
    /**
     * 프로젝트 ID로 프로젝트 정보 조회 (contract 도메인에서 사용)
     * 
     * [기능]
     * - 계약서 작성 시 프로젝트 정보가 필요할 때 사용
     * - contract 도메인 내에서 프로젝트 정보를 직접 조회
     * 
     * [파라미터]
     * @param projectId 조회할 프로젝트의 ID
     * 
     * [반환값]
     * @return ProjectsVO 객체 (프로젝트 정보), 없으면 null
     * 
     * [호출 위치]
     * - ContractFormController: 계약서 작성 화면에서 프로젝트 정보 조회
     */
    com.sanaiclub.project.model.vo.ProjectsVO selectProjectById(@Param("projectId") Integer projectId);
    
    /**
     * 클라이언트 ID로 프로젝트 목록 조회 (contract 도메인에서 사용)
     * 
     * [기능]
     * - 계약서 작성 시 클라이언트의 프로젝트 목록이 필요할 때 사용
     * - contract 도메인 내에서 프로젝트 목록을 직접 조회
     * 
     * [파라미터]
     * @param clientId 조회할 클라이언트의 ID
     * 
     * [반환값]
     * @return 프로젝트 목록 (List<ProjectsVO>), READY 상태인 프로젝트만 반환
     * 
     * [호출 위치]
     * - ContractFormController: 계약서 작성 화면에서 프로젝트 목록 조회
     */
    List<com.sanaiclub.project.model.vo.ProjectsVO> selectProjectsByClientId(@Param("clientId") Integer clientId);
    
    /**
     * 프로젝트에 지원한 프리랜서 목록 조회 (contract 도메인에서 사용)
     * 
     * [기능]
     * - 계약서 작성 시 프로젝트에 지원한 프리랜서 목록이 필요할 때 사용
     * - contract 도메인 내에서 프리랜서 목록을 직접 조회
     * 
     * [파라미터]
     * @param projectId 조회할 프로젝트의 ID
     * 
     * [반환값]
     * @return 프리랜서 정보 리스트 (List<Map<String, Object>>)
     *         - id: 프리랜서 ID (userId)
     *         - name: 프리랜서 이름
     *         - email: 프리랜서 이메일
     * 
     * [호출 위치]
     * - ContractApiController: AJAX로 프리랜서 목록 조회
     */
    List<java.util.Map<String, Object>> selectFreelancersByProjectId(@Param("projectId") Integer projectId);
}
