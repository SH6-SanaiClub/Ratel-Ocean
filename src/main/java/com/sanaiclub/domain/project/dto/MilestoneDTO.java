package com.sanaiclub.domain.project.dto;

public class MilestoneDTO {
    private String name;
    private Long amount;
    private String description;

    public MilestoneDTO() {
    }

    public MilestoneDTO(String name, Long amount, String description) {
        this.name = name;
        this.amount = amount;
        this.description = description;
    }

    // Getters and Setters
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Long getAmount() {
        return amount;
    }

    public void setAmount(Long amount) {
        this.amount = amount;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
