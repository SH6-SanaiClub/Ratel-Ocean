package com.sanaiclub.project.service;

import com.sanaiclub.project.dao.ClientReviewMapper;
import com.sanaiclub.project.model.dto.ReviewWriteDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ClientReviewService {

    private final ClientReviewMapper clientReviewMapper;

    public ReviewWriteDTO getReviewTargetInfo(Integer projectId) {
        return clientReviewMapper.selectReviewTargetInfo(projectId);
    }

    @Transactional
    public void submitReview(ReviewWriteDTO reviewDTO) {
        clientReviewMapper.updateContractReview(reviewDTO);
    }
}