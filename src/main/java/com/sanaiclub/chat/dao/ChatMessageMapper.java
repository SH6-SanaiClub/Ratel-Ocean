package com.sanaiclub.chat.dao;

import com.sanaiclub.chat.model.dto.ChatMessageDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ChatMessageMapper {
    List<ChatMessageDTO> findMessages(@Param("roomId") Integer roomId);

    ChatMessageDTO findFileByMessageId(Integer messageId);

    int insertMessage(ChatMessageDTO message);

    void markRoomMessagesAsRead(
            @Param("roomId") Integer roomId,
            @Param("loginUserId") Integer loginUserId
    );

    void deleteMessage(@Param("messageId") Integer messageId);
}
