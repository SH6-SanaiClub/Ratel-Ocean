package com.sanaiclub.user.service.impl;

import com.sanaiclub.user.model.dto.BizNoVerificationRequestDTO;
import com.sanaiclub.user.model.dto.BizNoVerificationResponseDTO;
import com.sanaiclub.user.service.BizNoVerificationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * 사업자번호 진위확인 서비스 구현
 * ═══════════════════════════════════════════════════════════════════════
 *
 * [역할]
 * - 국세청 공공데이터포털 API 호출
 * - HTTP 통신 및 결과 파싱
 *
 */
@Service
public class BizNoVerificationServiceImpl implements BizNoVerificationService {

    private static final Logger logger = LoggerFactory.getLogger(BizNoVerificationServiceImpl.class);

    @Value("${bizno.api.url}")
    private String apiUrl;

    @Value("${bizno.api.key}")
    private String apiKey;

    @Value("${bizno.api.timeout:5000}")
    private int timeout;

    private final RestTemplate restTemplate;

    public BizNoVerificationServiceImpl() {
        this.restTemplate = new RestTemplate();
    }

    /**
     * 사업자번호 진위확인
     */
    @Override
    public BizNoVerificationResponseDTO.BusinessData verifyBusinessNumber(String businessNumber) {
        logger.info("사업자번호 진위확인 시작: {}", maskBusinessNumber(businessNumber));

        try {
            // 1. 요청 DTO 생성
            BizNoVerificationRequestDTO request = BizNoVerificationRequestDTO.of(businessNumber);

            // 2. HTTP 헤더 설정
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("Authorization", "Infuser " + apiKey);

            // 3. HTTP 요청 엔티티 생성
            HttpEntity<BizNoVerificationRequestDTO> entity = new HttpEntity<>(request, headers);

            // 4. API 호출
            logger.debug("API 호출: URL={}", apiUrl);
            ResponseEntity<BizNoVerificationResponseDTO> response = restTemplate.exchange(
                    apiUrl,
                    HttpMethod.POST,
                    entity,
                    BizNoVerificationResponseDTO.class
            );

            // 5. 응답 검증
            BizNoVerificationResponseDTO responseBody = response.getBody();

            if (responseBody == null || !responseBody.isSuccess()) {
                logger.error("API 호출 실패: response={}", responseBody);
                throw new IllegalArgumentException("사업자번호 인증 API 호출에 실패했습니다.");
            }

            // 6. 결과 추출
            BizNoVerificationResponseDTO.BusinessData data = responseBody.getFirstData();

            if (data == null) {
                logger.error("API 응답 데이터 없음");
                throw new IllegalArgumentException("사업자번호 인증 결과를 찾을 수 없습니다.");
            }

            // 7. 유효성 확인
            if (!data.isValid()) {
                logger.warn("사업자번호 인증 실패: businessNumber={}, valid={}, msg={}",
                        maskBusinessNumber(businessNumber), data.getValid(), data.getValid_msg());
                throw new IllegalArgumentException("유효하지 않은 사업자번호입니다.");
            }

            // 8. 사업자 상태 확인
            if (!data.isActive()) {
                logger.warn("사업자 비활성 상태: businessNumber={}, status={}",
                        maskBusinessNumber(businessNumber), data.getB_stt());
                throw new IllegalArgumentException(
                        String.format("해당 사업자는 '%s' 상태입니다.", data.getB_stt())
                );
            }

            logger.info("사업자번호 인증 성공: businessNumber={}, status={}",
                    maskBusinessNumber(businessNumber), data.getB_stt());

            return data;

        } catch (IllegalArgumentException e) {
            // 비즈니스 예외는 그대로 전파
            throw e;

        } catch (Exception e) {
            // 네트워크 오류, JSON 파싱 오류 등
            logger.error("사업자번호 인증 중 오류 발생: businessNumber={}",
                    maskBusinessNumber(businessNumber), e);
            throw new IllegalArgumentException("사업자번호 인증 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
        }
    }

    /**
     * 사업자번호가 유효한지 확인
     */
    @Override
    public boolean isValidBusinessNumber(String businessNumber) {
        try {
            verifyBusinessNumber(businessNumber);
            return true;
        } catch (Exception e) {
            logger.debug("사업자번호 유효성 검사 실패: {}", e.getMessage());
            return false;
        }
    }

    /**
     * 사업자번호 마스킹 (로그용)
     * - 예: 123-45-67890 → 123-**-***90
     */
    private String maskBusinessNumber(String businessNumber) {
        if (businessNumber == null || businessNumber.length() < 10) {
            return "***";
        }

        String clean = businessNumber.replaceAll("-", "");

        if (clean.length() == 10) {
            return clean.substring(0, 3) + "-**-***" + clean.substring(8);
        }

        return "***";
    }
}