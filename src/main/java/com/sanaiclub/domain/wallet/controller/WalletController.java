package com.sanaiclub.domain.wallet.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * WalletController
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [설명]
 * 사용자의 지갑, 계좌, 결제 수단 관리를 담당하는 컨트롤러입니다.
 * 프리랜서의 환급 계좌 등록과 클라이언트의 결제 수단 등록을 포함합니다.
 * 
 * [위치]
 * 패키지: com.sanaiclub.domain.wallet.controller
 * 파일: WalletController.java
 * 
 * [기본 경로]
 * @RequestMapping("/settings") - 모든 엔드포인트는 /settings로 시작합니다.
 * 
 * [라우팅]
 * - GET /settings/accounts/register : 계좌 등록 페이지
 * - GET /settings/accounts/register.do : 계좌 등록 페이지 (대체 경로)
 * 
 * [향후 기능 (미구현)]
 * - GET /wallet/dashboard : 지갑 대시보드 (잔액 조회)
 * - GET /wallet/transactions : 거래 내역 조회
 * - POST /wallet/charge : 충전 처리
 * - POST /wallet/withdraw : 출금 처리
 * - POST /wallet/refund : 환급 처리
 * 
 * [참고]
 * 실제 계좌 등록, 검증, 거래 처리 등의 로직은
 * domain/wallet/service/WalletService에서 처리될 예정입니다.
 * 
 * @author Team SanaiClub (신한DS 금융 SW 아카데미)
 * @version 1.0
 * @since 2026-01-13
 */
@Controller
@RequestMapping("/settings")
public class WalletController {

    /**
     * ─────────────────────────────────────────────────────────────────
     * [계좌 등록 페이지]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /settings/accounts/register, /settings/accounts/register.do
     * 설명: 프리랜서가 환급받을 계좌를 등록하거나 클라이언트가 결제 수단을 등록하는 페이지입니다.
     * 
     * [수집 정보]
     * - 계좌주명
     * - 은행명
     * - 계좌번호
     * - 계좌 유형 (일반계좌, 기업계좌)
     * 
     * [향후 기능]
     * - 실시간 계좌 검증 (금융결제원 API)
     * - OTP 인증
     * - 계좌 추가/변경/삭제
     * 
     * @return "wallet/registerAccount" - src/main/webapp/WEB-INF/views/wallet/registerAccount.jsp 렌더링
     */
    @GetMapping({"/accounts/register", "/accounts/register.do"})
    public String registerAccount() {
        return "wallet/registerAccount";
    }

    /**
     * ─────────────────────────────────────────────────────────────────
     * [금융 관리]
     * ─────────────────────────────────────────────────────────────────
     * 
     * 엔드포인트: GET /finance
     * 설명: 사용자의 금융 정보를 종합 관리하는 페이지입니다.
     *      - 지갑 잔액 조회
     *      - 거래 내역 (수입/지출)
     *      - 충전/환급 신청
     *      - 계좌 정보 관리
     * 
     * [표시 정보]
     * - 현재 잔액
     * - 이번 달 수입
     * - 이번 달 지출
     * - 최근 거래 내역 (10개)
     * - 보유 계좌 정보
     * 
     * @return "wallet/finance" - src/main/webapp/WEB-INF/views/wallet/finance.jsp 렌더링
     */
    @GetMapping("/finance")
    public String finance() {
        return "wallet/finance";
    }
}
