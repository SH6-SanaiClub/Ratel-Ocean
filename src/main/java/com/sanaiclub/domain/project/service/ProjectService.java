package com.sanaiclub.domain.project.service;

import com.sanaiclub.domain.project.dao.ProjectMapper;
import com.sanaiclub.domain.project.dao.StackMapper;
import com.sanaiclub.domain.project.dto.ProjectCreateRequestDTO;
import com.sanaiclub.domain.project.dto.ProjectDashboardDTO;
import com.sanaiclub.domain.project.dto.ProjectDetailDTO;
import com.sanaiclub.domain.project.dto.StackDto;
import com.sanaiclub.domain.project.vo.ProjectStackVO;
import com.sanaiclub.domain.project.vo.ProjectStatus;
import com.sanaiclub.domain.project.vo.ProjectVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * ProjectService
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [설명]
 * 프로젝트 등록 비즈니스 로직을 처리하는 서비스 클래스입니다.
 * 프로젝트 생성, 기획서 파일 업로드, 스택 매핑 등의 작업을 수행합니다.
 * 
 * [위치]
 * 패키지: com.sanaiclub.domain.project.service
 * 파일: ProjectService.java
 * 
 * [주요 기능]
 * 1. setStackListToModel: 스택 목록을 Model에 추가 (JSP에서 사용)
 *    - POSITION 카테고리: 개발분야 (웹, 모바일 등)
 *    - SKILL 카테고리: 기술스택 (Java, React 등)
 * 
 * 2. createProject: 프로젝트 생성 (트랜잭션)
 *    - projects 테이블에 프로젝트 기본 정보 삽입
 *    - 기획서 파일 업로드 처리 (선택 사항)
 *    - project_stacks 테이블에 개발분야 및 기술스택 삽입
 *    - 생성된 projectId 반환
 * 
 * [파일 업로드 경로]
 * 실제 경로: src/main/webapp/resources/upload/project/
 * 웹 접근 경로: /resources/upload/project/{filename}
 * 
 * @author 이은희 (신한DS 금융 SW 아카데미)
 * @version 1.0
 * @since 2026-01-18
 */
@Service
public class ProjectService {

    /**
     * ═══════════════════════════════════════════════════════════════════════
     * 기획서 파일 업로드 디렉토리 설정
     * ═══════════════════════════════════════════════════════════════════════
     * 
     * [중요] 파일 업로드 경로 설정
     * 
     * 1. 개발 환경:
     *    - 절대 경로: 프로젝트의 src/main/webapp/resources/upload/project 폴더
     *    - 웹 접근: http://localhost:9999/ratelocean/resources/upload/project/{filename}
     * 
     * 2. 운영 환경 (Tomcat 배포 후):
     *    - 절대 경로: TOMCAT_HOME/webapps/ratelocean/resources/upload/project 폴더
     *    - 웹 접근: http://도메인/ratelocean/resources/upload/project/{filename}
     * 
     * 3. 파일 저장 프로세스:
     *    - 업로드된 파일은 UUID로 고유 파일명 생성 (중복 방지)
     *    - 형식: {UUID}_{원본파일명}
     *    - 예시: 550e8400-e29b-41d4-a716-446655440000_기획서.pdf
     * 
     * 4. 보안 고려사항:
     *    - 파일 크기 제한: 5GB (application.properties에서 설정)
     *    - 허용 확장자: PDF, DOC, DOCX, XLS, XLSX, PPT, PPTX, ZIP, RAR
     *    - 바이러스 검사: 추후 추가 필요
     * 
     * 5. 디렉토리 자동 생성:
     *    - 존재하지 않으면 자동으로 생성됨 (mkdirs)
     *    - 권한 설정 필요: 읽기/쓰기 가능하도록 설정
     * 
     * [변경 방법]
     * - application.properties에 설정 추가 권장
     * - @Value 어노테이션으로 주입
     */
    private String resolveUploadDir() {
        String catalinaBase = System.getProperty("catalina.base");
        if (catalinaBase != null) {
            // Tomcat 배포 후: <catalina.base>/webapps/ratelocean/resources/upload/project
            return Paths.get(catalinaBase, "webapps", "ratelocean", "resources", "upload", "project")
                    .toString() + File.separator;
        }

        // 로컬 개발용: 프로젝트 루트 기준 상대 경로
        return Paths.get(System.getProperty("user.dir"), "src", "main", "webapp", "resources", "upload", "project")
                .toString() + File.separator;
    }

    @Autowired
    private ProjectMapper projectMapper;

    @Autowired
    private StackMapper stackMapper;

    /**
     * ─────────────────────────────────────────────────────────────────
     * 스택 목록을 Model에 추가
     * ─────────────────────────────────────────────────────────────────
     * 
     * stacks 테이블에서 모든 스택을 조회하여 POSITION과 SKILL로 분리합니다.
     * JSP에서 ${positionList}와 ${skillList}로 접근할 수 있습니다.
     * 
     * @param model Spring MVC Model 객체
     */
    public void setStackListToModel(Model model) {
        List<StackDto> allStack = stackMapper.findAll();
        List<StackDto> positionList = new ArrayList<>();
        List<StackDto> skillList = new ArrayList<>();

        for (StackDto stack : allStack) {
            if ("POSITION".equals(stack.getCategory())) {
                positionList.add(stack);
            } else if ("SKILL".equals(stack.getCategory())) {
                skillList.add(stack);
            }
        }
        
        model.addAttribute("positionList", positionList);
        model.addAttribute("skillList", skillList);
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * 프로젝트 생성 (트랜잭션) - 모달 방식 지원
     * ─────────────────────────────────────────────────────────────────
     * 
     * 1. ProjectVO 생성 및 필드 매핑
     *    - DTO의 String budget을 Integer로 변환 (콤마 제거)
     *    - startType이 ASAP이면 현재 날짜 사용, DATE면 지정 날짜 사용
     *    - deadlineDate는 startDate + 30일로 자동 계산
     * 
     * 2. 기획서 파일 업로드 (선택 사항)
     *    - UUID로 고유 파일명 생성
     *    - 지정된 경로에 파일 저장
     *    - planUrl과 fileSize를 ProjectVO에 설정
     * 
     * 3. projects 테이블에 삽입
     *    - useGeneratedKeys로 자동 생성된 projectId를 VO에 매핑
     * 
     * 4. project_stacks 테이블에 삽입 (모달 방식)
     *    - stackIds, stackLevels, stackYears가 인덱스로 매칭됨
     *    - 각 스택마다 개별 레벨과 경력이 지정됨
     *    - 개발 영역(POSITION) + 기술 스택(SKILL) 모두 동일한 방식으로 처리
     * 
     * @param request 프로젝트 등록 요청 DTO
     * @param clientId 클라이언트 ID (세션에서 가져옴)
     * @param planFile 기획서 파일 (MultipartFile, 선택 사항)
     * @return 생성된 프로젝트 ID
     * @throws IOException 파일 업로드 실패 시 발생
     */
    @Transactional
    public Integer createProject(ProjectCreateRequestDTO request, Integer clientId, MultipartFile planFile) throws IOException {

        // ═══════════════════════════════════════════════════════════════════════
        //  Step 1: ProjectVO 생성 및 DTO → VO 필드 매핑
        // ═══════════════════════════════════════════════════════════════════════
        
        /**
         * [1-1] ProjectVO 인스턴스 생성
         * 
         * - projects 테이블에 INSERT할 데이터를 담는 Value Object입니다
         * - MyBatis Mapper에서 이 VO를 파라미터로 받아 SQL을 실행합니다
         */
        ProjectVO projectVO = new ProjectVO();

        /**
         * [1-2] 기본 정보 매핑 (클라이언트 ID, 제목, 설명)
         * 
         * - clientId: 세션에서 추출한 로그인 사용자 ID (FK → users.user_id)
         * - title: 프로젝트 제목 (필수, VARCHAR(200))
         * - description: 프로젝트 상세 설명 (필수, TEXT)
         * 
         * 검증:
         * - Controller에서 @ModelAttribute로 바인딩 시 자동으로 데이터 타입 검증됨
         * - 필수 필드 누락 시 DB 제약 조건(NOT NULL)에서 예외 발생
         */
        projectVO.setClientId(clientId);
        projectVO.setTitle(request.getTitle());
        projectVO.setDescription(request.getDescription());

        /**
         * [1-3] 예산 처리 (String → Integer 변환 with null-safe)
         * 
         * 입력 형식:
         * - 사용자가 입력한 예산은 "1,000,000" 형태의 문자열입니다
         * - HTML input type="text"로 받아 JavaScript에서 콤마 포맷팅됨
         * 
         * 처리 과정:
         * 1) null 체크: null이면 "0"으로 대체
         * 2) 콤마 제거: "1,000,000" → "1000000"
         * 3) 공백 제거: trim()으로 앞뒤 공백 제거
         * 4) Integer 변환: parseInt()로 숫자 타입 변환
         * 
         * 예외 처리:
         * - NumberFormatException 발생 시 예산을 0으로 설정
         * - 잘못된 형식(문자 포함, 음수 등) 입력 시 기본값 적용
         * 
         * 예산 협의 가능 여부:
         * - budgetNegotiable: Boolean 타입
         * - null이면 false로 처리 (삼항 연산자로 null-safe 보장)
         */
        try {
            String budgetStr = request.getBudget() == null ? "0" : request.getBudget().replace(",", "").trim();
            projectVO.setBudget(Integer.parseInt(budgetStr));
        } catch (Exception e) {
            projectVO.setBudget(0);  // 변환 실패 시 기본값
        }
        projectVO.setBudgetNegotiable(request.getBudgetNegotiable() != null && request.getBudgetNegotiable());

        /**
         * [1-4] 예상 진행 기간 설정 (빈 값 방어 로직)
         * 
         * 입력 형식:
         * - "1개월 이내", "1~3개월", "3~6개월" 등의 문자열
         * - HTML 라디오 버튼으로 선택하거나 사용자 입력
         * 
         * 기본값 처리:
         * - null이거나 빈 문자열이면 "TBD"(To Be Determined)로 설정
         * - DB 제약 조건: NOT NULL이므로 반드시 값이 있어야 함
         * 
         * 기간 협의 가능 여부:
         * - durationNegotiable: 체크박스 입력값 (Boolean)
         * - null이면 false로 처리
         */
        String estDuration = request.getEstDuration();
        if (estDuration == null || estDuration.trim().isEmpty()) {
            estDuration = "TBD"; // 기본값: 미정
        }
        projectVO.setEstDuration(estDuration);
        projectVO.setDurationNegotiable(request.getDurationNegotiable() != null && request.getDurationNegotiable());

        /**
         * [1-5] 프로젝트 시작일 설정 (사용자 선택에 따른 분기 처리)
         * 
         * 입력 형식:
         * - startType: "ASAP" 또는 "SPECIFIC"
         *   1) "ASAP" (계약 후 즉시): 현재 날짜를 시작일로 사용
         *   2) "SPECIFIC" (구체적 날짜): 사용자가 지정한 startDate 사용
         * 
         * 처리 로직:
         * - ASAP 선택 시: LocalDate.now()로 현재 날짜 설정
         * - 구체적 날짜 선택 시:
         *   a) startDate가 null이거나 빈 문자열 → 현재 날짜 사용
         *   b) startDate가 있으면 "yyyy-MM-dd" 형식으로 파싱
         * 
         * 데이터 타입:
         * - DTO: String ("2026-01-20")
         * - VO: java.sql.Date (DB에 DATE 타입으로 저장)
         * - 변환: Date.valueOf(LocalDate.parse(...))
         */
        if ("ASAP".equals(request.getStartType())) {
            projectVO.setStartDate(Date.valueOf(LocalDate.now()));
        } else {
            if (request.getStartDate() == null || request.getStartDate().isEmpty()) {
                projectVO.setStartDate(Date.valueOf(LocalDate.now()));
            } else {
                projectVO.setStartDate(Date.valueOf(LocalDate.parse(request.getStartDate())));
            }
        }

        /**
         * [1-6] 지원 마감일 자동 계산 (시작일 + 30일)
         * 
         * 비즈니스 규칙:
         * - 프로젝트 지원 마감일은 시작일로부터 30일 후로 고정
         * - 사용자가 직접 입력하지 않고 자동으로 설정됨
         * 
         * 계산 방법:
         * 1) startDate(java.sql.Date)를 LocalDate로 변환
         * 2) plusDays(30)으로 30일 추가
         * 3) Date.valueOf()로 java.sql.Date로 다시 변환
         * 
         * 예시:
         * - 시작일: 2026-01-18
         * - 마감일: 2026-02-17
         * 
         * 참고:
         * - 이 마감일은 프리랜서가 지원할 수 있는 기한입니다
         * - 실제 프로젝트 종료일과는 무관합니다
         */
        LocalDate startLocalDate = projectVO.getStartDate().toLocalDate();
        projectVO.setDeadlineDate(Date.valueOf(startLocalDate.plusDays(30)));

        /**
         * [1-7] 소통 및 계약 조건 설정 (NULL 방어 로직 적용)
         * 
         * 이 섭션에서는 프로젝트 진행 방식과 관련된 필드를 설정합니다:
         * 1) communicateMethod: 소통 방식 (ONLINE/OFFLINE)
         * 2) paymentMethod: 대금 지급 방식 (LUMP_SUM/INSTALLMENT)
         * 3) maxRevisionCount: 최대 무료 수정 횟수 (0~3)
         * 4) changePolicy: 수정 관련 상세 규정 (TEXT)
         * 
         * 모든 필드는 선택 사항이므로, 사용자가 입력하지 않은 경우
         * 기본값을 자동으로 설정하여 DB 제약 조건(NOT NULL)을 충족시킵니다.
         */
        
        /**
         * [1-7-1] 소통 방식 (communicateMethod)
         * 
         * 옵션:
         * - "ONLINE": 화상회의, 메신저 등 비대면 미팅
         * - "OFFLINE": 대면 미팅 선호
         * 
         * 기본값:
         * - null이거나 빈 문자열이면 "ONLINE" 설정
         * - 대부분의 프로젝트는 온라인으로 진행되므로 기본값으로 적합
         */
        String communicateMethod = request.getCommunicateMethod();
        if (communicateMethod == null || communicateMethod.trim().isEmpty()) {
            communicateMethod = "ONLINE"; // 기본값: 온라인 미팅
        }
        projectVO.setCommunicateMethod(communicateMethod);

        /**
         * [1-7-2] 대금 지급 방식 (paymentMethod)
         * 
         * 옵션:
         * - "LUMP_SUM": 일괄 지급 (프로젝트 완료 후 전액)
         * - "INSTALLMENT": 분할 지급 (단계별 지급)
         * 
         * 기본값:
         * - null이거나 빈 문자열이면 "LUMP_SUM" 설정
         * - 일괄 지급이 가장 일반적인 방식이므로 기본값으로 설정
         */
        String paymentMethod = request.getPaymentMethod();
        if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
            paymentMethod = "LUMP_SUM"; // 기본값: 일괄 지급
        }
        projectVO.setPaymentMethod(paymentMethod);

        /**
         * [1-7-3] 최대 무료 수정 횟수 (maxRevisionCount)
         * 
         * 의미:
         * - 프로젝트가 완료된 후 추가 비용 없이 수정을 요청할 수 있는 횟수
         * - 예시: 색상 변경, 텍스트 수정, 이미지 교체, UI 조정 등
         * - 주의: 새로운 기능 추가나 대규모 수정은 포함되지 않음
         * 
         * 범위:
         * - 최소: 0회 (무료 수정 불가)
         * - 최대: 3회 (HTML input에서 max="3" 제한)
         * 
         * 기본값:
         * - null이면 1회로 설정
         * - 1회는 가장 일반적인 무료 수정 횟수
         */
        Integer maxRevisionCount = request.getMaxRevisionCount();
        if (maxRevisionCount == null) {
            maxRevisionCount = 1; // 기본값: 1회 무료 수정
        }
        projectVO.setMaxRevisionCount(maxRevisionCount);

        /**
         * [1-7-4] 수정 관련 상세 규정 (changePolicy)
         * 
         * 의미:
         * - maxRevisionCount를 초과하는 수정 요청에 대한 규정
         * - 추가 비용 발생 여부, 수정 범위 제한 등을 명시
         * 
         * 형식:
         * - 자유 형식의 TEXT 필드
         * - 사용자가 직접 입력하거나 비워둡 수 있음
         * 
         * 기본값:
         * - null이거나 빈 문자열이면 기본 문구 설정
         * - "수정 사항은 상호 협의에 따라 처리됩니다"
         */
        String changePolicy = request.getChangePolicy();
        if (changePolicy == null || changePolicy.trim().isEmpty()) {
            changePolicy = "Revisions will be handled by mutual agreement.";
        }
        projectVO.setChangePolicy(changePolicy);
        
        // 상태 및 공개 여부
        // 상태/공개 기본값 설정
        projectVO.setProjectStatus(request.getProjectStatus() == null ? ProjectStatus.READY : request.getProjectStatus());
        projectVO.setIsPublic(request.getIsPublic() == null ? Boolean.TRUE : request.getIsPublic());

        // ─────── Step 2: 기획서 파일 업로드 (선택 사항) ───────
        
        if (planFile != null && !planFile.isEmpty()) {
            // 업로드 디렉토리 생성 (존재하지 않을 경우)
            String uploadDir = resolveUploadDir();
            Path uploadPath = Paths.get(uploadDir);
            Files.createDirectories(uploadPath);

            // UUID로 고유 파일명 생성
            String originalFileName = planFile.getOriginalFilename();
            String savedFileName = UUID.randomUUID().toString() + "_" + originalFileName;
            Path savePath = uploadPath.resolve(savedFileName);
            
            // 파일 저장
            planFile.transferTo(savePath.toFile());

            // VO에 파일 정보 설정
            projectVO.setPlanUrl("/resources/upload/project/" + savedFileName);
            double size = (double) planFile.getSize() / (1024 * 1024);
            projectVO.setFileSize(String.format("%.2f MB", size));
        } else {
            projectVO.setPlanUrl(null);
            projectVO.setFileSize(null);
        }

        // ─────── Step 3: projects 테이블에 삽입 ───────
        
        projectMapper.insertProject(projectVO);
        Integer projectId = projectVO.getProjectId(); // 자동 생성된 ID

        // ─────── Step 4: project_stacks 테이블에 삽입 (모달 방식) ───────
        
        if (request.getStackIds() != null && !request.getStackIds().isEmpty()) {
            List<String> stackIdsStr = request.getStackIds();
            List<String> stackLevelsStr = request.getStackLevels();
            List<String> stackYearsStr = request.getStackYears();
            
            // stackIds, stackLevels, stackYears의 길이가 동일해야 함
            if (stackLevelsStr != null && stackYearsStr != null && 
                stackIdsStr.size() == stackLevelsStr.size() && stackIdsStr.size() == stackYearsStr.size()) {
                
                for (int i = 0; i < stackIdsStr.size(); i++) {
                    try {
                        Integer stackId = Integer.parseInt(stackIdsStr.get(i));
                        Integer stackLevel = Integer.parseInt(stackLevelsStr.get(i));
                        Integer stackYear = Integer.parseInt(stackYearsStr.get(i));
                        
                        ProjectStackVO stackVO = new ProjectStackVO(
                                null, 
                                projectId, 
                                stackId, 
                                stackLevel, 
                                stackYear
                        );
                        projectMapper.insertProjectStack(stackVO);
                    } catch (NumberFormatException e) {
                        System.err.println("⚠️ 스택 데이터 변환 실패: stackId=" + stackIdsStr.get(i) + 
                                         ", level=" + stackLevelsStr.get(i) + 
                                         ", year=" + stackYearsStr.get(i));
                    }
                }
            } else {
                // 데이터 불일치 시 로그 기록 (실제 운영에서는 예외 발생 권장)
                System.err.println("⚠️ stackIds, stackLevels, stackYears 길이 불일치!");
            }
        }

        return projectId;
    }

    /**
     * 대시보드/프리랜서 목록에 사용할 전체 프로젝트 목록 조회
     */
    public List<ProjectDashboardDTO> findAllProjects() {
        List<ProjectDashboardDTO> list = projectMapper.findAllProjects();
        if (list == null) {
            return new ArrayList<>();
        }
        return list;
    }

    /**
     * 특정 클라이언트가 등록한 프로젝트 목록 조회
     */
    public List<ProjectDashboardDTO> findProjectsByClientId(Integer clientId) {
        if (clientId == null) {
            return new ArrayList<>();
        }
        List<ProjectDashboardDTO> list = projectMapper.findProjectsByClientId(clientId);
        if (list == null) {
            return new ArrayList<>();
        }
        return list;
    }

    /**
     * 프로젝트 상세 조회 (스택 및 첨부 포함)
     */
    public ProjectDetailDTO getProjectDetail(Integer projectId) {
        if (projectId == null) {
            return null;
        }
        return projectMapper.findProjectById(projectId);
    }
}
