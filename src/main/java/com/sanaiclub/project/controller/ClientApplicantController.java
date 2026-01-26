package com.sanaiclub.project.controller;

import com.sanaiclub.project.model.dto.ClientApplicantDTO;
import com.sanaiclub.project.service.ClientApplicantService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/client/api")
@RequiredArgsConstructor
public class ClientApplicantController {

    private final ClientApplicantService clientApplicantService;

    // 지원자 목록 조회
    @GetMapping("/applicants")
    public List<ClientApplicantDTO> getApplicantList(@RequestParam("projectId") Integer projectId) {
        return clientApplicantService.getApplicants(projectId);
    }

    // 지원자 상세 조회 (자동 열람 처리 포함)
    @GetMapping("/applicant/{applicationId}")
    public ClientApplicantDTO getApplicantDetail(@PathVariable("applicationId") Integer applicationId) {
        return clientApplicantService.getApplicantDetail(applicationId);
    }

    // 상태 변경 API (채팅, 계약, 합격/불합격 등 버튼용)
    @PostMapping("/applicant/status")
    public void updateStatus(@RequestParam("applicationId") Integer applicationId,
                             @RequestParam("status") String status) {
        clientApplicantService.updateStatus(applicationId, status);
    }
}