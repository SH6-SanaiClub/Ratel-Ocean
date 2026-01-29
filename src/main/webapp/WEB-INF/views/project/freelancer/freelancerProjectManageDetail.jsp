<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%
    String tab = request.getParameter("tab");
    if (tab == null || tab.isBlank()) tab = "inProgress";
    request.setAttribute("tab", tab);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <title>프리랜서 프로젝트 관리</title>
    <style>
        :root{
            --bg:#f6f7fb;
            --card:#fff;
            --text:#111827;
            --muted:#6b7280;
            --line:#e5e7eb;
            --primary:#1f7a8c;
            --primary-weak:rgba(31,122,140,.10);
            --danger:#ef4444;
            --shadow:0 10px 30px rgba(17,24,39,.08);
        }
        body{margin:0;background:var(--bg);font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Inter,Helvetica,Arial,"Apple SD Gothic Neo","Noto Sans KR",sans-serif;color:var(--text)}
        .wrap{max-width:1440px;margin:28px auto;padding:0 16px}

        .top{display:flex;align-items:center;justify-content:space-between;margin-bottom:16px}
        h1{margin:0;font-size:26px;letter-spacing:-.2px}

        .grid{display:grid;grid-template-columns:340px 1fr;gap:16px}
        .card{background:var(--card);border:1px solid var(--line);border-radius:14px;box-shadow:var(--shadow)}
        .card-hd{padding:14px 16px;border-bottom:1px solid var(--line);display:flex;align-items:center;justify-content:space-between}
        .card-hd .ttl{font-weight:700}
        .card-bd{padding:14px 16px}

        /* 기존 .tabs / .tab / .tab.tab-wide 부분을 이것으로 교체 */
        .tabs{
            display:grid;
            grid-template-columns: 1fr 1.35fr 1fr; /* 두번째(완료)만 조금 더 크게 */
            gap:10px;
            width:100%;
        }

        .tab{
            display:flex;
            align-items:center;
            justify-content:center;
            gap:8px;
            padding:10px 14px;
            border-radius:999px;
            border:1px solid var(--line);
            background:#fff;
            color:var(--muted);
            text-decoration:none;
            font-weight:800;
            font-size:13px;
            min-width:0; /* grid에서는 min-width가 오히려 방해될 수 있어서 0 */
        }

        .tab.tab-wide{ /* grid에선 필요 없지만 남겨도 무해 */
            flex:unset;
        }

        .tab.active{background:var(--primary);border-color:var(--primary);color:#fff}

        .plist{display:flex;flex-direction:column;gap:10px}
        .pitem{border:1px solid var(--line);border-radius:12px;padding:12px 12px;text-decoration:none;color:inherit;background:#fff}
        .pitem.active{border-color:var(--primary);box-shadow:0 0 0 3px var(--primary-weak)}
        .pitem .row{display:flex;align-items:center;justify-content:space-between;gap:10px}
        .badge{display:inline-flex;align-items:center;justify-content:center;padding:3px 8px;border-radius:999px;font-size:12px;font-weight:800;background:#f3f4f6;color:#374151}
        .badge.primary{background:var(--primary-weak);color:var(--primary)}
        .badge.done{background:#ecfdf5;color:#065f46}
        .badge.review{background:#fff7ed;color:#9a3412}
        .ptitle{margin:8px 0 6px 0;font-weight:800}
        .psub{margin:0;color:var(--muted);font-size:12px}

        .empty{
            height:540px;display:flex;align-items:center;justify-content:center;
            color:var(--muted);text-align:center;line-height:1.5
        }

        .milestone{border:1px solid var(--line);border-radius:14px;padding:14px;margin-bottom:12px;background:#fff}
        .milestone .toprow{display:flex;align-items:flex-start;justify-content:space-between;gap:10px}
        .mname{font-weight:900}
        .mmeta{margin-top:8px;color:var(--muted);font-size:13px;display:flex;gap:10px;flex-wrap:wrap}
        .amount{font-weight:900}
        .btn{
            display:inline-flex;align-items:center;justify-content:center;gap:8px;
            border:none;border-radius:12px;padding:10px 12px;
            background:var(--primary);color:#fff;font-weight:900;cursor:pointer
        }
        .btn:disabled{background:#cbd5e1;cursor:not-allowed}
        .btn.outline{background:#fff;border:1px solid var(--line);color:var(--text)}
        .help{color:var(--muted);font-size:12px;margin-top:8px}

        .chips{display:flex;flex-wrap:wrap;gap:8px}
        .chip{
            display:inline-flex;align-items:center;gap:8px;
            padding:8px 10px;border:1px solid var(--line);border-radius:999px;
            cursor:pointer;user-select:none;background:#fff;font-weight:800;font-size:13px
        }
        .chip input{display:none}
        .chip.on{
            border-color:var(--primary);
            background:var(--primary-weak);
            color:var(--primary);
            box-shadow:0 0 0 3px var(--primary-weak);
        }


        .stars{display:flex;gap:8px;align-items:center}
        .star{font-size:22px;cursor:pointer;user-select:none;color:#d1d5db}
        .star.on{color:#f59e0b}
        textarea{width:100%;min-height:140px;border:1px solid var(--line);border-radius:12px;padding:12px;resize:vertical;font-family:inherit}
        .muted{color:var(--muted)}
        .divider{height:1px;background:var(--line);margin:12px 0}

        @media(max-width:1100px){
            .grid{grid-template-columns:1fr}
            .empty{height:240px}
            .tabs{flex-wrap:wrap}
            .tab{flex:unset}
            .tab.tab-wide{flex:unset}
        }

        /* ===== 스킬 검색 영역 ===== */
        #skillKeyword{
            background:#fff;
            font-size:14px;
            font-weight:600;
            color:var(--text);
        }

        #skillKeyword::placeholder{
            color:#9ca3af;
            font-weight:500;
        }

        /* 검색 / 초기화 버튼 살짝 덜 강조 */
        #btnSkillSearch,
        #btnSkillReset{
            height:44px;
            padding:0 18px;
            border-radius:999px;
            font-weight:800;
        }

        /* ===== 스킬 칩 컨테이너 ===== */
        #skillChips{
            border:1px dashed var(--line);
            border-radius:16px;
            padding:14px;
            background:#fafafa;
        }

        /* 스크롤바 (디자인용, 없어도 됨) */
        #skillChips::-webkit-scrollbar{
            width:6px;
        }
        #skillChips::-webkit-scrollbar-thumb{
            background:#d1d5db;
            border-radius:6px;
        }
        #skillChips::-webkit-scrollbar-track{
            background:transparent;
        }

        /* ===== 스킬 칩 ===== */
        #skillChips .chip{
            background:#fff;
            border:1px solid #d1d5db;
            color:#374151;
            transition:
                    background .15s ease,
                    border-color .15s ease,
                    box-shadow .15s ease,
                    color .15s ease;
        }

        /* hover */
        #skillChips .chip:hover{
            border-color:var(--primary);
            color:var(--primary);
        }

        /* 선택된 상태 */
        #skillChips .chip.on{
            background:var(--primary-weak);
            border-color:var(--primary);
            color:var(--primary);
            box-shadow:0 0 0 3px var(--primary-weak);
        }

        /* 선택된 칩 텍스트 강조 */
        #skillChips .chip.on span{
            font-weight:900;
        }

        /* 마일스톤 상태별 뱃지 */
        .badge.deposited {
            background: #E3F2FD;
            color: #1565C0;
        }
        .badge.requested {
            background: #FFF3E0;
            color: #E65100;
            animation: pulse-badge 1.5s infinite;
        }
        .badge.paid {
            background: #E8F5E9;
            color: #2E7D32;
        }
        @keyframes pulse-badge {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.7; }
        }

        /* 지급 완료된 마일스톤 */
        .milestone.paid-milestone {
            opacity: 0.7;
            background: #f9f9f9;
        }

        .paid-label {
            color: #2E7D32;
            font-weight: 700;
            font-size: 13px;
        }
        .waiting-label {
            color: #9e9e9e;
            font-weight: 600;
            font-size: 13px;
        }

        .milestone.requested-milestone {
            border-left: 3px solid #E65100;
        }

    </style>
</head>
<body>
<div class="wrap">
    <div class="top">
        <h1>프리랜서 프로젝트 관리</h1>
    </div>

    <div class="grid">
        <section class="card">
            <div class="card-hd">
                <div class="ttl">프로젝트 목록</div>
            </div>
            <div class="card-bd">
                <div class="tabs" style="margin-bottom:12px;">
                    <c:url var="tabInProgressUrl" value="/freelancer/project/detail">
                        <c:param name="tab" value="inProgress"/>
                    </c:url>
                    <c:url var="tabCompletedUrl" value="/freelancer/project/detail">
                        <c:param name="tab" value="completed"/>
                    </c:url>
                    <c:url var="tabReviewsUrl" value="/freelancer/project/detail">
                        <c:param name="tab" value="reviews"/>
                    </c:url>

                    <a class="tab ${tab == 'inProgress' ? 'active' : ''}" href="${tabInProgressUrl}">진행중</a>
                    <a class="tab tab-wide ${tab == 'completed' ? 'active' : ''}" href="${tabCompletedUrl}">완료</a>
                    <a class="tab ${tab == 'reviews' ? 'active' : ''}" href="${tabReviewsUrl}">리뷰</a>
                </div>

                <div class="plist">
                    <c:choose>
                        <c:when test="${tab == 'inProgress'}">
                            <c:forEach var="p" items="${inProgressList}">
                                <c:url var="go" value="/freelancer/project/detail">
                                    <c:param name="tab" value="inProgress"/>
                                    <c:param name="contractId" value="${p.contractId}"/>
                                </c:url>
                                <a class="pitem ${selectedContractId == p.contractId ? 'active' : ''}" href="${go}">
                                    <div class="row">
                                        <span class="badge primary">진행중</span>
                                        <span class="badge">D-${p.dday}</span>
                                    </div>
                                    <div class="ptitle">${fn:escapeXml(p.title)}</div>
                                    <p class="psub">
                                        <c:if test="${not empty p.companyName}">${fn:escapeXml(p.companyName)} · </c:if>
                                            ${fn:escapeXml(p.clientName)}
                                    </p>
                                </a>
                            </c:forEach>
                            <c:if test="${empty inProgressList}">
                                <div class="empty">진행중인 프로젝트가 없습니다.</div>
                            </c:if>
                        </c:when>

                        <c:when test="${tab == 'completed'}">
                            <c:forEach var="p" items="${completedList}">
                                <c:url var="go" value="/freelancer/project/detail">
                                    <c:param name="tab" value="completed"/>
                                    <c:param name="contractId" value="${p.contractId}"/>
                                </c:url>
                                <a class="pitem ${selectedContractId == p.contractId ? 'active' : ''}" href="${go}">
                                    <div class="row">
                                        <span class="badge done">완료</span>
                                        <span class="badge">${p.startDate} ~ ${p.endDate}</span>
                                    </div>
                                    <div class="ptitle">${fn:escapeXml(p.title)}</div>
                                    <p class="psub">
                                        <c:if test="${not empty p.companyName}">${fn:escapeXml(p.companyName)} · </c:if>
                                            ${fn:escapeXml(p.clientName)}
                                    </p>
                                </a>
                            </c:forEach>
                            <c:if test="${empty completedList}">
                                <div class="empty">완료된 프로젝트가 없습니다.</div>
                            </c:if>
                        </c:when>

                        <c:otherwise>
                            <c:forEach var="p" items="${reviewList}">
                                <c:url var="go" value="/freelancer/project/detail">
                                    <c:param name="tab" value="reviews"/>
                                    <c:param name="contractId" value="${p.contractId}"/>
                                </c:url>
                                <a class="pitem ${selectedContractId == p.contractId ? 'active' : ''}" href="${go}">
                                    <div class="row">
                                        <span class="badge review">리뷰</span>
                                        <span class="badge">${p.startDate} ~ ${p.endDate}</span>
                                    </div>
                                    <div class="ptitle">${fn:escapeXml(p.title)}</div>
                                    <p class="psub">
                                        <c:if test="${not empty p.companyName}">${fn:escapeXml(p.companyName)} · </c:if>
                                            ${fn:escapeXml(p.clientName)}
                                    </p>
                                </a>
                            </c:forEach>
                            <c:if test="${empty reviewList}">
                                <div class="empty">리뷰를 확인할 프로젝트가 없습니다.</div>
                            </c:if>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </section>

        <section class="card">
            <div class="card-hd">
                <div class="ttl">
                    <c:choose>
                        <c:when test="${tab == 'inProgress'}">마일스톤</c:when>
                        <c:when test="${tab == 'completed'}">사용 기술스택 저장</c:when>
                        <c:otherwise>리뷰</c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="card-bd">
                <c:if test="${empty selectedContractId}">
                    <div class="empty">좌측 목록에서 프로젝트를 선택해주세요.</div>
                </c:if>

                <c:if test="${not empty selectedContractId}">
                    <c:choose>
                        <c:when test="${tab == 'inProgress'}">
                            <c:forEach var="m" items="${milestones}">
                                <div class="milestone">
                                    <div class="toprow">
                                        <div>
                                            <div class="row" style="gap:10px;justify-content:flex-start;">
                                                <span class="badge primary">${m.stepOrder}단계</span>
                                                <c:choose>
                                                    <c:when test="${m.status == 'WAITING'}">
                                                        <span class="badge">⏳ 결제 대기</span>
                                                    </c:when>
                                                    <c:when test="${m.status == 'DEPOSITED'}">
                                                        <span class="badge deposited">💳 에스크로 보관</span>
                                                    </c:when>
                                                    <c:when test="${m.status == 'REQUESTED'}">
                                                        <span class="badge requested">📤 지급 요청됨</span>
                                                    </c:when>
                                                    <c:when test="${m.status == 'PAID'}">
                                                        <span class="badge paid">✅ 지급 완료</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge">${m.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="mname" style="margin-top:8px;">${fn:escapeXml(m.milestoneName)}</div>
                                            <div class="mmeta">
                                                <span>지급 예정일: <b><c:out value="${empty m.dueDate ? '-' : m.dueDate}"/></b></span>
                                                <span>금액: <span class="amount">₩ <fmt:formatNumber value="${m.amount}" groupingUsed="true"/></span></span>
                                            </div>
                                            <c:if test="${not empty m.workScope}">
                                                <div class="help">업무범위: ${fn:escapeXml(m.workScope)}</div>
                                            </c:if>
                                        </div>

                                        <div style="min-width:150px;display:flex;justify-content:flex-end;">
                                            <c:choose>
                                                <c:when test="${m.status == 'PAID'}">
                                                    <span class="paid-label">✅ 입금 완료</span>
                                                </c:when>
                                                <c:when test="${m.status == 'WAITING'}">
                                                    <span class="waiting-label">결제 대기 중</span>
                                                </c:when>
                                                <c:when test="${m.actionable}">
                                                    <button class="btn js-toggle-request"
                                                            data-milestone-id="${m.milestoneId}"
                                                            data-status="${m.status}">
                                                        <c:choose>
                                                            <c:when test="${m.status == 'REQUESTED'}">요청취소</c:when>
                                                            <c:otherwise>승인요청</c:otherwise>
                                                        </c:choose>
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <button class="btn" disabled>승인요청</button>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>

                            <c:if test="${empty milestones}">
                                <div class="empty">마일스톤이 없습니다.</div>
                            </c:if>
                        </c:when>

                        <c:when test="${tab == 'completed'}">
                            <div class="muted" style="font-size:13px;margin-bottom:10px;">
                                프로젝트에서 사용한 기술을 선택하고 저장해주세요!
                            </div>
                            <div class="divider"></div>

                            <div class="muted" style="font-weight:900;margin:10px 0 8px;">포지션</div>

                            <div class="chips" id="positionChips">
                                <c:forEach var="s" items="${positionStacks}">
                                    <c:set var="isOn" value="${preSelectedIds != null && preSelectedIds.contains(s.stackId)}" />
                                    <label class="chip ${isOn ? 'on' : ''}">
                                        <input type="checkbox" class="js-stack" value="${s.stackId}" ${isOn ? 'checked' : ''}/>
                                        <span>${fn:escapeXml(s.stackName)}</span>
                                    </label>
                                </c:forEach>
                            </div>

                            <div class="divider"></div>

                            <div class="muted" style="font-weight:900;margin:10px 0 8px;">스킬</div>

                            <div style="display:flex;gap:10px;align-items:center;margin-bottom:12px;">
                                <input id="skillKeyword" type="text" placeholder="스킬 검색 (예: Java, Spring)"
                                       style="flex:1;height:44px;border-radius:999px;border:1px solid var(--line);padding:0 16px;outline:none;" />
                                <button class="btn outline" id="btnSkillSearch" type="button">검색</button>
                                <button class="btn outline" id="btnSkillReset" type="button">초기화</button>
                            </div>

                            <div class="chips" id="skillChips" style="max-height:260px;overflow:auto;padding-right:6px;">
                                <c:forEach var="s" items="${skillStacks}">
                                    <c:set var="isOn" value="${preSelectedIds != null && preSelectedIds.contains(s.stackId)}" />
                                    <label class="chip ${isOn ? 'on' : ''}" data-name="${fn:escapeXml(s.stackName)}">
                                        <input type="checkbox" class="js-stack" value="${s.stackId}" ${isOn ? 'checked' : ''}/>
                                        <span>${fn:escapeXml(s.stackName)}</span>
                                    </label>
                                </c:forEach>
                            </div>


                            <div style="display:flex;gap:10px;margin-top:14px;">
                                <button class="btn" id="btnSaveStacks" data-contract-id="${selectedContractId}">선택 저장</button>
                                <button class="btn outline" id="btnResetStacks">초기화(새로고침)</button>
                            </div>
                            <div class="help" id="stackSaveMsg"></div>
                        </c:when>

                        <c:otherwise>
                            <c:set var="hasMyReview" value="${not empty reviewView.freelancerRating && reviewView.freelancerRating > 0}" />

                            <c:choose>
                                <c:when test="${not hasMyReview}">
                                    <div class="muted" style="font-weight:800;margin-bottom:8px;">
                                        대상: <b>${fn:escapeXml(selected.clientName)}</b>
                                    </div>

                                    <div class="divider"></div>

                                    <div style="font-weight:900;margin-bottom:8px;">만족도</div>
                                    <div class="stars" id="starBox" data-rating="0">
                                        <span class="star" data-v="1">★</span>
                                        <span class="star" data-v="2">★</span>
                                        <span class="star" data-v="3">★</span>
                                        <span class="star" data-v="4">★</span>
                                        <span class="star" data-v="5">★</span>
                                        <span class="badge" id="ratingText">0점</span>
                                    </div>
                                    <input type="hidden" id="rating" value="0"/>

                                    <div style="margin-top:12px;font-weight:900;">상세 의견</div>
                                    <textarea id="experience" placeholder="협업 경험을 남겨주세요."></textarea>

                                    <div style="display:flex;gap:10px;margin-top:12px;">
                                        <button class="btn" id="btnSaveReview" data-contract-id="${selectedContractId}">리뷰 저장</button>
                                        <button class="btn outline" id="btnClearReview">초기화</button>
                                    </div>
                                    <div class="help" id="reviewMsg"></div>
                                </c:when>

                                <c:otherwise>
                                    <div style="font-weight:900;margin-bottom:8px;">내가 남긴 리뷰</div>
                                    <div class="milestone ${m.status == 'PAID' ? 'paid-milestone' : ''} ${m.status == 'REQUESTED' ? 'requested-milestone' : ''}">
                                        <div class="row" style="justify-content:flex-start;gap:10px;">
                                            <span class="badge primary">평점</span>
                                            <span><b><c:out value="${empty reviewView.freelancerRating ? '-' : reviewView.freelancerRating}"/></b></span>
                                        </div>
                                        <div class="help" style="margin-top:10px;white-space:pre-wrap;">
                                            <c:out value="${empty reviewView.freelancerExperience ? '작성된 리뷰가 없습니다.' : reviewView.freelancerExperience}"/>
                                        </div>
                                    </div>

                                    <div style="font-weight:900;margin:18px 0 8px;">클라이언트가 남긴 리뷰</div>
                                    <div class="milestone ${m.status == 'PAID' ? 'paid-milestone' : ''} ${m.status == 'REQUESTED' ? 'requested-milestone' : ''}">
                                        <div class="row" style="justify-content:flex-start;gap:10px;">
                                            <span class="badge primary">평점</span>
                                            <span><b><c:out value="${empty reviewView.clientRating ? '-' : reviewView.clientRating}"/></b></span>
                                        </div>
                                        <div class="help" style="margin-top:10px;white-space:pre-wrap;">
                                            <c:out value="${empty reviewView.clientExperience ? '클라이언트 리뷰가 아직 없습니다.' : reviewView.clientExperience}"/>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </c:otherwise>
                    </c:choose>
                </c:if>
            </div>
        </section>
    </div>
</div>

<script>
    function setStars(val){
        const stars = document.querySelectorAll('#starBox .star');
        stars.forEach(s => {
            const v = Number(s.dataset.v);
            s.classList.toggle('on', v <= val);
        });
        const ratingEl = document.getElementById('rating');
        const textEl = document.getElementById('ratingText');
        if(ratingEl) ratingEl.value = String(val);
        if(textEl) textEl.textContent = val + '점';
    }

    const starBox = document.getElementById('starBox');
    if(starBox){
        const init = Number(starBox.dataset.rating || '0');
        setStars(init);
        starBox.addEventListener('click', (e) => {
            const t = e.target;
            if(!t.classList.contains('star')) return;
            setStars(Number(t.dataset.v));
        });
    }

    async function postJson(url, body){
        const res = await fetch(url, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            credentials: 'same-origin',
            body: JSON.stringify(body || {})
        });
        const text = await res.text();
        let json = {};
        try { json = text ? JSON.parse(text) : {}; } catch(e) {}
        if(!res.ok){
            const msg = (json && json.message) ? json.message : ('요청 실패 (' + res.status + ')');
            throw new Error(msg);
        }
        return json;
    }

    document.querySelectorAll('.js-toggle-request').forEach(btn => {
        btn.addEventListener('click', async () => {
            const milestoneId = btn.dataset.milestoneId;
            const status = btn.dataset.status;

            const isCancel = (status === 'REQUESTED');
            const msg = isCancel ? '승인요청을 취소하시겠습니까?' : '승인요청을 보내시겠습니까?';
            if(!confirm(msg)) return;

            btn.disabled = true;
            const prevText = btn.textContent;
            btn.textContent = '처리중...';

            try{
                const url = '<c:url value="/freelancer/project/detail/milestones"/>' + '/' + milestoneId + '/toggle';
                const json = await postJson(url, {});
                if(!json.ok){
                    alert('처리할 수 없는 상태입니다.');
                }
                location.reload();
            }catch(e){
                alert(e.message);
                btn.disabled = false;
                btn.textContent = prevText;
            }
        });
    });

    const btnResetStacks = document.getElementById('btnResetStacks');
    if(btnResetStacks){
        btnResetStacks.addEventListener('click', () => location.reload());
    }

    function bindChipToggle(containerId){
        const box = document.getElementById(containerId);
        if(!box) return;

        box.addEventListener('click', (e) => {
            const label = e.target.closest('.chip');
            if(!label || !box.contains(label)) return;

            const input = label.querySelector('input[type="checkbox"]');
            if(!input) return;

            input.checked = !input.checked;
            label.classList.toggle('on', input.checked);
        });
    }

    bindChipToggle('positionChips');
    bindChipToggle('skillChips');

    const btnSaveStacks = document.getElementById('btnSaveStacks');
    if(btnSaveStacks){
        btnSaveStacks.addEventListener('click', async () => {
            const contractId = btnSaveStacks.dataset.contractId;
            const selected = Array.from(document.querySelectorAll('.js-stack'))
                .filter(i => i.checked)
                .map(i => Number(i.value));

            btnSaveStacks.disabled = true;
            const msgEl = document.getElementById('stackSaveMsg');
            if(msgEl) msgEl.textContent = '저장 중...';
            try{
                await postJson('<c:url value="/freelancer/project/detail/stacks/save"/>', {
                    contractId: Number(contractId),
                    stackIds: selected
                });
                if(msgEl) msgEl.textContent = '저장 완료!';
            }catch(e){
                if(msgEl) msgEl.textContent = e.message;
                alert(e.message);
            }finally{
                btnSaveStacks.disabled = false;
            }
        });
    }

    const btnSaveReview = document.getElementById('btnSaveReview');
    if(btnSaveReview){
        btnSaveReview.addEventListener('click', async () => {
            const contractId = btnSaveReview.dataset.contractId;
            const rating = Number(document.getElementById('rating').value || '0');
            const experience = document.getElementById('experience').value || '';

            if(rating < 1 || rating > 5){
                alert('평점을 1~5점으로 선택해주세요.');
                return;
            }

            btnSaveReview.disabled = true;
            const msgEl = document.getElementById('reviewMsg');
            if(msgEl) msgEl.textContent = '저장 중...';
            try{
                await postJson('<c:url value="/freelancer/project/detail/review/save"/>', {
                    contractId: Number(contractId),
                    rating: rating,
                    experience: experience
                });
                if(msgEl) msgEl.textContent = '리뷰 저장 완료!';
                location.reload();
            }catch(e){
                if(msgEl) msgEl.textContent = e.message;
                alert(e.message);
            }finally{
                btnSaveReview.disabled = false;
            }
        });
    }

    const btnClearReview = document.getElementById('btnClearReview');
    if(btnClearReview){
        btnClearReview.addEventListener('click', () => {
            setStars(0);
            const exp = document.getElementById('experience');
            const msgEl = document.getElementById('reviewMsg');
            if(exp) exp.value = '';
            if(msgEl) msgEl.textContent = '';
        });
    }

    const skillKeyword = document.getElementById('skillKeyword');
    const btnSkillSearch = document.getElementById('btnSkillSearch');
    const btnSkillReset = document.getElementById('btnSkillReset');
    const skillChips = document.getElementById('skillChips');

    function filterSkills(){
        if(!skillChips) return;
        const q = (skillKeyword?.value || '').trim().toLowerCase();
        skillChips.querySelectorAll('.chip').forEach(chip => {
            const name = (chip.dataset.name || chip.textContent || '').toLowerCase();
            chip.style.display = (!q || name.includes(q)) ? '' : 'none';
        });
    }

    if(btnSkillSearch) btnSkillSearch.addEventListener('click', filterSkills);
    if(skillKeyword) skillKeyword.addEventListener('keydown', (e) => {
        if(e.key === 'Enter'){ e.preventDefault(); filterSkills(); }
    });
    if(btnSkillReset){
        btnSkillReset.addEventListener('click', () => {
            if(skillKeyword) skillKeyword.value = '';
            filterSkills();
        });
    }

</script>
</body>
</html>
