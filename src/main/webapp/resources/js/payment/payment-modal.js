/**
 * ============================================================================
 * Payment Modal JavaScript - 포트원 결제 연동
 * ============================================================================
 *
 * [주요 기능]
 * 1. 결제 모달 열기/닫기
 * 2. 포트원 결제창 호출
 * 3. 결제 완료 후 서버 검증
 * 4. 결제 성공/실패 처리
 *
 * [의존성]
 * - jQuery
 * - 포트원 SDK (https://cdn.iamport.kr/v1/iamport.js)
 *
 * ============================================================================
 */

// 전역 변수
let IMP_CODE = 'imp57425168'; // 포트원 식별코드
let currentContractId = null;
let currentContractData = null;

/**
 * ============================================================================
 * 초기화
 * ============================================================================
 */
$(document).ready(function() {
    console.log('[Payment Modal] 초기화 완료');

    // 포트원 SDK 초기화
    if (typeof IMP !== 'undefined') {
        IMP.init(IMP_CODE);
        console.log('[Payment Modal] 포트원 SDK 초기화 완료');
    } else {
        console.error('[Payment Modal] 포트원 SDK를 찾을 수 없습니다.');
    }

    // ESC 키로 모달 닫기
    $(document).on('keydown', function(e) {
        if (e.key === 'Escape') {
            closePaymentModal();
        }
    });

    // 오버레이 클릭 시 모달 닫기
    $('.payment-modal-overlay').on('click', function(e) {
        if (e.target === this) {
            closePaymentModal();
        }
    });
});

/**
 * ============================================================================
 * 결제 모달 열기
 * ============================================================================
 */
function openPaymentModal(contractId, totalBudget, projectTitle, freelancerName) {
    console.log('[Payment Modal] 모달 열기:', { contractId, totalBudget, projectTitle, freelancerName });

    currentContractId = contractId;
    currentContractData = {
        contractId: contractId,
        totalBudget: totalBudget,
        projectTitle: projectTitle || '프로젝트',
        freelancerName: freelancerName || '프리랜서'
    };

    // 모달에 정보 표시
    $('#payment-project-title').text(projectTitle || '-');
    $('#payment-freelancer-name').text(freelancerName || '-');
    $('#payment-contract-id').text('#' + contractId);
    $('#payment-total-amount').text(formatCurrency(totalBudget));

    // 모달 표시
    $('.payment-modal-overlay').addClass('active');
    $('body').css('overflow', 'hidden'); // 배경 스크롤 방지
}

/**
 * ============================================================================
 * 결제 모달 닫기
 * ============================================================================
 */
function closePaymentModal() {
    console.log('[Payment Modal] 모달 닫기');

    $('.payment-modal-overlay').removeClass('active');
    $('body').css('overflow', ''); // 스크롤 복원

    // 데이터 초기화
    currentContractId = null;
    currentContractData = null;
}

/**
 * ============================================================================
 * 결제 시작
 * ============================================================================
 */
function startPayment() {
    console.log('[Payment Modal] 결제 시작');

    if (!currentContractId || !currentContractData) {
        alert('결제 정보를 불러올 수 없습니다.');
        return;
    }

    // 버튼 비활성화 및 로딩 표시
    const $btn = $('#payment-submit-btn');
    $btn.prop('disabled', true);
    $btn.html('<span class="payment-loading-spinner"></span> 결제 준비 중...');

    // 1단계: 서버에서 결제 준비 (merchant_uid 생성)
    preparePayment();
}

/**
 * ============================================================================
 * 서버에 결제 준비 요청 (merchant_uid 생성)
 * ============================================================================
 */
function preparePayment() {
    console.log('[Payment Modal] 서버에 결제 준비 요청');

    const requestData = {
        contractId: currentContractId,
        amount: currentContractData.totalBudget,
        name: currentContractData.projectTitle + ' 계약',
        buyerName: '클라이언트', // 실제 클라이언트명은 서버에서 조회
        buyerEmail: '', // 서버에서 조회
        buyerTel: '' // 서버에서 조회
    };

    $.ajax({
        url: '/payment/prepare',
        method: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(requestData),
        success: function(prepareData) {
            console.log('[Payment Modal] 결제 준비 성공:', prepareData);

            // 2단계: 포트원 결제창 호출
            callPortonePayment(prepareData);
        },
        error: function(xhr, status, error) {
            console.error('[Payment Modal] 결제 준비 실패:', error);
            console.error('[Payment Modal] 서버 응답:', xhr.responseText);

            // 버튼 복원
            const $btn = $('#payment-submit-btn');
            $btn.prop('disabled', false);
            $btn.html('💳 결제하기');

            // 에러 메시지
            let errorMsg = '결제 준비 중 오류가 발생했습니다.';

            if (xhr.status === 404) {
                errorMsg = '결제 API를 찾을 수 없습니다. 서버 설정을 확인해주세요.';
            } else if (xhr.responseJSON && xhr.responseJSON.message) {
                errorMsg = xhr.responseJSON.message;
            } else if (xhr.responseText) {
                try {
                    const errorData = JSON.parse(xhr.responseText);
                    errorMsg = errorData.message || errorMsg;
                } catch (e) {
                    // JSON 파싱 실패 시 기본 메시지 사용
                }
            }

            alert(errorMsg);
        }
    });
}

/**
 * ============================================================================
 * 포트원 결제창 호출
 * ============================================================================
 */
function callPortonePayment(prepareData) {
    console.log('[Payment Modal] 포트원 결제창 호출:', prepareData);

    // 포트원 SDK 사용 가능 여부 확인
    if (typeof IMP === 'undefined') {
        alert('결제 시스템을 초기화할 수 없습니다. 페이지를 새로고침해주세요.');

        const $btn = $('#payment-submit-btn');
        $btn.prop('disabled', false);
        $btn.html('💳 결제하기');
        return;
    }

    // 결제 요청 데이터
    const paymentData = {
        pg: 'html5_inicis', // PG사 (테스트용)
        pay_method: 'card', // 결제 수단
        merchant_uid: prepareData.merchantUid, // 서버에서 생성한 주문번호
        name: prepareData.name, // 상품명
        amount: prepareData.amount, // 결제 금액
        buyer_email: prepareData.buyerEmail || '',
        buyer_name: prepareData.buyerName || '클라이언트',
        buyer_tel: prepareData.buyerTel || '',
        buyer_addr: '',
        buyer_postcode: '',
        m_redirect_url: window.location.origin + '/payment/mobile/callback', // 모바일 리다이렉트 URL
        notice_url: window.location.origin + '/payment/webhook', // 웹훅 URL
        app_scheme: 'ratelapp' // 앱 스킴 (모바일)
    };

    console.log('[Payment Modal] 결제 데이터:', paymentData);

    // 포트원 결제창 호출
    IMP.request_pay(paymentData, function(response) {
        console.log('[Payment Modal] 포트원 응답:', response);

        // 버튼 복원
        const $btn = $('#payment-submit-btn');
        $btn.prop('disabled', false);
        $btn.html('💳 결제하기');

        if (response.success) {
            // 결제 성공 → 서버 검증
            console.log('[Payment Modal] 결제 성공, 서버 검증 시작');
            verifyPayment(response.imp_uid, response.merchant_uid);
        } else {
            // 결제 실패
            console.error('[Payment Modal] 결제 실패:', response.error_msg);
            showPaymentFailModal(response.error_msg || '결제에 실패했습니다.');
        }
    });
}

/**
 * ============================================================================
 * 서버에 결제 완료 검증 요청
 * ============================================================================
 */
function verifyPayment(impUid, merchantUid) {
    console.log('[Payment Modal] 서버 검증 요청:', { impUid, merchantUid });

    // 로딩 모달 표시
    showLoadingModal();

    const requestData = {
        impUid: impUid,
        merchantUid: merchantUid
    };

    $.ajax({
        url: '/payment/complete',
        method: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(requestData),
        success: function(result) {
            console.log('[Payment Modal] 검증 성공:', result);

            // 로딩 모달 숨김
            hideLoadingModal();

            if (result.success) {
                // 결제 성공
                showPaymentSuccessModal(result);
            } else {
                // 검증 실패
                showPaymentFailModal(result.message || '결제 검증에 실패했습니다.');
            }
        },
        error: function(xhr, status, error) {
            console.error('[Payment Modal] 검증 실패:', error);

            // 로딩 모달 숨김
            hideLoadingModal();

            // 에러 메시지
            const errorMsg = xhr.responseJSON?.message || '결제 검증 중 오류가 발생했습니다.';
            showPaymentFailModal(errorMsg);
        }
    });
}

/**
 * ============================================================================
 * 결제 성공 모달 표시
 * ============================================================================
 */
function showPaymentSuccessModal(result) {
    console.log('[Payment Modal] 결제 성공 모달 표시');

    // 기존 모달 닫기
    closePaymentModal();

    // 성공 모달 HTML
    const successHtml = `
        <div class="payment-modal-overlay active" id="payment-success-overlay">
            <div class="payment-modal-container">
                <div class="payment-result-modal">
                    <div class="payment-result-icon">✅</div>
                    <h2 class="payment-result-title">결제가 완료되었습니다!</h2>
                    <p class="payment-result-message">
                        계약이 성공적으로 체결되었습니다.<br>
                        에스크로 시스템에서 안전하게 금액을 보관합니다.
                    </p>
                    <button type="button" class="payment-result-btn" onclick="closeSuccessModalAndReload()">
                        계약 관리로 돌아가기
                    </button>
                </div>
            </div>
        </div>
    `;

    $('body').append(successHtml);
}

/**
 * ============================================================================
 * 결제 실패 모달 표시
 * ============================================================================
 */
function showPaymentFailModal(errorMessage) {
    console.log('[Payment Modal] 결제 실패 모달 표시:', errorMessage);

    // 기존 모달 닫기
    closePaymentModal();

    // 실패 모달 HTML
    const failHtml = `
        <div class="payment-modal-overlay active" id="payment-fail-overlay">
            <div class="payment-modal-container">
                <div class="payment-result-modal">
                    <div class="payment-result-icon">❌</div>
                    <h2 class="payment-result-title">결제에 실패했습니다</h2>
                    <p class="payment-result-message">
                        ${errorMessage}<br>
                        다시 시도해주세요.
                    </p>
                    <button type="button" class="payment-result-btn" onclick="closeFailModalAndRetry()">
                        확인
                    </button>
                </div>
            </div>
        </div>
    `;

    $('body').append(failHtml);
}

/**
 * ============================================================================
 * 로딩 모달 표시/숨김
 * ============================================================================
 */
function showLoadingModal() {
    const loadingHtml = `
        <div class="payment-modal-overlay active" id="payment-loading-overlay">
            <div class="payment-modal-container" style="max-width: 400px;">
                <div class="payment-result-modal">
                    <div class="payment-loading-spinner" style="width: 60px; height: 60px; border-width: 6px; margin: 0 auto 24px;"></div>
                    <h3 style="font-size: 20px; color: #2B2B28; margin: 0;">결제 처리 중...</h3>
                    <p style="font-size: 14px; color: #6B7272; margin: 12px 0 0;">잠시만 기다려주세요.</p>
                </div>
            </div>
        </div>
    `;

    $('body').append(loadingHtml);
}

function hideLoadingModal() {
    $('#payment-loading-overlay').remove();
}

/**
 * ============================================================================
 * 성공 모달 닫기 및 페이지 새로고침
 * ============================================================================
 */
function closeSuccessModalAndReload() {
    $('#payment-success-overlay').remove();
    $('body').css('overflow', '');

    // 페이지 새로고침하여 업데이트된 계약 상태 확인
    window.location.reload();
}

/**
 * ============================================================================
 * 실패 모달 닫기
 * ============================================================================
 */
function closeFailModalAndRetry() {
    $('#payment-fail-overlay').remove();
    $('body').css('overflow', '');
}

/**
 * ============================================================================
 * 유틸리티 함수
 * ============================================================================
 */

/**
 * 통화 포맷팅
 */
function formatCurrency(amount) {
    if (!amount && amount !== 0) return '-';
    return Number(amount).toLocaleString('ko-KR') + '원';
}

/**
 * 날짜 포맷팅
 */
function formatDate(dateString) {
    if (!dateString) return '-';
    const date = new Date(dateString);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}