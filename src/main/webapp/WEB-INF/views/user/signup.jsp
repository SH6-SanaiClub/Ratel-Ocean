<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>역할 선택 - Ratel Ocean</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif; background-color: #F1F6EE; min-height: 100vh; display: flex; flex-direction: column; }
        header { background-color: white; border-bottom: 1px solid #e0e0e0; padding: 1rem 0; }
        .header-inner { max-width: 1200px; margin: 0 auto; padding: 0 2rem; display: flex; justify-content: space-between; align-items: center; }
        .logo { height: 40px; }
        .logo img { height: 100%; }
        .nav { display: flex; gap: 2rem; }
        .nav a { color: #2B2B2B; text-decoration: none; font-weight: 500; }
        main { flex: 1; display: flex; align-items: center; justify-content: center; padding: 4rem 2rem; }
        .container { max-width: 900px; width: 100%; }
        .content-header { text-align: center; margin-bottom: 4rem; }
        .eyebrow { text-transform: uppercase; letter-spacing: 0.1em; color: #6F7272; font-size: 0.875rem; margin-bottom: 1rem; }
        .title { font-size: 2.5rem; font-weight: 700; color: #2B2B2B; margin-bottom: 1rem; }
        .subtitle { font-size: 1.1rem; color: #6F7272; }
        .roles-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(350px, 1fr)); gap: 2rem; margin-bottom: 3rem; }
        .role-card { background: white; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); padding: 2rem; text-align: center; cursor: pointer; transition: all 0.3s ease; border: 2px solid transparent; }
        .role-card:hover { transform: translateY(-4px); box-shadow: 0 8px 16px rgba(0,0,0,0.15); border-color: #1F7A8C; }
        .role-card h3 { font-size: 1.5rem; color: #2B2B2B; margin-bottom: 1rem; }
        .role-card p { color: #6F7272; margin-bottom: 1.5rem; line-height: 1.6; }
        .role-btn { display: inline-block; padding: 0.75rem 2rem; background-color: #1F7A8C; color: white; border: none; border-radius: 6px; font-weight: 500; cursor: pointer; text-decoration: none; transition: background-color 0.2s; }
        .role-btn:hover { background-color: #165f6d; }
        footer { background-color: #2B2B2B; color: white; padding: 2rem 0; text-align: center; font-size: 0.875rem; }
    </style>
</head>
<body>
    <header>
        <div class="header-inner">
            <a class="logo" href="${pageContext.request.contextPath}/">
                <img src="${pageContext.request.contextPath}/resources/images/ratelogo.png" alt="Ratel Ocean">
            </a>
            <nav class="nav">
                <a href="${pageContext.request.contextPath}/service">서비스 소개</a>
                <a href="${pageContext.request.contextPath}/support">고객센터</a>
            </nav>
        </div>
    </header>

    <main>
        <div class="container">
            <div class="content-header">
                <p class="eyebrow">회원 가입</p>
                <h1 class="title">어떤 역할로 가입하시겠어요?</h1>
                <p class="subtitle">프리랜서 또는 클라이언트로 선택하고 가입을 진행해주세요.</p>
            </div>

            <div class="roles-grid">
                <!-- 프리랜서 -->
                <div class="role-card">
                    <h3>👨‍💻 프리랜서</h3>
                    <p>프로젝트를 수주하고 프리랜서 활동을 시작하세요. 다양한 프로젝트에 입찰하고 수익을 창출할 수 있습니다.</p>
                    <a href="${pageContext.request.contextPath}/join/freelancer.jsp" class="role-btn">프리랜서로 시작</a>
                </div>

                <!-- 클라이언트 -->
                <div class="role-card">
                    <h3>🏢 클라이언트</h3>
                    <p>프로젝트를 등록하고 수천 명의 전문가 프리랜서를 만나보세요. 이상적인 팀을 구성하고 프로젝트를 완성하세요.</p>
                    <a href="${pageContext.request.contextPath}/join/client" class="role-btn">클라이언트로 시작</a>
                </div>
            </div>
        </div>
    </main>

    <footer>
        <div class="container">© 2024 Ratel Ocean. All rights reserved.</div>
    </footer>
</body>
</html>
            <div class="card-inner">
                <div class="form-section">
                    <h3 class="section-title">계정 정보</h3>
                    <div class="grid two-col">
                        <label class="field" for="loginId">
                            <div class="label">Login ID</div>
                            <div class="input-row">
                                <input id="loginId" name="loginId" class="input" placeholder="" autocomplete="username" />
                                <button id="id-check" class="btn small outline" type="button">중복확인</button>
                            </div>
                            <div id="id-msg" class="inline-msg" aria-live="polite"></div>
                        </label>

                        <label class="field" for="email">
                            <div class="label">이메일</div>
                            <div class="input-row">
                                <input id="email" name="email" class="input" placeholder="" autocomplete="email" />
                                <button id="email-check" class="btn small outline" type="button">중복확인</button>
                            </div>
                            <div id="email-msg" class="inline-msg" aria-live="polite"></div>
                        </label>

                        <label class="field" for="password">
                            <div class="label">비밀번호</div>
                            <input id="password" name="password" class="input" placeholder="비밀번호 입력" type="password" autocomplete="new-password" />
                        </label>

                        <label class="field" for="passwordConfirm">
                            <div class="label">비밀번호 확인</div>
                            <input id="passwordConfirm" class="input" placeholder="비밀번호 확인" type="password" autocomplete="new-password" />
                        </label>
                    </div>
                </div>

                <div class="form-section">
                    <h3 class="section-title">개인 정보</h3>
                    <div class="grid two-col">
                        <div class="upload-area" aria-hidden="true">
                            <div class="avatar-placeholder" role="img" aria-label="프로필 이미지 업로드">
                                <svg width="40" height="40" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                    <path d="M12 5V3" stroke="#1F7A8C" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                                    <path d="M12 21v-2" stroke="#1F7A8C" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                                    <path d="M5 12H3" stroke="#1F7A8C" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                                    <path d="M21 12h-2" stroke="#1F7A8C" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                                    <circle cx="12" cy="12" r="3" stroke="#1F7A8C" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                                </svg>
                            </div>
                            <div class="label small muted">이미지 등록</div>
                        </div>

                        <label class="field" for="fullName">
                            <div class="label">이름</div>
                            <input id="fullName" name="fullName" class="input" placeholder="" autocomplete="name" />
                        </label>

                        <label class="field" for="phone">
                            <div class="label">전화번호 <span class="small muted">(인증필수)</span></div>
                            <div class="input-row">
                                <input id="phone" name="phone" type="tel" class="input" placeholder="" autocomplete="tel" maxlength="13" pattern="01[0-9]-\d{3,4}-\d{4}" />
                                <button id="send-code" class="btn small outline" type="button">인증번호 전송</button>
                            </div>
                            <div id="phone-msg" class="inline-msg" aria-live="polite"></div>
                            <div id="verify-area" class="verify-area" aria-live="polite" style="display:none">
                                <input id="verify-code-input" class="input" placeholder="인증번호 6자리" />
                                <button id="verify-code-btn" class="btn small outline" type="button">확인</button>
                                <span id="verify-timer" class="timer">5:00</span>
                            </div>
                            <div id="verify-msg" class="inline-msg" aria-live="polite"></div>
                        </label>

                        <label class="field" for="birth">
                            <div class="label">생년월일</div>
                            <input id="birth" name="birth" class="input" placeholder="" autocomplete="bday" />
                        </label>
                    </div>
                </div>

                <div class="form-section" id="freelancer-section" style="display:block;">
                    <h3 class="section-title">프리랜서 추가 정보</h3>
                    <div class="grid two-col">
                        <label class="field" for="nickname" style="grid-column: 1 / -1;">
                            <div class="label">닉네임 <span class="small muted">(필수)</span></div>
                            <input id="nickname" class="input" placeholder="" required />
                        </label>

                        <label class="field" for="introduction" style="grid-column: 1 / -1;">
                            <div class="label">자기소개</div>
                            <textarea id="introduction" class="input" placeholder=""></textarea>
                        </label>

                        <label class="field" for="github_url">
                            <div class="label">GitHub URL <span class="small muted">(선택)</span></div>
                            <input id="github_url" class="input" placeholder="" />
                        </label>

                        <label class="field" for="website_url">
                            <div class="label">웹사이트 URL <span class="small muted">(선택)</span></div>
                            <input id="website_url" class="input" placeholder="" />
                        </label>
                    </div>
                </div>

                <div class="form-section" id="account-section" style="display:block;">
                    <h3 class="section-title">계좌 정보 <span class="small muted">(수익금 정산용)</span></h3>
                    <p style="color:#6F7272; font-size:0.9rem; margin-bottom:1rem;">
                        ℹ️ 프로젝트 완료 후 용역비를 받기 위한 계좌 정보를 입력해주세요.
                    </p>
                    <div class="grid two-col">
                        <label class="field" for="bank_name">
                            <div class="label">은행명 <span class="small muted">(필수)</span></div>
                            <select id="bank_name" class="input" required>
                                <option value="">은행 선택</option>
                                <option value="KB국민은행">KB국민은행</option>
                                <option value="신한은행">신한은행</option>
                                <option value="우리은행">우리은행</option>
                                <option value="하나은행">하나은행</option>
                                <option value="NH농협은행">NH농협은행</option>
                                <option value="IBK기업은행">IBK기업은행</option>
                                <option value="카카오뱅크">카카오뱅크</option>
                                <option value="토스뱅크">토스뱅크</option>
                                <option value="케이뱅크">케이뱅크</option>
                            </select>
                        </label>

                        <label class="field" for="account_number">
                            <div class="label">계좌번호 <span class="small muted">(필수, 숫자만)</span></div>
                            <input id="account_number" class="input" placeholder="" inputmode="numeric" required />
                        </label>

                        <label class="field" for="account_holder" style="grid-column: 1 / -1;">
                            <div class="label">예금주명 <span class="small muted">(필수, 실명)</span></div>
                            <input id="account_holder" class="input" placeholder="" required />
                            <div class="inline-msg" style="color:#6F7272; margin-top:0.25rem;">
                                ⚠️ 예금주명은 입력하신 이름과 일치해야 합니다.
                            </div>
                        </label>
                    </div>
                </div>
            </div>
        </form>

        <div class="actions text-center">
            <button id="next-btn" class="btn primary large disabled" type="button" disabled>다음으로</button>
        </div>
    </div>
</main>

<section class="login-banner">
    <div class="container">이미 계정이 있으신가요? <a class="login-btn" href="${pageContext.request.contextPath}/login">로그인</a></div>
</section>

<script src="${pageContext.request.contextPath}/resources/js/signup.js"></script>
</body>
</html>