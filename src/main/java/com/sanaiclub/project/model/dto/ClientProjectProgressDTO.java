package com.sanaiclub.project.model.dto;

import com.sanaiclub.wallet.model.dto.ClientMilestoneDTO;
import lombok.Data;
import java.util.Date;
import java.util.List;

@Data
public class ClientProjectProgressDTO {
    private Integer contractId;

    private Integer freelancerId;
    private String freelancerName;
    private Date startDate;
    private Date endDate;
    private Integer budget;
    private String communicateMethod;
    private String paymentMethod;
    private Integer maxRevisionCount;
    private String originContractUrl;

    private List<ClientMilestoneDTO> milestones;
}