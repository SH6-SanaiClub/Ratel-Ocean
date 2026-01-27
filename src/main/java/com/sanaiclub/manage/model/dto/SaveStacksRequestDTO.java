package com.sanaiclub.manage.model.dto;

import lombok.Data;
import java.util.List;

@Data
public class SaveStacksRequestDTO {
    private Integer contractId;
    private List<Integer> stackIds;
}
