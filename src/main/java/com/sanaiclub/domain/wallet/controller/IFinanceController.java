package com.sanaiclub.domain.wallet.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * [WalletController 확장]
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * 기존의 registerAccount() 메서드에 금융 관리 관련 메서드들을 추가합니다.
 * (WalletController.java에 기존 내용 이미 포함되어 있음)
 * 
 * 이 파일은 금융 관리 페이지 라우팅을 위한 추가 내용입니다.
 */
@Controller
public interface IFinanceController {

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
    String finance();
}
