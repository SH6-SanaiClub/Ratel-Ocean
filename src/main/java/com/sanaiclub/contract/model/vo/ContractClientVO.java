package com.sanaiclub.contract.model.vo;

import lombok.Builder;
import lombok.Getter;

/**
 * ContractClientVO - 클라이언트 정보 VO
 * 
 * [역할]
 * - 계약 관련 클라이언트 정보를 담는 불변 객체
 * - Builder 패턴으로만 생성
 */
@Getter
@Builder
public class ContractClientVO {
    private final Integer clientId;
    private final String clientName;
    private final String email;
    private final String phone;
    private final String companyName;
}
