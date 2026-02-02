package com.sanaiclub.chat.controller;

import com.sanaiclub.chat.model.dto.ChatMessageDTO;
import com.sanaiclub.chat.model.dto.ChatRoomDTO;
import com.sanaiclub.chat.service.ChatService;
import com.sanaiclub.common.util.AuthContext;
import com.sanaiclub.user.model.vo.UserType;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/chat")
public class ChattingController {

    @GetMapping
    public String chatMain(Model model) {
        Integer loginUserId = AuthContext.getCurrentUserId();
        UserType userType = AuthContext.getCurrentUserType();

        if (loginUserId == null) {
            return "redirect:/login";
        }
        model.addAttribute("loginUserId", loginUserId);
        model.addAttribute("userType", userType != null ? userType.name() : "");
        return "chat/room";
    }



}