/**
 * Ratel-Ocean Landing Page JavaScript
 * 탭 전환, 스크롤 애니메이션, 인터랙션 효과
 */

(function() {
    'use strict';

    // DOM이 로드되면 실행
    document.addEventListener('DOMContentLoaded', function() {
        initTabNavigation();
        initSmoothScroll();
        initScrollAnimations();
        initHeaderScroll();
    });

    /**
     * 탭 네비게이션 초기화
     */
    function initTabNavigation() {
        const tabButtons = document.querySelectorAll('.tab-button');

        tabButtons.forEach(button => {
            button.addEventListener('click', function() {
                // 모든 탭 버튼에서 active 클래스 제거
                tabButtons.forEach(btn => btn.classList.remove('active'));

                // 클릭된 버튼에 active 클래스 추가
                this.classList.add('active');

                // 탭 전환 애니메이션
                const projectsGrid = document.querySelector('.projects-grid');
                if (projectsGrid) {
                    projectsGrid.style.opacity = '0';
                    projectsGrid.style.transform = 'translateY(20px)';

                    setTimeout(() => {
                        projectsGrid.style.transition = 'all 0.5s ease';
                        projectsGrid.style.opacity = '1';
                        projectsGrid.style.transform = 'translateY(0)';
                    }, 100);
                }
            });
        });
    }

    /**
     * 부드러운 스크롤 초기화
     */
    function initSmoothScroll() {
        const links = document.querySelectorAll('a[href^="#"]');

        links.forEach(link => {
            link.addEventListener('click', function(e) {
                const href = this.getAttribute('href');

                // 빈 해시나 페이지 최상단(#)은 무시
                if (href === '#' || href === '') {
                    return;
                }

                const target = document.querySelector(href);

                if (target) {
                    e.preventDefault();

                    const headerHeight = document.querySelector('.header').offsetHeight;
                    const targetPosition = target.offsetTop - headerHeight - 20;

                    window.scrollTo({
                        top: targetPosition,
                        behavior: 'smooth'
                    });
                }
            });
        });
    }

    /**
     * 스크롤 시 요소 애니메이션
     */
    function initScrollAnimations() {
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -100px 0px'
        };

        const observer = new IntersectionObserver(function(entries) {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }
            });
        }, observerOptions);

        // 애니메이션을 적용할 요소들
        const animatedElements = document.querySelectorAll(
            '.value-card, .feature-card, .project-card'
        );

        animatedElements.forEach(el => {
            el.style.opacity = '0';
            el.style.transform = 'translateY(30px)';
            el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
            observer.observe(el);
        });
    }

    /**
     * 헤더 스크롤 효과
     */
    function initHeaderScroll() {
        const header = document.querySelector('.header');
        let lastScroll = 0;

        window.addEventListener('scroll', function() {
            const currentScroll = window.pageYOffset;

            // 스크롤 다운 시 헤더 배경 강조
            if (currentScroll > 100) {
                header.style.boxShadow = '0 4px 20px rgba(0, 0, 0, 0.15)';
            } else {
                header.style.boxShadow = '0 2px 10px rgba(0, 0, 0, 0.1)';
            }

            lastScroll = currentScroll;
        });
    }

    /**
     * 프로젝트 카드 호버 효과
     */
    function initProjectCardEffects() {
        const projectCards = document.querySelectorAll('.project-card');

        projectCards.forEach(card => {
            card.addEventListener('mouseenter', function() {
                this.style.transform = 'translateY(-8px) scale(1.02)';
            });

            card.addEventListener('mouseleave', function() {
                this.style.transform = 'translateY(0) scale(1)';
            });
        });
    }

    /**
     * 대시보드 차트 애니메이션
     */
    function initDashboardAnimation() {
        const bars = document.querySelectorAll('.bar');
        const progressFills = document.querySelectorAll('.progress-fill');

        // 차트 바 애니메이션
        bars.forEach((bar, index) => {
            setTimeout(() => {
                bar.style.transition = 'height 1s ease';
                const currentHeight = bar.style.height;
                bar.style.height = '0';

                setTimeout(() => {
                    bar.style.height = currentHeight;
                }, 100);
            }, index * 100);
        });

        // 프로그레스 바 애니메이션
        progressFills.forEach((fill, index) => {
            setTimeout(() => {
                const currentWidth = fill.style.width;
                fill.style.width = '0';

                setTimeout(() => {
                    fill.style.width = currentWidth;
                }, 100);
            }, index * 150);
        });
    }

    /**
     * 숫자 카운트업 애니메이션
     */
    function animateValue(element, start, end, duration) {
        let startTimestamp = null;
        const step = (timestamp) => {
            if (!startTimestamp) startTimestamp = timestamp;
            const progress = Math.min((timestamp - startTimestamp) / duration, 1);
            const value = Math.floor(progress * (end - start) + start);
            element.textContent = value.toLocaleString('ko-KR');
            if (progress < 1) {
                window.requestAnimationFrame(step);
            }
        };
        window.requestAnimationFrame(step);
    }

    /**
     * 페이지 로드 시 대시보드 애니메이션 실행
     */
    window.addEventListener('load', function() {
        setTimeout(initDashboardAnimation, 500);
    });

    /**
     * 모바일 메뉴 토글 (향후 확장용)
     */
    function initMobileMenu() {
        // 추후 햄버거 메뉴 구현 시 사용
        const mobileMenuButton = document.querySelector('.mobile-menu-button');
        const nav = document.querySelector('.nav');

        if (mobileMenuButton && nav) {
            mobileMenuButton.addEventListener('click', function() {
                nav.classList.toggle('active');
            });
        }
    }

    /**
     * 폼 유효성 검사 (향후 확장용)
     */
    function initFormValidation() {
        const forms = document.querySelectorAll('form');

        forms.forEach(form => {
            form.addEventListener('submit', function(e) {
                // 폼 유효성 검사 로직
                // 필요 시 구현
            });
        });
    }

    /**
     * 스크롤 진행률 표시 (선택사항)
     */
    function initScrollProgress() {
        const progressBar = document.createElement('div');
        progressBar.style.position = 'fixed';
        progressBar.style.top = '0';
        progressBar.style.left = '0';
        progressBar.style.height = '3px';
        progressBar.style.background = 'linear-gradient(90deg, #1F7A8C, #9AD2CB)';
        progressBar.style.zIndex = '9999';
        progressBar.style.transition = 'width 0.2s';
        document.body.appendChild(progressBar);

        window.addEventListener('scroll', function() {
            const windowHeight = document.documentElement.scrollHeight - document.documentElement.clientHeight;
            const scrolled = (window.pageYOffset / windowHeight) * 100;
            progressBar.style.width = scrolled + '%';
        });
    }

    // 스크롤 진행률 표시 활성화 (선택사항)
    // initScrollProgress();

})();