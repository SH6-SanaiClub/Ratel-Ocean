package com.sanaiclub.chat.model.dto;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import java.util.Date;

@Getter
@Setter
@ToString
public class ChatRoomDTO {
    private Integer roomId;
    private Integer freelancerId;
    private Integer projectId;
    private String title;
    private Integer senderId;
    private Integer opponentId;
    private String profileImageUrl;
    private Date createdAt;
    private Date lastMessageAt;
    private String lastMessageContent;
    private Integer lastMessageSenderId;
    private Boolean freelancerExited;
    private Boolean clientExited;
    private Integer unreadCount;
    private String name;
    private boolean hasNewMessage;
}


