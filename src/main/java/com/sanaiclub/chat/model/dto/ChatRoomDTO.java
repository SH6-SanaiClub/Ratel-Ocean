package com.sanaiclub.chat.model.dto;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import java.util.Date;

@Getter
@Setter
@ToString
public class ChatRoomDTO {
    private Integer room_id;
    private Integer project_id;
    private Integer sender_id;
    private Boolean is_active;
    private String profile_image_url;
    private Date created_at;
    private Date last_message_at;
    private String last_message_content;
    private Long last_message_sender_id;
    private Integer unread_count;
    private String name;
    private boolean has_new_message;
}
