package com.sanaiclub.user.service.impl;

import com.sanaiclub.common.util.EncryptionUtil;
import com.sanaiclub.user.dao.*;
import com.sanaiclub.user.model.dto.*;
import com.sanaiclub.user.model.vo.*;
import com.sanaiclub.user.service.JoinService;
import com.sanaiclub.wallet.dao.WalletMapper;
import com.sanaiclub.wallet.model.vo.FreelancerWalletVO;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class JoinServiceImpl implements JoinService {

    private static final Logger logger = LoggerFactory.getLogger(JoinServiceImpl.class);

    private final UserMapper userMapper;
    private final FreelancerProfileMapper freelancerProfileMapper;
    private final ClientProfileMapper clientProfileMapper;
    private final CompanyMapper companyMapper;
    private final AccountMapper accountMapper;
    private final WalletMapper walletMapper;
    private final PasswordEncoder passwordEncoder;
    private final EncryptionUtil encryptionUtil;

    // ═══════════════════════════════════════════════════════════════
    // 중복 확인
    // ═══════════════════════════════════════════════════════════════

    @Override
    public boolean isIdDuplicate(String loginId) {
        return userMapper.checkId(loginId) > 0;
    }

    @Override
    public boolean isEmailDuplicate(String email) {
        return userMapper.checkEmail(email) > 0;
    }

    @Override
    public boolean isBusinessNumberDuplicate(String businessNumber) {
        String cleanNumber = businessNumber.replaceAll("-", "");
        return companyMapper.checkBusinessNumber(cleanNumber) > 0;
    }

    // ═══════════════════════════════════════════════════════════════
    // 회원가입
    // ═══════════════════════════════════════════════════════════════

    // 프리랜서 회원가입
    @Transactional(rollbackFor = Exception.class)
    @Override
    public boolean signUpFreelancer(
            UserSignupRequestDTO userDto,
            FreelancerProfileDTO profileDto,
            AccountDTO accountDto) throws Exception {
        try {
            // 1. User INSERT
            Integer userId = insertCommonUser(userDto);
            logger.debug("User 등록 완료: userId={}", userId);

            // 2. FreelancerProfile INSERT
            int profileInserted = freelancerProfileMapper.insertFreelancerProfile(userId, profileDto);
            if (profileInserted == 0) {
                throw new IllegalStateException("프리랜서 프로필 등록 실패");
            }
            logger.debug("프리랜서 프로필 등록 완료: userId={}", userId);

            // 3. Account INSERT
            Integer accountId = insertCommonAccount(userId, accountDto);
            logger.debug("계좌 정보 등록 완료: userId={}, accountId={}", userId, accountId);

            // 4. FreelancerWallet INSERT (프리랜서만)
            insertFreelancerWallet(userId, accountId, accountDto.getWalletPassword());
            logger.debug("지갑 생성 완료: userId={}, accountId={}", userId, accountId);

            logger.info("✅ 프리랜서 회원가입 완료: userId={}, loginId={}", userId, userDto.getLoginId());
            return true;

        } catch (Exception e) {
            logger.error("❌ 프리랜서 회원가입 실패: {}", e.getMessage(), e);
            throw e;
        }
    }

    // 클라이언트 회원가입 (개인)
    @Transactional(rollbackFor = Exception.class)
    @Override
    public boolean signUpClientPersonal(UserSignupRequestDTO userDto, AccountDTO accountDto) throws Exception {
        try {
            // 1. User INSERT
            Integer userId = insertCommonUser(userDto);
            logger.debug("User 등록 완료: userId={}", userId);

            // 2. ClientProfile INSERT (개인 - company_id는 null)
            int profileInserted = clientProfileMapper.insertClientProfile(
                    userId,
                    null,  // 개인은 회사 없음
                    ClientType.PERSONAL
            );
            if (profileInserted == 0) {
                throw new IllegalStateException("클라이언트 프로필 등록 실패");
            }
            logger.debug("클라이언트 프로필 등록 완료 (개인): userId={}", userId);

            // 3. Account INSERT
            insertCommonAccount(userId, accountDto);
            logger.debug("계좌 정보 등록 완료: userId={}", userId);

            logger.info("✅ 개인 클라이언트 회원가입 완료: userId={}, loginId={}", userId, userDto.getLoginId());
            return true;

        } catch (Exception e) {
            logger.error("❌ 개인 클라이언트 회원가입 실패: {}", e.getMessage(), e);
            throw e;
        }
    }

    // 클라이언트 회원가입 (법인)
    @Transactional(rollbackFor = Exception.class)
    @Override
    public boolean signUpClientCorporation(UserSignupRequestDTO userDto, CompanyRegistrationDTO companyDto, AccountDTO accountDto) throws Exception {
        try {
            // 1. User INSERT
            Integer userId = insertCommonUser(userDto);
            logger.debug("User 등록 완료: userId={}", userId);

            // 2. Company INSERT
            CompanyVO company = CompanyVO.builder()
                    .companyName(companyDto.getCompanyName())
                    .ceoName(companyDto.getCeoName())
                    .ceoEmail(companyDto.getCeoEmail())
                    .businessNumber(companyDto.getCleanBusinessNumber())
                    .openingDate(companyDto.getOpeningDateAsLocalDate())
                    .businessVerified(companyDto.isVerified())
                    .industry(companyDto.getIndustry())
                    .address(companyDto.getAddress())
                    .companySize(companyDto.getCompanySize())
                    .websiteUrl(companyDto.getWebsiteUrl())
                    .build();

            int companyInserted = companyMapper.insertCompany(company);
            if (companyInserted == 0) {
                throw new IllegalStateException("회사 정보 등록 실패");
            }

            Integer companyId = company.getCompanyId();  // AUTO_INCREMENT ID
            logger.debug("회사 정보 등록 완료: companyId={}", companyId);

            // 3. ClientProfile INSERT (법인 - company_id 포함)
            int profileInserted = clientProfileMapper.insertClientProfile(
                    userId,
                    companyId,
                    ClientType.CORPORATION
            );
            if (profileInserted == 0) {
                throw new IllegalStateException("클라이언트 프로필 등록 실패");
            }
            logger.debug("클라이언트 프로필 등록 완료 (법인): userId={}, companyId={}", userId, companyId);

            // 4. Account INSERT
            insertCommonAccount(userId, accountDto);
            logger.debug("계좌 정보 등록 완료: userId={}", userId);

            logger.info("✅ 법인 클라이언트 회원가입 완료: userId={}, companyId={}, loginId={}",
                    userId, companyId, userDto.getLoginId());
            return true;

        } catch (Exception e) {
            logger.error("❌ 법인 클라이언트 회원가입 실패: {}", e.getMessage(), e);
            throw e;
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // 헬퍼 메서드
    // ═══════════════════════════════════════════════════════════════

    // 공통 User 정보 INSERT
    private Integer insertCommonUser(UserSignupRequestDTO userDto) {

        // 비밀번호 암호화
        String encodedPassword = passwordEncoder.encode(userDto.getPassword());

        // dto -> vo 변환
        UserVO userVO = UserVO.builder()
                .loginId(userDto.getLoginId())
                .password(encodedPassword)
                .email(userDto.getEmail())
                .name(userDto.getName())
                .phone(userDto.getPhone())
                .birthDate(userDto.getBirthDate())
                .userType(userDto.getUserType())
                .status(UserStatus.ACTIVE)
                .build();

        // INSERT
        int inserted = userMapper.insertUser(userVO);
        if (inserted == 0) {
            throw new IllegalStateException("사용자 정보 등록 실패");
        }

        // useGeneratedKeys로 받아온 ID 리턴
        return userVO.getUserId();
    }

    // 공통 계좌 정보 INSERT
    private Integer insertCommonAccount(Integer userId, AccountDTO accountDto) throws Exception {

        // 계좌번호 암호화
        String encryptedAccountNumber = encryptionUtil.encrypt(accountDto.getAccountNumber());

        // DTO → VO 변환
        AccountVO accountVO = AccountVO.builder()
                .userId(userId)
                .bankName(accountDto.getBankName())
                .accountNumber(encryptedAccountNumber)
                .accountHolder(accountDto.getAccountHolder())
                .build();

        // INSERT
        int inserted = accountMapper.insertAccount(accountVO);
        if (inserted == 0) {
            throw new IllegalStateException("계좌 정보 등록 실패");
        }

        // useGeneratedKeys로 받아온 accountId 반환
        return accountVO.getAccountId();
    }

    // 프리랜서 지갑 생성 메서드
    private void insertFreelancerWallet(Integer userId, Integer accountId, String walletPassword) {
        // 지갑 비밀번호 암호화 (BCrypt)
        String encodedWalletPw = passwordEncoder.encode(walletPassword);

        FreelancerWalletVO walletVO = FreelancerWalletVO.builder()
                .userId(userId)
                .accountId(accountId)
                .balance(0L)
                .totalEarned(0L)
                .walletPw(encodedWalletPw)
                .version(0)
                .build();

        int inserted = walletMapper.insertWallet(walletVO);
        if (inserted == 0) {
            throw new IllegalStateException("지갑 생성 실패");
        }
    }
}