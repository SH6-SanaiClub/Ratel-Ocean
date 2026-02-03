<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<style>
  *{ box-sizing:border-box; }
  body{ margin:0; font-family: Arial, sans-serif; }

  .ro_hd_header{
    position: sticky; top:0;
    height:64px;
    background:#ffffff;
    color:#111827;
    z-index:1000;
    border-bottom:1px solid #e5e7eb;
  }
  .ro_hd_headerInner{
    height:64px;
    max-width:1200px;
    margin:0 auto;
    padding:0 24px;
    display:grid;
    grid-template-columns: 1fr auto 1fr;
    align-items:center;
    column-gap:16px;
  }

  .ro_hd_logo a{
    color:#111827;
    text-decoration:none;
    font-weight:800;
    letter-spacing:.3px;
    font-size:20px;
  }

  .ro_hd_nav{
    display:flex;
    gap:28px;
    align-items:center;
    justify-content:center;
  }
  .ro_hd_navItem{ position:relative; }
  .ro_hd_navLink{
    display:inline-flex;
    align-items:center;
    height:64px;
    padding:0 6px;
    color:#111827;
    text-decoration:none;
    font-weight:700;
    opacity:.85;
  }
  .ro_hd_navLink:hover{ opacity:1; }

  .ro_hd_dropdownBar{
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
  .ro_hd_navItem:hover .ro_hd_dropdownBar{ height:180px; }

  .ro_hd_dropdownInner{
    max-width:1200px;
    margin:0 auto;
    padding:22px 24px 22px 300px;
    display:flex;
    gap:40px;
  }
  .ro_hd_ddCol{ min-width:180px; }
  .ro_hd_ddTitle{
    margin:0 0 12px;
    font-size:14px;
    font-weight:800;
    color:#111827;
  }
  .ro_hd_ddLink{
    display:block;
    font-size:13px;
    color:#4b5563;
    text-decoration:none;
    margin:0 0 9px;
  }
  .ro_hd_ddLink:hover{ color:#111827; }

  .ro_hd_actions{
    height:64px;
    display:flex;
    align-items:center;
    justify-content:flex-end;
    gap:12px;
  }

  .ro_hd_iconItem{
    position:relative;
    height:64px;
    display:flex;
    align-items:center;
  }
  .ro_hd_iconBtn{
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
  .ro_hd_ico{ display:block; width:20px; height:20px; fill: currentColor; }

  .ro_hd_iconBtn:hover{
    opacity:1;
    background:#f3f4f6;
  }

  .ro_hd_miniDd{
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
  .ro_hd_iconItem.ro_hd_open .ro_hd_miniDd{
    opacity:1;
    transform: translateY(0);
    pointer-events:auto;
  }


  .ro_hd_miniHead{
    padding:14px 14px;
    background:#f9fafb;
    border-bottom:1px solid #eef2f7;
    font-weight:800;
    font-size:13px;
  }
  .ro_hd_miniBody{ padding:12px 14px; }
  .ro_hd_miniRow{
    display:flex;
    gap:10px;
    padding:10px 8px;
    border-radius:10px;
    text-decoration:none;
    color:#111827;
  }
  .ro_hd_miniRow:hover{ background:#f3f4f6; }
  .ro_hd_miniMuted{
    font-size:12px;
    color:#6b7280;
    margin-top:2px;
  }
  .ro_hd_miniCta{
    display:block;
    padding:12px 14px;
    border-top:1px solid #eef2f7;
    background:#fff;
    text-decoration:none;
    color:#111827;
    font-weight:700;
  }
  .ro_hd_miniCta:hover{ background:#f9fafb; }

  .ro_hd_badge{
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
    .ro_hd_headerInner{ grid-template-columns: 1fr 1fr; }
    .ro_hd_nav{ display:none; }
  }
</style>

<header class="ro_hd_header">
  <div class="ro_hd_headerInner">

    <div class="ro_hd_logo">
      <c:choose>
        <c:when test="${userType eq 'CLIENT'}">
          <a href="${ctx}/client/dashboard">RatelOcean</a>
        </c:when>
        <c:when test="${userType eq 'FREELANCER'}">
          <a href="${ctx}/freelancer/dashboard">RatelOcean</a>
        </c:when>
        <c:otherwise>
          <a href="${ctx}/">RatelOcean</a>
        </c:otherwise>
      </c:choose>
    </div>

    <nav class="ro_hd_nav">
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

    <div class="ro_hd_actions">

      <div class="ro_hd_iconItem">
        <a class="ro_hd_iconBtn ro_hd_jsDdToggle" href="#" title="채팅" data-dd="chat">
          <svg class="ro_hd_ico" viewBox="0 0 24 24" aria-hidden="true">
            <path d="M20 2H4a2 2 0 0 0-2 2v14l4-3h14a2 2 0 0 0 2-2V4a2 2 0 0 0-2-2z"/>
          </svg>
        </a>
        <div class="ro_hd_miniDd">
          <div class="ro_hd_miniHead">채팅</div>
          <div class="ro_hd_miniBody">
            <a class="ro_hd_miniRow" href="${pageContext.request.contextPath}/chat">
              <div>
                <div style="font-weight:800; font-size:13px;">채팅 목록</div>
                <div class="ro_hd_miniMuted">대화를 확인하세요.</div>
              </div>
            </a>
          </div>
          <a class="ro_hd_miniCta" href="${pageContext.request.contextPath}/chat">채팅 전체 보기</a>
        </div>
      </div>

      <div class="ro_hd_iconItem">
        <a class="ro_hd_iconBtn ro_hd_jsDdToggle" href="#" title="알림" data-dd="noti">
          <svg class="ro_hd_ico" viewBox="0 0 24 24" aria-hidden="true">
            <path d="M12 22a2 2 0 0 0 2-2H10a2 2 0 0 0 2 2zm6-6V11a6 6 0 1 0-12 0v5L4 18v1h16v-1l-2-2z"/>
          </svg>
        </a>
        <div class="ro_hd_miniDd">
          <div class="ro_hd_miniHead">알림</div>
          <div class="ro_hd_miniBody">
            <a class="ro_hd_miniRow" href="${pageContext.request.contextPath}/notification">
              <div>
                <div style="font-weight:800; font-size:13px;">알림 목록</div>
                <div class="ro_hd_miniMuted">새로운 알림을 확인하세요.</div>
              </div>
            </a>
          </div>
          <a class="ro_hd_miniCta" href="${pageContext.request.contextPath}/notification">알림 전체 보기</a>
        </div>
      </div>

      <div class="ro_hd_iconItem">
        <a class="ro_hd_iconBtn ro_hd_jsDdToggle" href="#" title="마이페이지" data-dd="mypage">
          <svg class="ro_hd_ico" viewBox="0 0 24 24" aria-hidden="true">
            <path d="M12 12a4 4 0 1 0-4-4 4 4 0 0 0 4 4zm0 2c-4.42 0-8 2-8 4.5V21h16v-2.5C20 16 16.42 14 12 14z"/>
          </svg>
        </a>

        <div class="ro_hd_miniDd">
          <div class="ro_hd_miniHead">마이페이지</div>
          <div class="ro_hd_miniBody">
            <c:choose>
              <c:when test="${empty userType}">
                <a class="ro_hd_miniRow" href="${pageContext.request.contextPath}/login">
                  <div>
                    <div style="font-weight:800; font-size:13px;">로그인</div>
                    <div class="ro_hd_miniMuted">로그인 후 이용할 수 있어요.</div>
                  </div>
                </a>
                <a class="ro_hd_miniRow" href="${pageContext.request.contextPath}/join">
                  <div>
                    <div style="font-weight:800; font-size:13px;">회원가입</div>
                    <div class="ro_hd_miniMuted">계정 만들고 시작하기</div>
                  </div>
                </a>
              </c:when>

              <c:when test="${userType == 'FREELANCER'}">
                <a class="ro_hd_miniRow" href="${pageContext.request.contextPath}/freelancer/mypage">
                  <div>
                    <div style="font-weight:800; font-size:13px;">마이페이지</div>
                    <div class="ro_hd_miniMuted">내 정보 수정</div>
                  </div>
                </a>
                <a class="ro_hd_miniRow" href="${pageContext.request.contextPath}/freelancer/mypage">
                  <div>
                    <div style="font-weight:800; font-size:13px;">내 지갑</div>
                    <div class="ro_hd_miniMuted">출금/거래내역</div>
                  </div>
                </a>
                <a class="ro_hd_miniRow" href="${pageContext.request.contextPath}/freelancer/profile/edit">
                  <div>
                    <div style="font-weight:800; font-size:13px;">내 프로필 수정</div>
                    <div class="ro_hd_miniMuted">닉네임/학력/경력/프로젝트</div>
                  </div>
                </a>
              </c:when>

              <c:when test="${userType == 'CLIENT'}">
                <a class="ro_hd_miniRow" href="${pageContext.request.contextPath}/client/mypage">
                  <div>
                    <div style="font-weight:800; font-size:13px;">마이페이지</div>
                    <div class="ro_hd_miniMuted">내 정보 수정/리뷰 보기</div>
                  </div>
                </a>
              </c:when>
            </c:choose>
          </div>
          <a class="ro_hd_miniCta" href="#" onclick="logout(event)" >로그아웃</a>
        </div>
      </div>

    </div>
  </div>
</header>

<script>
  document.addEventListener('DOMContentLoaded', function () {
    const items = Array.from(document.querySelectorAll('.ro_hd_actions .ro_hd_iconItem'));
    const toggles = Array.from(document.querySelectorAll('.ro_hd_actions .ro_hd_jsDdToggle'));

    console.log('[header] toggles:', toggles.length);

    function closeAll(except) {
      items.forEach(it => {
        if (except && it === except) return;
        it.classList.remove('ro_hd_open');
      });
    }

    toggles.forEach(btn => {
      btn.addEventListener('click', function (e) {
        e.preventDefault();
        e.stopPropagation();

        const item = btn.closest('.ro_hd_iconItem');
        const willOpen = !item.classList.contains('ro_hd_open');

        closeAll();
        if (willOpen) item.classList.add('ro_hd_open');
      });
    });

    document.querySelectorAll('.ro_hd_actions .ro_hd_miniDd').forEach(dd => {
      dd.addEventListener('click', e => e.stopPropagation());
    });

    document.addEventListener('click', () => closeAll());

    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') closeAll();
    });
  });

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
