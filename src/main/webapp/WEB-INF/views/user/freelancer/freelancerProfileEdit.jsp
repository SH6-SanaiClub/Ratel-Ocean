<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%
  String tab = request.getParameter("tab");
  if (tab == null || tab.isBlank()) tab = "skill";
  request.setAttribute("tab", tab);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>마이페이지</title>
  <style>
    :root{
      --bg: #f6f4fb;
      --card: #ffffff;
      --text: #111827;
      --muted: #6b7280;
      --line: #e5e7eb;
      --primary: #6d4dfd;
      --primary-weak: rgba(109,77,253,0.12);
      --shadow: 0 20px 60px rgba(17,24,39,0.08);
      --radius: 18px;
    }
    *{ box-sizing: border-box; }
    body{
      margin: 0;
      font-family: -apple-system, BlinkMacSystemFont, "Apple SD Gothic Neo", "Noto Sans KR", Segoe UI, Roboto, Helvetica, Arial, sans-serif;
      background: var(--bg);
      color: var(--text);
    }

    .wrap{
      max-width: 1320px;
      margin: 26px auto 60px;
      padding: 0 18px;
    }
    .page{
      background: var(--card);
      border-radius: 24px;
      box-shadow: var(--shadow);
      border: 1px solid rgba(229,231,235,0.7);
      overflow: hidden;
    }
    .content{
      display: grid;
      grid-template-columns: 300px 1fr;
      min-height: 760px;
    }

    .sidebar{
      border-right: 1px solid var(--line);
      padding: 22px 18px;
      background: linear-gradient(180deg, #fff 0%, #fbfaff 100%);
    }
    .sb-title{
      font-size: 14px;
      color: var(--muted);
      font-weight: 700;
      margin: 6px 8px 14px;
    }
    .menu{
      display:flex;
      flex-direction: column;
      gap: 8px;
    }
    .menu a{
      text-decoration: none;
      color: var(--text);
      padding: 12px 12px;
      border-radius: 14px;
      border: 1px solid transparent;
      display:flex;
      align-items:center;
      gap: 10px;
      font-weight: 700;
      cursor: pointer;
    }
    .menu a:hover{ background: #f7f5ff; }
    .menu a.active{
      background: var(--primary-weak);
      border-color: rgba(109,77,253,0.35);
      color: #2b1cc9;
    }
    .icon{
      width: 30px; height: 30px;
      border-radius: 12px;
      background: #f3f4f6;
      display:flex; align-items:center; justify-content:center;
      color: #374151;
      font-size: 14px;
    }
    .menu a.active .icon{
      background: rgba(109,77,253,0.18);
      color: var(--primary);
    }

    .main{ padding: 36px 44px; }
    .card-head{
      display:flex;
      align-items: flex-end;
      justify-content: space-between;
      gap: 10px;
      margin-bottom: 18px;
    }
    .title{
      font-size: 22px;
      font-weight: 900;
      margin: 0;
    }
    .desc{
      margin: 6px 0 0;
      color: var(--muted);
      font-size: 13px;
    }

    .panel{ display:none; animation: fade 180ms ease-out; }
    .panel.active{ display:block; }
    @keyframes fade{
      from{ opacity: 0; transform: translateY(4px); }
      to{ opacity: 1; transform: translateY(0); }
    }

    .form{
      border: 1px solid var(--line);
      border-radius: var(--radius);
      padding: 20px;
      background: #fff;
    }

    .btns{ display:flex; gap: 10px; justify-content: flex-end; margin-top: 16px; }
    .btn{
      border: none;
      border-radius: 14px;
      padding: 12px 18px;
      font-weight: 900;
      cursor: pointer;
      font-size: 14px;
    }
    .btn.primary{
      background: var(--primary);
      color: #fff;
      box-shadow: 0 14px 30px rgba(109,77,253,0.22);
    }
    .btn.ghost{ background: #fff; border: 1px solid var(--line); color: #111827; }
    .btn.danger{ background:#e04545; color:#fff; }
    .btn.small{ padding: 8px 10px; font-size: 12px; border-radius: 12px; }

    select,input,textarea{
      border: 1px solid var(--line);
      border-radius: 14px;
      padding: 10px 10px;
      font-size: 14px;
      outline: none;
      background: #fff;
    }
    textarea{ min-height: 90px; resize: vertical; }

    /* ===== Toast (하단 중앙, 자동 사라짐) ===== */
    .toast{
      position: fixed;
      left: 50%;
      bottom: 26px;
      transform: translateX(-50%) translateY(12px);
      opacity: 0;
      pointer-events: none;
      background: rgba(17,24,39,0.92);
      color: #fff;
      padding: 12px 16px;
      border-radius: 999px;
      box-shadow: 0 12px 30px rgba(0,0,0,0.18);
      font-weight: 800;
      font-size: 13px;
      z-index: 9999;
      transition: opacity 180ms ease, transform 180ms ease;
      max-width: min(720px, calc(100vw - 32px));
      text-align: center;
    }
    .toast.show{
      opacity: 1;
      transform: translateX(-50%) translateY(0);
    }

    /* ====== Stack UI (스케치 느낌) ====== */
    .stack-top{
      display:flex;
      gap:10px;
      align-items:center;
      margin-bottom: 10px;
    }
    .stack-top .search{
      flex: 1;
      display:flex;
      gap:10px;
      align-items:center;
    }
    .stack-top input[type="text"]{ width:100%; }
    .tagBox{
      border: 1px solid var(--line);
      border-radius: var(--radius);
      padding: 14px;
      background: #fff;
    }
    .tagScroll{
      margin-top: 10px;
      max-height: 150px;
      overflow:auto;
      padding: 6px;
      border: 1px dashed var(--line);
      border-radius: 14px;
    }
    .btnsWrap{ display:flex; flex-wrap:wrap; gap:8px; }
    .tag{
      border:1px solid #ccc;
      border-radius:999px;
      padding:8px 12px;
      cursor:pointer;
      background:#fff;
      font-weight:800;
      font-size:13px;
      user-select: none;
    }
    .tag.active{ border-color:#2d6cdf; color:#2d6cdf; background: rgba(45,108,223,0.06); }

    .sel{ margin-top:14px; }
    .sel-title{ font-size: 14px; font-weight: 900; margin: 0 0 8px; }
    .sel-item{
      display:flex; gap:10px; align-items:center;
      padding: 10px 12px;
      border:1px solid var(--line);
      border-radius:14px;
      margin: 10px 0;
      justify-content: space-between;
    }
    .right{
      display:flex; gap:8px; align-items:center; flex-wrap:wrap;
    }
    .hint{ font-size: 12px; color: var(--muted); margin-top: 8px; }

    /* ====== Career/External list + inline edit ====== */
    .topActions{
      display:flex;
      justify-content: flex-end;
      margin-bottom: 10px;
    }
    .list{
      margin-top: 14px;
      border-top: 1px dashed var(--line);
      padding-top: 14px;
      display:flex; flex-direction: column; gap: 10px;
    }
    .item{
      border: 1px solid var(--line);
      border-radius: 14px;
      padding: 14px;
      display:flex;
      align-items: center;
      justify-content: space-between;
      gap: 10px;
      background:#fff;
    }
    .meta{ display:flex; flex-direction: column; gap:4px; }
    .meta b{ font-size: 14px; }
    .meta span{ color: var(--muted); font-size: 12px; }
    .mini{ display:flex; gap:8px; align-items:center; }
    .mini form{ margin:0; }

    .editForm{
      margin-top: 10px;
      border: 1px solid var(--line);
      border-radius: 14px;
      padding: 14px;
      background: #fbfaff;
      display:none;
    }
    .editForm.active{ display:block; }

    .split{
      display:grid;
      grid-template-columns: 1fr 1fr;
      gap: 14px;
    }
    .row{ display:flex; flex-direction: column; gap: 8px; }
    .row label{ font-size: 13px; color: #374151; font-weight: 700; }
    .full{ grid-column: 1 / -1; }

    /* ===== Position 카드형 버튼 ===== */

    /* 포지션 버튼 영역만 grid로 */
    #positionButtons{
      display: grid;
      grid-template-columns: repeat(4, minmax(0, 1fr)); /* 4칸, 더 크고 싶으면 3 또는 2로 */
      gap: 12px;
    }

    /* 카드형 버튼 스타일 */
    #positionButtons .posTag{
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 14px 16px;
      border-radius: 18px;
      border: 1px solid var(--line);
      background: #fff;
      font-weight: 900;
      font-size: 14px;
      justify-content: flex-start;
    }

    /* 아이콘 박스 */
    #positionButtons .posTag .posIcon{
      width: 42px;
      height: 42px;
      border-radius: 16px;
      background: #f3f4f6;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 18px;
      flex: 0 0 auto;
    }

    /* 라벨 */
    #positionButtons .posTag .posLabel{
      font-weight: 900;
    }

    /* 선택(active) 상태 */
    #positionButtons .posTag.active{
      border-color: rgba(109,77,253,0.35);
      background: var(--primary-weak);
      color: #2b1cc9;
    }

    #positionButtons .posTag.active .posIcon{
      background: rgba(109,77,253,0.18);
    }
    .head-actions{
      display:flex;
      gap:10px;
      align-items:center;
    }

  </style>
</head>

<body>
<div class="wrap">
  <div class="page">
    <div class="content">

      <!-- Sidebar -->
      <aside class="sidebar">
        <div class="sb-title">프리랜서 프로필</div>

        <nav class="menu" id="menu">
          <a href="?tab=settings" data-tab="settings" class="<%= "settings".equals(tab) ? "active" : "" %>">
            <div class="icon">⚙️</div> 프로필 기본 정보
          </a>
          <a href="?tab=position" data-tab="position" class="<%= "position".equals(tab) ? "active" : "" %>">
            <div class="icon">🧭</div> 포지션
          </a>
          <a href="?tab=skill" data-tab="skill" class="<%= "skill".equals(tab) ? "active" : "" %>">
            <div class="icon">🛠</div> 스킬
          </a>
          <a href="?tab=career" data-tab="career" class="<%= "career".equals(tab) ? "active" : "" %>">
            <div class="icon">🧩</div> 경력
          </a>
          <a href="?tab=external" data-tab="external" class="<%= "external".equals(tab) ? "active" : "" %>">
            <div class="icon">🗂️</div> 외부 프로젝트
          </a>

        </nav>
      </aside>

      <!-- Main -->
      <main class="main">

        <!-- ===================== 프로필 기본 정보 수정 ===================== -->
        <section class="panel <%= "settings".equals(tab) ? "active" : "" %>" id="panel-settings">
          <div class="card-head">
            <div>
              <h2 class="title">프로필 기본 정보</h2>
              <p class="desc">프로필 기본 정보 수정 페이지 입니다.</p>
            </div>
          </div>
          <div class="form">
            <div style="color:var(--muted); font-size:13px;">TODO: freelancer_profile, portfolio 파트 / 이미지,포트폴리오, 닉네임, 이메일, git or 블로그 url (어떤거쓸지 중복선택가능), 자기소개작성, 최종학력 </div>
          </div>
        </section>

        <!-- ===================== 포지션 ===================== -->
        <section class="panel <%= "position".equals(tab) ? "active" : "" %>" id="panel-position">
          <div class="card-head">
            <div>
              <h2 class="title">포지션</h2>
              <p class="desc">가능한 포지션을 선택하고 경력을 입력하세요. (0년 부터 기입 가능)</p>
            </div>
          </div>

          <form class="form"
                method="post"
                action="${pageContext.request.contextPath}/freelancer/profile/edit/stack/save"
                id="positionForm">

            <input type="hidden" name="tab" value="position"/>
            <input type="hidden" name="category" value="POSITION"/>

            <div class="tagBox">
              <div class="btnsWrap" id="positionButtons">
                <c:forEach var="p" items="${positionOptions}">
                  <button type="button"
                          class="tag posTag"
                          data-id="${p.stackId}"
                          data-name="${fn:escapeXml(p.stackName)}">
                      <span class="posIcon">
                        <c:choose>
                          <c:when test="${p.stackName eq '웹'}">🖥️</c:when>
                          <c:when test="${p.stackName eq '모바일앱'}">📱</c:when>
                          <c:when test="${p.stackName eq '데이터베이스'}">🗄️</c:when>
                          <c:when test="${p.stackName eq 'DevOps/인프라'}">⚙️</c:when>
                          <c:when test="${p.stackName eq '게임/그래픽'}">🎮</c:when>
                          <c:when test="${p.stackName eq 'AI/빅데이터'}">🤖</c:when>
                          <c:when test="${p.stackName eq '임베디드/하드웨어'}">🔧</c:when>
                          <c:otherwise>📌</c:otherwise>
                        </c:choose>
                      </span>
                    <span class="posLabel">${p.stackName}</span>
                  </button>
                </c:forEach>
              </div>


              <div class="sel">
                <div class="sel-title">내 보유 포지션</div>
                <div id="selectedPositions"></div>
                <div class="hint">저장 버튼을 누르면 선택/경력 값이 저장됩니다.</div>
              </div>
            </div>

            <div id="positionHiddenBox"></div>

            <div class="btns">
              <button class="btn primary" type="submit">저장</button>
            </div>
          </form>
        </section>

        <!-- ===================== 스킬 ===================== -->
        <section class="panel <%= "skill".equals(tab) ? "active" : "" %>" id="panel-skill">
          <div class="card-head">
            <div>
              <h2 class="title">스킬</h2>
              <p class="desc">보유 스킬을 선택하고 레벨(1~5) / 경력(0년~)을 입력하세요.</p>
            </div>
          </div>

          <form class="form"
                method="post"
                action="${pageContext.request.contextPath}/freelancer/profile/edit/stack/save"
                id="skillForm">

            <input type="hidden" name="tab" value="skill"/>
            <input type="hidden" name="category" value="SKILL"/>

            <div class="stack-top">
              <div class="search">
                <input type="text" id="skillSearch" placeholder="스킬 검색 (예: Java, Spring)"/>
              </div>
              <button type="button" class="btn ghost" id="skillSearchBtn">검색</button>
              <button type="button" class="btn ghost" id="skillResetBtn">초기화</button>
            </div>

            <div class="tagBox">
              <div class="desc" style="margin:0 0 6px; font-size:12px;">아래에서 스킬을 선택하세요.</div>
              <div class="tagScroll" id="skillScroll">
                <div class="btnsWrap" id="skillButtons">
                  <c:forEach var="s" items="${skillOptions}">
                    <button type="button"
                            class="tag"
                            data-id="${s.stackId}"
                            data-name="${fn:escapeXml(s.stackName)}">
                        ${s.stackName}
                    </button>
                  </c:forEach>
                </div>
              </div>

              <div class="sel">
                <div class="sel-title">내 보유 스킬</div>
                <div id="selectedSkills"></div>
                <div class="hint">저장 버튼을 누르면 선택/레벨/경력 값이 저장됩니다.</div>
              </div>
            </div>

            <div id="skillHiddenBox"></div>

            <div class="btns">
              <button class="btn primary" type="submit">저장</button>
            </div>
          </form>
        </section>

        <!-- ===================== 경력 ===================== -->
        <section class="panel <%= "career".equals(tab) ? "active" : "" %>" id="panel-career">
          <div class="card-head">
            <div>
              <h2 class="title">경력</h2>
              <p class="desc">추가 혹은 수정 버튼을 누르면 입력폼이 열립니다.</p>
            </div>

            <div class="head-actions">
              <button type="button" class="btn ghost" id="careerAddToggle">+ 추가</button>
            </div>
          </div>


          <div class="form">
            <!-- 추가 폼 (토글) -->
            <form method="post"
                  action="${pageContext.request.contextPath}/freelancer/profile/edit/career/add"
                  id="careerAddForm"
                  style="display:none;">

              <div class="split">
                <div class="row">
                  <label>회사명</label>
                  <input name="companyName" type="text" required placeholder="예) 사나이클럽" />
                </div>
                <div class="row">
                  <label>직무(역할)</label>
                  <input name="role" type="text" required placeholder="예) 백엔드 개발" />
                </div>
                <div class="row">
                  <label>포지션</label>
                  <input name="position" type="text" required placeholder="예) Backend Developer" />
                </div>
                <div class="row">
                  <label>시작일</label>
                  <input name="startDate" type="date" required />
                </div>
                <div class="row">
                  <label>종료일(선택)</label>
                  <input name="endDate" type="date" />
                </div>
                <div class="row full">
                  <label>설명(선택)</label>
                  <textarea name="description" placeholder="담당 업무, 성과 등"></textarea>
                </div>
              </div>

              <div class="btns">
                <button type="button" class="btn ghost" id="careerAddCancel">닫기</button>
                <button class="btn primary" type="submit">저장</button>
              </div>
            </form>

            <!-- 리스트 / 인라인 수정폼 -->
            <div class="sel">
              <div class="title" style="font-size:16px;">내 보유 경력</div>
              <div class="hint">저장된 회사 경력 목록입니다.</div>
            </div>
            <div class="list" id="careerList">
              <c:forEach var="c" items="${careers}">
                <div class="itemWrap" data-career-id="${c.careerId}">
                  <!-- 요약 카드 -->
                  <div class="item">
                    <div class="meta">
                      <b>${c.companyName} · ${c.position}</b>
                      <span>
                        ${c.startDate}
                        ~
                        <c:choose>
                          <c:when test="${empty c.endDate}">재직중</c:when>
                          <c:otherwise>${c.endDate}</c:otherwise>
                        </c:choose>
                        · ${c.role}
                      </span>
                    </div>
                    <div class="mini">
                      <button type="button" class="btn ghost small careerEditBtn">수정</button>
                      <form method="post"
                            action="${pageContext.request.contextPath}/freelancer/profile/edit/career/delete"
                            onsubmit="return confirm('삭제할까요?');">
                        <input type="hidden" name="careerId" value="${c.careerId}" />
                        <button type="submit" class="btn danger small">삭제</button>
                      </form>
                    </div>
                  </div>

                  <!-- 인라인 수정 폼 -->
                  <form class="editForm careerEditForm"
                        method="post"
                        action="${pageContext.request.contextPath}/freelancer/profile/edit/career/update">

                    <input type="hidden" name="careerId" value="${c.careerId}"/>

                    <div class="split">
                      <div class="row">
                        <label>회사명</label>
                        <input name="companyName" type="text" required value="${fn:escapeXml(c.companyName)}"/>
                      </div>
                      <div class="row">
                        <label>직무(역할)</label>
                        <input name="role" type="text" required value="${fn:escapeXml(c.role)}"/>
                      </div>
                      <div class="row">
                        <label>포지션</label>
                        <input name="position" type="text" required value="${fn:escapeXml(c.position)}"/>
                      </div>
                      <div class="row">
                        <label>시작일</label>
                        <input name="startDate" type="date" required value="${c.startDate}"/>
                      </div>
                      <div class="row">
                        <label>종료일(선택)</label>
                        <input name="endDate" type="date" value="${c.endDate}"/>
                      </div>
                      <div class="row full">
                        <label>설명(선택)</label>
                        <textarea name="description">${fn:escapeXml(c.description)}</textarea>
                      </div>
                    </div>

                    <div class="btns">
                      <button type="button" class="btn ghost careerEditCancel">취소</button>
                      <button type="submit" class="btn primary">저장</button>
                    </div>
                  </form>
                </div>
              </c:forEach>
            </div>
          </div>
        </section>

        <!-- ===================== 외부 프로젝트 ===================== -->
        <section class="panel <%= "external".equals(tab) ? "active" : "" %>" id="panel-external">
          <div class="card-head">
            <div>
              <h2 class="title">외부 프로젝트</h2>
              <p class="desc">추가 혹은 수정 버튼을 누르면 입력폼이 열립니다.</p>
            </div>

            <div class="head-actions">
              <button type="button" class="btn ghost" id="expAddToggle">+ 추가</button>
            </div>
          </div>

          <div class="form">

            <!-- 추가 폼 (토글) -->
            <form method="post"
                  action="${pageContext.request.contextPath}/freelancer/profile/edit/experience/add"
                  id="expAddForm"
                  style="display:none;">

              <div class="split">

                <div class="row">
                  <label>프로젝트명</label>
                  <input name="title" type="text" required placeholder="예) 외주 쇼핑몰 개발" />
                </div>
                <div class="row">
                  <label>클라이언트명(선택)</label>
                  <input name="clientName" type="text" placeholder="예) ○○회사" />
                </div>
                <div class="row">
                  <label>시작일</label>
                  <input name="startDate" type="date" required />
                </div>
                <div class="row">
                  <label>종료일(선택)</label>
                  <input name="endDate" type="date" />
                </div>
                <div class="row">
                  <label>역할</label>
                  <input name="role" type="text" required placeholder="예) 백엔드 개발" />
                </div>
                <div class="row full">
                  <label>설명(선택)</label>
                  <textarea name="description" placeholder="프로젝트 설명, 담당 업무"></textarea>
                </div>
              </div>

              <div class="btns">
                <button type="button" class="btn ghost" id="expAddCancel">닫기</button>
                <button class="btn primary" type="submit">저장</button>
              </div>
            </form>

            <!-- 리스트 / 인라인 수정폼 -->
            <div class="sel">
              <div class="title" style="font-size:16px;">내 보유 프로젝트</div>
              <div class="hint">저장된 외부 프로젝트 목록입니다.</div>
            </div>

            <div class="list" id="expList">
              <c:forEach var="e" items="${experiences}">
                <div class="itemWrap" data-exp-id="${e.experienceId}">
                  <div class="item">
                    <div class="meta">
                      <b>${e.title} · ${e.role}</b>
                      <span>
                        ${e.startDate}
                        ~
                        <c:choose>
                          <c:when test="${empty e.endDate}">진행중</c:when>
                          <c:otherwise>${e.endDate}</c:otherwise>
                        </c:choose>
                        <c:if test="${not empty e.clientName}"> · ${e.clientName}</c:if>
                      </span>
                    </div>
                    <div class="mini">
                      <button type="button" class="btn ghost small expEditBtn">수정</button>
                      <form method="post"
                            action="${pageContext.request.contextPath}/freelancer/profile/edit/experience/delete"
                            onsubmit="return confirm('삭제할까요?');">
                        <input type="hidden" name="experienceId" value="${e.experienceId}" />
                        <button type="submit" class="btn danger small">삭제</button>
                      </form>
                    </div>
                  </div>

                  <form class="editForm expEditForm"
                        method="post"
                        action="${pageContext.request.contextPath}/freelancer/profile/edit/experience/update">
                    <input type="hidden" name="experienceId" value="${e.experienceId}"/>

                    <div class="split">
                      <div class="row">
                        <label>프로젝트명</label>
                        <input name="title" type="text" required value="${fn:escapeXml(e.title)}"/>
                      </div>
                      <div class="row">
                        <label>클라이언트명(선택)</label>
                        <input name="clientName" type="text" value="${fn:escapeXml(e.clientName)}"/>
                      </div>
                      <div class="row">
                        <label>시작일</label>
                        <input name="startDate" type="date" required value="${e.startDate}"/>
                      </div>
                      <div class="row">
                        <label>종료일(선택)</label>
                        <input name="endDate" type="date" value="${e.endDate}"/>
                      </div>
                      <div class="row">
                        <label>역할</label>
                        <input name="role" type="text" required value="${fn:escapeXml(e.role)}"/>
                      </div>
                      <div class="row full">
                        <label>설명(선택)</label>
                        <textarea name="description">${fn:escapeXml(e.description)}</textarea>
                      </div>
                    </div>

                    <div class="btns">
                      <button type="button" class="btn ghost expEditCancel">취소</button>
                      <button type="submit" class="btn primary">저장</button>
                    </div>
                  </form>
                </div>
              </c:forEach>
            </div>
          </div>
        </section>


        <div id="toast" class="toast"></div>
      </main>
    </div>
  </div>
</div>

<script>
  // ================== 탭 전환 (리로드 없이) ==================
  (function(){
    const menu = document.getElementById('menu');
    if(!menu) return;

    menu.addEventListener('click', function(e){
      const a = e.target.closest('a[data-tab]');
      if(!a) return;
      e.preventDefault();

      const tab = a.getAttribute('data-tab');

      menu.querySelectorAll('a').forEach(x => x.classList.remove('active'));
      a.classList.add('active');

      document.querySelectorAll('.panel').forEach(p => p.classList.remove('active'));
      const panel = document.getElementById('panel-' + tab);
      if(panel) panel.classList.add('active');

      const url = new URL(window.location.href);
      url.searchParams.set('tab', tab);
      window.history.replaceState({}, '', url.toString());
    });
  })();

  // ================== Stack (Skill/Position) ==================
  function esc(str){
    if(str === null || str === undefined) return "";
    return String(str)
            .replaceAll("&","&amp;")
            .replaceAll("<","&lt;")
            .replaceAll(">","&gt;")
            .replaceAll('"',"&quot;")
            .replaceAll("'","&#039;");
  }

  const mySkills = new Map();
  const myPositions = new Map();

  // 서버 초기값 → JS 배열
  const initSkills = [
    <c:forEach var="x" items="${mySkills}" varStatus="st">
    {"stackId": ${x.stackId}, "name": "${fn:escapeXml(x.stackName)}", "level": ${x.stackLevel}, "years": ${x.stackYear}}${st.last ? "" : ","}
    </c:forEach>
  ];
  const initPositions = [
    <c:forEach var="x" items="${myPositions}" varStatus="st">
    {"stackId": ${x.stackId}, "name": "${fn:escapeXml(x.stackName)}", "level": 1, "years": ${x.stackYear}}${st.last ? "" : ","}
    </c:forEach>
  ];

  initSkills.forEach(s => mySkills.set(String(s.stackId), s));
  initPositions.forEach(p => myPositions.set(String(p.stackId), p));

  function levelOptions(selected){
    let html = "";
    const sel = Number(selected || 1);
    for(let n=1;n<=5;n++){
      html += '<option value="'+n+'"'+(n===sel?' selected':'')+'>'+n+'</option>';
    }
    return html;
  }

  function renderSkills(){
    document.querySelectorAll("#skillButtons .tag").forEach(btn => {
      btn.classList.toggle("active", mySkills.has(btn.dataset.id));
    });

    const box = document.getElementById("selectedSkills");
    if(!box) return;
    box.innerHTML = "";

    mySkills.forEach((v) => {
      const div = document.createElement("div");
      div.className = "sel-item";
      div.innerHTML =
              '<div><b>'+esc(v.name)+'</b></div>' +
              '<div class="right">' +
              '<span style="font-weight:800; font-size:12px; color:#6b7280;">Level</span>' +
              '<select class="skillLevel" data-id="'+v.stackId+'">' + levelOptions(v.level) + '</select>' +
              '<span style="font-weight:800; font-size:12px; color:#6b7280;">경력</span>' +
              '<input type="number" min="0" step="1" class="skillYears" data-id="'+v.stackId+'" value="'+Number(v.years||0)+'" style="width:90px"/> <span>년</span>' +
              '<button type="button" class="btn danger small removeSkill" data-id="'+v.stackId+'">X</button>' +
              '</div>';
      box.appendChild(div);
    });
  }

  function renderPositions(){
    document.querySelectorAll("#positionButtons .tag").forEach(btn => {
      btn.classList.toggle("active", myPositions.has(btn.dataset.id));
    });

    const box = document.getElementById("selectedPositions");
    if(!box) return;
    box.innerHTML = "";

    myPositions.forEach((v) => {
      const div = document.createElement("div");
      div.className = "sel-item";
      div.innerHTML =
              '<div><b>'+esc(v.name)+'</b></div>' +
              '<div class="right">' +
              '<span style="font-weight:800; font-size:12px; color:#6b7280;">경력</span>' +
              '<input type="number" min="0" step="1" class="posYears" data-id="'+v.stackId+'" value="'+Number(v.years||0)+'" style="width:90px"/> <span>년</span>' +
              '<button type="button" class="btn danger small removePos" data-id="'+v.stackId+'">X</button>' +
              '</div>';
      box.appendChild(div);
    });
  }

  // 태그 클릭 토글 (버튼 내부 클릭 포함)
  document.getElementById("skillButtons")?.addEventListener("click", (e) => {
    const btn = e.target.closest("button.tag");
    if(!btn) return;
    const id = String(btn.dataset.id);
    const name = btn.dataset.name || btn.textContent.trim();
    if(mySkills.has(id)) mySkills.delete(id);
    else mySkills.set(id, {stackId:Number(id), name:name, level:1, years:0});
    renderSkills();
  });

  document.getElementById("positionButtons")?.addEventListener("click", (e) => {
    const btn = e.target.closest("button.tag");
    if(!btn) return;
    const id = String(btn.dataset.id);
    const name = btn.dataset.name || btn.textContent.trim();
    if(myPositions.has(id)) myPositions.delete(id);
    else myPositions.set(id, {stackId:Number(id), name:name, level:1, years:0});
    renderPositions();
  });

  // 값 변경 반영
  document.addEventListener("change", (e) => {
    if(e.target.classList.contains("skillLevel")){
      const id = String(e.target.dataset.id);
      const v = mySkills.get(id);
      if(v) v.level = Number(e.target.value || 1);
    }
    if(e.target.classList.contains("skillYears")){
      const id = String(e.target.dataset.id);
      const v = mySkills.get(id);
      if(v) v.years = Math.max(0, Number(e.target.value || 0));
    }
    if(e.target.classList.contains("posYears")){
      const id = String(e.target.dataset.id);
      const v = myPositions.get(id);
      if(v) v.years = Math.max(0, Number(e.target.value || 0));
    }
  });

  // 삭제
  document.addEventListener("click", (e) => {
    if(e.target.classList.contains("removeSkill")){
      mySkills.delete(String(e.target.dataset.id));
      renderSkills();
    }
    if(e.target.classList.contains("removePos")){
      myPositions.delete(String(e.target.dataset.id));
      renderPositions();
    }
  });

  // submit 직전 hidden 생성 (컨트롤러 DTO: FreelancerStackSaveRequestDTO.stacks)
  function fillHiddenStacks(box, sourceMap){
    box.innerHTML = "";
    let i = 0;
    sourceMap.forEach(v => {
      box.insertAdjacentHTML("beforeend",
              '<input type="hidden" name="stacks['+i+'].stackId" value="'+v.stackId+'"/>' +
              '<input type="hidden" name="stacks['+i+'].stackLevel" value="'+(v.level ?? 1)+'"/>' +
              '<input type="hidden" name="stacks['+i+'].stackYear" value="'+(v.years ?? 0)+'"/>'
      );
      i++;
    });
  }

  document.getElementById("skillForm")?.addEventListener("submit", function(){
    fillHiddenStacks(document.getElementById("skillHiddenBox"), mySkills);
  });
  document.getElementById("positionForm")?.addEventListener("submit", function(){
    fillHiddenStacks(document.getElementById("positionHiddenBox"), myPositions);
  });

  // 스킬 검색(필터링)
  (function(){
    const input = document.getElementById("skillSearch");
    const btn = document.getElementById("skillSearchBtn");
    const reset = document.getElementById("skillResetBtn");
    const wrap = document.getElementById("skillButtons");
    if(!input || !btn || !reset || !wrap) return;

    function apply(){
      const q = (input.value || "").trim().toLowerCase();
      wrap.querySelectorAll("button.tag").forEach(b => {
        const name = (b.dataset.name || b.textContent || "").toLowerCase();
        b.style.display = (q === "" || name.includes(q)) ? "" : "none";
      });
    }
    btn.addEventListener("click", apply);
    input.addEventListener("keydown", (e)=>{ if(e.key==="Enter"){ e.preventDefault(); apply(); }});
    reset.addEventListener("click", ()=>{ input.value=""; apply(); });
  })();

  // 초기 렌더
  renderSkills();
  renderPositions();

  // ================== Career / External: 토글 + 인라인 수정 ==================
  (function(){
    const addToggle = document.getElementById("careerAddToggle");
    const addForm = document.getElementById("careerAddForm");
    const addCancel = document.getElementById("careerAddCancel");
    if(addToggle && addForm){
      addToggle.addEventListener("click", ()=>{ addForm.style.display = (addForm.style.display==="none"||!addForm.style.display) ? "block" : "none"; });
    }
    addCancel?.addEventListener("click", ()=>{ addForm.style.display="none"; });
    document.querySelectorAll(".careerEditBtn").forEach(btn=>{
      btn.addEventListener("click", ()=>{
        const wrap = btn.closest(".itemWrap");
        if(!wrap) return;
        const form = wrap.querySelector(".careerEditForm");
        if(!form) return;
        form.classList.add("active");
        form.scrollIntoView({behavior:"smooth", block:"start"});
      });
    });
    document.querySelectorAll(".careerEditCancel").forEach(btn=>{
      btn.addEventListener("click", ()=>{
        const form = btn.closest(".careerEditForm");
        if(!form) return;
        form.classList.remove("active");
      });
    });
  })();

  (function(){
    const addToggle = document.getElementById("expAddToggle");
    const addForm = document.getElementById("expAddForm");
    const addCancel = document.getElementById("expAddCancel");
    if(addToggle && addForm){
      addToggle.addEventListener("click", ()=>{ addForm.style.display = (addForm.style.display==="none"||!addForm.style.display) ? "block" : "none"; });
    }
    addCancel?.addEventListener("click", ()=>{ addForm.style.display="none"; });
    document.querySelectorAll(".expEditBtn").forEach(btn=>{
      btn.addEventListener("click", ()=>{
        const wrap = btn.closest(".itemWrap");
        if(!wrap) return;
        const form = wrap.querySelector(".expEditForm");
        if(!form) return;
        form.classList.add("active");
        form.scrollIntoView({behavior:"smooth", block:"start"});
      });
    });
    document.querySelectorAll(".expEditCancel").forEach(btn=>{
      btn.addEventListener("click", ()=>{
        const form = btn.closest(".expEditForm");
        if(!form) return;
        form.classList.remove("active");
      });
    });
  })();

  // ===== Toast helper =====
  function showToast(message, ms){
    const el = document.getElementById("toast");
    if(!el) return;
    el.textContent = message;
    el.classList.add("show");
    window.clearTimeout(el._t);
    el._t = window.setTimeout(() => {
      el.classList.remove("show");
    }, ms || 2000);
  }

  // ===== 서버 msg 있으면 토스트로 출력 =====
  (function(){
    const serverMsg = "<c:out value='${msg}' default='' />";
    if(serverMsg && serverMsg.trim().length > 0){
      showToast(serverMsg.trim(), 2000);
    }
  })();
</script>

</body>
</html>
