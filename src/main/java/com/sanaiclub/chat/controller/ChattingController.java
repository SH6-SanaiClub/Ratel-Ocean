package com.sanaiclub.chat.controller;

import com.sanaiclub.chat.dao.ChatMessageMapper;
import com.sanaiclub.chat.model.dto.ChatMessageDTO;
import com.sanaiclub.chat.model.dto.ChatRoomDTO;
import com.sanaiclub.chat.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.MessageMapping;
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
@RequiredArgsConstructor
public class ChattingController {

    private final ChatService chatService;
    private final SimpMessageSendingOperations messagingTemplate; // STOMP 메시지 전송 템플릿
    private final ChatMessageMapper chatMessageMapper;

    /*
    /**
     * [STOMP] 실시간 메시지 전송 처리
     * 클라이언트가 '/pub/chat/message'로 메시지를 보내면 이 메서드가 실행됨

    @MessageMapping("/chat/message")
    public void message(ChatMessageDTO message) {
        // 1. DB 저장 및 메시지 정보 반환 (ID, 생성시간 등 포함)
        ChatMessageDTO savedMessage = chatService.sendAndReturnMessage(
                message.getRoomId(),
                message.getSenderId(),
                message.getContent(),
                message.getFileName(),
                message.getFileUrl(),
                message.getFileSize()
        );

        // 2. 해당 방(Room) 구독자들에게 메시지 전송 (채팅방 안의 대화 내용 갱신)
        messagingTemplate.convertAndSend("/sub/chat/room/" + savedMessage.getRoomId(), savedMessage);

        // 3-1. 보낸 사람(나)의 채팅 목록 갱신
        messagingTemplate.convertAndSend("/sub/chat/list/" + message.getSenderId(), savedMessage);

        // 3-2. 받는 사람(상대방) 찾기 및 채팅 목록 갱신
        ChatRoomDTO roomInfo = chatService.findRoomInfo(message.getRoomId(), message.getSenderId());

        if (roomInfo != null) {
            Integer opponentId = roomInfo.getOpponentId();
            if (opponentId != null) {
                messagingTemplate.convertAndSend("/sub/chat/list/" + opponentId, savedMessage);
            }
        }
    }
*/
    // 채팅 아이콘 → 목록 화면
    @GetMapping
    public String chatMain(HttpSession session) {
        session.setAttribute("loginUserId", chatService.getLoginUserId());
        return "chat/room";
    }


    @GetMapping("/room/{roomId}/info")
    @ResponseBody
    public ChatRoomDTO roomInfo(
            @PathVariable Integer roomId,
            HttpSession session
    ) {
        Integer loginUserId = chatService.getLoginUserId(); // 실제 세션 로그인 유저 id로 교체

        // 서비스에서 ChatRoomDTO 반환하도록
        ChatRoomDTO dto = chatService.findRoomInfo(roomId, loginUserId);
        System.out.println(" ChatRoomDTO:" + dto);
        return dto;
    }

    @PostMapping("/room/{roomId}/read")
    @ResponseBody
    public void markAsRead(@PathVariable Integer roomId) {
        chatService.markRoomAsRead(roomId);
    }

    // 채팅방 목록 데이터 (AJAX)
    @GetMapping("/rooms")
    @ResponseBody
    public List<ChatRoomDTO> rooms() {
        return chatService.findMyRooms();
    }

    // 메시지 목록 조회
    @GetMapping("/room/{roomId}/messages")
    @ResponseBody
    public List<ChatMessageDTO> getMessages(@PathVariable Integer roomId) {
        return chatService.findMessages(roomId);
    }
    //방 나가기
    @PostMapping("/room/{roomId}/exit")
    @ResponseBody
    public String exitRoom(@PathVariable Integer roomId, HttpSession session) {
        Integer loginUserId = chatService.getLoginUserId();
        chatService.exitRoom(roomId, loginUserId);

        return "ok";
    }
    // 메시지 전송
    @PostMapping("/room/{roomId}/message")
    public ResponseEntity<ChatMessageDTO> sendMessage(
            @PathVariable Integer roomId,
            @RequestParam String content,
            @RequestParam(required = false) MultipartFile file,
            HttpSession session
    ) throws IOException {
        String fileName = null;
        String fileUrl = null;
        Long fileSize = null;

        if (file != null && !file.isEmpty()) {
            fileName = file.getOriginalFilename();
            fileSize = file.getSize();
            String uploadDir = session.getServletContext().getRealPath("/") + "upload/chat";
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();
            File savedFile = new File(uploadDir, fileName);
            file.transferTo(savedFile);
            fileUrl = "/upload/chat/" + fileName;
        }

        // --- [1. DB 저장] ---
        Integer senderId = chatService.getLoginUserId();
        ChatMessageDTO message =
                chatService.sendAndReturnMessage(
                        roomId,
                        senderId,
                        content,
                        fileName,
                        fileUrl,
                        fileSize
                );
        messagingTemplate.convertAndSend("/sub/chat/room/" + roomId, message);
        messagingTemplate.convertAndSend("/sub/chat/list/" + senderId, message);
        ChatRoomDTO roomInfo = chatService.findRoomInfo(roomId, senderId);
        if (roomInfo != null && roomInfo.getOpponentId() != null) {
            messagingTemplate.convertAndSend("/sub/chat/list/" + roomInfo.getOpponentId(), message);
        }

        return ResponseEntity.ok(message);
    }
    @GetMapping("/file/{messageId}")
    public ResponseEntity<Resource> downloadFile(
            @PathVariable Integer messageId, HttpSession session
    ) throws Exception {

        // 1️⃣ DB에서 파일 정보 조회
        ChatMessageDTO msg = chatMessageMapper.findFileByMessageId(messageId);

        if (msg == null || msg.getFileUrl() == null) {
            return ResponseEntity.notFound().build();
        }

        // 2️⃣ 실제 파일 경로

        String filePath = session.getServletContext().getRealPath("/upload/chat") + "/" + msg.getFileName();
        System.out.println(filePath);
        File file = new File(filePath);

        if (!file.exists()) {
            System.out.println("파일존재XXXX");
            return ResponseEntity.notFound().build();
        }
        System.out.println("파일존재");
        // 3️⃣ Resource로 변환
        Resource resource = new FileSystemResource(file);

        // 4️⃣ 파일명 인코딩 (한글 깨짐 방지)
        String encodedFileName =
                URLEncoder.encode(msg.getFileName(), "UTF-8").replaceAll("\\+", "%20");

        // 5️⃣ 다운로드 헤더
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename=\"" + encodedFileName + "\"")
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .contentLength(file.length())
                .body(resource);
    }

    // 채팅방 진입 (화면)
    @GetMapping("/room/{roomId}") // room_id -> roomId
    public String roomPage(@PathVariable Integer roomId, Model model, HttpSession httpSession) {
        // login_user_id -> loginUserId
        Integer loginUserId = (Integer) httpSession.getAttribute("loginUserId");
        model.addAttribute("roomId", roomId); // room_id -> roomId
        httpSession.setAttribute("loginUserId", chatService.getLoginUserId());
        return "chat/room";
    }

    @PostMapping("/message/{messageId}/delete") // message_id -> messageId
    @ResponseBody
    public ResponseEntity<?> deleteMessage(@PathVariable int messageId) {
        try {
            chatService.deleteMessage(messageId); // delete_message -> deleteMessage
            return ResponseEntity.ok().build(); // 200 OK
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("삭제 실패");
        }
    }
}