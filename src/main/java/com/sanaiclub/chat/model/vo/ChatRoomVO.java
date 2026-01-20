package com.sanaiclub.chat.model.vo;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.Date;

@Getter
@Setter
public class ChatRoomVO {

    private Integer room_id;                // 방 ID
    private Integer project_id;              // 상대방 ID
    private Integer freelancer_id;
    private Boolean is_active;           // 방 활성화 여부
    private Date last_message_at;       // 마지막 메시지 내용
    private Date created_at;         // 방 생성 시간
}
