package com.sanaiclub.portfolio.service;

import com.sanaiclub.portfolio.model.dto.FreelancerProfileViewDTO;

public interface FreelancerProfileViewService {
    FreelancerProfileViewDTO getProfile(Integer profileUserId, Integer viewerUserId);
}
