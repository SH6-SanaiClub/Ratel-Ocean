package com.sanaiclub.contract.model.dto;

import com.sanaiclub.contract.model.vo.ContractVO;
import com.sanaiclub.project.model.vo.ProjectsVO;
import com.sanaiclub.user.model.vo.UserVO;
import com.sanaiclub.user.model.vo.FreelancerProfileVO;
import com.sanaiclub.user.model.vo.ClientProfileVO;
import com.sanaiclub.user.model.vo.CompanyVO;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * ============================================================================
 * ContractDetailDTO - 계약 상세 정보 DTO
 * ============================================================================
 * 
 * [역할]
 * - contract_id를 통해 JOIN하여 조회한 계약 상세 정보
 * - contract, project, freelancer, client 정보를 함께 담음
 * - Controller ↔ Service 간 데이터 전달용
 * - 계약 상세 페이지에서 필요한 모든 정보를 한 번에 제공
 * 
 * [데이터 흐름]
 * - ContractMapper.selectContractDetailWithJoin() → ContractDetailDTO
 * - ContractService.getContractDetail() → ContractDetailDTO
 * - ContractFormController, ContractApiController 등에서 사용
 * 
 * [JOIN 구조]
 * - contracts (기본 테이블)
 * - projects (LEFT JOIN): origin_contract_url에서 projectId 추출하여 조인
 * - users - 프리랜서 (LEFT JOIN): origin_contract_url에서 freelancerId 추출하여 조인
 * - freelancer_profiles (LEFT JOIN): 프리랜서 프로필 정보
 * - users - 클라이언트 (LEFT JOIN): projects.client_id로 조인
 * - client_profiles (LEFT JOIN): 클라이언트 프로필 정보
 * - companies (LEFT JOIN): 회사 정보
 * 
 * [포함 정보]
 * - contract: 계약 기본 정보 (ContractVO)
 * - project: 프로젝트 정보 (ProjectsVO, project 도메인)
 * - freelancerUser: 프리랜서 사용자 정보 (UserVO, user 도메인)
 * - freelancerProfile: 프리랜서 프로필 정보 (FreelancerProfileVO, user 도메인)
 * - clientUser: 클라이언트 사용자 정보 (UserVO, user 도메인)
 * - clientProfile: 클라이언트 프로필 정보 (ClientProfileVO, user 도메인)
 * - company: 회사 정보 (CompanyVO, user 도메인)
 * 
 * [주의사항]
 * - 다른 도메인의 VO를 포함하지만, contract_id를 통해 JOIN하여 조회한 결과이므로 contract 도메인의 책임 범위 내
 * - LEFT JOIN을 사용하므로, 관련 정보가 없어도 계약 정보는 반환됨
 * - origin_contract_url이 NULL이거나 형식이 맞지 않으면 조인 실패 (NULL 반환)
 * - MyBatis resultMap을 사용하여 복잡한 객체 구조 매핑
 * 
 * [사용 위치]
 * - 계약 상세 페이지: 모든 관련 정보 표시
 * - 계약서 생성: 클라이언트/프리랜서 정보 필요
 * - API 응답: REST API로 상세 정보 반환
 * 
 * ============================================================================
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ContractDetailDTO {
    private ContractVO contract;
    private ProjectsVO project;
    private UserVO freelancerUser;
    private FreelancerProfileVO freelancerProfile;
    private UserVO clientUser;
    private ClientProfileVO clientProfile;
    private CompanyVO company;
}
