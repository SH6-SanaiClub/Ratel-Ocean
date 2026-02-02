package com.sanaiclub.chat.dao;

import com.sanaiclub.chat.model.dto.ChatMessageDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ChatMessageMapper {
    List<ChatMessageDTO> findMessages(@Param("roomId") Integer roomId);

    ChatMessageDTO findFileByMessageId(Integer messageId);

    void insertMessage(
            @Param("roomId") Integer roomId,
            @Param("senderId") Integer senderId,
            @Param("content") String content,
            @Param("fileName") String fileName,
            @Param("fileUrl") String fileUrl,
            @Param("fileSize") Long fileSize
    );

    void markRoomMessagesAsRead(
            @Param("roomId") Integer roomId,
            @Param("loginUserId") Integer loginUserId
    );

    void deleteMessage(@Param("messageId") Integer messageId);
}
