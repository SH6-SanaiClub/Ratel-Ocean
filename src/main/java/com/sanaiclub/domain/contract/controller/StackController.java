package com.sanaiclub.domain.contract.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 기술 스택(stacks) 데이터 조회 API
 * - POSITION: 개발 영역 (8개)
 * - SKILL: 기술 스택 (124개)
 */
@Controller
@RequestMapping("/api/stacks")
public class StackController {

    @Autowired
    private DataSource dataSource;

    /**
     * GET /api/stacks/positions
     * 개발 영역 목록 조회 (POSITION 카테고리)
     * @return List<Map> - [{"id": 125, "name": "웹"}, ...]
     */
    @GetMapping("/positions")
    @ResponseBody
    public List<Map<String, Object>> getPositions() {
        List<Map<String, Object>> positions = new ArrayList<>();
        
        String sql = "SELECT stack_id, stack_name FROM stacks WHERE category = 'POSITION' ORDER BY stack_name";
        
        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> position = new HashMap<>();
                position.put("id", rs.getLong("stack_id"));
                position.put("name", rs.getString("stack_name"));
                positions.add(position);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            // 에러 발생 시 빈 리스트 반환
        }
        
        return positions;
    }

    /**
     * GET /api/stacks/skills
     * 기술 스택 목록 조회 (SKILL 카테고리)
     * @return List<Map> - [{"id": 1, "name": ".Net"}, ...]
     */
    @GetMapping("/skills")
    @ResponseBody
    public List<Map<String, Object>> getSkills() {
        List<Map<String, Object>> skills = new ArrayList<>();
        
        String sql = "SELECT stack_id, stack_name FROM stacks WHERE category = 'SKILL' ORDER BY stack_name";
        
        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> skill = new HashMap<>();
                skill.put("id", rs.getLong("stack_id"));
                skill.put("name", rs.getString("stack_name"));
                skills.add(skill);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            // 에러 발생 시 빈 리스트 반환
        }
        
        return skills;
    }

    /**
     * GET /api/stacks/all
     * 전체 스택 목록 조회 (카테고리 포함)
     * @return Map - {"positions": [...], "skills": [...]}
     */
    @GetMapping("/all")
    @ResponseBody
    public Map<String, Object> getAllStacks() {
        Map<String, Object> result = new HashMap<>();
        result.put("positions", getPositions());
        result.put("skills", getSkills());
        return result;
    }
}
