<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<style>
  *{ box-sizing:border-box; }
  body{ margin:0; font-family: Arial, sans-serif; }

  .header{
    position: sticky; top:0;
    height:64px;
    background:#ffffff;
    color:#111827;
    z-index:1000;
    border-bottom:1px solid #e5e7eb;
  }
  .header-inner{
    height:64px;
    max-width:1200px;
    margin:0 auto;
    padding:0 24px;
    display:grid;
    grid-template-columns: 1fr auto 1fr;
    align-items:center;
    column-gap:16px;
  }

  .logo a{
    color:#111827;
    text-decoration:none;
    font-weight:800;
    letter-spacing:.3px;
  }

  .nav{
    display:flex;
    gap:28px;
    align-items:center;
    justify-content:center;
  }
  .nav-item{ position:relative; }
  .nav-link{
    display:inline-flex;
    align-items:center;
    height:64px;
    padding:0 6px;
    color:#111827;
    text-decoration:none;
    font-weight:700;
    opacity:.85;
  }
  .nav-link:hover{ opacity:1; }

  .dropdown-bar{
    position: fixed;
    left:0;
    top:64px;
    width:100%;
    height:0;
    overflow:hidden;
    background:#ffffff;
    border-bottom:1px solid #e5e7eb;
    box-shadow:0 10px 30px rgba(0,0,0,.08);
    transition: height .25s ease;
    z-index:999;
  }
  .nav-item:hover .dropdown-bar{ height:180px; }

  .dropdown-inner{
    max-width:1200px;
    margin:0 auto;
    padding:22px 24px 22px 300px;
    display:flex;
    gap:40px;
  }
  .dd-col{ min-width:180px; }
  .dd-title{
    margin:0 0 12px;
    font-size:14px;
    font-weight:800;
    color:#111827;
  }
  .dd-link{
    display:block;
    font-size:13px;
    color:#4b5563;
    text-decoration:none;
    margin:0 0 9px;
  }
  .dd-link:hover{ color:#111827; }

  .actions{
    height:64px;
    display:flex;
    align-items:center;
    justify-content:flex-end;
    gap:12px;
  }

  .icon-item{
    position:relative;
    height:64px;
    display:flex;
    align-items:center;
  }
  .icon-btn{
    height:40px;
    width:40px;
    display:flex;
    align-items:center;
    justify-content:center;
    border-radius:999px;
    color:#111827;
    text-decoration:none;

    background:#f3f4f6;
    border:1px solid #e5e7eb;
    box-shadow:0 1px 2px rgba(0,0,0,.04);
    opacity:0.9;

  }
  .ico{ display:block; width:20px; height:20px; fill: currentColor; }

  .icon-btn:hover{
    opacity:1;
    background:#f3f4f6;
  }

  .mini-dd{
    position:absolute;
    right:0;
    top:64px;
    width:320px;
    background:#ffffff;
    color:#111827;
    border:1px solid #e5e7eb;
    border-radius:14px;
    box-shadow:0 18px 40px rgba(0,0,0,.14);
    overflow:hidden;

    opacity:0;
    transform: translateY(-6px);
    pointer-events:none;
    transition: opacity .15s ease, transform .15s ease;
    z-index:1001;
  }
  .icon-item.open .mini-dd{
    opacity:1;
    transform: translateY(0);
    pointer-events:auto;
  }


  .mini-head{
    padding:14px 14px;
    background:#f9fafb;
    border-bottom:1px solid #eef2f7;
    font-weight:800;
    font-size:13px;
  }
  .mini-body{ padding:12px 14px; }
  .mini-row{
    display:flex;
    gap:10px;
    padding:10px 8px;
    border-radius:10px;
    text-decoration:none;
    color:#111827;
  }
  .mini-row:hover{ background:#f3f4f6; }
  .mini-muted{
    font-size:12px;
    color:#6b7280;
    margin-top:2px;
  }
  .mini-cta{
    display:block;
    padding:12px 14px;
    border-top:1px solid #eef2f7;
    background:#fff;
    text-decoration:none;
    color:#111827;
    font-weight:700;
  }
  .mini-cta:hover{ background:#f9fafb; }

  .badge{
    position:absolute;
    top:6px; right:6px;
    min-width:16px; height:16px;
    padding:0 4px;
    border-radius:999px;
    background:#ef4444;
    color:#fff;
    font-size:10px;
    line-height:16px;
    text-align:center;
  }

  @media (max-width: 860px){
    .header-inner{ grid-template-columns: 1fr 1fr; }
    .nav{ display:none; }
  }
</style>

<header class="header">
  <div class="header-inner">

    <div class="logo">
      <a href="${pageContext.request.contextPath}/">RateOcean</a>
    </div>

    <nav class="nav">
      <c:choose>
        <c:when test="${userType == 'FREELANCER'}">
          <jsp:include page="/WEB-INF/views/common/nav-freelancer.jsp" />
        </c:when>
        <c:when test="${userType == 'CLIENT'}">
          <jsp:include page="/WEB-INF/views/common/nav-client.jsp" />
        </c:when>
        <c:otherwise>
        </c:otherwise>
      </c:choose>
    </nav>

    <div class="actions">

      <!-- 채팅 -->
      <div class="icon-item">
        <a class="icon-btn js-dd-toggle" href="#" title="채팅" data-dd="chat">
        <svg class="ico" viewBox="0 0 24 24" aria-hidden="true">
            <path d="M20 2H4a2 2 0 0 0-2 2v14l4-3h14a2 2 0 0 0 2-2V4a2 2 0 0 0-2-2z"/>
          </svg>
        </a>
        <div class="mini-dd">
          <div class="mini-head">채팅</div>
          <div class="mini-body">
            <a class="mini-row" href="${pageContext.request.contextPath}/chat">
              <div>
                <div style="font-weight:800; font-size:13px;">채팅 목록</div>
                <div class="mini-muted">대화를 확인하세요.</div>
              </div>
            </a>
          </div>
          <a class="mini-cta" href="${pageContext.request.contextPath}/chat">채팅 전체 보기</a>
        </div>
      </div>

      <!-- 알림 -->
      <div class="icon-item">
        <a class="icon-btn js-dd-toggle" href="#" title="알림" data-dd="noti">
          <svg class="ico" viewBox="0 0 24 24" aria-hidden="true">
            <path d="M12 22a2 2 0 0 0 2-2H10a2 2 0 0 0 2 2zm6-6V11a6 6 0 1 0-12 0v5L4 18v1h16v-1l-2-2z"/>
          </svg>
        </a>
        <div class="mini-dd">
          <div class="mini-head">알림</div>
          <div class="mini-body">
            <a class="mini-row" href="${pageContext.request.contextPath}/notification">
              <div>
                <div style="font-weight:800; font-size:13px;">알림 목록</div>
                <div class="mini-muted">새로운 알림을 확인하세요.</div>
              </div>
            </a>
          </div>
          <a class="mini-cta" href="${pageContext.request.contextPath}/notification">알림 전체 보기</a>
        </div>
      </div>

      <!-- 마이페이지 -->
      <div class="icon-item">
        <a class="icon-btn js-dd-toggle" href="#" title="마이페이지" data-dd="mypage">
          <svg class="ico" viewBox="0 0 24 24" aria-hidden="true">
            <path d="M12 12a4 4 0 1 0-4-4 4 4 0 0 0 4 4zm0 2c-4.42 0-8 2-8 4.5V21h16v-2.5C20 16 16.42 14 12 14z"/>
          </svg>
        </a>

        <div class="mini-dd">
          <div class="mini-head">마이페이지</div>
          <div class="mini-body">
            <c:choose>
              <c:when test="${empty userType}">
                <a class="mini-row" href="${pageContext.request.contextPath}/login">
                  <div>
                    <div style="font-weight:800; font-size:13px;">로그인</div>
                    <div class="mini-muted">로그인 후 이용할 수 있어요.</div>
                  </div>
                </a>
                <a class="mini-row" href="${pageContext.request.contextPath}/join">
                  <div>
                    <div style="font-weight:800; font-size:13px;">회원가입</div>
                    <div class="mini-muted">계정 만들고 시작하기</div>
                  </div>
                </a>
              </c:when>

              <c:when test="${userType == 'FREELANCER'}">
                <a class="mini-row" href="${pageContext.request.contextPath}/freelancer/mypage">
                  <div>
                    <div style="font-weight:800; font-size:13px;">마이페이지</div>
                    <div class="mini-muted">내 정보 수정</div>
                  </div>
                </a>
                <a class="mini-row" href="${pageContext.request.contextPath}/freelancer/mypage">
                  <div>
                    <div style="font-weight:800; font-size:13px;">내 지갑</div>
                    <div class="mini-muted">출금/거래내역</div>
                  </div>
                </a>
                <a class="mini-row" href="${pageContext.request.contextPath}/freelancer/profile/edit">
                  <div>
                    <div style="font-weight:800; font-size:13px;">내 프로필 수정</div>
                    <div class="mini-muted">닉네임/학력/경력/프로젝트</div>
                  </div>
                </a>
              </c:when>

              <c:when test="${userType == 'CLIENT'}">
                <a class="mini-row" href="${pageContext.request.contextPath}/client/mypage">
                  <div>
                    <div style="font-weight:800; font-size:13px;">마이페이지</div>
                    <div class="mini-muted">내 정보 수정/리뷰 보기</div>
                  </div>
                </a>
              </c:when>
            </c:choose>
          </div>
          <a class="mini-cta" href="#" onclick="logout(event)" >로그아웃</a>
        </div>
      </div>

    </div>
  </div>
</header>

<script>
  document.addEventListener('DOMContentLoaded', function () {
    const items = Array.from(document.querySelectorAll('.actions .icon-item'));
    const toggles = Array.from(document.querySelectorAll('.actions .js-dd-toggle'));

    // 디버그: 이 숫자가 3이 아니면 HTML 클래스 적용이 안된거임
    console.log('[header] toggles:', toggles.length);

    function closeAll(except) {
      items.forEach(it => {
        if (except && it === except) return;
        it.classList.remove('open');
      });
    }

    toggles.forEach(btn => {
      btn.addEventListener('click', function (e) {
        e.preventDefault();
        e.stopPropagation();

        const item = btn.closest('.icon-item');
        const willOpen = !item.classList.contains('open');

        closeAll(); // 다른 것 닫고
        if (willOpen) item.classList.add('open'); // 얘만 열기
      });
    });

    // 드롭다운 내부 클릭은 닫히지 않게
    document.querySelectorAll('.actions .mini-dd').forEach(dd => {
      dd.addEventListener('click', e => e.stopPropagation());
    });

    // 바깥 클릭하면 닫기
    document.addEventListener('click', () => closeAll());

    // ESC 닫기
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') closeAll();
    });
  });

  // 로그아웃
  async function logout(e) {
    e.preventDefault();
    try {
      const response = await fetch('${pageContext.request.contextPath}/logout', { method: 'POST' });
      if (response.ok) window.location.href = '${pageContext.request.contextPath}/login';
    } catch (error) {
      console.error('로그아웃 오류:', error);
      alert('로그아웃에 실패했습니다.');
    }
  }
</script>
