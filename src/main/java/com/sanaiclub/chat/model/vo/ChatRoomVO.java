package com.sanaiclub.chat.model.vo;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.Date;

@Getter
@Setter
public class ChatRoomVO {
    private Integer roomId;
    private Integer projectId;
    private Integer freelancerId;
    private Date lastMessageAt;
    private Date createdAt;
    private Boolean freelancer_exited;
    private Boolean client_exited;
}
