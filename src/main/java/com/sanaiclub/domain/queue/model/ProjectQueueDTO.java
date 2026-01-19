package com.sanaiclub.domain.queue.model;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * ProjectQueueDTO - 큐에 포함된 프로젝트 정보
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * 자동 추천 큐, 조건 큐에 속한 프로젝트 정보를 나타내는 DTO입니다.
 * 프로젝트의 기본 정보와 매칭 점수를 포함합니다.
 */
public class ProjectQueueDTO {
    
    private Long projectId;
    private String projectTitle;
    private String projectDescription;
    private Long minBudget;
    private Long maxBudget;
    private String category;
    private String expectedDuration;
    private int matchScore;  // 매칭 점수 (0-100)
    private String status;
    
    // ─────────────────────────────────────────────────────────────────
    // Constructors
    // ─────────────────────────────────────────────────────────────────
    
    public ProjectQueueDTO() {}
    
    public ProjectQueueDTO(Long projectId, String projectTitle, Long minBudget, 
                           Long maxBudget, String category, int matchScore) {
        this.projectId = projectId;
        this.projectTitle = projectTitle;
        this.minBudget = minBudget;
        this.maxBudget = maxBudget;
        this.category = category;
        this.matchScore = matchScore;
    }
    
    // ─────────────────────────────────────────────────────────────────
    // Getters & Setters
    // ─────────────────────────────────────────────────────────────────
    
    public Long getProjectId() {
        return projectId;
    }
    
    public void setProjectId(Long projectId) {
        this.projectId = projectId;
    }
    
    public String getProjectTitle() {
        return projectTitle;
    }
    
    public void setProjectTitle(String projectTitle) {
        this.projectTitle = projectTitle;
    }
    
    public String getProjectDescription() {
        return projectDescription;
    }
    
    public void setProjectDescription(String projectDescription) {
        this.projectDescription = projectDescription;
    }
    
    public Long getMinBudget() {
        return minBudget;
    }
    
    public void setMinBudget(Long minBudget) {
        this.minBudget = minBudget;
    }
    
    public Long getMaxBudget() {
        return maxBudget;
    }
    
    public void setMaxBudget(Long maxBudget) {
        this.maxBudget = maxBudget;
    }
    
    public String getCategory() {
        return category;
    }
    
    public void setCategory(String category) {
        this.category = category;
    }
    
    public String getExpectedDuration() {
        return expectedDuration;
    }
    
    public void setExpectedDuration(String expectedDuration) {
        this.expectedDuration = expectedDuration;
    }
    
    public int getMatchScore() {
        return matchScore;
    }
    
    public void setMatchScore(int matchScore) {
        this.matchScore = matchScore;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
}
