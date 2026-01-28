package com.sanaiclub.contract.model.dto;

import com.sanaiclub.project.model.vo.ProjectsVO;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;
import java.util.Map;

/** 계약서 확인 페이지용 데이터 컨테이너. */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ContractCheckPageDTO {
    private String contractInputType;
    private String originContractUrl;
    private ContractAutoFillDTO autoFillDTO;
    private Map<String, Object> formDto;
    private Map<String, Object> client;
    private Map<String, Object> freelancer;
    private ProjectsVO project;
    private Map<String, Object> contract;
    private List<ContractMilestoneRequestDTO> milestones;
    private String errorMessage;
}
