package com.sanaiclub.contract.controller;

import com.sanaiclub.contract.dao.ContractMapper;
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


@Slf4j
@Controller
@RequestMapping("/client/contract")
@RequiredArgsConstructor
public class ContractApiController {

    private final ContractMapper contractMapper;

    /**
     * 프로젝트별 프리랜서 목록 조회 (AJAX)
     */
    @GetMapping(value = "/freelancers", produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public List<Map<String, Object>> freelancersByProject(@RequestParam("projectId") Integer projectId) {
        try {
            // contract 도메인의 Mapper를 통해 프로젝트에 지원한 프리랜서 목록 조회
            // contract 도메인 내에서 해결 (다른 도메인 Mapper 참조하지 않음)
            List<Map<String, Object>> freelancerList = contractMapper.selectFreelancersByProjectId(projectId);
            
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
