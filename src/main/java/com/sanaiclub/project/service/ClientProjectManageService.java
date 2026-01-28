package com.sanaiclub.project.service;

import com.sanaiclub.project.dao.ClientProjectManageMapper;
import com.sanaiclub.project.model.dto.ClientProjectManageDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ClientProjectManageService {

    private final ClientProjectManageMapper clientProjectManageMapper;

    public List<ClientProjectManageDTO> getMyProjects(Integer clientId, String status) {
        return clientProjectManageMapper.selectMyProjects(clientId, status);
    }
}