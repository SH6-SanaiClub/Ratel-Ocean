package com.sanaiclub.project.service;

import com.sanaiclub.project.dao.ProjectMapper;
import com.sanaiclub.project.dao.StackMapper;
import com.sanaiclub.project.model.dto.ProjectCreateRequestDTO;
import com.sanaiclub.project.model.dto.StackDto;
import com.sanaiclub.project.model.vo.ProjectStackVO;
import com.sanaiclub.project.model.vo.ProjectVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class ProjectService {

    private static final String UPLOAD_DIR = "D:\\workspace\\Ratel-Ocean\\src\\main\\webapp\\resources\\upload\\project\\";

    @Autowired
    private ProjectMapper projectMapper;

    @Autowired
    private StackMapper stackMapper;

    // 기술 스택을 가져오는 메서드
    public void setStackListToModel(Model model) {
        // DB에서 모든 스택을 가져옴
        List<StackDto> allStack = stackMapper.findAll();

        // 데이터를 담기 위한 리스트 생성
        List<StackDto> positionList = new ArrayList<>();
        List<StackDto> skillList = new ArrayList<>();

        // 가져온 스택 분류
        for (StackDto stack : allStack) {
            // 카테고리가 포지션이면 포지션 리스트에 저장
            if ("POSITION".equals(stack.getCategory())) {
                positionList.add(stack);
                // 카테고리가 스킬이면 스킬 리스트에 저장
            } else if ("SKILL".equals(stack.getCategory())) {
                skillList.add(stack);
            }
        }

        // 분류된 리스트 데이터를 모델에 저장
        model.addAttribute("positionList", positionList);
        model.addAttribute("skillList", skillList);
    }

    // 프로젝트 등록 메서드
    @Transactional
    public void createProject(ProjectCreateRequestDTO request, Integer clientId, MultipartFile planFile) throws IOException {

        ProjectVO projectVO = new ProjectVO();


        // 클라이언트 ID, 프로젝트 제목, 설명 저장
        projectVO.setClientId(clientId);
        projectVO.setTitle(request.getTitle());
        projectVO.setDescription(request.getDescription());

        // 예산 처리
        try {
            // 콤마(,) 및 앞뒤 공백 제거
            String budgetStr = request.getBudget().replace(",", "").trim();
            // 형변환 후 저장
            projectVO.setBudget(Integer.parseInt(budgetStr));
        } catch (Exception e) {
            // 에러시 0 저장
            projectVO.setBudget(0);
        }
        // 예산 협의 가능 여부 처리
        // 받아온 값이 null이 아니고 true인 경우에만 VO에 true 저장
        projectVO.setBudgetNegotiable(request.getBudgetNegotiable() != null && request.getBudgetNegotiable());

        // 기간 처리
        projectVO.setEstDuration(request.getEstDuration());
        // 기간 조율 가능여부도 예산과 동일한 방식으로 VO에 저장
        projectVO.setDurationNegotiable(request.getDurationNegotiable() != null && request.getDurationNegotiable());

        // 시작일 처리
        // ASAP(즉시 착수 가능) 선택 여부 확인
        if ("ASAP".equals(request.getStartType())) {
            // 오늘 날짜 저장
            projectVO.setStartDate(Date.valueOf(LocalDate.now()));
        } else {
            // 즉시 착수 가능 아닐 경우 사용자 선택 날짜 저장
            // 에러 방지용 코드
            if (request.getStartDate() == null || request.getStartDate().isEmpty()) {
                projectVO.setStartDate(Date.valueOf(LocalDate.now()));
            } else {
                // 정상 선택시 사용자 지정 날짜 저장
                projectVO.setStartDate(Date.valueOf(LocalDate.parse(request.getStartDate())));
            }
        }

        // 마감일 계산 (시작일 기준 +30일)
        // java.sql.Date를 계산하기 편한 LocalDate로 잠시 바꾼 뒤 다시 변환
        LocalDate startLocalDate = projectVO.getStartDate().toLocalDate();
        projectVO.setDeadlineDate(Date.valueOf(startLocalDate.plusDays(30)));

        // 기타 정보 저장
        projectVO.setCommunicateMethod(request.getCommunicateMethod());
        projectVO.setPaymentMethod(request.getPaymentMethod());
        projectVO.setMaxRevisionCount(request.getMaxRevisionCount());
        projectVO.setChangePolicy(request.getChangePolicy());
        projectVO.setProjectStatus(request.getProjectStatus());
        projectVO.setIsPublic(request.getIsPublic());
        projectVO.setPlanUrl(request.getPlanUrl());
        projectVO.setFileSize(request.getFileSize());

        // 파일 업로드 및 정보 저장 로직
        if (planFile != null && !planFile.isEmpty()) {
            // 1. 디렉토리 확인 및 생성
            File dir = new File(UPLOAD_DIR);
            if (!dir.exists()) {
                dir.mkdirs();
            }

            // 2. 파일명 중복 방지 (UUID 사용)
            String originalFileName = planFile.getOriginalFilename();
            String savedFileName = UUID.randomUUID().toString() + "_" + originalFileName;

            // 3. 파일 저장 (지정된 로컬 경로)
            File saveFile = new File(UPLOAD_DIR + savedFileName);
            planFile.transferTo(saveFile);

            // 4. DB 저장용 정보 설정
            // 웹 서버 접근 경로 (/resources/...)로 저장
            projectVO.setPlanUrl("/resources/upload/project/" + savedFileName);

            // 파일 크기 계산 (MB 단위)
            double size = (double) planFile.getSize() / (1024 * 1024);
            projectVO.setFileSize(String.format("%.2f MB", size));
        } else {
            // 파일이 없을 경우 null 처리
            projectVO.setPlanUrl(null);
            projectVO.setFileSize(null);
        }

        // 프로젝트 메인 정보 INSERT
        projectMapper.insertProject(projectVO);
        Integer projectId = projectVO.getProjectId();

        // 스택 저장
        Integer inputLevel = request.getMinLevel();
        int inputYear = (request.getMinYear() != null) ? request.getMinYear() : 0;

        // 포지션(직군) 저장
        if (request.getPositionId() != null) {
            ProjectStackVO positionVO = new ProjectStackVO(
                    null,
                    projectId,
                    request.getPositionId(),
                    inputLevel,
                    inputYear
            );
            projectMapper.insertProjectStack(positionVO);
        }

        // 기술 스택 저장
        if (request.getStackIdsUnknown() == null && request.getStackIds() != null) {
            for (Integer stackId : request.getStackIds()) {
                ProjectStackVO skillVO = new ProjectStackVO(
                        null,
                        projectId,
                        stackId,
                        inputLevel,
                        inputYear
                );
                projectMapper.insertProjectStack(skillVO);
            }
        }
    }
}