<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>프로젝트 등록 | Ratel Ocean</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/project/create.css">
</head>
<body>

<div class="wrapper">
    <form id="projectForm" action="${pageContext.request.contextPath}/project/create" method="post" enctype="multipart/form-data">

        <div class="step-section active" id="step1">
            <div class="step-header-group">
                <span class="step-desc-small">진행하고자 하는 프로젝트의 기본 정보를 입력해주세요.</span>
                <h2 class="step-title">프로젝트 개요</h2>
            </div>

            <div class="form-group-styled">
                <label class="label">프로젝트 제목 <span class="required">*</span></label>
                <input type="text" name="title" id="title" class="form-control" placeholder="예) 배달 플랫폼 관리자 페이지 개발" required>
            </div>

            <div class="form-group-styled">
                <label class="label">프로젝트 상세 내용 <span class="required">*</span></label>
                <textarea name="description" id="description" class="form-control" rows="20" required
                          placeholder="프로젝트 개요 :&#13;&#10;- 의뢰 배경, 달성하려는 목적/목표를 알려주세요.&#13;&#10;[예시] 운영중인 쇼핑몰의 C/S 효율 제고를 위한 AI 챗봇 개발입니다.&#13;&#10;&#13;&#10;주요 기능 :&#13;&#10;- 핵심적인 기능(혹은 화면 구성)이나 아이디어에 대해 알려주세요.&#13;&#10;[예시] 자사 C/S 메뉴얼에 대한 학습, FAQ 기반 답변 제공, 상담원 연결 등&#13;&#10;&#13;&#10;참고 사이트/앱 :&#13;&#10;- 원하는 디자인/기능을 가진 참고 서비스가 있다면 참고하는 부분들과 함께 알려주세요.&#13;&#10;[예시] 위시캣, 크몽 등 플랫폼&#13;&#10;&#13;&#10;지원 시 참고 사항 :&#13;&#10;- 파트너스가 충족해야 하는 조건이나 우대 사항 등을 알려주세요.&#13;&#10;[예시] 유사한 프로젝트 경험이 있는 업체를 찾고 있으며 디자인에 역량이 있는 업체를 선호합니다."></textarea>
            </div>

            <div class="form-group-styled">
                <label class="label">기획서 등 관련 파일</label>
                <div class="file-drop-zone compact" onclick="document.getElementById('fileInput').click()">
                    <div id="fileDisplayDefault" class="file-content-center">
                        <i class="fa-solid fa-cloud-arrow-up file-icon-mid"></i>
                        <p class="file-text-small">클릭하여 파일 업로드</p>
                    </div>
                    <div id="fileDisplaySelected" style="display:none;" class="file-content-center">
                        <i class="fa-solid fa-file-lines file-icon-selected"></i>
                        <p id="fileNameDisplay" class="file-name-text"></p>
                        <p class="file-change-text">클릭하여 파일 변경</p>
                    </div>
                </div>
                <input type="file" id="fileInput" name="planFile" style="display:none;" onchange="handleFileSelect(this)">
                <input type="hidden" name="planUrl" id="planUrl">
                <input type="hidden" name="fileSize" id="fileSize">
            </div>

            <div class="btn-area right">
                <button type="button" class="btn btn-next" onclick="nextStep(2)">다음 단계</button>
            </div>
        </div>

        <div class="step-section" id="step2">
            <div class="step-header-group">
                <span class="step-desc-small">어떤 전문가가 필요하신가요?</span>
                <h2 class="step-title">개발 영역 및 기술 스택</h2>
            </div>

            <div class="form-group-styled">
                <label class="label">개발 영역 (직군) <span class="required">*</span></label>
                <div class="selection-grid-4">
                    <c:forEach var="pos" items="${positionList}">
                        <label class="selection-card" onclick="selectCard(this)">
                            <input type="radio" name="positionId" value="${pos.stackId}" required>
                            <div class="mini-card-icon">
                                <c:choose>
                                    <c:when test="${pos.stackName eq '게임/그래픽'}"><i class="fa-solid fa-gamepad"></i></c:when>
                                    <c:when test="${pos.stackName eq '데이터베이스'}"><i class="fa-solid fa-database"></i></c:when>
                                    <c:when test="${pos.stackName eq '모바일앱'}"><i class="fa-solid fa-mobile-screen"></i></c:when>
                                    <c:when test="${pos.stackName eq '웹'}"><i class="fa-solid fa-globe"></i></c:when>
                                    <c:when test="${pos.stackName eq '임베디드/하드웨어'}"><i class="fa-solid fa-microchip"></i></c:when>
                                    <c:when test="${fn:contains(pos.stackName, 'AI')}"><i class="fa-solid fa-brain"></i></c:when>
                                    <c:when test="${fn:contains(pos.stackName, 'DevOps')}"><i class="fa-solid fa-server"></i></c:when>
                                    <c:otherwise><i class="fa-solid fa-code"></i></c:otherwise>
                                </c:choose>
                            </div>
                            <strong>${pos.stackName}</strong>
                        </label>
                    </c:forEach>
                </div>
            </div>

            <div class="form-group-styled">
                <label class="label">관련 기술 스택 <span class="required">*</span></label>
                <div id="stackDisplayBox" class="stack-display-box">
                    <span class="placeholder-text">아래 목록에서 선택하거나 검색해주세요.</span>
                </div>
                <input type="text" id="stackSearchInput" class="form-control" placeholder="기술 스택 검색 (예: Java, React)">
                <div id="selectedStackHidden" style="display:none;"></div>
                <div class="stack-list mt-2">
                    <c:forEach var="skill" items="${skillList}">
                        <div class="stack-item" onclick="addStack('${skill.stackId}', '${skill.stackName}', this)">${skill.stackName}</div>
                        <input type="checkbox" id="chk_stack_${skill.stackId}" style="display:none;">
                    </c:forEach>
                </div>
            </div>

            <div class="form-group-styled row-half">
                <div class="col-half">
                    <label class="label">요구 숙련도 <span class="required">*</span></label>
                    <select name="minLevel" class="form-control">
                        <option value="1" selected>Lv.1 입문</option>
                        <option value="2">Lv.2 초급</option>
                        <option value="3">Lv.3 중급</option>
                        <option value="4">Lv.4 중급+</option>
                        <option value="5">Lv.5 고급</option>
                    </select>
                </div>
                <div class="col-half">
                    <label class="label">필요 경력</label>
                    <div class="input-with-unit">
                        <input type="number" name="minYear" id="minYearInput" class="form-control" placeholder="0">
                        <span class="unit-text">년 (이상)</span>
                    </div>
                    <label class="check-option-small">
                        <input type="checkbox" id="minYearUnknown" onchange="toggleYear(this)"> <span>경력 무관</span>
                    </label>
                </div>
            </div>

            <div class="btn-area between">
                <button type="button" class="btn btn-prev" onclick="prevStep(1)">이전</button>
                <button type="button" class="btn btn-next" onclick="nextStep(3)">다음 단계</button>
            </div>
        </div>

        <div class="step-section" id="step3">
            <div class="step-header-group">
                <span class="step-desc-small">예산과 일정을 설정해주세요.</span>
                <h2 class="step-title">예산 및 일정</h2>
            </div>

            <div class="form-group-styled">
                <label class="label">프로젝트 예산 <span class="required">*</span></label>
                <div class="input-with-unit">
                    <span class="currency">₩</span>
                    <input type="text" name="budget" id="budgetInput" class="form-control" placeholder="0" required>
                    <span class="unit-text">원</span>
                </div>
                <label class="check-option mt-2">
                    <input type="checkbox" name="budgetNegotiable" value="true">
                    <span>입력한 예산에서 조율이 가능합니다.</span>
                </label>
            </div>

            <div class="form-group-styled">
                <label class="label">예상 시작일 <span class="required">*</span></label>
                <div class="start-date-group">
                    <label class="radio-row">
                        <input type="radio" name="startType" value="DATE" onchange="toggleStartType(this)">
                        <div class="date-input-wrapper">
                            <input type="date" name="startDate" id="startDate" class="form-control" disabled>
                        </div>
                    </label>
                    <label class="check-option indent">
                        <input type="checkbox" name="startNegotiable" value="true">
                        <span>프로젝트 착수 일자의 협의가 가능합니다.</span>
                    </label>
                    <label class="radio-row">
                        <input type="radio" name="startType" value="ASAP" checked onchange="toggleStartType(this)">
                        <span>계약 체결 이후, 즉시 시작하길 희망합니다.</span>
                    </label>
                </div>
            </div>

            <div class="form-group-styled">
                <label class="label">예상 진행 기간 <span class="required">*</span></label>
                <div class="input-with-unit">
                    <input type="number" name="estDuration" id="durationInput" class="form-control" placeholder="기간 입력" required>
                    <span class="unit-text">일</span>
                </div>
                <label class="check-option mt-2">
                    <input type="checkbox" name="durationNegotiable" value="true">
                    <span>기간 조율 가능</span>
                </label>
            </div>

            <div class="btn-area between">
                <button type="button" class="btn btn-prev" onclick="prevStep(2)">이전</button>
                <button type="button" class="btn btn-next" onclick="nextStep(4)">다음 단계</button>
            </div>
        </div>

        <div class="step-section" id="step4">
            <div class="step-header-group">
                <span class="step-desc-small">프로젝트 진행 방식을 선택해주세요.</span>
                <h2 class="step-title">계약 및 소통</h2>
            </div>
            <div class="form-group-styled">
                <label class="label">미팅 방식 <span class="required">*</span></label>
                <div class="selection-grid-2">
                    <label class="selection-card selected" onclick="selectCard(this)">
                        <input type="radio" name="communicateMethod" value="ONLINE" checked>
                        <i class="fa-solid fa-video"></i>
                        <strong>온라인 미팅</strong>
                        <span class="card-text-sub">화상회의, 메신저 등</span>
                    </label>
                    <label class="selection-card" onclick="selectCard(this)">
                        <input type="radio" name="communicateMethod" value="OFFLINE">
                        <i class="fa-solid fa-people-arrows"></i>
                        <strong>오프라인 미팅</strong>
                        <span class="card-text-sub">대면 미팅 선호</span>
                    </label>
                </div>
            </div>
            <div class="form-group-styled">
                <label class="label">대금 지급 방식 <span class="required">*</span></label>
                <div class="selection-grid-2">
                    <label class="selection-card selected" onclick="selectCard(this)">
                        <input type="radio" name="paymentMethod" value="LUMP_SUM" checked>
                        <i class="fa-solid fa-coins"></i>
                        <strong>일괄 지급</strong>
                        <span class="card-text-sub">프로젝트 종료 후 전액</span>
                    </label>
                    <label class="selection-card" onclick="selectCard(this)">
                        <input type="radio" name="paymentMethod" value="INSTALLMENT">
                        <i class="fa-solid fa-chart-pie"></i>
                        <strong>분할 지급</strong>
                        <span class="card-text-sub">단계별로 나누어 지급</span>
                    </label>
                </div>
            </div>

            <hr style="margin: 30px 0; border:0; border-top:1px solid #eee;">

            <div class="form-group-styled">
                <label class="label">무상 수정 횟수 <span class="required">*</span></label>
                <div class="input-with-unit" style="max-width: 150px;">
                    <input type="number" name="maxRevisionCount" id="maxRevisionCount" class="form-control" value="0" min="0" max="3">
                    <span class="unit-text">회</span>
                </div>
                <p class="input-desc" style="margin-top:5px; color:#d32f2f;">최대 3회까지 설정 가능합니다.</p>
            </div>

            <div class="form-group-styled">
                <label class="label">수정 관련 상세 규정 (선택)</label>
                <textarea name="changePolicy" class="form-control" rows="3" placeholder="예) 텍스트/이미지 단순 교체는 무제한입니다."></textarea>
            </div>

            <div class="btn-area between">
                <button type="button" class="btn btn-prev" onclick="prevStep(3)">이전</button>
                <button type="button" class="btn btn-next" onclick="nextStep(5)">미리보기</button>
            </div>
        </div>

        <div class="step-section" id="step5">
            <h2 class="step-title" style="text-align:center;">프로젝트 등록 미리보기</h2>
            <div class="preview-card">
                <div class="preview-header-center">
                    <span class="preview-badge" id="previewCategory">카테고리</span>
                    <h3 id="previewTitle">제목 미리보기</h3>
                </div>

                <div class="preview-grid-box">
                    <div class="preview-box-item">
                        <span class="pb-label">예상 금액</span>
                        <strong class="pb-value" id="previewBudget">0원</strong>
                    </div>
                    <div class="preview-box-item border-left">
                        <span class="pb-label">예상 기간</span>
                        <strong class="pb-value" id="previewDuration">0일</strong>
                    </div>
                    <div class="preview-box-item border-left">
                        <span class="pb-label">시작 예정</span>
                        <strong class="pb-value" id="previewStart">미정</strong>
                    </div>
                </div>

                <div class="preview-content-area">
                    <label class="label">프로젝트 내용</label>
                    <div class="preview-desc-box" id="previewDescription"></div>
                </div>

                <div class="preview-meta-area">
                    <div class="meta-row">
                        <span class="meta-label">관련 기술</span>
                        <div class="meta-value" id="previewStacks"></div>
                    </div>
                    <div class="meta-row">
                        <span class="meta-label">필요 요건</span>
                        <div class="meta-value">
                            <span class="pill-badge blue" id="previewLevelBadge"></span>
                            <span class="pill-badge green" id="previewYearBadge"></span>
                        </div>
                    </div>
                    <div class="meta-row">
                        <span class="meta-label">진행 방식</span>
                        <div class="meta-value">
                            <span id="previewComm"></span> / <span id="previewPay"></span>
                        </div>
                    </div>
                    <div class="meta-row">
                        <span class="meta-label">수정 지원</span>
                        <div class="meta-value">
                            <span id="previewRevision"></span>
                        </div>
                    </div>
                </div>

                <div id="previewFileArea" style="display:none; margin-top:20px; text-align:center; padding:15px; background:#f8f9fa; border-radius:8px;">
                    <i class="fa-solid fa-paperclip"></i> 첨부파일: <strong id="previewFileName"></strong>
                </div>
            </div>

            <input type="hidden" name="isPublic" value="true">
            <input type="hidden" name="projectStatus" value="READY">

            <div class="btn-area between">
                <button type="button" class="btn btn-prev" onclick="prevStep(4)">수정하기</button>
                <button type="submit" class="btn btn-submit">등록 완료</button>
            </div>
        </div>
    </form>
</div>
<script src="${pageContext.request.contextPath}/resources/js/project/create.js"></script>
</body>
</html>