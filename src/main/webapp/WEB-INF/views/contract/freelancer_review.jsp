<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>클라이언트 리뷰 작성 | Ratel Ocean</title>
    
    <!--
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     프리랜서 → 클라이언트 리뷰 작성 페이지
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    [목적]
    계약 완료 후 프리랜서가 클라이언트에 대한 평가를 작성합니다.
    
    [입력 항목]
    1. 별점: 0.0 ~ 10.0 (0.5 단위)
    2. 공개 리뷰: 최대 500자
    
    [클라이언트 페이지와의 차이점]
    - 재계약 의사 항목 없음
    - 프리랜서는 별점과 리뷰만 작성
    
    [브랜드 컬러]
    - Background: #F1F6EE (연한 베이지)
    - Card: #FFFFFF (흰색)
    - Button: #1F7A8C (틸 블루)
    - Highlight: #9AD9DB (밝은 틸)
    - Text: #2B2B2B (거의 검정) / #6F7272 (회색)
    
    [별점 UI]
    HTML5 range input으로 구현 (step=0.5)
    실시간 숫자 표시: 8.5 / 10.0
    
    [리뷰 작성]
    textarea, maxlength=500, 실시간 글자 수 표시
    
    [폼 검증]
    - 별점 필수
    - 리뷰는 선택 (500자 이내)
    
    [제출 시]
    POST /review/freelancer
    성공 시 대시보드로 리다이렉트
    
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    -->
    
    <style>
        /* ━━━━ 전역 스타일 ━━━━ */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #F1F6EE;
            color: #2B2B2B;
            line-height: 1.6;
            padding: 40px 20px;
        }
        
        /* ━━━━ 카드 레이아웃 ━━━━ */
        .container {
            max-width: 700px;
            margin: 0 auto;
            background: #FFFFFF;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            padding: 40px;
        }
        
        /* ━━━━ 헤더 ━━━━ */
        .header {
            text-align: center;
            margin-bottom: 40px;
            padding-bottom: 20px;
            border-bottom: 2px solid #9AD9DB;
        }
        
        .header h1 {
            font-size: 28px;
            color: #1F7A8C;
            margin-bottom: 10px;
        }
        
        .header p {
            color: #6F7272;
            font-size: 14px;
        }
        
        /* ━━━━ 계약 요약 섹션 ━━━━ */
        .contract-summary {
            background: #F9FAFB;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
            border-left: 4px solid #1F7A8C;
        }
        
        .contract-summary h3 {
            color: #1F7A8C;
            font-size: 18px;
            margin-bottom: 12px;
        }
        
        .contract-item {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #E5E7EB;
        }
        
        .contract-item:last-child {
            border-bottom: none;
        }
        
        .contract-item .label {
            color: #6F7272;
            font-weight: 600;
        }
        
        .contract-item .value {
            color: #2B2B2B;
            font-weight: 500;
        }
        
        /* ━━━━ 폼 그룹 ━━━━ */
        .form-group {
            margin-bottom: 30px;
        }
        
        .form-group label {
            display: block;
            font-size: 16px;
            font-weight: 600;
            color: #2B2B2B;
            margin-bottom: 12px;
        }
        
        .required {
            color: #DC2626;
        }
        
        /* ━━━━ 별점 입력 ━━━━ */
        .rating-container {
            background: #F9FAFB;
            padding: 20px;
            border-radius: 8px;
        }
        
        .rating-display {
            text-align: center;
            margin-bottom: 16px;
        }
        
        .rating-number {
            font-size: 48px;
            font-weight: bold;
            color: #1F7A8C;
        }
        
        .rating-max {
            font-size: 24px;
            color: #6F7272;
        }
        
        .rating-slider {
            width: 100%;
            height: 8px;
            border-radius: 4px;
            background: linear-gradient(to right, #DC2626 0%, #FBBF24 50%, #10B981 100%);
            outline: none;
            -webkit-appearance: none;
        }
        
        .rating-slider::-webkit-slider-thumb {
            -webkit-appearance: none;
            appearance: none;
            width: 24px;
            height: 24px;
            border-radius: 50%;
            background: #1F7A8C;
            cursor: pointer;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
        }
        
        .rating-slider::-moz-range-thumb {
            width: 24px;
            height: 24px;
            border-radius: 50%;
            background: #1F7A8C;
            cursor: pointer;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
            border: none;
        }
        
        .rating-hint {
            text-align: center;
            color: #6F7272;
            font-size: 13px;
            margin-top: 8px;
        }
        
        /* ━━━━ 리뷰 작성 텍스트 영역 ━━━━ */
        .form-group textarea {
            width: 100%;
            min-height: 150px;
            padding: 16px;
            border: 2px solid #E5E7EB;
            border-radius: 8px;
            font-size: 15px;
            font-family: inherit;
            resize: vertical;
            transition: border-color 0.2s ease;
        }
        
        .form-group textarea:focus {
            outline: none;
            border-color: #1F7A8C;
            box-shadow: 0 0 0 3px rgba(31, 122, 140, 0.1);
        }
        
        .char-counter {
            text-align: right;
            color: #6F7272;
            font-size: 13px;
            margin-top: 6px;
        }
        
        .char-counter.limit-warning {
            color: #DC2626;
            font-weight: 600;
        }
        
        /* ━━━━ 제출 버튼 ━━━━ */
        .submit-section {
            margin-top: 40px;
            text-align: center;
        }
        
        .btn-submit {
            background: #1F7A8C;
            color: #FFFFFF;
            padding: 16px 48px;
            border: none;
            border-radius: 8px;
            font-size: 18px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(31, 122, 140, 0.3);
        }
        
        .btn-submit:hover {
            background: #155A6A;
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(31, 122, 140, 0.4);
        }
        
        .btn-submit:active {
            transform: translateY(0);
        }
        
        /* ━━━━ 에러/성공 메시지 ━━━━ */
        .message {
            padding: 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            text-align: center;
        }
        
        .message.error {
            background: #FEE2E2;
            color: #DC2626;
            border: 1px solid #FCA5A5;
        }
        
        .message.success {
            background: #D1FAE5;
            color: #10B981;
            border: 1px solid #A7F3D0;
        }
        
        /* ━━━━ 반응형 디자인 ━━━━ */
        @media (max-width: 768px) {
            .container {
                padding: 24px;
            }
            
            .header h1 {
                font-size: 24px;
            }
            
            .rating-number {
                font-size: 36px;
            }
            
            .btn-submit {
                width: 100%;
                padding: 14px;
            }
        }
    </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/common/header.jsp" />
    <div class="container">
        <!-- ━━━━ 헤더 ━━━━ -->
        <div class="header">
            <h1>🌟 클라이언트 리뷰 작성</h1>
            <p>프로젝트가 완료되었습니다. 클라이언트에 대한 평가를 남겨주세요.</p>
        </div>
        
        <!-- ━━━━ 에러/성공 메시지 ━━━━ -->
        <c:if test="${not empty errorMessage}">
            <div class="message error">
                ${errorMessage}
            </div>
        </c:if>
        <c:if test="${not empty successMessage}">
            <div class="message success">
                ${successMessage}
            </div>
        </c:if>
        
        <!-- ━━━━ 계약 요약 ━━━━ -->
        <div class="contract-summary">
            <h3>📋 계약 정보</h3>
            <div class="contract-item">
                <span class="label">프로젝트명</span>
                <span class="value">${contract.projectTitle}</span>
            </div>
            <div class="contract-item">
                <span class="label">계약 ID</span>
                <span class="value">#${contract.contractId}</span>
            </div>
            <div class="contract-item">
                <span class="label">계약 금액</span>
                <span class="value">${contract.totalBudget} 원</span>
            </div>
            <div class="contract-item">
                <span class="label">계약 기간</span>
                <span class="value">${contract.contractStartDate} ~ ${contract.contractEndDate}</span>
            </div>
        </div>
        
        <!-- ━━━━ 리뷰 작성 폼 ━━━━ -->
        <form id="reviewForm" action="${pageContext.request.contextPath}/review/freelancer" method="POST" onsubmit="return validateForm()">
            <!-- Hidden 필드 -->
            <input type="hidden" name="contractId" value="${contract.contractId}">
            <input type="hidden" name="freelancerId" value="${contract.freelancerId}">
            
            <!-- ━━━━ 별점 입력 ━━━━ -->
            <div class="form-group">
                <label>
                    별점 평가 <span class="required">*</span>
                </label>
                <div class="rating-container">
                    <div class="rating-display">
                        <span class="rating-number" id="ratingValue">5.0</span>
                        <span class="rating-max">/ 10.0</span>
                    </div>
                    <input 
                        type="range" 
                        id="ratingSlider" 
                        name="rating" 
                        class="rating-slider"
                        min="0" 
                        max="10" 
                        step="0.5" 
                        value="5.0"
                        required>
                    <p class="rating-hint">
                        슬라이더를 움직여 평점을 선택하세요 (0.5 단위)
                    </p>
                </div>
            </div>
            
            <!-- ━━━━ 공개 리뷰 작성 ━━━━ -->
            <div class="form-group">
                <label>
                    공개 리뷰 (선택)
                </label>
                <textarea 
                    id="experienceTextarea"
                    name="experience" 
                    placeholder="클라이언트와의 협업 경험, 의사소통, 프로젝트 진행 과정 등을 자유롭게 작성해주세요. 이 리뷰는 공개됩니다."
                    maxlength="500"></textarea>
                <div class="char-counter" id="charCounter">
                    <span id="charCount">0</span> / 500자
                </div>
            </div>
            
            <!-- ━━━━ 제출 버튼 ━━━━ -->
            <div class="submit-section">
                <button type="submit" class="btn-submit">
                    📝 리뷰 제출하기
                </button>
            </div>
        </form>
    </div>
    
    <!-- ━━━━ JavaScript ━━━━ -->
    <script>
        /**
         * 별점 슬라이더 실시간 업데이트
         */
        const ratingSlider = document.getElementById('ratingSlider');
        const ratingValue = document.getElementById('ratingValue');
        
        ratingSlider.addEventListener('input', function() {
            const value = parseFloat(this.value).toFixed(1);
            ratingValue.textContent = value;
        });
        
        /**
         * 리뷰 텍스트 글자 수 카운터
         */
        const textarea = document.getElementById('experienceTextarea');
        const charCount = document.getElementById('charCount');
        const charCounter = document.getElementById('charCounter');
        
        textarea.addEventListener('input', function() {
            const length = this.value.length;
            charCount.textContent = length;
            
            // 490자 이상이면 경고 표시
            if (length >= 490) {
                charCounter.classList.add('limit-warning');
            } else {
                charCounter.classList.remove('limit-warning');
            }
        });
        
        /**
         * 폼 제출 전 검증
         */
        function validateForm() {
            const rating = parseFloat(ratingSlider.value);
            
            // 별점 검증
            if (isNaN(rating) || rating < 0 || rating > 10) {
                alert('별점을 선택해주세요 (0.0 ~ 10.0)');
                return false;
            }
            
            // 리뷰 텍스트 길이 검증 (500자 초과 방지)
            const experience = textarea.value.trim();
            if (experience.length > 500) {
                alert('리뷰는 최대 500자까지 작성 가능합니다.');
                return false;
            }
            
            // 제출 확인
            const confirmed = confirm(
                '별점: ' + rating + '점\n\n' +
                '위 내용으로 리뷰를 제출하시겠습니까?'
            );
            
            return confirmed;
        }
        
        /**
         * 페이지 로드 시 초기화
         */
        window.addEventListener('DOMContentLoaded', function() {
            // 초기 별점 표시
            ratingValue.textContent = parseFloat(ratingSlider.value).toFixed(1);
            
            // 초기 글자 수 표시
            charCount.textContent = textarea.value.length;
        });
    </script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

</body>
</html>
