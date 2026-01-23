package com.sanaiclub.contract.service;

import java.io.File;
import com.sanaiclub.contract.model.dto.ContractAutoFillDTO;
import com.sanaiclub.project.model.vo.ProjectsVO;
import com.sanaiclub.user.model.vo.UserVO;
import com.sanaiclub.user.model.vo.FreelancerProfileVO;

/**
 * ============================================================================
 * ContractAutoFillService - 계약 자동 초안 생성 서비스 인터페이스
 * ============================================================================
 * 
 * [역할]
 * - PDF 계약서, 사용자 입력 내용, 프로젝트/프리랜서 정보를 종합하여
 *   "계약 주요 정보 초안"을 자동으로 생성
 * - AI를 활용한 계약서 내용 추출 및 자동 채우기
 * 
 * [처리 흐름]
 * 1. PDF 계약서 텍스트 추출 (PDF가 있는 경우)
 * 2. 사용자 입력 내용 수집 (manualText)
 * 3. 프로젝트/프리랜서 정보 수집
 * 4. AI를 통한 계약 정보 추출 및 분석
 * 5. 계약 주요 정보 초안 DTO 생성
 * 
 * [책임 분리 원칙]
 * - 이 인터페이스는 "흐름"만 정의
 * - PDF 처리, AI 호출, DB 접근은 구현체(ContractAutoFillServiceImpl)에서 수행
 * - 다른 도메인 정보는 Controller에서 조회하여 전달받음
 * - Service는 contract 도메인만 담당하며 다른 도메인을 침범하지 않음
 * 
 * [구현체]
 * - ContractAutoFillServiceImpl: 실제 구현
 * - DeepSeekContractAIServiceImpl: AI 서비스 구현
 * - PDFProcessingService: PDF 처리 서비스
 * 
 * [사용 시나리오]
 * - ContractAutoFillController: 계약서 자동 채우기 요청
 * - 사용자가 PDF 업로드 또는 직접 입력한 내용을 기반으로 계약 정보 초안 생성
 * 
 * ============================================================================
 */
public interface ContractAutoFillService {

    /**
     * 계약 주요 정보 초안 생성
     * 
     * [기능]
     * - PDF 계약서, 사용자 입력 내용, 프로젝트/프리랜서 정보를 종합하여
     *   계약 주요 정보 초안을 자동으로 생성
     * - AI를 활용하여 계약서 내용을 분석하고 구조화된 정보 추출
     * 
     * [입력 소스]
     * - PDF 계약서: 텍스트 추출 후 AI 분석
     * - 사용자 입력: 직접 작성한 계약 내용
     * - 프로젝트 정보: 프로젝트 제목, 설명, 예산 등
     * - 프리랜서 정보: 이름, 이메일, 연락처 등
     * 
     * [출력]
     * - ContractAutoFillDTO: 계약 주요 정보 초안
     *   * 계약 기간 (시작일, 종료일)
     *   * 총 예산
     *   * 결제 방식 (MILESTONE 또는 FIXED)
     *   * 마일스톤 정보 (MILESTONE 타입일 때)
     *   * 계약 목적, 업무 범위, 결과물 정의 등
     * 
     * [책임 분리]
     * - 다른 도메인 정보는 Controller에서 조회하여 전달받음
     * - Service는 contract 도메인만 담당하며 다른 도메인을 침범하지 않음
     * - PDF 처리, AI 호출은 구현체에서 수행
     * 
     * [파라미터]
     * @param pdfFile 업로드된 PDF 계약서 (없을 수도 있음, null 가능)
     *                - PDF가 있으면 텍스트 추출 후 AI 분석
     *                - PDF가 없으면 사용자 입력과 프로젝트 정보만 사용
     * 
     * @param manualText 사용자가 직접 작성한 계약 내용 (없을 수도 있음, null 가능)
     *                   - PDF가 없을 때 주요 입력 소스
     *                   - PDF가 있어도 보완 정보로 사용 가능
     * 
     * @param project 프로젝트 정보 (project 도메인의 ProjectsVO)
     *                - Controller에서 조회하여 전달
     *                - 프로젝트 제목, 설명, 예산, 기간 등 포함
     * 
     * @param freelancerUser 프리랜서 사용자 정보 (user 도메인의 UserVO)
     *                       - Controller에서 조회하여 전달
     *                       - 이름, 이메일, 연락처 등 포함
     * 
     * @param freelancerProfile 프리랜서 프로필 정보 (user 도메인의 FreelancerProfileVO, null 가능)
     *                          - Controller에서 조회하여 전달
     *                          - 닉네임, 소개, 포트폴리오 등 포함
     * 
     * @return 계약 주요 정보 초안 DTO (ContractAutoFillDTO)
     *         - 계약 기간, 예산, 결제 방식, 마일스톤 등 포함
     *         - AI가 추출한 정보와 사용자 입력을 종합한 결과
     */
    ContractAutoFillDTO generateDraft(
            File pdfFile,
            String manualText,
            ProjectsVO project,
            UserVO freelancerUser,
            FreelancerProfileVO freelancerProfile
    );
}
