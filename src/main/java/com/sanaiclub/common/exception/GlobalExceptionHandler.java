package com.sanaiclub.common.exception;

import com.sanaiclub.common.dto.ApiResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger logger = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    // 유효성 검증 실패 (@Valid)
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<Map<String, String>>> handleValidationException(
            MethodArgumentNotValidException e,
            HttpServletRequest request) {

        logger.warn("[유효성 검증 실패] {} - {}",
                request.getMethod(),
                request.getRequestURI());

        // 필드별 에러 메시지 수집
        Map<String, String> errors = new HashMap<>();
        for (FieldError error : e.getBindingResult().getFieldErrors()) {
            errors.put(error.getField(), error.getDefaultMessage());
            logger.debug("  - {}: {}", error.getField(), error.getDefaultMessage());
        }

        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.<Map<String, String>>builder()
                        .success(false)
                        .message("입력값이 올바르지 않습니다.")
                        .data(errors)
                        .build());
    }

    // 예상치 못한 시스템 오류
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleGeneralException(
            Exception e,
            HttpServletRequest request) {

        // 상세 로그 기록 (스택 트레이스 포함)
        logger.error("[시스템 오류] {} - {}: {}",
                request.getMethod(),
                request.getRequestURI(),
                e.getMessage(),
                e);

        // 사용자에게는 일반적인 메시지만 반환
        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요."));
    }
}
