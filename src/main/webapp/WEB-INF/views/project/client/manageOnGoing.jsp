<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div id="ongoingCenterPanel" class="card" style="display:none;">
    <div class="panel-header-column">
        <div style="display:flex; justify-content:space-between; align-items:center;">
            <span>프로젝트 진행 현황</span>
        </div>
        <div style="font-size:15px; color:#333; margin-top:8px; font-weight:700;" id="ongoingProjectTitle"></div>
    </div>

    <div class="scroll-container" id="milestoneListArea">
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