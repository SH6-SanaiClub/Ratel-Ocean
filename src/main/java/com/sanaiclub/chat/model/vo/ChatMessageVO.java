package com.sanaiclub.chat.model.vo;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.Date;

@Getter
@Setter
public class ChatMessageVO {

    private Integer message_id;      // 메시지 ID
    private Integer room_id;         // 방 ID
    private Integer sender_id;       // 작성자 ID
    private String content;      // 내용

    private String file_name;     // 첨부 파일 이름
    private String file_url;      // 첨부 파일 URL
    private Long file_size;       // 첨부 파일 크기

    private Date created_at; // 작성 시간

    private Boolean is_deleted;   // 삭제 여부
    private int is_read;
    private Date deleted_at;
}
