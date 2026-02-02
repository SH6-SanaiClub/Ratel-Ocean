package com.sanaiclub.chat.service;

import com.sanaiclub.chat.dao.ChatMessageMapper;
import com.sanaiclub.chat.dao.ChatRoomMapper;
import com.sanaiclub.chat.model.dto.ChatMessageDTO;
import com.sanaiclub.chat.model.dto.ChatRoomDTO;
import com.sanaiclub.common.util.AuthContext;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ChatService {
    private final ChatRoomMapper chatRoomMapper;
    private final ChatMessageMapper chatMessageMapper;

    @Transactional
    public List<ChatRoomDTO> findMyRooms(Integer loginUserId) {
        List<ChatRoomDTO> rooms = chatRoomMapper.findMyRooms(loginUserId);
        return rooms;
    }

    @Autowired
    private SimpMessagingTemplate messagingTemplate;
    @Transactional
    public ChatMessageDTO processAndSendMessage(Integer roomId, Integer senderId, String content, MultipartFile file, String uploadPath) throws IOException {
        String fileName = null;
        String fileUrl = null;
        Long fileSize = null;

        if (file != null && !file.isEmpty()) {
            String originalFileName = file.getOriginalFilename();
            fileSize = file.getSize();
            String savedFileName = UUID.randomUUID().toString() + "_" + originalFileName;
            File dir = new File(uploadPath);
            if (!dir.exists()) dir.mkdirs();
            File savedFile = new File(uploadPath, savedFileName);
            file.transferTo(savedFile);
            fileName = originalFileName;
            fileUrl = "/upload/chat/" + savedFileName;
        }
        markRoomAsRead(roomId, AuthContext.getCurrentUserId());
        ChatMessageDTO message =sendAndReturnMessage(
                roomId,
                senderId,
                content,
                fileName,
                fileUrl,
                fileSize
        );
        messagingTemplate.convertAndSend("/sub/chat/room/" + roomId, message);
        messagingTemplate.convertAndSend("/sub/chat/list/" + senderId, message);
        ChatRoomDTO roomInfo = findRoomInfo(roomId, senderId);
        if (roomInfo != null && roomInfo.getOpponentId() != null) {
            messagingTemplate.convertAndSend("/sub/chat/list/" + roomInfo.getOpponentId(), message);
        }
        return message;
    }

    @Transactional
    public ChatMessageDTO sendAndReturnMessage(Integer roomId, Integer senderId, String content, String fileName, String fileUrl, Long fileSize) {
        chatMessageMapper.insertMessage(roomId, senderId, content, fileName, fileUrl, fileSize);
        List<ChatMessageDTO> messages = chatMessageMapper.findMessages(roomId);
        ChatMessageDTO newMessage = messages.get(messages.size() - 1);
        chatRoomMapper.updateLastMessage(roomId);
        return newMessage;
    }

    @Transactional
    public Integer createOrGetRoom(Integer projectId, Integer freelancerId) {
        Integer existingRoomId = chatRoomMapper.findExistRoom(projectId, freelancerId);

        if (existingRoomId != null) {
            return existingRoomId;
        }
        ChatRoomDTO newRoom = new ChatRoomDTO();
        newRoom.setProjectId(projectId);
        newRoom.setFreelancerId(freelancerId);
        chatRoomMapper.insertChatRoom(newRoom);
        return newRoom.getRoomId();
    }

    public ChatMessageDTO findFileByMessageId(Integer messageId){
        return chatMessageMapper.findFileByMessageId(messageId);
    }

    public ChatRoomDTO findRoomInfo(Integer roomId, Integer loginUserId) {
        return chatRoomMapper.findRoomInfo(roomId, loginUserId);
    }

    public List<ChatMessageDTO> findMessages(Integer roomId) {
        return chatMessageMapper.findMessages(roomId);
    }

    @Transactional
    public void markRoomAsRead(Integer roomId, Integer loginUserId) {
        chatMessageMapper.markRoomMessagesAsRead(roomId, loginUserId);
    }

    public void deleteMessage(Integer messageId) {
        chatMessageMapper.deleteMessage(messageId);
    }

    public void exitRoom(Integer roomId, Integer userId) {
        Map<String, Object> param = new HashMap<>();
        param.put("roomId", roomId);
        param.put("userId", userId);
        chatRoomMapper.exitRoom(param);
    }
}
