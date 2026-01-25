package com.sanaiclub.contract.dao;

import com.sanaiclub.contract.model.vo.ContractMilestoneVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * ============================================================================
 * ContractMilestoneMapper - 계약 마일스톤(Milestone) 데이터 접근 인터페이스
 * ============================================================================
 * 
 * [역할]
 * - contract_milestones 테이블에 대한 데이터 접근 메서드를 정의
 * - MyBatis Mapper 인터페이스로, XML 파일(ContractMilestoneMapper.xml)과 연결
 * - Service 계층에서 호출하여 마일스톤 관련 데이터베이스 작업 수행
 * 
 * [책임]
 * - SQL 쿼리 실행 (INSERT, SELECT, DELETE)
 * - 파라미터 바인딩 및 결과 매핑
 * - 비즈니스 로직은 포함하지 않음 (순수 데이터 접근만)
 * 
 * [마일스톤 개념]
 * - 계약의 작업을 여러 단계로 나누어 관리
 * - 각 단계마다 작업 범위와 결제 금액을 정의
 * - 결제 방식이 "MILESTONE"인 계약에서만 사용
 * - 예) 1단계: 기획 및 설계 (30%), 2단계: 개발 (50%), 3단계: 테스트 및 배포 (20%)
 * 
 * [사용 계층]
 * - Service 계층(ContractService)에서만 호출
 * - Controller는 직접 호출하지 않음 (Service를 통해서만 접근)
 * 
 * [매핑 파일]
 * - src/main/resources/mybatis/mappers/contract/ContractMilestoneMapper.xml
 * - 각 메서드는 XML의 <insert>, <select>, <delete> 태그와 매핑
 * 
 * [관계]
 * - contract_milestones.contract_id → contracts.contract_id (FK)
 * - 하나의 계약은 여러 개의 마일스톤을 가질 수 있음 (1:N 관계)
 * 
 * ============================================================================
 */
@Mapper
public interface ContractMilestoneMapper {

    /**
     * 마일스톤 등록
     * 
     * [기능]
     * - 계약에 새로운 마일스톤(단계)을 추가
     * - 계약 생성 시 또는 계약 수정 시 마일스톤 정보 저장
     * 
     * [파라미터]
     * @param contractId 마일스톤이 속한 계약의 ID
     * @param step 마일스톤 단계 순서 (1, 2, 3, ...)
     * @param title 마일스톤 이름/제목 (예: "1단계: 기획 및 설계")
     * @param description 작업 범위/설명 (예: "요구사항 분석, 시스템 설계 문서 작성")
     * @param amount 해당 마일스톤의 결제 금액
     * 
     * [반환값]
     * @return INSERT된 행의 개수 (보통 1)
     * 
     * [주의사항]
     * - step은 1부터 시작하며, 계약 내에서 중복되지 않아야 함
     * - 같은 contractId에 대해 여러 마일스톤을 순차적으로 INSERT 가능
     * - amount는 해당 마일스톤의 금액이며, 모든 마일스톤의 amount 합계가 total_budget과 일치해야 함
     * 
     * [호출 위치]
     * - ContractService.createContract(): 계약 생성 시 마일스톤 저장
     * - ContractService.updateContract(): 계약 수정 시 마일스톤 저장
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
     * 
     * [기능]
     * - 특정 계약의 모든 마일스톤을 조회
     * - 계약 상세 페이지에서 단계별 작업 계획 표시
     * - 결제 진행 상황 확인
     * 
     * [파라미터]
     * @param contractId 조회할 계약의 ID
     * 
     * [반환값]
     * @return 마일스톤 목록 (List<ContractMilestoneVO>), 단계 순서대로 정렬
     * 
     * [정렬]
     * - step_order 오름차순 (1단계, 2단계, 3단계...)
     * 
     * [주의사항]
     * - contractId가 존재하지 않거나 마일스톤이 없으면 빈 리스트 반환
     * - 결제 방식이 "FIXED"인 계약은 마일스톤이 없을 수 있음
     * 
     * [호출 위치]
     * - ContractService.getContractById(): 계약 조회 시 마일스톤 포함
     * - ContractFormController: 계약 상세 페이지 로드
     * - ContractApiController: API로 마일스톤 목록 요청
     */
    List<ContractMilestoneVO> selectMilestonesByContractId(
            @Param("contractId") Integer contractId
    );

    /**
     * 계약의 모든 마일스톤 삭제
     * 
     * [기능]
     * - 특정 계약의 모든 마일스톤을 삭제
     * - 주로 계약 수정 시 기존 마일스톤을 모두 삭제하고 새로 등록할 때 사용
     * 
     * [파라미터]
     * @param contractId 삭제할 마일스톤이 속한 계약의 ID
     * 
     * [반환값]
     * @return DELETE된 행의 개수
     * 
     * [주의사항]
     * - contractId가 존재하지 않으면 0 반환 (에러 없음)
     * - 해당 계약의 모든 마일스톤이 삭제됨 (부분 삭제 불가)
     * - 삭제 후에는 insertMilestone으로 새 마일스톤을 등록해야 함
     * 
     * [트랜잭션]
     * - 일반적으로 updateContract와 함께 트랜잭션으로 처리
     * - 삭제 실패 시 롤백되어 데이터 일관성 유지
     * 
     * [호출 위치]
     * - ContractService.updateContract(): 계약 수정 시 기존 마일스톤 삭제
     * - ContractService.deleteContract(): 계약 삭제 시 (있는 경우)
     */
    int deleteMilestonesByContractId(
            @Param("contractId") Integer contractId
    );

    /**
     * 마일스톤 상태 업데이트
     * 
     * [기능]
     * - 특정 마일스톤의 상태를 변경 (WAITING → REQUESTED → DEPOSITED → PAID)
     * - 프리랜서가 지급 요청하거나, 클라이언트가 지급 수락할 때 사용
     * 
     * [파라미터]
     * @param contractId 마일스톤이 속한 계약의 ID
     * @param step 업데이트할 마일스톤의 단계 순서 (null이면 계약의 모든 WAITING 마일스톤)
     * @param status 변경할 상태 (REQUESTED, DEPOSITED, PAID 등)
     * 
     * [반환값]
     * @return UPDATE된 행의 개수
     * 
     * [주의사항]
     * - step이 null이면 해당 계약의 모든 WAITING 마일스톤 상태를 변경 (일시지급 시)
     * - 상태 전이는 비즈니스 로직에서 검증해야 함
     * 
     * [호출 위치]
     * - ContractService.requestPayment(): 프리랜서 지급 요청
     * - ContractService.approvePayment(): 클라이언트 지급 수락
     */
    int updateMilestoneStatus(
            @Param("contractId") Integer contractId,
            @Param("step") Integer step,
            @Param("status") String status
    );
}
