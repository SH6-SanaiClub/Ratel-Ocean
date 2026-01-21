package com.sanaiclub.contract.util;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;

/**
 * resources/prompts/*.txt 템플릿을 읽어오는 유틸
 * - 레거시 MVC2에서도 안전하게 사용 가능
 */
public class PromptTemplateLoader {

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

    public static String load(String classpathLocation) {
        return loadFromClasspath(classpathLocation);
    }
}
