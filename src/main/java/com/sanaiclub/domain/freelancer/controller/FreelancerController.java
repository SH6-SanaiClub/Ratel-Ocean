package com.sanaiclub.domain.freelancer.controller;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.sanaiclub.domain.freelancer.dto.FreelancerProfile;
import com.sanaiclub.domain.freelancer.dto.SkillInput;
import com.sanaiclub.domain.freelancer.mapper.FreelancerMapper;
import com.sanaiclub.domain.freelancer.service.FreelancerService;
import com.sanaiclub.domain.project.service.ProjectService;
import com.sanaiclub.domain.user.dto.User;
import com.sanaiclub.domain.user.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpSession;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

/**
 * 프리랜서 관련 컨트롤러
 * 
 * 핸들러:
 * - /freelancer/dashboard : 프리랜서 대시보드
 * - /freelancer/main : 프리랜서 메인 페이지
 * - /freelancer/complete-profile.do : 프로필 완성 페이지 (GET)
 * - /freelancer/complete-profile.do : 프로필 완성 처리 (POST)
 */
@Controller
@RequestMapping("/freelancer")
public class FreelancerController {

    @Autowired
    private FreelancerService freelancerService;
    
    @Autowired
    private FreelancerMapper freelancerMapper;
    
    @Autowired
    private UserMapper userMapper;

    @Autowired
    private ProjectService projectService;
    
    private ObjectMapper objectMapper = new ObjectMapper();

    /**
     * 프리랜서 메인 페이지
     */
    @GetMapping("/main")
    public String main(HttpSession session, Model model) {
        Long userId = (Long) session.getAttribute("userId");
        User user = (User) session.getAttribute("loginUser");
        
        System.out.println("=== freelancer/main 접근 ===");
        System.out.println("userId: " + userId);
        System.out.println("loginUser: " + user);
        
        if (userId == null || user == null) {
            System.out.println("❌ 로그인되지 않음 - 로그인 페이지로 리다이렉트");
            return "redirect:/login";
        }
        
        // 프리랜서 프로필 정보 조회
        FreelancerProfile freelancerProfile = freelancerMapper.findByUserId(userId);
        
        // Model에 정보 전달
        model.addAttribute("user", user);
        model.addAttribute("freelancerProfile", freelancerProfile);
        
        System.out.println("✅ freelancer/main 페이지 표시");
        return "freelancer/main";
    }

    /**
     * 프리랜서 대시보드
     */
    @GetMapping("/dashboard")
    public String dashboard() {
        return "freelancer/dashboard";
    }


    /**
     * 기술 스택 목록 조회 (AJAX)
     * 
     * 요청:
     * - GET /freelancer/get-stacks.do
     * 
     * 응답:
     * - JSON: { "stacks": [ { "stack_id": 1, "stack_name": "Java", "category": "SKILL" }, ... ] }
     * 
     * 사용처:
     * - complete-profile.jsp의 기술 스택 모달
     */
    @GetMapping("/get-stacks.do")
    @ResponseBody
    public Map<String, Object> getStacks() {
        try {
            List<Map<String, Object>> stacks = freelancerService.getAllStacks();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("stacks", stacks);
            response.put("count", stacks.size());
            
            return response;
        } catch (Exception e) {
            e.printStackTrace();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "기술 스택 목록 조회 실패: " + e.getMessage());
            
            return response;
        }
    }

    /**
     * 프로필 완성 페이지 조회 (GET)
     * 
     * 접근:
     * - http://localhost:9999/ratelocean/freelancer/complete-profile.do
     * - 프리랜서 가입 후 프로필 완성 페이지로 리다이렉트
     * 
     * 반환:
     * - freelancer/complete-profile.jsp
     */
    @GetMapping("/complete-profile.do")
    public String showCompleteProfilePage(HttpSession session, Model model) {
        // 세션에서 로그인한 사용자 정보 확인
        Long userId = (Long) session.getAttribute("userId");
        String userType = (String) session.getAttribute("userType");
        
        // 임시 사용자 (회원가입 직후)
        User tempUser = (User) session.getAttribute("tempUser");
        
        // 프리랜서만 접근 가능 (로그인 사용자 또는 회원가입 중인 임시 사용자)
        if (userId == null && tempUser == null) {
            return "redirect:/join/select-role.do";
        }
        
        // 프로필 정보 조회 (userId가 있을 경우만)
        if (userId != null) {
            FreelancerProfile profile = freelancerService.getProfile(userId);
            model.addAttribute("profile", profile);
        }
        
        return "freelancer/complete-profile";
    }

    /**
     * 프로필 완성 처리 (POST)
     * 
     * 요청:
     * - POST /freelancer/complete-profile.do
     * - nickname, introduction, school_name, major, degree, grad_status, 
     *   bank_name, account_number, account_holder, skills_json
     * 
     * 처리:
     * 1. JSON 기술 스택 파싱 (skills_json)
     * 2. 프리랜서 프로필 업데이트
     * 3. 기술 스택 저장
     * 4. 대시보드로 리다이렉트
     * 
     * 응답:
     * - 성공: redirect:/freelancer/dashboard
     * - 실패: redirect:/freelancer/complete-profile.do
     */
    @PostMapping("/complete-profile.do")
    public String completeProfile(
            @RequestParam String nickname,
            @RequestParam(required = false) String introduction,
            @RequestParam(required = false) String school_name,
            @RequestParam(required = false) String major,
            @RequestParam(required = false) String degree,
            @RequestParam(required = false) String grad_status,
            @RequestParam(required = false) String github_url,
            @RequestParam(required = false) String website_url,
            @RequestParam(required = false) String bank_name,
            @RequestParam(required = false) String account_number,
            @RequestParam(required = false) String account_holder,
            @RequestParam(required = false) String skills_json,
            HttpSession session,
            RedirectAttributes redirectAttributes) {
        
        try {
            // 1. 세션에서 사용자 확인 (로그인 사용자 또는 회원가입 중인 임시 사용자)
            Long userId = (Long) session.getAttribute("userId");
            User tempUser = (User) session.getAttribute("tempUser");
            
            System.out.println("=== completeProfile POST 시작 ===");
            System.out.println("userId from session: " + userId);
            System.out.println("tempUser from session: " + tempUser);
            
            // userId가 없고 tempUser도 없으면 로그인 페이지로
            if (userId == null && tempUser == null) {
                System.out.println("❌ 세션에 사용자 정보가 없습니다.");
                return "redirect:/join/select-role.do";
            }
            
            // tempUser가 있으면 먼저 DB에 저장하고 userId를 얻음
            if (userId == null && tempUser != null) {
                System.out.println("📝 tempUser를 DB에 저장 중...");
                // UserService를 통해 DB에 저장하고 userId 획득
                // 여기서는 간단히 userMapper를 직접 사용
                int result = userMapper.insertUser(tempUser);
                if (result > 0) {
                    userId = tempUser.getUserId();
                    System.out.println("✅ User 저장 완료. userId: " + userId);
                    
                    // 세션 업데이트
                    session.setAttribute("userId", userId);
                    session.setAttribute("userType", tempUser.getUserType());
                    session.setAttribute("user", tempUser);
                    session.removeAttribute("tempUser");
                } else {
                    System.out.println("❌ User 저장 실패");
                    redirectAttributes.addFlashAttribute("error", "사용자 정보 저장에 실패했습니다.");
                    return "redirect:/freelancer/complete-profile.do";
                }
            }
            
            System.out.println("최종 userId: " + userId);
            
            // 2. 프로필 정보 생성 (snake_case → camelCase 변환)
            FreelancerProfile profile = new FreelancerProfile();
            profile.setUserId(userId);
            profile.setNickname(nickname);
            profile.setIntroduction(introduction);
            profile.setGithubUrl(github_url);
            profile.setWebsiteUrl(website_url);
            profile.setSchoolName(school_name);
            profile.setMajor(major);
            profile.setDegree(degree);
            profile.setGradStatus(grad_status);
            profile.setIsProfileComplete(true);
            
            // 3. skills_json 파싱
            List<SkillInput> skills = parseSkillsJson(skills_json);
            
            // 4. 프로필 완성 처리
            boolean success = freelancerService.completeProfile(userId, profile, skills);
            
            if (success) {
                // ✅ 자동 로그인: 세션에 있는 User를 loginUser로 설정
                User currentUser = (User) session.getAttribute("user");
                if (currentUser == null) {
                    currentUser = tempUser; // tempUser가 있으면 사용
                }
                
                if (currentUser != null) {
                    session.setAttribute("loginUser", currentUser);
                    session.setAttribute("userId", currentUser.getUserId());
                    session.setAttribute("userType", currentUser.getUserType());
                    session.setAttribute("userName", currentUser.getName());
                    System.out.println("✅ 자동 로그인 완료: " + currentUser.getLoginId());
                    
                    // tempUser 제거 (임시 사용자는 이제 불필요)
                    session.removeAttribute("tempUser");
                }
                
                // 5. 성공 메시지와 함께 프리랜서 메인 페이지로 리다이렉트
                redirectAttributes.addFlashAttribute("message", "프로필이 완성되었습니다!");
                return "redirect:/freelancer/main";
            } else {
                // 실패 메시지와 함께 프로필 페이지로 리다이렉트
                redirectAttributes.addFlashAttribute("error", "프로필 저장 중 오류가 발생했습니다.");
                return "redirect:/freelancer/complete-profile.do";
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "오류 발생: " + e.getMessage());
            return "redirect:/freelancer/complete-profile.do";
        }
    }

    /**
     * JSON 문자열을 SkillInput 리스트로 파싱
     * 
     * JSON 형식:
     * [
     *   { "id": 1, "name": "Java", "level": 3, "years": 1 },
     *   { "id": 2, "name": "React", "level": 3, "years": 2 }
     * ]
     * 
     * @param skillsJson JSON 문자열
     * @return SkillInput 리스트
     */
    private List<SkillInput> parseSkillsJson(String skillsJson) {
        if (skillsJson == null || skillsJson.isEmpty() || "[]".equals(skillsJson)) {
            return List.of();
        }
        
        try {
            List<SkillInput> skills = objectMapper.readValue(
                skillsJson,
                new TypeReference<List<SkillInput>>() {}
            );
            return skills;
        } catch (Exception e) {
            System.err.println("❌ 기술 스택 JSON 파싱 실패: " + e.getMessage());
            e.printStackTrace();
            return List.of();
        }
    }

    /**
     * 프리랜서 프로젝트 찾기 (김연아씨 대시보드 기반)
     * 지원할 수 있는 프로젝트 목록을 검색합니다.
     */
    @GetMapping("/projects")
    public String freelancerProjects(Model model) {
        var projectList = projectService.findAllProjects();
        model.addAttribute("projectList", projectList);
        model.addAttribute("currentPage", 1);
        model.addAttribute("totalPages", 1);
        model.addAttribute("startPage", 1);
        model.addAttribute("endPage", 1);
        model.addAttribute("totalElements", projectList.size());
        return "freelancer/projects";
    }

    /**
     * 프리랜서 내 프로젝트 관리
     * 수락한 프로젝트들의 진행 상황을 관리합니다.
     */
    @GetMapping("/my-projects")
    public String freelancerMyProjects() {
        return "freelancer/my-projects";
    }

    /**
     * 프리랜서 금융 관리
     * 수입, 지출, 정산 내역 등을 관리합니다.
     */
    @GetMapping("/finance")
    public String freelancerFinance() {
        return "freelancer/finance";
    }

    /**
     * 프리랜서 경력 관리
     * 프로필, 포트폴리오, 평가 등을 관리합니다.
     */
    @GetMapping("/career")
    public String freelancerCareer() {
        return "freelancer/career";
    }
}

