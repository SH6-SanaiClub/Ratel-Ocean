<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>프로젝트 등록 | Ratel Ocean</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote-lite.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/project/create.css">
</head>
<body>

<div class="wrapper">
    <div class="step-indicator">
        <div class="step active" data-step="1">1. 기본 정보</div>
        <div class="step" data-step="2">2. 전문가 요건</div>
        <div class="step" data-step="3">3. 일정 및 계약</div>
        <div class="step" data-step="4">4. 등록 미리보기</div>
    </div>

    <form id="projectForm" action="${pageContext.request.contextPath}/project/create" method="post" enctype="multipart/form-data">

        <div class="step-section active" id="step1">
            <div class="section-header">
                <h2 class="section-title">프로젝트 기본 정보</h2>
                <p class="section-desc">프로젝트의 핵심 내용을 구체적으로 작성해주세요.</p>
            </div>

            <div class="form-group">
                <label class="label">프로젝트 제목 <span class="required">*</span></label>
                <input type="text" name="title" id="title" class="form-control"
                       placeholder="예) 배달 플랫폼 관리자 페이지 기획 및 디자인 (30자 이내)" required>
            </div>

            <div class="form-group" style="position:relative;">
                <label class="label">상세 내용 <span class="required">*</span></label>
                <div class="textarea-guide-box">
                    <p class="guide-title"><i class="fa-solid fa-lightbulb"></i> 상세 내용은 이렇게 작성해보세요!</p>
                    <ul class="guide-list">
                        <li><strong>1. 프로젝트 배경:</strong> 프로젝트를 시작하게 된 계기나 목적을 알려주세요.</li>
                        <li><strong>2. 주요 기능:</strong> 꼭 필요한 핵심 기능(로그인, 결제, GPS 등)을 나열해주세요.</li>
                        <li><strong>3. 작업 분량:</strong> 기획서 유무, 예상 페이지 수 등을 적어주시면 정확한 견적이 가능합니다.</li>
                        <li><strong>4. 참고 자료:</strong> 벤치마킹할 사이트나 앱 URL이 있다면 남겨주세요.</li>
                    </ul>
                </div>
                <textarea name="description" id="description" class="form-control" required></textarea>
            </div>

            <div class="form-group">
                <label class="label">첨부 파일 (선택)</label>
                <div class="file-upload-box" onclick="document.getElementById('planFile').click()">
                    <div id="file-placeholder">
                        <i class="fa-solid fa-cloud-arrow-up upload-icon"></i>
                        <p class="upload-text">파일을 이곳에 드래그하거나 클릭하여 업로드하세요</p>
                        <p class="upload-sub">기획서, 요구사항 정의서 등 (최대 5GB)</p>
                    </div>
                    <div id="file-selected" style="display:none;" class="file-info-center">
                        <i class="fa-solid fa-check-circle file-icon-selected"></i>
                        <p id="file-name-display" class="file-name-text"></p>
                        <span class="change-btn">파일 변경하기</span>
                    </div>
                    <input type="file" id="planFile" name="planFile" style="display:none;" onchange="handleFileSelect(this)">
                </div>
            </div>

            <div class="btn-area right">
                <button type="button" class="btn btn-next" onclick="nextStep(2)">다음 단계</button>
            </div>
        </div>

        <div class="step-section" id="step2">
            <div class="section-header">
                <h2 class="section-title">전문가 요건</h2>
            </div>

            <div class="form-group">
                <label class="label">개발 분야 (중복 선택 가능) <span class="required">*</span></label>
                <div class="position-grid">
                    <c:forEach var="pos" items="${positionList}">
                        <div class="position-card" onclick="togglePosition(this)">
                            <div class="icon-wrapper">
                                <c:set var="n" value="${fn:toLowerCase(pos.stackName)}" />
                                <c:choose>
                                    <%-- 1. AI/인공지능 (가장 먼저 체크) --%>
                                    <c:when test="${fn:contains(n, 'ai') or fn:contains(n, 'artificial') or fn:contains(n, 'intelligence') or fn:contains(n, 'ml') or fn:contains(n, '인공지능') or fn:contains(n, '머신러닝') or fn:contains(n, '딥러닝') or fn:contains(n, 'learning')}">
                                        <i class="fa-solid fa-brain"></i>
                                    </c:when>
                                    <%-- 2. 데이터베이스 (DB, SQL 등) --%>
                                    <c:when test="${fn:contains(n, 'db') or fn:contains(n, 'sql') or fn:contains(n, 'database') or fn:contains(n, '데이터베이스') or fn:contains(n, 'nosql')}">
                                        <i class="fa-solid fa-database"></i>
                                    </c:when>
                                    <%-- 3. 웹 --%>
                                    <c:when test="${fn:contains(n, 'web') or fn:contains(n, '웹') or fn:contains(n, 'front') or fn:contains(n, 'back') or fn:contains(n, 'full') or fn:contains(n, 'html')}">
                                        <i class="fa-solid fa-globe"></i>
                                    </c:when>
                                    <%-- 4. 앱/모바일 --%>
                                    <c:when test="${fn:contains(n, 'app') or fn:contains(n, 'mobile') or fn:contains(n, '모바일') or fn:contains(n, 'ios') or fn:contains(n, 'android') or fn:contains(n, '앱')}">
                                        <i class="fa-solid fa-mobile-screen-button"></i>
                                    </c:when>
                                    <%-- 5. 게임/VR --%>
                                    <c:when test="${fn:contains(n, 'game') or fn:contains(n, '게임') or fn:contains(n, 'vr') or fn:contains(n, 'unity') or fn:contains(n, 'unreal')}">
                                        <i class="fa-solid fa-gamepad"></i>
                                    </c:when>
                                    <%-- 6. 인프라/DevOps/Cloud --%>
                                    <c:when test="${fn:contains(n, 'devops') or fn:contains(n, 'infra') or fn:contains(n, 'cloud') or fn:contains(n, 'aws') or fn:contains(n, '서버') or fn:contains(n, '인프라') or fn:contains(n, 'system')}">
                                        <i class="fa-solid fa-server"></i>
                                    </c:when>
                                    <%-- 7. 임베디드/HW --%>
                                    <c:when test="${fn:contains(n, 'embedded') or fn:contains(n, 'iot') or fn:contains(n, 'hw') or fn:contains(n, '임베디드') or fn:contains(n, '하드웨어')}">
                                        <i class="fa-solid fa-microchip"></i>
                                    </c:when>
                                    <%-- 8. 보안 --%>
                                    <c:when test="${fn:contains(n, 'security') or fn:contains(n, 'sec') or fn:contains(n, '보안') or fn:contains(n, '해킹')}">
                                        <i class="fa-solid fa-shield-halved"></i>
                                    </c:when>
                                    <%-- 9. 블록체인 --%>
                                    <c:when test="${fn:contains(n, 'block') or fn:contains(n, 'chain') or fn:contains(n, '블록체인')}">
                                        <i class="fa-solid fa-link"></i>
                                    </c:when>
                                    <%-- 10. 디자인 --%>
                                    <c:when test="${fn:contains(n, 'design') or fn:contains(n, 'ui') or fn:contains(n, 'ux') or fn:contains(n, '디자인') or fn:contains(n, 'publish') or fn:contains(n, '퍼블리싱')}">
                                        <i class="fa-solid fa-pen-nib"></i>
                                    </c:when>
                                    <%-- 11. 기획/PM --%>
                                    <c:when test="${fn:contains(n, 'plan') or fn:contains(n, 'pm') or fn:contains(n, '기획') or fn:contains(n, 'po') or fn:contains(n, 'manager')}">
                                        <i class="fa-solid fa-file-signature"></i>
                                    </c:when>
                                    <%-- 기타 --%>
                                    <c:otherwise>
                                        <i class="fa-solid fa-code"></i>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <span>${pos.stackName}</span>
                            <input type="checkbox" name="positionIds" value="${pos.stackId}">
                        </div>
                    </c:forEach>
                </div>
            </div>

            <div class="form-group">
                <label class="label">필요 기술 스택 <span class="required">*</span></label>
                <div class="selected-stack-area">
                    <div id="selectedChips" class="chips-wrap"></div>
                    <span id="stackPlaceholder" class="stack-placeholder">아래 목록에서 기술을 선택하면 여기에 추가됩니다.</span>
                </div>
                <div class="stack-search-wrap">
                    <input type="text" id="stackSearch" class="form-control" placeholder="기술 스택 검색">
                    <i class="fa-solid fa-magnifying-glass search-icon"></i>
                </div>
                <div id="stackContainer" class="stack-list-visible">
                    <c:forEach var="skill" items="${skillList}">
                        <div class="stack-chip" onclick="toggleStack(this, '${skill.stackName}')">
                                ${skill.stackName}
                            <input type="checkbox" name="stackIds" value="${skill.stackId}">
                        </div>
                    </c:forEach>
                </div>
                <label class="check-label-btn mt-10">
                    <input type="checkbox" id="stackIdsUnknown" name="stackIdsUnknown" onchange="toggleStackUnknown(this)">
                    <span class="btn-text">🤷‍♂️ 잘 모르겠어요 (전문가와 협의)</span>
                </label>
            </div>

            <div class="row-half">
                <div class="col-half">
                    <label class="label">요구 숙련도</label>
                    <select name="minLevel" class="form-control">
                        <option value="1" selected>Lv.1 초급 (Junior)</option>
                        <option value="2">Lv.2 중급 (Middle)</option>
                        <option value="3">Lv.3 고급 (Senior)</option>
                        <option value="4">Lv.4 특급 (Lead)</option>
                        <option value="5">Lv.5 마스터 (Master)</option>
                    </select>
                </div>
                <div class="col-half">
                    <label class="label">필요 경력</label>
                    <div class="input-unit-wrapper">
                        <input type="number" id="minYear" name="minYear" class="form-control" placeholder="0">
                        <span class="unit">년 이상</span>
                    </div>
                    <label class="check-label small-check">
                        <input type="checkbox" id="minYearUnknown" onchange="toggleYear(this)"> 경력 무관
                    </label>
                </div>
            </div>

            <div class="btn-area">
                <button type="button" class="btn btn-prev" onclick="prevStep(1)">이전</button>
                <button type="button" class="btn btn-next" onclick="nextStep(3)">다음 단계</button>
            </div>
        </div>

        <div class="step-section" id="step3">
            <div class="section-header">
                <h2 class="section-title">일정 및 계약 조건</h2>
            </div>

            <div class="form-group">
                <label class="label">지출 가능 예산 <span class="required">*</span></label>
                <div class="input-unit-wrapper large-input">
                    <span class="currency-symbol">₩</span>
                    <input type="text" id="budgetInput" name="budget" class="form-control pl-40" placeholder="0" onkeyup="inputNumberFormat(this)" required>
                    <span class="unit">원</span>
                </div>
                <label class="check-label small-check">
                    <input type="checkbox" name="budgetNegotiable" value="true"> 예산 조율 가능
                </label>
            </div>

            <div class="row-half">
                <div class="col-half">
                    <label class="label">예상 기간 <span class="required">*</span></label>
                    <select name="estDuration" id="estDuration" class="form-control" required>
                        <option value="" disabled selected>선택해주세요</option>
                        <option value="1개월 이하">1개월 이하</option>
                        <option value="1~3개월">1~3개월</option>
                        <option value="3~6개월">3~6개월</option>
                        <option value="6개월 이상">6개월 이상</option>
                    </select>
                    <label class="check-label small-check">
                        <input type="checkbox" name="durationNegotiable" value="true"> 기간 협의 가능
                    </label>
                </div>
                <div class="col-half">
                    <label class="label">시작 예정일 <span class="required">*</span></label>
                    <input type="date" id="startDate" name="startDate" class="form-control">
                    <div class="radio-group-row">
                        <label class="radio-chip">
                            <input type="radio" name="startType" value="ASAP" checked onclick="toggleStartType(this)">
                            <span>즉시 착수</span>
                        </label>
                        <label class="radio-chip">
                            <input type="radio" name="startType" value="DATE" onclick="toggleStartType(this)">
                            <span>날짜 지정</span>
                        </label>
                    </div>
                </div>
            </div>

            <hr style="margin: 30px 0; border:0; border-top:1px solid #eee;">

            <div class="row-half">
                <div class="col-half">
                    <label class="label">미팅 방식 <span class="required">*</span></label>
                    <div class="radio-group-row">
                        <label class="radio-chip">
                            <input type="radio" name="communicateMethod" value="ONLINE" checked>
                            <span>온라인 (화상/메신저)</span>
                        </label>
                        <label class="radio-chip">
                            <input type="radio" name="communicateMethod" value="OFFLINE">
                            <span>오프라인 (대면)</span>
                        </label>
                    </div>
                </div>
                <div class="col-half">
                    <label class="label">대금 지급 방식 <span class="required">*</span></label>
                    <div class="radio-group-row">
                        <label class="radio-chip">
                            <input type="radio" name="paymentMethod" value="LUMP_SUM" checked>
                            <span>일괄 지급 (종료 후)</span>
                        </label>
                        <label class="radio-chip">
                            <input type="radio" name="paymentMethod" value="INSTALLMENT">
                            <span>분할 지급 (단계별)</span>
                        </label>
                    </div>
                </div>
            </div>

            <div class="form-group">
                <label class="label">무상 수정 가능 횟수 (최대 3회) <span class="required">*</span></label>
                <div class="input-unit-wrapper" style="max-width: 200px;">
                    <input type="number" name="maxRevisionCount" id="maxRevisionCount" class="form-control" value="0" required>
                    <span class="unit">회</span>
                </div>
            </div>

            <div class="form-group">
                <label class="label">수정 및 재진행 정책 (선택)</label>
                <div class="textarea-guide-box">
                    <p class="guide-title" style="margin-bottom:5px;"><i class="fa-solid fa-pen-to-square"></i> 정책 작성 가이드</p>
                    <p style="font-size:13px; color:#666; margin:0;">수정 범위 및 추가 비용 발생 기준을 명시하면 분쟁을 예방할 수 있습니다.</p>
                </div>
                <textarea name="changePolicy" id="changePolicy" class="form-control" style="height:100px; min-height:100px;"></textarea>
            </div>

            <div class="btn-area">
                <button type="button" class="btn btn-prev" onclick="prevStep(2)">이전</button>
                <button type="button" class="btn btn-next" onclick="nextStep(4)">미리보기</button>
            </div>
        </div>

        <div class="step-section" id="step4" style="background:transparent; padding:0; border:none; box-shadow:none;">
            <div style="text-align:center; margin-bottom:30px;">
                <h2 style="font-size:26px; font-weight:800; color:#333;">프로젝트 공지 미리보기</h2>
                <p style="color:#666;">등록 전 꼼꼼히 확인해주세요.</p>
            </div>

            <div class="preview-card">
                <div class="preview-header-wrap">
                    <div class="preview-badges">
                        <span class="p-badge p-badge-blue" id="prev-positions">웹개발</span>
                        <span class="p-badge p-badge-green">등록 대기</span>
                    </div>
                    <h1 class="preview-title" id="prev-title"></h1>

                    <div class="preview-summary-box">
                        <div class="sum-item">
                            <div class="sum-icon"><i class="fa-solid fa-coins"></i></div>
                            <div class="sum-info">
                                <span class="sum-label">예상 예산</span>
                                <strong class="sum-val" id="prev-budget"></strong>
                            </div>
                        </div>
                        <div class="sum-divider"></div>
                        <div class="sum-item">
                            <div class="sum-icon"><i class="fa-regular fa-calendar"></i></div>
                            <div class="sum-info">
                                <span class="sum-label">예상 기간</span>
                                <strong class="sum-val" id="prev-duration"></strong>
                            </div>
                        </div>
                        <div class="sum-divider"></div>
                        <div class="sum-item">
                            <div class="sum-icon"><i class="fa-solid fa-rocket"></i></div>
                            <div class="sum-info">
                                <span class="sum-label">시작 예정일</span>
                                <strong class="sum-val" id="prev-start"></strong>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="preview-body-wrap">
                    <div class="preview-row">
                        <h3 class="preview-label"><i class="fa-solid fa-circle-info"></i> 프로젝트 상세 내용</h3>
                        <div class="preview-content-text" id="prev-desc"></div>
                    </div>

                    <div class="preview-row">
                        <h3 class="preview-label"><i class="fa-solid fa-code"></i> 필요 기술 / 숙련도</h3>
                        <div class="tech-chip-list" id="prev-stacks" style="margin-bottom:15px;"></div>

                        <div id="prev-req-box" class="req-info-box">
                            <div class="req-item">
                                <i class="fa-solid fa-user-graduate"></i>
                                <span id="prev-level-text"></span>
                            </div>
                            <div class="req-divider"></div>
                            <div class="req-item">
                                <i class="fa-solid fa-briefcase"></i>
                                <span id="prev-year-text"></span>
                            </div>
                        </div>
                    </div>

                    <div class="preview-row">
                        <h3 class="preview-label"><i class="fa-solid fa-file-contract"></i> 계약 및 작업 조건</h3>
                        <ul class="contract-info-list" style="list-style:none; padding:0; color:#555;">
                            <li><span style="font-weight:600; margin-right:10px;">• 미팅 방식:</span> <span id="prev-meeting"></span></li>
                            <li><span style="font-weight:600; margin-right:10px;">• 대금 지급:</span> <span id="prev-payment"></span></li>
                            <li><span style="font-weight:600; margin-right:10px;">• 수정 횟수:</span> <span id="prev-revision"></span></li>
                        </ul>
                        <div id="prev-policy-area" style="margin-top:10px; padding:15px; background:#f9f9f9; border-radius:8px; font-size:14px; color:#666; display:none;">
                            <strong>[수정 정책]</strong> <span id="prev-policy-text"></span>
                        </div>
                    </div>

                    <div class="preview-row" id="prev-file-area" style="display:none;">
                        <h3 class="preview-label"><i class="fa-solid fa-paperclip"></i> 첨부파일</h3>
                        <div class="preview-file-card">
                            <div class="pf-icon"><i class="fa-solid fa-file-arrow-down"></i></div>
                            <div class="pf-info">
                                <div class="pf-name" id="prev-filename"></div>
                                <div class="pf-sub">클릭하여 다운로드</div>
                            </div>
                            <div class="pf-action"><i class="fa-solid fa-download"></i></div>
                        </div>
                    </div>
                </div>
            </div>

            <input type="hidden" name="isPublic" value="true">
            <input type="hidden" name="projectStatus" value="READY">
            <input type="hidden" name="viewCount" value="0">
            <input type="hidden" name="applicantCount" value="0">
            <input type="hidden" name="deadlineDate" id="deadlineDate">

            <div class="btn-area">
                <button type="button" class="btn btn-prev" onclick="prevStep(3)">수정하기</button>
                <button type="submit" class="btn btn-submit">프로젝트 등록 완료</button>
            </div>
        </div>

    </form>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote-lite.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/project/create.js"></script>
</body>
</html>