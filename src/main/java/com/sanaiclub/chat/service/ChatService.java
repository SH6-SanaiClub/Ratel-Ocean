package com.sanaiclub.chat.service;

import com.sanaiclub.chat.dao.ChatMessageMapper;
import com.sanaiclub.chat.dao.ChatRoomMapper;
import com.sanaiclub.chat.model.dto.ChatMessageDTO;
import com.sanaiclub.chat.model.dto.ChatRoomDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final ChatRoomMapper chatRoomMapper;
    private final ChatMessageMapper chatMessageMapper;
    private final Map<Integer, Integer> typingMap = new ConcurrentHashMap<>();

    // =========================================
    // 1. 내 채팅방 목록 조회 (AJAX용)
    // =========================================
    @Transactional
    public List<ChatRoomDTO> findMyRooms() { // find_my_rooms -> findMyRooms
        Integer loginUserId = getLoginUserId();
        List<ChatRoomDTO> rooms = chatRoomMapper.findMyRooms(loginUserId);
        return rooms;
    }
    @Transactional
    public ChatMessageDTO sendAndReturnMessage(Integer roomId, Integer senderId, String content, String fileName, String fileUrl, Long fileSize) {
        chatMessageMapper.insertMessage(roomId, senderId, content, fileName, fileUrl, fileSize);
        List<ChatMessageDTO> messages = chatMessageMapper.findMessages(roomId);
        ChatMessageDTO newMessage = messages.get(messages.size() - 1);
        chatRoomMapper.updateLastMessage(roomId, content != null ? content : "파일을 보냈습니다.");
        return newMessage;
    }
    // =========================================
    // 2. 단일 채팅방 조회
    // =========================================
    public List<ChatMessageDTO> findRoomById(Integer roomId, Integer loginUserId) {
        return chatRoomMapper.findRoomById(roomId, loginUserId);
    }

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
    public void updateTyping(Integer roomId, boolean typing) {
        Integer userId = getLoginUserId();
        if (typing) {
            typingMap.put(roomId, userId);
        } else {
            typingMap.remove(roomId);
        }
    }
    public Integer getTypingUser(Integer roomId) {
        return typingMap.get(roomId);
    }
    @Transactional
    public void sendMessage(Integer roomId, String content, String fileName, String fileUrl, Long fileSize) {
        Integer senderId = getLoginUserId();
        chatMessageMapper.insertMessage(roomId, senderId, content, fileName, fileUrl, fileSize);

        // 마지막 메시지 업데이트 (update_last_message -> updateLastMessage)
        chatRoomMapper.updateLastMessage(roomId, content);
    }

    // =========================================
    // 5. 공유 파일 조회
    // =========================================
    public List<ChatMessageDTO> findSharedFiles(Integer roomId) {
        List<ChatMessageDTO> messages = chatMessageMapper.findMessages(roomId);
        // getFile_url -> getFileUrl (DTO가 카멜로 바뀌었을 때 기준)
        messages.removeIf(m -> m.getFileUrl() == null || m.getFileUrl().isEmpty());
        return messages;
    }

    // =========================================
    // 6. 메시지 읽음 처리
    // =========================================
    @Transactional
    public void markRoomAsRead(Integer roomId) {
        Integer loginUserId = getLoginUserId();
        chatMessageMapper.markRoomMessagesAsRead(roomId, loginUserId);
    }

    public void resetTyping(Integer roomId) {
        typingMap.remove(roomId);
    }

    // =========================================
    // 7. 메시지 삭제
    // =========================================
    public void deleteMessage(Integer messageId) {
        chatMessageMapper.deleteMessage(messageId);
    }
    //방 나가기
    @Transactional
    public void exitRoom(Integer roomId) {
        Integer userId = getLoginUserId();
        chatRoomMapper.exitRoom(roomId, userId);
    }

    // =========================================
    // 로그인 유저 ID 가져오기 (테스트용)
    // =========================================
    private Integer getLoginUserId() {
        return 1; // 테스트용 하드코딩 유지
    }
}
