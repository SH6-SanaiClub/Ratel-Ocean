package com.sanaiclub.domain.user.controller;

import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * UserController
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [설명]
 * 사용자 관련 요청을 처리하는 컨트롤러입니다.
 * 회원가입, 로그인 등 사용자 도메인의 주요 기능을 담당합니다.
 * 
 * [위치]
 * 패키지: com.sanaiclub.domain.user.controller
 * 파일: UserController.java
 * 
 * [기본 경로]
 * @RequestMapping("/") - 모든 엔드포인트는 /join, /login 등으로 시작합니다.
 * 
 * [회원가입 흐름]
 * 1. GET /join/select-role.do
 *    └─ 사용자가 프리랜서 또는 클라이언트 역할을 선택하는 페이지 표시
 * 
 * 2. POST /join/select-role.do
 *    └─ 선택한 역할을 HttpSession에 저장
 *    └─ 프론트엔드에 리다이렉트 URL 반환 (JSON)
 * 
 * 3. GET /join/signup.do
 *    └─ 회원정보 입력 페이지 표시 (이메일, 비밀번호, 전화번호 등)
 * 
 * [로그인 흐름]
 * GET /login, /login.do → 로그인 폼 표시
 * 
 * [현재 상태]
 * - JSP 렌더링 및 세션 저장만 구현됨
 * - 실제 회원가입 검증 및 DB 저장은 미구현
 * 
 * [향후 계획]
 * 실제 회원가입 로직은 domain/user/service/UserService에서 처리될 예정:
 * ├─ 이메일 중복 확인
 * ├─ 비밀번호 검증 및 암호화
 * ├─ 전화번호 인증
 * ├─ 프로필 정보 저장 (프리랜서/클라이언트별 상이)
 * └─ 세션 생성 및 로그인 처리
 * 
 * @author Team SanaiClub (신한DS 금융 SW 아카데미)
 * @version 1.0
 * @since 2026-01-13
 */
@Controller
public class UserController {

    /**
     * ─────────────────────────────────────────────────────────────────
     * [역할 선택 페이지]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /join/select-role.do
     * 설명: 사용자가 프리랜서 또는 클라이언트 중 역할을 선택하는 페이지를 표시합니다.
     *      이 페이지는 회원가입 프로세스의 첫 번째 단계입니다.
     * 
     * [화면 구성]
     * - 프리랜서 선택 카드: 프로젝트 기반 업무 수행
     * - 클라이언트 선택 카드: 프리랜서에게 일감 발주
     * - 각 역할에 대한 설명 및 장점
     * 
     * @return "user/selectRole" - src/main/webapp/WEB-INF/views/user/selectRole.jsp 렌더링
     */
    @GetMapping("/join/select-role.do")
    public String selectRolePage() {
        return "user/selectRole";
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [역할 선택 처리]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: POST /join/select-role.do
     * 설명: 프론트엔드에서 선택한 역할(FREELANCER 또는 CLIENT)을 HttpSession에 저장합니다.
     *      이후 회원가입 페이지에서 역할별로 다른 입력 필드를 표시하기 위해 사용됩니다.
     * 
     * [처리 과정]
     * 1. @RequestParam으로 선택한 역할(role) 받기
     * 2. HttpSession에 'selectedRole'이라는 이름으로 저장
     * 3. 프론트엔드에 JSON 응답 반환
     *    - "success": true (성공 여부)
     *    - "redirectUrl": "/join/signup.do" (다음 단계 페이지)
     * 
     * @param role 선택한 역할 (예: "FREELANCER", "CLIENT")
     * @param session HttpSession 객체 - 역할 정보를 세션에 저장하기 위해 사용
     * @return JSON 문자열 - {"success":true,"redirectUrl":"/join/signup.do"}
     */
    @PostMapping("/join/select-role.do")
    @ResponseBody
    public String selectRole(@RequestParam String role, HttpSession session) {
        // 역할 저장 - 다음 단계(회원정보 입력)에서 참조
        session.setAttribute("selectedRole", role);
        return "{\"success\":true,\"redirectUrl\":\"/join/signup.do\"}";
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [회원가입 정보 입력 페이지]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /join/signup, /join/signup.do
     * 설명: 사용자가 실제 회원가입 정보(이메일, 비밀번호, 전화번호 등)를 입력하는 페이지를 표시합니다.
     *      이전 단계에서 선택한 역할(FREELANCER 또는 CLIENT)에 따라 입력 필드가 달라집니다.
     * 
     * [입력 필드 - 공통]
     * - 이메일 (중복 확인 필수)
     * - 비밀번호 (보안 규칙 적용)
     * - 비밀번호 확인
     * - 이름 (실명)
     * - 전화번호 (인증 필수)
     * 
     * [입력 필드 - 프리랜서 추가]
     * - 주요 기술스택 선택
     * - 경력 연수
     * - 포트폴리오 URL (선택사항)
     * 
     * [입력 필드 - 클라이언트 추가]
     * - 회사명
     * - 담당 업무
     * - 회사 규모
     * 
     * @return "user/signup" - src/main/webapp/WEB-INF/views/user/signup.jsp 렌더링
     */
    @GetMapping({"/join/signup", "/join/signup.do"})
    public String signupPage() {
        return "user/signup";
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [로그인 페이지]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /login, /login.do
     * 설명: 사용자 로그인 페이지를 표시합니다.
     *      이메일과 비밀번호를 입력받아 로그인을 처리합니다.
     * 
     * [입력 필드]
     * - 이메일
     * - 비밀번호
     * 
     * [기능]
     * - 로그인 처리 (POST /login.do)
     * - 비밀번호 찾기 링크
     * - 회원가입 링크 (/join/select-role.do)
     * 
     * @return "user/login" - src/main/webapp/WEB-INF/views/user/login.jsp 렌더링
     */
    @GetMapping({"/login", "/login.do"})
    public String loginPage() {
        return "user/login";
    }
}
