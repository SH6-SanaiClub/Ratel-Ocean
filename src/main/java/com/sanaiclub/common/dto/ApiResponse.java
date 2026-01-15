package com.sanaiclub.common.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * ApiResponse - 공통 API 응답 래퍼
 * ═══════════════════════════════════════════════════════════════════════
 *
 * [역할]
 * - 모든 API 응답을 일관된 형식으로 감싸는 래퍼 클래스
 * - 성공/실패 여부, 메시지, 데이터를 표준화
 *
 * [응답 형식]
 * {
 *   "success": true,
 *   "message": "로그인 성공",
 *   "data": { ... 실제 데이터 ... }
 * }
 *
 * [왜 공통 응답 형식이 필요한가?]
 * 1. 클라이언트가 응답 처리 로직을 통일할 수 있음
 * 2. 에러 처리가 일관됨
 * 3. API 문서화가 쉬워짐
 *
 * [제네릭 사용]
 * - ApiResponse<LoginResponseDTO>: 로그인 응답
 * - ApiResponse<UserInfoDTO>: 사용자 정보 응답
 * - ApiResponse<Void>: 데이터 없는 응답 (로그아웃 등)
 *
 * @param <T> 응답 데이터 타입
 * @author sanaiclub
 * @version 1.0
 */
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ApiResponse<T> {

    /**
     * 요청 성공 여부
     * - true: 성공
     * - false: 실패
     */
    private boolean success;

    /**
     * 응답 메시지
     */
    private String message;

    /**
     * 응답 데이터
     * - 성공 시: 실제 데이터 객체
     * - 실패 시: null
     */
    private T data;

    // ═══════════════════════════════════════════════════════════════
    // 정적 팩토리 메서드 - 성공 응답
    // ═══════════════════════════════════════════════════════════════

    /**
     * 성공 응답 (데이터 + 메시지)
     *
     * @param data    응답 데이터
     * @param message 성공 메시지
     * @return ApiResponse
     */
    public static <T> ApiResponse<T> success(T data, String message) {
        return ApiResponse.<T>builder()
                .success(true)
                .message(message)
                .data(data)
                .build();
    }

    /**
     * 성공 응답 (데이터만, 기본 메시지)
     *
     * @param data 응답 데이터
     * @return ApiResponse
     */
    public static <T> ApiResponse<T> success(T data) {
        return success(data, "요청이 성공적으로 처리되었습니다.");
    }

    /**
     * 성공 응답 (메시지만, 데이터 없음)
     *
     * @param message 성공 메시지
     * @return ApiResponse
     */
    public static ApiResponse<Void> success(String message) {
        return ApiResponse.<Void>builder()
                .success(true)
                .message(message)
                .data(null)
                .build();
    }


    // ═══════════════════════════════════════════════════════════════
    // 정적 팩토리 메서드 - 실패 응답
    // ═══════════════════════════════════════════════════════════════

    /**
     * 실패 응답
     *
     * @param message 에러 메시지
     * @return ApiResponse
     */
    public static <T> ApiResponse<T> error(String message) {
        return ApiResponse.<T>builder()
                .success(false)
                .message(message)
                .data(null)
                .build();
    }

    /**
     * 인증 실패 응답 (401)
     *
     * @param message 에러 메시지
     * @return ApiResponse
     */
    public static <T> ApiResponse<T> unauthorized(String message) {
        return ApiResponse.<T>builder()
                .success(false)
                .message(message)
                .data(null)
                .build();
    }

    /**
     * 권한 없음 응답 (403)
     *
     * @param message 에러 메시지
     * @return ApiResponse
     */
    public static <T> ApiResponse<T> forbidden(String message) {
        return ApiResponse.<T>builder()
                .success(false)
                .message(message)
                .data(null)
                .build();
    }
}
