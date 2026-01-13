package com.sanaiclub.domain.career.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * CareerController
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [설명]
 * 프리랜서의 경력, 포트폴리오, 기술스택을 관리하는 컨트롤러입니다.
 * 프리랜서 프로필의 핵심 요소들을 편집하고 조회하는 기능을 담당합니다.
 * 
 * [위치]
 * 패키지: com.sanaiclub.domain.career.controller
 * 파일: CareerController.java
 * 
 * [라우팅]
 * - GET /career : 경력 관리 페이지
 * - GET /mypage : 마이페이지 (사용자 정보 조회/수정)
 * 
 * [향후 기능 (미구현)]
 * - GET /career/{id} : 경력 상세 조회
 * - POST /career : 경력 추가
 * - PUT /career/{id} : 경력 수정
 * - DELETE /career/{id} : 경력 삭제
 * - POST /career/{id}/portfolio : 포트폴리오 업로드
 * - POST /career/skills : 기술스택 추가/수정
 * 
 * @author Team SanaiClub (신한DS 금융 SW 아카데미)
 * @version 1.0
 * @since 2026-01-13
 */
@Controller
public class CareerController {

    /**
     * ─────────────────────────────────────────────────────────────────
     * [경력 관리]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /career
     * 설명: 프리랜서가 자신의 경력을 관리하는 페이지입니다.
     *      - 경력 사항 입력/수정
     *      - 포트폴리오 등록/관리
     *      - 기술스택 추가/삭제
     *      - 자격증 등록
     * 
     * [표시 정보]
     * - 경력 사항 목록 (회사명, 직책, 기간)
     * - 포트폴리오 프로젝트 목록
     * - 보유 기술스택 (기술명, 경력도)
     * - 자격증 목록
     * 
     * [기능]
     * - 경력 추가/수정/삭제
     * - 포트폴리오 이미지 업로드
     * - 기술스택 검색 및 추가
     * - 자격증 스캔본 업로드
     * 
     * @return "career/career" - src/main/webapp/WEB-INF/views/career/career.jsp 렌더링
     */
    @GetMapping("/career")
    public String career() {
        return "career/career";
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [마이페이지]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /mypage
     * 설명: 사용자 개인정보 조회 및 수정, 계정 설정을 관리하는 페이지입니다.
     *      프리랜서와 클라이언트의 페이지 구성이 다를 수 있습니다.
     * 
     * [표시 정보]
     * - 기본 정보 (이름, 이메일, 전화번호)
     * - 프로필 이미지
     * - 소개 글
     * - 관심사 / 특기
     * 
     * [기능]
     * - 프로필 사진 변경
     * - 기본 정보 수정
     * - 소개 글 수정
     * - 비밀번호 변경
     * - 계정 보안 설정
     * 
     * @return "career/mypage" - src/main/webapp/WEB-INF/views/career/mypage.jsp 렌더링
     */
    @GetMapping("/mypage")
    public String mypage() {
        return "career/mypage";
    }
}
