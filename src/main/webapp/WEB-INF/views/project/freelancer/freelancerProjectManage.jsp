<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>내 프로젝트 관리</title>

  <style>
    :root{
      --bg:#f6f7fb; --card:#fff; --text:#111827; --muted:#6b7280; --line:#e5e7eb;
      --primary:#1a9aa6; --primary-weak:rgba(26,154,166,.12);
      --shadow:0 20px 60px rgba(17,24,39,.08);
      --radius:18px;
      --ok:#22c55e; --warn:#f59e0b; --info:#3b82f6; --danger:#ef4444;
    }
    *{ box-sizing:border-box; }
    body{
      margin:0;
      font-family:-apple-system,BlinkMacSystemFont,"Apple SD Gothic Neo","Noto Sans KR",Segoe UI,Roboto,Helvetica,Arial,sans-serif;
      background:var(--bg);
      color:var(--text);
    }
    .wrap{ max-width:1180px; margin:26px auto 70px; padding:0 18px; }

    .pageTitle{ display:flex; align-items:flex-end; justify-content:space-between; gap:16px; }
    .h1{ font-size:34px; font-weight:950; letter-spacing:-.5px; margin:0; }
    .sub{ margin:6px 0 0; color:var(--muted); font-weight:800; }

    .btn{
      border:none; border-radius:14px; padding:12px 14px; font-weight:950; cursor:pointer; font-size:13px;
      display:inline-flex; align-items:center; gap:8px; white-space:nowrap;
    }
    .btn.primary{ background:var(--primary); color:#fff; box-shadow:0 14px 30px rgba(26,154,166,.22); }
    .btn.ghost{ background:#fff; border:1px solid var(--line); color:#111827; }
    .btn:hover{ filter:brightness(.985); }

    .gridTop{
      margin-top:18px;
      display:grid;
      grid-template-columns: 1.2fr 1fr 1fr;
      gap:14px;
    }
    .stat{
      background:var(--card);
      border:1px solid rgba(229,231,235,.75);
      box-shadow:var(--shadow);
      border-radius:22px;
      padding:16px 18px;
      min-height:110px;
      position:relative;
      overflow:hidden;
    }
    .stat .label{ color:var(--muted); font-weight:950; font-size:13px; display:flex; gap:8px; align-items:center; }
    .dot{ width:8px; height:8px; border-radius:999px; background:var(--info); }
    .dot.warn{ background:var(--warn); }
    .dot.ok{ background:var(--ok); }

    .stat .value{ margin-top:10px; font-size:34px; font-weight:950; letter-spacing:-.6px; }
    .stat .small{
      margin-top:8px; display:inline-flex; gap:8px; align-items:center;
      padding:8px 10px; border-radius:999px; background:var(--primary-weak); color:#0b6e76;
      font-weight:950; font-size:12px;
    }

    .main{
      margin-top:16px;
      display:grid;
      grid-template-columns: 420px 1fr;
      gap:14px;
      align-items:start;
    }

    .panel{
      background:var(--card);
      border:1px solid rgba(229,231,235,.75);
      box-shadow:var(--shadow);
      border-radius:22px;
      padding:16px 16px;
    }
    .panel h3{ margin:0 0 12px; font-size:14px; font-weight:950; }

    /*!* Tabs *!*/
    /*.tabs{*/
    /*  display:flex; gap:10px; align-items:center;*/
    /*  border-bottom:1px solid rgba(229,231,235,.9);*/
    /*  padding-bottom:10px;*/
    /*  margin-bottom:12px;*/
    /*  overflow:auto;*/
    /*}*/

    /* Tabs: 왼쪽(탭) + 오른쪽(상세관리 버튼) */
    .tabs{
      display:flex;
      align-items:center;
      justify-content:space-between; /* 핵심 */
      gap:10px;
      border-bottom:1px solid rgba(229,231,235,.9);
      padding-bottom:10px;
      margin-bottom:12px;
    }

    /* 탭 3개를 한 덩어리로 */
    .tabGroup{
      display:flex;
      gap:10px;
      align-items:center;
      overflow:auto;
    }

    /* 오른쪽 버튼 영역 */
    .tabsRight{
      margin-left:auto;
      display:flex;
      align-items:center;
      gap:10px;
      flex-shrink:0;
    }

    .tab{
      padding:10px 12px;
      border-radius:999px;
      font-weight:950;
      font-size:13px;
      color:#374151;
      border:1px solid transparent;
      text-decoration:none;
      white-space:nowrap;
    }
    .tab.active{
      background:var(--primary-weak);
      border-color:rgba(26,154,166,.25);
      color:#0b6e76;
    }

    /* Calendar */
    .calHead{
      display:flex; align-items:center; justify-content:space-between; gap:12px;
      margin-bottom:10px;
    }
    .calNav{ display:flex; gap:8px; align-items:center; }
    .calNav .btn{ padding:10px 12px; }
    .ym{ font-weight:950; font-size:16px; letter-spacing:-.3px; }

    .calGrid{
      display:grid;
      grid-template-columns: repeat(7, 1fr);
      gap:8px;
      user-select:none;
    }
    .dow{
      text-align:center; font-size:12px; font-weight:950; color:var(--muted);
      padding:6px 0;
    }
    .day{
      background:#fff;
      border:1px solid rgba(229,231,235,.85);
      border-radius:14px;
      min-height:52px;
      padding:8px 9px;
      position:relative;
      cursor:pointer;
    }
    .day.muted{ opacity:.35; cursor:default; }
    .day .n{ font-weight:950; font-size:13px; }
    .day .marks{ position:absolute; left:9px; bottom:8px; display:flex; gap:4px; }
    .mk{ width:6px; height:6px; border-radius:999px; background:var(--info); }
    .mk.start{ background:var(--ok); }
    .mk.milestone{ background:var(--warn); }
    .mk.end{ background:var(--danger); }
    .day.selected{ outline:2px solid rgba(26,154,166,.35); background:rgba(26,154,166,.06); }

    .eventList{ margin-top:12px; display:flex; flex-direction:column; gap:8px; }
    .evt{
      border:1px solid rgba(229,231,235,.85);
      border-radius:14px;
      padding:10px 10px;
      background:linear-gradient(180deg,#fff 0%, #fbfdff 100%);
      cursor:pointer;
    }
    .evt:hover{ filter:brightness(.99); }
    .evt .t{
      font-weight:950;
      font-size:13px;
      display:flex;
      flex-direction:column;   /* 줄바꿈 핵심 */
      align-items:flex-start;  /* 왼쪽 정렬 */
      gap:6px;
    }
    .evt .t span{
      display:block;           /* 제목을 한 줄 블록으로 */
      line-height:1.25;
      word-break:keep-all;
    }

    .evt .s{ color:var(--muted); font-weight:850; font-size:12px; margin-top:6px; }
    .pill{
      display:inline-flex; align-items:center;
      padding:4px 8px; border-radius:999px;
      font-weight:950; font-size:11px;
      border:1px solid rgba(229,231,235,.85);
      background:rgba(17,24,39,.03);
      color:#374151;
    }
    .pill.start{ background:rgba(34,197,94,.12); border-color:rgba(34,197,94,.22); color:#0f7a3a; }
    .pill.milestone{ background:rgba(245,158,11,.12); border-color:rgba(245,158,11,.22); color:#9a5a00; }
    .pill.end{ background:rgba(239,68,68,.12); border-color:rgba(239,68,68,.22); color:#b91c1c; }

    /* Project cards */
    .cards{ display:flex; flex-direction:column; gap:12px; }
    .card{
      border:1px solid rgba(229,231,235,.85);
      border-radius:18px;
      padding:14px 14px;
      background:#fff;
    }
    .cardTop{
      display:flex; align-items:flex-start; justify-content:space-between; gap:12px; flex-wrap:wrap;
    }
    .title{ font-weight:950; font-size:16px; letter-spacing:-.2px; }
    .client{ margin-top:6px; color:var(--muted); font-weight:850; font-size:12px; }

    .badge{
      display:inline-flex; align-items:center; gap:8px;
      padding:8px 10px;
      border-radius:999px;
      background:rgba(17,24,39,.04);
      border:1px solid rgba(229,231,235,.85);
      font-weight:950; font-size:12px; color:#374151;
    }
    .badge.warn{ background:rgba(245,158,11,.12); border-color:rgba(245,158,11,.22); color:#9a5a00; }
    .badge.ok{ background:rgba(34,197,94,.12); border-color:rgba(34,197,94,.22); color:#0f7a3a; }
    .badge.info{ background:rgba(59,130,246,.12); border-color:rgba(59,130,246,.22); color:#1d4ed8; }

    .metaRow{
      margin-top:12px;
      display:grid;
      grid-template-columns: 1.1fr 1.1fr .8fr .9fr;
      gap:10px;
      align-items:center;
    }
    .k{ color:var(--muted); font-size:11px; font-weight:950; }
    .v{ margin-top:5px; font-weight:950; font-size:13px; }

    .progressWrap{ display:flex; align-items:center; gap:10px; }
    .bar{ height:6px; background:rgba(17,24,39,.08); border-radius:999px; overflow:hidden; flex:1; }
    .bar > span{ display:block; height:100%; background:var(--primary); width:0; }
    .pct{ font-weight:950; font-size:12px; color:#0b6e76; }

    .actions{
      margin-top:12px;
      display:flex; gap:10px; justify-content:flex-end; flex-wrap:wrap;
    }


    @media (max-width: 980px){
      .gridTop{ grid-template-columns:1fr; }
      .main{ grid-template-columns:1fr; }
      .metaRow{ grid-template-columns:1fr 1fr; }
      .btn{ justify-content:center; }
    }
  </style>
</head>

<body>
<jsp:include page="/WEB-INF/views/common/headerBase.jsp" />
<div class="wrap">

  <div class="pageTitle">
    <div>
      <h1 class="h1">내 프로젝트 관리</h1>
      <p class="sub">캘린더로 계약/마일스톤 일정을 확인하고 프로젝트를 효율적으로 관리하세요.</p>
    </div>

    <a class="btn primary" href="${pageContext.request.contextPath}/project/bookmark" style="text-decoration:none;">
      북마크 목록
    </a>
  </div>

  <!-- Top Summary -->
  <div class="gridTop">
    <div class="stat">
      <div class="label"><span class="dot info"></span> 진행 중</div>
      <div class="value"><c:out value="${summary.inProgressCount}"/></div>
      <div class="small">예상 수익 ₩ <fmt:formatNumber value="${summary.expectedRevenue}" type="number" groupingUsed="true"/></div>

    </div>

    <div class="stat">
      <div class="label"><span class="dot warn"></span> 지원한 프로젝트</div>
      <div class="value"><c:out value="${summary.appliedCount}"/></div>
    </div>

    <div class="stat">
      <div class="label"><span class="dot ok"></span> 완료된 프로젝트</div>
      <div class="value"><c:out value="${summary.completedCount}"/></div>
    </div>
  </div>

  <div class="main">

    <!-- LEFT: Calendar -->
    <div class="panel">
      <div class="calHead">
        <div class="ym" id="ymText"></div>
        <div class="calNav">
          <button class="btn ghost" type="button" id="prevBtn">◀</button>
          <button class="btn ghost" type="button" id="todayBtn">오늘</button>
          <button class="btn ghost" type="button" id="nextBtn">▶</button>
        </div>
      </div>

      <div class="calGrid" id="calGrid">
        <div class="dow">S</div><div class="dow">M</div><div class="dow">T</div><div class="dow">W</div>
        <div class="dow">T</div><div class="dow">F</div><div class="dow">S</div>
        <!-- days injected -->
      </div>

      <h3 style="margin-top:16px;">선택한 날짜 일정</h3>
      <div class="eventList" id="eventList">
        <div style="color:var(--muted); font-weight:900; font-size:13px;">날짜를 선택하면 일정이 표시됩니다.</div>
      </div>
    </div>

    <!-- RIGHT: Tabs + List -->
    <div class="panel">

      <div class="tabs">
        <div class="tabGroup">
          <a class="tab ${tab eq 'inProgress' ? 'active' : ''}"
             href="${pageContext.request.contextPath}/freelancer/project/manage?tab=inProgress&ym=${ym}">
            진행 중 (<c:out value="${summary.inProgressCount}"/>)
          </a>
          <a class="tab ${tab eq 'applied' ? 'active' : ''}"
             href="${pageContext.request.contextPath}/freelancer/project/manage?tab=applied&ym=${ym}">
            지원한 (<c:out value="${summary.appliedCount}"/>)
          </a>
          <a class="tab ${tab eq 'completed' ? 'active' : ''}"
             href="${pageContext.request.contextPath}/freelancer/project/manage?tab=completed&ym=${ym}">
            완료 (<c:out value="${summary.completedCount}"/>)
          </a>
        </div>

        <div class="tabsRight">
          <a class="btn primary"
             href="${pageContext.request.contextPath}/freelancer/project/detail"
             style="text-decoration:none;">
            상세 관리
          </a>
        </div>
      </div>


      <div class="cards">
        <!-- 진행중 -->
        <c:if test="${tab eq 'inProgress'}">
          <c:if test="${empty inProgressList}">
            <div style="color:var(--muted); font-weight:900; padding:14px;">진행 중인 프로젝트가 없습니다.</div>
          </c:if>

          <c:forEach var="p" items="${inProgressList}">
            <div class="card">
              <div class="cardTop">
                <div>
                  <div class="title"><c:out value="${p.title}"/></div>
                  <div class="client">클라이언트: <c:out value="${p.clientName}"/></div>
                </div>

                <div class="badge info">
                  계약 종료까지
                  <c:if test="${p.dday ne null}">
                    · D-<c:out value="${p.dday}"/>
                  </c:if>
                </div>
              </div>

              <div class="metaRow">
                <div>
                  <div class="k">계약 기간</div>
                  <div class="v"><c:out value="${p.startDate}"/> ~ <c:out value="${p.endDate}"/></div>
                </div>

                <div>
                  <div class="k">다음 마일스톤</div>
                  <div class="v">
                    <c:choose>
                      <c:when test="${not empty p.nextMilestoneName}">
                        <c:out value="${p.nextMilestoneName}"/>
                        <c:if test="${not empty p.nextMilestoneDueDate}">
                          · <c:out value="${p.nextMilestoneDueDate}"/>
                        </c:if>
                      </c:when>
                      <c:otherwise>없음</c:otherwise>
                    </c:choose>
                  </div>
                </div>

                <div>
                  <div class="k">진척도</div>
                  <div class="v">
                    <div class="progressWrap">
                      <div class="bar"><span style="width:${p.progressPercent}%;"></span></div>
                      <div class="pct"><c:out value="${p.progressPercent}"/>%</div>
                    </div>
                  </div>
                </div>

                <div>
                  <div class="k">계약 금액</div>
                  <div class="v">
                    ₩ <fmt:formatNumber value="${p.totalBudget}" type="number" groupingUsed="true"/>
                  </div>

                </div>
              </div>

              <div class="actions">
                <a class="btn ghost" href="${pageContext.request.contextPath}/chat/list" style="text-decoration:none;">메시지</a>
              </div>
            </div>
          </c:forEach>
        </c:if>

        <!-- 지원 -->
        <c:if test="${tab eq 'applied'}">
          <c:if test="${empty appliedList}">
            <div style="color:var(--muted); font-weight:900; padding:14px;">지원한 프로젝트가 없습니다.</div>
          </c:if>

          <c:forEach var="p" items="${appliedList}">
            <div class="card">
              <div class="cardTop">
                <div>
                  <div class="title"><c:out value="${p.title}"/></div>
                  <div class="client">클라이언트: <c:out value="${p.clientName}"/></div>
                </div>

                <div class="badge warn">
                  공고 마감
                  <c:if test="${p.dday ne null}">
                    · D-<c:out value="${p.dday}"/>
                  </c:if>
                </div>
              </div>

              <div class="metaRow">
                <div>
                  <div class="k">예상 시작</div>
                  <div class="v"><c:out value="${p.startDate}"/></div>
                </div>

                <div>
                  <div class="k">마감</div>
                  <div class="v"><c:out value="${p.endDate}"/></div>
                </div>

                <div>
                  <div class="k"> </div>
                  <div class="v"> </div>
                </div>

                <div>
                  <div class="k">예산</div>
                  <div class="v">₩ <fmt:formatNumber value="${p.totalBudget}" type="number" groupingUsed="true"/></div>

                </div>
              </div>

              <div class="actions">
                <a class="btn ghost" href="${pageContext.request.contextPath}/project/detail?projectId=${p.projectId}" style="text-decoration:none;">공고 보기</a>
              </div>
            </div>
          </c:forEach>
        </c:if>

        <!-- 완료 -->
        <c:if test="${tab eq 'completed'}">
          <c:if test="${empty completedList}">
            <div style="color:var(--muted); font-weight:900; padding:14px;">완료된 프로젝트가 없습니다.</div>
          </c:if>

          <c:forEach var="p" items="${completedList}">
            <div class="card">
              <div class="cardTop">
                <div>
                  <div class="title"><c:out value="${p.title}"/></div>
                  <div class="client">클라이언트: <c:out value="${p.clientName}"/></div>
                </div>

                <div class="badge ok">완료</div>
              </div>

              <div class="metaRow">
                <div>
                  <div class="k">계약 기간</div>
                  <div class="v"><c:out value="${p.startDate}"/> ~ <c:out value="${p.endDate}"/></div>
                </div>

                <div>
                  <div class="k">마지막 진행률</div>
                  <div class="v"><c:out value="${p.progressPercent}"/>%</div>
                </div>

                <div>
                  <div class="k">총 금액</div>
                  <div class="v">₩ <fmt:formatNumber value="${p.totalBudget}" type="number" groupingUsed="true"/></div>
                </div>

                <div>
                  <div class="k">후기/평가</div>
                  <div class="v">추후 연동</div>
                </div>
              </div>

              <div class="actions">
                <a class="btn ghost" href="${pageContext.request.contextPath}/contract/detail?contractId=${p.contractId}" style="text-decoration:none;">상세 보기</a>
                <a class="btn primary" href="${pageContext.request.contextPath}/freelancer/project/detail?tab=reviews&contractId=${p.contractId}" style="text-decoration:none;">리뷰 보기</a>
              </div>
            </div>
          </c:forEach>
        </c:if>

      </div>
    </div>
  </div>
</div>
<!-- ===== 캘린더 이벤트 데이터(숨김) : JS 문자열 삽입 금지 버전 ===== -->
<div id="evDataWrap" style="display:none;">
  <c:forEach var="ev" items="${events}">
    <div class="evData"
         data-date="<c:out value='${ev.date}'/>"
         data-type="<c:out value='${ev.type}'/>"
         data-title="<c:out value='${ev.title}'/>"
         data-project-id="<c:out value='${ev.projectId}'/>"
         data-contract-id="<c:out value='${ev.contractId}'/>"
         data-milestone-id="<c:out value='${ev.milestoneId}'/>"
         data-step-order="<c:out value='${ev.stepOrder}'/>">
    </div>
  </c:forEach>
</div>

<script>
  const ctx = "${pageContext.request.contextPath}";

  // ===== data-*에서 events 읽어서 날짜별로 쌓기 (JS 문자열 깨짐 방지) =====
  const calendarEvents = {}; // { "2026-01-16": [ ... ] }

  function normalizeType(t){
    if(!t) return "milestone";
    if(t === "MILESTONE") return "milestone";
    if(t === "CONTRACT_START") return "start";
    if(t === "CONTRACT_END") return "end";
    return "milestone";
  }

  document.querySelectorAll("#evDataWrap .evData").forEach(el => {
    const date = (el.dataset.date || "").trim();
    if(!date) return;

    const type = normalizeType((el.dataset.type || "").trim());
    const title = (el.dataset.title || "").trim();

    const projectId = el.dataset.projectId ? Number(el.dataset.projectId) : null;
    const contractId = el.dataset.contractId ? Number(el.dataset.contractId) : null;
    const milestoneId = el.dataset.milestoneId ? Number(el.dataset.milestoneId) : null;
    const stepOrder = el.dataset.stepOrder ? Number(el.dataset.stepOrder) : null;

    if(!calendarEvents[date]) calendarEvents[date] = [];
    calendarEvents[date].push({ date, type, title, projectId, contractId, milestoneId, stepOrder });
  });

  // ===== 기본 상태 =====
  let current = new Date();
  let selectedDate = null;

  // 서버에서 내려준 ym(예: 2026-01)이 있으면 그 달로 시작
  <c:if test="${not empty ym}">
  current = new Date("${ym}-01T00:00:00");
  </c:if>

  const calGrid = document.getElementById('calGrid');
  const ymText = document.getElementById('ymText');
  const eventList = document.getElementById('eventList');

  function pad(n){ return n < 10 ? '0' + n : '' + n; }
  function fmtDate(d){ return d.getFullYear() + '-' + pad(d.getMonth()+1) + '-' + pad(d.getDate()); }
  function fmtYm(d){ return d.getFullYear() + '-' + pad(d.getMonth()+1); }

  function renderCalendar(){
    // 기존 day 제거
    calGrid.querySelectorAll('.day').forEach(d => d.remove());

    const y = current.getFullYear();
    const m = current.getMonth();
    ymText.innerText = y + '년 ' + (m+1) + '월';

    const firstDay = new Date(y, m, 1);
    const startDow = firstDay.getDay();
    const lastDate = new Date(y, m+1, 0).getDate();

    // 앞쪽 padding
    for(let i=0;i<startDow;i++){
      const d = document.createElement('div');
      d.className = 'day muted';
      calGrid.appendChild(d);
    }

    for(let day=1; day<=lastDate; day++){
      const date = new Date(y, m, day);
      const key = fmtDate(date);

      const cell = document.createElement('div');
      cell.className = 'day';
      cell.dataset.date = key;

      const n = document.createElement('div');
      n.className = 'n';
      n.innerText = day;
      cell.appendChild(n);

      const list = calendarEvents[key];
      if(list && list.length > 0){
        const marks = document.createElement('div');
        marks.className = 'marks';

        // type별 점 1개씩
        const seen = {};
        list.forEach(ev => {
          if(seen[ev.type]) return;
          seen[ev.type] = true;
          const mk = document.createElement('span');
          mk.className = 'mk ' + ev.type; // start/milestone/end
          marks.appendChild(mk);
        });

        cell.appendChild(marks);
      }

      cell.onclick = () => selectDate(cell, key);
      calGrid.appendChild(cell);
    }

    // 선택 유지
    if(selectedDate){
      const sel = document.querySelector('.day[data-date="'+selectedDate+'"]');
      if(sel) selectDate(sel, selectedDate, true);
    }
  }

  function selectDate(cell, key, silent){
    document.querySelectorAll('.day.selected').forEach(d => d.classList.remove('selected'));
    cell.classList.add('selected');
    selectedDate = key;
    renderEvents(key);
  }

  function pillHtml(type, stepOrder){
    if(type === "start") return '<span class="pill start">계약 시작</span>';
    if(type === "end") return '<span class="pill end">계약 종료</span>';
    // milestone
    const step = (stepOrder != null) ? (' ' + stepOrder + '단계') : '';
    return '<span class="pill milestone">마일스톤' + step + '</span>';
  }

  function renderEvents(key){
    eventList.innerHTML = '';
    const list = calendarEvents[key];

    if(!list || list.length === 0){
      eventList.innerHTML =
              '<div style="color:var(--muted); font-weight:900; font-size:13px;">일정이 없습니다.</div>';
      return;
    }

    const order = { start: 0, milestone: 1, end: 2 };
    list.sort((a,b) => (order[a.type] ?? 9) - (order[b.type] ?? 9));

    list.forEach(ev => {
      const div = document.createElement('div');
      div.className = 'evt';
      div.innerHTML = `
        <div class="t">\${pillHtml(ev.type, ev.stepOrder)} <span>\${escapeHtml(ev.title)}</span></div>
        <div class="s">\${key}</div>
      `;

      div.onclick = () => {
        if(ev.contractId){
          window.location.href = ctx + "/contract/detail?contractId=" + ev.contractId;
          return;
        }
        if(ev.projectId){
          window.location.href = ctx + "/project/detail?projectId=" + ev.projectId;
        }
      };

      eventList.appendChild(div);
    });
  }

  // title을 innerHTML에 넣을 때 안전 처리
  function escapeHtml(str){
    return String(str ?? '')
            .replaceAll('&','&amp;')
            .replaceAll('<','&lt;')
            .replaceAll('>','&gt;')
            .replaceAll('"','&quot;')
            .replaceAll("'","&#39;");
  }

  // ===== 월 이동: (핵심) 서버에 ym으로 다시 요청해서 events를 새로 받아오기 =====
  function goMonth(delta){
    const d = new Date(current);
    d.setMonth(d.getMonth() + delta);

    const nextYm = fmtYm(d);
    const tab = "${tab}";
    window.location.href = ctx + "/freelancer/project/manage?tab=" + encodeURIComponent(tab) + "&ym=" + nextYm;
  }

  document.getElementById('prevBtn').onclick = () => goMonth(-1);
  document.getElementById('nextBtn').onclick = () => goMonth(1);

  document.getElementById('todayBtn').onclick = () => {
    const d = new Date();
    const tab = "${tab}";
    window.location.href = ctx + "/freelancer/project/manage?tab=" + encodeURIComponent(tab) + "&ym=" + fmtYm(d);
  };

  // 최초 렌더
  renderCalendar();
</script>


</body>
</html>
