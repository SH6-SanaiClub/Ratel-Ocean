package com.sanaiclub.project.model.dto;

import com.sanaiclub.project.model.vo.ProjectsVO;
import lombok.ToString;

import java.util.List;

@ToString
public class ProjectDetailDTO extends ProjectsVO {

    private Boolean budgetNegotiable;   // 예산 협의 가능 여부
    private Boolean durationNegotiable; // 기간 협의 가능 여부

    private String planUrl;             // 기획서 파일 경로

    // 기술 스택
    private List<RequiredStackDTO> stacks;

    // 현재 로그인한 사용자 기준 상태값
    private boolean isApplied;
    private boolean isWishlisted;

    //  Getter / Setter

    public Boolean getBudgetNegotiable() {
        return budgetNegotiable;
    }

    public void setBudgetNegotiable(Boolean budgetNegotiable) {
        this.budgetNegotiable = budgetNegotiable;
    }

    public Boolean getDurationNegotiable() {
        return durationNegotiable;
    }

    public void setDurationNegotiable(Boolean durationNegotiable) {
        this.durationNegotiable = durationNegotiable;
    }

    public String getPlanUrl() {
        return planUrl;
    }

    public void setPlanUrl(String planUrl) {
        this.planUrl = planUrl;
    }

    public List<RequiredStackDTO> getStacks() {
        return stacks;
    }

    public void setStacks(List<RequiredStackDTO> stacks) {
        this.stacks = stacks;
    }

    public boolean isApplied() {
        return isApplied;
    }

    public void setApplied(boolean applied) {
        isApplied = applied;
    }

    public boolean isWishlisted() {
        return isWishlisted;
    }

    public void setWishlisted(boolean wishlisted) {
        isWishlisted = wishlisted;
    }
}