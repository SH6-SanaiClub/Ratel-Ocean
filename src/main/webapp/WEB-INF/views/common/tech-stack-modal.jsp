<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- 
═══════════════════════════════════════════════════════════════════════
기술 스택 선택 모달 (공통 컴포넌트)
═══════════════════════════════════════════════════════════════════════

[사용법]
1. JSP 파일에 include:
   (예시) include file="/WEB-INF/views/common/tech-stack-modal.jsp"

2. JavaScript에서 모달 열기:
   openTechStackModal(callback);

3. 콜백 함수로 선택된 데이터 받기:
   function callback(selectedAreas, selectedStacks) {
       console.log('개발 영역:', selectedAreas);  // [{id, name}, ...]
       console.log('기술 스택:', selectedStacks);  // [{id, name}, ...]
   }

[특징]
- 개발 영역 (복수 선택 가능, 필수)
- 기술 스택 (복수 선택 가능, 선택사항)
- 알파벳 필터, 검색 기능
- 재사용 가능한 모달 형식

[의존성]
- jQuery
- 기존 client_con_second.jsp 스타일과 동일
-->

<style>
    /* ═══════════════════════════════════════════════════════════════════════
       모달 오버레이 및 컨테이너
       ═══════════════════════════════════════════════════════════════════════ */
    
    .tech-stack-modal-overlay {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.5);
        z-index: 9998;
        animation: fadeIn 0.2s ease;
    }
    
    .tech-stack-modal-overlay.active {
        display: flex;
        justify-content: center;
        align-items: center;
    }
    
    @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
    }
    
    .tech-stack-modal {
        background: white;
        border-radius: 12px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
        width: 90%;
        max-width: 900px;
        max-height: 90vh;
        overflow-y: auto;
        padding: 2rem;
        animation: slideUp 0.3s ease;
        position: relative;
        z-index: 9999;
    }
    
    @keyframes slideUp {
        from {
            opacity: 0;
            transform: translateY(30px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    
    .modal-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 2rem;
        padding-bottom: 1rem;
        border-bottom: 2px solid #94D9DB;
    }
    
    .modal-title {
        font-size: 1.5rem;
        font-weight: 700;
        color: #2B2B2B;
    }
    
    .modal-close-btn {
        background: none;
        border: none;
        font-size: 1.8rem;
        color: #999;
        cursor: pointer;
        transition: color 0.2s ease;
        width: 36px;
        height: 36px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
    }
    
    .modal-close-btn:hover {
        color: #333;
        background-color: #f0f0f0;
    }
    
    /* ═══════════════════════════════════════════════════════════════════════
       섹션 스타일
       ═══════════════════════════════════════════════════════════════════════ */
    
    .modal-section {
        margin-bottom: 2rem;
    }
    
    .modal-section-title {
        font-size: 1.1rem;
        font-weight: 600;
        color: #2B2B2B;
        margin-bottom: 1rem;
    }
    
    .modal-section-subtitle {
        font-size: 0.9rem;
        color: #666;
        margin-bottom: 0.75rem;
    }
    
    /* ═══════════════════════════════════════════════════════════════════════
       개발 영역 버튼 그리드
       ═══════════════════════════════════════════════════════════════════════ */
    
    .position-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
        gap: 0.75rem;
    }
    
    .position-btn {
        padding: 0.75rem 1rem;
        border: 2px solid #ddd;
        background-color: white;
        color: #666;
        border-radius: 8px;
        font-size: 0.9rem;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s ease;
        text-align: center;
    }
    
    .position-btn:hover {
        border-color: #94D9DB;
        background-color: #f8fdfd;
        transform: translateY(-2px);
        box-shadow: 0 2px 8px rgba(148, 217, 219, 0.2);
    }
    
    .position-btn.selected {
        background: linear-gradient(135deg, #94D9DB 0%, #7cc5c7 100%);
        border-color: #94D9DB;
        color: white;
        font-weight: 600;
        box-shadow: 0 2px 8px rgba(148, 217, 219, 0.3);
    }
    
    .position-btn.selected:hover {
        background: linear-gradient(135deg, #7cc5c7 0%, #6ab5b7 100%);
    }
    
    /* ═══════════════════════════════════════════════════════════════════════
       기술 스택 선택 영역
       ═══════════════════════════════════════════════════════════════════════ */
    
    .selected-tags-area {
        min-height: 50px;
        padding: 0.75rem;
        border: 2px dashed #ddd;
        border-radius: 8px;
        background-color: #f9fafb;
        display: flex;
        flex-wrap: wrap;
        gap: 0.5rem;
        align-items: center;
        margin-bottom: 1rem;
    }
    
    .selected-tags-area.empty {
        justify-content: center;
        align-items: center;
        color: #999;
        font-style: italic;
    }
    
    .tech-tag {
        background: linear-gradient(135deg, #e8f4f5 0%, #d4eef0 100%);
        border: 1.5px solid #94D9DB;
        color: #1F7A8C;
        padding: 6px 12px;
        border-radius: 20px;
        font-weight: 500;
        font-size: 0.875rem;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        box-shadow: 0 1px 3px rgba(31, 122, 140, 0.1);
        transition: all 0.2s ease;
    }
    
    .tech-tag:hover {
        background: linear-gradient(135deg, #d4eef0 0%, #c0e8eb 100%);
        box-shadow: 0 2px 5px rgba(31, 122, 140, 0.15);
    }
    
    .tech-tag-remove {
        color: #1F7A8C;
        font-weight: 700;
        font-size: 1rem;
        cursor: pointer;
        width: 18px;
        height: 18px;
        border-radius: 50%;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        transition: all 0.2s ease;
    }
    
    .tech-tag-remove:hover {
        background-color: #ff6b6b;
        color: white;
        transform: scale(1.15);
    }
    
    /* ═══════════════════════════════════════════════════════════════════════
       검색 및 필터
       ═══════════════════════════════════════════════════════════════════════ */
    
    .search-filter-area {
        display: flex;
        gap: 0.75rem;
        align-items: center;
        margin-bottom: 0.75rem;
    }
    
    .search-input-box {
        flex: 1;
        padding: 0.75rem;
        border: 1px solid #ddd;
        border-radius: 6px;
        font-size: 0.9rem;
        font-family: inherit;
        transition: border-color 0.2s ease;
    }
    
    .search-input-box:focus {
        outline: none;
        border-color: #94D9DB;
        box-shadow: 0 0 0 3px rgba(148, 217, 219, 0.1);
    }
    
    .alphabet-filters {
        display: flex;
        gap: 0.25rem;
        flex-wrap: wrap;
        margin-bottom: 0.75rem;
    }
    
    .alphabet-btn {
        width: 32px;
        height: 32px;
        border: 1px solid #ddd;
        background-color: white;
        color: #666;
        border-radius: 6px;
        font-size: 0.85rem;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s ease;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    .alphabet-btn:hover {
        border-color: #94D9DB;
        background-color: #e8f4f5;
        color: #1F7A8C;
    }
    
    .alphabet-btn.active {
        background-color: #94D9DB;
        border-color: #94D9DB;
        color: white;
    }
    
    .alphabet-btn.all {
        width: auto;
        padding: 0 0.75rem;
    }
    
    /* ═══════════════════════════════════════════════════════════════════════
       기술 스택 그리드
       ═══════════════════════════════════════════════════════════════════════ */
    
    .tech-items-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
        gap: 0.5rem;
        max-height: 300px;
        overflow-y: auto;
        padding: 0.75rem;
        border: 1px solid #ddd;
        border-radius: 6px;
        background-color: white;
    }
    
    .tech-item {
        padding: 0.5rem 0.75rem;
        border: 1px solid #ddd;
        background-color: white;
        color: #666;
        border-radius: 6px;
        font-size: 0.85rem;
        cursor: pointer;
        transition: all 0.2s ease;
        text-align: center;
    }
    
    .tech-item:hover {
        border-color: #94D9DB;
        background-color: #f8fdfd;
        color: #1F7A8C;
    }
    
    .tech-item.selected {
        background-color: #94D9DB;
        border-color: #1F7A8C;
        color: white;
        font-weight: 600;
    }
    
    .tech-item.selected:hover {
        background-color: #7ac5c8;
        border-color: #1F7A8C;
    }
    
    .tech-item.hidden {
        display: none;
    }
    
    /* ═══════════════════════════════════════════════════════════════════════
       모달 푸터 버튼
       ═══════════════════════════════════════════════════════════════════════ */
    
    .modal-footer {
        display: flex;
        gap: 1rem;
        justify-content: flex-end;
        margin-top: 2rem;
        padding-top: 1.5rem;
        border-top: 1px solid #e5e7eb;
    }
    
    .modal-btn {
        padding: 0.75rem 1.5rem;
        border: none;
        border-radius: 6px;
        font-size: 1rem;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s ease;
    }
    
    .modal-btn-cancel {
        background: white;
        color: #666;
        border: 1px solid #ddd;
    }
    
    .modal-btn-cancel:hover {
        background: #f9f9f9;
        border-color: #999;
    }
    
    .modal-btn-confirm {
        background: linear-gradient(135deg, #94D9DB 0%, #7cc5c7 100%);
        color: white;
    }
    
    .modal-btn-confirm:hover {
        background: linear-gradient(135deg, #7cc5c7 0%, #6ab5b7 100%);
        transform: translateY(-2px);
        box-shadow: 0 2px 8px rgba(148, 217, 219, 0.3);
    }
</style>

<!-- 모달 HTML -->
<div class="tech-stack-modal-overlay" id="techStackModalOverlay">
    <div class="tech-stack-modal" id="techStackModal">
        <!-- 헤더 -->
        <div class="modal-header">
            <h2 class="modal-title">개발 영역 및 기술 스택 선택</h2>
            <button type="button" class="modal-close-btn" onclick="closeTechStackModal()">&times;</button>
        </div>
        
        <!-- 레벨 정의 섹션 (안내) -->
        <div class="modal-section" style="background-color: #e8f4f5; border-left: 4px solid #1F7A8C; border-radius: 4px; padding: 1rem; margin-bottom: 1.5rem;">
            <h3 class="modal-section-title" style="margin-top: 0; color: #1F7A8C;">📊 기술 레벨 정의</h3>
            <p class="modal-section-subtitle" style="margin-bottom: 0.8rem;">선택하신 기술의 레벨을 나중에 지정하실 수 있습니다:</p>
            <div style="font-size: 0.9rem; color: #333; line-height: 1.8;">
                <p style="margin: 0.3rem 0;"><strong>Lv.1:</strong> 기본 개념 이해 - 해당 기술의 기본 개념과 용어를 이해하고 있으며, 문서나 예제를 참고하여 간단한 사용이 가능</p>
                <p style="margin: 0.3rem 0;"><strong>Lv.2:</strong> 기본 기능 활용 가능 - 기본적인 기능을 활용하여 단순한 작업을 수행할 수 있으며, 참고 자료를 통해 기능 구현 가능</p>
                <p style="margin: 0.3rem 0;"><strong>Lv.3:</strong> 실무 활용 가능 - 실제 프로젝트에서 독립적으로 기능을 구현할 수 있으며, 일반적인 문제를 스스로 해결 가능</p>
                <p style="margin: 0.3rem 0;"><strong>Lv.4:</strong> 설계 및 개선 가능 - 구조 설계, 성능 개선, 문제 해결을 주도할 수 있으며, 품질과 효율을 고려한 구현 가능</p>
                <p style="margin: 0.3rem 0;"><strong>Lv.5:</strong> 전문가 수준 - 기술 전반에 대한 깊은 이해를 바탕으로 복잡한 문제 해결 및 기술 선택과 표준 수립 주도 가능</p>
            </div>
        </div>
        
        <!-- 개발 영역 섹션 -->
        <div class="modal-section">
            <h3 class="modal-section-title">개발 영역 * (복수 선택 가능)</h3>
            <div class="position-grid" id="modalPositionGrid">
                <!-- JavaScript로 동적 생성 -->
            </div>
            <!-- 선택된 개발 영역 표시 -->
            <div class="selected-tags-area" id="modalSelectedPositionTags" style="margin-top: 1rem;">
                <span style="color: #999;">선택된 개발 영역이 없습니다</span>
            </div>
        </div>
        
        <!-- 기술 스택 섹션 -->
        <div class="modal-section">
            <h3 class="modal-section-title">희망 기술 스택</h3>
            <p class="modal-section-subtitle">사용하고 싶은 기술 스택을 선택하세요. 선택 후 레벨과 경력을 입력할 수 있습니다.</p>
            
            <!-- 선택된 태그 영역 -->
            <div class="selected-tags-area" id="modalSelectedTechTags">
                <span style="color: #999;">선택된 기술 스택이 없습니다</span>
            </div>
            
            <!-- 검색창 -->
            <div class="search-filter-area">
                <input type="text" class="search-input-box" id="modalTechSearch" placeholder="🔍 검색... (예: Java, React, MySQL)">
            </div>
            
            <!-- 알파벳 필터 -->
            <div class="alphabet-filters">
                <button type="button" class="alphabet-btn all active" data-filter="all">전체</button>
                <button type="button" class="alphabet-btn" data-filter="A-C">A-C</button>
                <button type="button" class="alphabet-btn" data-filter="D-F">D-F</button>
                <button type="button" class="alphabet-btn" data-filter="G-I">G-I</button>
                <button type="button" class="alphabet-btn" data-filter="J-L">J-L</button>
                <button type="button" class="alphabet-btn" data-filter="M-O">M-O</button>
                <button type="button" class="alphabet-btn" data-filter="P-R">P-R</button>
                <button type="button" class="alphabet-btn" data-filter="S-U">S-U</button>
                <button type="button" class="alphabet-btn" data-filter="V-Z">V-Z</button>
            </div>
            
            <!-- 기술 스택 그리드 -->
            <div class="tech-items-grid" id="modalTechItemsGrid">
                <!-- JavaScript로 동적 생성 -->
            </div>
        </div>
        
        <!-- 푸터 -->
        <div class="modal-footer">
            <button type="button" class="modal-btn modal-btn-cancel" onclick="closeTechStackModal()">취소</button>
            <button type="button" class="modal-btn modal-btn-confirm" onclick="confirmTechStackSelection()">적용</button>
        </div>
    </div>
</div>

<!-- 기술 스택 모달 JavaScript는 별도의 tech-stack-modal.js 파일에서 로드됩니다 -->
