package com.sanaiclub.contract.dao;

import com.sanaiclub.contract.model.vo.ContractClientVO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ContractClientDao {
    ContractClientVO findByUserId(Integer userId);
    ContractClientVO findById(Integer clientId);
}
