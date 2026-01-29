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
@RequiredArgsConstructor
public class ChattingController {

    private final ChatService chatService;
    private final SimpMessageSendingOperations messagingTemplate; // STOMP 메시지 전송 템플릿


    // 채팅 아이콘 → 목록 화면
    @GetMapping
    public String chatMain(Model model) {
        // 1. AuthContext에서 로그인한 사용자 ID 및 타입 조회
        Integer loginUserId = AuthContext.getCurrentUserId();
        UserType userType = AuthContext.getCurrentUserType();

        if (loginUserId == null) {
            return "redirect:/login";
        }

        model.addAttribute("loginUserId", loginUserId);
        model.addAttribute("userType", userType != null ? userType.name() : "");

        // 3. 채팅방 목록 조회 로직 (선택 사항: 비동기로 불러온다면 여기선 패스)
        // List<ChatRoomDTO> myRooms = chatService.findMyRooms(loginUserId);
        // model.addAttribute("myRooms", myRooms);

        return "chat/room"; // /WEB-INF/views/chat/room.jsp
    }

    @GetMapping("/room/{roomId}/info")
    @ResponseBody
    public ChatRoomDTO roomInfo( @PathVariable Integer roomId) {
        return chatService.findRoomInfo(roomId, AuthContext.getCurrentUserId());
    }

    @PostMapping("/room/{roomId}/read")
    @ResponseBody
    public void markAsRead(@PathVariable Integer roomId) {
        chatService.markRoomAsRead(roomId, AuthContext.getCurrentUserId());
    }
    @PostMapping("/create-or-get-room")
    @ResponseBody
    public Integer createOrGetRoom(@RequestParam Integer projectId) {
        // 1. 현재 로그인한 유저(프리랜서) ID 가져오기
        Integer freelancerId = AuthContext.getCurrentUserId();

        // 2. 채팅방 생성 서비스 호출
        Integer roomId = chatService.createOrGetRoom(projectId, freelancerId);
        return roomId;
    }
    // 채팅방 목록 데이터 (AJAX)
    @GetMapping("/rooms")
    @ResponseBody
    public List<ChatRoomDTO> rooms() {
        return chatService.findMyRooms(AuthContext.getCurrentUserId());
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
        chatService.exitRoom(roomId, AuthContext.getCurrentUserId());
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
        Integer senderId = AuthContext.getCurrentUserId();
        String uploadPath = session.getServletContext().getRealPath("/") + "upload/chat";
        ChatMessageDTO message = chatService.processAndSendMessage(
                roomId,
                senderId,
                content,
                file,
                uploadPath
        );
        return ResponseEntity.ok(message);
    }
    @GetMapping("/file/{messageId}")
    public ResponseEntity<Resource> downloadFile(
            @PathVariable Integer messageId, HttpSession session
    ) throws Exception {

        // 1️⃣ DB에서 파일 정보 조회
        ChatMessageDTO msg = chatService.findFileByMessageId(messageId);

        if (msg == null || msg.getFileUrl() == null) {
            return ResponseEntity.notFound().build();
        }

        // 2️⃣ 실제 파일 경로
        String contextPath = session.getServletContext().getRealPath("/");
        String filePath = contextPath + msg.getFileUrl();
        File file = new File(filePath);

        if (!file.exists()) {
            return ResponseEntity.notFound().build();
        }
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

    @PostMapping("/message/{messageId}/delete")
    @ResponseBody
    public ResponseEntity<?> deleteMessage(@PathVariable int messageId, @RequestBody Map<String, Integer> payload) {
        try {
            Integer roomId = payload.get("roomId"); // 클라이언트에서 roomId를 함께 전달받음
            if (roomId == null) {
                return ResponseEntity.badRequest().body("roomId is missing");
            }
            chatService.deleteMessage(messageId);

            Map<String, Object> deleteSignal = new HashMap<>();
            deleteSignal.put("type", "DELETE");
            deleteSignal.put("messageId", messageId);

            messagingTemplate.convertAndSend("/sub/chat/room/" + roomId, deleteSignal);

            return ResponseEntity.ok().build();
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Fail to delete");
        }
    }
}