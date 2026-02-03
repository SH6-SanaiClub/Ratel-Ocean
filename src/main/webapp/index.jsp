<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ratel-Ocean - 프리랜서 IT 개발 플랫폼</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/landing.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700;900&display=swap" rel="stylesheet">
</head>
<body>
<header class="header">
    <div class="container">
        <div class="header-content">
            <div class="logo">
                <a href="${pageContext.request.contextPath}/">

                    <span class="logo-text">RatelOcean</span>
                </a>
            </div>
            <nav class="nav">
                <ul class="nav-list">
                    <li><a href="#features">기능 소개</a></li>
                    <li><a href="#benefits">예시 대시보드</a></li>
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

<section class="hero">
    <div class="container">
        <div class="hero-content">
            <div class="hero-text">
                <span class="hero-badge">VISUAL IDENTITY SYSTEM</span>
                <h1 class="hero-title">
                    프로젝트 관리부터<br>
                    계약, 정산, 경력 관리<br>
                    한 번에 해결하세요.
                </h1>
                <p class="hero-description">
                    프리랜서와 클라이언트를 위한 통합 플랫폼.<br>
                    프로젝트 운영, 계약/정산 흐름을 체계화하고<br>
                    수행 이력을 경력으로 깔끔하게 관리할 수 있습니다.
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
                        <span class="feature-text">안전한 정산 프로세스</span>
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

<section class="partners">
    <div class="container">
        <p class="partners-title">함께 성장하는 파트너들과 안전한 프로젝트 경험을 만들어갑니다.</p>
        <div class="partners-grid">
            <div class="partner-logo">ACME Corp</div>
            <div class="partner-logo">Starkind</div>
            <div class="partner-logo">Globex</div>
            <div class="partner-logo">Soylent</div>
            <div class="partner-logo">Umbrella</div>
        </div>
    </div>
</section>

<section class="values" id="benefits">
    <div class="container">
        <h2 class="section-title">전문가의 안정과 성장을 위해 설계되었습니다</h2>
        <p class="section-subtitle">프리랜서와 클라이언트가 신뢰 기반으로 협업할 수 있도록, 핵심 흐름을 한 곳에 모았습니다.</p>

        <div class="values-grid">
            <div class="value-card">
                <div class="value-icon">
                    <svg width="48" height="48" viewBox="0 0 48 48" fill="none">
                        <path d="M24 4L6 14V22C6 33 13.5 43 24 44C34.5 43 42 33 42 22V14L24 4Z" stroke="#173160" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                        <path d="M18 24L22 28L30 20" stroke="#173160" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                </div>
                <h3 class="value-title">거래 리스크 감소</h3>
                <p class="value-description">
                    프로젝트 진행 과정에서 생길 수 있는 리스크를 줄이고,
                    계약과 산출물 흐름을 체계적으로 관리할 수 있습니다.
                </p>
                <ul class="value-list">
                    <li>명확한 계약 흐름</li>
                    <li>진행 상태 투명화</li>
                    <li>분쟁 예방 가이드</li>
                </ul>
            </div>

            <div class="value-card">
                <div class="value-icon">
                    <svg width="48" height="48" viewBox="0 0 48 48" fill="none">
                        <circle cx="24" cy="24" r="18" stroke="#173160" stroke-width="2"/>
                        <path d="M24 12V24L30 30" stroke="#173160" stroke-width="2" stroke-linecap="round"/>
                    </svg>
                </div>
                <h3 class="value-title">현금 흐름 안정화</h3>
                <p class="value-description">
                    정산 상태와 거래 내역을 한눈에 확인하고,
                    업무-정산 간 공백을 최소화할 수 있도록 돕습니다.
                </p>
                <ul class="value-list">
                    <li>정산 내역 일원화</li>
                    <li>예상 수익 가시화</li>
                    <li>거래 기록 자동 보관</li>
                </ul>
            </div>

            <div class="value-card">
                <div class="value-icon">
                    <svg width="48" height="48" viewBox="0 0 48 48" fill="none">
                        <path d="M40 18L24 6L8 18V38C8 39.1046 8.89543 40 10 40H38C39.1046 40 40 39.1046 40 38V18Z" stroke="#173160" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                        <path d="M18 40V24H30V40" stroke="#173160" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                </div>
                <h3 class="value-title">경력 자산화</h3>
                <p class="value-description">
                    수행한 프로젝트 이력을 깔끔하게 정리하고,
                    다음 프로젝트 수주에 활용할 수 있도록 지원합니다.
                </p>
                <ul class="value-list">
                    <li>프로젝트 히스토리 관리</li>
                    <li>성과/리뷰 축적</li>
                    <li>포트폴리오 연결</li>
                </ul>
            </div>
        </div>
    </div>
</section>

<section class="features" id="features">
    <div class="container">
        <h2 class="section-title">왜 Ratel-Ocean을 선택해야 할까요?</h2>
        <p class="section-subtitle">협업 과정의 번거로움을 줄이고, 핵심에 집중할 수 있도록 기능을 설계했습니다.</p>

        <div class="features-grid">
            <div class="feature-card">
                <div class="feature-icon-large">
                    <svg width="64" height="64" viewBox="0 0 64 64" fill="none">
                        <rect x="8" y="8" width="48" height="48" rx="8" stroke="#173160" stroke-width="2"/>
                        <path d="M28 32L32 36L40 28" stroke="#173160" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                </div>
                <h3 class="feature-title">안전한 프로젝트 운영</h3>
                <p class="feature-description">
                    진행 상태, 지원자, 계약까지 하나의 흐름으로 관리해
                    놓치는 일이 없도록 도와드립니다.
                </p>
            </div>

            <div class="feature-card">
                <div class="feature-icon-large">
                    <svg width="64" height="64" viewBox="0 0 64 64" fill="none">
                        <path d="M32 8L8 20V32C8 45.255 17.255 57.255 32 60C46.745 57.255 56 45.255 56 32V20L32 8Z" stroke="#173160" stroke-width="2"/>
                        <circle cx="32" cy="32" r="8" stroke="#173160" stroke-width="2"/>
                    </svg>
                </div>
                <h3 class="feature-title">정산 & 거래 내역 관리</h3>
                <p class="feature-description">
                    정산 흐름과 거래 내역을 한곳에서 확인하고,
                    기록을 체계적으로 보관할 수 있습니다.
                </p>
            </div>

            <div class="feature-card">
                <div class="feature-icon-large">
                    <svg width="64" height="64" viewBox="0 0 64 64" fill="none">
                        <circle cx="32" cy="20" r="8" stroke="#173160" stroke-width="2"/>
                        <path d="M16 56C16 46.059 23.163 38 32 38C40.837 38 48 46.059 48 56" stroke="#173160" stroke-width="2" stroke-linecap="round"/>
                    </svg>
                </div>
                <h3 class="feature-title">간편한 경력/리뷰 관리</h3>
                <p class="feature-description">
                    프로젝트 경험과 리뷰를 모아,
                    신뢰를 쌓고 다음 기회를 더 쉽게 만드세요.
                </p>
            </div>
        </div>
    </div>
</section>

<section class="projects" id="projects">
    <div class="container">
        <h2 class="section-title">프로젝트 미리보기</h2>
        <p class="section-subtitle">실제로 등록되는 프로젝트 형태를 미리 확인해보세요.</p>

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
                    계약 과정에서 필요한 핵심 항목을 표준화해,
                    빠르고 안전하게 계약을 진행할 수 있습니다.
                </p>
                <div class="project-footer">
                    <div class="project-amount">
                        <span class="amount-label">모집금액</span>
                        <span class="amount-value">₩2,450,000</span>
                        <span class="amount-change">상승 +12%</span>
                    </div>
                    <div class="project-deadline">
                        <span class="deadline-label">지원 현황</span>
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
                    고객 맞춤형 쇼핑 경험을 제공하는 모바일 애플리케이션 개발 프로젝트입니다.
                    iOS와 Android 모두 지원합니다.
                </p>
                <div class="project-footer">
                    <div class="project-amount">
                        <span class="amount-label">모집금액</span>
                        <span class="amount-value">₩3,800,000</span>
                        <span class="amount-change">상승 +8%</span>
                    </div>
                    <div class="project-deadline">
                        <span class="deadline-label">지원 현황</span>
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
                        <span class="deadline-label">지원 현황</span>
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

<section class="cta">
    <div class="container">
        <div class="cta-content">
            <h2 class="cta-title">프리랜서 커리어를 한 단계 업그레이드하세요</h2>
            <p class="cta-description">
                프로젝트 운영부터 정산, 경력 관리까지.<br>
                Ratel-Ocean에서 더 간편하고 안전하게 시작할 수 있습니다.
            </p>
            <div class="cta-actions">
                <a href="${pageContext.request.contextPath}/join/select-role" class="btn btn-primary btn-lg">지금 무료로 시작하기</a>
                <a href="#features" class="btn btn-outline-white btn-lg">기능 더 보기</a>
            </div>
        </div>
    </div>
</section>

<footer class="footer">
    <div class="container">
        <div class="footer-content">
            <div class="footer-brand">
                <div class="logo">
                    <span class="logo-icon">🦦</span>
                    <span class="logo-text">Ratel-Ocean</span>
                </div>
                <p class="footer-description">
                    프리랜서와 클라이언트를 연결하고,
                    계약/정산/경력 관리를 더 안전하고 간편하게 만드는 플랫폼입니다.
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
                        <li><a href="#">프로젝트 관리</a></li>
                        <li><a href="#">계약/정산</a></li>
                        <li><a href="#">경력 관리</a></li>
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

<script src="${pageContext.request.contextPath}/js/landing.js"></script>
</body>
</html>
