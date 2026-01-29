package com.sanaiclub.chat.dao;

import com.sanaiclub.chat.model.dto.ChatMessageDTO;
import com.sanaiclub.chat.model.dto.ChatRoomDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface ChatRoomMapper {

    // 내 채팅방 목록 조회 (find_my_rooms -> findMyRooms)
    List<ChatRoomDTO> findMyRooms(@Param("loginUserId") Integer loginUserId);
    // 채팅방 나가기
    void exitRoom(Map<String, Object> param);
    // 채팅방 정보 조회
    ChatRoomDTO findRoomInfo(@Param("roomId") Integer roomId, @Param("loginUserId") Integer loginUserId);
    // 마지막 메시지 업데이트 (update_last_message -> updateLastMessage)
    void updateLastMessage(@Param("roomId") Integer roomId);

    //프로젝트 ID와 사용자 ID를 통해 기존 채팅방 ID 조g회
    Integer findRoomIdByProjectAndUser(@Param("projectId") Integer projectId, @Param("userId") Integer userId);
}