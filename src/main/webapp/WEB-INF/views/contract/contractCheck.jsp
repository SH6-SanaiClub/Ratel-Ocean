<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
	<title>계약서 확인 및 수정</title>
	<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/contract/contract-form.css" />
	<style>
		:root {
			--bg: #f6f7fb;
			--card: #fff;
			--text: #111827;
			--muted: #6b7280;
			--line: #e5e7eb;
			--primary: #1a9aa6;
			--primary-weak: rgba(26, 154, 166, 0.12);
			--shadow: 0 20px 60px rgba(17, 24, 39, 0.08);
			--radius: 18px;
		}
		
		body {
			background: var(--bg) !important;
		}
		
		/* 카드 스타일 개선 */
		.card {
			background: var(--card) !important;
			border: 1px solid rgba(229, 231, 235, 0.75) !important;
			border-radius: 22px !important;
			box-shadow: var(--shadow) !important;
		}
		
		/* 버튼 스타일 개선 */
		.btn-primary {
			background: var(--primary) !important;
			color: #fff !important;
			box-shadow: 0 14px 30px rgba(26, 154, 166, 0.22) !important;
			border-radius: 14px !important;
		}
		
		.btn-primary:hover {
			filter: brightness(0.985) !important;
		}
		
		.btn-secondary {
			background: var(--card) !important;
			border: 1px solid var(--line) !important;
			color: var(--text) !important;
			border-radius: 14px !important;
		}
		
		.btn-secondary:hover {
			filter: brightness(0.985) !important;
		}
		
		/* 입력 필드 스타일 개선 */
		input[type="text"],
		input[type="date"],
		input[type="number"],
		textarea {
			border: 1px solid rgba(229, 231, 235, 0.85) !important;
			border-radius: 14px !important;
		}
		
		input[type="text"]:focus,
		input[type="date"]:focus,
		input[type="number"]:focus,
		textarea:focus {
			border-color: var(--primary) !important;
			box-shadow: 0 0 0 3px var(--primary-weak) !important;
		}
		
		/* 사이드바 카드 스타일 */
		.sidebar-card,
		.ai-requirements-box,
		.ai-guide-box {
			background: var(--card) !important;
			border: 1px solid rgba(229, 231, 235, 0.75) !important;
			border-radius: 22px !important;
			box-shadow: var(--shadow) !important;
		}
		
		/* 지급 방식 버튼 스타일 */
		.payment-method-btn.active {
			background: var(--primary-weak) !important;
			border-color: rgba(26, 154, 166, 0.25) !important;
			color: #0b6e76 !important;
		}
		
		/* 마일스톤 테이블 스타일 */
		.milestone-table {
			border: 1px solid rgba(229, 231, 235, 0.75) !important;
			border-radius: 14px !important;
		}
		
		.milestone-table th,
		.milestone-table td {
			border-color: rgba(229, 231, 235, 0.85) !important;
		}
	</style>
</head>
<body>
<c:set var="activeMenu" value="contracts" scope="request"/>
<c:set var="userType" value="CLIENT" scope="request"/>
<jsp:include page="/WEB-INF/views/common/headerBase.jsp" />
<div class="page-wrapper">
	<c:if test="${empty sessionScope.contractCheckAlertShown}">
		<div class="alert-box">
			<strong>AI가 자동 작성한 계약서 초안입니다.</strong><br>
			실제 계약에 앞서 반드시 내용을 검토/수정해 주세요. (오타, 누락, 조건 등)<br>
			※ 계약서 보내기 전까지 언제든 수정 가능합니다.
		</div>
		<c:set var="contractCheckAlertShown" value="true" scope="session"/>
	</c:if>
	
	<c:if test="${not empty errorMessage}">
		<div class="warning error-warning">
			${errorMessage}
		</div>
	</c:if>

	<!-- 2단 레이아웃: 왼쪽 메인 콘텐츠, 오른쪽 AI 요구사항/조언 -->
	<div class="contract-check-layout" style="display: grid !important; grid-template-columns: 1fr 380px !important; gap: 32px !important; width: 100% !important; max-width: 1400px !important; margin: 0 auto !important;">
		<!-- 왼쪽: 메인 콘텐츠 영역 -->
		<div class="main-content">
			<!-- PDF 업로드 시: PDF 표시 -->
			<c:if test="${contractInputType eq 'PDF' and not empty originContractUrl}">
				<div class="card">
					<div class="section-title">📄 업로드한 계약서 PDF</div>
					<div class="pdf-viewer-container">
						<iframe id="pdfViewer" src=""></iframe>
						<script>
							(function() {
								var pdfPath = '<c:out value="${originContractUrl}" />';
								console.log('[DEBUG] PDF 경로 (원본):', pdfPath);
								if (pdfPath && pdfPath.trim() !== '') {
									// 백슬래시를 슬래시로 변환 (Windows 경로 대응)
									pdfPath = pdfPath.replace(/\\/g, '/');
									
									// 경로를 세그먼트별로 나누어 각각 인코딩 (슬래시는 유지)
									// contracts/8/19/file.pdf -> contracts/8/19/encodeURIComponent(file.pdf)
									var pathSegments = pdfPath.split('/');
									var encodedSegments = pathSegments.map(function(segment, index) {
										// 마지막 세그먼트(파일명)만 인코딩, 나머지는 그대로
										if (index === pathSegments.length - 1) {
											return encodeURIComponent(segment);
										}
										return segment;
									});
									var encodedPath = encodedSegments.join('/');
									
									var pdfUrl = '${pageContext.request.contextPath}/client/contract/file/' + encodedPath;
									console.log('[DEBUG] PDF URL (최종):', pdfUrl);
									console.log('[DEBUG] PDF 경로 (정규화):', pdfPath);
									var iframe = document.getElementById('pdfViewer');
									if (iframe) {
										iframe.src = pdfUrl;
										iframe.onload = function() {
											console.log('[DEBUG] PDF 로드 완료');
										};
										iframe.onerror = function() {
											console.error('[ERROR] PDF 로드 실패:', pdfUrl);
										};
									} else {
										console.error('[ERROR] PDF iframe 요소를 찾을 수 없습니다.');
									}
								} else {
									console.error('[ERROR] PDF 경로가 없습니다. originContractUrl:', pdfPath);
								}
							})();
						</script>
					</div>
					<p class="pdf-hint-text">
						💡 PDF 파일을 확인하신 후, 오른쪽 AI 요구사항과 아래 계약 정보를 검토하세요.
					</p>
				</div>
			</c:if>

			<!-- 계약 정보 입력 폼 -->
			<form id="contractCheckForm" method="post" action="${pageContext.request.contextPath}/client/contract/confirm" enctype="multipart/form-data">
				<input type="hidden" name="projectId" value="${formDto.projectId}" />
				<input type="hidden" name="freelancerId" value="${formDto.freelancerId}" />
				<input type="hidden" name="originContractUrl" value="${originContractUrl}" />
				<input type="hidden" name="contractInputType" value="${contractInputType}" />
				
				<!-- 직접 작성 시에만 계약서 카드 표시 -->
				<c:if test="${contractInputType eq 'FORM'}">
				<div class="card contract-form-card" id="contractCardForPdf">
					<div class="contract-header">
						<h1>계약서</h1>
						<p>Contract Agreement</p>
					</div>

					<!-- 계약 당사자 정보 (읽기 전용) -->
					<div class="form-group">
						<h3 class="contract-clause-title">제1조 (당사자)</h3>
						<div class="party-info-grid">
							<div class="info-card">
								<div class="info-label">발주자 (갑)</div>
								<div class="info-value info-value-large"><c:out value="${client.clientName}" default="-"/></div>
								<div class="info-text-secondary">이메일: <c:out value="${client.email}" default="-"/></div>
								<div class="info-text-secondary">연락처: <c:out value="${client.phone}" default="-"/></div>
								<c:if test="${not empty client.companyName}">
									<div class="info-text-secondary">회사명: <c:out value="${client.companyName}"/></div>
								</c:if>
							</div>
							<div class="info-card">
								<div class="info-label">수주자 (을)</div>
								<div class="info-value info-value-large"><c:out value="${freelancer.name}" default="-"/></div>
								<div class="info-text-secondary">이메일: <c:out value="${freelancer.email}" default="-"/></div>
								<div class="info-text-secondary">연락처: <c:out value="${freelancer.phone}" default="-"/></div>
							</div>
						</div>
					</div>

					<!-- 계약 목적 및 범위 (직접 작성 시 입력 필드) -->
					<div class="form-group">
						<h3 class="contract-clause-title">제2조 (계약의 목적 및 범위)</h3>
						<div class="form-group">
							<label>계약 목적 <span class="required-mark">*</span></label>
							<textarea name="contractPurpose" rows="6" required class="contract-textarea"><c:out value="${formDto.contractPurpose}"/></textarea>
						</div>
						<div class="form-group">
							<label>업무 범위 <span class="required-mark">*</span></label>
							<textarea name="workScope" rows="6" required class="contract-textarea"><c:out value="${formDto.workScope}"/></textarea>
						</div>
						<div class="form-group">
							<label>결과물 정의 <span class="required-mark">*</span></label>
							<textarea name="deliverables" rows="6" required class="contract-textarea"><c:out value="${formDto.deliverables}"/></textarea>
						</div>
						<div class="form-group">
							<label>지급 조건 <span class="required-mark">*</span></label>
							<textarea name="paymentCondition" rows="5" required class="contract-textarea contract-textarea-small"><c:out value="${formDto.paymentCondition}"/></textarea>
						</div>
						<div class="form-group">
							<label>일정 관련 조건 <span class="required-mark">*</span></label>
							<textarea name="scheduleCondition" rows="5" required class="contract-textarea contract-textarea-small"><c:out value="${formDto.scheduleCondition}"/></textarea>
						</div>
						<div class="form-group">
							<label>기타 특약 사항</label>
							<textarea name="specialTerms" rows="5" class="contract-textarea contract-textarea-small"><c:out value="${formDto.specialTerms}"/></textarea>
						</div>
					</div>
				</div>
				</c:if>

				<!-- 계약 정보 입력 (PDF/직접 작성 공통) -->
				<div class="contract-info-section">
					<h3>계약 정보 입력</h3>
					
					<!-- 계약 기간 및 금액 -->
					<div class="form-group">
						<label>① 계약 생성일</label>
						<jsp:useBean id="now" class="java.util.Date" />
						<fmt:formatDate value="${now}" pattern="yyyy-MM-dd" var="currentDate" />
						<input type="text" value="<fmt:formatDate value="${now}" pattern="yyyy년 MM월 dd일"/>" readonly 
							class="readonly-input" />
						<input type="hidden" name="contractedAt" value="${currentDate}" />
					</div>
					
					<div class="form-group">
						<label>② 계약 시작일 <span class="required-mark">*</span></label>
						<input type="date" name="contractStartDate" value="${contract.contractStartDate}" required />
					</div>
					
					<div class="form-group">
						<label>③ 계약 종료일 <span class="required-mark">*</span></label>
						<input type="date" name="contractEndDate" value="${contract.contractEndDate}" required />
					</div>
					
					<div class="form-group">
						<label>④ 총 계약금액 <span class="required-mark">*</span></label>
						<input type="number" name="totalBudget" value="${contract.totalBudget}" required min="0" step="1" />
						<p class="hint-text">※ 위 금액은 부가세를 포함하지 않습니다.</p>
					</div>

					<!-- 지급 방식 -->
					<div class="form-group payment-method-group">
						<label>지급 방식 <span class="required-mark">*</span></label>
						<div class="payment-method-buttons">
							<button type="button" class="payment-method-btn <c:if test="${contract.paymentMethod eq 'FULL'}">active</c:if>" data-value="FULL">
								<span class="payment-method-icon">💰</span>
								<span class="payment-method-label">일시 지급</span>
								<span class="payment-method-desc">계약 완료 시 일괄 지급</span>
							</button>
							<button type="button" class="payment-method-btn <c:if test="${contract.paymentMethod eq 'MILESTONE'}">active</c:if>" data-value="MILESTONE">
								<span class="payment-method-icon">📊</span>
								<span class="payment-method-label">분할 지급</span>
								<span class="payment-method-desc">마일스톤별 단계적 지급</span>
							</button>
						</div>
						<input type="hidden" name="paymentMethod" id="paymentMethod" value="${contract.paymentMethod}" required />
					</div>

					<!-- 마일스톤 섹션 (paymentMethod가 MILESTONE일 때만 표시, 폼 제출 시 데이터 전송 보장을 위해 제출 전 JavaScript로 강제 표시) -->
					<div class="form-group" id="milestoneSection" 
						<c:choose>
							<c:when test="${contract.paymentMethod eq 'MILESTONE'}">style="display:block;"</c:when>
							<c:otherwise>style="display:none;"</c:otherwise>
						</c:choose>
					>
						<h3 class="milestone-section-title">제5조 (마일스톤 및 단계별 지급)</h3>
						<p class="milestone-description">
							본 계약에 따른 대금은 아래 각 호의 마일스톤 달성 시 단계적으로 지급한다.
						</p>
						<table class="milestone-table">
							<thead>
								<tr>
									<th class="width-80">단계</th>
									<th>마일스톤명</th>
									<th class="width-150">지급금액 (원)</th>
									<th>작업 내용</th>
									<th class="text-center width-80">삭제</th>
								</tr>
							</thead>
							<tbody id="milestoneTableBody">
								<c:forEach var="m" items="${contract.milestones}" varStatus="status">
									<tr>
										<td class="milestone-step-cell">
											${status.index + 1}단계
										</td>
										<td>
											<input type="text" name="milestoneName" value="${m.title}" required />
										</td>
										<td>
											<input type="number" name="milestoneAmount" value="${m.amount}" class="milestone-amount milestone-amount-input" required min="0" step="1" />
										</td>
										<td>
											<input type="text" name="milestoneDesc" value="${m.description}" />
										</td>
										<td class="text-center">
											<button type="button" class="btn btn-secondary milestone-delete-btn" onclick="removeMilestone(this)">삭제</button>
										</td>
									</tr>
								</c:forEach>
							</tbody>
						</table>
						<button type="button" class="btn btn-primary milestone-add-btn" onclick="addMilestone()">+ 마일스톤 추가</button>
						<div id="milestoneSummary" class="milestone-summary">
							<div class="milestone-summary-row milestone-summary-single-row">
								<div style="display: flex; align-items: center; gap: 8px;">
									<span class="milestone-summary-label">마일스톤 금액 합계:</span>
									<span id="milestoneTotal" class="milestone-summary-value">0원</span>
								</div>
								<div style="display: flex; align-items: center; gap: 8px;">
									<span class="milestone-summary-label">총 계약금액:</span>
									<span id="totalBudgetDisplay" class="milestone-summary-value-dark">0원</span>
								</div>
								<div style="display: flex; align-items: center; gap: 8px;">
									<span class="milestone-summary-label">차이:</span>
									<span id="amountDifference" class="milestone-summary-value-difference">0원</span>
								</div>
							</div>
						</div>
						<div id="milestoneWarning" class="warning" style="display:none; margin-top: 12px;">
							⚠️ 경고: 마일스톤 금액 합계가 총 계약금액과 일치하지 않습니다. 금액을 조정해주세요.
						</div>
					</div>
				</div>

				<!-- 버튼 영역 -->
				<div class="action-buttons-container">
					<button type="button" class="btn btn-secondary" onclick="history.back()">이전으로</button>
					<button type="submit" class="btn btn-primary btn-flex" id="sendContractBtn" 
						<c:if test="${contractInputType eq 'FORM'}">disabled</c:if>
					>계약서 보내기</button>
				</div>
			</form>
		</div>

		<!-- 오른쪽: AI 요구사항/조언 사이드바 -->
		<div class="sidebar">
			<!-- PDF 업로드 시: AI 요구사항 -->
			<c:if test="${contractInputType eq 'PDF' and not empty draft.requirements}">
				<div class="ai-requirements-box">
					<div class="section-title">
						<span>🤖</span>
						<span>AI가 생성한 프로젝트 요구사항</span>
					</div>
					<p class="ai-description-text">
						프로젝트와 계약서 내용을 분석하여 생성된 요구사항입니다. 계약서 전송 전에 검토하시기 바랍니다.
					</p>
					<ul class="ai-requirements-list">
						<c:forEach var="req" items="${draft.requirements}">
							<li><c:out value="${req}"/></li>
						</c:forEach>
					</ul>
				</div>
			</c:if>

			<!-- 직접 작성 시: AI 조언 -->
			<c:if test="${contractInputType eq 'FORM' and not empty draft.requirements}">
				<div class="ai-guide-box">
					<div class="section-title">
						<span>💡</span>
						<span>AI 조언 및 가이드</span>
					</div>
					<p class="ai-description-text">
						왼쪽 계약서 카드의 내용을 AI 조언에 맞춰 작성하시기 바랍니다. 엉뚱하거나 잘못된 내용이 기입되지 않도록 주의하세요.
					</p>
					<div class="ai-guide-content">
						<strong class="ai-guide-title">프로젝트 요구사항 참고:</strong>
						<ul class="ai-requirements-list ai-requirements-list-compact">
							<c:forEach var="req" items="${draft.requirements}">
								<li><c:out value="${req}"/></li>
							</c:forEach>
						</ul>
					</div>
				</div>
			</c:if>

			<!-- 프로젝트 정보 카드 -->
			<div class="sidebar-card">
				<div class="sidebar-card-title">
					<span>📋</span>
					<span>프로젝트 정보</span>
				</div>
				<div class="sidebar-info-item">
					<div class="sidebar-info-label">프로젝트명</div>
					<div class="sidebar-info-value"><c:out value="${project.title}" default="-"/></div>
				</div>
				<c:if test="${not empty project.budget}">
					<div class="sidebar-info-item">
						<div class="sidebar-info-label">예산</div>
						<div class="sidebar-info-value"><fmt:formatNumber value="${project.budget}" pattern="#,###"/>원</div>
					</div>
				</c:if>
				<div class="sidebar-info-item">
					<div class="sidebar-info-label">예상 기간</div>
					<div class="sidebar-info-value"><c:out value="${project.estDuration}" default="-"/></div>
				</div>
				<div class="sidebar-info-item">
					<div class="sidebar-info-label">일정</div>
					<div class="sidebar-info-value">
						<c:out value="${project.startDate}" default="-"/> ~ <c:out value="${project.deadlineDate}" default="-"/>
					</div>
				</div>
			</div>

			<!-- 프리랜서 정보 카드 -->
			<div class="sidebar-card">
				<div class="sidebar-card-title">
					<span>👤</span>
					<span>프리랜서 정보</span>
				</div>
				<div class="sidebar-info-item">
					<div class="sidebar-info-label">이름</div>
					<div class="sidebar-info-value"><c:out value="${freelancer.name}" default="-"/></div>
				</div>
				<div class="sidebar-info-item">
					<div class="sidebar-info-label">이메일</div>
					<div class="sidebar-info-value sidebar-info-value-break"><c:out value="${freelancer.email}" default="-"/></div>
				</div>
				<div class="sidebar-info-item">
					<div class="sidebar-info-label">연락처</div>
					<div class="sidebar-info-value"><c:out value="${freelancer.phone}" default="-"/></div>
				</div>
				<c:if test="${not empty freelancer.nickname}">
					<div class="sidebar-info-item">
						<div class="sidebar-info-label">닉네임</div>
						<div class="sidebar-info-value"><c:out value="${freelancer.nickname}"/></div>
					</div>
				</c:if>
			</div>
		</div>
	</div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
// 지급 방식 버튼 클릭 이벤트
$('.payment-method-btn').on('click', function() {
	var value = $(this).data('value');
	$('.payment-method-btn').removeClass('active');
	$(this).addClass('active');
	$('#paymentMethod').val(value);
	toggleMilestoneSection();
	checkMilestoneBudget();
	checkRequiredFields();
});

// 지급 방식에 따라 마일스톤 섹션 표시/숨김
function toggleMilestoneSection() {
	var method = $('#paymentMethod').val();
	if (method === 'MILESTONE') {
		$('#milestoneSection').show();
	} else {
		$('#milestoneSection').hide();
	}
}

$(document).ready(function() {
	// 초기 로드 시 paymentMethod 값 확인하여 마일스톤 섹션 표시
	var initialPaymentMethod = '<c:out value="${contract.paymentMethod}" />';
	
	// 마일스톤이 없으면 빈 행 하나 추가 (사용자가 입력할 수 있도록)
	if (initialPaymentMethod === 'MILESTONE' && $('#milestoneTableBody tr').length === 0) {
		addMilestone();
	}
	
	// 마일스톤 섹션 표시/숨김 처리 (초기값 반영)
	toggleMilestoneSection();
	
	// 초기 마일스톤 금액 표시 업데이트
	checkMilestoneBudget();
	
	// PDF 업로드 시에도 마일스톤 검증 필요
	var contractInputType = '<c:out value="${contractInputType}" />';
	checkRequiredFields();
});

// 마일스톤 추가
function addMilestone() {
	var currentRowCount = $('#milestoneTableBody tr').length;
	var newStep = currentRowCount + 1;
	var newRow = '<tr>' +
		'<td class="milestone-step-cell">' + newStep + '단계</td>' +
		'<td><input type="text" name="milestoneName" required /></td>' +
		'<td><input type="number" name="milestoneAmount" class="milestone-amount milestone-amount-input" required min="0" step="1" /></td>' +
		'<td><input type="text" name="milestoneDesc" /></td>' +
		'<td class="text-center"><button type="button" class="btn btn-secondary milestone-delete-btn" onclick="removeMilestone(this)">삭제</button></td>' +
		'</tr>';
	$('#milestoneTableBody').append(newRow);
	// 이벤트 리스너 추가
	$('#milestoneTableBody tr:last .milestone-amount').on('input', function() {
		checkMilestoneBudget();
		checkRequiredFields();
	});
	checkMilestoneBudget();
	checkRequiredFields();
}

// 마일스톤 삭제
function removeMilestone(btn) {
	$(btn).closest('tr').remove();
	// 단계 번호 재정렬
	$('#milestoneTableBody tr').each(function(index) {
		$(this).find('td:first').text((index + 1) + '단계');
	});
	checkMilestoneBudget();
	checkRequiredFields();
}

// 마일스톤 금액 합계 검증
function checkMilestoneBudget() {
	// 지급 방식이 마일스톤이 아닌 경우 검증하지 않음
	if ($('#paymentMethod').val() !== 'MILESTONE') {
		$('#milestoneWarning').hide();
		$('#milestoneSummary').hide();
		return true; // 검증 통과
	}
	
	$('#milestoneSummary').show();
	
	var total = 0;
	$('.milestone-amount').each(function() {
		var val = parseFloat($(this).val()) || 0;
		total += val;
	});
	var budget = parseFloat($('input[name="totalBudget"]').val()) || 0;
	var difference = total - budget;
	
	// 금액 표시 업데이트
	$('#milestoneTotal').text(total.toLocaleString('ko-KR') + '원');
	$('#totalBudgetDisplay').text(budget.toLocaleString('ko-KR') + '원');
	
	// 차이 표시
	var differenceText;
	if (difference > 0) {
		differenceText = '+' + Math.abs(difference).toLocaleString('ko-KR') + '원';
		$('#amountDifference').text(differenceText).css('color', '#dc3545');
	} else if (difference < 0) {
		differenceText = '-' + Math.abs(difference).toLocaleString('ko-KR') + '원';
		$('#amountDifference').text(differenceText).css('color', '#dc3545');
	} else {
		differenceText = '0원';
		$('#amountDifference').text(differenceText).css('color', '#28a745');
	}
	
	// 마일스톤 금액 합계가 총 계약금액과 일치하지 않으면 경고 표시 및 버튼 비활성화
	if (Math.abs(difference) > 0.01) { // 부동소수점 오차 고려
		$('#milestoneWarning').show();
		return false; // 검증 실패
	} else {
		$('#milestoneWarning').hide();
		return true; // 검증 통과
	}
}

// 필수 필드 검증
function checkRequiredFields() {
	var contractInputType = '<c:out value="${contractInputType}" />';
	
	// 마일스톤 모드일 경우 금액 일치 여부 먼저 확인
	var milestoneValid = true;
	if ($('#paymentMethod').val() === 'MILESTONE') {
		milestoneValid = checkMilestoneBudget();
		if (!milestoneValid) {
			$('#sendContractBtn').prop('disabled', true);
			return;
		}
	}
	
	if (contractInputType === 'PDF') {
		// PDF 업로드 시에는 마일스톤 검증 통과 시 활성화
		if (milestoneValid) {
			$('#sendContractBtn').prop('disabled', false);
		}
		return;
	}
	
	var required = ['contractStartDate', 'contractEndDate', 'totalBudget'];
	var allFilled = true;
	required.forEach(function(name) {
		var el = $('[name="' + name + '"]');
		if (!el.val()) allFilled = false;
	});
	
	// 직접 작성 시 추가 필드 검증
	if (contractInputType === 'FORM') {
		var formRequired = ['contractPurpose', 'workScope', 'deliverables', 'paymentCondition', 'scheduleCondition'];
		formRequired.forEach(function(name) {
			var el = $('[name="' + name + '"]');
			if (!el.val()) allFilled = false;
		});
	}
	
	// 마일스톤 모드일 경우 마일스톤 검증
	if ($('#paymentMethod').val() === 'MILESTONE') {
		var hasMilestones = $('input[name="milestoneName"]').length > 0;
		if (!hasMilestones) {
			allFilled = false;
		}
	}
	
	if (allFilled && milestoneValid) {
		$('#sendContractBtn').prop('disabled', false);
	} else {
		$('#sendContractBtn').prop('disabled', true);
	}
}

// textarea 자동 높이 조절 함수
function autoResizeTextarea(textarea) {
	if (!textarea) return;
	textarea.style.height = 'auto';
	var scrollHeight = textarea.scrollHeight;
	if (scrollHeight > 0) {
		var minHeight = parseInt(textarea.style.minHeight) || 120;
		textarea.style.height = Math.max(minHeight, scrollHeight) + 'px';
	}
}

// 페이지 로드 시 모든 textarea 높이 조절
$(document).ready(function() {
	$('textarea').each(function() {
		autoResizeTextarea(this);
	});
});

$(document).on('input change', '.milestone-amount, input[name="totalBudget"], input[name="contractStartDate"], input[name="contractEndDate"], textarea[name="contractPurpose"], textarea[name="workScope"], textarea[name="deliverables"], textarea[name="paymentCondition"], textarea[name="scheduleCondition"]', function() {
	// textarea인 경우 자동 높이 조절
	if (this.tagName === 'TEXTAREA') {
		autoResizeTextarea(this);
	}
	// 마일스톤 금액이나 총 계약금액이 변경되면 검증
	if ($(this).hasClass('milestone-amount') || $(this).attr('name') === 'totalBudget') {
		checkMilestoneBudget();
	}
	checkRequiredFields();
});

$('#contractCheckForm').on('submit', function(e) {
	// 마일스톤 섹션이 숨겨져 있으면 강제로 표시 (폼 제출 시 데이터 전송 보장)
	// display:none인 요소의 input 값이 일부 브라우저에서 전송되지 않을 수 있으므로 제출 전에 반드시 표시해야 함
	var paymentMethod = $('#paymentMethod').val();
	if (paymentMethod === 'MILESTONE') {
		$('#milestoneSection').show();
		
		// 마일스톤 데이터 검증
		var milestoneNames = $('input[name="milestoneName"]').map(function() { 
			return $(this).val(); 
		}).get();
		
		// 마일스톤이 없으면 경고
		if (milestoneNames.length === 0 || milestoneNames.every(function(name) { 
			return !name || name.trim() === ''; 
		})) {
			alert('마일스톤 지급 방식을 선택하셨습니다. 최소 1개 이상의 마일스톤을 입력해주세요.');
			e.preventDefault();
			return;
		}
	}
	
	if (!confirm('계약서를 프리랜서에게 전달하시겠습니까?')) {
		e.preventDefault();
		return;
	}
	
	// FORM 시나리오인 경우 서버에서 PDF 생성하므로 단순히 폼 제출
	var contractInputType = '<c:out value="${contractInputType}" />';
	if (contractInputType === 'FORM') {
		var submitBtn = document.getElementById('sendContractBtn');
		submitBtn.disabled = true;
		submitBtn.textContent = '계약서 전송 중...';
	}
});
</script>
</body>
</html>
