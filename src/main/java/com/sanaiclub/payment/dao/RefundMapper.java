package com.sanaiclub.payment.dao;

import com.sanaiclub.payment.model.vo.RefundVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface RefundMapper {

    /**
     * 환불 정보 저장
     */
    int insertRefund(RefundVO refund);

    /**
     * 환불 ID로 조회
     */
    RefundVO selectRefundById(@Param("refundId") Integer refundId);

    /**
     * 계약 ID로 환불 목록 조회
     */
    List<RefundVO> selectRefundsByContractId(@Param("contractId") Integer contractId);

    /**
     * 결제 ID로 환불 목록 조회
     */
    List<RefundVO> selectRefundsByPaymentId(@Param("paymentId") Integer paymentId);

    /**
     * 환불 상태 업데이트
     */
    int updateRefundStatus(@Param("refundId") Integer refundId,
                           @Param("refundStatus") String refundStatus);

    /**
     * 환불 정보 전체 업데이트
     */
    int updateRefund(RefundVO refund);
}