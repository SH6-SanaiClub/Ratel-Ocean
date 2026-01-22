package com.sanaiclub.chat.model.dto;

import lombok.*;

import java.time.LocalDateTime;
import java.util.Date;


@AllArgsConstructor
@Data
@NoArgsConstructor
public class ChatMessageDTO {
    private Integer messageId; // message_id -> messageId
    private Integer senderId; // sender_id -> senderId
    private Integer roomId; // room_id -> roomId
    private Integer projectId; // project_id -> projectId
    private String title;
    private Integer userId; // user_id -> userId
    private String name;
    private String profileImageUrl; // profile_image_url -> profileImageUrl
    private String content;
    private Date createdAt; // created_at -> createdAt
    private Date deletedAt; // deleted_at -> deletedAt
    private int isRead; // is_read -> isRead
    private int isDeleted; // is_deleted -> isDeleted
    private String fileName; // file_name -> fileName
    private String fileUrl; // file_url -> fileUrl
    private Long fileSize; // file_size -> fileSize
}
