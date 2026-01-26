<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div id="ongoingCenterPanel" class="card" style="display:none;">
    <div class="panel-header-column">

        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 8px;">
            <span>프로젝트 진행 현황</span>
            <span id="projectPeriodDisplay" style="font-size:13px; color:#1F7A8C; font-weight:700;"></span>
        </div>

        <div style="display:flex; justify-content:space-between; align-items:center;">
            <div id="ongoingProjectTitle" style="font-size:15px; color:#333; font-weight:700;"></div>
            <div id="ongoingFreelancerDisplay" style="font-size:13px; color:#333; font-weight:700;"></div>
        </div>

    </div>

    <div class="scroll-container">
        <div id="projectDetailSummary" style="background:#f8f9fa; border:1px solid #eee; border-radius:10px; padding:15px; margin-bottom:20px; display:none;">
            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:10px; font-size:13px;">
                <div><span style="color:#888;">총 예산:</span> <strong id="sumBudget" style="color:#1F7A8C;"></strong></div>
                <div><span style="color:#888;">소통 방식:</span> <strong id="sumComm"></strong></div>
                <div><span style="color:#888;">지급 방식:</span> <strong id="sumPayment"></strong></div>
                <div><span style="color:#888;">수정 횟수:</span> <strong id="sumRevision"></strong>회</div>
            </div>
        </div>

        <%-- 마일스톤 리스트 --%>
        <div id="milestoneListArea"></div>
    </div>

    <div id="ongoingControlButtons" style="padding:15px; border-top:1px solid #eee; background:#fff; display:none;">
        <button type="button" class="btn-action btn-secondary" id="btnDownloadContract" style="margin-bottom:10px; gap:8px;">
            <i class="fa-solid fa-file-pdf"></i> 원본 계약서 다운로드
        </button>

        <div style="display:grid; grid-template-columns: 1fr 1.5fr; gap:10px;">
            <button type="button" class="btn-action" onclick="terminateProject()" style="background:#fff; border-color:#ff4d4f; color:#ff4d4f;">
                계약 파기하기
            </button>
            <button type="button" class="btn-action btn-primary" onclick="completeProject()">
                프로젝트 완료 및 종료
            </button>
        </div>
    </div>
</div>

<div id="ongoingRightPanel" class="card" style="display:none; background:#fdfdfd;">
    <div class="panel-header-text">
        <div style="display:flex; align-items:center; gap:8px;">
            <span id="chatFreelancerName">채팅</span>
        </div>
    </div>
    <div id="chatContainer" style="flex:1; display:flex; align-items:center; justify-content:center; background:#f9f9f9; border:1px dashed #ddd; margin:10px 0; border-radius:8px; color:#aaa;">
        채팅 모듈 로딩 영역
    </div>
</div>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/project/projectProgress.css">
<script src="${pageContext.request.contextPath}/resources/js/project/projectProgress.js"></script>