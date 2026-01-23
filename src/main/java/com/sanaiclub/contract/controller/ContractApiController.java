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

/**
 * ============================================================================
 * ContractApiController - 계약 관련 API 컨트롤러
 * ============================================================================
 * 
 * [역할]
 * - AJAX 요청을 처리하는 RESTful API 컨트롤러
 * - JSON 응답 제공
 * - 비동기 데이터 로딩 지원
 * 
 * [주요 기능]
 * - GET /client/contract/freelancers: 프로젝트별 프리랜서 목록 조회 (JSON)
 * 
 * [사용 시나리오]
 * - 계약서 작성 화면에서 프로젝트 선택 시
 * - JavaScript로 AJAX 요청하여 프리랜서 목록 동적 로딩
 * - 프리랜서 드롭다운 목록 업데이트
 * 
 * [응답 형식]
 * - MediaType.APPLICATION_JSON_VALUE
 * - List<Map<String, Object>> 형식
 * 
 * [경로]
 * - Base URL: /client/contract
 * - 클라이언트 전용 API
 * 
 * [책임 분리]
 * - Controller: HTTP 요청 처리, JSON 응답
 * - Mapper: 데이터 접근 (다른 도메인 Mapper 사용 가능)
 * 
 * ============================================================================
 */
@Slf4j
@Controller
@RequestMapping("/client/contract")
@RequiredArgsConstructor
public class ContractApiController {

    private final ContractMapper contractMapper;

    /**
     * 프로젝트별 프리랜서 목록 조회 (AJAX)
     * 
     * [기능]
     * - 계약서 작성 화면에서 프로젝트 선택 시, 해당 프로젝트의 프리랜서 목록을 JSON으로 반환
     * - AJAX 요청으로 동적 로딩
     * - 프로젝트에 지원한 프리랜서 목록 조회
     * 
     * [처리 흐름]
     * 1. projectId로 프로젝트에 지원한 프리랜서 목록 조회
     * 2. List<Map<String, Object>> 형식으로 변환
     * 3. JSON으로 응답
     * 
     * [사용 시나리오]
     * - contractForm.jsp에서 프로젝트 선택 시 JavaScript로 호출
     * - 프리랜서 드롭다운 목록 업데이트
     * - 사용자가 프로젝트를 선택하면 해당 프로젝트의 프리랜서만 표시
     * 
     * [응답 형식]
     * - List<Map<String, Object>>
     * - 각 Map에는 프리랜서 정보 포함 (userId, name, email 등)
     * 
     * [에러 처리]
     * - 예외 발생 시 빈 리스트 반환 (에러 로그 기록)
     * - 클라이언트는 빈 리스트를 받아도 정상 처리
     * 
     * [주의사항]
     * - project 도메인의 Mapper를 사용 (Controller에서 여러 도메인 조합 가능)
     * - 프리랜서가 없으면 빈 리스트 반환
     * 
     * @param projectId 프로젝트 ID (필수, 쿼리 파라미터)
     *                  - URL: /client/contract/freelancers?projectId=100
     * @return 프리랜서 목록 (JSON, List<Map<String, Object>>)
     *         - 프리랜서가 없거나 오류 발생 시 빈 리스트 반환
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
