package com.sanaiclub.payment.model.dto;

import com.sanaiclub.contract.model.vo.MilestoneStatus;
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
public class PayoutResponseDTO {

    /** 마일스톤 ID */
    private Integer milestoneId;

    /** 계약 ID */
    private Integer contractId;

    /** 지급 금액 */
    private Long amount;

    /** 마일스톤 상태 */
    private MilestoneStatus milestoneStatus;

    /** 프리랜서 지갑 잔액 (지급 후) */
    private Long walletBalance;

    /** 지급 완료 시각 */
    private LocalDateTime paidAt;

    /** 성공 여부 */
    private Boolean success;

    /** 메시지 */
    private String message;
}