package com.sanaiclub.user.model.dto;


import com.sanaiclub.user.model.vo.UserType;
import com.sanaiclub.user.model.vo.UserVO;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserInfoDTO {

    private Integer userId;
    private String loginId;
    private String email;
    private UserType userType; //사용자 유형 (FREELANCER / CLIENT)
    private String name;
    private String profileImageUrl;


    /**
     * UserVO → UserInfoDTO 변환
     */
    public static UserInfoDTO fromVO(UserVO userVO) {
        if (userVO == null){
           return null;
        }

        return UserInfoDTO.builder()
                .userId(userVO.getUserId())
                .loginId(userVO.getLoginId())
                .email(userVO.getEmail())
                .userType(userVO.getUserType())
                .name(userVO.getName())
                .profileImageUrl(userVO.getProfileImageUrl())
                .build();
    }

    /**
     * 프리랜서 여부 확인
     * @return 프리랜서면 true
     */
    public boolean isFreelancer() {
        return UserType.FREELANCER.equals(this.userType);
    }

    /**
     * 클라이언트 여부 확인
     * @return 클라이언트면 true
     */
    public boolean isClient() {
        return UserType.CLIENT.equals(this.userType);
    }
}
