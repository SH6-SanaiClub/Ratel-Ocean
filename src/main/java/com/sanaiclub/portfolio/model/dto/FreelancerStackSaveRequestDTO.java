package com.sanaiclub.portfolio.model.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class FreelancerStackSaveRequestDTO {
    private String category;     // SKILL / POSITION

    private List<MyStackItemDTO> stacks;

}
