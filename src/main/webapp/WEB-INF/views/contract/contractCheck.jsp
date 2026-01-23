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
		body {
			background: var(--off-white);
			font-family: 'Noto Sans KR', sans-serif;
			margin: 0;
			padding: 0;
		}
		.page-wrapper {
			max-width: 1400px;
			margin: 0 auto;
			padding: 40px 20px;
		}
		.contract-check-layout {
			display: grid;
			grid-template-columns: 1fr 420px;
			gap: 32px;
			align-items: start;
		}
		.main-content {
			display: flex;
			flex-direction: column;
			gap: 24px;
		}
		.sidebar {
			position: sticky;
			top: 20px;
			display: flex;
			flex-direction: column;
			gap: 20px;
		}
		.card {
			background: var(--white);
			border-radius: 16px;
			box-shadow: 0 4px 12px rgba(0,0,0,0.08);
			padding: 28px;
			margin-bottom: 0;
		}
		.section-title {
			font-size: 22px;
			font-weight: 700;
			color: var(--dark);
			margin: 0 0 20px;
			padding-bottom: 12px;
			border-bottom: 2px solid var(--deep-teal);
		}
		.pdf-viewer-container {
			border: 2px solid #e9ecef;
			border-radius: 12px;
			overflow: hidden;
			background: #fff;
			margin-bottom: 20px;
			min-height: 700px;
		}
		.pdf-viewer-container iframe {
			width: 100%;
			height: 700px;
			border: none;
			display: block;
		}
		.ai-requirements-box {
			background: linear-gradient(135deg, #f0f7ff 0%, #e8f4fd 100%);
			border: 2px solid var(--deep-teal);
			border-radius: 16px;
			padding: 24px;
			box-shadow: 0 4px 12px rgba(31, 122, 140, 0.15);
		}
		.ai-requirements-box .section-title {
			color: var(--deep-teal);
			border-bottom-color: var(--deep-teal);
			display: flex;
			align-items: center;
			gap: 8px;
			font-size: 20px;
			margin-bottom: 16px;
		}
		.ai-requirements-list {
			list-style: none;
			padding: 0;
			margin: 0;
		}
		.ai-requirements-list li {
			padding: 14px 18px;
			margin-bottom: 10px;
			background: #fff;
			border-radius: 10px;
			border-left: 4px solid var(--deep-teal);
			box-shadow: 0 2px 6px rgba(0,0,0,0.08);
			line-height: 1.7;
			color: #333;
			transition: transform 0.2s, box-shadow 0.2s;
			font-size: 14px;
		}
		.ai-requirements-list li:hover {
			transform: translateX(4px);
			box-shadow: 0 4px 8px rgba(0,0,0,0.12);
		}
		.ai-requirements-list li:last-child {
			margin-bottom: 0;
		}
		.contract-form-card {
			background: #fff;
			border: 2px solid var(--deep-teal);
			border-radius: 16px;
			padding: 32px;
		}
		.contract-header {
			text-align: center;
			margin-bottom: 32px;
			padding-bottom: 24px;
			border-bottom: 2px solid var(--deep-teal);
		}
		.contract-header h1 {
			font-size: 32px;
			font-weight: 700;
			color: var(--dark);
			margin: 0 0 8px;
		}
		.contract-header p {
			color: var(--gray);
			font-size: 14px;
			margin: 0;
		}
		.form-group {
			margin-bottom: 24px;
		}
		.form-group label {
			display: block;
			font-weight: 600;
			color: #444;
			margin-bottom: 8px;
			font-size: 15px;
		}
		.form-group input[type="date"],
		.form-group input[type="number"],
		.form-group select,
		.form-group textarea {
			width: 100%;
			padding: 12px;
			border: 2px solid #e9ecef;
			border-radius: 8px;
			font-size: 15px;
			transition: border-color 0.2s;
			font-family: inherit;
			min-height: 120px;
			line-height: 1.6;
		}
		.form-group input:focus,
		.form-group select:focus,
		.form-group textarea:focus {
			outline: none;
			border-color: var(--deep-teal);
		}
		.info-card {
			background: #f8f9fa;
			border-radius: 12px;
			padding: 20px;
			margin-bottom: 16px;
		}
		.info-card .info-label {
			font-size: 13px;
			color: var(--gray);
			margin-bottom: 6px;
			font-weight: 500;
		}
		.info-card .info-value {
			font-size: 16px;
			font-weight: 600;
			color: var(--dark);
		}
		.milestone-table {
			width: 100%;
			border-collapse: collapse;
			margin-top: 16px;
		}
		.milestone-table th,
		.milestone-table td {
			border: 1px solid #e9ecef;
			padding: 12px;
			text-align: left;
		}
		.milestone-table th {
			background: #f0f7ff;
			font-weight: 600;
			color: var(--dark);
		}
		.milestone-table td {
			background: #fff;
		}
		.milestone-table input {
			width: 100%;
			padding: 8px;
			border: 1px solid #ddd;
			border-radius: 6px;
			font-size: 14px;
		}
		.btn {
			padding: 12px 24px;
			border-radius: 8px;
			border: none;
			font-size: 16px;
			font-weight: 600;
			cursor: pointer;
			transition: all 0.2s;
		}
		.btn-primary {
			background: var(--deep-teal);
			color: #fff;
		}
		.btn-primary:hover {
			background: #1a6b7a;
			transform: translateY(-1px);
			box-shadow: 0 4px 8px rgba(0,0,0,0.15);
		}
		.btn-secondary {
			background: #e9ecef;
			color: #495057;
		}
		.btn-secondary:hover {
			background: #dee2e6;
		}
		.btn:disabled {
			background: #ced4da;
			color: #6c757d;
			cursor: not-allowed;
			transform: none;
		}
		.warning {
			background: #fff3cd;
			border: 1px solid #ffc107;
			border-radius: 8px;
			padding: 12px;
			margin-top: 12px;
			color: #856404;
		}
		.alert-box {
			background: #fffbe6;
			border: 1px solid #ffe58f;
			border-radius: 12px;
			padding: 18px 24px;
			margin-bottom: 24px;
			color: #ad8b00;
		}
		.ai-guide-box {
			background: linear-gradient(135deg, #fffbe6 0%, #fff8e1 100%);
			border: 2px solid #ffc107;
			border-radius: 16px;
			padding: 24px;
			box-shadow: 0 4px 12px rgba(255, 193, 7, 0.15);
		}
		.ai-guide-box .section-title {
			color: #ad8b00;
			border-bottom-color: #ffc107;
			font-size: 20px;
			margin-bottom: 16px;
		}
		.sidebar-card {
			background: #fff;
			border-radius: 16px;
			padding: 24px;
			box-shadow: 0 2px 8px rgba(0,0,0,0.06);
			border: 1px solid #e9ecef;
		}
		.sidebar-card-title {
			font-size: 18px;
			font-weight: 700;
			color: var(--dark);
			margin: 0 0 16px;
			padding-bottom: 12px;
			border-bottom: 2px solid #e9ecef;
			display: flex;
			align-items: center;
			gap: 8px;
		}
		.sidebar-info-item {
			padding: 12px 0;
			border-bottom: 1px solid #f0f0f0;
		}
		.sidebar-info-item:last-child {
			border-bottom: none;
		}
		.sidebar-info-label {
			font-size: 12px;
			color: #6c757d;
			margin-bottom: 4px;
			font-weight: 500;
			text-transform: uppercase;
			letter-spacing: 0.5px;
		}
		.sidebar-info-value {
			font-size: 15px;
			font-weight: 600;
			color: var(--dark);
			line-height: 1.5;
		}
		.contract-info-section {
			background: #f8f9fa;
			border-radius: 12px;
			padding: 24px;
			margin-top: 24px;
		}
		.contract-info-section h3 {
			font-size: 18px;
			font-weight: 600;
			color: var(--dark);
			margin: 0 0 16px;
			padding-bottom: 12px;
			border-bottom: 1px solid #e9ecef;
		}
		@media (max-width: 1200px) {
			.contract-check-layout {
				grid-template-columns: 1fr;
			}
			.sidebar {
				position: static;
			}
		}
	</style>
</head>
<body>
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
		<div class="warning" style="background: #f8d7da; border-color: #dc3545; color: #721c24;">
			${errorMessage}
		</div>
	</c:if>

	<!-- 2단 레이아웃: 왼쪽 메인 콘텐츠, 오른쪽 AI 요구사항/조언 -->
	<div class="contract-check-layout">
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
					<p style="color: #666; font-size: 14px; margin-top: 12px;">
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
						<h3 style="font-size: 18px; font-weight: 600; color: var(--dark); margin-bottom: 16px; padding-bottom: 8px; border-bottom: 1px solid #e9ecef;">제1조 (당사자)</h3>
						<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
							<div class="info-card">
								<div class="info-label">발주자 (갑)</div>
								<div class="info-value" style="font-size: 18px; margin-bottom: 8px;"><c:out value="${client.clientName}" default="-"/></div>
								<div style="font-size: 14px; color: #666;">이메일: <c:out value="${client.email}" default="-"/></div>
								<div style="font-size: 14px; color: #666;">연락처: <c:out value="${client.phone}" default="-"/></div>
								<c:if test="${not empty client.companyName}">
									<div style="font-size: 14px; color: #666;">회사명: <c:out value="${client.companyName}"/></div>
								</c:if>
							</div>
							<div class="info-card">
								<div class="info-label">수주자 (을)</div>
								<div class="info-value" style="font-size: 18px; margin-bottom: 8px;"><c:out value="${freelancer.name}" default="-"/></div>
								<div style="font-size: 14px; color: #666;">이메일: <c:out value="${freelancer.email}" default="-"/></div>
								<div style="font-size: 14px; color: #666;">연락처: <c:out value="${freelancer.phone}" default="-"/></div>
							</div>
						</div>
					</div>

					<!-- 계약 목적 및 범위 (직접 작성 시 입력 필드) -->
					<div class="form-group">
						<h3 style="font-size: 18px; font-weight: 600; color: var(--dark); margin-bottom: 16px; padding-bottom: 8px; border-bottom: 1px solid #e9ecef;">제2조 (계약의 목적 및 범위)</h3>
						<div class="form-group">
							<label>계약 목적 <span style="color: #dc3545;">*</span></label>
							<textarea name="contractPurpose" rows="6" required style="width: 100%; padding: 12px; border: 2px solid #e9ecef; border-radius: 8px; font-size: 15px; resize: vertical; min-height: 150px; line-height: 1.6;"><c:out value="${formDto.contractPurpose}"/></textarea>
						</div>
						<div class="form-group">
							<label>업무 범위 <span style="color: #dc3545;">*</span></label>
							<textarea name="workScope" rows="6" required style="width: 100%; padding: 12px; border: 2px solid #e9ecef; border-radius: 8px; font-size: 15px; resize: vertical; min-height: 150px; line-height: 1.6;"><c:out value="${formDto.workScope}"/></textarea>
						</div>
						<div class="form-group">
							<label>결과물 정의 <span style="color: #dc3545;">*</span></label>
							<textarea name="deliverables" rows="6" required style="width: 100%; padding: 12px; border: 2px solid #e9ecef; border-radius: 8px; font-size: 15px; resize: vertical; min-height: 150px; line-height: 1.6;"><c:out value="${formDto.deliverables}"/></textarea>
						</div>
						<div class="form-group">
							<label>지급 조건 <span style="color: #dc3545;">*</span></label>
							<textarea name="paymentCondition" rows="5" required style="width: 100%; padding: 12px; border: 2px solid #e9ecef; border-radius: 8px; font-size: 15px; resize: vertical; min-height: 120px; line-height: 1.6;"><c:out value="${formDto.paymentCondition}"/></textarea>
						</div>
						<div class="form-group">
							<label>일정 관련 조건 <span style="color: #dc3545;">*</span></label>
							<textarea name="scheduleCondition" rows="5" required style="width: 100%; padding: 12px; border: 2px solid #e9ecef; border-radius: 8px; font-size: 15px; resize: vertical; min-height: 120px; line-height: 1.6;"><c:out value="${formDto.scheduleCondition}"/></textarea>
						</div>
						<div class="form-group">
							<label>기타 특약 사항</label>
							<textarea name="specialTerms" rows="5" style="width: 100%; padding: 12px; border: 2px solid #e9ecef; border-radius: 8px; font-size: 15px; resize: vertical; min-height: 120px; line-height: 1.6;"><c:out value="${formDto.specialTerms}"/></textarea>
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
							style="background: #f8f9fa; cursor: not-allowed;" />
						<input type="hidden" name="contractedAt" value="${currentDate}" />
					</div>
					
					<div class="form-group">
						<label>② 계약 시작일 <span style="color: #dc3545;">*</span></label>
						<input type="date" name="contractStartDate" value="${contract.contractStartDate}" required />
					</div>
					
					<div class="form-group">
						<label>③ 계약 종료일 <span style="color: #dc3545;">*</span></label>
						<input type="date" name="contractEndDate" value="${contract.contractEndDate}" required />
					</div>
					
					<div class="form-group">
						<label>④ 총 계약금액 <span style="color: #dc3545;">*</span></label>
						<input type="number" name="totalBudget" value="${contract.totalBudget}" required min="0" step="1" />
						<p style="margin-top: 6px; color: #666; font-size: 13px;">※ 위 금액은 부가세를 포함하지 않습니다.</p>
					</div>

					<!-- 지급 방식 -->
					<div class="form-group">
						<label>지급 방식 <span style="color: #dc3545;">*</span></label>
						<select name="paymentMethod" id="paymentMethod" required>
							<option value="FULL" <c:if test="${contract.paymentMethod eq 'FULL'}">selected</c:if>>일시 지급 (계약 완료 시 일괄 지급)</option>
							<option value="MILESTONE" <c:if test="${contract.paymentMethod eq 'MILESTONE'}">selected</c:if>>분할 지급 (마일스톤별 단계적 지급)</option>
						</select>
					</div>

					<!-- 마일스톤 섹션 (paymentMethod가 MILESTONE일 때만 표시) -->
					<div class="form-group" id="milestoneSection" style="display:none;">
						<h3 style="font-size: 18px; font-weight: 600; color: var(--dark); margin-bottom: 16px; padding-bottom: 8px; border-bottom: 1px solid #e9ecef;">제5조 (마일스톤 및 단계별 지급)</h3>
						<p style="color: #666; margin-bottom: 16px; line-height: 1.6;">
							본 계약에 따른 대금은 아래 각 호의 마일스톤 달성 시 단계적으로 지급한다.
						</p>
						<table class="milestone-table">
							<thead>
								<tr>
									<th style="width: 80px;">단계</th>
									<th>마일스톤명</th>
									<th style="width: 150px; text-align: right;">지급금액 (원)</th>
									<th>작업 내용</th>
									<th style="width: 80px; text-align: center;">삭제</th>
								</tr>
							</thead>
							<tbody id="milestoneTableBody">
								<c:forEach var="m" items="${contract.milestones}" varStatus="status">
									<tr>
										<td style="text-align: center; font-weight: 600; background: #f8f9fa;">
											${status.index + 1}단계
										</td>
										<td>
											<input type="text" name="milestoneName" value="${m.title}" required />
										</td>
										<td>
											<input type="number" name="milestoneAmount" value="${m.amount}" class="milestone-amount" required min="0" step="1" style="text-align: right;" />
										</td>
										<td>
											<input type="text" name="milestoneDesc" value="${m.description}" />
										</td>
										<td style="text-align: center;">
											<button type="button" class="btn btn-secondary" onclick="removeMilestone(this)" style="padding: 6px 12px; font-size: 12px;">삭제</button>
										</td>
									</tr>
								</c:forEach>
							</tbody>
						</table>
						<button type="button" class="btn btn-primary" onclick="addMilestone()" style="margin-top: 12px;">+ 마일스톤 추가</button>
						<div id="milestoneSummary" style="margin-top: 16px; padding: 16px; background: #f8f9fa; border-radius: 8px; border: 1px solid #e9ecef;">
							<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
								<span style="font-weight: 600; color: #495057;">마일스톤 금액 합계:</span>
								<span id="milestoneTotal" style="font-size: 18px; font-weight: 700; color: var(--deep-teal);">0원</span>
							</div>
							<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
								<span style="font-weight: 600; color: #495057;">총 계약금액:</span>
								<span id="totalBudgetDisplay" style="font-size: 18px; font-weight: 700; color: var(--dark);">0원</span>
							</div>
							<div style="display: flex; justify-content: space-between; align-items: center; padding-top: 12px; border-top: 2px solid #dee2e6;">
								<span style="font-weight: 600; color: #495057;">차이:</span>
								<span id="amountDifference" style="font-size: 18px; font-weight: 700;">0원</span>
							</div>
						</div>
						<div id="milestoneWarning" class="warning" style="display:none; margin-top: 12px;">
							⚠️ 경고: 마일스톤 금액 합계가 총 계약금액과 일치하지 않습니다. 금액을 조정해주세요.
						</div>
					</div>
				</div>

				<!-- 버튼 영역 -->
				<div style="display: flex; gap: 16px; margin-top: 24px;">
					<button type="button" class="btn btn-secondary" onclick="history.back()">이전으로</button>
					<button type="submit" class="btn btn-primary" id="sendContractBtn" 
						<c:if test="${contractInputType eq 'PDF'}">style="flex: 1;"</c:if>
						<c:if test="${contractInputType eq 'FORM'}">disabled style="flex: 1;"</c:if>
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
					<p style="color: #666; margin-bottom: 20px; line-height: 1.7; font-size: 14px;">
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
					<p style="color: #666; margin-bottom: 20px; line-height: 1.7; font-size: 14px;">
						왼쪽 계약서 카드의 내용을 AI 조언에 맞춰 작성하시기 바랍니다. 엉뚱하거나 잘못된 내용이 기입되지 않도록 주의하세요.
					</p>
					<div style="background: #fff; padding: 18px; border-radius: 10px; border: 1px solid #ffc107;">
						<strong style="color: #ad8b00; display: block; margin-bottom: 14px; font-size: 15px;">프로젝트 요구사항 참고:</strong>
						<ul class="ai-requirements-list" style="margin: 0;">
							<c:forEach var="req" items="${draft.requirements}">
								<li style="border-left-color: #ffc107; margin-bottom: 8px;"><c:out value="${req}"/></li>
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
					<div class="sidebar-info-value" style="font-size: 14px; word-break: break-all;"><c:out value="${freelancer.email}" default="-"/></div>
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
// 지급 방식에 따라 마일스톤 섹션 표시/숨김
function toggleMilestoneSection() {
	var method = $('#paymentMethod').val();
	if (method === 'MILESTONE') {
		$('#milestoneSection').show();
	} else {
		$('#milestoneSection').hide();
	}
}

$('#paymentMethod').on('change', function() {
	toggleMilestoneSection();
	checkMilestoneBudget();
	checkRequiredFields();
});

$(document).ready(function() {
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
		'<td style="text-align: center; font-weight: 600; background: #f8f9fa;">' + newStep + '단계</td>' +
		'<td><input type="text" name="milestoneName" required /></td>' +
		'<td><input type="number" name="milestoneAmount" class="milestone-amount" required min="0" step="1" style="text-align: right;" /></td>' +
		'<td><input type="text" name="milestoneDesc" /></td>' +
		'<td style="text-align: center;"><button type="button" class="btn btn-secondary" onclick="removeMilestone(this)" style="padding: 6px 12px; font-size: 12px;">삭제</button></td>' +
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
	var differenceText = difference.toLocaleString('ko-KR') + '원';
	if (difference > 0) {
		$('#amountDifference').text('+' + differenceText).css('color', '#dc3545');
	} else if (difference < 0) {
		$('#amountDifference').text(differenceText).css('color', '#dc3545');
	} else {
		$('#amountDifference').text('0원').css('color', '#28a745');
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
	if (!confirm('계약서를 프리랜서에게 전달하시겠습니까?')) {
		e.preventDefault();
		return;
	}
	
	// FORM 시나리오인 경우 서버에서 PDF 생성하므로 단순히 폼 제출
	var contractInputType = '<c:out value="${contractInputType}" />';
	if (contractInputType === 'FORM') {
		// 서버에서 PDF 생성하므로 추가 작업 없음
		var submitBtn = document.getElementById('sendContractBtn');
		var originalText = submitBtn.textContent;
		submitBtn.disabled = true;
		submitBtn.textContent = '계약서 전송 중...';
		// 폼 제출은 계속 진행
	}
});
</script>
</body>
</html>
