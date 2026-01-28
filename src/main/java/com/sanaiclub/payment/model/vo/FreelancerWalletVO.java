package com.sanaiclub.payment.model.vo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;


@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FreelancerWalletVO {

    /** 지갑 ID (PK) */
    private Integer walletId;

    /** 프리랜서 user_id (FK) */
    private Integer userId;

    /** 현재 잔액 */
    private Long balance;

    /** 누적 수익 */
    private Long totalEarned;

    /** 낙관적 락을 위한 버전 */
    private Integer version;

    /** 생성일시 */
    private LocalDateTime createdAt;

    /** 수정일시 */
    private LocalDateTime updatedAt;
}