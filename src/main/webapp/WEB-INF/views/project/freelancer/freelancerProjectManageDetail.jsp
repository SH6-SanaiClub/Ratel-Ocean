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
            --primary:#173160;
            --text:#0f172a;
            --bg:#f5f6f8;

            --paper:#ffffff;
            --muted:#64748b;

            --line: rgba(59,111,220,.22);
            --primary-weak: rgba(59,111,220,.10);

            --neutral-bg:#e5e7eb;
            --neutral-text:#111827;
            --neutral-line:#cbd5e1;

            --ok-bg:#ecfdf5; --ok-fg:#065f46; --ok-bd:rgba(16,185,129,.22);
            --warn-bg:#fff7ed; --warn-fg:#9a3412; --warn-bd:rgba(234,88,12,.22);

            --radius:16px;
        }

        *{box-sizing:border-box}
        body{
            margin:0;
            background:var(--bg);
            font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Inter,Helvetica,Arial,"Apple SD Gothic Neo","Noto Sans KR",sans-serif;
            color:var(--text);
            -webkit-font-smoothing:antialiased;
            text-rendering:optimizeLegibility;
        }
        a{color:inherit}
        .titleBox{ display:flex; flex-direction:column; gap:6px; }
        h1.h1{
            margin:0;
            font-size:24px;
            font-weight:900;
            letter-spacing:-.6px;
            color:var(--text);
        }
        .sub{
            margin:0 0 20px 0;
            font-size:13px;
            font-weight:600;
            color:var(--muted);
            letter-spacing:-.2px;
        }
        .page-wrap{max-width:1250px;margin:28px auto;padding:0 16px; }
        .top{display:flex;align-items:center;justify-content:space-between;margin-bottom:14px}

        .shell{background:#fff;border:1px solid var(--line);border-radius:0;padding:18px;}
        .grid{display:grid;grid-template-columns:320px 1fr;gap:16px}

        .panel{
            background:var(--paper);
            border:1px solid var(--line);
            border-radius:var(--radius);
            overflow:hidden;
            height: calc(75vh);
            display:flex;
            flex-direction:column;
        }
        .panel-hd{padding:14px 16px;border-bottom:1px solid var(--line);display:flex;align-items:center;justify-content:space-between;gap:10px;background:#fff}
        .panel-hd .ttl{font-weight:900}
        .panel-bd{padding:14px 16px;flex:1;min-height:0;overflow:auto}

        .tabs{display:grid;grid-template-columns:1fr 1fr 1fr;gap:0;width:100%;border:1px solid var(--line);border-radius:12px;overflow:hidden;background:#fff}
        .tab{display:flex;align-items:center;justify-content:center;padding:12px 10px;text-decoration:none;font-weight:900;font-size:13px;color:var(--muted);border-right:1px solid var(--line);background:#fff;position:relative}
        .tab:last-child{border-right:none}
        .tab.active{color:var(--primary);background:rgba(59,111,220,.06)}
        .tab.active::after{content:"";position:absolute;left:0;right:0;bottom:0;height:3px;background:var(--primary)}

        .plist{display:flex;flex-direction:column;gap:10px;margin-top:12px}
        .pitem{display:block;text-decoration:none;color:inherit;border:1px solid var(--line);border-radius:14px;padding:12px 12px;background:#fff;position:relative}
        .pitem:hover{border-color:rgba(59,111,220,.35)}
        .pitem.active{border-color:var(--primary);}
        .pitem.active::before{content:"";position:absolute;left:0;top:10px;bottom:10px;width:4px;border-radius:4px;background:var(--primary)}

        .row{display:flex;align-items:center;justify-content:space-between;gap:10px}

        .badge{
            display:inline-flex;align-items:center;justify-content:center;
            padding:3px 8px;border-radius:999px;font-size:12px;font-weight:900;
            background:rgba(59,111,220,.10);color:var(--text);border:1px solid rgba(59,111,220,.22);
            box-shadow:none;white-space:nowrap
        }
        .badge.primary{background:var(--primary-weak);color:var(--text);border-color:var(--line)}
        .badge.done{background:var(--ok-bg);color:var(--ok-fg);border-color:var(--ok-bd)}
        .badge.review{background:var(--warn-bg);color:var(--warn-fg);border-color:var(--warn-bd)}
        .badge.date{background:rgba(59,111,220,.10);color:var(--text);border:1px solid rgba(59,111,220,.22)}

        .ptitle{margin:8px 0 6px 0;font-weight:900}
        .psub{margin:0;color:var(--muted);font-size:12px}

        .empty{
            height:520px;display:flex;align-items:center;justify-content:center;
            color:var(--muted);text-align:center;line-height:1.5;
            border:1px dashed var(--line);border-radius:14px;background:rgba(255,255,255,.7)
        }

        .milestone{border:1px solid var(--line);border-radius:14px;padding:14px;margin-bottom:12px;background:#fff}
        .milestone .toprow{display:flex;align-items:flex-start;justify-content:space-between;gap:10px}
        .mname{font-weight:900}
        .mmeta{margin-top:8px;color:var(--muted);font-size:13px;display:flex;gap:10px;flex-wrap:wrap}
        .amount{font-weight:900}

        .btn{display:inline-flex;align-items:center;justify-content:center;gap:8px;border:none;border-radius:12px;padding:10px 12px;background:var(--primary);color:#fff;font-weight:900;cursor:pointer}
        .btn:disabled{background:#cbd5e1;cursor:not-allowed}
        .btn.outline{background:var(--neutral-bg);color:var(--neutral-text);border:1px solid var(--neutral-line);box-shadow:none}

        .help{color:var(--muted);font-size:12px;margin-top:8px}
        .muted{color:var(--muted)}
        .divider{height:1px;background:var(--line);margin:12px 0}

        .chips{display:flex;flex-wrap:wrap;gap:8px}
        .chip{display:inline-flex;align-items:center;gap:8px;padding:8px 10px;border:1px solid var(--neutral-line);border-radius:999px;cursor:pointer;user-select:none;background:#fff;font-weight:900;font-size:13px}
        .chip input{display:none}
        .chip.on{border-color:var(--line);background:var(--primary-weak);color:var(--text);}

        .stars{display:flex;gap:8px;align-items:center;flex-wrap:wrap}
        .star{font-size:22px;cursor:pointer;user-select:none;color:#d1d5db}
        .star.on{color:#f59e0b}

        .stars-readonly{
            display:inline-flex;
            align-items:center;
            gap:2px;
            padding:6px 10px;
            border-radius:999px;
        }
        .stars-readonly .s{
            font-size:14px;
            line-height:1;
            color:rgba(15,23,42,.25);
            letter-spacing:-1px;
        }
        .stars-readonly .s.on{color:var(--primary)}
        .stars-readonly .num{
            margin-left:6px;
            font-weight:900;
            font-size:12px;
            color:var(--text);
        }

        .review-text{
            white-space:pre-wrap;
            color:var(--text);
            border-radius:12px;
            padding:5px;
            min-height:120px;
            line-height:1.65;
            font-size:14px;
            font-weight:400;
            letter-spacing:-.15px;
            font-family:inherit;
            -webkit-font-smoothing:antialiased;
        }
        .review-empty{
            color:var(--muted);
            font-size:13px;
            line-height:1.6;
            border:1px dashed var(--line);
            border-radius:12px;
            padding:12px;
            background:rgba(255,255,255,.7)
        }

        textarea{
            width:100%;
            min-height:160px;
            border:1px solid var(--line);
            border-radius:14px;
            padding:12px;
            resize:vertical;
            font-family:inherit;
            outline:none;
            background:#fff;
            line-height:1.65;
            font-size:14px;
            font-weight:400;
            letter-spacing:-.15px;
            -webkit-font-smoothing:antialiased;
        }

        #skillKeyword{background:#fff;font-size:14px;font-weight:700;color:var(--text);border:1px solid var(--line)}
        #skillKeyword::placeholder{color:#9ca3af;font-weight:600}

        #btnSkillSearch,#btnSkillReset{height:44px;padding:0 18px;border-radius:12px;font-weight:900}

        #skillChips{border:1px dashed var(--line);border-radius:16px;padding:14px;background:rgba(59,111,220,.04)}
        #skillChips::-webkit-scrollbar{width:6px}
        #skillChips::-webkit-scrollbar-thumb{background:#d1d5db;border-radius:6px}
        #skillChips::-webkit-scrollbar-track{background:transparent}

        #skillChips .chip{background:#fff;border:1px solid var(--neutral-line);color:var(--neutral-text);transition:background .15s ease,border-color .15s ease,box-shadow .15s ease,color .15s ease}
        #skillChips .chip:hover{border-color:rgba(59,111,220,.45)}
        #skillChips .chip.on{background:var(--primary-weak);border-color:var(--line);color:var(--text);}
        #skillChips .chip.on span{font-weight:900}

        .badge.deposited{background:#E3F2FD;color:#1565C0;border-color:rgba(21,101,192,.22)}
        .badge.requested{background:#FFF3E0;color:#E65100;border-color:rgba(230,81,0,.22);animation:pulse-badge 1.5s infinite}
        .badge.paid{background:#E8F5E9;color:#2E7D32;border-color:rgba(46,125,50,.22);animation:none}
        @keyframes pulse-badge{0%,100%{opacity:1}50%{opacity:.7}}

        .milestone.paid-milestone{opacity:.75;background:#fafafa}
        .paid-label{color:#2E7D32;font-weight:900;font-size:13px}
        .waiting-label{color:#9e9e9e;font-weight:800;font-size:13px}
        .milestone.requested-milestone{border-left:4px solid #E65100}

        .review-shell{display:flex;flex-direction:column;gap:14px}



        .review-top{
            padding:14px 14px 12px;
            border-bottom:1px solid var(--line);
            display:flex;
            align-items:flex-start;
            justify-content:space-between;
            gap:12px;
            background:#fff;
        }
        .review-top .kicker{
            font-weight:900;
            font-size:12px;
            color:var(--muted);
            margin-bottom:6px;
        }
        .review-top .title{
            font-weight:900;
            font-size:16px;
            letter-spacing:-.2px;
            line-height:1.25;
        }
        .review-top .period{
            margin-top:6px;
            font-size:12px;
            color:var(--muted);
        }

        .review-person{
            padding:14px;
            display:flex;
            gap:12px;
            border-top:0;
            background:rgba(59,111,220,.04);
            min-height:76px;
            align-items:stretch;
        }

        .review-person .avatar{
            width:44px;
            height:44px;
            border-radius:999px;
            background:rgba(15,23,42,.10);
            display:flex;
            align-items:center;
            justify-content:center;
            flex:0 0 auto;
            align-self:center;
        }

        .review-person .avatar svg{opacity:.55}

        .review-person > div:not(.avatar){
            display:flex;
            flex-direction:column;
            justify-content:center;
            min-height:44px;
        }

        .review-person .name{
            font-weight:900;
            line-height:1.2;
            margin:0;
        }

        .review-person .sub{
            font-size:12px;
            color:var(--muted);
            margin:2px 0 0 0;
            line-height:1.2;
        }


        .review-body{padding:14px}

        .review-label{
            font-weight:900;
            font-size:13px;
            margin:10px 0 10px;
        }

        .review-stars{
            border:1px solid var(--line);
            border-radius:14px;
            background:#fff;
            padding:16px 14px;
            text-align:center;
        }
        .review-stars .stars{
            justify-content:center;
            gap:12px;
        }
        .review-stars .star{
            font-size:38px;
            line-height:1;
            color:rgba(15,23,42,.18);
        }
        .review-stars .star.on{color:#f59e0b}
        .review-score{
            margin-top:10px;
            font-weight:900;
            color:var(--primary);
            font-size:14px;
        }

        .review-opinion{
            margin-top:14px;
            border:1px solid var(--line);
            border-radius:14px;
            background:#fff;
            padding:14px;
        }

        .review-actions{
            display:flex;
            gap:10px;
            margin-top:14px;
        }
        .review-actions .btn{
            flex:1;
            height:48px;
        }
        .review-actions .btn.outline{
            flex:0 0 auto;
            padding:0 16px;
        }

        .review-grid{
            display:grid;
            grid-template-columns:1fr;
            gap:12px;
        }
        .review-card{
            border:1px solid var(--line);
            border-radius:14px;
            background:#fff;
            overflow:hidden;
        }
        .review-card .hd{
            padding:14px;
            border-bottom:1px solid var(--line);
            display:flex;
            align-items:center;
            justify-content:space-between;
            gap:10px;
        }
        .review-card .hd .t{font-weight:900}
        .review-card .bd{padding:14px}

        @media(max-width:1100px){
            .shell{padding:14px}
            .grid{grid-template-columns:1fr}
            .empty{height:240px}
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/headerBase.jsp" />

<div class="page-wrap">
    <div class="titleBox">
        <h1 class="h1">내 프로젝트 관리</h1>
        <p class="sub">마일스톤 지급 여부를 확인하고 리뷰를 작성하거나 볼 수 있어요.</p>
    </div>

    <div class="shell">
        <div class="grid">
            <section class="panel">
                <div class="panel-hd">
                    <div class="ttl">프로젝트 목록</div>
                </div>
                <div class="panel-bd">
                    <div class="tabs">
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
                        <a class="tab ${tab == 'completed' ? 'active' : ''}" href="${tabCompletedUrl}">완료</a>
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
                                            <span class="badge date">D-${p.dday}</span>
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
                                            <span class="badge date">${p.startDate} ~ ${p.endDate}</span>
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
                                            <span class="badge date">${p.startDate} ~ ${p.endDate}</span>
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

            <section class="panel">
                <div class="panel-hd">
                    <div class="ttl">
                        <c:choose>
                            <c:when test="${tab == 'inProgress'}">마일스톤</c:when>
                            <c:when test="${tab == 'completed'}">사용 기술스택 저장</c:when>
                            <c:otherwise>리뷰</c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="panel-bd">
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
                                                        <span class="paid-label">✔ 입금 완료</span>
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
                                           style="flex:1;height:44px;border-radius:12px;padding:0 16px;outline:none;" />
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

                                <div class="review-shell">
                                    <div class="review-sheet">
                                        <div class="review-top">
                                            <div>

                                                <div class="title">${fn:escapeXml(selected.title)}</div>
                                                <div class="period">
                                                    수행 기간:
                                                    <b><c:out value="${selected.startDate}"/></b>
                                                    ~
                                                    <b><c:out value="${selected.endDate}"/></b>
                                                </div>
                                            </div>
                                            <div class="badge done">완료됨</div>
                                        </div>

                                        <div class="review-person">
                                            <div class="avatar">
                                                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                                                    <path d="M12 12c2.761 0 5-2.462 5-5.5S14.761 1 12 1 7 3.462 7 6.5 9.239 12 12 12Z" fill="currentColor"/>
                                                    <path d="M4 23c0-4.418 3.582-8 8-8h0c4.418 0 8 3.582 8 8" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                                                </svg>
                                            </div>
                                            <div>
                                                <div class="name"><b>${fn:escapeXml(selected.clientName)}</b></div>
                                                <div class="sub">클라이언트</div>
                                            </div>
                                        </div>

                                        <div class="review-body">
                                            <c:choose>
                                                <c:when test="${not hasMyReview}">
                                                    <div class="review-label">만족도를 평가해주세요</div>
                                                    <div class="review-stars">
                                                        <div class="stars" id="starBox" data-rating="0">
                                                            <span class="star" data-v="1">★</span>
                                                            <span class="star" data-v="2">★</span>
                                                            <span class="star" data-v="3">★</span>
                                                            <span class="star" data-v="4">★</span>
                                                            <span class="star" data-v="5">★</span>
                                                        </div>
                                                        <div class="review-score" id="ratingText">0점</div>
                                                        <input type="hidden" id="rating" value="0"/>
                                                    </div>

                                                    <div class="review-label" style="margin-top:14px;">상세 의견</div>
                                                    <div class="review-opinion">
                                                        <textarea id="experience" placeholder="클라이언트와의 협업 경험을 솔직하게 남겨주세요."></textarea>

                                                        <div class="review-actions">
                                                            <button class="btn" id="btnSaveReview" data-contract-id="${selectedContractId}">리뷰 등록하기</button>
                                                            <button class="btn outline" id="btnClearReview" type="button">초기화</button>
                                                        </div>

                                                        <div class="help" id="reviewMsg" style="text-align:center;"></div>
                                                    </div>
                                                </c:when>

                                                <c:otherwise>
                                                    <div class="review-grid">
                                                        <div class="review-card">
                                                            <div class="hd">
                                                                <div class="t">내가 남긴 리뷰</div>
                                                                <div class="stars-readonly" aria-label="내가 남긴 평점">
                                                                    <span class="s ${reviewView.freelancerRating >= 1 ? 'on' : ''}">★</span>
                                                                    <span class="s ${reviewView.freelancerRating >= 2 ? 'on' : ''}">★</span>
                                                                    <span class="s ${reviewView.freelancerRating >= 3 ? 'on' : ''}">★</span>
                                                                    <span class="s ${reviewView.freelancerRating >= 4 ? 'on' : ''}">★</span>
                                                                    <span class="s ${reviewView.freelancerRating >= 5 ? 'on' : ''}">★</span>
                                                                    <span class="num">(<c:out value="${empty reviewView.freelancerRating ? '-' : reviewView.freelancerRating}"/>.0)</span>
                                                                </div>
                                                            </div>
                                                            <div class="bd">
                                                                <c:choose>
                                                                    <c:when test="${empty reviewView.freelancerExperience}">
                                                                        <div class="review-empty">작성된 리뷰가 없습니다.</div>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <div class="review-text"><c:out value="${reviewView.freelancerExperience}"/></div>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>

                                                        <div class="review-card">
                                                            <div class="hd">
                                                                <div class="t">클라이언트가 남긴 리뷰</div>
                                                                <div class="stars-readonly" aria-label="클라이언트 평점">
                                                                    <span class="s ${reviewView.clientRating >= 1 ? 'on' : ''}">★</span>
                                                                    <span class="s ${reviewView.clientRating >= 2 ? 'on' : ''}">★</span>
                                                                    <span class="s ${reviewView.clientRating >= 3 ? 'on' : ''}">★</span>
                                                                    <span class="s ${reviewView.clientRating >= 4 ? 'on' : ''}">★</span>
                                                                    <span class="s ${reviewView.clientRating >= 5 ? 'on' : ''}">★</span>
                                                                    <span class="num">(<c:out value="${empty reviewView.clientRating ? '-' : reviewView.clientRating}"/>.0)</span>
                                                                </div>
                                                            </div>
                                                            <div class="bd">
                                                                <c:choose>
                                                                    <c:when test="${empty reviewView.clientExperience}">
                                                                        <div class="review-empty">클라이언트 리뷰가 아직 없습니다.</div>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <div class="review-text"><c:out value="${reviewView.clientExperience}"/></div>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </c:if>
                </div>
            </section>
        </div>
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
