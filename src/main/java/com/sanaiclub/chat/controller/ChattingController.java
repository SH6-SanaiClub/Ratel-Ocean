package com.sanaiclub.chat.controller;

import com.sanaiclub.chat.model.dto.ChatMessageDTO;
import com.sanaiclub.chat.model.dto.ChatRoomDTO;
import com.sanaiclub.chat.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/chat")
@RequiredArgsConstructor
public class ChattingController {

    private final ChatService chatService;

    // 채팅 아이콘 → 목록 화면
    @GetMapping
    public String roomList() {
        return "chat/roomList";
    }

    // 채팅방 진입 (화면)
    @GetMapping("/room/{room_id}")
    public String roomPage(@PathVariable Integer room_id, Model model) {
        model.addAttribute("room_id", room_id);
        return "chat/room";
    }
    @GetMapping("/room/{room_id}/info")
    @ResponseBody
    public Map<String, Object> roomInfo(@PathVariable Integer room_id) {

        ChatRoomDTO room = chatService.find_room_by_id(room_id);
        Integer loginUserId = 1; // 세션에서

        Integer targetUserId;

        // 예시 구조 (freelancer / client)
        if (room.getSender_id() != null && room.getSender_id().equals(loginUserId)) {
            targetUserId = room.getProject_id(); // 예시 아님, 구조에 맞게
        } else {
            targetUserId = room.getSender_id();
        }

        Map<String, Object> result = new HashMap<>();
        result.put("room_id", room.getRoom_id());
        result.put("name", room.getName());
        result.put("profile_image_url", room.getProfile_image_url());
        result.put("project_id", room.getProject_id());

        // ⭐ 핵심
        result.put("user_id", targetUserId);

        return result;
    }
    @PostMapping("/chat/room/{room_id}/read")
    @ResponseBody
    public void markAsRead(@PathVariable Integer room_id) {
        chatService.markRoomAsRead(room_id);
    }

    // 채팅방 목록 데이터 (AJAX)
    @GetMapping("/rooms")
    @ResponseBody
    public List<ChatRoomDTO> rooms() {
        return chatService.find_my_rooms();
    }

    // 메시지 목록 조회
    @GetMapping("/room/{room_id}/messages")
    @ResponseBody
    public List<ChatMessageDTO> getMessages(@PathVariable Integer room_id) {
        return chatService.find_messages(room_id);
    }
    @GetMapping("/room/{room_id}/typing")
    @ResponseBody
    public Integer getTyping(@PathVariable Integer room_id) {
        return chatService.getTypingUser(room_id);
    }

    @PostMapping("/room/{room_id}/typing")
    @ResponseBody
    public void typing(
            @PathVariable Integer room_id,
            @RequestParam boolean typing
    ) {
        chatService.updateTyping(room_id, typing);
    }

    // 메시지 전송
    @PostMapping("/room/{room_id}/message")
    @ResponseBody
    public void sendMessage(
            @PathVariable Integer room_id,
            @RequestParam(required = false) String content,
            @RequestParam(required = false) MultipartFile file
    ) throws IOException{
        String file_name = null;
        String file_url = null;
        Long file_size = null;

        // 파일 처리
        if (file != null && !file.isEmpty()) {
            file_name = file.getOriginalFilename();
            file_size = file.getSize();

            String uploadDir = "C:/upload/chat";
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();
            File savedFile = new File(uploadDir, file_name);
            file.transferTo(savedFile);
            file_url = "/upload/chat/" + file_name;
        }
            chatService.send_message(room_id, content, file_name, file_url, file_size);


    }


}

