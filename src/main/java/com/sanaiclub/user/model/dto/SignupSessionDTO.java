package com.sanaiclub.user.model.dto;

import com.sanaiclub.user.model.vo.ClientType;
import com.sanaiclub.user.model.vo.UserType;
import lombok.*;

import java.io.Serializable;
import java.time.LocalDate;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * 회원가입 세션 임시 저장 DTO
 * ═══════════════════════════════════════════════════════════════════════
 *
 * [역할]
 * - 회원가입 진행 중 단계별로 입력된 정보를 세션에 임시 저장
 * - 모든 단계 완료 후 한번에 트랜잭션으로 DB INSERT
 *
 * [저장 시점]
 * Step 1: userType 저장
 * Step 2: 공통 정보 (loginId, email, password, name, phone, birthDate) 저장
 * Step 3 (클라이언트만): clientType 저장
 * Step 4 (법인 클라이언트만): companyInfo 저장
 *
 * [세션 키]
 * "signupSession"
 *
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SignupSessionDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    // Step 1: 유저 타입 선택

    /**
     * 사용자 유형 (FREELANCER/CLIENT)
     */
    private UserType userType;

    // Step 2: 공통 정보 입력

    /**
     * 로그인 ID
     */
    private String loginId;

    /**
     * 이메일
     */
    private String email;

    /**
     * 비밀번호 (암호화 전)
     */
    private String password;

    /**
     * 이름
     */
    private String name;

    /**
     * 전화번호
     */
    private String phone;

    /**
     * 생년월일
     */
    private LocalDate birthDate;

    // Step 3: 클라이언트 타입 선택 (클라이언트만)

    /**
     * 클라이언트 유형 (PERSONAL/CORPORATION)
     */
    private ClientType clientType;

    // Step 4: 회사 정보 입력 (법인 클라이언트만)

    /**
     * 회사 정보
     * - clientType이 CORPORATION인 경우에만 사용
     */
    private CompanyRegistrationDTO companyInfo;


    /**
     * 프리랜서인지 확인
     */
    public boolean isFreelancer() {
        return UserType.FREELANCER.equals(this.userType);
    }

    /**
     * 클라이언트인지 확인
     */
    public boolean isClient() {
        return UserType.CLIENT.equals(this.userType);
    }

    /**
     * 법인 클라이언트인지 확인
     */
    public boolean isCorporationClient() {
        return isClient() && ClientType.CORPORATION.equals(this.clientType);
    }

    /**
     * 개인 클라이언트인지 확인
     */
    public boolean isPersonalClient() {
        return isClient() && ClientType.PERSONAL.equals(this.clientType);
    }

    /**
     * Step 1 완료 여부
     */
    public boolean isStep1Complete() {
        return this.userType != null;
    }

    /**
     * Step 2 완료 여부
     */
    public boolean isStep2Complete() {
        return this.loginId != null
                && this.email != null
                && this.password != null
                && this.name != null
                && this.phone != null
                && this.birthDate != null;
    }

    /**
     * Step 3 완료 여부 (클라이언트만 해당)
     */
    public boolean isStep3Complete() {
        if (!isClient()) {
            return true;  // 프리랜서는 Step 3 없음
        }
        return this.clientType != null;
    }

    /**
     * Step 4 완료 여부 (법인 클라이언트만 해당)
     */
    public boolean isStep4Complete() {
        if (!isCorporationClient()) {
            return true;  // 개인 클라이언트는 Step 4 없음
        }
        return this.companyInfo != null && this.companyInfo.isVerified();
    }

    /**
     * 모든 단계 완료 여부
     */
    public boolean isAllStepsComplete() {
        return isStep1Complete()
                && isStep2Complete()
                && isStep3Complete()
                && isStep4Complete();
    }
}