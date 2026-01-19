package com.sanaiclub.domain.queue.model;

import java.util.List;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * QueueDTO - 조건 큐 정보
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * 사용자가 생성한 조건 기반 큐(CUSTOM QUEUE)를 나타내는 DTO입니다.
 * 큐의 조건과 해당 큐에 추천된 프로젝트 목록을 포함합니다.
 */
public class QueueDTO {
    
    private Long queueId;
    private String queueName;           // 큐의 이름
    private String queueStatus;         // ACTIVE / INACTIVE
    private Long minBudget;
    private Long maxBudget;
    private String expectedDuration;
    private String category;            // 분야
    private List<String> techStacks;    // 기술 스택 목록
    private List<ProjectQueueDTO> projects;  // 이 큐의 추천 프로젝트 (최대 5개)
    
    // ─────────────────────────────────────────────────────────────────
    // Constructors
    // ─────────────────────────────────────────────────────────────────
    
    public QueueDTO() {}
    
    public QueueDTO(Long queueId, String queueName, String queueStatus, 
                    Long minBudget, Long maxBudget) {
        this.queueId = queueId;
        this.queueName = queueName;
        this.queueStatus = queueStatus;
        this.minBudget = minBudget;
        this.maxBudget = maxBudget;
    }
    
    // ─────────────────────────────────────────────────────────────────
    // Getters & Setters
    // ─────────────────────────────────────────────────────────────────
    
    public Long getQueueId() {
        return queueId;
    }
    
    public void setQueueId(Long queueId) {
        this.queueId = queueId;
    }
    
    public String getQueueName() {
        return queueName;
    }
    
    public void setQueueName(String queueName) {
        this.queueName = queueName;
    }
    
    public String getQueueStatus() {
        return queueStatus;
    }
    
    public void setQueueStatus(String queueStatus) {
        this.queueStatus = queueStatus;
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
    
    public String getExpectedDuration() {
        return expectedDuration;
    }
    
    public void setExpectedDuration(String expectedDuration) {
        this.expectedDuration = expectedDuration;
    }
    
    public String getCategory() {
        return category;
    }
    
    public void setCategory(String category) {
        this.category = category;
    }
    
    public List<String> getTechStacks() {
        return techStacks;
    }
    
    public void setTechStacks(List<String> techStacks) {
        this.techStacks = techStacks;
    }
    
    public List<ProjectQueueDTO> getProjects() {
        return projects;
    }
    
    public void setProjects(List<ProjectQueueDTO> projects) {
        this.projects = projects;
    }
    
    public boolean isActive() {
        return "ACTIVE".equals(this.queueStatus);
    }
}
