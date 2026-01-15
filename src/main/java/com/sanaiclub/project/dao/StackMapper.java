package com.sanaiclub.project.dao;

import com.sanaiclub.project.model.dto.StackDto;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface StackMapper {
    // 모든 스택 데이터를 가져옴
    List<StackDto> findAll();
}