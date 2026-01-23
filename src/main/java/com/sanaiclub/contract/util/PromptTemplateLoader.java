package com.sanaiclub.contract.util;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;

/**
 * ============================================================================
 * PromptTemplateLoader - 프롬프트 템플릿 로더 유틸리티
 * ============================================================================
 * 
 * [역할]
 * - resources/prompts/*.txt 템플릿 파일을 읽어오는 유틸리티 클래스
 * - 클래스패스에서 템플릿 파일을 로드
 * - 레거시 MVC2 환경에서도 안전하게 사용 가능
 * 
 * [사용 위치]
 * - ContractAutoFillServiceImpl: AI 프롬프트 템플릿 로드
 * 
 * [템플릿 파일 위치]
 * - src/main/resources/contract/prompts/contract_autofill_prompt.txt
 * - 클래스패스: "contract/prompts/contract_autofill_prompt.txt"
 * 
 * [특징]
 * - 정적 메서드: 인스턴스 생성 없이 사용 가능
 * - UTF-8 인코딩: 한글 템플릿 지원
 * - 예외 처리: 파일이 없거나 읽기 실패 시 RuntimeException 발생
 * 
 * ============================================================================
 */
public class PromptTemplateLoader {

    /**
     * 클래스패스에서 프롬프트 템플릿 파일 로드
     * 
     * [기능]
     * - 클래스패스에서 템플릿 파일을 읽어서 문자열로 반환
     * - UTF-8 인코딩으로 읽기 (한글 지원)
     * 
     * [처리 흐름]
     * 1. 클래스 로더를 통해 클래스패스에서 리소스 스트림 획득
     * 2. BufferedReader로 한 줄씩 읽기
     * 3. StringBuilder로 모든 줄을 결합
     * 4. 문자열 반환
     * 
     * [에러 처리]
     * - 파일이 없으면 IllegalStateException 발생
     * - 읽기 실패 시 RuntimeException 발생
     * 
     * [사용 예시]
     * - loadFromClasspath("contract/prompts/contract_autofill_prompt.txt")
     * 
     * @param classpathLocation 클래스패스 상의 파일 경로
     *                          예) "contract/prompts/contract_autofill_prompt.txt"
     * @return 템플릿 파일 내용 (문자열)
     * @throws IllegalStateException 파일이 없을 때
     * @throws RuntimeException 파일 읽기 실패 시
     */
    public static String loadFromClasspath(String classpathLocation) {
        try (InputStream is = PromptTemplateLoader.class.getClassLoader().getResourceAsStream(classpathLocation)) {
            if (is == null) {
                throw new IllegalStateException("Prompt file not found: " + classpathLocation);
            }
            BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line).append("\n");
            }
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("Failed to load prompt: " + classpathLocation, e);
        }
    }

    /**
     * 프롬프트 템플릿 파일 로드 (간편 메서드)
     * 
     * [기능]
     * - loadFromClasspath()의 별칭 메서드
     * - 더 간단한 메서드명으로 사용 가능
     * 
     * @param classpathLocation 클래스패스 상의 파일 경로
     * @return 템플릿 파일 내용 (문자열)
     */
    public static String load(String classpathLocation) {
        return loadFromClasspath(classpathLocation);
    }
}
