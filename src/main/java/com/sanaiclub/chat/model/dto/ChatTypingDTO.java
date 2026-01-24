package com.sanaiclub.chat.model.dto;

import lombok.Data;

@Data
public class ChatTypingDTO {
    private Integer roomId;
    private boolean typing;
}
