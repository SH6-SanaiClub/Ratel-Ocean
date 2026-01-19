package com.sanaiclub.domain.project.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.ui.Model;
import javax.servlet.http.HttpSession;

import com.sanaiclub.domain.project.dto.ContractReviewDTO;
import com.sanaiclub.domain.project.dto.MilestoneDTO;
import com.sanaiclub.domain.project.dto.ProjectCreateRequestDTO;
import com.sanaiclub.domain.project.service.ProjectService;

import java.time.LocalDate;
import java.util.Arrays;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * ProjectController
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [설명]
 * 프로젝트 관리 기능을 담당하는 컨트롤러입니다.
 * 프리랜서의 진행 프로젝트와 클라이언트의 등록 프로젝트를 관리합니다.
 * 
 * [위치]
 * 패키지: com.sanaiclub.domain.project.controller
 * 파일: ProjectController.java
 * 
 * [라우팅]
 * - GET /projects : 프로젝트 목록 및 관리 페이지
 * - GET /dashboard : 메인 대시보드 (프로젝트 요약 표시)
 * 
 * [향후 기능 (미구현)]
 * - GET /projects/{id} : 프로젝트 상세 조회
 * - POST /projects : 프로젝트 생성
 * - PUT /projects/{id} : 프로젝트 수정
 * - DELETE /projects/{id} : 프로젝트 삭제
 * - POST /projects/{id}/apply : 프로젝트 지원 (프리랜서)
 * 
 * @author Team SanaiClub (신한DS 금융 SW 아카데미)
 * @version 1.0
 * @since 2026-01-13
 */
@Controller
@RequestMapping("")
public class ProjectController {

    @Autowired
    private ProjectService projectService;

    /**
     * ─────────────────────────────────────────────────────────────────
     * [프로젝트 대시보드]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /project/dashboard
     * 설명: 프로젝트 대시보드 페이지 (프로젝트 목록 및 검색)
     * 
     * @return "project/dashboard" - src/main/webapp/WEB-INF/views/project/dashboard.jsp 렌더링
     */
    @GetMapping("/project/dashboard")
    public String projectDashboard(Model model) {
        var projectList = projectService.findAllProjects();
        model.addAttribute("projectList", projectList);
        model.addAttribute("currentPage", 1);
        model.addAttribute("totalPages", 1);
        model.addAttribute("startPage", 1);
        model.addAttribute("endPage", 1);
        model.addAttribute("totalElements", projectList.size());
        return "project/dashboard";
    }

    /**
     * 프로젝트 상세 페이지
     */
    @GetMapping("/project/{projectId}")
    public String projectDetail(@PathVariable("projectId") Integer projectId, Model model) {
        var detail = projectService.getProjectDetail(projectId);
        if (detail == null) {
            return "redirect:/project/dashboard?error=notfound";
        }
        model.addAttribute("project", detail);
        return "project/detail";
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [클라이언트 메인 페이지]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /client/main
     * 설명: 클라이언트 로그인/회원가입 후 첫 화면
     * 
     * @return "client/main" - 클라이언트 전용 메인 페이지
     */
    @GetMapping("/client/main")
    public String clientMain() {
        return "client/main";
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [프로젝트 관리]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /projects
     * 설명: 사용자가 진행 중인 프로젝트들을 관리하는 페이지입니다.
     *      - 프리랜서: 수락한 프로젝트 목록, 진행 상황 조회
     *      - 클라이언트: 등록한 프로젝트 목록, 지원자 관리
     * 
     * [표시 정보]
     * - 프로젝트 명
     * - 상태 (진행중/완료/취소)
     * - 진행률
     * - 예산
     * - 마감일
     * - 최종 수정일
     * 
     * @return "project/projects" - src/main/webapp/WEB-INF/views/project/projects.jsp 렌더링
     */
    @GetMapping("/projects")
    public String projects() {
        return "project/projects";
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [클라이언트 계약 첫 단계]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /contract/first
     * 설명: 클라이언트가 프리랜서와의 계약을 시작하는 페이지입니다.
     *      - 프로젝트 공지 상세 내용 재확인
     *      - 계약 대상 프리랜서 정보 확인
     *      - 계약서 PDF 업로드
     * 
     * @return "client_con_first" - src/main/webapp/WEB-INF/views/client_con_first.jsp 렌더링
     */
    @GetMapping("/contract/first")
    public String clientContractFirst() {
        return "client_con_first";
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [클라이언트 계약 두 번째 단계 - PDF 처리 및 AI 분석]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: POST /contract/first
     * 설명: 클라이언트가 업로드한 PDF 계약서를 처리합니다.
     *      1. 파일 저장
     *      2. AI/LLM이 계약서 내용을 구조화 (모의 처리)
     *      3. ContractReviewDTO로 변환하여 client_con_second로 forward
     * 
     * @param contractPdf 업로드된 PDF 계약서 파일
     * @param model Spring Model (request scope)
     * @return "client_con_second" - src/main/webapp/WEB-INF/views/client_con_second.jsp
     */
    @PostMapping("/contract/first")
    public String processContractPdf(MultipartFile contractPdf, Model model) {
        // PDF 파일 받기
        if (contractPdf == null || contractPdf.isEmpty()) {
            model.addAttribute("error", "파일을 업로드해주세요");
            return "client_con_first";
        }

        // 실제로는 여기서:
        // 1. PDF를 서버에 저장 (origin_contract_url)
        // 2. LLM API 호출하여 계약 정보 추출
        // 3. 추출된 정보로 ContractReviewDTO 생성
        // 4. ai_report_url에 분석 결과 저장
        
        // Mock AI Processing: 실제 DB 스키마에 맞춘 데이터
        ContractReviewDTO contract = new ContractReviewDTO();

        // projects 테이블 기반 데이터 (AI가 PDF와 프로젝트 공지에서 추출)
        contract.setProjectId(1L);  // 가상의 project_id
        contract.setClientId(1L);   // projects.client_id
        contract.setFreelancerId(2L);  // 선택된 프리랜서 user_id
        
        // contracts 테이블 매핑: contract_start_date, contract_end_date
        contract.setStartDate(LocalDate.of(2026, 1, 21));  // contract_start_date
        contract.setDeadlineDate(LocalDate.of(2026, 4, 21));  // contract_end_date
        
        // projects.est_duration
        contract.setEstDuration("3개월 (13주)");
        
        // contracts.total_budget
        contract.setBudget(5000000L);
        contract.setBudgetNegotiable(false);

        // AI가 PDF 및 프로젝트 설명에서 추출한 개발 영역 (projects.description에서 파싱)
        contract.setDevelopmentAreas(Arrays.asList(
            "백엔드 개발", 
            "데이터베이스 설계", 
            "API 설계 및 구현",
            "시스템 아키텍처"
        ));

        // AI가 추출한 기술 스택 (projects.description 또는 별도 tech_stacks 테이블)
        contract.setTechnicalStacks(Arrays.asList(
            "Java 17", 
            "Spring MVC 5.3", 
            "MyBatis 3.5",
            "MySQL 8.0",
            "Git",
            "Apache Tomcat 9.0",
            "RESTful API"
        ));

        // projects.communicate_method 매핑 (MESSENGER, VIDEOCALL, EMAIL 등)
        contract.setCommunicationMethods(Arrays.asList("MESSENGER", "VIDEOCALL", "EMAIL"));
        contract.setOtherMethod("");

        // projects.description에서 추출된 예상 산출물
        contract.setExpectedDeliverables(
            "1. RESTful API 서버\n" +
            "   - 사용자 인증 API (회원가입, 로그인, 로그아웃)\n" +
            "   - 프로젝트 관리 API (등록, 조회, 수정, 삭제)\n" +
            "   - 매칭 시스템 API\n" +
            "   - 채팅 및 알림 API\n" +
            "   - 결제 및 정산 API\n\n" +
            "2. 데이터베이스 스키마\n" +
            "   - ERD 설계 문서\n" +
            "   - 테이블 구조 및 인덱스 설계\n" +
            "   - 데이터 무결성 제약조건\n\n" +
            "3. API 문서 (Swagger/OpenAPI)\n" +
            "   - 엔드포인트별 상세 설명\n" +
            "   - 요청/응답 예시\n\n" +
            "4. 소스 코드 및 테스트\n" +
            "   - Git 저장소 (브랜치 전략 포함)\n" +
            "   - 코드 주석 및 README\n" +
            "   - 단위 테스트 코드"
        );

        // AI가 분석한 주요 기능 (projects.description 기반)
        contract.setMainFeatures(
            "【사용자 인증 시스템】\n" +
            "- JWT 기반 인증 구현 (users 테이블 연동)\n" +
            "- 회원가입 (이메일 인증)\n" +
            "- 로그인/로그아웃 (refresh_token 관리)\n" +
            "- 비밀번호 찾기 및 재설정\n" +
            "- 프로필 관리 (freelancer_profiles, client_profiles)\n\n" +
            "【프로젝트 관리 시스템】\n" +
            "- 프로젝트 등록 (projects 테이블 INSERT)\n" +
            "- 카테고리별 필터링 및 검색\n" +
            "- 프로젝트 상세 조회 (project_status: READY/IN_PROGRESS/CLOSED)\n" +
            "- 지원서 제출 및 관리\n" +
            "- 조회수 및 지원자 수 추적\n\n" +
            "【매칭 및 계약 시스템】\n" +
            "- 프리랜서-클라이언트 매칭\n" +
            "- 계약서 PDF 업로드 (origin_contract_url 저장)\n" +
            "- AI 기반 계약 정보 추출 (ai_report_url 생성)\n" +
            "- contracts 테이블에 계약 저장\n" +
            "- contract_status: SIGNED → IN_PROGRESS → COMPLETED\n\n" +
            "【채팅 및 알림】\n" +
            "- 실시간 1:1 채팅 (WebSocket)\n" +
            "- 파일 전송 기능\n" +
            "- 알림 발송 (이메일, 푸시)\n" +
            "- 읽음/안읽음 상태 관리\n\n" +
            "【결제 및 정산 시스템】\n" +
            "- 에스크로 결제 연동 (payment_method)\n" +
            "- 마일스톤별 단계 지급 (contract_milestones 테이블)\n" +
            "- milestone status: WAITING → DEPOSITED → REQUESTED → PAID\n" +
            "- 거래 내역 조회"
        );

        // contract_milestones 테이블 데이터 (AI가 PDF와 프로젝트 규모에서 추출)
        // step_order, milestone_name, work_scope, amount, due_date
        
        MilestoneDTO milestone1 = new MilestoneDTO();
        milestone1.setName("1단계: 시스템 설계 및 환경 구축");  // milestone_name
        milestone1.setAmount(1000000L);  // amount
        milestone1.setDescription(  // work_scope
            "- 데이터베이스 ERD 설계 (users, projects, contracts 등 26개 테이블)\n" +
            "- API 명세서 작성 (Swagger 3.0)\n" +
            "- 개발 환경 구축 (Git, Jenkins, Tomcat 세팅)\n" +
            "- 프로젝트 기본 구조 셋업 (Spring MVC 설정)\n" +
            "- MyBatis 매퍼 기본 구조\n" +
            "예상 기간: 2주 (2026.01.21 ~ 2026.02.04)"
        );

        MilestoneDTO milestone2 = new MilestoneDTO();
        milestone2.setName("2단계: 사용자 인증 및 회원 관리 API");
        milestone2.setAmount(1200000L);
        milestone2.setDescription(
            "- JWT 기반 인증 시스템 구현\n" +
            "- users 테이블 CRUD API\n" +
            "- freelancer_profiles, client_profiles 관리 API\n" +
            "- 로그인, 로그아웃, 토큰 갱신\n" +
            "- 프로필 이미지 업로드 (profile_image_url)\n" +
            "- 단위 테스트 작성 (JUnit 5)\n" +
            "예상 기간: 3주 (2026.02.05 ~ 2026.02.25)"
        );

        MilestoneDTO milestone3 = new MilestoneDTO();
        milestone3.setName("3단계: 프로젝트 및 매칭 시스템");
        milestone3.setAmount(1500000L);
        milestone3.setDescription(
            "- projects 테이블 CRUD API\n" +
            "- 프로젝트 검색 및 필터링 (title, description, budget, project_status)\n" +
            "- 지원서 제출 및 관리 (applicant_count 증가)\n" +
            "- 매칭 알고리즘 (프리랜서 평점, 경력 기반)\n" +
            "- 프로젝트 상태 관리 (READY → IN_PROGRESS → CLOSED)\n" +
            "- 조회수 추적 (view_count)\n" +
            "예상 기간: 4주 (2026.02.26 ~ 2026.03.25)"
        );

        MilestoneDTO milestone4 = new MilestoneDTO();
        milestone4.setName("4단계: 계약, 결제 및 최종 통합");
        milestone4.setAmount(1300000L);
        milestone4.setDescription(
            "- contracts 테이블 저장 (total_budget, payment_method, contract_status)\n" +
            "- PDF 업로드 및 AI 분석 (origin_contract_url, ai_report_url)\n" +
            "- contract_milestones 테이블 관리 (step_order, status)\n" +
            "- 에스크로 결제 API 연동\n" +
            "- 마일스톤별 금액 지급 처리 (WAITING → DEPOSITED → PAID)\n" +
            "- 실시간 채팅 API (WebSocket)\n" +
            "- 알림 시스템 (이메일, 푸시)\n" +
            "- 전체 통합 테스트\n" +
            "- API 문서 최종 정리\n" +
            "- 배포 및 인수인계\n" +
            "예상 기간: 4주 (2026.03.26 ~ 2026.04.21)"
        );

        contract.setMilestones(Arrays.asList(milestone1, milestone2, milestone3, milestone4));

        // Model에 contract 객체 추가 (JSP에서 사용)
        model.addAttribute("contract", contract);
        
        // 실제로는 여기서 contracts 테이블에 INSERT하고 contract_id를 받아와야 함
        // contract.setContractId(savedContractId);

        return "client_con_second";
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [클라이언트 계약 두 번째 단계 - 직접 접근 (테스트용)]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /contract/second
     * 설명: 테스트를 위해 Step 2 페이지에 직접 접근할 수 있도록 합니다.
     *      Mock 데이터로 ContractReviewDTO를 생성합니다.
     *      실제 운영에서는 POST /contract/first를 거쳐야만 접근 가능합니다.
     */
    @GetMapping("/contract/second")
    public String contractSecondDirect(Model model) {
        // 테스트용 Mock 데이터 (POST와 동일한 데이터)
        ContractReviewDTO contract = new ContractReviewDTO();

        // 기본 정보 (Mock 데이터 - AI가 PDF와 프로젝트 공지에서 추출)
        contract.setProjectId(1L);
        contract.setClientId(1L);
        contract.setFreelancerId(2L);
        contract.setStartDate(LocalDate.of(2026, 1, 21));
        contract.setDeadlineDate(LocalDate.of(2026, 4, 21));
        contract.setEstDuration("3개월 (13주)");
        contract.setBudget(5000000L);
        contract.setBudgetNegotiable(false);

        // 개발 영역 (Mock 데이터 - AI가 추출)
        contract.setDevelopmentAreas(Arrays.asList(
            "백엔드 개발", 
            "데이터베이스 설계", 
            "API 설계 및 구현",
            "시스템 아키텍처"
        ));

        // 기술 스택 (Mock 데이터 - AI가 추출)
        contract.setTechnicalStacks(Arrays.asList(
            "Java 17", 
            "Spring MVC 5.3", 
            "MyBatis 3.5",
            "MySQL 8.0",
            "Git",
            "Apache Tomcat 9.0",
            "RESTful API"
        ));

        // 협업 방식 (Mock 데이터 - AI가 추출)
        contract.setCommunicationMethods(Arrays.asList("MESSENGER", "VIDEOCALL", "EMAIL"));
        contract.setOtherMethod("");

        // 프로젝트 내용 (Mock 데이터 - AI가 PDF에서 추출)
        contract.setExpectedDeliverables(
            "1. RESTful API 서버\n" +
            "   - 사용자 인증 API (회원가입, 로그인, 로그아웃)\n" +
            "   - 프로젝트 관리 API (등록, 조회, 수정, 삭제)\n" +
            "   - 매칭 시스템 API\n" +
            "   - 채팅 및 알림 API\n" +
            "   - 결제 및 정산 API\n\n" +
            "2. 데이터베이스 스키마\n" +
            "   - ERD 설계 문서\n" +
            "   - 테이블 구조 및 인덱스 설계\n" +
            "   - 데이터 무결성 제약조건\n\n" +
            "3. API 문서\n" +
            "   - Swagger/OpenAPI 명세서\n" +
            "   - 엔드포인트별 상세 설명\n" +
            "   - 요청/응답 예시\n\n" +
            "4. 소스 코드\n" +
            "   - Git 저장소 (브랜치 전략 포함)\n" +
            "   - 코드 주석 및 README\n" +
            "   - 단위 테스트 코드"
        );

        contract.setMainFeatures(
            "【사용자 인증 시스템】\n" +
            "- JWT 기반 인증 구현\n" +
            "- 회원가입 (이메일 인증)\n" +
            "- 로그인/로그아웃\n" +
            "- 비밀번호 찾기 및 재설정\n" +
            "- 프로필 관리 (프리랜서/클라이언트 구분)\n\n" +
            "【프로젝트 관리 시스템】\n" +
            "- 프로젝트 등록 및 검색\n" +
            "- 카테고리별 필터링\n" +
            "- 프로젝트 상세 조회\n" +
            "- 지원서 제출 및 관리\n" +
            "- 프로젝트 상태 관리\n\n" +
            "【매칭 및 계약 시스템】\n" +
            "- 프리랜서-클라이언트 매칭\n" +
            "- 계약서 PDF 업로드 및 파싱\n" +
            "- AI 기반 계약 정보 추출\n" +
            "- 계약서 검토 및 수정\n" +
            "- 전자 서명 기능\n\n" +
            "【채팅 및 알림】\n" +
            "- 실시간 1:1 채팅\n" +
            "- 파일 전송 기능\n" +
            "- 알림 발송 (이메일, 푸시)\n" +
            "- 읽음/안읽음 상태 관리\n\n" +
            "【결제 및 정산 시스템】\n" +
            "- 에스크로 결제 연동\n" +
            "- 마일스톤별 단계 지급\n" +
            "- 거래 내역 조회\n" +
            "- 정산 관리"
        );

        // 마일스톤 (Mock 데이터 - AI가 PDF에서 추출)
        MilestoneDTO milestone1 = new MilestoneDTO();
        milestone1.setName("1단계: 시스템 설계 및 환경 구축");
        milestone1.setAmount(1000000L);
        milestone1.setDescription(
            "- 데이터베이스 ERD 설계 및 검토\n" +
            "- API 명세서 작성 (Swagger)\n" +
            "- 개발 환경 구축 (Git, 서버 세팅)\n" +
            "- 프로젝트 기본 구조 셋업\n" +
            "예상 기간: 2주"
        );

        MilestoneDTO milestone2 = new MilestoneDTO();
        milestone2.setName("2단계: 사용자 인증 및 회원 관리 API 개발");
        milestone2.setAmount(1200000L);
        milestone2.setDescription(
            "- JWT 기반 인증 시스템 구현\n" +
            "- 회원가입, 로그인 API\n" +
            "- 프로필 관리 API\n" +
            "- 단위 테스트 작성\n" +
            "예상 기간: 3주"
        );

        MilestoneDTO milestone3 = new MilestoneDTO();
        milestone3.setName("3단계: 프로젝트 및 매칭 시스템 API 개발");
        milestone3.setAmount(1500000L);
        milestone3.setDescription(
            "- 프로젝트 CRUD API\n" +
            "- 검색 및 필터링 기능\n" +
            "- 매칭 알고리즘 구현\n" +
            "- 지원서 관리 API\n" +
            "예상 기간: 4주"
        );

        MilestoneDTO milestone4 = new MilestoneDTO();
        milestone4.setName("4단계: 채팅, 결제 및 최종 통합");
        milestone4.setAmount(1300000L);
        milestone4.setDescription(
            "- 실시간 채팅 API 구현\n" +
            "- 에스크로 결제 연동\n" +
            "- 알림 시스템 구축\n" +
            "- 전체 통합 테스트\n" +
            "- API 문서 최종 정리\n" +
            "- 배포 및 인수인계\n" +
            "예상 기간: 4주"
        );

        contract.setMilestones(Arrays.asList(milestone1, milestone2, milestone3, milestone4));

        // Model에 contract 객체 추가 (request scope)
        model.addAttribute("contract", contract);

        return "client_con_second";
    }

    /**
     * 클라이언트 프로젝트 찾기 (프로젝트 등록/관리)
     */
    @GetMapping("/client/projects")
    public String clientProjects() {
        return "client/projects";
    }

    /**
     * 클라이언트 내 프로젝트 관리
     */
    @GetMapping("/client/my-projects")
    public String clientMyProjects(HttpSession session, Model model) {
        // 로그인 사용자 확인
        Object userIdObj = session.getAttribute("userId");
        Integer clientId = null;
        if (userIdObj instanceof Integer) {
            clientId = (Integer) userIdObj;
        } else if (userIdObj instanceof Long) {
            clientId = ((Long) userIdObj).intValue();
        }

        if (clientId == null) {
            return "redirect:/login?error=unauthorized";
        }

        var projectList = projectService.findProjectsByClientId(clientId);
        model.addAttribute("projectList", projectList);
        model.addAttribute("currentPage", 1);
        model.addAttribute("totalPages", 1);
        model.addAttribute("startPage", 1);
        model.addAttribute("endPage", 1);
        model.addAttribute("totalElements", projectList.size());

        return "client/my-projects";
    }

    /**
     * 클라이언트 프로필 관리
     */
    @GetMapping("/client/profile")
    public String clientProfile() {
        return "client/profile";
    }

    /**
     * 공통 채팅방 (프리랜서 & 클라이언트 공유)
     */
    @GetMapping("/chat")
    public String chat() {
        return "chat/chat";
    }

    /**
     * 공통 알림 페이지 (프리랜서 & 클라이언트 공유)
     */
    @GetMapping("/notifications")
    public String notifications() {
        return "notifications/notifications";
    }

    /**
     * 레거시 경로 지원: /project_dashboard → /project/dashboard
     */
    @GetMapping("/project_dashboard")
    public String legacyProjectDashboard() {
        return "redirect:/project/dashboard";
    }

    /**
     * 레거시 경로 지원: /myproject → 역할별 페이지로 리다이렉트
     * FREELANCER → /freelancer/my-projects
     * CLIENT     → /client/my-projects
     */
    @GetMapping("/myproject")
    public String legacyMyProject(HttpSession session) {
        Object ut = session != null ? session.getAttribute("userType") : null;
        String userType = ut != null ? ut.toString() : "";
        if ("FREELANCER".equals(userType)) {
            return "redirect:/freelancer/my-projects";
        } else if ("CLIENT".equals(userType)) {
            return "redirect:/client/my-projects";
        }
        return "redirect:/login";
    }

    /**
     * 레거시 경로 지원: /mymoney → 역할별 페이지로 리다이렉트
     * FREELANCER → /freelancer/finance
     * CLIENT     → /client/profile (임시 대체)
     */
    @GetMapping("/mymoney")
    public String legacyMyMoney(HttpSession session) {
        Object ut = session != null ? session.getAttribute("userType") : null;
        String userType = ut != null ? ut.toString() : "";
        if ("FREELANCER".equals(userType)) {
            return "redirect:/freelancer/finance";
        } else if ("CLIENT".equals(userType)) {
            return "redirect:/client/profile";
        }
        return "redirect:/login";
    }

    /**
     * 레거시 경로 지원: /mycareer → 역할별 페이지로 리다이렉트
     * FREELANCER → /freelancer/career
     * CLIENT     → /client/profile (임시 대체)
     */
    @GetMapping("/mycareer")
    public String legacyMyCareer(HttpSession session) {
        Object ut = session != null ? session.getAttribute("userType") : null;
        String userType = ut != null ? ut.toString() : "";
        if ("FREELANCER".equals(userType)) {
            return "redirect:/freelancer/career";
        } else if ("CLIENT".equals(userType)) {
            return "redirect:/client/profile";
        }
        return "redirect:/login";
    }

    /**
     * 레거시 경로 지원: /myprofile → 역할별 페이지로 리다이렉트
     * FREELANCER → /freelancer/main
     * CLIENT     → /client/profile
     */
    @GetMapping("/myprofile")
    public String legacyMyProfile(HttpSession session) {
        Object ut = session != null ? session.getAttribute("userType") : null;
        String userType = ut != null ? ut.toString() : "";
        if ("FREELANCER".equals(userType)) {
            return "redirect:/freelancer/main";
        } else if ("CLIENT".equals(userType)) {
            return "redirect:/client/profile";
        }
        return "redirect:/login";
    }

    // ═══════════════════════════════════════════════════════════════════════
    //  프로젝트 등록 기능 (이은희 개발자 구현)
    // ═══════════════════════════════════════════════════════════════════════

    /**
     * ─────────────────────────────────────────────────────────────────
     * [프로젝트 등록 폼]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /project/create
     * 설명: 프로젝트 등록 폼 페이지를 표시합니다.
     *      5단계 폼으로 구성된 프로젝트 등록 페이지를 렌더링합니다.
     *      stacks 테이블에서 개발분야(POSITION)와 기술스택(SKILL)을 조회하여 
     *      Model에 추가합니다.
     * 
     * @param model Spring MVC Model 객체
     * @return "project/create" - 프로젝트 등록 폼 JSP
     */
    @GetMapping("/project/create")
    public String createForm(Model model) {
        projectService.setStackListToModel(model);
        return "project/create";
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [프로젝트 등록 처리]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: POST /project/create
     * 설명: 프로젝트 등록 요청을 처리합니다.
     *      1. 세션에서 로그인한 클라이언트 ID 조회
     *      2. ProjectVO 생성 및 projects 테이블에 삽입
     *      3. 기획서 파일 업로드 (선택 사항)
     *      4. project_stacks 테이블에 개발분야 및 기술스택 삽입
     *      5. 생성된 projectId와 함께 success 페이지로 리다이렉트
     * 
     * [세션 인증]
     * - 로그인한 사용자의 userId를 세션에서 가져옵니다
     * - 세션에 userId가 없으면 로그인 페이지로 리다이렉트
     * - userType이 CLIENT가 아니면 접근 거부 (클라이언트만 프로젝트 등록 가능)
     * 
     * [파일 업로드]
     * - 업로드 경로: src/main/webapp/resources/upload/project/
     * - 웹 접근 경로: /resources/upload/project/{filename}
     * - 최대 파일 크기: 5GB (application.properties에서 설정)
     * - UUID로 고유 파일명 생성하여 중복 방지
     * 
     * [트랜잭션]
     * - @Transactional 어노테이션으로 안전한 등록 보장
     * - 오류 발생 시 자동 롤백
     * 
     * @param request 프로젝트 등록 요청 DTO
     * @param planFile 기획서 파일 (MultipartFile, 선택 사항)
     * @param stackIdsUnknown 기술 스택 미정 여부
     * @param session HttpSession (clientId 및 userType 조회용)
     * @return "redirect:/project/success?projectId={id}" - 등록 완료 페이지로 리다이렉트
     */
    @PostMapping("/project/create")
    public String createProcess(@ModelAttribute ProjectCreateRequestDTO request,
                                @RequestParam(value = "planFile", required = false) MultipartFile planFile,
                                HttpSession session) {

        // ═══════════════════════════════════════════════════════════════════════
        //  Step 1: 세션 기반 인증 및 권한 검증
        // ═══════════════════════════════════════════════════════════════════════
        
        /**
         * [1-1] 세션에서 로그인 사용자 ID 추출
         * 
         * - 세션 속성 "userId"에서 로그인한 사용자의 ID를 가져옵니다
         * - 타입 안정성: 세션에 Long 또는 Integer 타입으로 저장될 수 있으므로
         *   instanceof를 사용하여 타입을 확인 후 안전하게 변환합니다
         * - 변환 실패 시 clientId는 null로 유지됩니다
         * 
         * 참고: 로그인 시 users 테이블의 user_id(INT)가 세션에 저장되며,
         *      일부 환경에서는 자동으로 Long 타입으로 변환될 수 있습니다
         */
        Object userIdObj = session.getAttribute("userId");
        Integer clientId = null;
        
        if (userIdObj != null) {
            if (userIdObj instanceof Integer) {
                // Integer 타입으로 저장된 경우 직접 할당
                clientId = (Integer) userIdObj;
            } else if (userIdObj instanceof Long) {
                // Long 타입으로 저장된 경우 Integer로 안전하게 변환
                clientId = ((Long) userIdObj).intValue();
            }
        }
        
        /**
         * [1-2] 로그인 여부 확인
         * 
         * - clientId가 null이면 로그인하지 않은 상태입니다
         * - 로그인 페이지로 리다이렉트하며 다음 정보를 전달합니다:
         *   1) error=unauthorized: 인증 실패 메시지 표시
         *   2) returnUrl=/project/create: 로그인 후 돌아올 URL
         * 
         * 보안: 프로젝트 등록은 반드시 로그인한 사용자만 가능합니다
         */
        if (clientId == null) {
            return "redirect:/login?error=unauthorized&returnUrl=/project/create";
        }
        
        /**
         * [1-3] 사용자 권한 검증 (CLIENT 타입만 허용)
         * 
         * - 세션 속성 "userType"에서 사용자 유형을 확인합니다
         * - 허용된 타입: "CLIENT" (프로젝트를 등록하는 의뢰인)
         * - 거부된 타입: "FREELANCER" (프로젝트를 수행하는 프리랜서)
         * 
         * 비즈니스 규칙: 프로젝트는 클라이언트만 등록할 수 있으며,
         *               프리랜서는 등록된 프로젝트에 지원만 가능합니다
         */
        String userType = (String) session.getAttribute("userType");
        if (!"CLIENT".equals(userType)) {
            // 권한 없음: 대시보드로 리다이렉트하며 접근 금지 메시지 전달
            return "redirect:/project/dashboard?error=forbidden";
        }

        // ═══════════════════════════════════════════════════════════════════════
        //  Step 2: 프로젝트 생성 및 저장 (트랜잭션 처리)
        // ═══════════════════════════════════════════════════════════════════════
        
        /**
         * [2-1] 프로젝트 ID 초기화
         * 
         * - 생성된 프로젝트의 ID를 저장할 변수입니다
         * - INSERT 후 MyBatis의 useGeneratedKeys를 통해 자동 생성된 ID가 할당됩니다
         * - 성공 시 이 ID를 사용하여 리다이렉트 또는 후속 처리를 진행합니다
         */
        Integer projectId = null;

        try {
            /**
             * [2-2] 프로젝트 생성 전 디버깅 로그 출력
             * 
             * - 개발/운영 환경에서 문제 추적을 위한 로그입니다
             * - 출력 정보:
             *   1) clientId: 프로젝트를 등록하는 클라이언트 ID
             *   2) 제목: 프로젝트 제목
             *   3) 예산: 프로젝트 예산 (콤마 포함 문자열)
             * 
             * 운영 환경 배포 시: SLF4J Logger로 교체 권장 (System.out 대신)
             */
            System.out.println("════════════════════════════════════════");
            System.out.println("프로젝트 등록 시작");
            System.out.println("clientId: " + clientId);
            System.out.println("제목: " + request.getTitle());
            System.out.println("예산: " + request.getBudget());
            System.out.println("════════════════════════════════════════");
            
            /**
             * [2-3] ProjectService를 통한 프로젝트 생성
             * 
             * 이 메서드는 다음 작업을 트랜잭션으로 처리합니다:
             * 
             * 1) ProjectVO 생성 및 필드 매핑
             *    - DTO → VO 변환
             *    - 예산 문자열 → Integer 변환 (콤마 제거)
             *    - 시작일/마감일 자동 계산
             *    - 기본값 적용 (communicateMethod, paymentMethod 등)
             * 
             * 2) 기획서 파일 업로드 (선택 사항)
             *    - multipart/form-data로 전송된 파일 처리
             *    - UUID 파일명 생성으로 중복 방지
             *    - src/main/webapp/resources/upload/project/ 경로에 저장
             *    - planUrl 및 fileSize 설정
             * 
             * 3) projects 테이블에 INSERT
             *    - MyBatis의 useGeneratedKeys로 자동 생성된 project_id 반환
             *    - 기본 상태: READY, 공개 여부: true
             * 
             * 4) project_stacks 테이블에 기술스택 매핑 INSERT
             *    - 모달에서 선택한 개발 영역(POSITION) + 기술 스택(SKILL)
             *    - stackIds, stackLevels, stackYears가 인덱스 순서로 매칭됨
             *    - 각 스택마다 요구 레벨(1~5)과 경력(년)이 개별 지정됨
             * 
             * @param request 프로젝트 등록 요청 DTO (폼 데이터)
             * @param clientId 로그인한 클라이언트 ID (세션에서 추출)
             * @param planFile 기획서 파일 (MultipartFile, 선택 사항)
             * @return 생성된 프로젝트 ID (project_id)
             * @throws IOException 파일 업로드 실패 시
             * @throws Exception 데이터베이스 오류 또는 검증 실패 시
             */
            projectId = projectService.createProject(request, clientId, planFile);
            
            /**
             * [2-4] 프로젝트 생성 성공 로그 출력
             * 
             * - 정상적으로 프로젝트가 생성되었음을 확인합니다
             * - 생성된 projectId를 출력하여 추적 가능하게 합니다
             * - 이후 이 ID를 사용하여 상세 페이지로 이동하거나 목록을 조회합니다
             */
            System.out.println("════════════════════════════════════════");
            System.out.println("프로젝트 등록 성공!");
            System.out.println("생성된 projectId: " + projectId);
            System.out.println("════════════════════════════════════════");
            
        } catch (Exception e) {
            /**
             * [2-5] 예외 처리 및 에러 리다이렉트
             * 
             * 프로젝트 등록 중 발생 가능한 예외:
             * - IOException: 파일 업로드 실패
             * - SQLException: 데이터베이스 제약 조건 위반
             * - NumberFormatException: 예산 또는 스택 데이터 변환 실패
             * - NullPointerException: 필수 필드 누락
             * 
             * 예외 발생 시 처리:
             * 1) 에러 메시지와 스택 트레이스를 표준 에러 출력에 기록
             * 2) 등록 폼 페이지로 리다이렉트하며 error=true 파라미터 전달
             * 3) JSP에서 error 파라미터를 감지하여 사용자에게 오류 메시지 표시
             * 
             * 보안 고려사항:
             * - 에러 메시지에 한글이 포함되면 HTTP 헤더 인코딩 문제 발생 가능
             * - 따라서 error=true만 전달하고, JSP에서 사전 정의된 메시지 표시
             * 
             * 트랜잭션:
             * - Service 계층의 @Transactional로 인해 예외 발생 시 자동 롤백됨
             * - projects와 project_stacks 모두 롤백되어 데이터 무결성 보장
             */
            System.err.println("════════════════════════════════════════");
            System.err.println("프로젝트 등록 실패!");
            System.err.println("에러 메시지: " + e.getMessage());
            e.printStackTrace();  // 전체 스택 트레이스 출력으로 디버깅 지원
            System.err.println("════════════════════════════════════════");
            return "redirect:/project/create?error=true";
        }

        // ═══════════════════════════════════════════════════════════════════════
        //  Step 3: 프로젝트 등록 완료 후 내 프로젝트 목록으로 이동
        // ═══════════════════════════════════════════════════════════════════════

        /**
         * [3-1] 클라이언트 내 프로젝트 페이지로 리다이렉트
         * 
         * - 경로: /client/my-projects
         * - 이 경로의 컨트롤러 메서드(clientMyProjects)에서:
         *   1) 세션에서 userId 추출
         *   2) projectService.findProjectsByClientId(userId) 호출
         *   3) 해당 클라이언트가 등록한 모든 프로젝트 목록 조회
         *   4) Model에 projectList 추가
         *   5) client/my-projects.jsp 렌더링
         * 
         * - JSP에서는 방금 등록한 프로젝트가 목록 맨 위에 표시됩니다
         *   (최신순 정렬: ORDER BY created_at DESC)
         * 
         * 참고: 과거에는 /project/success?projectId={id}로 이동했으나,
         *      사용자 경험 개선을 위해 바로 목록 페이지로 이동하도록 변경됨
         */
        return "redirect:/client/my-projects";
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [프로젝트 등록 완료]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /project/success
     * 설명: 프로젝트 등록 완료 페이지를 표시합니다.
     *      생성된 projectId를 Model에 추가하여 JSP에서 사용할 수 있도록 합니다.
     * 
     * @param projectId 생성된 프로젝트 ID (URL 파라미터)
     * @param model Spring MVC Model 객체
     * @return "project/success" - 등록 완료 페이지 JSP
     */
    @GetMapping("/project/success")
    public String successPage(@RequestParam(value = "projectId", required = false) Integer projectId, Model model) {
        model.addAttribute("projectId", projectId);
        return "project/success";
    }
}

