package com.sanaiclub.common.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * TrustGuidelineController
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [설명]
 * 플랫폼의 신뢰 가이드라인 페이지를 제공하는 컨트롤러입니다.
 * 프리랜서와 클라이언트 간의 안전한 거래를 위한 규칙과 가이드를 제시합니다.
 * 
 * [위치]
 * 패키지: com.sanaiclub.common.controller
 * 파일: TrustGuidelineController.java
 * 
 * [주요 기능]
 * - 신뢰 가이드라인 정보 제공 (정적 페이지)
 * - 플랫폼 사용 규칙 및 주의사항 안내
 * - 분쟁 해결 절차 설명
 * 
 * [라우팅]
 * - GET /trust-guideline : 신뢰 가이드라인 페이지 조회
 * - GET /trust-guideline.do : 신뢰 가이드라인 페이지 조회 (대체 경로)
 * 
 * [특징]
 * - 데이터베이스 쿼리 없는 순수 JSP 렌더링
 * - 사용자 인증 불필요 (누구나 접근 가능)
 * - 정적 콘텐츠로 구성
 * 
 * @author Team SanaiClub (신한DS 금융 SW 아카데미)
 * @version 1.0
 * @since 2026-01-13
 */
@Controller
public class TrustGuidelineController {

    /**
     * ─────────────────────────────────────────────────────────────────
     * [신뢰 가이드라인 페이지]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /trust-guideline, /trust-guideline.do
     * 설명: 플랫폼의 신뢰 가이드라인을 상세히 설명하는 페이지를 제공합니다.
     *      사용자가 안전하게 플랫폼을 이용할 수 있도록 필요한 정보를 제공합니다.
     * 
     * [페이지 내용]
     * - 신뢰 원칙: 플랫폼의 핵심 가치관
     * - 책임 및 의무: 프리랜서와 클라이언트의 책임
     * - 이용 규칙: 금지 사항 및 주의사항
     * - 분쟁 해결: 문제 발생 시 대응 절차
     * - FAQ: 자주 묻는 질문
     * 
     * @return "common/trust-guideline" - src/main/webapp/WEB-INF/views/common/trust-guideline.jsp 렌더링
     */
    @GetMapping({"/trust-guideline", "/trust-guideline.do"})
    public String getTrustGuideline() {
        return "common/trust-guideline";
    }
}
