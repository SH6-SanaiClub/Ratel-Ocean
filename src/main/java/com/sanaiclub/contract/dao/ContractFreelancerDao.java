package com.sanaiclub.contract.dao;

import com.sanaiclub.contract.model.vo.ContractFreelancerVO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface ContractFreelancerDao {
    ContractFreelancerVO findById(Integer id);
    List<ContractFreelancerVO> findAll();
    List<ContractFreelancerVO> findByProjectId(Integer projectId);
}
