<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>업로드된 파일 목록</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 40px 20px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
        }

        .header {
            background: white;
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
        }

        h1 {
            color: #333;
            font-size: 32px;
            margin-bottom: 10px;
        }

        .subtitle {
            color: #666;
            font-size: 14px;
            margin-bottom: 20px;
        }

        .stats {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
        }

        .stat-box {
            flex: 1;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 15px;
            text-align: center;
        }

        .stat-number {
            font-size: 36px;
            font-weight: bold;
            margin-bottom: 5px;
        }

        .stat-label {
            font-size: 14px;
            opacity: 0.9;
        }

        .upload-path {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 10px;
            font-size: 13px;
            color: #666;
            word-break: break-all;
        }

        .upload-path strong {
            color: #333;
        }

        .buttons {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }

        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
        }

        .btn-secondary {
            background: white;
            color: #667eea;
            border: 2px solid #667eea;
        }

        .btn-secondary:hover {
            background: #f8f9ff;
        }

        .files-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
        }

        .file-card {
            background: white;
            border-radius: 15px;
            padding: 20px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            transition: all 0.3s;
        }

        .file-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
        }

        .file-icon {
            font-size: 48px;
            text-align: center;
            margin-bottom: 15px;
        }

        .file-extension {
            display: inline-block;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            margin-bottom: 10px;
        }

        .file-name {
            font-weight: 600;
            color: #333;
            margin-bottom: 10px;
            word-break: break-all;
            font-size: 14px;
            line-height: 1.4;
        }

        .file-meta {
            color: #999;
            font-size: 13px;
            margin-bottom: 5px;
        }

        .file-actions {
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid #e0e0e0;
            display: flex;
            gap: 10px;
        }

        .file-actions a, .file-actions button {
            flex: 1;
            padding: 8px 16px;
            color: white;
            text-decoration: none;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            transition: all 0.3s;
            border: none;
            cursor: pointer;
        }

        .file-actions a {
            background: #667eea;
        }

        .file-actions a:hover {
            background: #764ba2;
        }

        .file-actions button {
            background: #dc3545;
        }

        .file-actions button:hover {
            background: #c82333;
        }

        .file-actions button:disabled {
            background: #ccc;
            cursor: not-allowed;
        }

        .empty-state {
            background: white;
            border-radius: 20px;
            padding: 60px 40px;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        }

        .empty-icon {
            font-size: 80px;
            margin-bottom: 20px;
        }

        .empty-text {
            color: #666;
            font-size: 18px;
            margin-bottom: 30px;
        }

        .alert {
            background: #fff3cd;
            border: 1px solid #ffc107;
            color: #856404;
            padding: 15px 20px;
            border-radius: 10px;
            margin-bottom: 20px;
        }

        @media (max-width: 768px) {
            .files-grid {
                grid-template-columns: 1fr;
            }

            .stats {
                flex-direction: column;
            }

            h1 {
                font-size: 24px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📂 업로드된 파일 목록</h1>
            <p class="subtitle">모든 사용자가 업로드한 파일을 확인할 수 있습니다</p>

            <c:if test="${not empty error}">
                <div class="alert">
                    ⚠️ ${error}
                </div>
            </c:if>

            <div class="stats">
                <div class="stat-box">
                    <div class="stat-number">${totalFiles}</div>
                    <div class="stat-label">총 파일 개수</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number">
                        <c:set var="totalSize" value="0" />
                        <c:forEach items="${files}" var="file">
                            <c:set var="totalSize" value="${totalSize + file.sizeBytes}" />
                        </c:forEach>
                        <c:choose>
                            <c:when test="${totalSize < 1024}">
                                ${totalSize} B
                            </c:when>
                            <c:when test="${totalSize < 1024 * 1024}">
                                ${String.format('%.2f', totalSize / 1024.0)} KB
                            </c:when>
                            <c:when test="${totalSize < 1024 * 1024 * 1024}">
                                ${String.format('%.2f', totalSize / (1024.0 * 1024.0))} MB
                            </c:when>
                            <c:otherwise>
                                ${String.format('%.2f', totalSize / (1024.0 * 1024.0 * 1024.0))} GB
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="stat-label">총 용량</div>
                </div>
            </div>

            <div class="upload-path">
                <strong>📍 저장 경로:</strong> ${uploadDir}
            </div>

            <div class="buttons">
                <a href="${pageContext.request.contextPath}/test/upload" class="btn btn-primary">
                    📤 파일 업로드하기
                </a>
                <a href="${pageContext.request.contextPath}/test/files" class="btn btn-secondary">
                    🔄 새로고침
                </a>
                <a href="${pageContext.request.contextPath}/" class="btn btn-secondary">
                    🏠 홈으로
                </a>
            </div>
        </div>

        <c:choose>
            <c:when test="${empty files}">
                <div class="empty-state">
                    <div class="empty-icon">📭</div>
                    <div class="empty-text">아직 업로드된 파일이 없습니다</div>
                    <a href="${pageContext.request.contextPath}/test/upload" class="btn btn-primary">
                        첫 파일 업로드하기
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="files-grid">
                    <c:forEach items="${files}" var="file">
                        <div class="file-card">
                            <div class="file-icon">
                                <c:choose>
                                    <c:when test="${fn:toLowerCase(file.extension) eq 'pdf'}">📄</c:when>
                                    <c:when test="${fn:toLowerCase(file.extension) eq 'png' or fn:toLowerCase(file.extension) eq 'jpg' or fn:toLowerCase(file.extension) eq 'jpeg' or fn:toLowerCase(file.extension) eq 'gif'}">🖼️</c:when>
                                    <c:when test="${fn:toLowerCase(file.extension) eq 'zip' or fn:toLowerCase(file.extension) eq 'rar' or fn:toLowerCase(file.extension) eq '7z'}">📦</c:when>
                                    <c:when test="${fn:toLowerCase(file.extension) eq 'doc' or fn:toLowerCase(file.extension) eq 'docx'}">📝</c:when>
                                    <c:when test="${fn:toLowerCase(file.extension) eq 'xls' or fn:toLowerCase(file.extension) eq 'xlsx'}">📊</c:when>
                                    <c:when test="${fn:toLowerCase(file.extension) eq 'ppt' or fn:toLowerCase(file.extension) eq 'pptx'}">📊</c:when>
                                    <c:when test="${fn:toLowerCase(file.extension) eq 'txt'}">📃</c:when>
                                    <c:when test="${fn:toLowerCase(file.extension) eq 'mp3' or fn:toLowerCase(file.extension) eq 'wav'}">🎵</c:when>
                                    <c:when test="${fn:toLowerCase(file.extension) eq 'mp4' or fn:toLowerCase(file.extension) eq 'avi'}">🎬</c:when>
                                    <c:otherwise>📄</c:otherwise>
                                </c:choose>
                            </div>
                            
                            <c:if test="${not empty file.extension}">
                                <span class="file-extension">${file.extension}</span>
                            </c:if>
                            
                            <div class="file-name">${file.name}</div>
                            
                            <div class="file-meta">
                                📦 크기: ${file.size}
                            </div>
                            
                            <div class="file-meta">
                                🕐 업로드: ${file.uploadDate}
                            </div>
                            
                            <div class="file-meta" style="font-size: 11px; color: #aaa; margin-top: 10px;">
                                ${file.path}
                            </div>
                            
                            <div class="file-actions">
                                <a href="${pageContext.request.contextPath}/test/download?filename=${file.name}">
                                    ⬇️ 다운로드
                                </a>
                                <button class="delete-btn" data-filename="${file.name}">
                                    🗑️ 삭제
                                </button>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <script>
        // 파일 삭제 기능
        document.querySelectorAll('.delete-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const filename = this.getAttribute('data-filename');
                
                if (!confirm('정말로 이 파일을 삭제하시겠습니까?\n\n파일명: ' + filename)) {
                    return;
                }
                
                // 버튼 비활성화
                this.disabled = true;
                this.innerHTML = '⏳ 삭제 중...';
                
                // 삭제 요청
                fetch('${pageContext.request.contextPath}/test/delete', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'filename=' + encodeURIComponent(filename)
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        alert('✅ ' + data.message);
                        // 페이지 새로고침
                        location.reload();
                    } else {
                        alert('❌ ' + data.message);
                        this.disabled = false;
                        this.innerHTML = '🗑️ 삭제';
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('❌ 파일 삭제 중 오류가 발생했습니다.');
                    this.disabled = false;
                    this.innerHTML = '🗑️ 삭제';
                });
            });
        });

        // 자동 새로고침 (30초마다)
        let autoRefresh = false;
        
        function toggleAutoRefresh() {
            autoRefresh = !autoRefresh;
            if (autoRefresh) {
                console.log('자동 새로고침 활성화 (30초마다)');
                setTimeout(function refresh() {
                    if (autoRefresh) {
                        location.reload();
                    }
                }, 30000);
            }
        }

        // 페이지 로드 시 총 파일 수 표시
        console.log('총 ${totalFiles}개의 파일이 업로드되어 있습니다.');
    </script>

    <!-- Contract 테스트 섹션 추가 -->
    <div class="header" style="margin-top: 30px; background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); color: white;">
        <h2 style="color: white; font-size: 28px; margin-bottom: 15px;">🧪 Contract 시스템 테스트</h2>
        <p style="color: rgba(255,255,255,0.9); font-size: 14px;">3단계 계약 프로세스를 한 페이지에서 직접 테스트하세요</p>
    </div>

    <!-- 1단계: PDF 업로드 & 초기화 -->
    <div class="header" style="margin-top: 20px;">
        <h3 style="color: #667eea; margin-bottom: 15px;">📋 Step 1: 계약 초기화 (GET /contract/start)</h3>
        <form action="${pageContext.request.contextPath}/contract/start" method="GET" style="display: flex; gap: 10px; flex-wrap: wrap;">
            <div style="flex: 1; min-width: 200px;">
                <label style="display: block; margin-bottom: 5px; font-weight: 600; color: #333;">프로젝트 ID:</label>
                <input type="number" name="projectId" value="1" required 
                       style="width: 100%; padding: 10px; border: 2px solid #ddd; border-radius: 6px; font-size: 14px;">
            </div>
            <div style="flex: 1; min-width: 200px;">
                <label style="display: block; margin-bottom: 5px; font-weight: 600; color: #333;">프리랜서 ID:</label>
                <input type="number" name="freelancerId" value="1" required 
                       style="width: 100%; padding: 10px; border: 2px solid #ddd; border-radius: 6px; font-size: 14px;">
            </div>
            <div style="flex: 1; min-width: 200px; display: flex; align-items: flex-end;">
                <button type="submit" style="width: 100%; padding: 10px 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                        color: white; border: none; border-radius: 6px; font-size: 14px; font-weight: 600; cursor: pointer;">
                    🚀 계약 시작 페이지로 이동
                </button>
            </div>
        </form>
        <div style="margin-top: 15px; padding: 15px; background: #f0f7ff; border-left: 4px solid #2196f3; border-radius: 4px;">
            <p style="margin: 0; font-size: 13px; color: #1976d2;">
                ℹ️ <strong>설명:</strong> 프로젝트와 프리랜서 정보를 기반으로 계약 작성 페이지를 엽니다. PDF 업로드 폼이 표시됩니다.
            </p>
        </div>
    </div>

    <!-- 2단계: PDF 분석 테스트 -->
    <div class="header" style="margin-top: 20px;">
        <h3 style="color: #667eea; margin-bottom: 15px;">🤖 Step 2: AI 분석 (POST /contract/analyze)</h3>
        <form action="${pageContext.request.contextPath}/contract/analyze" method="POST" enctype="multipart/form-data" 
              onsubmit="return validateContractAnalyze(this);" style="display: flex; flex-direction: column; gap: 15px;">
            
            <div style="display: flex; gap: 15px; flex-wrap: wrap;">
                <div style="flex: 1; min-width: 200px;">
                    <label style="display: block; margin-bottom: 5px; font-weight: 600; color: #333;">프로젝트 ID:</label>
                    <input type="number" name="projectId" value="1" required 
                           style="width: 100%; padding: 10px; border: 2px solid #ddd; border-radius: 6px; font-size: 14px;">
                </div>
                <div style="flex: 1; min-width: 200px;">
                    <label style="display: block; margin-bottom: 5px; font-weight: 600; color: #333;">프리랜서 ID:</label>
                    <input type="number" name="freelancerId" value="1" required 
                           style="width: 100%; padding: 10px; border: 2px solid #ddd; border-radius: 6px; font-size: 14px;">
                </div>
            </div>

            <div>
                <label style="display: block; margin-bottom: 5px; font-weight: 600; color: #333;">📄 계약서 PDF 파일:</label>
                <input type="file" name="pdf" accept=".pdf" required 
                       style="width: 100%; padding: 10px; border: 2px dashed #667eea; border-radius: 6px; font-size: 14px; background: #f8f9ff;">
                <p style="margin: 5px 0 0 0; font-size: 12px; color: #666;">※ PDF 파일만 업로드 가능 (최대 50MB)</p>
            </div>

            <button type="submit" style="width: 100%; padding: 12px 20px; background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); 
                    color: white; border: none; border-radius: 6px; font-size: 16px; font-weight: 600; cursor: pointer;">
                🤖 AI 분석 시작
            </button>
        </form>
        <div style="margin-top: 15px; padding: 15px; background: #fff3e0; border-left: 4px solid #ff9800; border-radius: 4px;">
            <p style="margin: 0; font-size: 13px; color: #e65100;">
                ⚠️ <strong>주의:</strong> PDF를 업로드하면 AI가 자동으로 계약 내용을 분석하여 마일스톤을 추출합니다. 
                분석 완료 후 검토 페이지(contract-review.jsp)로 이동합니다.
            </p>
        </div>
    </div>

    <!-- 3단계: 계약 확정 (참고용) -->
    <div class="header" style="margin-top: 20px;">
        <h3 style="color: #667eea; margin-bottom: 15px;">✅ Step 3: 계약 확정 (POST /contract/confirm)</h3>
        <div style="padding: 20px; background: #e8f5e9; border: 2px solid #4caf50; border-radius: 8px; text-align: center;">
            <p style="margin: 0 0 10px 0; font-size: 16px; font-weight: 600; color: #2e7d32;">
                ✨ Step 2 완료 후 검토 페이지에서 진행
            </p>
            <p style="margin: 0; font-size: 13px; color: #558b2f;">
                AI 분석 결과를 검토하고 수정한 뒤, "계약 확정" 버튼을 눌러 계약을 완료합니다.<br>
                확정된 계약은 데이터베이스에 저장되며, 확인 페이지(contract-confirm.jsp)가 표시됩니다.
            </p>
        </div>
    </div>

    <!-- 엔드포인트 테스트 현황 -->
    <div class="header" style="margin-top: 20px; background: #f5f5f5;">
        <h3 style="color: #333; margin-bottom: 15px;">🔗 Contract API 엔드포인트 목록</h3>
        <table style="width: 100%; border-collapse: collapse; font-size: 13px;">
            <thead>
                <tr style="background: #667eea; color: white;">
                    <th style="padding: 12px; text-align: left; border: 1px solid #ddd;">Method</th>
                    <th style="padding: 12px; text-align: left; border: 1px solid #ddd;">Endpoint</th>
                    <th style="padding: 12px; text-align: left; border: 1px solid #ddd;">Description</th>
                    <th style="padding: 12px; text-align: center; border: 1px solid #ddd;">Status</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td style="padding: 10px; border: 1px solid #ddd; font-weight: 600; color: #4caf50;">GET</td>
                    <td style="padding: 10px; border: 1px solid #ddd; font-family: 'Courier New', monospace; color: #1976d2;">/contract/start</td>
                    <td style="padding: 10px; border: 1px solid #ddd;">계약 초기화 페이지 (PDF 업로드 폼)</td>
                    <td style="padding: 10px; border: 1px solid #ddd; text-align: center;">
                        <a href="${pageContext.request.contextPath}/contract/start?projectId=1&freelancerId=1" 
                           target="_blank" style="color: #4caf50; text-decoration: none; font-weight: 600;">🔗 테스트</a>
                    </td>
                </tr>
                <tr style="background: #fafafa;">
                    <td style="padding: 10px; border: 1px solid #ddd; font-weight: 600; color: #ff9800;">POST</td>
                    <td style="padding: 10px; border: 1px solid #ddd; font-family: 'Courier New', monospace; color: #1976d2;">/contract/analyze</td>
                    <td style="padding: 10px; border: 1px solid #ddd;">PDF 업로드 + AI 분석 (위 Step 2 폼 사용)</td>
                    <td style="padding: 10px; border: 1px solid #ddd; text-align: center; color: #ff9800; font-weight: 600;">📋 Form</td>
                </tr>
                <tr>
                    <td style="padding: 10px; border: 1px solid #ddd; font-weight: 600; color: #ff9800;">POST</td>
                    <td style="padding: 10px; border: 1px solid #ddd; font-family: 'Courier New', monospace; color: #1976d2;">/contract/confirm</td>
                    <td style="padding: 10px; border: 1px solid #ddd;">계약 확정 및 DB 저장 (검토 페이지에서 진행)</td>
                    <td style="padding: 10px; border: 1px solid #ddd; text-align: center; color: #2196f3; font-weight: 600;">📝 Review</td>
                </tr>
            </tbody>
        </table>
    </div>

    <script>
        function validateContractAnalyze(form) {
            const pdfInput = form.querySelector('input[name="pdf"]');
            if (!pdfInput.files || !pdfInput.files[0]) {
                alert('❌ PDF 파일을 선택해주세요!');
                return false;
            }

            const file = pdfInput.files[0];
            if (!file.name.toLowerCase().endsWith('.pdf')) {
                alert('❌ PDF 파일만 업로드 가능합니다!');
                return false;
            }

            const maxSize = 50 * 1024 * 1024; // 50MB
            if (file.size > maxSize) {
                alert('❌ 파일 크기가 50MB를 초과합니다!');
                return false;
            }

            // 로딩 표시
            const submitBtn = form.querySelector('button[type="submit"]');
            submitBtn.disabled = true;
            submitBtn.innerHTML = '⏳ 분석 중... (최대 10초 소요)';

            return true;
        }
    </script>
</body>
</html>
