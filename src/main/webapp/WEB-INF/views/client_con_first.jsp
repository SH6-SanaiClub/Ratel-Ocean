<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>계약 시작하기 - Ratel Ocean</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background-color: #f9f9f9;
            padding: 2rem;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
        }

        .page-title {
            font-size: 1.8rem;
            font-weight: 700;
            color: #2B2B2B;
            margin-bottom: 2rem;
        }

        .content-wrapper {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 2rem;
            margin-bottom: 2rem;
        }

        .section {
            background: white;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            padding: 1.5rem;
        }

        .section-title {
            font-size: 1.2rem;
            font-weight: 600;
            color: #2B2B2B;
            margin-bottom: 1.5rem;
            padding-bottom: 0.75rem;
            border-bottom: 2px solid #94D9DB;
        }

        /* 좌측: 프로젝트 공지 */
        .project-notice {
            min-height: 400px;
            max-height: 500px;
            overflow-y: auto;
            background-color: #fafafa;
            border: 1px solid #e5e7eb;
            border-radius: 6px;
            padding: 1rem;
            line-height: 1.6;
            color: #555;
            font-size: 0.95rem;
        }

        .project-notice p {
            margin-bottom: 1rem;
        }

        .project-notice::-webkit-scrollbar {
            width: 8px;
        }

        .project-notice::-webkit-scrollbar-track {
            background: transparent;
        }

        .project-notice::-webkit-scrollbar-thumb {
            background: #ccc;
            border-radius: 4px;
        }

        .project-notice::-webkit-scrollbar-thumb:hover {
            background: #999;
        }

        /* 우측: 계약 파트너 */
        .partner-card {
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
        }

        .partner-image {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            background-color: #e5e7eb;
            margin-bottom: 1.5rem;
            object-fit: cover;
            border: 3px solid #94D9DB;
        }

        .partner-name {
            font-size: 1.3rem;
            font-weight: 600;
            color: #2B2B2B;
            margin-bottom: 0.5rem;
        }

        .partner-desc {
            font-size: 0.95rem;
            color: #666;
            line-height: 1.5;
        }

        /* 하단: 계약서 업로드 */
        .upload-section {
            background: white;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            padding: 2rem;
            margin-bottom: 2rem;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-group label {
            display: block;
            font-weight: 600;
            color: #2B2B2B;
            margin-bottom: 0.5rem;
            font-size: 0.95rem;
        }

        .file-input-wrapper {
            position: relative;
            display: inline-block;
            width: 100%;
        }

        .file-input-wrapper input[type="file"] {
            display: none;
        }

        .file-label {
            display: block;
            padding: 1rem;
            background-color: #f0f0f0;
            border: 2px dashed #94D9DB;
            border-radius: 6px;
            text-align: center;
            cursor: pointer;
            color: #666;
            font-size: 0.95rem;
            transition: background-color 0.2s ease;
        }

        .file-label:hover {
            background-color: #e8f8f9;
        }

        .file-name {
            margin-top: 0.5rem;
            font-size: 0.85rem;
            color: #94D9DB;
            font-weight: 600;
        }

        .button-group {
            display: flex;
            gap: 1rem;
            justify-content: center;
        }

        .btn {
            padding: 0.75rem 2rem;
            border-radius: 6px;
            border: none;
            font-size: 0.95rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .btn-primary {
            background-color: #2B2B2B;
            color: white;
        }

        .btn-primary:hover {
            background-color: #1a1a1a;
        }

        .btn-secondary {
            background-color: #e5e7eb;
            color: #2B2B2B;
        }

        .btn-secondary:hover {
            background-color: #d1d5db;
        }

        @media (max-width: 768px) {
            .content-wrapper {
                grid-template-columns: 1fr;
            }

            .page-title {
                font-size: 1.5rem;
            }
        }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/views/common/client_header.jsp" %>
    <div class="container">
        <h1 class="page-title">계약 시작하기</h1>

        <!-- 좌측/우측 콘텐츠 -->
        <div class="content-wrapper">
            <!-- 좌측: 프로젝트 공지 -->
            <div class="section">
                <h2 class="section-title">프로젝트 공지 상세 내용</h2>
                <div class="project-notice">
                    <p><strong>📌 프로젝트명:</strong> 금융 서비스 플랫폼 "라텔오션" 백엔드 API 개발</p>
                    <p><strong>📅 프로젝트 기간:</strong> 2026년 1월 21일 ~ 2026년 4월 21일 (3개월)</p>
                    <p><strong>💰 예산:</strong> 5,000,000원 (협의 불가)</p>
                    
                    <p><strong>📋 프로젝트 설명:</strong></p>
                    <p>프리랜서-클라이언트 매칭 플랫폼 "라텔오션"의 백엔드 API 서버를 개발합니다. 
                       Spring MVC 기반의 RESTful API를 구축하고, MySQL 데이터베이스와 연동하여 
                       안정적이고 확장 가능한 서비스를 제공하는 것이 목표입니다.</p>
                    
                    <p><strong>🎯 주요 작업 항목:</strong></p>
                    <p>• 사용자 인증 및 회원 관리 API (JWT 기반)<br/>
                       • 프로젝트 등록 및 매칭 시스템 API<br/>
                       • 실시간 채팅 및 알림 기능 구현<br/>
                       • 에스크로 결제 및 정산 시스템 연동<br/>
                       • 계약서 PDF 파싱 및 AI 분석 모듈 통합<br/>
                       • 관리자 대시보드 데이터 제공 API</p>
                    
                    <p><strong>🛠 기술 스택:</strong></p>
                    <p>• Backend: Java 17, Spring MVC 5.3, MyBatis 3.5<br/>
                       • Database: MySQL 8.0<br/>
                       • 협업 도구: Git, Notion, Slack<br/>
                       • 배포: Apache Tomcat 9.0</p>
                    
                    <p><strong>✅ 요구사항:</strong></p>
                    <p>• Spring MVC 및 MyBatis 실무 경험 3년 이상<br/>
                       • RESTful API 설계 및 구현 경험 필수<br/>
                       • MySQL 데이터베이스 설계 및 최적화 능력<br/>
                       • Git을 활용한 협업 경험</p>
                    
                    <p><strong>📢 특이사항:</strong></p>
                    <p>• 주 2회 (화/금) 오후 3시 온라인 진도 검토 미팅<br/>
                       • 코드 리뷰는 PR 단위로 진행<br/>
                       • 단계별 산출물 제출 및 검수 진행<br/>
                       • API 문서화(Swagger) 필수</p>
                </div>
            </div>

            <!-- 우측: 계약 파트너 -->
            <div class="section">
                <h2 class="section-title">계약 파트너</h2>
                <div class="partner-card">
                    <img src="${pageContext.request.contextPath}/resources/images/default_profile.png" 
                         alt="프리랜서 프로필" class="partner-image">
                    <div class="partner-name">김개발 (개발자)</div>
                    <div class="partner-desc">
                        <p style="margin-bottom: 1rem;">⭐ 평점 4.8 / 5.0 (프로젝트 12건)</p>
                        <p style="margin-bottom: 0.5rem;"><strong>전문 분야:</strong></p>
                        <p style="margin-bottom: 1rem;">Spring 백엔드 개발, RESTful API 설계</p>
                        <p style="margin-bottom: 0.5rem;"><strong>경력:</strong></p>
                        <p style="margin-bottom: 1rem;">백엔드 개발 5년 (Java/Spring 전문)</p>
                        <p style="margin-bottom: 0.5rem;"><strong>주요 성과:</strong></p>
                        <p>• 전자상거래 플랫폼 API 개발 (MAU 10만)<br/>
                           • 금융 서비스 백엔드 구축 경험 2건<br/>
                           • 프로젝트 일정 준수율 100%</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- 하단: 계약서 업로드 -->
        <div class="upload-section">
            <h2 class="section-title">계약서 원본 업로드</h2>
            <p style="color: #666; margin-bottom: 1.5rem; font-size: 0.9rem;">
                💡 업로드하신 PDF 계약서를 AI가 분석하여 계약 정보를 자동으로 추출합니다. 
                다음 단계에서 내용을 검토하고 수정하실 수 있습니다.
            </p>
            
            <form method="post" action="/ratelocean/contract/first" enctype="multipart/form-data">
                <div class="form-group">
                    <label for="contractPdf">계약서 PDF 파일</label>
                    <div class="file-input-wrapper">
                        <input type="file" id="contractPdf" name="contractPdf" accept=".pdf" required>
                        <label for="contractPdf" class="file-label">
                            <span>PDF 파일을 선택하거나 클릭하세요</span>
                            <div class="file-name" id="fileName"></div>
                        </label>
                    </div>
                </div>

                <div class="button-group">
                    <button type="button" class="btn btn-secondary" onclick="history.back()">
                        이전으로
                    </button>
                    <button type="submit" class="btn btn-primary">
                        계약 시작하기
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        document.getElementById('contractPdf').addEventListener('change', function(e) {
            var fileName = e.target.files[0]?.name || '';
            document.getElementById('fileName').textContent = fileName ? '선택됨: ' + fileName : '';
        });
    </script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

</body>
</html>
