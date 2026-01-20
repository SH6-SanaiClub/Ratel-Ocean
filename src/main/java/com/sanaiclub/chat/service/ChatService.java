package com.sanaiclub.chat.service;

import com.sanaiclub.chat.dao.ChatMessageMapper;
import com.sanaiclub.chat.dao.ChatRoomMapper;
import com.sanaiclub.chat.model.dto.ChatMessageDTO;
import com.sanaiclub.chat.model.dto.ChatRoomDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final ChatRoomMapper chatRoomMapper;
    private final ChatMessageMapper chatMessageMapper;

    // =========================================
    // 1. 내 채팅방 목록 조회 (AJAX용)
    // =========================================
    public List<ChatRoomDTO> find_my_rooms() {
        Integer login_user_id = getLoginUserId();
        List<ChatRoomDTO> rooms = chatRoomMapper.find_my_rooms(login_user_id);

        for (ChatRoomDTO room : rooms) {
            List<ChatMessageDTO> messages = chatMessageMapper.findMessages(room.getRoom_id());
            if (!messages.isEmpty()) {
                ChatMessageDTO last_msg = messages.get(messages.size() - 1);
                room.setLast_message_content(last_msg.getContent());
                room.setLast_message_at(last_msg.getCreated_at());
                // 로그인 유저가 읽지 않은 메시지 있는지 확인
                room.setHas_new_message(last_msg.getSender_id() != login_user_id && last_msg.getIs_read() == 0);
            } else {
                room.setLast_message_content("아직 메시지가 없습니다.");
            }
        }

        return rooms;
    }

    // =========================================
    // 2. 단일 채팅방 조회
    // =========================================
    public ChatRoomDTO find_room_by_id(Integer room_id) {
        return chatRoomMapper.find_room_by_id(room_id); // Mapper에 selectRoomDetail 구현 필요
    }

    // =========================================
    // 3. 메시지 목록 조회
    // =========================================
    public List<ChatMessageDTO> find_messages(Integer room_id) {
        return chatMessageMapper.findMessages(room_id);
    }

    // =========================================
    // 4. 메시지 전송
    // =========================================
    @Transactional
    public void send_message(Integer room_id, String content, String file_name, String file_url, Long file_size) {
        Integer sender_id = getLoginUserId();

        chatMessageMapper.insertMessage(room_id, sender_id, content, file_name, file_url, file_size);

        // 마지막 메시지 업데이트
        chatRoomMapper.update_last_message(room_id, content);
    }

    // =========================================
    // 5. 공유 파일 조회
    // =========================================
    public List<ChatMessageDTO> find_shared_files(Integer room_id) {
        List<ChatMessageDTO> messages = chatMessageMapper.findMessages(room_id);
        messages.removeIf(m -> m.getFile_url() == null || m.getFile_url().isEmpty());
        return messages;
    }

    // =========================================
    // 6. 메시지 읽음 처리
    // =========================================
    public void mark_as_read(Integer message_id) {
        chatMessageMapper.markAsRead(message_id);
    }

    // =========================================
    // 7. 메시지 삭제
    // =========================================
    public void delete_message(Integer message_id) {
        chatMessageMapper.deleteMessage(message_id);
    }

    // =========================================
    // 로그인 유저 ID 가져오기 (테스트용)
    // =========================================
    private Integer getLoginUserId() {
        // 실제 구현에서는 SecurityContext, Session 등에서 가져오기
        return 1; // 테스트용 하드코딩
    }
}
