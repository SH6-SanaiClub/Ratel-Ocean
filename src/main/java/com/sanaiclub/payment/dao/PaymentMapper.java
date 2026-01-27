package com.sanaiclub.payment.dao;

import com.sanaiclub.payment.model.vo.PaymentVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface PaymentMapper {

    /**
     * 결제 정보 저장
     */
    int insertPayment(PaymentVO payment);

    /**
     * 결제 ID로 조회
     */
    PaymentVO selectPaymentById(@Param("paymentId") Integer paymentId);

    /**
     * 포트원 결제 고유번호로 조회
     */
    PaymentVO selectPaymentByImpUid(@Param("impUid") String impUid);

    /**
     * 가맹점 주문번호로 조회
     */
    PaymentVO selectPaymentByMerchantUid(@Param("merchantUid") String merchantUid);

    /**
     * 계약 ID로 결제 목록 조회
     */
    List<PaymentVO> selectPaymentsByContractId(@Param("contractId") Integer contractId);

    /**
     * 결제 상태 업데이트
     */
    int updatePaymentStatus(@Param("paymentId") Integer paymentId,
                            @Param("paymentStatus") String paymentStatus);

    /**
     * 결제 정보 전체 업데이트
     */
    int updatePayment(PaymentVO payment);

    /**
     * 결제 삭제 (물리 삭제 - 주의)
     */
    int deletePayment(@Param("paymentId") Integer paymentId);
}