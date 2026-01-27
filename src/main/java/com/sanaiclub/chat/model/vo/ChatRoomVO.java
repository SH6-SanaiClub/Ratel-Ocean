package com.sanaiclub.chat.model.vo;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.Date;

@Getter
@Setter
public class ChatRoomVO {

    private Integer roomId;                // 방 ID
    private Integer projectId;              // 상대방 ID
    private Integer freelancerId;
    private Boolean isActive;           // 방 활성화 여부
    private Date lastMessageAt;       // 마지막 메시지 내용
    private Date createdAt;
    private Boolean freelancer_exited;
    private Boolean client_exited;
}
