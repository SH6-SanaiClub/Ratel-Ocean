<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ratel-Ocean - 프리랜서 IT 개발 플랫폼</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/landing.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700;900&display=swap" rel="stylesheet">
</head>
<body>
<!-- Header -->
<header class="header">
    <div class="container">
        <div class="header-content">
            <div class="logo">
                <a href="${pageContext.request.contextPath}/">
                    <span class="logo-icon">🦦</span>
                    <span class="logo-text">Ratel-Ocean</span>
                </a>
            </div>
            <nav class="nav">
                <ul class="nav-list">
                    <li><a href="#features">기능 소개</a></li>
                    <li><a href="#benefits">예제 더보드</a></li>
                    <li><a href="#projects">프로젝트</a></li>
                    <li><a href="#pricing">도움말</a></li>
                </ul>
            </nav>
            <div class="header-actions">
                <a href="${pageContext.request.contextPath}/login" class="btn btn-outline">로그인</a>
                <a href="${pageContext.request.contextPath}/join/select-role" class="btn btn-primary">무료 시작하기</a>
            </div>
        </div>
    </div>
</header>

<!-- Hero Section -->
<section class="hero">
    <div class="container">
        <div class="hero-content">
            <div class="hero-text">
                <span class="hero-badge">VISUAL IDENTITY SYSTEM</span>
                <h1 class="hero-title">
                    프로젝트 관리부터<br>
                    계약, 정산, 자산화까지<br>
                    한번에 해결하세요.
                </h1>
                <p class="hero-description">
                    프리랜서 전문 프리랜서를 위한 통합 시스템. 일상적 업무를<br>
                    자동으로 관리하고, 비즈니스 거래에서의 안전을 보장하며,<br>
                    프로젝트 경력을 관리하세요.
                </p>
                <div class="hero-actions">
                    <a href="${pageContext.request.contextPath}/join/select-role?userType=FREELANCER" class="btn btn-primary btn-lg">
                        프리랜서 시작하기
                    </a>
                    <a href="${pageContext.request.contextPath}/join/select-role?userType=CLIENT" class="btn btn-secondary btn-lg">
                        클라이언트 시작하기
                    </a>
                </div>
                <div class="hero-features">
                    <div class="feature-item">
                        <span class="feature-icon">✓</span>
                        <span class="feature-text">무료 프로젝트 등록</span>
                    </div>
                    <div class="feature-item">
                        <span class="feature-icon">✓</span>
                        <span class="feature-text">안전 정산 솔루션</span>
                    </div>
                </div>
            </div>
            <div class="hero-image">
                <div class="dashboard-preview">
                    <div class="dashboard-header">
                        <span class="dashboard-dot"></span>
                        <span class="dashboard-dot"></span>
                        <span class="dashboard-dot"></span>
                    </div>
                    <div class="dashboard-content">
                        <div class="chart-section">
                            <h3>수익 대시보드</h3>
                            <div class="chart-bars">
                                <div class="bar" style="height: 40%"></div>
                                <div class="bar" style="height: 60%"></div>
                                <div class="bar" style="height: 45%"></div>
                                <div class="bar" style="height: 80%"></div>
                                <div class="bar" style="height: 55%"></div>
                                <div class="bar" style="height: 70%"></div>
                            </div>
                        </div>
                        <div class="progress-section">
                            <h3>프로젝트 진행률</h3>
                            <div class="progress-item">
                                <span>프로젝트 A</span>
                                <div class="progress-bar">
                                    <div class="progress-fill" style="width: 85%"></div>
                                </div>
                            </div>
                            <div class="progress-item">
                                <span>프로젝트 B</span>
                                <div class="progress-bar">
                                    <div class="progress-fill" style="width: 60%"></div>
                                </div>
                            </div>
                            <div class="progress-item">
                                <span>프로젝트 C</span>
                                <div class="progress-bar">
                                    <div class="progress-fill" style="width: 40%"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Partners Section -->
<section class="partners">
    <div class="container">
        <p class="partners-title">우리의 파트너들을 만나보세요. 여러분.</p>
        <div class="partners-grid">
            <div class="partner-logo">ACME Corp</div>
            <div class="partner-logo">Starkind</div>
            <div class="partner-logo">Globex</div>
            <div class="partner-logo">Soylent</div>
            <div class="partner-logo">Umbrella</div>
        </div>
    </div>
</section>

<!-- Core Values Section -->
<section class="values">
    <div class="container">
        <h2 class="section-title">전문가의 안정과 성장을 위해 설계되었습니다</h2>
        <p class="section-subtitle">프리랜서와 전문직이 안전하게 프로젝트 수주 및 관리하면서 수익을 보장을 지원을 중심으로 출시되었습니다.</p>

        <div class="values-grid">
            <div class="value-card">
                <div class="value-icon">
                    <svg width="48" height="48" viewBox="0 0 48 48" fill="none">
                        <path d="M24 4L6 14V22C6 33 13.5 43 24 44C34.5 43 42 33 42 22V14L24 4Z" stroke="#1F7A8C" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                        <path d="M18 24L22 28L30 20" stroke="#1F7A8C" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                </div>
                <h3 class="value-title">게임 리스크 감소</h3>
                <p class="value-description">
                    안전하게 업무를 보호 받아 안정된 업계에서 거래를 하세요.
                    프로젝트 보호금 제도와 정산되어서 안전하고 효과적으로 관리됩니다.
                </p>
                <ul class="value-list">
                    <li>프로젝트 커리 보호금</li>
                    <li>실전 근본 보호</li>
                    <li>실천 모범 사례</li>
                </ul>
            </div>

            <div class="value-card">
                <div class="value-icon">
                    <svg width="48" height="48" viewBox="0 0 48 48" fill="none">
                        <circle cx="24" cy="24" r="18" stroke="#1F7A8C" stroke-width="2"/>
                        <path d="M24 12V24L30 30" stroke="#1F7A8C" stroke-width="2" stroke-linecap="round"/>
                    </svg>
                </div>
                <h3 class="value-title">현금 흐름 안정화</h3>
                <p class="value-description">
                    프리랜서 수수를 계약하면 발생되어 정산과 센터 보호
                    관리를 시스템으로 협력해서 깨끗한 허위 업무를 조정해 자동으로 산고는 모습입니다.
                </p>
                <ul class="value-list">
                    <li>수입 발행을 안전</li>
                    <li>근본부터 정산을 수익</li>
                    <li>교부된 보호 사업비</li>
                </ul>
            </div>

            <div class="value-card">
                <div class="value-icon">
                    <svg width="48" height="48" viewBox="0 0 48 48" fill="none">
                        <path d="M40 18L24 6L8 18V38C8 39.1046 8.89543 40 10 40H38C39.1046 40 40 39.1046 40 38V18Z" stroke="#1F7A8C" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                        <path d="M18 40V24H30V40" stroke="#1F7A8C" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                </div>
                <h3 class="value-title">경력 자산화</h3>
                <p class="value-description">
                    프리랜서 수행한 프로젝트를 단순한 일사적 가치를 프로모트 하세요.
                    실제 수개 경험을 가자 시장에서 방향한 거위 수수를 수액합니다.
                </p>
                <ul class="value-list">
                    <li>정보와 클로저 이력</li>
                    <li>실채 추율 제공면</li>
                    <li>디지털 링터 수익</li>
                </ul>
            </div>
        </div>
    </div>
</section>

<!-- Features Section -->
<section class="features" id="features">
    <div class="container">
        <h2 class="section-title">왜 Ratel-Ocean를 선택해야 할까요?</h2>
        <p class="section-subtitle">프리랜서 커뮤니티를 중심으로 방송된 중심의 수이로 관리방식이 실현 방식을 것으로 제공됩니다.</p>

        <div class="features-grid">
            <div class="feature-card">
                <div class="feature-icon-large">
                    <svg width="64" height="64" viewBox="0 0 64 64" fill="none">
                        <rect x="8" y="8" width="48" height="48" rx="8" stroke="#1F7A8C" stroke-width="2"/>
                        <path d="M28 32L32 36L40 28" stroke="#1F7A8C" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                </div>
                <h3 class="feature-title">안전한 상거 거래</h3>
                <p class="feature-description">
                    다양한 업종을 추종은 통합 에어컨이 생활에서
                    필아터 행사자로 근성이 안내합의 관리 수치를
                    보호하게 거래를 합니다.
                </p>
            </div>

            <div class="feature-card">
                <div class="feature-icon-large">
                    <svg width="64" height="64" viewBox="0 0 64 64" fill="none">
                        <path d="M32 8L8 20V32C8 45.255 17.255 57.255 32 60C46.745 57.255 56 45.255 56 32V20L32 8Z" stroke="#1F7A8C" stroke-width="2"/>
                        <circle cx="32" cy="32" r="8" stroke="#1F7A8C" stroke-width="2"/>
                    </svg>
                </div>
                <h3 class="feature-title">편한 세금 & 정산</h3>
                <p class="feature-description">
                    세금 산출 계산을 환한하실 수 있어서 일저 근본을 보장해 배부 정삭 방송 프로필
                    낼해볼 수 세무 관리를 경험해시고 근접합니다.
                </p>
            </div>

            <div class="feature-card">
                <div class="feature-icon-large">
                    <svg width="64" height="64" viewBox="0 0 64 64" fill="none">
                        <circle cx="32" cy="20" r="8" stroke="#1F7A8C" stroke-width="2"/>
                        <path d="M16 56C16 46.059 23.163 38 32 38C40.837 38 48 46.059 48 56" stroke="#1F7A8C" stroke-width="2" stroke-linecap="round"/>
                    </svg>
                </div>
                <h3 class="feature-title">간편한 경력 관리</h3>
                <p class="feature-description">
                    보호 평가 프로젝트를 어떤 여부는 관리하고
                    전공들 취급해 선택해 타지털 포트폴리오를
                    수작혀하여 합니다.
                </p>
            </div>
        </div>
    </div>
</section>

<!-- Projects Preview Section -->
<section class="projects" id="projects">
    <div class="container">
        <h2 class="section-title">프로젝트 미리보기</h2>
        <p class="section-subtitle">실시간으로 등록된 마을라이 프로젝트를 확인해보세요.</p>

        <div class="projects-tabs">
            <button class="tab-button active" data-tab="all">상세정보</button>
            <button class="tab-button" data-tab="web">후기</button>
            <button class="tab-button" data-tab="mobile">팀원모집</button>
        </div>

        <div class="projects-grid">
            <div class="project-card">
                <div class="project-header">
                    <div class="project-meta">
                        <span class="project-category">웹 개발</span>
                        <span class="project-status verified">Verified</span>
                    </div>
                </div>
                <h3 class="project-title">프로젝트 표준 계약서</h3>
                <p class="project-description">
                    Ratel-Ocean에서 제공하는 법적 등기가 보완되어 프로젝트 계약서를 사용합니다.
                    한번 클릭으로 검증되어 사용됩니다.
                </p>
                <div class="project-footer">
                    <div class="project-amount">
                        <span class="amount-label">모집금액</span>
                        <span class="amount-value">₩2,450,000</span>
                        <span class="amount-change">상승 +12%</span>
                    </div>
                    <div class="project-deadline">
                        <span class="deadline-label">지원 마감일</span>
                        <span class="deadline-value">4건</span>
                        <span class="deadline-date">2일 뒤 마감</span>
                    </div>
                </div>
                <div class="project-tags">
                    <span class="tag">React</span>
                    <span class="tag">Node.js</span>
                    <span class="tag">MongoDB</span>
                </div>
            </div>

            <div class="project-card">
                <div class="project-header">
                    <div class="project-meta">
                        <span class="project-category">모바일 앱</span>
                        <span class="project-status verified">Verified</span>
                    </div>
                </div>
                <h3 class="project-title">E-커머스 모바일 앱 개발</h3>
                <p class="project-description">
                    고객 맞춤형 쇼핑 경험을 제공하는 모바일 애플리케이션을 개발합니다.
                    iOS와 Android 모두 지원합니다.
                </p>
                <div class="project-footer">
                    <div class="project-amount">
                        <span class="amount-label">모집금액</span>
                        <span class="amount-value">₩3,800,000</span>
                        <span class="amount-change">상승 +8%</span>
                    </div>
                    <div class="project-deadline">
                        <span class="deadline-label">지원 마감일</span>
                        <span class="deadline-value">7건</span>
                        <span class="deadline-date">5일 뒤 마감</span>
                    </div>
                </div>
                <div class="project-tags">
                    <span class="tag">Flutter</span>
                    <span class="tag">Firebase</span>
                    <span class="tag">UI/UX</span>
                </div>
            </div>

            <div class="project-card">
                <div class="project-header">
                    <div class="project-meta">
                        <span class="project-category">백엔드</span>
                        <span class="project-status verified">Verified</span>
                    </div>
                </div>
                <h3 class="project-title">대용량 데이터 처리 시스템</h3>
                <p class="project-description">
                    실시간 데이터 분석 및 처리를 위한 백엔드 시스템 구축 프로젝트입니다.
                    확장 가능한 아키텍처가 필요합니다.
                </p>
                <div class="project-footer">
                    <div class="project-amount">
                        <span class="amount-label">모집금액</span>
                        <span class="amount-value">₩5,200,000</span>
                        <span class="amount-change">상승 +15%</span>
                    </div>
                    <div class="project-deadline">
                        <span class="deadline-label">지원 마감일</span>
                        <span class="deadline-value">3건</span>
                        <span class="deadline-date">7일 뒤 마감</span>
                    </div>
                </div>
                <div class="project-tags">
                    <span class="tag">Java</span>
                    <span class="tag">Spring Boot</span>
                    <span class="tag">MySQL</span>
                </div>
            </div>
        </div>

        <div class="projects-cta">
            <a href="${pageContext.request.contextPath}/projects" class="btn btn-outline btn-lg">모든 프로젝트 보기</a>
        </div>
    </div>
</section>

<!-- CTA Section -->
<section class="cta">
    <div class="container">
        <div class="cta-content">
            <h2 class="cta-title">프리랜서 커리어를 한 단계 업그레이드하세요</h2>
            <p class="cta-description">
                이제 수요 협력을 전문 직후를 통해 작업. 정산, 경력을 서로 Ratel-Ocean에서 건파하고 있습니다.
            </p>
            <div class="cta-actions">
                <a href="${pageContext.request.contextPath}/join/select-role" class="btn btn-primary btn-lg">지금 무료로 시작하기</a>
                <a href="#features" class="btn btn-outline-white btn-lg">도움 받기</a>
            </div>
        </div>
    </div>
</section>

<!-- Footer -->
<footer class="footer">
    <div class="container">
        <div class="footer-content">
            <div class="footer-brand">
                <div class="logo">
                    <span class="logo-icon">🦦</span>
                    <span class="logo-text">Ratel-Ocean</span>
                </div>
                <p class="footer-description">
                    일정한 수주를 투명한 규모를 스랭 주운한 프로젝트를 선택할
                    거리사항부터 받침돼 모호 근본수 관리수합니다.
                </p>
                <div class="social-links">
                    <a href="#" aria-label="Facebook">f</a>
                    <a href="#" aria-label="Twitter">t</a>
                </div>
            </div>

            <div class="footer-links">
                <div class="footer-column">
                    <h4>제품</h4>
                    <ul>
                        <li><a href="#">프리 계약</a></li>
                        <li><a href="#">포트 투적</a></li>
                        <li><a href="#">운영일</a></li>
                    </ul>
                </div>

                <div class="footer-column">
                    <h4>회사</h4>
                    <ul>
                        <li><a href="#">회사 소개</a></li>
                        <li><a href="#">채용</a></li>
                        <li><a href="#">문의하기</a></li>
                    </ul>
                </div>

                <div class="footer-column">
                    <h4>법적 고지</h4>
                    <ul>
                        <li><a href="#">이용약관</a></li>
                        <li><a href="#">개인정보처리방침</a></li>
                    </ul>
                </div>
            </div>
        </div>

        <div class="footer-bottom">
            <p>&copy; 2024 Ratel-Ocean. All rights reserved.</p>
        </div>
    </div>
</footer>

<script src="${pageContext.request.contextPath}/resources/js/landing.js"></script>
</body>
</html>
