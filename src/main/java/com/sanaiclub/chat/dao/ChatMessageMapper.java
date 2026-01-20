package com.sanaiclub.chat.dao;

import com.sanaiclub.chat.model.dto.ChatMessageDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ChatMessageMapper {

    List<ChatMessageDTO> findMessages(@Param("room_id")Integer room_id);

    void insertMessage(
            @Param("room_id") Integer room_id,
            @Param("sender_id") Integer sender_id,
            @Param("content") String content,
            @Param("file_name") String file_name,
            @Param("file_url") String file_url,
            @Param("file_size") Long file_size
    );
    void markRoomMessagesAsRead(
            @Param("room_id") Integer room_id,
            @Param("login_user_id") Integer login_user_id
    );


    // 메시지 삭제 처리
    void deleteMessage(
            @Param("message_id") Integer message_id
    );
}
