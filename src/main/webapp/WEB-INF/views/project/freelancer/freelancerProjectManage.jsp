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

    html, body { height: 100%; }
    body { background: #f5f6f8; }
    .pm{
      --primary:#173160;
      --primary-weak: rgba(59,111,220,.10);
      --primary-bd:   rgba(59,111,220,.22);

      --bg:#f6f6f8;
      --card:#ffffff;
      --text:#0f172a;
      --muted:#64748b;

      --line:#e2e8f0;
      --line2:#cbd5e1;

      --shadow: 0 6px 18px rgba(15,23,42,.05);

      --outer-radius: 10px;
      --inner-radius: 999px;

      --ok:#16a34a;
      --warn:#f59e0b;
      --info:#3b6fdc;
      --danger:#ef4444;

      --ghost-bg:#e5e7eb;
      --ghost-fg:#111827;
      --ghost-bd:#cbd5e1;

      font-family:-apple-system,BlinkMacSystemFont,"Apple SD Gothic Neo","Noto Sans KR",Segoe UI,Roboto,Helvetica,Arial,sans-serif;
      color: var(--text);

      min-height: calc(100vh - 80px);
    }

    .pm *{ box-sizing:border-box; }

    .pm .wrap{ max-width:1200px; margin:26px auto 70px; padding:0 18px; }


    .pm .pageTitle{
      display:flex;
      align-items:flex-start;
      justify-content:space-between;
      gap:16px;
      margin-bottom:16px;
    }
    .pm .titleBox{ display:flex; flex-direction:column; gap:6px; }
    .pm .h1{
      margin:0;
      font-size:24px;
      font-weight:900;
      letter-spacing:-.6px;
      color:var(--text);
    }
    .pm .sub{
      margin:0;
      color:var(--muted);
      font-weight:800;
      line-height:1.45;
      font-size:13px;
    }


    .pm .btn{
      border:1px solid transparent;
      border-radius: 12px;
      padding:11px 14px;
      font-weight:900;
      cursor:pointer;
      font-size:13px;
      display:inline-flex;
      align-items:center;
      gap:8px;
      white-space:nowrap;
      user-select:none;
      text-decoration:none;
      transition:filter .12s ease, transform .06s ease, background .12s ease, border-color .12s ease;
    }
    .pm .btn:active{ transform:translateY(1px); }

    .pm .btn.primary{
      background:var(--primary);
      color:#fff;
      border-color: rgba(23,49,96,.20);
      box-shadow:none;
    }
    .pm .btn.primary:hover{ filter:brightness(1.02); }

    .pm .btn.ghost{
      background: var(--ghost-bg);
      color: var(--ghost-fg);
      /*border-color: var(--ghost-bd);*/
      box-shadow:none;
    }
    .pm .btn.ghost:hover{ filter:brightness(.99); }


    .pm .gridTop{
      display:grid;
      grid-template-columns: 1.2fr 1fr 1fr;
      gap:14px;
      margin-bottom:14px;
    }
    .pm .stat{
      background:var(--card);
      border:1px solid var(--line);
      border-radius: var(--outer-radius);
      box-shadow: var(--shadow);
      padding:16px 16px;
      min-height:110px;
    }
    .pm .statTop{
      display:flex;
      align-items:center;
      justify-content:space-between;
      gap:10px;
    }
    .pm .statLabel{
      display:flex;
      align-items:center;
      gap:8px;
      color:var(--muted);
      font-weight:900;
      font-size:12.5px;
    }
    .pm .dot{ width:8px; height:8px; border-radius:999px; background:var(--info); }
    .pm .dot.warn{ background:var(--warn); }
    .pm .dot.ok{ background:var(--ok); }

    .pm .statValue{
      margin-top:10px;
      font-size:34px;
      font-weight:950;
      letter-spacing:-.8px;
      color:var(--text);
    }
    .pm .chip{
      margin-top:10px;
      display:inline-flex;
      align-items:center;
      gap:8px;
      padding:7px 10px;
      border-radius: var(--inner-radius);
      background: var(--primary-weak);
      border:1px solid var(--primary-bd);
      color: var(--text);
      font-weight:900;
      font-size:12px;
    }


    .pm .main{
      display:grid;
      grid-template-columns: 420px 1fr;
      gap:14px;
      align-items:start;
    }
    .pm .panel{
      background:var(--card);
      border:1px solid var(--line);
      border-radius: var(--outer-radius);
      box-shadow: var(--shadow);
      padding:16px;
    }


    .pm .calHead{
      display:flex;
      align-items:center;
      justify-content:space-between;
      gap:12px;
      margin-bottom:12px;
    }
    .pm .ym{
      font-weight:950;
      font-size:16px;
      letter-spacing:-.3px;
      color:var(--text);
    }
    .pm .calNav{ display:flex; gap:8px; align-items:center; }

    .pm .calGrid{
      display:grid;
      grid-template-columns: repeat(7, 1fr);
      gap:8px;
      user-select:none;
    }
    .pm .dow{
      text-align:center;
      font-size:11px;
      font-weight:900;
      color:var(--muted);
      padding:6px 0;
    }
    .pm .day{
      background:#fff;
      border:1px solid var(--line);
      border-radius: 10px;
      min-height:56px;
      padding:9px 10px;
      position:relative;
      cursor:pointer;
      transition:border-color .12s ease, background .12s ease;
    }
    .pm .day:hover{
      border-color: rgba(15,23,42,.22);
      background: rgba(15,23,42,.01);
    }
    .pm .day.muted{ opacity:.35; cursor:default; }
    .pm .day.muted:hover{ border-color:var(--line); background:#fff; }
    .pm .day .n{ font-weight:950; font-size:13px; color:var(--text); }
    .pm .day .marks{
      position:absolute;
      left:10px;
      bottom:9px;
      display:flex;
      gap:5px;
    }
    .pm .mk{ width:6px; height:6px; border-radius:999px; background:var(--info); }
    .pm .mk.start{ background:var(--ok); }
    .pm .mk.milestone{ background:var(--warn); }
    .pm .mk.end{ background:var(--danger); }

    .pm .day.selected{
      border-color: var(--primary-bd);
      background: var(--primary-weak);
    }

    .pm .sectionTitle{
      margin:14px 0 10px;
      font-size:13px;
      font-weight:950;
      color:var(--text);
    }
    .pm .eventList{ display:flex; flex-direction:column; gap:8px; }

    .pm .evt{
      border:1px solid var(--line);
      border-radius: 10px;
      padding:10px 10px;
      background:#fff;
      cursor:pointer;
      transition:border-color .12s ease, background .12s ease;
    }
    .pm .evt:hover{
      border-color: rgba(15,23,42,.22);
      background: rgba(15,23,42,.01);
    }
    .pm .evt .t{
      font-weight:950;
      font-size:13px;
      display:flex;
      flex-direction:column;
      gap:6px;
      color:var(--text);
    }
    .pm .evt .t span{ display:block; line-height:1.28; word-break:keep-all; }
    .pm .evt .s{
      color:var(--muted);
      font-weight:850;
      font-size:12px;
      margin-top:6px;
    }

    .pm .pill{
      display:inline-flex;
      align-items:center;
      padding:4px 9px;
      border-radius: var(--inner-radius);
      font-weight:950;
      font-size:11px;
      border:1px solid var(--line2);
      background: rgba(15,23,42,.03);
      color:#334155;
      width:fit-content;
    }
    .pm .pill.start{ background: rgba(22,163,74,.10); border-color: rgba(22,163,74,.22); color:#0f7a3a; }
    .pm .pill.milestone{ background: rgba(245,158,11,.10); border-color: rgba(245,158,11,.22); color:#9a5a00; }
    .pm .pill.end{ background: rgba(239,68,68,.10); border-color: rgba(239,68,68,.22); color:#b91c1c; }


    .pm .tabs{
      display:flex;
      align-items:flex-end;
      justify-content:space-between;
      gap:10px;
      border-bottom:1px solid var(--line);
      padding-bottom:10px;
      margin-bottom:12px;
    }
    .pm .tabGroup{
      display:flex;
      gap:25px;
      align-items:flex-end;

      overflow: visible;
      flex-wrap: nowrap;
    }
    .pm .tab{
      position:relative;
      padding:10px 2px;
      font-weight:950;
      font-size:13px;
      color:#334155;
      text-decoration:none;
      white-space:nowrap;
    }
    .pm .tab:hover{ color:var(--text); }
    .pm .tab.active{ color:var(--text); }
    .pm .tab.active:after{
      content:"";
      position:absolute;
      left:0; right:0;
      bottom:-10px;
      height:3px;
      background: var(--primary);
      border-radius: 999px;
    }
    .pm .tabsRight{ flex-shrink:0; }


    .pm .cards{ display:flex; flex-direction:column; gap:12px; }

    .pm .card{
      background:#fff;
      border:1px solid var(--line);
      border-radius: var(--outer-radius);
      box-shadow: var(--shadow);
      padding:16px;
    }
    .pm .cardTop{
      display:flex;
      align-items:flex-start;
      justify-content:space-between;
      gap:12px;
      flex-wrap:wrap;
    }
    .pm .title{
      font-weight:950;
      font-size:16px;
      letter-spacing:-.2px;
      color:var(--text);
    }
    .pm .client{
      margin-top:6px;
      color:var(--muted);
      font-weight:850;
      font-size:12px;
    }

    .pm .badge{
      display:inline-flex;
      align-items:center;
      gap:8px;
      padding:7px 10px;
      border-radius: var(--inner-radius);
      font-weight:950;
      font-size:12px;
      border:1px solid var(--line2);
      background: rgba(15,23,42,.03);
      color:#334155;
    }
    .pm .badge.info{ background: var(--primary-weak); border-color: var(--primary-bd); color: var(--text); }
    .pm .badge.warn{ background: rgba(245,158,11,.10); border-color: rgba(245,158,11,.22); color:#9a5a00; }
    .pm .badge.ok{ background: rgba(22,163,74,.10); border-color: rgba(22,163,74,.22); color:#0f7a3a; }

    .pm .metaRow{
      margin-top:14px;
      padding-top:14px;
      border-top: 1px dashed rgba(148,163,184,.55);
      display:grid;
      grid-template-columns: 1.1fr 1.1fr .8fr .9fr;
      gap:14px;
      align-items:start;
    }
    .pm .k{
      color:var(--muted);
      font-size:11px;
      font-weight:950;
      letter-spacing:-.1px;
    }
    .pm .v{
      margin-top:6px;
      font-weight:950;
      font-size:13px;
      color:var(--text);
      line-height:1.35;
    }

    .pm .progressWrap{ display:flex; align-items:center; gap:10px; }
    .pm .bar{
      height:8px;
      background: rgba(15,23,42,.08);
      border-radius: 999px;
      overflow:hidden;
      flex:1;
    }
    .pm .bar > span{
      display:block;
      height:100%;
      background: var(--primary);
      border-radius: 999px;
      width:0;
    }
    .pm .pct{
      min-width:38px;
      text-align:right;
      font-weight:950;
      font-size:12px;
      color: var(--text);
    }

    .pm .actions{
      margin-top:14px;
      display:flex;
      justify-content:flex-end;
      gap:10px;
      flex-wrap:wrap;
    }


    @media (max-width: 980px){
      .pm .gridTop{ grid-template-columns:1fr; }
      .pm .main{ grid-template-columns:1fr; }
      .pm .metaRow{ grid-template-columns:1fr 1fr; }
      .pm .tabs{ flex-direction:column; align-items:stretch; gap:10px; }
      .pm .tabsRight{ display:flex; justify-content:flex-end; }
      .pm .tabGroup{ gap:14px; flex-wrap:wrap; } /* 모바일에서 줄바꿈 */
    }
  </style>
</head>

<body>
<jsp:include page="/WEB-INF/views/common/headerBase.jsp" />

<div class="pm">
  <div class="wrap">

    <div class="pageTitle">
      <div class="titleBox">
        <h1 class="h1">내 프로젝트 관리</h1>
        <p class="sub">캘린더로 계약/마일스톤 일정을 확인하고 프로젝트를 효율적으로 관리하세요.</p>
      </div>

      <a class="btn primary" href="${pageContext.request.contextPath}/project/bookmark">
        북마크 목록
      </a>
    </div>

    <!-- Top Summary -->
    <div class="gridTop">
      <div class="stat">
        <div class="statTop">
          <div class="statLabel"><span class="dot"></span> 진행 중</div>
        </div>
        <div class="statValue"><c:out value="${summary.inProgressCount}"/></div>
        <div class="chip">
          예상 수익 ₩ <fmt:formatNumber value="${summary.expectedRevenue}" type="number" groupingUsed="true"/>
        </div>
      </div>

      <div class="stat">
        <div class="statTop">
          <div class="statLabel"><span class="dot warn"></span> 지원한 프로젝트</div>
        </div>
        <div class="statValue"><c:out value="${summary.appliedCount}"/></div>
      </div>

      <div class="stat">
        <div class="statTop">
          <div class="statLabel"><span class="dot ok"></span> 완료된 프로젝트</div>
        </div>
        <div class="statValue"><c:out value="${summary.completedCount}"/></div>
      </div>
    </div>

    <div class="main">

      <!-- Calendar -->
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
        </div>

        <div class="sectionTitle">선택한 날짜 일정</div>
        <div class="eventList" id="eventList">
          <div style="color:var(--muted); font-weight:900; font-size:13px;">날짜를 선택하면 일정이 표시됩니다.</div>
        </div>
      </div>

      <!-- Tabs + List -->
      <div class="panel">

        <div class="tabs">
          <div class="tabGroup">
            <a class="tab ${tab eq 'inProgress' ? 'active' : ''}"
               href="${pageContext.request.contextPath}/freelancer/project/manage?tab=inProgress&ym=${ym}">
              진행 중
            </a>
            <a class="tab ${tab eq 'applied' ? 'active' : ''}"
               href="${pageContext.request.contextPath}/freelancer/project/manage?tab=applied&ym=${ym}">
              지원 중
            </a>
            <a class="tab ${tab eq 'completed' ? 'active' : ''}"
               href="${pageContext.request.contextPath}/freelancer/project/manage?tab=completed&ym=${ym}">
              완료
            </a>
          </div>

          <div class="tabsRight">
            <a class="btn primary"
               href="${pageContext.request.contextPath}/freelancer/project/detail">
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
                  <a class="btn ghost" href="${pageContext.request.contextPath}/chat/list">메시지</a>
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
                  <a class="btn ghost" href="${pageContext.request.contextPath}/project/detail?projectId=${p.projectId}">공고 보기</a>
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
                  <a class="btn ghost" href="${pageContext.request.contextPath}/contract/detail?contractId=${p.contractId}">상세 보기</a>
                  <a class="btn primary" href="${pageContext.request.contextPath}/freelancer/project/detail?tab=reviews&contractId=${p.contractId}">리뷰 보기</a>
                </div>
              </div>
            </c:forEach>
          </c:if>

        </div>
      </div>
    </div>
  </div>
</div>

<!-- 캘린더 이벤트 데이터 -->
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

  const calendarEvents = {};

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

  let current = new Date();
  let selectedDate = null;

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
    calGrid.querySelectorAll('.day').forEach(d => d.remove());

    const y = current.getFullYear();
    const m = current.getMonth();
    ymText.innerText = y + '년 ' + (m+1) + '월';

    const firstDay = new Date(y, m, 1);
    const startDow = firstDay.getDay();
    const lastDate = new Date(y, m+1, 0).getDate();

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

        const seen = {};
        list.forEach(ev => {
          if(seen[ev.type]) return;
          seen[ev.type] = true;
          const mk = document.createElement('span');
          mk.className = 'mk ' + ev.type;
          marks.appendChild(mk);
        });

        cell.appendChild(marks);
      }

      cell.onclick = () => selectDate(cell, key);
      calGrid.appendChild(cell);
    }

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

  function escapeHtml(str){
    return String(str ?? '')
            .replaceAll('&','&amp;')
            .replaceAll('<','&lt;')
            .replaceAll('>','&gt;')
            .replaceAll('"','&quot;')
            .replaceAll("'","&#39;");
  }

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

  renderCalendar();
</script>

</body>
</html>
