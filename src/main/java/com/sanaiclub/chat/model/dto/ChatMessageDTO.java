package com.sanaiclub.chat.model.dto;

import lombok.*;

import java.time.LocalDateTime;
import java.util.Date;


@AllArgsConstructor
@Data
@NoArgsConstructor
public class ChatMessageDTO {
    private Integer messageId;
    private Integer senderId;
    private Integer roomId;
    private Integer projectId;
    private String title;
    private Integer userId;
    private String name;
    private String profileImageUrl;
    private String content;
    private Date createdAt;
    private Date deletedAt;
    private int isRead;
    private int isDeleted;
    private String fileName;
    private String fileUrl;
    private Long fileSize;
    private Boolean freelancerExited;
    private Boolean clientExited;
}
