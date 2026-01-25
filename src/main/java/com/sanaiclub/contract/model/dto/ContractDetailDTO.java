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
 * ContractDetailDTO - 계약 상세 정보 DTO (JOIN 결과)
 * ============================================================================
 * 
 * [역할]
 * 계약 상세 정보를 조회할 때 여러 테이블을 JOIN하여 조회한 결과를 담는 DTO입니다.
 * 계약 정보뿐만 아니라 관련된 프로젝트, 프리랜서, 클라이언트, 회사 정보를 모두 포함하여
 * 상세 페이지에 필요한 모든 데이터를 한 번에 전달합니다.
 * 
 * [연관 파일]
 * 
 * DAO 계층:
 * - ContractMapper.selectContractDetailWithJoin(): 여러 테이블 JOIN 쿼리 실행
 *   * contracts, projects, users (프리랜서), users (클라이언트), 
 *     freelancer_profiles, client_profiles, companies 테이블 LEFT JOIN
 * 
 * Controller 계층:
 * - ClientContractManagementController: 클라이언트 계약 관리 페이지
 *   * contractManagement.jsp에 전달하여 상세 정보 표시
 * - FreelancerContractController: 프리랜서 계약 목록 페이지
 *   * freelancerContractList.jsp에 전달하여 상세 정보 표시
 * 
 * View 계층:
 * - contractManagement.jsp: 클라이언트 계약 관리 페이지
 *   * 계약 상세 정보, 프로젝트 정보, 프리랜서 정보, 클라이언트 정보 표시
 * - freelancerContractList.jsp: 프리랜서 계약 목록 페이지
 *   * 계약 상세 정보, 프로젝트 정보, 클라이언트 정보 표시
 * 
 * [다른 영역의 VO 재사용]
 * 
 * 이 DTO는 다른 영역(user, project)의 VO를 중첩으로 사용하여 코드 재사용성을
 * 높이고 일관성을 유지합니다. 각 영역의 VO는 해당 도메인의 데이터를 담당하며,
 * 계약 도메인에서는 이를 조합하여 사용합니다.
 * 
 * 재사용되는 VO:
 * - ProjectsVO (project 패키지): 프로젝트 정보
 *   * projectId, title, description, budget, startDate, deadlineDate 등
 *   * 계약과 연결된 프로젝트의 상세 정보
 * 
 * - UserVO (user 패키지): 사용자 계정 정보 (프리랜서 및 클라이언트)
 *   * userId, loginId, email, name, phone, userType 등
 *   * 프리랜서와 클라이언트의 기본 계정 정보
 * 
 * - FreelancerProfileVO (user 패키지): 프리랜서 프로필 정보
 *   * freelancerId, nickname, introduction, portfolioUrl 등
 *   * 프리랜서의 상세 프로필 정보
 * 
 * - ClientProfileVO (user 패키지): 클라이언트 프로필 정보
 *   * clientId, companyId, clientName 등
 *   * 클라이언트의 상세 프로필 정보
 * 
 * - CompanyVO (user 패키지): 회사 정보
 *   * companyId, companyName, businessNumber, address 등
 *   * 클라이언트가 소속된 회사 정보
 * 
 * [JOIN 쿼리 구조]
 * 
 * ContractMapper.selectContractDetailWithJoin()에서 실행되는 쿼리:
 * 
 * SELECT 
 *   c.*,                    -- contracts 테이블 (ContractVO)
 *   p.*,                    -- projects 테이블 (ProjectsVO)
 *   fu.*,                   -- users 테이블 (프리랜서, UserVO)
 *   fp.*,                   -- freelancer_profiles 테이블 (FreelancerProfileVO)
 *   cu.*,                   -- users 테이블 (클라이언트, UserVO)
 *   cp.*,                   -- client_profiles 테이블 (ClientProfileVO)
 *   co.*                    -- companies 테이블 (CompanyVO)
 * FROM contracts c
 * LEFT JOIN projects p ON ...
 * LEFT JOIN users fu ON ... (프리랜서)
 * LEFT JOIN freelancer_profiles fp ON ...
 * LEFT JOIN users cu ON ... (클라이언트)
 * LEFT JOIN client_profiles cp ON ...
 * LEFT JOIN companies co ON ...
 * WHERE c.contract_id = ?
 * 
 * [데이터 흐름]
 * 
 * 1. Controller에서 contractId로 조회 요청
 * 2. ContractMapper.selectContractDetailWithJoin() 실행
 * 3. JOIN 결과를 Map<String, Object>로 반환
 * 4. MyBatis resultMap을 통해 각 VO 객체로 매핑
 * 5. ContractDetailDTO.builder()로 DTO 생성
 * 6. Controller → Model에 추가
 * 7. JSP에서 ${contractDetail.project.title} 같은 방식으로 접근
 * 
 * [사용 예시]
 * 
 * JSP에서의 사용:
 * - ${contractDetail.contract.contractId}: 계약 ID
 * - ${contractDetail.project.title}: 프로젝트 제목
 * - ${contractDetail.freelancerUser.name}: 프리랜서 이름
 * - ${contractDetail.clientProfile.clientName}: 클라이언트 이름
 * - ${contractDetail.company.companyName}: 회사명
 * 
 * [주의사항]
 * 
 * - JOIN 실패 시에도 계약 기본 정보는 표시 가능 (LEFT JOIN 사용)
 * - project, freelancerUser, clientUser 등은 null일 수 있음
 * - null 체크 후 사용해야 함 (JSP에서 <c:if> 사용)
 * - 계약이 존재하지 않으면 null 반환
 * 
 * [책임 분리]
 * 
 * - ContractDetailDTO: 여러 VO를 조합하여 전달하는 컨테이너 역할
 * - 각 VO: 자신의 도메인 데이터만 담당
 * - Controller: DTO를 Model에 추가하여 View에 전달
 * - View: DTO의 중첩된 VO에 접근하여 데이터 표시
 * 
 * [장점]
 * 
 * 1. 코드 재사용성: 다른 영역의 VO를 재사용하여 중복 코드 방지
 * 2. 일관성: 각 도메인의 VO를 그대로 사용하여 데이터 구조 일관성 유지
 * 3. 유지보수성: 각 도메인의 VO가 변경되어도 계약 도메인은 영향 없음
 * 4. 명확성: 각 필드가 어느 도메인에 속하는지 명확히 구분
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
