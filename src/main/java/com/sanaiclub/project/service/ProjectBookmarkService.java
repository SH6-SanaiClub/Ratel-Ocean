package com.sanaiclub.project.service;

import com.sanaiclub.project.dao.ProjectBookmarkMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ProjectBookmarkService {

    private final ProjectBookmarkMapper bookmarkMapper;

    @Transactional
    public boolean toggle(Integer projectId, Integer userId) {
        // 이미 있으면 삭제 → false 반환
        if (bookmarkMapper.isBookmarked(projectId, userId) > 0) {
            bookmarkMapper.deleteBookmark(projectId, userId);
            return false;
        }
        // 없으면 추가 → true 반환
        bookmarkMapper.insertBookmark(projectId, userId);
        return true;
    }
}
