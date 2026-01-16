package com.sanaiclub.project.model.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class DashboardPageDTO {
    private List<ProjectDashboardCardDTO> projectList;

    private int page;        // 현재 페이지(1부터)
    private int size;        // 페이지당 개수
    private int totalCount;  // 전체 개수
    private int totalPages;  // 전체 페이지 수

    private int startPage;   // 페이지 블록 시작
    private int endPage;     // 페이지 블록 끝
    private boolean hasPrevBlock;
    private boolean hasNextBlock;
    private int prevBlockPage;
    private int nextBlockPage;
}