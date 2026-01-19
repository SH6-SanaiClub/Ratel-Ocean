package com.sanaiclub.domain.project.dto;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class ContractReviewDTO {
    private Long contractId;
    private Long projectId;
    private Long clientId;
    private Long freelancerId;
    private LocalDate startDate;
    private LocalDate deadlineDate;
    private String estDuration;
    private Long budget;
    private Boolean budgetNegotiable;
    private List<String> developmentAreas;
    private List<String> technicalStacks;
    private List<String> communicationMethods;
    private String otherMethod;
    private String expectedDeliverables;
    private String mainFeatures;
    private List<MilestoneDTO> milestones;

    public ContractReviewDTO() {
        this.developmentAreas = new ArrayList<>();
        this.technicalStacks = new ArrayList<>();
        this.communicationMethods = new ArrayList<>();
        this.milestones = new ArrayList<>();
        this.budgetNegotiable = false;
    }

    // Getters and Setters
    public Long getContractId() {
        return contractId;
    }

    public void setContractId(Long contractId) {
        this.contractId = contractId;
    }

    public Long getProjectId() {
        return projectId;
    }

    public void setProjectId(Long projectId) {
        this.projectId = projectId;
    }

    public Long getClientId() {
        return clientId;
    }

    public void setClientId(Long clientId) {
        this.clientId = clientId;
    }

    public Long getFreelancerId() {
        return freelancerId;
    }

    public void setFreelancerId(Long freelancerId) {
        this.freelancerId = freelancerId;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getDeadlineDate() {
        return deadlineDate;
    }

    public void setDeadlineDate(LocalDate deadlineDate) {
        this.deadlineDate = deadlineDate;
    }

    public String getEstDuration() {
        return estDuration;
    }

    public void setEstDuration(String estDuration) {
        this.estDuration = estDuration;
    }

    public Long getBudget() {
        return budget;
    }

    public void setBudget(Long budget) {
        this.budget = budget;
    }

    public Boolean getBudgetNegotiable() {
        return budgetNegotiable;
    }

    public void setBudgetNegotiable(Boolean budgetNegotiable) {
        this.budgetNegotiable = budgetNegotiable;
    }

    public List<String> getDevelopmentAreas() {
        return developmentAreas;
    }

    public void setDevelopmentAreas(List<String> developmentAreas) {
        this.developmentAreas = developmentAreas;
    }

    public List<String> getTechnicalStacks() {
        return technicalStacks;
    }

    public void setTechnicalStacks(List<String> technicalStacks) {
        this.technicalStacks = technicalStacks;
    }

    public List<String> getCommunicationMethods() {
        return communicationMethods;
    }

    public void setCommunicationMethods(List<String> communicationMethods) {
        this.communicationMethods = communicationMethods;
    }

    public String getOtherMethod() {
        return otherMethod;
    }

    public void setOtherMethod(String otherMethod) {
        this.otherMethod = otherMethod;
    }

    public String getExpectedDeliverables() {
        return expectedDeliverables;
    }

    public void setExpectedDeliverables(String expectedDeliverables) {
        this.expectedDeliverables = expectedDeliverables;
    }

    public String getMainFeatures() {
        return mainFeatures;
    }

    public void setMainFeatures(String mainFeatures) {
        this.mainFeatures = mainFeatures;
    }

    public List<MilestoneDTO> getMilestones() {
        return milestones;
    }

    public void setMilestones(List<MilestoneDTO> milestones) {
        this.milestones = milestones;
    }
}
