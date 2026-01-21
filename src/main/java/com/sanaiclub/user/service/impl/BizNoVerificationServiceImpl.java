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
 * 사업자번호 진위확인 서비스 구현
 */
@Service
public class BizNoVerificationServiceImpl implements BizNoVerificationService {

    private static final Logger logger = LoggerFactory.getLogger(BizNoVerificationServiceImpl.class);

    @Value("${bizno.api.url}")
    private String apiUrl;

    @Value("${bizno.api.key}")
    private String apiKey;

    private final RestTemplate restTemplate;

    public BizNoVerificationServiceImpl() {
        this.restTemplate = new RestTemplate();
    }

    @Override
    public BizNoVerificationResponseDTO.BusinessData verifyBusinessNumber(
            String businessNumber,
            String ceoName,
            String openingDate
    ) {
        logger.info("사업자번호 진위확인 시작: businessNumber={}, ceoName={}, openingDate={}",
                maskBusinessNumber(businessNumber), maskName(ceoName), openingDate);

        try {
            // 1. 요청 DTO 생성
            BizNoVerificationRequestDTO request = BizNoVerificationRequestDTO.of(
                    businessNumber,
                    ceoName,
                    openingDate
            );

            // 2. HTTP 헤더 설정
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            // 3. HTTP 요청 엔티티 생성
            HttpEntity<BizNoVerificationRequestDTO> entity = new HttpEntity<>(request, headers);

            // 4. API 호출 (serviceKey를 쿼리 파라미터로 전달)
            String url = apiUrl + "?serviceKey=" + apiKey;
            logger.debug("API 호출: URL={}", apiUrl);

            ResponseEntity<BizNoVerificationResponseDTO> response = restTemplate.exchange(
                    url,
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

            // 7. 유효성 확인 (valid 필드만 체크)
            if (!data.isValid()) {
                logger.warn("사업자번호 인증 실패: businessNumber={}, valid={}",
                        maskBusinessNumber(businessNumber), data.getValid());
                throw new IllegalArgumentException("입력하신 정보가 국세청 등록 정보와 일치하지 않습니다.");
            }

            // 8. 사업자 상태 확인
            if (!data.isActive()) {
                String status = data.getB_stt() != null ? data.getB_stt() : "알 수 없음";
                logger.warn("사업자 비활성 상태: businessNumber={}, status={}",
                        maskBusinessNumber(businessNumber), status);
                throw new IllegalArgumentException(
                        String.format("해당 사업자는 '%s' 상태입니다.", status)
                );
            }

            logger.info("사업자번호 인증 성공: businessNumber={}, status={}",
                    maskBusinessNumber(businessNumber),
                    data.getB_stt() != null ? data.getB_stt() : "정상");

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

    @Override
    public boolean isValidBusinessNumber(
            String businessNumber,
            String ceoName,
            String openingDate
    ) {
        try {
            verifyBusinessNumber(businessNumber, ceoName, openingDate);
            return true;
        } catch (Exception e) {
            logger.warn("사업자번호 유효성 검증 실패: {}", e.getMessage());
            return false;
        }
    }

    /**
     * 사업자번호 마스킹 (보안)
     */
    private String maskBusinessNumber(String businessNumber) {
        if (businessNumber == null || businessNumber.length() < 4) {
            return "****";
        }
        return businessNumber.substring(0, 3) + "***" + businessNumber.substring(businessNumber.length() - 2);
    }

    /**
     * 이름 마스킹 (보안)
     */
    private String maskName(String name) {
        if (name == null || name.length() < 2) {
            return "*";
        }
        return name.charAt(0) + "*".repeat(name.length() - 1);
    }
}