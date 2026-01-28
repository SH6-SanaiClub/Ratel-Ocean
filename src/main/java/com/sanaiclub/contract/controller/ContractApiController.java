package com.sanaiclub.contract.controller;

import com.sanaiclub.contract.service.ContractService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/** 계약 관련 API 컨트롤러. AJAX 요청 처리 및 JSON 응답 제공. */
@Slf4j
@Controller
@RequestMapping("/client/contract")
@RequiredArgsConstructor
public class ContractApiController {

    private final ContractService contractService;

    /** 프로젝트별 프리랜서 목록 조회. AJAX 요청으로 JSON 응답. */
    @GetMapping(value = "/freelancers", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public List<Map<String, Object>> freelancersByProject(@RequestParam("projectId") Integer projectId) {
        try {
            // Service를 통해 프로젝트에 지원한 프리랜서 목록 조회
            List<Map<String, Object>> freelancerList = contractService.getFreelancersByProjectId(projectId);
            
            if (freelancerList == null) {
                freelancerList = new ArrayList<>();
            }
            
            log.debug("프로젝트 {}의 프리랜서 목록 조회: {}명", projectId, freelancerList.size());
            return freelancerList;
        } catch (Exception e) {
            log.error("프리랜서 목록 조회 실패: projectId={}, error={}", projectId, e.getMessage(), e);
            return new ArrayList<>();
        }
    }
}
