package com.sanaiclub.common.exception;

import com.sanaiclub.common.dto.ApiResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.BindException;
import org.springframework.validation.FieldError;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.servlet.NoHandlerFoundException;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.Map;

/**
 * GlobalExceptionHandler - 전역 예외 처리
 *
 * [처리 범위]
 * 1. 유효성 검증 실패 (@Valid)
 * 2. 비즈니스 로직 예외 (IllegalArgumentException, IllegalStateException)
 * 3. HTTP 요청 오류 (잘못된 메서드, 파라미터 누락 등)
 * 4. JSON 파싱 오류
 * 5. 예상치 못한 시스템 오류
 *
 */
@ControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger logger = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    /**
     * @Valid 유효성 검증 실패
     */
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

    /**
     * BindException - 폼 데이터 바인딩 실패
     */
    @ExceptionHandler(BindException.class)
    public ResponseEntity<ApiResponse<Map<String, String>>> handleBindException(
            BindException e,
            HttpServletRequest request) {

        logger.warn("[폼 바인딩 실패] {} - {}",
                request.getMethod(),
                request.getRequestURI());

        Map<String, String> errors = new HashMap<>();
        for (FieldError error : e.getBindingResult().getFieldErrors()) {
            errors.put(error.getField(), error.getDefaultMessage());
        }

        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.<Map<String, String>>builder()
                        .success(false)
                        .message("입력 데이터가 올바르지 않습니다.")
                        .data(errors)
                        .build());
    }

    /**
     * IllegalArgumentException - 잘못된 인자
     * - 예: "이미 지원한 프로젝트입니다", "존재하지 않는 사용자입니다"
     */
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ApiResponse<Void>> handleIllegalArgumentException(
            IllegalArgumentException e,
            HttpServletRequest request) {

        logger.warn("[비즈니스 로직 예외] {} - {}: {}",
                request.getMethod(),
                request.getRequestURI(),
                e.getMessage());

        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(e.getMessage()));
    }

    /**
     * IllegalStateException - 잘못된 상태
     * - 예: "이미 승인된 프로젝트입니다", "인증되지 않은 사용자입니다"
     */
    @ExceptionHandler(IllegalStateException.class)
    public ResponseEntity<ApiResponse<Void>> handleIllegalStateException(
            IllegalStateException e,
            HttpServletRequest request) {

        logger.warn("[상태 검증 실패] {} - {}: {}",
                request.getMethod(),
                request.getRequestURI(),
                e.getMessage());

        return ResponseEntity
                .status(HttpStatus.CONFLICT)
                .body(ApiResponse.error(e.getMessage()));
    }

    /**
     * HttpRequestMethodNotSupportedException - 지원하지 않는 HTTP 메서드
     * - 예: POST 요청을 GET으로 호출
     */
    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<ApiResponse<Void>> handleMethodNotSupported(
            HttpRequestMethodNotSupportedException e,
            HttpServletRequest request) {

        logger.warn("[지원하지 않는 HTTP 메서드] {} - {} (지원: {})",
                request.getMethod(),
                request.getRequestURI(),
                e.getSupportedHttpMethods());

        return ResponseEntity
                .status(HttpStatus.METHOD_NOT_ALLOWED)
                .body(ApiResponse.error(
                        String.format("지원하지 않는 HTTP 메서드입니다. (%s)", e.getMethod())
                ));
    }

    /**
     * MissingServletRequestParameterException - 필수 파라미터 누락
     * - 예: @RequestParam(required=true)인데 값이 없을 때
     */
    @ExceptionHandler(MissingServletRequestParameterException.class)
    public ResponseEntity<ApiResponse<Void>> handleMissingParameter(
            MissingServletRequestParameterException e,
            HttpServletRequest request) {

        logger.warn("[필수 파라미터 누락] {} - {}: {}",
                request.getMethod(),
                request.getRequestURI(),
                e.getParameterName());

        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(
                        String.format("필수 파라미터가 누락되었습니다: %s", e.getParameterName())
                ));
    }

    /**
     * MethodArgumentTypeMismatchException - 파라미터 타입 불일치
     * - 예: Integer 파라미터에 "abc" 전달
     */
    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<ApiResponse<Void>> handleTypeMismatch(
            MethodArgumentTypeMismatchException e,
            HttpServletRequest request) {

        logger.warn("[파라미터 타입 불일치] {} - {}: {} (기대: {})",
                request.getMethod(),
                request.getRequestURI(),
                e.getName(),
                e.getRequiredType());

        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(
                        String.format("파라미터 타입이 올바르지 않습니다: %s", e.getName())
                ));
    }

    /**
     * HttpMessageNotReadableException - JSON 파싱 실패
     * - 예: 잘못된 JSON 형식, 필드 타입 불일치
     */
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ApiResponse<Void>> handleJsonParseError(
            HttpMessageNotReadableException e,
            HttpServletRequest request) {

        logger.warn("[JSON 파싱 실패] {} - {}: {}",
                request.getMethod(),
                request.getRequestURI(),
                e.getMessage());

        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error("요청 데이터 형식이 올바르지 않습니다."));
    }

    /**
     * NoHandlerFoundException - 404 에러 (핸들러를 찾을 수 없음)
     * - web.xml에서 throw-exception-if-no-handler-found=true 설정 필요
     */
    @ExceptionHandler(NoHandlerFoundException.class)
    public ResponseEntity<ApiResponse<Void>> handleNotFound(
            NoHandlerFoundException e,
            HttpServletRequest request) {

        logger.warn("[404 Not Found] {} - {}",
                request.getMethod(),
                request.getRequestURI());

        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error("요청한 리소스를 찾을 수 없습니다."));
    }

    // 예상치 못한 예외
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
