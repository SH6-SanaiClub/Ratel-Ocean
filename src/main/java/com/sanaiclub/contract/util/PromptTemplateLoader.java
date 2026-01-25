package com.sanaiclub.contract.util;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;


public class PromptTemplateLoader {

    /**
     * 클래스패스에서 프롬프트 템플릿 파일 로드
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
     */
    public static String load(String classpathLocation) {
        return loadFromClasspath(classpathLocation);
    }
}
