<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%
  String tab = request.getParameter("tab");
  if (tab == null || tab.isBlank()) tab = "settings";
  request.setAttribute("tab", tab);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>내 프로필 수정</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <style>
    :root{
      --bg:#f6f6f8;
      --paper:#ffffff;

      --sb-bg:#ffffff;
      --sb-hover:#f3f5f7;
      --sb-active-bg:#eef2f4;
      --sb-active-line: var(--text);

      --text:#0f172a;
      --muted:#6b7280;

      --line:#d8dee6;
      --line2:#c9d1dc;

      --primary:#173160;
      --primary-deep:#1f4fd8;
      --primary-weak: rgba(45,108,223,.12);

      --danger:#e04545;

      --shadow: 0 10px 28px rgba(17,24,39,.06);
      --shadow2: 0 6px 16px rgba(17,24,39,.06);

      --R0:0px;
      --R1:6px;
      --R2:14px;

      --focus: 0 0 0 3px rgba(45,108,223,.22);
    }

    *{ box-sizing:border-box; }
    body{
      margin:0;
      font-family: -apple-system, BlinkMacSystemFont, "Apple SD Gothic Neo",
      "Noto Sans KR", Segoe UI, Roboto, Helvetica, Arial, sans-serif;
      background: var(--bg);
      color: var(--text);
      -webkit-font-smoothing: antialiased;
      -moz-osx-font-smoothing: grayscale;
    }

    .wrap{
      max-width: 1320px;
      margin: 22px auto 60px;
      padding: 0 18px;
    }

    .sb-title{
      margin: 6px 10px 12px;
      font-family: -apple-system, BlinkMacSystemFont, "Apple SD Gothic Neo",
      "Noto Sans KR", Segoe UI, Roboto, Helvetica, Arial, sans-serif !important;
      font-size: 13px !important;
      font-weight: 900 !important;
      line-height: 1.25 !important;
      letter-spacing: -0.2px !important;
      color: var(--text) !important;
      text-decoration: none !important;
    }
    .sb-title *{
      font-family: inherit !important;
      color: inherit !important;
      text-decoration: none !important;
    }

    .page{
      background: var(--paper);
      border-radius: var(--R0);
      border: 1px solid var(--line);
      box-shadow: var(--shadow);
      overflow:hidden;
    }

    .content{
      display:grid;
      grid-template-columns: 300px 1fr;
      min-height: 760px;
    }

    .sidebar{
      border-right: 1px solid var(--line);
      padding: 18px 14px;
      background: var(--sb-bg);
    }

    .menu{
      display:flex;
      flex-direction: column;
      gap: 6px;
    }

    .menu a{
      text-decoration:none !important;
      color: var(--text);
      padding: 12px 12px;
      border-radius: 6px;
      border: 1px solid transparent;
      display:flex;
      align-items:center;
      gap: 10px;
      font-weight: 800;
      cursor: pointer;
      background: transparent;
      transition: background .12s ease, border-color .12s ease;
      position: relative;
    }

    .menu a:hover{
      background: var(--sb-hover);
    }

    .menu a.active{
      background: var(--sb-active-bg);
      border-color: rgba(15,23,42,.10);
    }

    .menu a.active::before{
      content:"";
      position:absolute;
      left:0;
      top:8px;
      bottom:8px;
      width:3px;
      background: var(--sb-active-line); /* == #0f172a */
      border-radius: 2px;
    }

    .icon{
      width: 30px;
      height: 30px;
      border-radius: 6px;
      background: rgba(15,23,42,.06);
      display:flex;
      align-items:center;
      justify-content:center;
      color: rgba(15,23,42,.75);
      font-size: 14px;
    }

    .menu a.active .icon{
      background: rgba(15,23,42,.08);
      color: var(--text);
    }

    .main{
      padding: 28px 34px;
      background:#fff;
    }

    .card-head{
      display:flex;
      align-items:flex-start;
      justify-content: space-between;
      gap: 12px;
      margin-bottom: 14px;
      padding-bottom: 12px;
      border-bottom: 1px solid var(--line);
    }
    .title{
      font-size: 20px;
      font-weight: 900;
      margin: 0;
      letter-spacing: -.2px;
    }
    .desc{
      margin: 6px 0 0;
      color: var(--muted);
      font-size: 13px;
      line-height: 1.45;
      font-weight: 650;
    }

    .panel{ display:none; animation: fade 160ms ease-out; }
    .panel.active{ display:block; }
    @keyframes fade{
      from{ opacity:0; transform: translateY(4px); }
      to{ opacity:1; transform: translateY(0); }
    }

    .form{
      border: 1px solid var(--line);
      border-radius: var(--R1);
      padding: 18px;
      background: #fff;
      box-shadow: var(--shadow2);
    }

    .btns{ display:flex; gap:10px; justify-content:flex-end; margin-top: 16px; }

    .btn{
      border: 1px solid transparent;
      border-radius: 12px;
      padding: 11px 16px;
      font-weight: 900;
      cursor: pointer;
      font-size: 14px;
      background:#fff;
      transition: background .12s ease, border-color .12s ease, box-shadow .12s ease, transform .08s ease;
    }
    .btn:active{ transform: translateY(1px); }
    .btn:focus{ outline:none; box-shadow: var(--focus); }

    .btn.primary{
      background: var(--primary);
      color:#fff;
      border-color: rgba(45,108,223,.25);
      /*box-shadow: 0 12px 26px rgba(45,108,223,.20);*/
    }
    .btn.primary:hover{ filter: brightness(.98); }

    .btn.ghost{
      background:#fff;
      border-color: var(--line2);
      color: var(--text);
    }
    .btn.ghost:hover{
      background:#f3f4f6;
      border-color:#b9c0cc;
    }

    .btn.danger{
      background: #e5e7eb;
      color: #111827;
      border-color: #cbd5e1;
      box-shadow: none;
    }
    .btn.danger:hover{
      background: #e5e7eb;
      border-color: #cbd5e1;
    }

    .btn.small{
      padding: 8px 10px;
      font-size: 12px;
      border-radius: 10px;
      font-weight: 900;
    }

    select,input,textarea{
      width:100%;
      border: 1px solid var(--line);
      border-radius: 12px;
      padding: 10px 12px;
      font-size: 14px;
      outline: none;
      background: #fff;
      color: var(--text);
    }
    textarea{ min-height: 90px; resize: vertical; }

    select:focus,input:focus,textarea:focus{
      border-color: rgba(45,108,223,.55);
      box-shadow: 0 0 0 4px rgba(45,108,223,.12);
    }

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
    .toast.show{ opacity:1; transform: translateX(-50%) translateY(0); }

    .stack-top{
      display:flex;
      gap:10px;
      align-items:center;
      margin-bottom: 10px;
    }
    .stack-top .search{ flex:1; display:flex; gap:10px; align-items:center; }

    .tagBox{
      border: 1px solid var(--line);
      border-radius: var(--R2);
      padding: 14px;
      background: #fff;
    }
    .tagScroll{
      margin-top: 10px;
      max-height: 150px;
      overflow:auto;
      padding: 6px;
      border: 1px dashed var(--line2);
      border-radius: 12px;
      background: #fafbfc;
    }
    .btnsWrap{ display:flex; flex-wrap:wrap; gap:8px; }

    .tag{
      border:1px solid var(--line2);
      border-radius: 999px;
      padding:8px 12px;
      cursor:pointer;
      background:#fff;
      font-weight: 900;
      font-size: 13px;
      user-select:none;
      transition: background .12s ease, border-color .12s ease, color .12s ease;
    }
    .tag:hover{ background:#f3f4f6; }
    .tag.active{
      border-color: rgba(59,111,220,.22);
      background: rgba(59,111,220,.10);
      color: var(--text);
    }

    .sel{ margin-top:14px; }
    .sel-title{ font-size: 14px; font-weight: 900; margin: 0 0 8px; }
    .sel-item{
      display:flex;
      gap:10px;
      align-items:center;
      padding: 10px 12px;
      border:1px solid var(--line);
      border-radius: 12px;
      margin: 10px 0;
      justify-content: space-between;
      background:#fff;
    }
    .right{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; }
    .hint{ font-size: 12px; color: var(--muted); margin-top: 8px; font-weight: 650; }

    /* ===== Career/External list ===== */
    .head-actions{ display:flex; gap:10px; align-items:center; }
    .list{
      margin-top: 14px;
      border-top: 1px dashed var(--line2);
      padding-top: 14px;
      display:flex;
      flex-direction: column;
      gap: 10px;
    }
    .item{
      border: 1px solid var(--line);
      border-radius: 12px;
      padding: 14px;
      display:flex;
      align-items: center;
      justify-content: space-between;
      gap: 10px;
      background:#fff;
    }
    .meta{ display:flex; flex-direction: column; gap:4px; min-width:0; }
    .meta b{ font-size: 14px; font-weight: 900; }
    .meta span{
      color: var(--muted);
      font-size: 12px;
      font-weight: 650;
      line-height: 1.45;
      white-space: nowrap;
      overflow:hidden;
      text-overflow: ellipsis;
      max-width: 720px;
      font-variant-numeric: tabular-nums;
    }
    .mini{ display:flex; gap:8px; align-items:center; }
    .mini form{ margin:0; }

    .editForm{
      margin-top: 10px;
      border: 1px solid var(--line);
      border-radius: 12px;
      padding: 14px;
      background: #fafbfc;
      display:none;
    }
    .editForm.active{ display:block; }

    .split{
      display:grid;
      grid-template-columns: 1fr 1fr;
      gap: 14px;
    }
    .row{ display:flex; flex-direction: column; gap: 8px; }
    .row label{ font-size: 13px; color: #374151; font-weight: 900; }
    .full{ grid-column: 1 / -1; }

    #positionButtons{
      display:grid;
      grid-template-columns: repeat(4, minmax(0, 1fr));
      gap: 12px;
    }
    #positionButtons .posTag{
      display:flex;
      align-items:center;
      gap: 12px;
      padding: 14px 14px;
      border-radius: 12px;
      border: 1px solid var(--line);
      background: #fff;
      font-weight: 900;
      font-size: 14px;
      justify-content:flex-start;
      cursor:pointer;
      transition: background .12s ease, border-color .12s ease, transform .08s ease;
    }
    #positionButtons .posTag:hover{
      border-color: rgba(59,111,220,.22);
      background: rgba(59,111,220,.10);
    }
    #positionButtons .posTag:active{ transform: translateY(1px); }

    #positionButtons .posTag .posIcon{
      width: 42px; height: 42px;
      border-radius: 14px;
      background: #eef2f7;
      display:flex; align-items:center; justify-content:center;
      font-size: 18px;
      flex: 0 0 auto;
    }
    #positionButtons .posTag.active{
      border-color: rgba(59,111,220,.22);
      background: rgba(59,111,220,.10);
      color: var(--text);
    }
    #positionButtons .posTag.active .posIcon{
      background: rgba(45,108,223,.14);
    }

    /* ===== settings grid ===== */
    .settingsWrap{ max-width: 980px; }

    .settingsGrid{
      display:grid;
      grid-template-columns: 260px 1fr;
      grid-template-areas:
    "photo info"
    "git blog"
    "edu edu"
    "port port"
    "save save";
      gap: 16px 18px;
      align-items:start;
    }

    .setBox{
      border:1px solid var(--line);
      border-radius: var(--R2);
      background:#fff;
      padding: 16px;
    }
    .setLabel{
      font-size: 13px;
      color:#374151;
      font-weight: 900;
      margin-bottom: 8px;
    }
    .setInput, .setTextarea{
      width:100%;
      border:1px solid var(--line);
      border-radius: 12px;
      padding: 12px 12px;
      font-size:14px;
      outline:none;
    }
    .setTextarea{ min-height: 130px; resize: vertical; }

    .setInput:focus, .setTextarea:focus{
      border-color: rgba(45,108,223,.55);
      box-shadow: 0 0 0 4px rgba(45,108,223,.12);
    }

    .setPhoto{ grid-area: photo; }
    .setInfo{ grid-area: info; }
    .setEdu{ grid-area: edu; }
    .setPort{ grid-area: port; }
    .setSave{ grid-area: save; display:flex; justify-content:flex-end; }

    .setPhoto, .setInfo{ height:100%; }
    .setInfo{ display:flex; flex-direction:column; }
    .setInfo .setTextarea{ flex:1; min-height:0; resize:none; }

    .avatarLg{
      width: 180px;
      height: 180px;
      border-radius: 999px;
      border:1px solid var(--line);
      overflow:hidden;
      background:#eef2f7;
      display:flex;
      align-items:center;
      justify-content:center;
      margin: 8px auto 14px;
    }
    .avatarLg img{ width:100%; height:100%; object-fit:cover; display:block; }
    .avatarLg .ph{ color:#9ca3af; font-weight:900; }

    .photoBtns{ display:flex; gap:10px; justify-content:center; }

    .eduGrid{
      display:grid;
      grid-template-columns: 1fr 1fr;
      gap: 12px;
    }

    .urlRow{
      grid-column: 1 / -1;
      display:grid;
      grid-template-columns: 1fr 1fr;
      gap: 16px 18px;
    }


    .fileBar{
      border:1px dashed var(--line2);
      background: #fafbfc;
      border-radius: 12px;
      padding: 14px;
      display:flex;
      align-items:center;
      justify-content:space-between;
      gap: 12px;
      cursor:pointer;
      transition: border-color .12s ease, background .12s ease, transform .08s ease;
    }
    .fileBar:focus{ outline:none; box-shadow: var(--focus); }

    .fileBar.dragover{
      background: rgba(45,108,223,.08);
      border-color: rgba(45,108,223,.45);
      transform: translateY(-1px);
    }
    .fileLeft{ display:flex; align-items:baseline; gap:8px; }
    .fileLeft b{ font-weight: 900; }
    .fileLeft .muted{ color: var(--muted); font-size: 12px; font-weight: 700; }

    /* 레벨 가이드 */
    .levelGuide{
      border: 1px solid var(--line);
      border-radius: var(--R2);
      background: #fafbfc;
      padding: 14px;
      margin: 0 0 14px;
    }
    .levelGuide h3{
      margin: 0 0 6px;
      font-size: 14px;
      font-weight: 900;
    }
    .levelGuide p{
      margin: 0 0 10px;
      color: var(--muted);
      font-size: 12px;
      font-weight: 650;
      line-height: 1.5;
    }
    .levelTable{
      width:100%;
      border-collapse: collapse;
      overflow:hidden;
      border-radius: 12px;
      background:#fff;
    }
    .levelTable th, .levelTable td{
      border: 1px solid var(--line);
      padding: 10px 10px;
      font-size: 12px;
      vertical-align: top;
      background: #fff;
    }
    .levelTable th{
      background: #f3f4f6;
      font-weight: 900;
      color: #374151;
    }
    .levelTable td:first-child{
      width: 70px;
      text-align:center;
      font-weight: 900;
    }

    @media (max-width: 980px){
      .content{ grid-template-columns: 1fr; }
      .sidebar{ border-right:0; border-bottom:1px solid var(--line); }
      .main{ padding: 22px 18px; }
      .settingsGrid{
        grid-template-columns: 1fr;
        grid-template-areas:
      "photo"
      "info"
      "git"
      "blog"
      "edu"
      "port"
      "save";
      }
      .urlRow{ grid-template-columns: 1fr; }
      #positionButtons{ grid-template-columns: repeat(2, minmax(0, 1fr)); }
      .meta span{ max-width: 100%; white-space: normal; }
    }

  </style>
</head>

<body>
<jsp:include page="/WEB-INF/views/common/headerBase.jsp" />
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

        <section class="panel <%= "settings".equals(tab) ? "active" : "" %>" id="panel-settings">
          <div class="card-head">
            <div>
              <h2 class="title">프로필 기본 정보</h2>
              <p class="desc">프로필 기본 정보 수정 페이지 입니다.</p>
            </div>
          </div>

          <div class="form settingsWrap">
            <form id="basicAllForm"
                  method="post"
                  action="${pageContext.request.contextPath}/freelancer/profile/edit/all/save"
                  enctype="multipart/form-data">

              <input type="hidden" name="tab" value="settings"/>

              <div class="settingsGrid">


                <div class="setBox setPhoto">
                  <div class="setLabel">프로필 사진</div>

                  <div class="avatarLg">
                    <c:choose>
                      <c:when test="${not empty profile.profileImageUrl}">
                        <img id="avatarImg"
                             src="${pageContext.request.contextPath}${profile.profileImageUrl}?v=<%=System.currentTimeMillis()%>"
                             alt="profile"/>
                      </c:when>
                      <c:otherwise>
                        <div class="ph" id="avatarPh">No Image</div>
                      </c:otherwise>
                    </c:choose>
                  </div>

                  <input id="profileImageFile" type="file" name="profileImageFile" accept="image/*" style="display:none;" />

                  <div class="photoBtns">
                    <button type="button" class="btn ghost" id="btnChangeImg">사진변경</button>
                    <button type="button" class="btn danger" id="btnDeleteImg"
                            <c:if test="${empty profile.profileImageUrl}">disabled</c:if>>삭제</button>
                  </div>

                  <input type="hidden" name="deleteProfileImage" id="deleteProfileImage" value="false"/>
                </div>

                <div class="setBox setInfo">
                  <div class="setLabel">닉네임</div>
                  <input class="setInput" name="nickname"
                         value="${fn:escapeXml(profile.nickname)}" required />

                  <div style="height:12px;"></div>

                  <div class="setLabel">자기소개</div>
                  <textarea class="setTextarea" name="introduction"
                            placeholder="자기소개를 입력하세요.">${fn:escapeXml(profile.introduction)}</textarea>
                </div>

                <div class="urlRow">
                  <div class="setBox">
                    <div class="setLabel">Git URL</div>
                    <input class="setInput" name="githubUrl"
                           value="${fn:escapeXml(profile.githubUrl)}"
                           placeholder="https://github.com/..." />
                  </div>

                  <div class="setBox">
                    <div class="setLabel">블로그 URL</div>
                    <input class="setInput" name="websiteUrl"
                           value="${fn:escapeXml(profile.websiteUrl)}"
                           placeholder="https://..." />
                  </div>
                </div>

                <!-- 학력 -->
                <div class="setBox setEdu">
                  <div class="setLabel">학력</div>

                  <div class="eduGrid">
                    <input class="setInput" name="schoolName" placeholder="학교명"
                           value="${fn:escapeXml(profile.schoolName)}"/>
                    <input class="setInput" name="major" placeholder="전공"
                           value="${fn:escapeXml(profile.major)}"/>
                    <input class="setInput" name="degree" placeholder="학위 (예: 학사/석사/박사)"
                           value="${fn:escapeXml(profile.degree)}"/>
                    <input class="setInput" name="gradStatus" placeholder="졸업상태 (예: 졸업/재학/휴학/수료)"
                           value="${fn:escapeXml(profile.gradStatus)}"/>
                  </div>
                </div>

                <!-- 포트폴리오 -->
                <div class="setBox setPort">
                  <div class="setLabel">포트폴리오 파일</div>

                  <c:if test="${not empty profile.portfolioId}">
                    <div style="margin-bottom:10px; font-size:13px;">
                      현재 파일:
                      <a href="${pageContext.request.contextPath}${profile.portfolioUrl}" target="_blank" rel="noopener"
                         style="font-weight:900; color:var(--primary-deep); text-decoration:none;">
                        <c:out value="${profile.portfolioTitle}" />
                      </a>
                    </div>
                  </c:if>

                  <input id="portfolioFile" type="file" name="portfolioFile" style="display:none;" />
                  <input type="hidden" name="deletePortfolio" id="deletePortfolio" value="false"/>

                  <div id="pfDrop" class="fileBar" tabindex="0">
                    <div class="fileLeft">
                      <b>파일 선택</b>
                      <span id="portfolioName" class="muted">선택된 파일 없음</span>
                    </div>
                    <button type="button" class="btn ghost small" id="pfPick">찾기</button>
                  </div>

                  <div style="margin-top:10px; display:flex; justify-content:flex-end;">
                    <button type="button" class="btn danger small" id="btnPortfolioDelete"
                            <c:if test="${empty profile.portfolioId}">disabled</c:if>>삭제</button>
                  </div>
                </div>

                <div class="setSave">
                  <button class="btn primary" type="submit">저장</button>
                </div>

              </div>
            </form>
          </div>
        </section>

        <section class="panel <%= "position".equals(tab) ? "active" : "" %>" id="panel-position">
          <div class="card-head">
            <div>
              <h2 class="title">포지션</h2>
              <p class="desc">가능한 포지션을 선택하고 레벨과 경력을 입력하세요. 실무 경력이 없거나, 1년 미만의 경우 0년으로 기입해주세요.</p>
            </div>
          </div>

          <div class="levelGuide">
            <h3>포지션 레벨 기준표</h3>
            <p>포지션별로 “지금 실무에서 어느 정도까지 혼자 할 수 있는지” 기준으로 선택해주세요.</p>

            <table class="levelTable">
              <thead>
              <tr><th>레벨</th><th>명칭</th><th>설명</th></tr>
              </thead>
              <tbody>
              <tr><td>1</td><td>입문/초급</td><td>문법 및 기초 개념만 이해, 간단한 코드/수정만 가능</td></tr>
              <tr><td>2</td><td>기초</td><td>기본적인 CRUD, 단순 기능 구현 가능, 문서/예제 참고 필요</td></tr>
              <tr><td>3</td><td>중급</td><td>실무 프로젝트 투입 가능, 독립적 기능 구현, 오류 해결 가능</td></tr>
              <tr><td>4</td><td>고급</td><td>복잡한 로직/구조 설계, 코드 리뷰/리딩, 성능 개선 가능</td></tr>
              <tr><td>5</td><td>전문가</td><td>아키텍처 설계, 기술 리딩, 최적화, 타인 멘토링 가능</td></tr>
              </tbody>
            </table>
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
                          <c:when test="${p.stackName eq '웹'}">&#x1F5A5;&#xFE0F;</c:when>
                          <c:when test="${p.stackName eq '모바일앱'}">&#x1F4F1;</c:when>
                          <c:when test="${p.stackName eq '데이터베이스'}">&#x1F5C4;&#xFE0F;</c:when>
                          <c:when test="${p.stackName eq 'DevOps/인프라'}">&#x2699;&#xFE0F;</c:when>
                          <c:when test="${p.stackName eq '게임/그래픽'}">&#x1F3AE;</c:when>
                          <c:when test="${p.stackName eq 'AI/빅데이터'}">&#x1F916;</c:when>
                          <c:when test="${p.stackName eq '임베디드/하드웨어'}">&#x1F527;</c:when>
                          <c:otherwise>&#x1F3B8;</c:otherwise>
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


        <section class="panel <%= "skill".equals(tab) ? "active" : "" %>" id="panel-skill">
          <div class="card-head">
            <div>
              <h2 class="title">스킬</h2>
              <p class="desc">보유 스킬을 선택하고 레벨과 경력을 입력하세요. 실무 경력이 없거나, 1년 미만의 경우 0년으로 기입해주세요.</p>
            </div>
          </div>

          <div class="levelGuide">
            <h3>기술스택 레벨 기준표</h3>
            <p>스킬별로 “지금 실무에서 어느 정도까지 혼자 할 수 있는지” 기준으로 선택해주세요.</p>

            <table class="levelTable">
              <thead>
              <tr><th>레벨</th><th>명칭</th><th>설명</th></tr>
              </thead>
              <tbody>
              <tr><td>1</td><td>입문/초급</td><td>문법 및 기초 개념만 이해, 간단한 코드/수정만 가능</td></tr>
              <tr><td>2</td><td>기초</td><td>기본적인 CRUD, 단순 기능 구현 가능, 문서/예제 참고 필요</td></tr>
              <tr><td>3</td><td>중급</td><td>실무 프로젝트 투입 가능, 독립적 기능 구현, 오류 해결 가능</td></tr>
              <tr><td>4</td><td>고급</td><td>복잡한 로직/구조 설계, 코드 리뷰/리딩, 성능 개선 가능</td></tr>
              <tr><td>5</td><td>전문가</td><td>아키텍처 설계, 기술 리딩, 최적화, 타인 멘토링 가능</td></tr>
              </tbody>
            </table>
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
              <button type="button" class="btn primary" id="skillSearchBtn">검색</button>
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


        <section class="panel <%= "career".equals(tab) ? "active" : "" %>" id="panel-career">
          <div class="card-head">
            <div>
              <h2 class="title">경력</h2>
              <p class="desc">추가 혹은 수정 버튼을 누르면 입력폼이 열립니다.</p>
            </div>

            <div class="head-actions">
              <button type="button" class="btn primary" id="careerAddToggle">+ 추가</button>
            </div>
          </div>

          <div class="form">
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

            <div class="sel">
              <div class="title" style="font-size:16px;">내 보유 경력</div>
              <div class="hint">저장된 회사 경력 목록입니다.</a</div>
            </div>

            <div class="list" id="careerList">
              <c:forEach var="c" items="${careers}">
                <div class="itemWrap" data-career-id="${c.careerId}">
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


        <section class="panel <%= "external".equals(tab) ? "active" : "" %>" id="panel-external">
          <div class="card-head">
            <div>
              <h2 class="title">외부 프로젝트</h2>
              <p class="desc">추가 혹은 수정 버튼을 누르면 입력폼이 열립니다.</p>
            </div>

            <div class="head-actions">
              <button type="button" class="btn primary" id="expAddToggle">+ 추가</button>
            </div>
          </div>

          <div class="form">
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
                  <label>클라이언트명</label>
                  <input name="clientName" type="text" placeholder="예) ○○회사" />
                </div>
                <div class="row">
                  <label>시작일</label>
                  <input name="startDate" type="date" required />
                </div>
                <div class="row">
                  <label>종료일</label>
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
                        <label>클라이언트명</label>
                        <input name="clientName" type="text" value="${fn:escapeXml(e.clientName)}"/>
                      </div>
                      <div class="row">
                        <label>시작일</label>
                        <input name="startDate" type="date" required value="${e.startDate}"/>
                      </div>
                      <div class="row">
                        <label>종료일</label>
                        <input name="endDate" type="date" value="${e.endDate}"/>
                      </div>
                      <div class="row">
                        <label>역할</label>
                        <input name="role" type="text" required value="${fn:escapeXml(e.role)}"/>
                      </div>
                      <div class="row full">
                        <label>설명</label>
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

  const initSkills = [
    <c:forEach var="x" items="${mySkills}" varStatus="st">
    {"stackId": ${x.stackId}, "name": "${fn:escapeXml(x.stackName)}", "level": ${x.stackLevel}, "years": ${x.stackYear}}${st.last ? "" : ","}
    </c:forEach>
  ];
  const initPositions = [
    <c:forEach var="x" items="${myPositions}" varStatus="st">
    {
      "stackId": ${x.stackId},
      "name": "${fn:escapeXml(x.stackName)}",
      "level": ${empty x.stackLevel ? 1 : x.stackLevel},
      "years": ${empty x.stackYear ? 0 : x.stackYear}
    }${st.last ? "" : ","}
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
              '<span style="font-weight:800; font-size:12px; color:var(--muted);">Level</span>' +
              '<select class="skillLevel" data-id="'+v.stackId+'" style="width:auto;">' + levelOptions(v.level) + '</select>' +
              '<span style="font-weight:800; font-size:12px; color:var(--muted);">경력</span>' +
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
              '<span style="font-weight:800; font-size:12px; color:var(--muted);">Level</span>' +
              '<select class="posLevel" data-id="'+v.stackId+'" style="width:auto;">' + levelOptions(v.level) + '</select>' +
              '<span style="font-weight:800; font-size:12px; color:var(--muted);">경력</span>' +
              '<input type="number" min="0" step="1" class="posYears" data-id="'+v.stackId+'" value="'+Number(v.years||0)+'" style="width:90px"/> <span>년</span>' +
              '<button type="button" class="btn danger small removePos" data-id="'+v.stackId+'">X</button>' +
              '</div>';
      box.appendChild(div);
    });
  }

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
    if(e.target.classList.contains("posLevel")){
      const id = String(e.target.dataset.id);
      const v = myPositions.get(id);
      if(v) v.level = Number(e.target.value || 1);
    }
    if(e.target.classList.contains("posYears")){
      const id = String(e.target.dataset.id);
      const v = myPositions.get(id);
      if(v) v.years = Math.max(0, Number(e.target.value || 0));
    }
  });

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

  renderSkills();
  renderPositions();

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

  (function(){
    const serverMsg = "<c:out value='${msg}' default='' />";
    if(serverMsg && serverMsg.trim().length > 0){
      showToast(serverMsg.trim(), 2000);
    }
  })();

  (function(){
    const form = document.getElementById("basicAllForm");
    if(!form) return;

    const imgInput = document.getElementById("profileImageFile");
    const btnChange = document.getElementById("btnChangeImg");
    const btnDelete = document.getElementById("btnDeleteImg");
    const delFlag = document.getElementById("deleteProfileImage");

    btnChange?.addEventListener("click", () => imgInput?.click());

    imgInput?.addEventListener("change", () => {
      if(!imgInput.files || imgInput.files.length === 0) return;
      delFlag.value = "false";
      const file = imgInput.files[0];
      const url = URL.createObjectURL(file);

      const avatar = document.querySelector(".avatarLg");
      const oldImg = document.getElementById("avatarImg");
      const ph = document.getElementById("avatarPh");

      if(ph) ph.style.display = "none";

      if(oldImg){
        oldImg.src = url;
        oldImg.style.display = "block";
      }else if(avatar){
        avatar.innerHTML = "";
        const newImg = document.createElement("img");
        newImg.id = "avatarImg";
        newImg.alt = "profile";
        newImg.src = url;
        avatar.appendChild(newImg);
      }

      showToast("프로필 이미지가 선택됐어요. 저장을 누르면 반영됩니다.", 1800);
    });

    btnDelete?.addEventListener("click", () => {
      if(btnDelete.disabled) return;
      if(!confirm("프로필 이미지를 삭제할까요?")) return;
      delFlag.value = "true";
      if(imgInput) imgInput.value = "";
      const avatar = document.querySelector(".avatarLg");
      if(avatar){
        avatar.innerHTML = '<div class="ph" id="avatarPh">No Image</div>';
      }
      showToast("프로필 이미지 삭제 예약됨. 저장을 누르면 반영됩니다.", 1800);
    });

    (function(){
      const pfDrop = document.getElementById("pfDrop");
      const pf = document.getElementById("portfolioFile");
      const pfName = document.getElementById("portfolioName");
      const pfPick = document.getElementById("pfPick");

      if(!pfDrop || !pf || !pfName) return;
      if(pfDrop.dataset.bound === "1") return;
      pfDrop.dataset.bound = "1";

      ["dragenter","dragover","dragleave","drop"].forEach(evt=>{
        window.addEventListener(evt, (e)=>{ e.preventDefault(); }, false);
        document.addEventListener(evt, (e)=>{ e.preventDefault(); }, false);
      });

      pfPick?.addEventListener("click", (e)=>{
        e.preventDefault();
        e.stopPropagation();
        pf.click();
      });

      pfDrop.addEventListener("click", (e)=>{
        if(e.target.closest("button")) return;
        pf.click();
      });

      pf.addEventListener("change", ()=>{
        if(pf.files && pf.files.length > 0){
          pfName.textContent = pf.files[0].name;
        }else{
          pfName.textContent = "선택된 파일 없음";
        }
      });

      pfDrop.addEventListener("dragover", ()=> pfDrop.classList.add("dragover"));
      pfDrop.addEventListener("dragleave", ()=> pfDrop.classList.remove("dragover"));

      pfDrop.addEventListener("drop", (e)=>{
        pfDrop.classList.remove("dragover");
        const files = e.dataTransfer?.files;
        if(!files || files.length === 0) return;

        const dt = new DataTransfer();
        dt.items.add(files[0]);
        pf.files = dt.files;

        pfName.textContent = files[0].name;
      });
    })();

    (function(){
      const btnDel = document.getElementById("btnPortfolioDelete");
      const delFlag = document.getElementById("deletePortfolio");
      const pf = document.getElementById("portfolioFile");
      const pfName = document.getElementById("portfolioName");

      if(!btnDel || !delFlag) return;

      btnDel.addEventListener("click", () => {
        if(btnDel.disabled) return;
        if(!confirm("포트폴리오 파일을 삭제할까요?")) return;

        delFlag.value = "true";
        if(pf) pf.value = "";
        if(pfName) pfName.textContent = "선택된 파일 없음";

        showToast("포트폴리오 삭제 예약됨. 저장을 누르면 반영됩니다.", 1800);
      });

      pf?.addEventListener("change", () => {
        if(pf.files && pf.files.length > 0){
          delFlag.value = "false";
        }
      });
    })();

  })();
</script>

</body>
</html>
