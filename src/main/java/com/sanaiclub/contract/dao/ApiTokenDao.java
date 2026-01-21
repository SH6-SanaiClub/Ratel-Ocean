package com.sanaiclub.contract.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ApiTokenDao {

    String findActiveTokenByServiceName(@Param("serviceName") String serviceName);
}
