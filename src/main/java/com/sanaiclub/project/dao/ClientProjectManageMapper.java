package com.sanaiclub.project.dao;

import com.sanaiclub.project.model.dto.ClientProjectManageDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ClientProjectManageMapper {
    // 내 프로젝트 목록 조회
    List<ClientProjectManageDTO> selectMyProjects(@Param("clientId") Integer clientId,
                                            @Param("status") String status);
}