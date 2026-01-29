package com.sanaiclub.chat.service;

import com.sanaiclub.chat.dao.ChatMessageMapper;
import com.sanaiclub.chat.dao.ChatRoomMapper;
import com.sanaiclub.chat.model.dto.ChatMessageDTO;
import com.sanaiclub.chat.model.dto.ChatRoomDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final ChatRoomMapper chatRoomMapper;
    private final ChatMessageMapper chatMessageMapper;

    public Integer getRoomIdByProject(Integer projectId, Integer userId) {
        return chatRoomMapper.findRoomIdByProjectAndUser(projectId, userId);
    }

    // =========================================
    // 1. 내 채팅방 목록 조회 (AJAX용)
    // =========================================
    @Transactional
    public List<ChatRoomDTO> findMyRooms(Integer loginUserId) {
        List<ChatRoomDTO> rooms = chatRoomMapper.findMyRooms(loginUserId);
        return rooms;
    }
    @Autowired
    private SimpMessagingTemplate messagingTemplate;
    @Transactional
    public ChatMessageDTO processAndSendMessage(Integer roomId, Integer senderId, String content, MultipartFile file, String uploadPath) throws IOException {
        String fileName = null;
        String fileUrl = null;
        Long fileSize = null;
        if (file != null && !file.isEmpty()) {
            String originalFileName = file.getOriginalFilename();
            fileSize = file.getSize();
            String savedFileName = UUID.randomUUID().toString() + "_" + originalFileName;
            File dir = new File(uploadPath);
            if (!dir.exists()) dir.mkdirs();
            File savedFile = new File(uploadPath, savedFileName);
            file.transferTo(savedFile);
            fileName = originalFileName;
            fileUrl = "/upload/chat/" + savedFileName;
        }
        ChatMessageDTO message =sendAndReturnMessage(
                roomId,
                senderId,
                content,
                fileName,
                fileUrl,
                fileSize
        );
        messagingTemplate.convertAndSend("/sub/chat/room/" + roomId, message);
        messagingTemplate.convertAndSend("/sub/chat/list/" + senderId, message);
        ChatRoomDTO roomInfo = findRoomInfo(roomId, senderId);
        if (roomInfo != null && roomInfo.getOpponentId() != null) {
            messagingTemplate.convertAndSend("/sub/chat/list/" + roomInfo.getOpponentId(), message);
        }
        return message;
    }


    @Transactional
    public ChatMessageDTO sendAndReturnMessage(Integer roomId, Integer senderId, String content, String fileName, String fileUrl, Long fileSize) {
        chatMessageMapper.insertMessage(roomId, senderId, content, fileName, fileUrl, fileSize);
        List<ChatMessageDTO> messages = chatMessageMapper.findMessages(roomId);
        ChatMessageDTO newMessage = messages.get(messages.size() - 1);
        chatRoomMapper.updateLastMessage(roomId);
        return newMessage;
    }
    @Transactional
    public Integer createNewRoom(Integer projectId, Integer freelancerId) {
        // 1. 방 정보를 담을 객체 생성
        ChatRoomDTO newRoom = new ChatRoomDTO();
        newRoom.setProjectId(projectId);
        newRoom.setFreelancerId(freelancerId);
        // client_id 컬럼이 필수라면 프로젝트 정보에서 가져오는 로직이 추가될 수 있습니다.

        // 2. DB에 삽입 (Mapper 호출)
        chatRoomMapper.insertChatRoom(newRoom);

        // 3. MyBatis useGeneratedKeys에 의해 newRoom 객체에 자동으로 담긴 roomId 반환
        return newRoom.getRoomId();
    }
    public ChatMessageDTO findFileByMessageId(Integer messageId){
        return chatMessageMapper.findFileByMessageId(messageId);
    }

    // =========================================
    // 2. 단일 채팅방 조회
    // =========================================
    public ChatRoomDTO findRoomInfo(Integer roomId, Integer loginUserId) {
        return chatRoomMapper.findRoomInfo(roomId, loginUserId);
    }
    // =========================================
    // 3. 메시지 목록 조회
    // =========================================
    public List<ChatMessageDTO> findMessages(Integer roomId) {
        return chatMessageMapper.findMessages(roomId);
    }

    // =========================================
    // 4. 메시지 전송
    // =========================================

    // =========================================
    // 6. 메시지 읽음 처리
    // =========================================
    @Transactional
    public void markRoomAsRead(Integer roomId, Integer loginUserId) {
        chatMessageMapper.markRoomMessagesAsRead(roomId, loginUserId);
    }

    // =========================================
    // 7. 메시지 삭제
    // =========================================
    public void deleteMessage(Integer messageId) {
        chatMessageMapper.deleteMessage(messageId);
    }
    //방 나가기
    public void exitRoom(Integer roomId, Integer userId) {
        Map<String, Object> param = new HashMap<>();
        param.put("roomId", roomId);
        param.put("userId", userId);

        // 1. 채팅방 상태 업데이트
        chatRoomMapper.exitRoom(param);

    }

}
