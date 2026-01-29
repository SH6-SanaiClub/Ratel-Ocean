package com.sanaiclub.common.util;

import com.sanaiclub.user.model.vo.UserType;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice
public class GlobalUserInfoAdvice {

    @ModelAttribute("userType")
    public UserType userType() {
        return AuthContext.getCurrentUserType();
    }

    @ModelAttribute("userId")
    public Integer userId(){
        return AuthContext.getCurrentUserId();
    }
}
