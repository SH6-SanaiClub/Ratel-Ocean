package com.sanaiclub.user.model.dto;

import com.sanaiclub.user.model.vo.ClientType;
import lombok.*;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * 클라이언트 유형 선택 DTO
 * ═══════════════════════════════════════════════════════════════════════
 *
 * [역할]
 * - 클라이언트 회원가입 3단계: 개인/법인 선택
 *
 * [선택지]
 * - PERSONAL: 개인 클라이언트 (사업자 번호 X)
 * - CORPORATION: 법인 클라이언트 (사업자 번호 O)
 *
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ClientTypeSelectDTO {

    /**
     * 클라이언트 유형
     */
    private ClientType clientType;

    /**
     * 법인인지 확인
     *
     * @return 법인이면 true
     */
    public boolean isCorporation() {
        return ClientType.CORPORATION.equals(this.clientType);
    }

    /**
     * 개인인지 확인
     *
     * @return 개인이면 true
     */
    public boolean isPersonal() {
        return ClientType.PERSONAL.equals(this.clientType);
    }
}