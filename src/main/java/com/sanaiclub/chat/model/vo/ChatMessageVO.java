package com.sanaiclub.chat.model.vo;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.Date;

@Getter
@Setter
public class ChatMessageVO {
    private Integer messageId;
    private Integer roomId;
    private Integer senderId;
    private String content;
    private String fileName;
    private String fileUrl;
    private Long fileSize;
    private Date createdAt;
    private Boolean isDeleted;
    private int isRead;
    private Date deletedAt;
}
