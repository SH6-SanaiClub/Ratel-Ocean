package com.sanaiclub.chat.dao;

import com.sanaiclub.chat.model.dto.ChatMessageDTO;
import com.sanaiclub.chat.model.dto.ChatRoomDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface ChatRoomMapper {
    void insertChatRoom(ChatRoomDTO chatRoom);

    List<ChatRoomDTO> findMyRooms(@Param("loginUserId") Integer loginUserId);

    void exitRoom(Map<String, Object> param);

    ChatRoomDTO findRoomInfo(@Param("roomId") Integer roomId, @Param("loginUserId") Integer loginUserId);

    void updateLastMessage(@Param("roomId") Integer roomId);

    Integer findExistRoom(@Param("projectId") Integer projectId, @Param("freelancerId") Integer freelancerId);

}