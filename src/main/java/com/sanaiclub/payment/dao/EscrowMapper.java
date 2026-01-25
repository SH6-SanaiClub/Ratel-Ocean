package com.sanaiclub.payment.dao;

import com.sanaiclub.payment.model.vo.EscrowVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface EscrowMapper {

    /**
     * 에스크로 생성
     */
    int insertEscrow(EscrowVO escrow);

    /**
     * 에스크로 ID로 조회
     */
    EscrowVO selectEscrowById(@Param("escrowId") Integer escrowId);

    /**
     * 결제 ID로 조회
     */
    EscrowVO selectEscrowByPaymentId(@Param("paymentId") Integer paymentId);

    /**
     * 계약 ID로 조회
     */
    EscrowVO selectEscrowByContractId(@Param("contractId") Integer contractId);

    /**
     * 마일스톤 지급 처리 (held_amount 차감, released_amount 증가)
     */
    int updateEscrowRelease(@Param("escrowId") Integer escrowId,
                            @Param("releaseAmount") Long releaseAmount);

    /**
     * 환불 처리 (held_amount 차감, refunded_amount 증가)
     */
    int updateEscrowRefund(@Param("escrowId") Integer escrowId,
                           @Param("refundAmount") Long refundAmount);

    /**
     * 에스크로 상태 업데이트
     */
    int updateEscrowStatus(@Param("escrowId") Integer escrowId,
                           @Param("escrowStatus") String escrowStatus);

    /**
     * 에스크로 전체 정보 업데이트
     */
    int updateEscrow(EscrowVO escrow);
}