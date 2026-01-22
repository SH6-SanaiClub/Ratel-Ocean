package com.sanaiclub.chat.model.vo;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.Date;

@Getter
@Setter
public class ChatMessageVO {

    private Integer messageId;      // 메시지 ID
    private Integer roomId;         // 방 ID
    private Integer senderId;       // 작성자 ID
    private String content;      // 내용

    private String fileName;     // 첨부 파일 이름
    private String fileUrl;      // 첨부 파일 URL
    private Long fileSize;       // 첨부 파일 크기

    private Date createdAt; // 작성 시간

    private Boolean isDeleted;   // 삭제 여부
    private int isRead;
    private Date deletedAt;
}
