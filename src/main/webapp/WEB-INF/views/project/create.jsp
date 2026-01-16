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
                          placeholder="&lt;1. 프로젝트 진행 배경 및 목적&gt;&#13;&#10;- 이 프로젝트를 기획하게 된 계기와 해결하고자 하는 문제를 적어주세요.&#13;&#10;(예시) 기존 오프라인 매장의 온라인 판매 확장을 위한 반응형 웹 사이트 구축&#13;&#10;&#13;&#10;&lt;2. 상세 업무 내용&gt;&#13;&#10;- 구현이 필요한 핵심 기능이나 페이지 구성에 대해 나열해 주세요.&#13;&#10;(예시) 소셜 로그인, 상품 검색/필터링, PG 결제 연동, 관리자 대시보드 개발 등&#13;&#10;&#13;&#10;&lt;3. 참고 레퍼런스&gt;&#13;&#10;- 벤치마킹하고 싶은 웹사이트나 앱 URL이 있다면 기재해 주세요.&#13;&#10;(예시) 'OOO' 서비스의 심플한 UI/UX를 선호합니다.&#13;&#10;&#13;&#10;&lt;4. 기타 유의사항&gt;&#13;&#10;- 작업 진행 시 선호하는 소통 방식이나 우대 조건을 자유롭게 적어주세요.&#13;&#10;(예시) 주 1회 진행 상황 공유 미팅 필수, 상용 서비스 출시 경험자 우대"></textarea>
            </div>

            <div class="form-group-styled">
                <label class="label">기획서 등 관련 파일</label>
                <div class="file-drop-zone compact" onclick="document.getElementById('fileInput').click()">
                    <div id="fileDisplayDefault" class="file-content-center">
                        <i class="fa-solid fa-cloud-arrow-up file-icon-mid"></i>
                        <p class="file-text-small">클릭하여 파일 업로드 (최대 5GB)</p>
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
                <label class="label">개발 영역 (분야) <span class="required">*</span></label>
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
                        <option value="1">Lv.1 입문</option>
                        <option value="2">Lv.2 초급</option>
                        <option value="3" selected>Lv.3 중급</option>
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
                    <input type="text" name="budget" id="budgetInput" class="form-control has-currency" placeholder="0" required>
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
                <select name="estDuration" id="durationSelect" class="form-control" required>
                    <option value="" disabled selected>예상 기간을 선택해주세요</option>
                    <option value="1개월 이하">1개월 이하</option>
                    <option value="1~3개월">1~3개월</option>
                    <option value="3~6개월">3~6개월</option>
                    <option value="6개월 이상">6개월 이상</option>
                </select>
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
                <label class="label">수정 요청 횟수<span class="required">*</span></label>
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
            <h2 class="step-title" style="text-align:center; margin-bottom:30px;">프로젝트 등록 미리보기</h2>

            <div class="preview-card">
                <div class="preview-header-center">
                    <span class="preview-badge" id="previewCategory">카테고리</span>
                    <h3 id="previewTitle">제목 미리보기</h3>
                </div>

                <div class="preview-grid-box">
                    <div class="preview-box-item">
                        <span class="pb-label">프로젝트 예산</span>
                        <strong class="pb-value" id="previewBudget">0원</strong>
                        <div id="previewBudgetNego" class="nego-badge round-badge-style">예산 조율 가능</div>
                    </div>
                    <div class="preview-box-item border-left">
                        <span class="pb-label">예상 진행 기간</span>
                        <strong class="pb-value" id="previewDuration">미선택</strong>
                        <div id="previewDurationNego" class="nego-badge round-badge-style">기간 조율 가능</div>
                    </div>
                    <div class="preview-box-item border-left">
                        <span class="pb-label">시작 예정일</span>
                        <strong class="pb-value" id="previewStart">미정</strong>
                        <div id="previewStartNego" class="nego-badge round-badge-style">일정 협의 가능</div>
                    </div>
                </div>

                <div class="preview-content-area">
                    <label class="label" style="font-size:18px; margin-bottom:15px;">프로젝트 상세 내용</label>
                    <div class="preview-desc-box" id="previewDescription"></div>
                </div>

                <div class="preview-meta-area">
                    <div class="meta-row">
                        <span class="meta-label">관련 기술</span>
                        <div class="meta-value" id="previewStacks">
                            <span style="color:#aaa;">선택된 기술이 없습니다.</span>
                        </div>
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
                        <span class="meta-label">수정 요청 횟수</span>
                        <div class="meta-value">
                            <span id="previewRevision" style="font-weight:600; color:#333;"></span>
                        </div>
                    </div>
                </div>

                <div id="previewFileArea" style="display:none; margin-top:30px; text-align:center; padding:20px; background:#f8f9fa; border:1px dashed #ccc; border-radius:8px;">
                    <i class="fa-solid fa-paperclip" style="color:#666; margin-right:5px;"></i>
                    첨부파일: <strong id="previewFileName" style="color:#1F7A8C; text-decoration:underline;"></strong>
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