<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div id="completedCenterPanel" class="card" style="display:none;">
    <div class="panel-header-column">
        <div style="display:flex; justify-content:space-between; align-items:center;">
            <span>프로젝트 리뷰</span>
            <span class="status-tag tag-completed">완료됨</span>
        </div>
        <div style="font-size:15px; color:#333; margin-top:8px; font-weight:700;" id="reviewProjectTitle"></div>
        <div style="font-size:12px; color:#888; margin-top:4px;">
            수행 기간: <span id="reviewPeriod"></span>
        </div>
    </div>

    <div class="scroll-container">
        <div id="reviewEmptyState" style="text-align:center; padding-top:100px; color:#ccc;">
            <i class="fa-solid fa-star" style="font-size:48px; margin-bottom:15px;"></i>
            <p>프로젝트를 선택하여<br>리뷰를 작성해주세요.</p>
        </div>

        <div id="reviewFormSection" style="display:none;">
            <div class="review-freelancer-info" style="background:#f9f9f9; padding:15px; border-radius:8px; margin-bottom:20px; display:flex; align-items:center; gap:10px;">
                <div class="detail-img-icon" style="width:50px; height:50px; font-size:24px; margin:0;"><i class="fa-solid fa-user"></i></div>
                <div>
                    <div style="font-weight:700; font-size:14px;" id="centerFreelancerName">-</div>
                </div>
            </div>

            <div class="review-section">
                <label class="review-label">만족도를 평가해주세요</label>

                <div class="star-rating">
                    <input type="radio" id="star5" name="rating" value="5"><label for="star5" title="5점"><i class="fa-solid fa-star"></i></label>
                    <input type="radio" id="star4" name="rating" value="4"><label for="star4" title="4점"><i class="fa-solid fa-star"></i></label>
                    <input type="radio" id="star3" name="rating" value="3"><label for="star3" title="3점"><i class="fa-solid fa-star"></i></label>
                    <input type="radio" id="star2" name="rating" value="2"><label for="star2" title="2점"><i class="fa-solid fa-star"></i></label>
                    <input type="radio" id="star1" name="rating" value="1"><label for="star1" title="1점"><i class="fa-solid fa-star"></i></label>
                </div>
                <div id="ratingValue" style="text-align:center; font-weight:bold; color:#FFBD2E; margin-bottom:10px; font-size:18px;">0점</div>
            </div>

            <div class="review-section" style="border:none;">
                <label class="review-label">상세 의견</label>
                <textarea id="reviewComment" class="review-textarea" placeholder="프리랜서와의 협업 경험을 솔직하게 남겨주세요."></textarea>
            </div>

            <button class="btn-new-project" style="width:100%; justify-content:center; margin-top:10px;" onclick="submitReview()">
                리뷰 등록하기
            </button>
        </div>
    </div>
</div>

<div id="completedRightPanel" class="card" style="display:none; background:#fdfdfd;">
    <div class="panel-header-text">재계약 의사</div>
    <div class="scroll-container">
        <div id="recontractEmptyState" style="text-align:center; padding-top:100px; color:#ccc;">
            <i class="fa-regular fa-handshake" style="font-size:48px; margin-bottom:15px;"></i>
            <p>프로젝트를<br>선택해주세요.</p>
        </div>

        <div id="recontractFormSection" style="display:none;">
            <div style="text-align:center; padding:30px 0; border-bottom:1px dashed #eee;">
                <div class="detail-img-icon"><i class="fa-solid fa-user"></i></div>
                <div style="font-size:16px; font-weight:700; margin-top:10px;" id="rightFreelancerName">-</div>
                <div style="font-size:13px; color:#888;">이 프리랜서와 다시 함께하시겠습니까?</div>
            </div>

            <div class="recontract-section" style="padding:20px 0;">
                <div class="radio-group">
                    <label class="radio-box">
                        <input type="radio" name="recontract" value="true">
                        <div class="radio-card">
                            <i class="fa-regular fa-thumbs-up"></i>
                            <span>네, 좋아요</span>
                        </div>
                    </label>
                    <label class="radio-box">
                        <input type="radio" name="recontract" value="false">
                        <div class="radio-card">
                            <i class="fa-regular fa-thumbs-down"></i>
                            <span>아니요</span>
                        </div>
                    </label>
                </div>
            </div>
        </div>
    </div>
</div>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/project/projectReview.css">
<script src="${pageContext.request.contextPath}/resources/js/project/projectReview.js?v=<%=System.currentTimeMillis()%>"></script>