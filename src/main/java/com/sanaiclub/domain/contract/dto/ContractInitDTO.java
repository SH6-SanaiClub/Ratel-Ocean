package com.sanaiclub.domain.contract.dto;

import java.io.Serializable;
import java.time.LocalDate;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * ContractInitDTO
 * ═══════════════════════════════════════════════════════════════════════
 * 
 * [역할]
 * 계약 생성 초기 단계에서 UI에 표시할 정보입니다.
 * 
 * [데이터 구성]
 * - projectDTO: 공고 기본 정보
 * - freelancerDTO: 프리랜서 정보
 * - estimatedBudget: 추정 예산 (선택사항)
 * 
 * [사용 시나리오]
 * 1. ContractController.getInitialContract() 호출
 * 2. contract-init.jsp로 forward
 * 3. JSP에서 project + freelancer 정보 표시
 * 4. 사용자가 PDF 업로드
 */
public class ContractInitDTO implements Serializable {
    private static final long serialVersionUID = 1L;
    
    // 프로젝트 기본 정보
    private Long projectId;
    private String projectTitle;
    private String projectDescription;
    private Long projectBudget;
    private LocalDate projectDeadline;
    private String developmentArea; // e.g., "웹 애플리케이션"
    private String requiredSkills;
    
    // 프리랜서 정보
    private Long freelancerId;
    private String freelancerName;
    private String freelancerEmail;
    private String freelancerPhone;
    private String freelancerProfile;
    private Long freelancerExperienceYears;
    private String freelancerTechStack;
    
    // 추정 정보 (선택)
    private Long estimatedBudget;
    private String estimatedTimeline;
    
    // ════════════════════════════════════════════════════════════════════
    // Constructors
    // ════════════════════════════════════════════════════════════════════
    public ContractInitDTO() {
    }
    
    // ════════════════════════════════════════════════════════════════════
    // Getters & Setters
    // ════════════════════════════════════════════════════════════════════
    public Long getProjectId() { return projectId; }
    public void setProjectId(Long projectId) { this.projectId = projectId; }
    
    public String getProjectTitle() { return projectTitle; }
    public void setProjectTitle(String projectTitle) { this.projectTitle = projectTitle; }
    
    public String getProjectDescription() { return projectDescription; }
    public void setProjectDescription(String projectDescription) { this.projectDescription = projectDescription; }
    
    public Long getProjectBudget() { return projectBudget; }
    public void setProjectBudget(Long projectBudget) { this.projectBudget = projectBudget; }
    
    public LocalDate getProjectDeadline() { return projectDeadline; }
    public void setProjectDeadline(LocalDate projectDeadline) { this.projectDeadline = projectDeadline; }
    
    public String getDevelopmentArea() { return developmentArea; }
    public void setDevelopmentArea(String developmentArea) { this.developmentArea = developmentArea; }
    
    public String getRequiredSkills() { return requiredSkills; }
    public void setRequiredSkills(String requiredSkills) { this.requiredSkills = requiredSkills; }
    
    public Long getFreelancerId() { return freelancerId; }
    public void setFreelancerId(Long freelancerId) { this.freelancerId = freelancerId; }
    
    public String getFreelancerName() { return freelancerName; }
    public void setFreelancerName(String freelancerName) { this.freelancerName = freelancerName; }
    
    public String getFreelancerEmail() { return freelancerEmail; }
    public void setFreelancerEmail(String freelancerEmail) { this.freelancerEmail = freelancerEmail; }
    
    public String getFreelancerPhone() { return freelancerPhone; }
    public void setFreelancerPhone(String freelancerPhone) { this.freelancerPhone = freelancerPhone; }
    
    public String getFreelancerProfile() { return freelancerProfile; }
    public void setFreelancerProfile(String freelancerProfile) { this.freelancerProfile = freelancerProfile; }
    
    public Long getFreelancerExperienceYears() { return freelancerExperienceYears; }
    public void setFreelancerExperienceYears(Long freelancerExperienceYears) { 
        this.freelancerExperienceYears = freelancerExperienceYears; 
    }
    
    public String getFreelancerTechStack() { return freelancerTechStack; }
    public void setFreelancerTechStack(String freelancerTechStack) { 
        this.freelancerTechStack = freelancerTechStack; 
    }
    
    public Long getEstimatedBudget() { return estimatedBudget; }
    public void setEstimatedBudget(Long estimatedBudget) { this.estimatedBudget = estimatedBudget; }
    
    public String getEstimatedTimeline() { return estimatedTimeline; }
    public void setEstimatedTimeline(String estimatedTimeline) { this.estimatedTimeline = estimatedTimeline; }
}
