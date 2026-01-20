<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>계약서 작성 - 프로젝트 정보 및 프리랜서 정보</title>
    <link rel="stylesheet" href="/resources/css/contract/contract-form.css" />
    <style>
        .contract-container { display: flex; flex-direction: column; gap: 32px; max-width: 900px; margin: 0 auto; }
        .contract-top { display: flex; gap: 32px; }
        .project-info, .freelancer-info { flex: 1; border: 1px solid #ddd; border-radius: 8px; padding: 24px; background: #fafbfc; }
        .section-title { font-weight: bold; font-size: 1.2em; margin-bottom: 12px; }
        .upload-section { border: 1px solid #ddd; border-radius: 8px; padding: 24px; background: #f5f5f5; }
    </style>
</head>
<body>
<div class="contract-container">
    <div style="display: flex; gap: 16px; margin-bottom: 16px;">
        <div>
            <label for="projectSelect">프로젝트 선택:</label>
            <select id="projectSelect">
                <option value="">-- 선택 --</option>
                <!-- 프로젝트 목록은 JS로 동적 로딩 예정 -->
            </select>
            <button type="button" onclick="fetchProjectInfo()">조회</button>
        </div>
        <div>
            <label for="freelancerSelect">프리랜서 선택:</label>
            <select id="freelancerSelect">
                <option value="">-- 선택 --</option>
                <!-- 프리랜서 목록은 JS로 동적 로딩 예정 -->
            </select>
            <button type="button" onclick="fetchFreelancerInfo()">조회</button>
        </div>
    </div>
    <div class="contract-top">
        <div class="project-info">
            <div class="section-title">프로젝트 정보</div>
            <div>프로젝트명: <span id="projectName">${project.name}</span></div>
            <div>설명: <span id="projectDescription">${project.description}</span></div>
            <div>예상 기간: <span id="projectDuration">${project.duration}</span></div>
            <div>예상 예산: <span id="projectBudget">${project.budget}</span></div>
            <div>요구 기술스택: <span id="projectTechStack">${project.techStack}</span></div>
        </div>
        <div class="freelancer-info">
            <div class="section-title">프리랜서 정보</div>
            <div>이름: <span id="freelancerName">${freelancer.name}</span></div>
            <div>이메일: <span id="freelancerEmail">${freelancer.email}</span></div>
            <div>연락처: <span id="freelancerPhone">${freelancer.phone}</span></div>
            <div>경력: <span id="freelancerCareer">${freelancer.career}</span></div>
        </div>
    </div>
    <div class="upload-section">
        <div class="section-title">계약서 PDF 업로드</div>
        <form action="/contract/upload" method="post" enctype="multipart/form-data">
            <input type="file" name="contractPdf" accept="application/pdf" required />
            <button type="submit">업로드</button>
        </form>
    </div>
</div>

<script>
// 프로젝트/프리랜서 목록 불러오기 (예시: /contract/projectList, /contract/freelancerList API 필요)

function loadProjectList() {
    fetch('/contract/projectList')
        .then(res => res.json())
        .then(list => {
            const select = document.getElementById('projectSelect');
            select.innerHTML = '<option value="">-- 선택 --</option>';
            list.forEach(p => {
                select.innerHTML += `<option value="${p.id}">${p.name}</option>`;
            });
            // 프로젝트 선택 시 지원자 목록 초기화
            select.onchange = function() {
                clearProjectInfo();
                clearFreelancerInfo();
                loadFreelancerListByProject(select.value);
            };
        });
}

function loadFreelancerListByProject(projectId) {
    const select = document.getElementById('freelancerSelect');
    if (!projectId) {
        select.innerHTML = '<option value="">-- 선택 --</option>';
        return;
    }
    fetch(`/contract/freelancerList?projectId=${projectId}`)
        .then(res => res.json())
        .then(list => {
            select.innerHTML = '<option value="">-- 선택 --</option>';
            list.forEach(f => {
                select.innerHTML += `<option value="${f.id}">${f.name}</option>`;
            });
        });
}

function fetchProjectInfo() {
    const id = document.getElementById('projectSelect').value;
    if (!id) return clearProjectInfo();
    fetch(`/contract/projectInfo?projectId=${id}`)
        .then(res => res.json())
        .then(data => {
            document.getElementById('projectName').textContent = data.name || '';
            document.getElementById('projectDescription').textContent = data.description || '';
            document.getElementById('projectDuration').textContent = data.duration || '';
            document.getElementById('projectBudget').textContent = data.budget || '';
            document.getElementById('projectTechStack').textContent = data.techStack || '';
        });
}

function fetchFreelancerInfo() {
    const id = document.getElementById('freelancerSelect').value;
    if (!id) return clearFreelancerInfo();
    fetch(`/contract/freelancerInfo?freelancerId=${id}`)
        .then(res => res.json())
        .then(data => {
            document.getElementById('freelancerName').textContent = data.name || '';
            document.getElementById('freelancerEmail').textContent = data.email || '';
            document.getElementById('freelancerPhone').textContent = data.phone || '';
            document.getElementById('freelancerCareer').textContent = data.career || '';
        });
}

function clearProjectInfo() {
    document.getElementById('projectName').textContent = '';
    document.getElementById('projectDescription').textContent = '';
    document.getElementById('projectDuration').textContent = '';
    document.getElementById('projectBudget').textContent = '';
    document.getElementById('projectTechStack').textContent = '';
}

function clearFreelancerInfo() {
    document.getElementById('freelancerName').textContent = '';
    document.getElementById('freelancerEmail').textContent = '';
    document.getElementById('freelancerPhone').textContent = '';
    document.getElementById('freelancerCareer').textContent = '';
}

window.onload = function() {
    loadProjectList();
    document.getElementById('freelancerSelect').innerHTML = '<option value="">-- 선택 --</option>';
    clearProjectInfo();
    clearFreelancerInfo();
}
</script>
</body>
</html>
