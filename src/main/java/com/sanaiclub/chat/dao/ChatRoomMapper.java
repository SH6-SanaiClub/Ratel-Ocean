package com.sanaiclub.chat.dao;

import com.sanaiclub.chat.model.dto.ChatMessageDTO;
import com.sanaiclub.chat.model.dto.ChatRoomDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface ChatRoomMapper {

    // 내 채팅방 목록 조회
    List<ChatRoomDTO> find_my_rooms(@Param("login_user_id") Integer login_user_id);

    // 단일 채팅방 상세 조회
    List<ChatMessageDTO> find_room_by_id(
            @Param("room_id") Integer room_id,
            @Param("login_user_id") Integer login_user_id
    );


    // 마지막 메시지 업데이트
    void update_last_message(@Param("room_id") Integer room_id,
                             @Param("content") String content);
}
