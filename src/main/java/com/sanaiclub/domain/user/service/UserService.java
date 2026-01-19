package com.sanaiclub.domain.user.service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.sanaiclub.domain.user.dto.User;
import com.sanaiclub.domain.user.mapper.UserMapper;
import com.sanaiclub.domain.freelancer.dto.FreelancerProfile;
import com.sanaiclub.domain.freelancer.mapper.FreelancerMapper;
import com.sanaiclub.domain.wallet.dto.Account;
import com.sanaiclub.domain.wallet.dto.FreelancerWallet;
import com.sanaiclub.domain.wallet.mapper.AccountMapper;

/**
 * UserService - 사용자 관련 비즈니스 로직 처리
 */
@Service
public class UserService {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private FreelancerMapper freelancerMapper;

    @Autowired
    private AccountMapper accountMapper;
    
    /**
     * FreelancerMapper 가져오기 (Controller에서 직접 접근용)
     */
    public FreelancerMapper getFreelancerMapper() {
        return freelancerMapper;
    }

    /**
     * 이메일 중복 확인
     */
    public boolean isEmailDuplicate(String email) {
        return userMapper.countByEmail(email) > 0;
    }

    /**
     * loginId 중복 확인
     */
    public boolean isLoginIdDuplicate(String loginId) {
        return userMapper.countByLoginId(loginId) > 0;
    }

    /**
     * 닉네임 중복 확인 (프리랜서)
     */
    public boolean isNicknameDuplicate(String nickname) {
        return freelancerMapper.countByNickname(nickname) > 0;
    }

    /**
     * 회원가입 처리 (프리랜서 - 프로필 + 계좌 + 지갑 포함)
     */
    @Transactional
    public User registerFreelancer(String loginId, String email, String password, 
                                   String name, String phone, String birthStr,
                                   String nickname, String introduction, 
                                   String githubUrl, String websiteUrl,
                                   String bankName, String accountNumber, String accountHolder) {
        
        // 1. 중복 검증
        if (isEmailDuplicate(email)) {
            throw new IllegalArgumentException("이미 사용 중인 이메일입니다.");
        }
        
        if (isLoginIdDuplicate(loginId)) {
            throw new IllegalArgumentException("이미 사용 중인 아이디입니다.");
        }
        
        if (nickname != null && !nickname.isEmpty() && isNicknameDuplicate(nickname)) {
            throw new IllegalArgumentException("이미 사용 중인 닉네임입니다.");
        }

        // 2. User 객체 생성
        User user = new User();
        user.setLoginId(loginId);
        user.setEmail(email);
        user.setPassword(password); // TODO: 실제로는 BCrypt 등으로 암호화 필요
        user.setName(name);
        user.setPhone(phone);
        user.setUserType("FREELANCER");
        user.setStatus("ACTIVE");

        // 3. 생년월일 파싱 (YYYY.MM.DD -> LocalDate)
        if (birthStr != null && !birthStr.isEmpty()) {
            try {
                String cleanBirth = birthStr.replace(".", "-");
                LocalDate birthDate = LocalDate.parse(cleanBirth, DateTimeFormatter.ISO_LOCAL_DATE);
                user.setBirthDate(birthDate);
            } catch (Exception e) {
                // 파싱 실패 시 무시
            }
        }

        // 4. users 테이블에 저장
        userMapper.insertUser(user);
        
        // 5. 프리랜서 프로필 생성
        if (nickname != null && !nickname.isEmpty()) {
            FreelancerProfile profile = new FreelancerProfile();
            profile.setUserId(user.getUserId());
            profile.setNickname(nickname);
            profile.setIntroduction(introduction);
            profile.setGithubUrl(githubUrl);
            profile.setWebsiteUrl(websiteUrl);
            profile.setIsProfileComplete(false); // 기본값
            
            freelancerMapper.insertFreelancerProfile(profile);
        }
        
        // 6. 계좌 정보 저장
        if (bankName != null && !bankName.isEmpty() && accountNumber != null && !accountNumber.isEmpty()) {
            Account account = new Account();
            account.setUserId(user.getUserId());
            account.setBankName(bankName);
            account.setAccountNumber(accountNumber);
            account.setAccountHolder(accountHolder);
            
            accountMapper.insertAccount(account);
            
            // 7. 프리랜서 지갑 생성 (계좌 연결)
            FreelancerWallet wallet = new FreelancerWallet();
            wallet.setFreelancerId(user.getUserId());
            wallet.setAccountId(account.getAccountId());
            wallet.setBalance(0L);
            wallet.setTotalEarned(0L);
            wallet.setWalletPw("0000"); // 기본 지갑 비밀번호 (추후 변경 필요)
            wallet.setVersion(0);
            
            accountMapper.insertFreelancerWallet(wallet);
        }
        
        return user;
    }

    /**
     * 로그인 처리
     */
    public User login(String email, String password) {
        return userMapper.findByEmailAndPassword(email, password);
    }
}
