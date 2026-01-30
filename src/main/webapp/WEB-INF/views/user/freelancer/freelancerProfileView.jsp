<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <title>프리랜서 프로필</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <style>
        :root{
            --bg:#f6f7fb;
            --paper:#ffffff;
            --text:#111827;
            --muted:#6b7280;
            --line:#e5e7eb;

            --primary:#6d4dfd;
            --primary-weak: rgba(109,77,253,.12);

            --shadow: 0 22px 70px rgba(17,24,39,.10);
            --radius: 18px;

            --chip-bg: rgba(109,77,253,.10);
            --chip-bd: rgba(109,77,253,.22);
            --chip-tx: #2f22c9;

            --card-bg: #fbfbff;
            --card-bd: rgba(229,231,235,.8);
        }

        *{ box-sizing:border-box; }
        body{
            margin:0;
            background: var(--bg);
            color: var(--text);
            font-family: -apple-system, BlinkMacSystemFont, "Apple SD Gothic Neo", "Noto Sans KR",
            Segoe UI, Roboto, Helvetica, Arial, sans-serif;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }
        a{ color:inherit; text-decoration:none; }
        a:hover{ opacity:.95; }


        .pfv-wrap{ max-width:1120px; margin:28px auto 70px; padding:0 18px; }

        #pfvRoot{
            background: var(--paper);
            border-radius: 26px;
            box-shadow: var(--shadow);
            border: 1px solid rgba(229,231,235,.75);
            overflow:hidden;
        }

        /* ===== 상단(프로필 카드 헤더) ===== */
        #pfvRoot .pfv-top{
            display:flex;
            align-items:center;
            justify-content:space-between;
            gap:16px;
            padding: 26px 30px;
            border-bottom: 1px solid var(--line);
            background: linear-gradient(180deg,#ffffff 0%, #fbfaff 100%);
        }
        #pfvRoot .pfv-top-left{
            display:flex;
            align-items:center;
            gap:14px;
            min-width:0;
        }
        #pfvRoot .pfv-avatar{
            width:72px; height:72px;
            border-radius: 22px;
            overflow:hidden;
            background: #f3f4f6;
            border: 1px solid rgba(229,231,235,.9);
            display:flex;
            align-items:center;
            justify-content:center;
            flex: 0 0 auto;
        }
        #pfvRoot .pfv-avatar img{ width:100%; height:100%; object-fit:cover; }
        #pfvRoot .pfv-avatar .pfv-fallback{
            width:100%; height:100%;
            display:flex; align-items:center; justify-content:center;
            font-size:28px; color:#9ca3af;
            background:
                    radial-gradient(120px 60px at 20% 10%, rgba(109,77,253,.18), transparent 60%),
                    radial-gradient(120px 60px at 80% 100%, rgba(34,211,238,.12), transparent 60%),
                    #f3f4f6;
        }

        #pfvRoot .pfv-title{ min-width:0; }
        #pfvRoot .pfv-name-line{
            display:flex;
            align-items:baseline;
            flex-wrap:wrap;
            gap:10px;
        }
        #pfvRoot .pfv-nickname{
            font-size:22px;
            font-weight: 900;
            letter-spacing: -0.2px;
            margin:0;
            line-height:1.15;
            white-space:nowrap;
            overflow:hidden;
            text-overflow:ellipsis;
            max-width: 520px;
        }
        #pfvRoot .pfv-subid{
            font-size:13px;
            font-weight:800;
            color: var(--muted);
            white-space:nowrap;
        }

        /* ===== 상단 버튼 영역 ===== */
        #pfvRoot .pfv-top-actions{
            display:flex;
            gap:10px;
            flex: 0 0 auto;
        }
        #pfvRoot .pfv-btn{
            border:none;
            border-radius: 14px;
            padding: 10px 14px;
            font-size:13px;
            font-weight: 900;
            cursor:pointer;
            display:inline-flex;
            align-items:center;
            gap:8px;
            user-select:none;
            transition: transform .08s ease, filter .12s ease;
            white-space:nowrap;
        }
        #pfvRoot .pfv-btn:active{ transform: translateY(1px); }
        #pfvRoot .pfv-btn.ghost{
            background:#fff;
            border:1px solid var(--line);
            color:#111827;
        }
        #pfvRoot .pfv-btn.primary{
            background: var(--primary);
            color:#fff;
            box-shadow: 0 14px 30px rgba(109,77,253,.22);
        }
        #pfvRoot .pfv-btn:hover{ filter: brightness(.98); }

        /* ===== 본문 레이아웃 ===== */
        #pfvRoot .pfv-body{
            padding: 22px 30px 34px;
        }
        #pfvRoot .pfv-layout{
            display:grid;
            grid-template-columns: 360px 1fr;
            gap: 18px;
            align-items:start;
        }

        @media (max-width: 980px){
            #pfvRoot .pfv-top{ flex-direction:column; align-items:flex-start; }
            #pfvRoot .pfv-top-actions{ width:100%; }
            #pfvRoot .pfv-top-actions .pfv-btn{ flex:1; justify-content:center; }
            #pfvRoot .pfv-layout{ grid-template-columns: 1fr; }
            #pfvRoot .pfv-nickname{ max-width: 100%; }
        }

        /* ===== 좌측 패널 ===== */
        #pfvRoot .pfv-side{
            display:flex;
            flex-direction:column;
            gap: 14px;
        }
        #pfvRoot .pfv-panel{
            border: 1px solid var(--card-bd);
            background: var(--card-bg);
            border-radius: var(--radius);
            padding: 16px 16px;
        }
        #pfvRoot .pfv-panel h3{
            margin:0 0 12px;
            font-size:13px;
            font-weight: 950;
            letter-spacing: .2px;
            color: #111827;
            display:flex;
            align-items:center;
            gap:8px;
        }
        /* badge 충돌 방지: pfv-badge */
        #pfvRoot .pfv-badge{
            font-size:11px;
            font-weight:950;
            padding:4px 8px;
            border-radius: 999px;
            background: rgba(109,77,253,.12);
            border: 1px solid rgba(109,77,253,.22);
            color: #3b2bd8;
        }

        #pfvRoot .pfv-kv{
            display:grid;
            grid-template-columns: 86px 1fr;
            row-gap: 10px;
            column-gap: 10px;
            align-items:start;
        }
        #pfvRoot .pfv-k{
            color: var(--muted);
            font-size: 12px;
            font-weight: 900;
            line-height:1.3;
            padding-top: 1px;
        }
        #pfvRoot .pfv-v{
            color:#111827;
            font-size: 13px;
            font-weight: 850;
            line-height:1.45;
            word-break: break-word;
        }
        #pfvRoot .pfv-link{
            border-bottom: 1px dashed rgba(17,24,39,.25);
            font-weight: 900;
        }
        #pfvRoot .pfv-link:hover{ border-bottom-style: solid; }

        /* ===== 우측 메인 섹션 ===== */
        #pfvRoot .pfv-main{
            display:flex;
            flex-direction:column;
            gap: 14px;
        }
        #pfvRoot .pfv-section{
            border: 1px solid var(--line);
            border-radius: var(--radius);
            background: #fff;
            padding: 16px 16px;
        }
        #pfvRoot .pfv-section h2{
            margin:0 0 12px;
            font-size: 14px;
            font-weight: 950;
            display:flex;
            align-items:center;
            justify-content:space-between;
            gap:10px;
            letter-spacing:.15px;
        }
        #pfvRoot .pfv-hint{
            color: var(--muted);
            font-size: 12px;
            font-weight: 800;
        }

        #pfvRoot .pfv-chips{
            display:flex;
            flex-wrap:wrap;
            gap: 8px;
        }
        #pfvRoot .pfv-chip{
            display:inline-flex;
            align-items:center;
            gap: 8px;
            padding: 8px 10px;
            border-radius: 999px;
            border: 1px solid var(--chip-bd);
            background: var(--chip-bg);
            color: var(--chip-tx);
            font-size: 12px;
            font-weight: 950;
        }

        #pfvRoot .pfv-lvl{
            display:inline-flex;
            align-items:center;
            gap: 8px;
            color:#4338ca;
            opacity:.95;
            font-weight: 950;
        }
        #pfvRoot .pfv-bars{ display:inline-flex; gap:2px; }
        #pfvRoot .pfv-bar{ width:6px; height:10px; border-radius: 3px; background: rgba(67,56,202,.18); }
        #pfvRoot .pfv-bar.on{ background: rgba(67,56,202,.78); }

        #pfvRoot .pfv-list{ display:flex; flex-direction:column; gap:10px; }
        #pfvRoot .pfv-item{
            border: 1px solid rgba(229,231,235,.85);
            border-radius: 14px;
            padding: 12px 12px;
            background: linear-gradient(180deg,#fff 0%, #ffffff 100%);
        }
        #pfvRoot .pfv-item-top{
            display:flex;
            justify-content:space-between;
            gap:10px;
            align-items:flex-start;
            flex-wrap:wrap;
        }
        #pfvRoot .pfv-item-title{ font-weight: 950; font-size: 13px; }
        #pfvRoot .pfv-item-sub{
            color: var(--muted);
            font-size: 12px;
            font-weight: 850;
            line-height:1.4;
        }
        #pfvRoot .pfv-item-desc{
            margin-top: 8px;
            color:#374151;
            font-size: 13px;
            font-weight: 700;
            line-height: 1.55;
            white-space: pre-line;
        }

        #pfvRoot .pfv-intro{
            color:#111827;
            font-size: 13px;
            font-weight: 750;
            line-height: 1.65;
            white-space: pre-line;
        }

        #pfvRoot .pfv-stars{
            display:inline-flex;
            align-items:center;
            gap:6px;
            font-weight: 950;
            color:#111827;
        }
        #pfvRoot .pfv-stars .pfv-score{ color: var(--muted); font-weight: 900; font-size:12px; }

        /* 프린트 */
        .noprint{}
        @media print{
            body{ background:#fff; }
            .pfv-wrap{ max-width:none; margin:0; padding:0; }
            #pfvRoot{ border:none; box-shadow:none; border-radius:0; }
            #pfvRoot .pfv-top{ border-bottom:1px solid #ddd; }
            .noprint{ display:none !important; }
            #pfvRoot .pfv-section, #pfvRoot .pfv-panel, #pfvRoot .pfv-item{ break-inside: avoid; page-break-inside: avoid; }
            a.pfv-link{ border:none; text-decoration: underline; }
        }
    </style>

    <script>
        function downloadPdf(){
            window.print();
        }
    </script>
</head>

<body>
<jsp:include page="/WEB-INF/views/common/headerBase.jsp" />

<div class="pfv-wrap">
    <div id="pfvRoot">

        <!-- ===== Header (프로필 상단) ===== -->
        <div class="pfv-top">
            <div class="pfv-top-left">
                <div class="pfv-avatar">
                    <c:choose>
                        <c:when test="${not empty p.profileImageUrl}">
                            <img src="${pageContext.request.contextPath}${p.profileImageUrl}" alt="profile"/>
                        </c:when>
                        <c:otherwise>
                            <div class="pfv-fallback">👤</div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="pfv-title">
                    <div class="pfv-name-line">
                        <div class="pfv-nickname">
                            <c:choose>
                                <c:when test="${not empty p.nickname}">
                                    <c:out value="${p.nickname}"/>
                                </c:when>
                                <c:otherwise>
                                    닉네임 미등록
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <c:if test="${not empty p.loginId}">
                            <div class="pfv-subid">(<c:out value="${p.loginId}"/>)</div>
                        </c:if>
                    </div>

                    <%--            <div class="pfv-meta-line">--%>
                    <%--              <c:if test="${not empty p.email}">--%>
                    <%--                <span class="pfv-meta-pill"><span class="pfv-dot"></span> Email. <c:out value="${p.email}"/></span>--%>
                    <%--              </c:if>--%>
                    <%--            </div>--%>
                </div>
            </div>

            <div class="pfv-top-actions noprint">
                <button class="pfv-btn ghost" type="button" onclick="downloadPdf()">PDF로 다운</button>

                <c:if test="${p.owner}">
                    <a class="pfv-btn primary" href="${pageContext.request.contextPath}/freelancer/profile/edit?tab=settings">
                        프로필 수정하기
                    </a>
                </c:if>
            </div>
        </div>

        <!-- ===== Body ===== -->
        <div class="pfv-body">
            <div class="pfv-layout">

                <!-- ===== Left Side ===== -->
                <div class="pfv-side">

                    <!-- 학력(값 있는 것만 줄 단위로 노출) -->
                    <c:if test="${not empty p.schoolName or not empty p.major or not empty p.degree or not empty p.gradStatus}">
                        <div class="pfv-panel">
                            <h3>학력 <span class="pfv-badge">Education</span></h3>
                            <div class="pfv-kv">
                                <c:if test="${not empty p.schoolName}">
                                    <div class="pfv-k">학교</div>
                                    <div class="pfv-v"><c:out value="${p.schoolName}"/></div>
                                </c:if>
                                <c:if test="${not empty p.major}">
                                    <div class="pfv-k">전공</div>
                                    <div class="pfv-v"><c:out value="${p.major}"/></div>
                                </c:if>
                                <c:if test="${not empty p.degree}">
                                    <div class="pfv-k">학위</div>
                                    <div class="pfv-v"><c:out value="${p.degree}"/></div>
                                </c:if>
                                <c:if test="${not empty p.gradStatus}">
                                    <div class="pfv-k">상태</div>
                                    <div class="pfv-v"><c:out value="${p.gradStatus}"/></div>
                                </c:if>
                            </div>
                        </div>
                    </c:if>

                    <!-- 포트폴리오 (public only) -->
                    <c:if test="${not empty p.publicPortfolios}">
                        <div class="pfv-panel">
                            <h3>포트폴리오 <span class="pfv-badge">Portfolio</span></h3>
                            <div class="pfv-list">
                                <c:forEach var="pf" items="${p.publicPortfolios}">
                                    <div class="pfv-item">
                                        <div class="pfv-item-top">
                                                <%--                    <div class="pfv-item-title"><c:out value="${pf.title}"/></div>--%>
                                        </div>

                                        <c:if test="${not empty pf.portfolioUrl}">
                                            <div class="pfv-item-sub" style="margin-top:6px;">
                                                <a class="pfv-link" href="${pf.portfolioUrl}" target="_blank" rel="noopener">
                                                    파일 보기
                                                </a>
                                            </div>
                                        </c:if>

                                        <c:if test="${not empty pf.description}">
                                            <div class="pfv-item-desc"><c:out value="${pf.description}"/></div>
                                        </c:if>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>

                    <!-- 링크 -->
                    <c:if test="${not empty p.githubUrl or not empty p.websiteUrl}">
                        <div class="pfv-panel">
                            <h3>링크 <span class="pfv-badge">Links</span></h3>
                            <div class="pfv-kv">
                                <c:if test="${not empty p.githubUrl}">
                                    <div class="pfv-k">GitHub</div>
                                    <div class="pfv-v">
                                        <a class="pfv-link" href="${p.githubUrl}" target="_blank" rel="noopener">
                                            <c:out value="${p.githubUrl}"/>
                                        </a>
                                    </div>
                                </c:if>

                                <c:if test="${not empty p.websiteUrl}">
                                    <div class="pfv-k">Website</div>
                                    <div class="pfv-v">
                                        <a class="pfv-link" href="${p.websiteUrl}" target="_blank" rel="noopener">
                                            <c:out value="${p.websiteUrl}"/>
                                        </a>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </c:if>

                    <!-- 연락처 -->
                    <c:if test="${not empty p.email}">
                        <div class="pfv-panel">
                            <h3>연락처 <span class="pfv-badge">Contact</span></h3>
                            <div class="pfv-kv">
                                <div class="pfv-k">Email</div>
                                <div class="pfv-v"><c:out value="${p.email}"/></div>
                            </div>
                        </div>
                    </c:if>

                </div>

                <!-- ===== Right Main ===== -->
                <div class="pfv-main">

                    <!-- 소개 -->
                    <c:if test="${not empty p.introduction}">
                        <div class="pfv-section">
                            <h2>소개 <span class="pfv-hint">Intro</span></h2>
                            <div class="pfv-intro"><c:out value="${p.introduction}"/></div>
                        </div>
                    </c:if>

                    <!-- 포지션 -->
                    <c:if test="${not empty p.positions}">
                        <div class="pfv-section">
                            <h2>포지션 <span class="pfv-hint">Position</span></h2>

                            <div class="pfv-chips">
                                <c:forEach var="pos" items="${p.positions}">
                    <span class="pfv-chip">
                      <span><c:out value="${pos.stackName}"/></span>

                      <c:if test="${pos.stackLevel ne null || (pos.stackYear ne null && pos.stackYear gt 0)}">
                        <span class="pfv-lvl">
                          <c:if test="${pos.stackLevel ne null}">
                            <span class="pfv-bars">
                              <c:forEach var="i" begin="1" end="5">
                                  <span class="pfv-bar ${i <= pos.stackLevel ? 'on' : ''}"></span>
                              </c:forEach>
                            </span>
                          </c:if>

                          <c:if test="${pos.stackYear ne null && pos.stackYear gt 0}">
                              · <c:out value="${pos.stackYear}"/>y
                          </c:if>
                        </span>
                      </c:if>
                    </span>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>

                    <!-- 스킬 -->
                    <c:if test="${not empty p.skills}">
                        <div class="pfv-section">
                            <h2>스킬 <span class="pfv-hint">Skills</span></h2>
                            <div class="pfv-chips">
                                <c:forEach var="s" items="${p.skills}">
                    <span class="pfv-chip">
                      <span><c:out value="${s.stackName}"/></span>
                      <span class="pfv-lvl">
                        <span class="pfv-bars">
                          <c:forEach var="i" begin="1" end="5">
                              <span class="pfv-bar ${i <= s.stackLevel ? 'on' : ''}"></span>
                          </c:forEach>
                        </span>
                        <c:if test="${s.stackYear ne null && s.stackYear gt 0}">
                            · <c:out value="${s.stackYear}"/>y
                        </c:if>
                      </span>
                    </span>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>

                    <!-- 경력 -->
                    <c:if test="${not empty p.careers}">
                        <div class="pfv-section">
                            <h2>경력 <span class="pfv-hint">Career</span></h2>
                            <div class="pfv-list">
                                <c:forEach var="c" items="${p.careers}">
                                    <div class="pfv-item">
                                        <div class="pfv-item-top">
                                            <div>
                                                <div class="pfv-item-title"><c:out value="${c.companyName}"/></div>
                                                <div class="pfv-item-sub"><c:out value="${c.role}"/> · <c:out value="${c.position}"/></div>
                                            </div>
                                            <div class="pfv-item-sub">
                                                <c:out value="${c.startDate}"/>
                                                <c:if test="${not empty c.endDate}"> ~ <c:out value="${c.endDate}"/></c:if>
                                                <c:if test="${empty c.endDate}"> ~ 재직중</c:if>
                                            </div>
                                        </div>
                                        <c:if test="${not empty c.description}">
                                            <div class="pfv-item-desc"><c:out value="${c.description}"/></div>
                                        </c:if>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>

                    <!-- 외부 프로젝트 경험 -->
                    <c:if test="${not empty p.projectExperiences}">
                        <div class="pfv-section">
                            <h2>외부 프로젝트 경험 <span class="pfv-hint">External Projects</span></h2>
                            <div class="pfv-list">
                                <c:forEach var="e" items="${p.projectExperiences}">
                                    <div class="pfv-item">
                                        <div class="pfv-item-top">
                                            <div>
                                                <div class="pfv-item-title"><c:out value="${e.title}"/></div>
                                                <div class="pfv-item-sub">
                                                    <c:out value="${e.role}"/>
                                                    <c:if test="${not empty e.clientName}">
                                                        · <c:out value="${e.clientName}"/>
                                                    </c:if>
                                                </div>
                                            </div>
                                            <div class="pfv-item-sub">
                                                <c:out value="${e.startDate}"/>
                                                <c:if test="${not empty e.endDate}"> ~ <c:out value="${e.endDate}"/></c:if>
                                                <c:if test="${empty e.endDate}"> ~ 진행중</c:if>
                                            </div>
                                        </div>
                                        <c:if test="${not empty e.description}">
                                            <div class="pfv-item-desc"><c:out value="${e.description}"/></div>
                                        </c:if>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>

                    <!-- Ratel Ocean 프로젝트 -->
                    <div class="pfv-section">
                        <h2>Ratel Ocean 프로젝트 <span class="pfv-hint">Completed on Platform</span></h2>

                        <c:if test="${empty p.completedProjects}">
                            <div class="pfv-item">
                                <div class="pfv-item-desc" style="margin-top:0; color: var(--muted); font-weight:850;">
                                    완료된 프로젝트가 아직 없습니다.
                                </div>
                            </div>
                        </c:if>

                        <c:if test="${not empty p.completedProjects}">
                            <div class="pfv-list">
                                <c:forEach var="cp" items="${p.completedProjects}">
                                    <div class="pfv-item" style="background: linear-gradient(180deg, #fff 0%, #fbfaff 100%);">
                                        <div class="pfv-item-top">
                                            <div>
                                                <div class="pfv-item-title"><c:out value="${cp.projectTitle}"/></div>
                                                <div class="pfv-item-sub">
                                                    <c:out value="${cp.clientName}"/> · 완료일 <c:out value="${cp.completedDate}"/>
                                                </div>
                                            </div>

                                            <div class="pfv-stars">
                                                <c:choose>
                                                    <c:when test="${cp.clientRating ne null}">
                                                        <c:forEach var="i" begin="1" end="5">
                                                            <c:choose>
                                                                <c:when test="${i <= cp.clientRating}">★</c:when>
                                                                <c:otherwise>☆</c:otherwise>
                                                            </c:choose>
                                                        </c:forEach>
                                                        <span class="pfv-score">(<c:out value="${cp.clientRating}"/>.0)</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        ☆☆☆☆☆ <span class="pfv-score">(미평가)</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>

                                        <c:if test="${not empty cp.clientExperience}">
                                            <div class="pfv-item-desc">클라이언트 평가 : <c:out value="${cp.clientExperience}"/></div>
                                        </c:if>

                                        <c:if test="${not empty cp.stacks}">
                                            <div style="margin-top:10px;">
                                                <div class="pfv-chips">
                                                    <c:forEach var="st" items="${cp.stacks}">
                              <span class="pfv-chip">
                                <c:out value="${st.stackName}"/>
                                <c:if test="${st.isPrimary}">
                                    <span class="pfv-lvl">· primary</span>
                                </c:if>
                              </span>
                                                    </c:forEach>
                                                </div>
                                            </div>
                                        </c:if>

                                    </div>
                                </c:forEach>
                            </div>
                        </c:if>
                    </div>

                </div>
            </div>
        </div>

    </div>
</div>
</body>
</html>
