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
    <form id="projectForm" action="${pageContext.request.contextPath}/project/create" method="post"
          enctype="multipart/form-data">

        <div class="step-section active" id="step1">
            <div class="step-header-group"><span class="step-desc-small">진행하고자 하는 프로젝트의 기본 정보를 입력해주세요.</span>
                <h2 class="step-title">프로젝트 개요</h2></div>
            <div class="form-group-styled"><label class="label">프로젝트 제목 <span class="required">*</span></label><input
                    type="text" name="title" id="title" class="form-control" placeholder="예) 배달 플랫폼 관리자 페이지 개발"
                    required></div>
            <div class="form-group-styled"><label class="label">프로젝트 상세 내용 <span
                    class="required">*</span></label><textarea name="description" id="description" class="form-control"
                                                               rows="20" required placeholder="내용을 입력해주세요."></textarea>
            </div>
            <div class="form-group-styled"><label class="label">기획서 등 관련 파일</label>
                <div class="file-drop-zone compact" onclick="document.getElementById('fileInput').click()">
                    <div id="fileDisplayDefault" class="file-content-center"><i
                            class="fa-solid fa-cloud-arrow-up file-icon-mid"></i>
                        <p class="file-text-small">클릭하여 파일 업로드 (최대 5GB)</p></div>
                    <div id="fileDisplaySelected" style="display:none;" class="file-content-center"><i
                            class="fa-solid fa-file-lines file-icon-selected"></i>
                        <p id="fileNameDisplay" class="file-name-text"></p>
                        <p class="file-change-text">클릭하여 파일 변경</p></div>
                </div>
                <input type="file" id="fileInput" name="planFile" style="display:none;"
                       onchange="handleFileSelect(this)"><input type="hidden" name="planUrl" id="planUrl"><input
                        type="hidden" name="fileSize" id="fileSize"></div>
            <div class="btn-area right">
                <button type="button" class="btn btn-next" onclick="nextStep(2)">다음 단계</button>
            </div>
        </div>

        <div class="step-section" id="step2">
            <div class="step-header-group"><span class="step-desc-small">어떤 전문가가 필요하신가요?</span>
                <h2 class="step-title">개발 영역 및 기술 스택</h2></div>
            <div class="form-group-styled"><label class="label">개발 영역 (분야) <span class="required">*</span></label>
                <div class="selection-grid-4"><c:forEach var="pos" items="${positionList}"><label class="selection-card"
                                                                                                  onclick="selectCard(this)"><input
                        type="radio" name="positionId" value="${pos.stackId}" required>
                    <div class="mini-card-icon"><c:choose><c:when test="${pos.stackName eq '게임/그래픽'}"><i
                            class="fa-solid fa-gamepad"></i></c:when><c:when test="${pos.stackName eq '데이터베이스'}"><i
                            class="fa-solid fa-database"></i></c:when><c:when test="${pos.stackName eq '모바일앱'}"><i
                            class="fa-solid fa-mobile-screen"></i></c:when><c:when test="${pos.stackName eq '웹'}"><i
                            class="fa-solid fa-globe"></i></c:when><c:when test="${pos.stackName eq '임베디드/하드웨어'}"><i
                            class="fa-solid fa-microchip"></i></c:when><c:when
                            test="${fn:contains(pos.stackName, 'AI')}"><i class="fa-solid fa-brain"></i></c:when><c:when
                            test="${fn:contains(pos.stackName, 'DevOps')}"><i
                            class="fa-solid fa-server"></i></c:when><c:otherwise><i
                            class="fa-solid fa-code"></i></c:otherwise></c:choose></div>
                    <strong>${pos.stackName}</strong></label></c:forEach></div>
            </div>
            <div class="form-group-styled"><label class="label">관련 기술 스택 <span class="required">*</span></label>
                <div id="stackDisplayBox" class="stack-display-box"><span
                        class="placeholder-text">아래 목록에서 선택하거나 검색해주세요.</span></div>
                <input type="text" id="stackSearchInput" class="form-control" placeholder="기술 스택 검색 (예: Java, React)">
                <div class="unknown-check-wrap mt-10"><label class="check-option-small"><input type="checkbox"
                                                                                               name="stackIdsUnknown"
                                                                                               id="stackIdsUnknown"
                                                                                               onchange="toggleStackUnknown(this)"><span>어떤 기술이 필요한지 잘 모르겠어요 (전문가와 협의)</span></label>
                </div>
                <div id="selectedStackHidden" style="display:none;"></div>
                <div class="stack-list mt-2"><c:forEach var="skill" items="${skillList}">
                    <div class="stack-item"
                         onclick="addStack('${skill.stackId}', '${skill.stackName}', this)">${skill.stackName}</div>
                    <input type="checkbox" id="chk_stack_${skill.stackId}" style="display:none;"></c:forEach></div>
            </div>
            <div class="form-group-styled row-half">
                <div class="col-half"><label class="label">요구 숙련도 <span class="required">*</span></label><select
                        name="minLevel" class="form-control">
                    <option value="1">Lv.1 입문</option>
                    <option value="2">Lv.2 초급</option>
                    <option value="3" selected>Lv.3 중급</option>
                    <option value="4">Lv.4 중급+</option>
                    <option value="5">Lv.5 고급</option>
                </select></div>
                <div class="col-half"><label class="label">필요 경력</label>
                    <div class="input-with-unit"><input type="number" name="minYear" id="minYearInput"
                                                        class="form-control" placeholder="0"><span class="unit-text">년 (이상)</span>
                    </div>
                    <label class="check-option-small"><input type="checkbox" id="minYearUnknown"
                                                             onchange="toggleYear(this)"> <span>경력 무관</span></label>
                </div>
            </div>
            <div class="btn-area between">
                <button type="button" class="btn btn-prev" onclick="prevStep(1)">이전</button>
                <button type="button" class="btn btn-next" onclick="nextStep(3)">다음 단계</button>
            </div>
        </div>

        <div class="step-section" id="step3">
            <div class="step-header-group"><span class="step-desc-small">예산과 일정을 설정해주세요.</span>
                <h2 class="step-title">예산 및 일정</h2></div>
            <div class="form-group-styled"><label class="label">지출 가능 예산 <span class="required">*</span></label>
                <div class="input-with-unit"><span class="currency">₩</span><input type="text" name="budget"
                                                                                   id="budgetInput"
                                                                                   class="form-control has-currency"
                                                                                   placeholder="0" required><span
                        class="unit-text">원</span></div>
                <label class="check-option mt-2"><input type="checkbox" name="budgetNegotiable" value="true"><span>입력한 예산에서 조율이 가능합니다.</span></label>
            </div>
            <div class="form-group-styled"><label class="label">예상 시작일 <span class="required">*</span></label>
                <div class="start-date-group"><label class="radio-row"><input type="radio" name="startType" value="DATE"
                                                                              onchange="toggleStartType(this)">
                    <div class="date-input-wrapper"><input type="date" name="startDate" id="startDate"
                                                           class="form-control" disabled></div>
                </label><label class="check-option indent"><input type="checkbox" name="startNegotiable"
                                                                  value="true"><span>프로젝트 착수 일자의 협의가 가능합니다.</span></label><label
                        class="radio-row"><input type="radio" name="startType" value="ASAP" checked
                                                 onchange="toggleStartType(this)"><span>계약 체결 이후, 즉시 시작하길 희망합니다.</span></label>
                </div>
            </div>
            <div class="form-group-styled"><label class="label">예상 진행 기간 <span class="required">*</span></label><select
                    name="estDuration" id="durationSelect" class="form-control" required>
                <option value="" disabled selected>예상 기간을 선택해주세요</option>
                <option value="1개월 이하">1개월 이하</option>
                <option value="1~3개월">1~3개월</option>
                <option value="3~6개월">3~6개월</option>
                <option value="6개월 이상">6개월 이상</option>
            </select><label class="check-option mt-2"><input type="checkbox" name="durationNegotiable"
                                                             value="true"><span>기간 조율 가능</span></label></div>
            <div class="btn-area between">
                <button type="button" class="btn btn-prev" onclick="prevStep(2)">이전</button>
                <button type="button" class="btn btn-next" onclick="nextStep(4)">다음 단계</button>
            </div>
        </div>

        <div class="step-section" id="step4">
            <div class="step-header-group"><span class="step-desc-small">프로젝트 진행 방식을 선택해주세요.</span>
                <h2 class="step-title">계약 및 소통</h2></div>
            <div class="form-group-styled"><label class="label">미팅 방식 <span class="required">*</span></label>
                <div class="selection-grid-2"><label class="selection-card selected" onclick="selectCard(this)"><input
                        type="radio" name="communicateMethod" value="ONLINE" checked><i
                        class="fa-solid fa-video"></i><strong>온라인 미팅</strong><span
                        class="card-text-sub">화상회의, 메신저 등</span></label><label class="selection-card"
                                                                               onclick="selectCard(this)"><input
                        type="radio" name="communicateMethod" value="OFFLINE"><i
                        class="fa-solid fa-people-arrows"></i><strong>오프라인 미팅</strong><span class="card-text-sub">대면 미팅 선호</span></label>
                </div>
            </div>
            <div class="form-group-styled"><label class="label">대금 지급 방식 <span class="required">*</span></label>
                <div class="selection-grid-2"><label class="selection-card selected" onclick="selectCard(this)"><input
                        type="radio" name="paymentMethod" value="LUMP_SUM" checked><i
                        class="fa-solid fa-coins"></i><strong>일괄 지급</strong><span
                        class="card-text-sub">프로젝트 종료 후 전액</span></label><label class="selection-card"
                                                                                onclick="selectCard(this)"><input
                        type="radio" name="paymentMethod" value="INSTALLMENT"><i
                        class="fa-solid fa-chart-pie"></i><strong>분할 지급</strong><span
                        class="card-text-sub">단계별로 나누어 지급</span></label></div>
            </div>
            <hr style="margin: 30px 0; border:0; border-top:1px solid #eee;">
            <div class="form-group-styled"><label class="label">무상 수정 횟수 <span class="required">*</span></label>
                <div class="input-with-unit" style="max-width: 150px;"><input type="number" name="maxRevisionCount"
                                                                              id="maxRevisionCount" class="form-control"
                                                                              value="0" min="0" max="3"><span
                        class="unit-text">회</span></div>
                <p class="input-desc" style="margin-top:5px; color:#d32f2f;">최대 3회까지 설정 가능합니다.</p></div>
            <div class="form-group-styled"><label class="label">수정 관련 상세 규정 (선택)</label><textarea name="changePolicy"
                                                                                                  class="form-control"
                                                                                                  rows="3"
                                                                                                  placeholder="예) 텍스트/이미지 단순 교체는 무제한입니다."></textarea>
            </div>
            <div class="btn-area between">
                <button type="button" class="btn btn-prev" onclick="prevStep(3)">이전</button>
                <button type="button" class="btn btn-next" onclick="nextStep(5)">미리보기</button>
            </div>
        </div>

        <div class="step-section" id="step5">
            <div class="detail-wrap">
                <div class="preview-card">
                    <div class="preview-title-text" id="previewTitle"></div>

                    <div class="preview-meta">
                        <span id="previewRegDate"></span>
                        <span>조회수 0</span>
                        <span>지원자 0명</span>
                        <span style="color:#5c3cce;">모집 대기</span>
                    </div>

                    <div class="preview-section">
                        <h3>프로젝트 설명</h3>
                        <div class="preview-desc" id="previewDescription"></div>
                    </div>

                    <div class="preview-section">
                        <h3>프로젝트 정보</h3>
                        <div class="preview-info-grid">
                            <div class="preview-info-box">
                                <div class="preview-info-label">예산</div>
                                <div id="previewBudget"></div>
                            </div>
                            <div class="preview-info-box">
                                <div class="preview-info-label">예상 기간</div>
                                <div id="previewDuration"></div>
                            </div>
                            <div class="preview-info-box">
                                <div class="preview-info-label">시작 예정일</div>
                                <div id="previewStart"></div>
                            </div>
                            <div class="preview-info-box">
                                <div class="preview-info-label">마감일 (예상)</div>
                                <div id="previewDeadline"></div>
                            </div>
                            <div class="preview-info-box">
                                <div class="preview-info-label">커뮤니케이션</div>
                                <div id="previewComm"></div>
                            </div>
                            <div class="preview-info-box">
                                <div class="preview-info-label">결제 방식</div>
                                <div id="previewPay"></div>
                            </div>
                            <div class="preview-info-box full">
                                <div class="preview-info-label">개발 분야 & 기술 스택</div>
                                <div id="previewStacks"></div>
                            </div>
                            <div class="preview-info-box">
                                <div class="preview-info-label">요구 레벨 / 경력</div>
                                <div id="previewLevelExp"></div>
                            </div>
                            <div class="preview-info-box">
                                <div class="preview-info-label">최대 수정 횟수</div>
                                <div id="previewRevision"></div>
                            </div>
                            <div class="preview-info-box full" id="previewPolicyContainer" style="display:none;">
                                <div class="preview-info-label">변경/수정 정책</div>
                                <div id="previewChangePolicy"></div>
                            </div>
                            <div class="preview-info-box full" id="previewFileContainer" style="display:none;">
                                <div class="preview-info-label">첨부 파일</div>
                                <div id="previewFileName" style="color:#5c3cce; text-decoration:underline;"></div>
                            </div>
                        </div>
                    </div>

                    <div class="preview-actions">
                        <button type="button" class="btn-preview-back" onclick="prevStep(4)">
                            수정하기
                        </button>
                        <button type="submit" class="btn-preview-submit">
                            등록 완료
                        </button>
                    </div>
                </div>
            </div>

            <input type="hidden" name="isPublic" value="true">
            <input type="hidden" name="projectStatus" value="READY">
        </div>
    </form>
</div>
<script src="${pageContext.request.contextPath}/resources/js/project/create.js"></script>
</body>
</html>