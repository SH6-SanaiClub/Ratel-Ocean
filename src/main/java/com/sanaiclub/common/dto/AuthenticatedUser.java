package com.sanaiclub.common.dto;

import com.sanaiclub.user.model.vo.UserType;
import lombok.*;

// AuthenticatedUser - 인증된 사용자 정보 DTO
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AuthenticatedUser {

    private Integer userId;
    private String loginId;
    private UserType userType; // FREELANCER / CLIENT

    /**
     * 프리랜서 여부 확인
     *
     * @return 프리랜서이면 true
     */
    public boolean isFreelancer() {
        return UserType.FREELANCER.equals(this.userType);
    }

    /**
     * 클라이언트 여부 확인
     *
     * @return 클라이언트이면 true
     */
    public boolean isClient() {
        return UserType.CLIENT.equals(this.userType);
    }

    /**
     * 특정 사용자 유형인지 확인
     *
     * @param userType 확인할 사용자 유형
     * @return 일치하면 true
     */
    public boolean hasUserType(UserType userType) {
        return this.userType == userType;
    }

    /**
     * 본인 확인
     *
     * @param userId 비교할 사용자 ID
     * @return 현재 사용자의 ID와 일치하면 true
     */
    public boolean isOwner(Integer userId) {
        return this.userId != null && this.userId.equals(userId);
    }

    @Override
    public String toString() {
        return "AuthenticatedUser{" +
                "userId=" + userId +
                ", loginId='" + loginId + '\'' +
                ", userType=" + userType +
                '}';
    }
}
