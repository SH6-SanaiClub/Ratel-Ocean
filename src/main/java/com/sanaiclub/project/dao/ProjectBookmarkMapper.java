package com.sanaiclub.project.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ProjectBookmarkMapper {
    int isBookmarked(@Param("projectId") Integer projectId, @Param("userId") Integer userId);
    int insertBookmark(@Param("projectId") Integer projectId, @Param("userId") Integer userId);
    int deleteBookmark(@Param("projectId") Integer projectId, @Param("userId") Integer userId);
}