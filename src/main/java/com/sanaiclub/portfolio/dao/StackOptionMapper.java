package com.sanaiclub.portfolio.dao;

import com.sanaiclub.project.model.dto.StackDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface StackOptionMapper {
    List<StackDTO> findByCategory(@Param("category") String category); // "SKILL" or "POSITION"
}
