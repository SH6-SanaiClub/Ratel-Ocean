<%@ page contentType="text/html;charset=UTF-8" %>
<!--
    ═══════════════════════════════════════════════════════════════════════
    registerAccount.jsp - 계좌 등록 페이지
    ═══════════════════════════════════════════════════════════════════════
    
    [설명]
    프리랜서가 수익금을 받기 위해 계좌 정보를 등록하는 페이지입니다.
    프로젝트 완료 후 용역비를 정산받기 위해서는 반드시 계좌 정보가 필요합니다.
    
    [연결되는 컨트롤러]
    AccountController.java > registerAccount() 메서드
    @GetMapping({"/accounts/register", "/accounts/register.do"})
    @RequestMapping("/settings")
    
    [페이지 위치]
    설정 → 결제 관리 → 계좌 등록
    경로: /settings/accounts/register.do
    
    [입력 필드]
    1. 계좌 소유자명
       - 은행에 등록된 실명
       - 예: "홍길동"
    
    2. 은행 선택
       - 국내 주요 은행 (국민, 우리, 신한, 농협 등)
       - 드롭다운 메뉴
    
    3. 계좌 번호
       - 하이픈 없이 숫자만 입력
       - 예: "12345678901234"
    
    4. 계좌 확인
       - 입력한 계좌 정보 재확인
       - 오타 방지
    
    [보안 고려사항]
    - HTTPS 통신 필수 (실제 배포 시)
    - 계좌 정보는 서버에 암호화되어 저장
    - 민감한 정보는 마스킹 처리
    - 계좌 변경 시 재인증 요구
    
    [정산 프로세스]
    1. 프로젝트 완료 요청
    2. 클라이언트 승인 대기
    3. 용역비 계산 (수수료 제외)
    4. 등록된 계좌로 송금
    5. 사용자에게 메일/SMS 알림
    
    [향후 개선 사항]
    1. 여러 계좌 등록 지원
    2. 해외 계좌 지원 (국제 송금)
    3. 가상계좌/전자지갑 지원
    4. 자동 정산 설정 (주/월 단위)
    5. 정산 기록 조회
    
    @version 1.0 (2026-01-13)
-->
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>계좌이체 등록 - FreelanceHub</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/account.css">
</head>
<body>
<!-- 상단 헤더 -->
<header class="site-header">
    <div class="container header-inner">
        <a class="logo" href="${pageContext.request.contextPath}/">
            <img src="${pageContext.request.contextPath}/resources/images/freelancehub-logo.svg" alt="FreelanceHub 로고">
        </a>
        <nav class="top-nav">
            <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
            <a href="${pageContext.request.contextPath}/projects">Projects</a>
            <a href="${pageContext.request.contextPath}/contracts">Contracts</a>
            <a href="${pageContext.request.contextPath}/settlements">Settlements</a>
            <button class="btn primary small">Post Project</button>
            <a href="#" class="profile">프로필</a>
        </nav>
    </div>
</header>

<!-- 메인 콘텐츠 -->
<main class="account-page">
    <div class="container">
        <!-- 현재 페이지 경로 (breadcrumb) -->
        <div class="breadcrumb">설정 &gt; 결제 관리 &gt; 계좌 등록</div>
        <h1 class="page-title">계좌이체 등록</h1>
        <p class="page-sub">안전한 에스크로 거래를 위해 출금 계좌를 등록해주세요.</p>

        <div class="info-box">
            <div class="bar"></div>
            <div class="info-inner">
                <svg class="info-icon" viewBox="0 0 24 24" width="20" height="20" aria-hidden="true"><path d="M12 2a10 10 0 100 20 10 10 0 000-20zm1 15h-2v-2h2v2zm0-4h-2V6h2v7z" fill="currentColor"></path></svg>
                <div class="info-text">
                    아직 결제되지 않았습니다.
                    지금 입력하시는 정보는 계약 체결 시 진행될 에스크로 결제를 위한 사전 등록 절차입니다.
                    실제 출금은 프로젝트 계약이 확정된 후 승인을 거쳐 진행됩니다.
                </div>
            </div>
        </div>

        <section class="card account-card">
            <form id="account-form" class="account-form" method="post" action="#" novalidate>
                <div class="form-row">
                    <label class="label">이 계좌는 누구 명의인가요?</label>
                    <div class="radio-row">
                        <label><input type="radio" name="ownerType" value="personal" checked> 개인</label>
                        <label><input type="radio" name="ownerType" value="business"> 사업자</label>
                    </div>
                </div>

                <div id="business-type" class="form-row hidden">
                    <label class="label">사업자 유형을 선택해주세요</label>
                    <div class="radio-row">
                        <label><input type="radio" name="bizType" value="sole"> 개인사업자</label>
                        <label><input type="radio" name="bizType" value="corporate"> 법인사업자</label>
                    </div>
                </div>

                <div class="form-row">
                    <label class="label" for="bank_name">은행명</label>
                    <input id="bank_name" name="bank_name" class="input" placeholder="은행명을 입력해주세요 (예: 국민은행)">
                </div>

                <div class="form-row">
                    <label class="label" for="account_number">계좌번호</label>
                    <input id="account_number" name="account_number" class="input" placeholder="- 없이 숫자만 입력해주세요" inputmode="numeric">
                </div>

                <div class="form-row">
                    <label class="label" for="account_holder">예금주명</label>
                    <input id="account_holder" name="account_holder" class="input" placeholder="통장에 표시된 예금주명을 입력하세요">
                </div>

                <div id="verification" class="verification-block">
                    <div class="verify-title">인증 정보</div>
                    <div id="personal-verify" class="verify-group">
                        <div class="row-inline">
                            <label class="label small">이름</label>
                            <input name="ver_name" class="input small" placeholder="예: 홍길동">
                            <label class="label small">생년월일 (6자리)</label>
                            <input name="ver_bday" class="input small" placeholder="YYMMDD" maxlength="6" inputmode="numeric">
                        </div>
                    </div>

                    <div id="sole-verify" class="verify-group hidden">
                        <div class="row-inline">
                            <label class="label small">사업자명</label>
                            <input name="ver_bus_name" class="input small" placeholder="사업자명을 입력하세요">
                            <label class="label small">사업자등록번호</label>
                            <input name="ver_bus_no" class="input small" placeholder="숫자만 입력" inputmode="numeric">
                        </div>
                    </div>

                    <div id="corp-verify" class="verify-group hidden">
                        <div class="row-inline">
                            <label class="label small">법인명</label>
                            <input name="ver_corp_name" class="input small" placeholder="법인명을 입력하세요">
                            <label class="label small">사업자등록번호</label>
                            <input name="ver_corp_no" class="input small" placeholder="숫자만 입력" inputmode="numeric">
                        </div>
                        <div class="note">법인 명의 계좌만 등록 가능합니다.</div>
                    </div>
                </div>

                <div class="security-note">
                    <div class="shield">
                        <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true"><path d="M12 2l7 3v5c0 5-3.58 9.74-7 12-3.42-2.26-7-7-7-12V5l7-3z" fill="currentColor"/></svg>
                    </div>
                    <div class="text">입력하신 정보는 SSL 암호화되어 안전하게 전송됩니다.</div>
                </div>

                <div class="actions-row">
                    <button type="button" class="btn secondary">계좌 인증</button>
                    <button type="button" class="btn primary">등록 완료 →</button>
                </div>

            </form>
        </section>

    </div>
</main>

<footer class="site-footer">
    <div class="container">© 2024 Freelance Platform. All rights reserved.</div>
</footer>

<script src="${pageContext.request.contextPath}/resources/js/account.js"></script>
</body>
</html>