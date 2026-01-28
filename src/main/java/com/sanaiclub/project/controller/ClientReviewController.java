package com.sanaiclub.project.controller;

import com.sanaiclub.project.model.dto.ReviewWriteDTO;
import com.sanaiclub.project.service.ClientReviewService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/client/api/review")
@RequiredArgsConstructor
public class ClientReviewController {

    private final ClientReviewService clientReviewService;

    @GetMapping("/info")
    public ReviewWriteDTO getReviewInfo(@RequestParam Integer projectId) {
        return clientReviewService.getReviewTargetInfo(projectId);
    }

    @PostMapping("/submit")
    public String submitReview(@RequestBody ReviewWriteDTO reviewDTO) {
        clientReviewService.submitReview(reviewDTO);
        return "success";
    }
}