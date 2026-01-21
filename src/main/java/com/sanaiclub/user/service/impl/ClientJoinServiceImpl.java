package com.sanaiclub.user.service.impl;

import com.sanaiclub.user.dao.ClientProfileMapper;
import com.sanaiclub.user.dao.CompanyMapper;
import com.sanaiclub.user.model.dto.CompanyRegistrationDTO;
import com.sanaiclub.user.model.vo.ClientProfileVO;
import com.sanaiclub.user.model.vo.ClientType;
import com.sanaiclub.user.model.vo.CompanyVO;
import com.sanaiclub.user.service.BizNoVerificationService;
import com.sanaiclub.user.service.ClientJoinService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * ═══════════════════════════════════════════════════════════════════════
 * 클라이언트 회원가입 서비스 구현
 * ═══════════════════════════════════════════════════════════════════════
 *
 * [트랜잭션 전략]
 * - 모든 단계 완료 후 한번에 INSERT
 * - user 등록은 이미 JoinService에서 완료
 * - 여기서는 client_profiles + companies만 처리
 *
 */
@Service
@Transactional(readOnly = true)
public class ClientJoinServiceImpl implements ClientJoinService {

    private static final Logger logger = LoggerFactory.getLogger(ClientJoinServiceImpl.class);

    private final ClientProfileMapper clientProfileMapper;
    private final CompanyMapper companyMapper;
    private final BizNoVerificationService bizNoVerificationService;

    public ClientJoinServiceImpl(
            ClientProfileMapper clientProfileMapper,
            CompanyMapper companyMapper,
            BizNoVerificationService bizNoVerificationService) {
        this.clientProfileMapper = clientProfileMapper;
        this.companyMapper = companyMapper;
        this.bizNoVerificationService = bizNoVerificationService;
    }

    /**
     * 클라이언트 프로필 등록 (개인)
     */
    @Override
    @Transactional
    public boolean registerClientProfile(Integer userId, ClientType clientType) {
        logger.info("클라이언트 프로필 등록 시작 (개인): userId={}, clientType={}", userId, clientType);

        try {
            // ClientProfileVO 생성
            ClientProfileVO profile = ClientProfileVO.builder()
                    .clientId(userId)  // PK = FK
                    .companyId(null)   // 개인은 회사 없음
                    .clientType(clientType)
                    .build();

            // INSERT
            int inserted = clientProfileMapper.insertClientProfile(profile);

            if (inserted == 0) {
                logger.error("클라이언트 프로필 등록 실패: userId={}", userId);
                throw new IllegalStateException("클라이언트 프로필 등록에 실패했습니다.");
            }

            logger.info("클라이언트 프로필 등록 성공: userId={}", userId);
            return true;

        } catch (Exception e) {
            logger.error("클라이언트 프로필 등록 중 오류: userId={}", userId, e);
            throw new IllegalStateException("클라이언트 프로필 등록 중 오류가 발생했습니다.");
        }
    }

    /**
     * 클라이언트 프로필 등록 (법인)
     * - 트랜잭션: companies INSERT → client_profiles INSERT
     */
    @Override
    @Transactional
    public boolean registerClientProfileWithCompany(Integer userId, CompanyRegistrationDTO companyDTO) {
        logger.info("클라이언트 프로필 등록 시작 (법인): userId={}, company={}",
                userId, companyDTO.getCompanyName());

        try {
            // 1. 사업자번호 중복 확인
            if (isBusinessNumberDuplicate(companyDTO.getCleanBusinessNumber())) {
                logger.warn("사업자번호 중복: businessNumber={}", companyDTO.getCleanBusinessNumber());
                throw new IllegalArgumentException("이미 등록된 사업자번호입니다.");
            }

            // 2. CompanyVO 생성
            CompanyVO company = CompanyVO.builder()
                    .companyName(companyDTO.getCompanyName())
                    .ceoName(companyDTO.getCeoName())
                    .ceoEmail(companyDTO.getCeoEmail())
                    .businessNumber(companyDTO.getCleanBusinessNumber())  // 하이픈 제거
                    .openingDate(companyDTO.getOpeningDateAsLocalDate())
                    .businessVerified(companyDTO.isVerified())
                    .industry(companyDTO.getIndustry())
                    .address(companyDTO.getAddress())
                    .companySize(companyDTO.getCompanySize())
                    .websiteUrl(companyDTO.getWebsiteUrl())
                    .build();

            // 3. companies 테이블 INSERT
            int inserted = companyMapper.insertCompany(company);

            if (inserted == 0) {
                logger.error("회사 정보 등록 실패: userId={}", userId);
                throw new IllegalStateException("회사 정보 등록에 실패했습니다.");
            }

            // 4. AUTO_INCREMENT된 companyId 추출
            Integer companyId = company.getCompanyId();
            logger.debug("회사 등록 성공: companyId={}", companyId);

            // 5. ClientProfileVO 생성
            ClientProfileVO profile = ClientProfileVO.builder()
                    .clientId(userId)
                    .companyId(companyId)  // 방금 생성한 회사 ID
                    .clientType(ClientType.CORPORATION)
                    .build();

            // 6. client_profiles 테이블 INSERT
            int profileInserted = clientProfileMapper.insertClientProfile(profile);

            if (profileInserted == 0) {
                logger.error("클라이언트 프로필 등록 실패: userId={}", userId);
                throw new IllegalStateException("클라이언트 프로필 등록에 실패했습니다.");
            }

            logger.info("클라이언트 프로필 등록 성공 (법인): userId={}, companyId={}", userId, companyId);
            return true;

        } catch (IllegalArgumentException e) {
            // 비즈니스 로직 예외는 그대로 전파
            throw e;

        } catch (Exception e) {
            logger.error("클라이언트 프로필 등록 중 오류 (법인): userId={}", userId, e);
            throw new IllegalStateException("클라이언트 프로필 등록 중 오류가 발생했습니다.");
        }
    }

    /**
     * 사업자번호 중복 확인
     */
    @Override
    public boolean isBusinessNumberDuplicate(String businessNumber) {
        String cleanNumber = businessNumber.replaceAll("-", "");
        return companyMapper.checkBusinessNumber(cleanNumber) > 0;
    }

    /**
     * 사업자번호 진위확인
     */
    @Override
    public boolean verifyBusinessNumber(
            String businessNumber,
            String ceoName,
            String openingDate
    ) {
        try {
            bizNoVerificationService.verifyBusinessNumber(
                    businessNumber,
                    ceoName,
                    openingDate
            );
            return true;
        } catch (Exception e) {
            logger.warn("사업자번호 진위확인 실패: {}", e.getMessage());
            return false;
        }
    }
}