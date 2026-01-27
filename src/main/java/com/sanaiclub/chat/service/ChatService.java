package com.sanaiclub.chat.service;

import com.sanaiclub.chat.dao.ChatMessageMapper;
import com.sanaiclub.chat.dao.ChatRoomMapper;
import com.sanaiclub.chat.model.dto.ChatMessageDTO;
import com.sanaiclub.chat.model.dto.ChatRoomDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final ChatRoomMapper chatRoomMapper;
    private final ChatMessageMapper chatMessageMapper;

    // =========================================
    // 1. 내 채팅방 목록 조회 (AJAX용)
    // =========================================
    @Transactional
    public List<ChatRoomDTO> findMyRooms(Integer loginUserId) {
        List<ChatRoomDTO> rooms = chatRoomMapper.findMyRooms(loginUserId);
        return rooms;
    }

    public Map<String, Object> getRoomParticipants(int roomId) {
        return chatRoomMapper.findParticipantsByRoomId(roomId);
    }

    @Transactional
    public ChatMessageDTO sendAndReturnMessage(Integer roomId, Integer senderId, String content, String fileName, String fileUrl, Long fileSize) {
        chatMessageMapper.insertMessage(roomId, senderId, content, fileName, fileUrl, fileSize);
        List<ChatMessageDTO> messages = chatMessageMapper.findMessages(roomId);
        ChatMessageDTO newMessage = messages.get(messages.size() - 1);
        chatRoomMapper.updateLastMessage(roomId);
        return newMessage;
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
    // 5. 공유 파일 조회
    // =========================================
    public List<ChatMessageDTO> findSharedFiles(Integer roomId) {
        List<ChatMessageDTO> messages = chatMessageMapper.findMessages(roomId);
        messages.removeIf(m -> m.getFileUrl() == null || m.getFileUrl().isEmpty());
        return messages;
    }

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
