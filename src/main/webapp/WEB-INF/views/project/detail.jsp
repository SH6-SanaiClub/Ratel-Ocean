<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% 
    // Get session user info
    Object userIdObj = session.getAttribute("userId");
    Object userRoleObj = session.getAttribute("userRole");
    Integer sessionUserId = userIdObj != null ? (Integer) userIdObj : null;
    String userRole = userRoleObj != null ? (String) userRoleObj : null;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>프로젝트 상세</title>
    <style>
        :root{
            --bg:#f8fafc;
            --card:#ffffff;
            --text:#111827;
            --text-light:#4b5563;
            --muted:#6b7280;
            --line:#e5e7eb;
            --primary:#5c3cce;
            --success:#10b981;
            --danger:#ef4444;
            --warning:#f59e0b;
            --shadow-sm:0 4px 12px rgba(0,0,0,0.06);
            --shadow:0 10px 28px rgba(15,23,42,0.08);
            --shadow-lg:0 20px 40px rgba(15,23,42,0.12);
            --radius:16px;
            --radius-lg:20px;
        }
        *{box-sizing:border-box;}
        html,body{margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Pretendard,Arial,sans-serif;background:var(--bg);color:var(--text);}
        
        .container{max-width:1200px;margin:0 auto;padding:0 16px;}
        .header-top{background:var(--card);border-bottom:1px solid var(--line);padding:20px 0;margin-bottom:32px;}
        .back-link{display:inline-flex;align-items:center;gap:6px;color:var(--primary);text-decoration:none;font-weight:700;font-size:14px;margin-bottom:12px;}
        .back-link:hover{opacity:0.8;}
        
        .detail-grid{display:grid;grid-template-columns:1fr 340px;gap:24px;margin-bottom:24px;}
        .content{display:flex;flex-direction:column;gap:24px;}
        .sidebar{display:flex;flex-direction:column;gap:16px;}
        
        /* Main Info Card */
        .card{
            background:var(--card);
            border-radius:var(--radius-lg);
            box-shadow:var(--shadow);
            padding:32px;
            overflow:hidden;
        }
        
        .card-title{font-size:14px;font-weight:900;color:var(--muted);text-transform:uppercase;letter-spacing:0.5px;margin:0 0 16px;}
        .card-header{border-bottom:1px solid var(--line);padding-bottom:20px;margin-bottom:20px;}
        
        .project-title{
            font-size:32px;
            font-weight:950;
            line-height:1.2;
            margin:0 0 16px;
            color:var(--text);
        }
        
        .stacks-section{margin:20px 0;}
        .stacks-label{font-size:12px;font-weight:900;color:var(--muted);text-transform:uppercase;margin-bottom:10px;}
        .stacks{display:flex;flex-wrap:wrap;gap:8px;}
        .stack-chip{
            padding:8px 14px;
            border-radius:999px;
            font-size:13px;
            font-weight:700;
            display:inline-flex;
            align-items:center;
            gap:4px;
            background:#f3f4f6;
            color:var(--text-light);
        }
        .stack-chip.position{
            background:#d1fae5;
            color:#047857;
        }
        .stack-chip.skill{
            background:#dbeafe;
            color:#1e40af;
        }
        .stack-level{font-size:11px;opacity:0.7;}
        
        .budget-section{
            margin-top:20px;
            padding-top:20px;
            border-top:1px solid var(--line);
        }
        .budget-label{font-size:12px;color:var(--muted);font-weight:700;margin-bottom:4px;}
        .budget-amount{
            font-size:28px;
            font-weight:950;
            color:var(--primary);
        }
        
        .meta-grid{
            display:grid;
            grid-template-columns:1fr 1fr;
            gap:12px;
            margin-top:20px;
        }
        .meta-item{
            background:#f9fafb;
            padding:12px;
            border-radius:12px;
            border:1px solid var(--line);
        }
        .meta-label{font-size:11px;color:var(--muted);font-weight:700;margin-bottom:4px;}
        .meta-value{font-size:13px;font-weight:700;color:var(--text);}
        
        /* Description */
        .desc-card .card-title{margin-bottom:16px;}
        .description{
            white-space:pre-wrap;
            line-height:1.7;
            font-size:14px;
            color:var(--text-light);
            word-break:break-word;
        }
        
        /* Attachments */
        .attachments-card .card-title{margin-bottom:16px;}
        .file-item{
            border:1px solid var(--line);
            border-radius:12px;
            padding:14px 16px;
            background:#f9fafb;
            display:flex;
            justify-content:space-between;
            align-items:center;
            gap:12px;
        }
        .file-info{flex:1;min-width:0;}
        .file-name{font-weight:700;font-size:14px;color:var(--text);margin-bottom:2px;word-break:break-all;}
        .file-meta{font-size:12px;color:var(--muted);}
        .file-action{
            padding:8px 16px;
            background:var(--primary);
            color:white;
            border:none;
            border-radius:8px;
            font-weight:700;
            font-size:12px;
            cursor:pointer;
            text-decoration:none;
            display:inline-block;
            transition:all 0.2s;
        }
        .file-action:hover{opacity:0.9;transform:translateY(-1px);}
        .empty-message{
            color:var(--muted);
            font-weight:700;
            font-size:14px;
            padding:20px;
            text-align:center;
            background:#f9fafb;
            border-radius:12px;
        }
        
        /* Sidebar */
        .sidebar-card{
            background:var(--card);
            border-radius:var(--radius-lg);
            box-shadow:var(--shadow);
            padding:20px;
            text-align:center;
        }
        .apply-btn, .chat-btn, .contract-btn{
            width:100%;
            padding:12px 16px;
            border:none;
            border-radius:10px;
            font-weight:700;
            font-size:14px;
            cursor:pointer;
            transition:all 0.2s;
            margin-bottom:8px;
            display:block;
            text-decoration:none;
        }
        .apply-btn{background:var(--primary);color:white;}
        .apply-btn:hover{opacity:0.9;transform:translateY(-2px);}
        .chat-btn{background:var(--success);color:white;}
        .chat-btn:hover{opacity:0.9;transform:translateY(-2px);}
        .contract-btn{background:var(--warning);color:white;}
        .contract-btn:hover{opacity:0.9;transform:translateY(-2px);}
        
        .client-info{
            text-align:left;
            padding:16px;
            background:#f9fafb;
            border-radius:12px;
            margin-top:12px;
            border:1px solid var(--line);
        }
        .client-label{font-size:11px;color:var(--muted);font-weight:700;margin-bottom:6px;}
        .client-name{font-weight:700;font-size:14px;color:var(--text);}
        
        @media (max-width:960px){
            .detail-grid{grid-template-columns:1fr;}
            .project-title{font-size:24px;}
            .meta-grid{grid-template-columns:1fr;}
            .card{padding:20px;}
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<c:if test="${empty project}">
    <div class="header-top">
        <div class="container">
            <a href="${pageContext.request.contextPath}/project/dashboard" class="back-link">← 목록으로</a>
        </div>
    </div>
    <div class="container" style="text-align: center; padding: 60px 20px;">
        <h2 style="color: #6b7280; font-size: 20px; font-weight: 700;">프로젝트를 찾을 수 없습니다.</h2>
        <p style="color: #9ca3af; margin-top: 8px;">존재하지 않거나 삭제된 프로젝트입니다.</p>
        <a href="${pageContext.request.contextPath}/project/dashboard" style="display: inline-block; margin-top: 20px; padding: 10px 20px; background: #5c3cce; color: white; text-decoration: none; border-radius: 8px;">목록으로 돌아가기</a>
    </div>
</c:if>

<c:if test="${not empty project}">
<div class="header-top">
    <div class="container">
        <a href="${pageContext.request.contextPath}/project/dashboard" class="back-link">← 목록으로</a>
    </div>
</div>

<div class="container">
    <div class="detail-grid">
        <div class="content">
            <!-- Main Info -->
            <div class="card">
                <div class="card-header">
                    <h1 class="project-title">${not empty project.title ? project.title : '제목 없음'}</h1>
                </div>
                
                <!-- Stacks -->
                <c:if test="${not empty project.stacks}">
                    <div class="stacks-section">
                        <div class="stacks-label">개발 영역</div>
                        <div class="stacks">
                            <c:forEach var="s" items="${project.stacks}">
                                <c:if test="${s.category eq 'POSITION'}">
                                    <span class="stack-chip position">${s.stackName}</span>
                                </c:if>
                            </c:forEach>
                        </div>
                    </div>
                    
                    <div class="stacks-section">
                        <div class="stacks-label">기술 스택</div>
                        <div class="stacks">
                            <c:forEach var="s" items="${project.stacks}">
                                <c:if test="${s.category eq 'SKILL'}">
                                    <span class="stack-chip skill">
                                        ${s.stackName}
                                        <c:if test="${s.stackLevel != null}"><span class="stack-level">Lv.${s.stackLevel}</span></c:if>
                                    </span>
                                </c:if>
                            </c:forEach>
                        </div>
                    </div>
                </c:if>
                
                <!-- Budget -->
                <div class="budget-section">
                    <div class="budget-label">예산</div>
                    <div class="budget-amount">
                        <c:choose>
                            <c:when test="${not empty project.budget}">₩<fmt:formatNumber value="${project.budget}" type="number" pattern="#,##0" /></c:when>
                            <c:otherwise>협의 예정</c:otherwise>
                        </c:choose>
                    </div>
                </div>
                
                <!-- Meta Info -->
                <div class="meta-grid">
                    <div class="meta-item">
                        <div class="meta-label">예상 기간</div>
                        <div class="meta-value">${not empty project.estDuration ? project.estDuration : '-'}</div>
                    </div>
                    <div class="meta-item">
                        <div class="meta-label">마감일</div>
                        <div class="meta-value">${not empty project.deadlineDate ? project.deadlineDate : '-'}</div>
                    </div>
                    <div class="meta-item">
                        <div class="meta-label">소통 방식</div>
                        <div class="meta-value">${not empty project.communicateMethod ? project.communicateMethod : '-'}</div>
                    </div>
                    <div class="meta-item">
                        <div class="meta-label">지급 방식</div>
                        <div class="meta-value">${not empty project.paymentMethod ? project.paymentMethod : '-'}</div>
                    </div>
                </div>
            </div>
            
            <!-- Description -->
            <div class="card desc-card">
                <div class="card-title">프로젝트 설명</div>
                <div class="description">${not empty project.description ? fn:escapeXml(project.description) : '설명이 없습니다.'}</div>
            </div>
            
            <!-- Attachments -->
            <div class="card attachments-card">
                <div class="card-title">첨부 파일</div>
                <c:choose>
                    <c:when test="${not empty project.planUrl}">
                        <div class="file-item">
                            <div class="file-info">
                                <div class="file-name">${fn:substringAfter(project.planUrl, '/project/')}</div>
                                <div class="file-meta">${project.fileSize}</div>
                            </div>
                            <a href="${pageContext.request.contextPath}${project.planUrl}" download class="file-action">다운로드</a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-message">등록된 첨부가 없습니다.</div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
        
        <!-- Sidebar -->
        <div class="sidebar">
            <%
                Integer clientId = null;
                Object projectObj = request.getAttribute("project");
                if (projectObj != null && projectObj instanceof com.sanaiclub.domain.project.dto.ProjectDetailDTO) {
                    com.sanaiclub.domain.project.dto.ProjectDetailDTO proj = (com.sanaiclub.domain.project.dto.ProjectDetailDTO) projectObj;
                    clientId = proj.getClientId();
                }
                
                boolean isClient = "client".equals(userRole) && 
                                   sessionUserId != null && 
                                   clientId != null &&
                                   sessionUserId.equals(clientId);
                boolean isFreelancer = "freelancer".equals(userRole);
            %>
            
            <c:choose>
                <c:when test="<%= isClient %>">
                    <!-- Client View -->
                    <div class="sidebar-card">
                        <button class="chat-btn" onclick="alert('준비 중: 지원자와 채팅하기')">💬 지원자와 채팅</button>
                        <button class="contract-btn" onclick="alert('준비 중: 계약서 작성')">📋 계약서 작성</button>
                    </div>
                </c:when>
                <c:otherwise>
                    <!-- Freelancer View -->
                    <div class="sidebar-card">
                        <button class="apply-btn" onclick="alert('준비 중: 지원하기')">✓ 지원하기</button>
                        <button class="chat-btn" onclick="alert('준비 중: 클라이언트와 채팅')">💬 채팅하기</button>
                    </div>
                </c:otherwise>
            </c:choose>
            
            <!-- Client Info -->
            <div class="sidebar-card">
                <div class="client-info">
                    <div class="client-label">클라이언트</div>
                    <div class="client-name">프로젝트 등록자</div>
                </div>
            </div>
        </div>
    </div>
</div>
</c:if>
</body>
</html>
