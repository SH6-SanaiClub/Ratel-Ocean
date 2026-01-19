package com.sanaiclub.domain.freelancer.dto;

/**
 * SkillInput DTO - 기술 스택 선택 입력값 매핑
 * 클라이언트에서 전송받는 skills_json 데이터 구조
 */
public class SkillInput {
    private Long stackId;           // stacks 테이블의 ID
    private String stackName;       // 기술명 (선택사항 - 표시용)
    private Integer stackLevel;     // 숙련도 (1-5)
    private Integer stackYear;      // 경력년수

    // 생성자
    public SkillInput() {
    }

    public SkillInput(Long stackId, Integer stackLevel, Integer stackYear) {
        this.stackId = stackId;
        this.stackLevel = stackLevel;
        this.stackYear = stackYear;
    }

    public SkillInput(Long stackId, String stackName, Integer stackLevel, Integer stackYear) {
        this.stackId = stackId;
        this.stackName = stackName;
        this.stackLevel = stackLevel;
        this.stackYear = stackYear;
    }

    // Getters and Setters
    public Long getStackId() {
        return stackId;
    }

    public void setStackId(Long stackId) {
        this.stackId = stackId;
    }

    public String getStackName() {
        return stackName;
    }

    public void setStackName(String stackName) {
        this.stackName = stackName;
    }

    public Integer getStackLevel() {
        return stackLevel;
    }

    public void setStackLevel(Integer stackLevel) {
        this.stackLevel = stackLevel;
    }

    public Integer getStackYear() {
        return stackYear;
    }

    public void setStackYear(Integer stackYear) {
        this.stackYear = stackYear;
    }

    @Override
    public String toString() {
        return "SkillInput{" +
                "stackId=" + stackId +
                ", stackName='" + stackName + '\'' +
                ", stackLevel=" + stackLevel +
                ", stackYear=" + stackYear +
                '}';
    }
}
