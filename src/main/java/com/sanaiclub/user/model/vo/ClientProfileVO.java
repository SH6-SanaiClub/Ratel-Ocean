package com.sanaiclub.user.model.vo;

import lombok.*;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * ClientProfileVO - client_profiles 테이블 매핑 VO
 * ═══════════════════════════════════════════════════════════════════════
 *
 * [역할]
 * - 클라이언트 전용 프로필 정보를 담는 객체
 * - users 테이블과 1:1 관계 (clientId가 PK이자 FK)
 * - 법인 클라이언트의 경우 companies 테이블과 연결
 *
 * [테이블 관계]
 * users (1) ──────── (1) client_profiles (N) ──────── (1) companies
 *      userId(PK) ←── clientId(PK,FK)   companyId(FK) ──→ companyId(PK)
 *
 * [클라이언트 유형]
 * - GENERAL: 일반 (개인/법인 구분 전)
 * - PERSONAL: 개인 클라이언트 (회사 정보 없음)
 * - CORPORATION: 법인 클라이언트 (회사 정보 필수)
 *
 * @author sanaiclub
 * @version 1.0
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ClientProfileVO {

    private int clientId;
    private Long companyId;
    private ClientType clientType;


    // ═══════════════════════════════════════════════════════════════
    // 편의 메서드
    // ═══════════════════════════════════════════════════════════════

    /**
     * 법인 클라이언트 여부 확인
     * @return 법인이면 true
     */
    public boolean isCorporation() {
        return ClientType.CORPORATION.equals(this.clientType);
    }

    /**
     * 개인 클라이언트 여부 확인
     * @return 개인이면 true
     */
    public boolean isPersonal() {
        return ClientType.PERSONAL.equals(this.clientType);
    }

    /**
     * 회사 정보 연결 여부 확인
     * @return 회사가 연결되어 있으면 true
     */
    public boolean hasCompany() {
        return this.companyId != null;
    }

    /**
     * 클라이언트 유형 설정이 완료되었는지 확인
     * @return GENERAL이 아니면 true (유형 선택 완료)
     */
    public boolean isTypeSelected() {
        return !ClientType.GENERAL.equals(this.clientType);
    }
}