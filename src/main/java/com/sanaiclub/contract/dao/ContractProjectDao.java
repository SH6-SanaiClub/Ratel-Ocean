package com.sanaiclub.contract.dao;


import java.util.List;

import com.sanaiclub.contract.model.vo.ContractProjectVO;
import org.apache.ibatis.annotations.Mapper;


@Mapper
public interface ContractProjectDao {
    ContractProjectVO findById(Integer id);
    List<ContractProjectVO> findAll();
    List<ContractProjectVO> findByClientId(Integer clientId);
}
