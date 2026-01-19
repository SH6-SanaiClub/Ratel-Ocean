package com.sanaiclub.project.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ProjectBookmarkMapper {
    int isBookmarked(@Param("projectId") long projectId, @Param("userId") long userId);
    int insertBookmark(@Param("projectId") long projectId, @Param("userId") long userId);
    int deleteBookmark(@Param("projectId") long projectId, @Param("userId") long userId);
}