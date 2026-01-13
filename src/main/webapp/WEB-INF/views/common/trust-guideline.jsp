<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>신뢰 및 책임 안내 - FreelanceHub</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background-color: #F1F6EE;
            color: #2B2B2B;
            line-height: 1.6;
        }

        /* ═══════════════════════════════════════════════════════ */
        /* 헤더 (고정) */
        /* ═══════════════════════════════════════════════════════ */
        header {
            position: sticky;
            top: 0;
            background-color: #2B2B2B;
            color: white;
            padding: 1rem 2rem;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            z-index: 100;
        }

        .header-container {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .logo {
            font-size: 1.5rem;
            font-weight: 700;
            letter-spacing: -0.5px;
        }

        nav a {
            color: white;
            text-decoration: none;
            margin-left: 2rem;
            font-size: 0.95rem;
            transition: opacity 0.3s ease;
        }

        nav a:hover {
            opacity: 0.8;
        }

        .nav-menu {
            display: flex;
            gap: 2rem;
        }

        .logout-btn {
            background-color: #3FC1C9;
            color: white;
            border: none;
            padding: 0.5rem 1.2rem;
            border-radius: 4px;
            cursor: pointer;
            font-size: 0.9rem;
            font-weight: 600;
            transition: background-color 0.3s ease;
        }

        .logout-btn:hover {
            background-color: #2E9E9A;
        }

        /* ═══════════════════════════════════════════════════════ */
        /* 메인 콘텐츠 */
        /* ═══════════════════════════════════════════════════════ */
        main {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 2rem;
        }

        /* 히어로 영역 */
        .hero {
            text-align: center;
            padding: 4rem 2rem;
        }

        .hero h1 {
            font-size: 2.5rem;
            margin-bottom: 1rem;
            color: #2B2B2B;
            font-weight: 700;
        }

        .hero p {
            font-size: 1.1rem;
            color: #6B6B6B;
            margin-bottom: 3rem;
            line-height: 1.8;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }

        /* 아이콘 카드 3개 */
        .icon-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 2rem;
            margin-bottom: 4rem;
        }

        .icon-card {
            background-color: white;
            padding: 2rem;
            border-radius: 8px;
            text-align: center;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .icon-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
        }

        .icon-placeholder {
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, #3FC1C9, #2E9E9A);
            border-radius: 8px;
            margin: 0 auto 1rem;
        }

        .icon-card h3 {
            font-size: 1.2rem;
            margin-bottom: 0.5rem;
            color: #2B2B2B;
        }

        .icon-card p {
            color: #6B6B6B;
            font-size: 0.95rem;
        }

        /* 책임 안내 카드 (2컬럼) */
        .responsibility-section {
            margin-bottom: 4rem;
        }

        .responsibility-section h2 {
            text-align: center;
            font-size: 1.8rem;
            margin-bottom: 3rem;
            color: #2B2B2B;
        }

        .responsibility-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 2rem;
        }

        .responsibility-card {
            background-color: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
            overflow: hidden;
        }

        .responsibility-card-image {
            width: 100%;
            height: 200px;
            background: linear-gradient(135deg, #3FC1C9 0%, #2E9E9A 100%);
            border-radius: 4px 4px 0 0;
            margin: -2rem -2rem 1.5rem -2rem;
        }

        .responsibility-card h3 {
            font-size: 1.3rem;
            margin-bottom: 1rem;
            color: #2B2B2B;
            border-bottom: 2px solid #3FC1C9;
            padding-bottom: 0.5rem;
        }

        .responsibility-card ul {
            list-style: none;
            padding: 0;
        }

        .responsibility-card li {
            padding: 0.6rem 0;
            color: #6B6B6B;
            font-size: 0.95rem;
            position: relative;
            padding-left: 1.5rem;
        }

        .responsibility-card li:before {
            content: "✓";
            position: absolute;
            left: 0;
            color: #3FC1C9;
            font-weight: 700;
        }

        /* 동의 영역 */
        .agreement-section {
            background-color: white;
            padding: 3rem 2rem;
            border-radius: 8px;
            text-align: center;
            margin-bottom: 4rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
        }

        .agreement-section h2 {
            font-size: 1.4rem;
            margin-bottom: 2rem;
            color: #2B2B2B;
        }

        .checkbox-container {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 1rem;
            margin-bottom: 2rem;
        }

        .checkbox-container input[type="checkbox"] {
            width: 20px;
            height: 20px;
            cursor: pointer;
            accent-color: #3FC1C9;
        }

        .checkbox-container label {
            color: #6B6B6B;
            font-size: 1rem;
            cursor: pointer;
            user-select: none;
        }

        .agreement-btn {
            background-color: #6B6B6B;
            color: white;
            border: none;
            padding: 1rem 2.5rem;
            border-radius: 4px;
            font-size: 1rem;
            font-weight: 600;
            cursor: not-allowed;
            transition: background-color 0.3s ease;
        }

        .agreement-btn.active {
            background-color: #2E9E9A;
            cursor: pointer;
        }

        .agreement-btn.active:hover {
            background-color: #277370;
        }

        /* ═══════════════════════════════════════════════════════ */
        /* 푸터 */
        /* ═══════════════════════════════════════════════════════ */
        footer {
            background-color: #2B2B2B;
            color: white;
            padding: 2rem;
            text-align: center;
            margin-top: 4rem;
            font-size: 0.9rem;
        }

        .footer-container {
            max-width: 1200px;
            margin: 0 auto;
        }

        .footer-links {
            margin-bottom: 1rem;
            display: flex;
            gap: 1.5rem;
            justify-content: center;
            flex-wrap: wrap;
        }

        .footer-links a {
            color: white;
            text-decoration: none;
            transition: opacity 0.3s ease;
        }

        .footer-links a:hover {
            opacity: 0.8;
        }

        .footer-copyright {
            color: #6B6B6B;
        }

        /* ═══════════════════════════════════════════════════════ */
        /* 반응형 디자인 */
        /* ═══════════════════════════════════════════════════════ */
        @media (max-width: 768px) {
            .header-container {
                flex-direction: column;
                gap: 1rem;
            }

            .nav-menu {
                gap: 1rem;
                flex-wrap: wrap;
                justify-content: center;
            }

            nav a {
                margin-left: 0;
            }

            .hero h1 {
                font-size: 1.8rem;
            }

            .hero p {
                font-size: 1rem;
            }

            .icon-cards {
                grid-template-columns: 1fr;
            }

            .responsibility-cards {
                grid-template-columns: 1fr;
            }

            main {
                padding: 0 1rem;
            }

            .agreement-section {
                padding: 2rem 1rem;
            }
        }
    </style>
</head>
<body>

    <!-- ═══════════════════════════════════════════════════════ -->
    <!-- 헤더 -->
    <!-- ═══════════════════════════════════════════════════════ -->
    <header>
        <div class="header-container">
            <div class="logo">FreelanceHub</div>
            <nav class="nav-menu">
                <a href="#">서비스 소개</a>
                <a href="#">프로젝트 찾기</a>
                <a href="#">전문가 찾기</a>
            </nav>
            <button class="logout-btn">로그아웃</button>
        </div>
    </header>

    <!-- ═══════════════════════════════════════════════════════ -->
    <!-- 메인 콘텐츠 -->
    <!-- ═══════════════════════════════════════════════════════ -->
    <main>

        <!-- 히어로 영역 -->
        <section class="hero">
            <h1>신뢰할 수 있는 협업을 위한 우리의 약속</h1>
            <p>
                FreelanceHub는 프리랜서와 클라이언트 간의<br>
                상호 존중과 신뢰를 바탕으로 한<br>
                건강한 협업 문화를 지향합니다.
            </p>

            <!-- 아이콘 카드 3개 -->
            <div class="icon-cards">
                <div class="icon-card">
                    <div class="icon-placeholder"></div>
                    <h3>상호 신뢰</h3>
                    <p>투명한 의사소통과 약속 이행을 통해 신뢰 관계를 구축합니다.</p>
                </div>
                <div class="icon-card">
                    <div class="icon-placeholder"></div>
                    <h3>품질 보증</h3>
                    <p>전문적인 역량과 책임감 있는 태도로 높은 수준의 결과를 제공합니다.</p>
                </div>
                <div class="icon-card">
                    <div class="icon-placeholder"></div>
                    <h3>원활한 소통</h3>
                    <p>명확한 요청과 정중한 피드백을 통해 협업의 질을 높입니다.</p>
                </div>
            </div>
        </section>

        <!-- 책임 안내 섹션 -->
        <section class="responsibility-section">
            <h2>함께 만드는 건강한 협업</h2>
            <div class="responsibility-cards">
                <!-- 프리랜서 -->
                <div class="responsibility-card">
                    <div class="responsibility-card-image"></div>
                    <h3>프리랜서의 책임</h3>
                    <ul>
                        <li>높은 수준의 전문성 유지</li>
                        <li>약속한 기한 준수</li>
                        <li>투명하고 적극적인 소통</li>
                        <li>결과물의 품질 보증</li>
                        <li>피드백에 대한 빠른 반응</li>
                        <li>전문적이고 정중한 태도</li>
                    </ul>
                </div>

                <!-- 클라이언트 -->
                <div class="responsibility-card">
                    <div class="responsibility-card-image"></div>
                    <h3>클라이언트의 책임</h3>
                    <ul>
                        <li>명확한 업무 범위와 요구사항 제공</li>
                        <li>약속한 대금 지급 준수</li>
                        <li>정중하고 구체적인 피드백</li>
                        <li>합리적인 기한 설정</li>
                        <li>프리랜서 존중과 신뢰</li>
                        <li>갈등 발생 시 성숙한 대응</li>
                    </ul>
                </div>
            </div>
        </section>

        <!-- 동의 섹션 -->
        <section class="agreement-section">
            <h2>협업 시작 전 확인사항</h2>
            <div class="checkbox-container">
                <input type="checkbox" id="agreeCheckbox">
                <label for="agreeCheckbox">
                    위의 신뢰 및 책임 원칙에 동의합니다.
                </label>
            </div>
            <button class="agreement-btn" id="agreeBtn" disabled>동의하고 시작하기</button>
        </section>

    </main>

    <!-- ═══════════════════════════════════════════════════════ -->
    <!-- 푸터 -->
    <!-- ═══════════════════════════════════════════════════════ -->
    <footer>
        <div class="footer-container">
            <div class="footer-links">
                <a href="#">서비스 이용약관</a>
                <a href="#">개인정보 보호정책</a>
                <a href="#">고객지원</a>
                <a href="#">법적 고지</a>
            </div>
            <div class="footer-copyright">
                © 2024 FreelanceHub Corp. All rights reserved.
            </div>
        </div>
    </footer>

    <!-- ═══════════════════════════════════════════════════════ -->
    <!-- 순수 JavaScript (페이지 로직) -->
    <!-- ═══════════════════════════════════════════════════════ -->
    <script>
        // 체크박스와 버튼 요소 선택
        const agreeCheckbox = document.getElementById('agreeCheckbox');
        const agreeBtn = document.getElementById('agreeBtn');

        // 체크박스 상태 변경 시 버튼 활성화/비활성화
        agreeCheckbox.addEventListener('change', function() {
            if (this.checked) {
                agreeBtn.classList.add('active');
                agreeBtn.disabled = false;
            } else {
                agreeBtn.classList.remove('active');
                agreeBtn.disabled = true;
            }
        });

        // 버튼 클릭 시 alert 표시
        agreeBtn.addEventListener('click', function() {
            if (!agreeBtn.disabled) {
                alert('다음 단계로 이동합니다');
                // 실제 페이지 이동은 하지 않음 (요구사항)
            }
        });

        // 로그아웃 버튼 클릭 이벤트
        document.querySelector('.logout-btn').addEventListener('click', function() {
            alert('로그아웃되었습니다');
            // 실제 로그아웃은 하지 않음
        });
    </script>

</body>
</html>
