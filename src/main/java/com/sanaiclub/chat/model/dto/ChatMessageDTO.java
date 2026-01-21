package com.sanaiclub.chat.model.dto;

import lombok.*;

import java.time.LocalDateTime;
import java.util.Date;


@AllArgsConstructor
@Data
@NoArgsConstructor
public class ChatMessageDTO {
    private Integer message_id;
    private Integer sender_id;
    private Integer room_id;
    private Integer project_id;
    private String title;
    private Integer user_id;
    private String name;
    private String profile_image_url;
    private String content;
    private Date created_at;
    private Date deleted_at;
    private int is_read;
    private int is_deleted;
    private String file_name;
    private String file_url;
    private Long file_size;
}
