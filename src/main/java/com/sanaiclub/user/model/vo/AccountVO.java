package com.sanaiclub.user.model.vo;

import lombok.*;

import java.time.LocalDateTime;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * AccountVO - accounts 테이블 매핑 VO
 * ═══════════════════════════════════════════════════════════════════════
 *
 * [역할]
 * - 사용자의 정산용 계좌 정보를 담는 객체
 * - 프리랜서: 수익금 출금 계좌
 * - 클라이언트: 프로젝트 대금 결제 계좌 (환불 등)
 *
 * [테이블 관계]
 * users (1) ──────── (N) accounts
 *     userId(PK) ←── userId(FK)
 *
 * [보안 고려사항]
 * - 계좌번호는 민감정보이므로 조회 시 마스킹 처리 필요
 * - 예: "123456789012" → "1234****9012"
 * - DB 저장 시 암호화 고려 가능 (AES 등)
 *
 * @author sanaiclub
 * @version 1.0
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AccountVO {

    private Integer accountId;
    private Integer userId;
    private String bankName;
    private String accountHolder;
    private String accountNumber;
    private LocalDateTime updatedAt;


    // ═══════════════════════════════════════════════════════════════
    // 편의 메서드
    // ═══════════════════════════════════════════════════════════════

    /**
     * 마스킹 처리된 계좌번호 반환
     * - 앞 4자리, 뒤 4자리만 표시
     * - 예: "12345678901234" → "1234****1234"
     *
     * @return 마스킹된 계좌번호
     */
    public String getMaskedAccountNumber() {
        if (this.accountNumber == null || this.accountNumber.length() < 8) {
            return this.accountNumber;
        }

        int length = this.accountNumber.length();
        String front = this.accountNumber.substring(0, 4);
        String back = this.accountNumber.substring(length - 4);
        String mask = "*".repeat(length - 8);

        return front + mask + back;
    }

    /**
     * 계좌 정보 요약 (표시용)
     * - 예: "국민은행 1234****1234"
     *
     * @return 은행명 + 마스킹된 계좌번호
     */
    public String getDisplayInfo() {
        return this.bankName + " " + getMaskedAccountNumber();
    }

    /**
     * 유효한 계좌 정보인지 확인
     * - 필수 필드가 모두 채워져 있는지 검증
     *
     * @return 유효하면 true
     */
    public boolean isValid() {
        return this.bankName != null && !this.bankName.trim().isEmpty()
                && this.accountHolder != null && !this.accountHolder.trim().isEmpty()
                && this.accountNumber != null && !this.accountNumber.trim().isEmpty();
    }

    /**
     * 예금주명 일치 여부 확인
     * - 본인인증 시 사용
     *
     * @param name 비교할 이름
     * @return 일치하면 true
     */
    public boolean isHolderMatch(String name) {
        if (this.accountHolder == null || name == null) {
            return false;
        }
        return this.accountHolder.trim().equals(name.trim());
    }
}