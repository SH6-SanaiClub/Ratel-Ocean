package com.sanaiclub.domain.queue.model;

import java.util.List;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * QueuePageData - 큐 페이지 렌더링용 데이터
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * JSP에 전달되는 전체 큐 페이지 데이터를 담는 컨테이너 클래스입니다.
 * 자동 추천 큐, 조건 큐, 사용자 정보를 모두 포함합니다.
 */
public class QueuePageData {
    
    private Long freelancerId;
    private String freelancerName;
    private String profileImageUrl;
    
    // 자동 추천 큐 (SYSTEM QUEUE) - 1개만 존재
    private List<ProjectQueueDTO> systemQueueProjects;  // 최대 5개
    
    // 조건 기반 큐 (CUSTOM QUEUE) - 최대 2개
    private List<QueueDTO> customQueues;
    
    // ─────────────────────────────────────────────────────────────────
    // Constructors
    // ─────────────────────────────────────────────────────────────────
    
    public QueuePageData() {}
    
    public QueuePageData(Long freelancerId, List<ProjectQueueDTO> systemQueue, 
                         List<QueueDTO> customQueues) {
        this.freelancerId = freelancerId;
        this.systemQueueProjects = systemQueue;
        this.customQueues = customQueues;
    }
    
    // ─────────────────────────────────────────────────────────────────
    // Getters & Setters
    // ─────────────────────────────────────────────────────────────────
    
    public Long getFreelancerId() {
        return freelancerId;
    }
    
    public void setFreelancerId(Long freelancerId) {
        this.freelancerId = freelancerId;
    }
    
    public String getFreelancerName() {
        return freelancerName;
    }
    
    public void setFreelancerName(String freelancerName) {
        this.freelancerName = freelancerName;
    }
    
    public String getProfileImageUrl() {
        return profileImageUrl;
    }
    
    public void setProfileImageUrl(String profileImageUrl) {
        this.profileImageUrl = profileImageUrl;
    }
    
    public List<ProjectQueueDTO> getSystemQueueProjects() {
        return systemQueueProjects;
    }
    
    public void setSystemQueueProjects(List<ProjectQueueDTO> systemQueueProjects) {
        this.systemQueueProjects = systemQueueProjects;
    }
    
    public List<QueueDTO> getCustomQueues() {
        return customQueues;
    }
    
    public void setCustomQueues(List<QueueDTO> customQueues) {
        this.customQueues = customQueues;
    }
    
    // ─────────────────────────────────────────────────────────────────
    // Utility Methods
    // ─────────────────────────────────────────────────────────────────
    
    public int getCustomQueueCount() {
        return customQueues != null ? customQueues.size() : 0;
    }
    
    public boolean canAddMoreQueues() {
        return getCustomQueueCount() < 2;
    }
}
