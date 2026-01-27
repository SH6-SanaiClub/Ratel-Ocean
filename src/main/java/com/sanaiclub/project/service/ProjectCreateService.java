package com.sanaiclub.project.service;

import com.sanaiclub.project.dao.ProjectCreateMapper;
import com.sanaiclub.project.dao.StackMapper;
import com.sanaiclub.project.model.dto.ProjectCreateRequestDTO;
import com.sanaiclub.project.model.dto.StackDTO;
import com.sanaiclub.project.model.vo.ProjectStackVO;
import com.sanaiclub.project.model.vo.ProjectsVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProjectCreateService {
    private static final String UPLOAD_DIR = "C:\\Users\\fzaca\\IdeaProjects\\Ratel-Ocean\\src\\main\\webapp\\resources\\upload\\project\\";

    private final ProjectCreateMapper projectCreateMapper;
    private final StackMapper stackMapper;

    // 화면용 스택 목록 세팅
    public void setStackListToModel(Model model) {
        List<StackDTO> allStacks = stackMapper.findAll();

        model.addAttribute("positionList", allStacks.stream()
                .filter(s -> "POSITION".equals(s.getCategory())).collect(Collectors.toList()));
        model.addAttribute("skillList", allStacks.stream()
                .filter(s -> "SKILL".equals(s.getCategory())).collect(Collectors.toList()));
    }

    // 프로젝트 생성 (Create)
    @Transactional
    public void createProject(ProjectCreateRequestDTO request, Integer clientId, MultipartFile planFile) throws Exception {
        sanitizeRequest(request); // NULL 방지 처리

        if (planFile != null && !planFile.isEmpty()) {
            request.setPlanUrl(uploadFile(planFile));
            request.setFileSize(String.valueOf(planFile.getSize()));
        }

        request.setClientId(clientId);
        projectCreateMapper.insertProject(request);
        insertStacks(request);
    }

    // 수정용 상세 조회
    public ProjectCreateRequestDTO getProjectDetailForEdit(Integer projectId) {
        ProjectsVO vo = projectCreateMapper.selectProjectById(projectId);
        if (vo == null) return null;

        ProjectCreateRequestDTO dto = new ProjectCreateRequestDTO();
        dto.setProjectId(vo.getProjectId());
        dto.setTitle(vo.getTitle());
        dto.setDescription(vo.getDescription());
        dto.setBudget(String.valueOf(vo.getBudget()));
        dto.setBudgetNegotiable(vo.getBudgetNegotiable());
        dto.setEstDuration(vo.getEstDuration());
        dto.setDurationNegotiable(vo.getDurationNegotiable());
        dto.setStartDate(vo.getStartDate() != null ? vo.getStartDate().toString() : "");
        dto.setDeadlineDate(vo.getDeadlineDate() != null ? vo.getDeadlineDate().toString() : "");
        dto.setCommunicateMethod(vo.getCommunicateMethod());
        dto.setPaymentMethod(vo.getPaymentMethod());
        dto.setMaxRevisionCount(vo.getMaxRevisionCount());
        dto.setChangePolicy(vo.getChangePolicy());
        dto.setPlanUrl(vo.getPlanUrl());

        dto.setViewCount(vo.getViewCount() != null ? vo.getViewCount() : 0);
        dto.setApplicantCount(vo.getApplicantCount() != null ? vo.getApplicantCount() : 0);

        List<StackDTO> stacks = projectCreateMapper.selectStackListByProjectId(projectId);
        dto.setStacks(stacks);

        ProjectStackVO config = projectCreateMapper.selectProjectStackConfig(projectId);
        if (config != null) {
            dto.setMinLevel(config.getStackLevel());
            dto.setMinYear(config.getStackYear());
        }

        return dto;
    }

    // 프로젝트 수정 (Update)
    @Transactional
    public void updateProject(ProjectCreateRequestDTO request, MultipartFile planFile) throws Exception {
        sanitizeRequest(request);

        if (planFile != null && !planFile.isEmpty()) {
            request.setPlanUrl(uploadFile(planFile));
            request.setFileSize(String.valueOf(planFile.getSize()));
        } else {
            request.setPlanUrl(request.getExistingPlanUrl());
        }

        projectCreateMapper.updateProject(request);

        projectCreateMapper.deleteProjectStacks(request.getProjectId());
        insertStacks(request);
    }

    // 프로젝트 삭제 (Delete)
    @Transactional
    public void deleteProject(Integer projectId) {
        projectCreateMapper.deleteProjectStacks(projectId);
        projectCreateMapper.deleteProject(projectId);
    }

    private void insertStacks(ProjectCreateRequestDTO request) {
        Integer pId = request.getProjectId();

        if (request.getPositionIds() != null) {
            for (Integer sId : request.getPositionIds()) {
                projectCreateMapper.insertProjectStack(new ProjectStackVO(null, pId, sId, 0, 0));
            }
        }
        if (request.getStackIds() != null) {
            for (Integer sId : request.getStackIds()) {
                projectCreateMapper.insertProjectStack(new ProjectStackVO(null, pId, sId, request.getMinLevel(), request.getMinYear()));
            }
        }
    }

    private String uploadFile(MultipartFile file) throws Exception {
        File dir = new File(UPLOAD_DIR);
        if (!dir.exists()) dir.mkdirs();

        String savedName = UUID.randomUUID() + "_" + file.getOriginalFilename();
        file.transferTo(new File(dir, savedName));
        return "/resources/upload/project/" + savedName;
    }

    // 모든 필수값 NULL 방지 (체크박스, 라디오, 셀렉트)
    private void sanitizeRequest(ProjectCreateRequestDTO request) {
        // 1. 체크박스 (Boolean) - 해제 시 null -> false 변환
        if (request.getBudgetNegotiable() == null) request.setBudgetNegotiable(false);
        if (request.getDurationNegotiable() == null) request.setDurationNegotiable(false);
        if (request.getStartNegotiable() == null) request.setStartNegotiable(false);
        if (request.getStackIdsUnknown() == null) request.setStackIdsUnknown(false);

        // 2. 라디오 버튼 / 셀렉트 (String) - 비어있을 경우 기본값 설정
        if (request.getPaymentMethod() == null || request.getPaymentMethod().trim().isEmpty()) {
            request.setPaymentMethod("FULL");
        }
        // 미팅 방식 (ONLINE / OFFLINE)
        if (request.getCommunicateMethod() == null || request.getCommunicateMethod().trim().isEmpty()) {
            request.setCommunicateMethod("ONLINE");
        }
        // 시작 방식 (ASAP / DATE)
        if (request.getStartType() == null || request.getStartType().trim().isEmpty()) {
            request.setStartType("ASAP");
        }
        // 예상 기간 (1개월 이하 등)
        if (request.getEstDuration() == null || request.getEstDuration().trim().isEmpty()) {
            request.setEstDuration("1개월 이하");
        }
    }
}