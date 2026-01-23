package com.sanaiclub.contract.model.vo;

import lombok.Builder;
import lombok.Getter;

/**
 * ContractFreelancerVO - 프리랜서 정보 VO
 * 
 * [역할]
 * - 계약 관련 프리랜서 정보를 담는 불변 객체
 * - Builder 패턴으로만 생성
 */
@Getter
@Builder
public class ContractFreelancerVO {
    private final Integer id;
    private final String name;
    private final String email;
    private final String phone;
    private final String nickname;
    private final String introduction;
}
