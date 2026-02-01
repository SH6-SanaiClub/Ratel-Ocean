<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>프로젝트 대시보드</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/project/dashboard.css">
</head>

<body>
<jsp:include page="/WEB-INF/views/common/headerBase.jsp" />
<div class="dashboard-wrap">
    <c:if test="${isClient}">
        <div class="register-area">
            <a href="${pageContext.request.contextPath}/project/create" class="btn-register">
                프로젝트 등록하기
            </a>
        </div>
    </c:if>

    <!--  상단 요약 -->
    <div class="summary-grid">

        <!-- today 토글 -->
        <a class="summary-link"
           href="${pageContext.request.contextPath}/project/dashboard?summary=${summary eq 'today' ? 'all' : 'today'}&page=1&size=${size}&onlyActive=${onlyActive}&keyword=${fn:escapeXml(keyword)}">
            <div class="summary-card ${summary eq 'today' ? 'is-active' : ''}">
                <div>
                    <div class="summary-title">오늘의 신규 프로젝트</div>
                    <div>
                        <span class="summary-value">${empty todayNewCount ? 0 : todayNewCount}</span>
                        <span class="summary-unit">건</span>
                    </div>
                </div>
                <div class="summary-badge">+</div>
            </div>
        </a>
        <!-- deadline7 토글 -->
        <a class="summary-link"
           href="${pageContext.request.contextPath}/project/dashboard?summary=${summary eq 'deadline7' ? 'all' : 'deadline7'}&page=1&size=${size}&onlyActive=${onlyActive}&keyword=${fn:escapeXml(keyword)}">
            <div class="summary-card ${summary eq 'deadline7' ? 'is-active' : ''}">
                <div>
                    <div class="summary-title">마감 임박 (7일 이내)</div>
                    <div>
                    <span class="summary-value" style="color:var(--danger);">
                        ${empty deadline7Count ? 0 : deadline7Count}
                    </span>
                        <span class="summary-unit">건</span>
                    </div>
                </div>
                <div class="summary-badge danger">!</div>
            </div>
        </a>

    </div>


    <!-- 검색 -->
    <%--<form class="search-box" method="get" action="${pageContext.request.contextPath}/project/dashboard">
        <input type="text"
               name="keyword"
               placeholder="프로젝트 제목 검색"
               value="${fn:escapeXml(keyword)}"/>

        <label>
            <input type="checkbox" name="onlyActive" value="true"
                   <c:if test="${onlyActive}">checked</c:if> />
            마감된 프로젝트 보기
        </label>

        <input type="hidden" name="size" value="${empty size ? 10 : size}"/>
        <input type="hidden" name="summary" value="${empty summary ? 'all' : summary}"/>

        <button type="submit">검색</button>
    </form>--%>

    <form id="filterForm" method="get" action="${pageContext.request.contextPath}/project/dashboard">

        <div class="filter-search-bar">
            <button type="button" class="btn-filter-toggle" id="filterToggleBtn">
                필터 옵션
            </button>

            <label class="checkbox-label" style="margin-left: 15px;">
                <input type="checkbox" name="onlyActive" value="true" <c:if test="${onlyActive}">checked</c:if>>
                마감된 프로젝트 포함
            </label>

            <div class="search-group">
                <select name="sort" class="sort-select">
                    <option value="latest" ${sort == 'latest' ? 'selected' : ''}>등록일순</option>
                    <option value="budget_desc" ${sort == 'budget_desc' ? 'selected' : ''}>예산순</option>
                    <option value="deadline_asc" ${sort == 'deadline_asc' ? 'selected' : ''}>마감임박순</option>
                </select>

                <div class="search-input-wrap">
                    <input type="text" name="keyword" class="search-input"
                           placeholder="프로젝트 제목 검색" value="${fn:escapeXml(keyword)}"/>
                    <button type="submit" class="search-btn">검색</button>
                </div>
            </div>
        </div>

        <div class="active-tags-bar" id="activeTagsContainer"></div>

        <div class="filter-panel" id="filterPanel">
            <div class="filter-body">
                <div class="filter-sidebar">
                    <div class="filter-tab active" data-target="tab-position">포지션</div>
                    <div class="filter-tab" data-target="tab-skill">스킬</div>
                    <div class="filter-tab" data-target="tab-budget">예산</div>
                </div>

                <div class="filter-content">

                    <div id="tab-position" class="tab-content active">
                        <input type="text" class="stack-search-input" placeholder="포지션 검색..."
                               onkeyup="filterChips(this)">
                        <div class="chip-list">
                            <c:forEach var="pos" items="${positionList}">
                                <c:set var="isPosChecked" value="false"/>
                                <c:if test="${not empty paramValues.positionIds}">
                                    <c:forEach var="pid" items="${paramValues.positionIds}">
                                        <c:if test="${pid eq pos.stackId}"><c:set var="isPosChecked"
                                                                                  value="true"/></c:if>
                                    </c:forEach>
                                </c:if>

                                <label class="filter-chip ${isPosChecked ? 'selected' : ''}"
                                       data-name="${pos.stackName}">
                                        ${pos.stackName}
                                    <input type="checkbox" name="positionIds"
                                           value="${pos.stackId}" ${isPosChecked ? 'checked' : ''}>
                                </label>
                            </c:forEach>
                        </div>
                    </div>

                    <div id="tab-skill" class="tab-content">
                        <input type="text" class="stack-search-input" placeholder="기술 스택 검색..."
                               onkeyup="filterChips(this)">
                        <div class="chip-list">
                            <c:forEach var="skill" items="${skillList}">
                                <c:set var="isSkillChecked" value="false"/>
                                <c:if test="${not empty paramValues.stackIds}">
                                    <c:forEach var="sid" items="${paramValues.stackIds}">
                                        <c:if test="${sid eq skill.stackId}"><c:set var="isSkillChecked" value="true"/></c:if>
                                    </c:forEach>
                                </c:if>

                                <label class="filter-chip ${isSkillChecked ? 'selected' : ''}"
                                       data-name="${skill.stackName}">
                                        ${skill.stackName}
                                    <input type="checkbox" name="stackIds"
                                           value="${skill.stackId}" ${isSkillChecked ? 'checked' : ''}>
                                </label>
                            </c:forEach>
                        </div>
                    </div>

                    <div id="tab-budget" class="tab-content">
                        <h4 style="margin-bottom:12px; font-weight:800; color:#374151;">예산 범위 (원)</h4>
                        <div class="budget-wrap">
                            <input type="text" name="minBudget" class="budget-field" placeholder="최소금액"
                                   value="${minBudget}" onkeyup="inputNumberFormat(this)">

                            <span style="font-weight:900; color:#cbd5e1;">—</span>

                            <input type="text" name="maxBudget" class="budget-field" placeholder="최대금액"
                                   value="${maxBudget}" onkeyup="inputNumberFormat(this)">
                        </div>
                    </div>

                </div>
            </div>

            <div class="panel-footer">
                <button type="button" class="btn-reset" id="resetFilterBtn">
                    <i class="fa-solid fa-rotate-right"></i> 필터 초기화
                </button>

                <button type="submit" class="btn-apply">적용하기</button>
            </div>
        </div>

        <input type="hidden" name="page" id="pageInput" value="${page}"/>

        <input type="hidden" name="size" value="${empty size ? 10 : size}"/>
        <input type="hidden" name="summary" value="${empty summary ? 'all' : summary}"/>
    </form>


    <!-- 리스트 -->
    <div class="project-list">

        <c:if test="${empty projectList}">
            <div class="empty">조건에 맞는 프로젝트가 없습니다.</div>
        </c:if>

        <c:forEach var="p" items="${projectList}">

            <div class="project-card"
                 onclick="location.href='${pageContext.request.contextPath}/project/detail?projectId=${p.projectId}&page=${page}&size=${size}&onlyActive=${onlyActive}&keyword=${fn:escapeXml(keyword)}'">

                <!-- LEFT -->
                <div class="left">

                    <!-- 회사명 / 개인 클라이언트 -->
                    <div class="owner-name">
                        <c:choose>
                            <c:when test="${not empty p.companyName}">
                                <span class="badge company">🏢 ${p.companyName}</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge personal">👤 ${p.clientName}</span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- 포지션 -->
                    <div class="chips">
                        <c:if test="${not empty p.stacks}">
                            <c:forEach var="s" items="${p.stacks}">
                                <c:if test="${not empty s.category and s.category eq 'POSITION'}">
                                    <span class="chip position">${s.stackName}</span>
                                </c:if>
                            </c:forEach>
                        </c:if>
                    </div>

                    <div class="title">${p.title}</div>

                    <!-- 스킬 -->
                    <div class="chips">
                        <c:if test="${not empty p.stacks}">
                            <c:forEach var="s" items="${p.stacks}">
                                <c:if test="${not empty s.category and s.category eq 'SKILL'}">
                                          <span class="chip">
                                            ${s.stackName}
                                            <c:if test="${s.stackLevel != null}">
                                            </c:if>
                                          </span>
                                </c:if>
                            </c:forEach>
                        </c:if>
                    </div>

                </div>

                <!-- RIGHT -->
                <div class="right">

                    <!-- 북마크 -->
                    <button type="button"
                            class="bookmark-btn ${p.bookmarked ? 'is-active' : ''}"
                            data-project-id="${p.projectId}"
                            title="북마크"
                            onclick="event.preventDefault(); event.stopPropagation();">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="M6 3h12a1 1 0 0 1 1 1v17l-7-4-7 4V4a1 1 0 0 1 1-1z"></path>
                        </svg>
                    </button>


                    <!-- D-day + 지원자 -->
                    <div class="right-mid">
                        <div class="dday">
                            <c:choose>
                                <c:when test="${p.dday >= 0}">마감 D-${p.dday}</c:when>
                                <c:otherwise>마감</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="applicants">지원자 ${p.applicantCount}명</div>
                    </div>

                    <!-- 예상기간(예산 왼쪽) + 예산(우측 아래) -->
                    <div class="right-bottom">
                        <div class="duration">예상 기간<br/>${p.estDuration}</div>
                        <div class="budget">
                            <fmt:formatNumber value="${p.budget / 10000}"
                                              maxFractionDigits="0"/>만원
                        </div>
                    </div>

                </div>

            </div>
            <%--            </a>--%>
        </c:forEach>

    </div>

    <!-- 페이징 -->
    <c:if test="${totalPages > 1}">
        <div class="pagination">

            <c:choose>
                <c:when test="${hasPrevBlock}">
                    <a class="page-link" href="javascript:void(0);" onclick="goPage(${prevBlockPage})">&laquo;</a>
                </c:when>
                <c:otherwise>
                    <span class="page-link disabled">&laquo;</span>
                </c:otherwise>
            </c:choose>

            <c:choose>
                <c:when test="${page > 1}">
                    <a class="page-link" href="javascript:void(0);" onclick="goPage(${page-1})">&lsaquo;</a>
                </c:when>
                <c:otherwise>
                    <span class="page-link disabled">&lsaquo;</span>
                </c:otherwise>
            </c:choose>

            <c:forEach var="pno" begin="${startPage}" end="${endPage}">
                <a class="page-link ${pno == page ? 'active' : ''}"
                   href="javascript:void(0);" onclick="goPage(${pno})">${pno}</a>
            </c:forEach>

            <c:choose>
                <c:when test="${page < totalPages}">
                    <a class="page-link" href="javascript:void(0);" onclick="goPage(${page+1})">&rsaquo;</a>
                </c:when>
                <c:otherwise>
                    <span class="page-link disabled">&rsaquo;</span>
                </c:otherwise>
            </c:choose>

            <c:choose>
                <c:when test="${hasNextBlock}">
                    <a class="page-link" href="javascript:void(0);" onclick="goPage(${nextBlockPage})">&raquo;</a>
                </c:when>
                <c:otherwise>
                    <span class="page-link disabled">&raquo;</span>
                </c:otherwise>
            </c:choose>

        </div>

        <div class="hint">${page} / ${totalPages} 페이지</div>
    </c:if>


</div>

<script>
    // 전역 유틸리티 함수

    // 숫자 콤마 포맷팅
    function inputNumberFormat(obj) {
        obj.value = comma(uncomma(obj.value));
    }

    function comma(str) {
        str = String(str);
        return str.replace(/(\d)(?=(?:\d{3})+(?!\d))/g, '$1,');
    }

    function uncomma(str) {
        str = String(str);
        return str.replace(/[^\d]+/g, '');
    }

    // 페이지 이동 함수
    function goPage(pageNo) {
        const pageInput = document.getElementById('pageInput');
        if (pageInput) {
            pageInput.value = pageNo;
        }
        submitForm(); // 공통 제출 함수 호출
    }

    // 폼 제출 공통 함수 (콤마 제거 후 전송)
    function submitForm() {
        // 예산 필드에서 콤마 제거
        document.querySelectorAll('.budget-field').forEach(input => {
            input.value = uncomma(input.value);
        });

        const form = document.getElementById('filterForm');
        if (form) {
            form.submit();
        }
    }

    // 내부 검색 함수 (포지션/스킬 검색)
    window.filterChips = function (searchInput) {
        const val = searchInput.value.toLowerCase();
        const list = searchInput.nextElementSibling;
        const items = list.querySelectorAll('.filter-chip');
        items.forEach(item => {
            const text = item.getAttribute('data-name').toLowerCase();
            item.style.display = text.includes(val) ? 'inline-flex' : 'none';
        });
    };



    // DOM 로드 후 실행
    document.addEventListener("DOMContentLoaded", () => {
        // 알림 및 북마크
        const alertMsg = "${alertMsg}";
        if (alertMsg) alert(alertMsg);

        document.querySelectorAll(".bookmark-btn").forEach((btn) => {
            btn.addEventListener("click", async (e) => {
                e.preventDefault(); e.stopPropagation();
                const projectId = btn.dataset.projectId;
                try {
                    const res = await fetch("${pageContext.request.contextPath}/project/bookmark/toggle", {
                        method: "POST",
                        headers: {"Content-Type":"application/x-www-form-urlencoded; charset=UTF-8"},
                        body: new URLSearchParams({ projectId })
                    });
                    const data = await res.json();
                    if (!data.ok) {
                        alert(data.message === "LOGIN_REQUIRED" ? "로그인이 필요합니다." : "실패");
                        return;
                    }
                    btn.classList.toggle("is-active", data.bookmarked);
                } catch (err) { console.error(err); alert("북마크 처리 중 오류"); }
            });
        });

        // 필터 UI 요소 가져오기
        const filterBtn = document.getElementById('filterToggleBtn');
        const filterPanel = document.getElementById('filterPanel');
        const tabs = document.querySelectorAll('.filter-tab');
        const contents = document.querySelectorAll('.tab-content');
        const tagContainer = document.getElementById('activeTagsContainer');
        const resetBtn = document.getElementById('resetFilterBtn');
        const applyBtn = document.querySelector('.btn-apply'); // 적용하기 버튼

        // 토글 버튼 동작
        if (filterBtn) {
            filterBtn.addEventListener('click', () => {
                filterPanel.classList.toggle('open');
                filterBtn.classList.toggle('active');
            });
        }

        // 탭 전환 동작
        tabs.forEach(tab => {
            tab.addEventListener('click', () => {
                tabs.forEach(t => t.classList.remove('active'));
                contents.forEach(c => c.classList.remove('active'));
                tab.classList.add('active');
                document.getElementById(tab.getAttribute('data-target')).classList.add('active');
            });
        });

        // 태그 렌더링 함수
        function renderActiveTags() {
            if (!tagContainer) return;
            tagContainer.innerHTML = '';

            const checkedInputs = document.querySelectorAll('.filter-chip input:checked');

            checkedInputs.forEach(input => {
                const chip = input.parentElement;
                const name = chip.getAttribute('data-name');

                const tag = document.createElement('div');
                tag.className = 'active-tag';
                // FontAwesome X 아이콘
                tag.innerHTML = `<span>\${name}</span> <i class="fa-solid fa-xmark"></i>`;

                // X 클릭 시 삭제
                tag.querySelector('i').addEventListener('click', (e) => {
                    e.stopPropagation();
                    input.checked = false;
                    chip.classList.remove('selected');
                    renderActiveTags();
                });
                tagContainer.appendChild(tag);
            });
        }

        // 칩 클릭 이벤트 연결
        const chips = document.querySelectorAll('.filter-chip');
        chips.forEach(chip => {
            const input = chip.querySelector('input');

            // 로드 시 체크 상태 반영
            if (input.checked) chip.classList.add('selected');

            input.addEventListener('change', () => {
                if (input.checked) chip.classList.add('selected');
                else chip.classList.remove('selected');
                renderActiveTags();
            });
        });

        // 초기화 버튼 클릭 이벤트
        if (resetBtn) {
            resetBtn.addEventListener('click', () => {
                // 체크박스 해제
                document.querySelectorAll('.filter-chip input').forEach(input => {
                    input.checked = false;
                    input.parentElement.classList.remove('selected');
                });

                // 예산 및 검색창 초기화
                document.querySelectorAll('.budget-field').forEach(input => input.value = '');
                document.querySelectorAll('.stack-search-input').forEach(input => {
                    input.value = '';
                    window.filterChips(input);
                });

                renderActiveTags();
            });
        }

        // 적용하기 버튼 클릭 시 콤마 제거 후 전송
        if(applyBtn) {
            applyBtn.addEventListener('click', (e) => {
                e.preventDefault();
                submitForm();
            });
        }

        // 페이지 로드 시 예산 값에 콤마 찍기
        document.querySelectorAll('.budget-field').forEach(input => {
            if(input.value) {
                input.value = comma(input.value);
            }
        });

        // 페이지 로드 시 태그 그리기
        renderActiveTags();
    });
</script>
</body>

</html>
