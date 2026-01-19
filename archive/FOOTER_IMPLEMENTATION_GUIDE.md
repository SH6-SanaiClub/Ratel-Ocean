# 📋 공통 하단바 (Footer) 구현 가이드

## 📁 파일 구조

```
src/main/webapp/WEB-INF/views/
├── common/
│   ├── footer.jsp                 ← 공통 하단바 (새로 생성)
│   ├── client_header.jsp          (기존)
│   └── freelancer_header.jsp      (기존)
├── policy/
│   ├── terms.jsp                  ← 이용약관 (새로 생성)
│   └── privacy.jsp                ← 개인정보처리방침 (새로 생성)
├── client_dashboard.jsp           (footer 추가)
└── dashboard.jsp                  (footer 추가)

src/main/java/com/sanaiclub/common/controller/
└── PolicyController.java          ← 정책 페이지 라우팅 (새로 생성)
```

---

## 1️⃣ 공통 하단바 (`footer.jsp`)

### 위치
```
/WEB-INF/views/common/footer.jsp
```

### 주요 특징
- **배경색**: #2B2B2B (헤더와 동일)
- **텍스트**: 밝은 회색 (#b0b0b0)
- **액센트**: #94D9DB (Ratel 브랜드 컬러)
- **최소 구성**: 서비스명, 슬로건, 정책 링크, 저작권만 포함

### 구성 요소

```html
┌─────────────────────────────────┐
│         RATEL OCEAN             │  ← 서비스명 (색상: #94D9DB)
│   계약·정산 기반 협업 플랫폼    │  ← 슬로건
│                                 │
│  이용약관 | 개인정보처리방침    │  ← 정책 링크
│                                 │
│ © 2026 SanaiClub. All reserved. │  ← 저작권
└─────────────────────────────────┘
```

### CSS 클래스

| 클래스 | 설명 |
|--------|------|
| `.site-footer` | 하단바 전체 컨테이너 |
| `.footer-inner` | 하단바 내부 콘텐츠 |
| `.footer-brand` | 서비스명 & 슬로건 영역 |
| `.footer-links` | 정책 링크 영역 |
| `.footer-copyright` | 저작권 영역 |

### 반응형 지원
- **모바일 (768px 이하)**: 간격 축소, 텍스트 크기 조정
- **데스크톱**: 중앙 정렬, 여유로운 간격

---

## 2️⃣ 정책 페이지

### 이용약관 (`policy/terms.jsp`)
- **경로**: `/policy/terms`
- **내용**: 서비스 이용 조건, 회원 의무, 책임 제한 등
- **스타일**: 하양 배경, 읽기 쉬운 구조

### 개인정보처리방침 (`policy/privacy.jsp`)
- **경로**: `/policy/privacy`
- **내용**: 개인정보 수집, 보호, 보유 기간 등
- **스타일**: 이용약관과 동일한 디자인

### 공통 기능
- 뒤로가기 버튼 (`← 돌아가기`)
- 모바일 반응형 지원
- Ratel 브랜드 컬러로 강조

---

## 3️⃣ 대시보드에 Footer 적용

### 클라이언트 대시보드
```html
<!-- 메인 콘텐츠 -->
<div style="...">
    ...
</div>

<!-- 공통 하단바 -->
<%@ include file="/WEB-INF/views/common/footer.jsp" %>

</body>
</html>
```

**파일**: `/WEB-INF/views/client_dashboard.jsp`

### 프리랜서 대시보드
```html
<!-- 2-2️⃣ 메인 콘텐츠 -->
<main>
    ...
</main>

</div>

<!-- 공통 하단바 -->
<%@ include file="/WEB-INF/views/common/footer.jsp" %>

</body>
</html>
```

**파일**: `/WEB-INF/views/dashboard.jsp`

---

## 4️⃣ Controller 라우팅

### PolicyController
```java
@Controller
@RequestMapping("/policy")
public class PolicyController {

    @GetMapping("/terms")
    public String showTerms() {
        return "policy/terms";  // /WEB-INF/views/policy/terms.jsp
    }

    @GetMapping("/privacy")
    public String showPrivacy() {
        return "policy/privacy";  // /WEB-INF/views/policy/privacy.jsp
    }
}
```

**파일**: `src/main/java/com/sanaiclub/common/controller/PolicyController.java`

### 라우팅 규칙
- 기본 URL: `http://서버/ratelocean`
- 이용약관: `/policy/terms`
- 개인정보처리방침: `/policy/privacy`

---

## 5️⃣ 다른 페이지에도 Footer 적용하기

### 모든 페이지의 하단에 이 코드 추가:
```html
<!-- 공통 하단바 -->
<%@ include file="/WEB-INF/views/common/footer.jsp" />
```

### 권장 페이지
- 모든 대시보드 페이지
- 정책 페이지
- 오류 페이지 (에러 페이지)

---

## 6️⃣ 스타일 커스터마이징

### 배경색 변경
```css
.site-footer {
    background-color: #원하는색;
}
```

### 텍스트 색상 변경
```css
.footer-brand .service-name {
    color: #원하는색;  /* 서비스명 */
}

.footer-links a {
    color: #원하는색;  /* 정책 링크 */
}
```

### 여백 조정
```css
.site-footer {
    padding: 3rem 2rem;  /* 변경 가능 */
}

.footer-inner {
    gap: 2rem;  /* 요소 간 간격 */
}
```

---

## 7️⃣ 구현 완료 체크리스트

✅ `footer.jsp` 생성 완료
✅ 정책 페이지 2개 생성 완료 (`terms.jsp`, `privacy.jsp`)
✅ `PolicyController` 생성 완료
✅ 클라이언트 대시보드에 footer 적용 완료
✅ 프리랜서 대시보드에 footer 적용 완료

---

## 📝 학부생 유지보수 가이드

### Q. Footer 색상을 바꾸고 싶으면?
**A.** `footer.jsp`의 `<style>` 섹션에서:
- `background-color: #2B2B2B;` → 원하는 색 변경
- `color: #94D9DB;` → 텍스트 색 변경

### Q. 정책 텍스트를 수정하려면?
**A.** `policy/terms.jsp` 또는 `policy/privacy.jsp`에서 직접 수정

### Q. Footer 링크를 추가하려면?
**A.** `footer-links` 섹션에 `<a>` 태그 추가:
```html
<a href="/path/to/page">페이지명</a>
<span class="separator">|</span>
```

### Q. 다른 페이지에도 Footer를 붙이려면?
**A.** 해당 페이지 `</body>` 바로 위에 삽입:
```html
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
```

---

## 🚀 빌드 및 배포

```bash
# 프로젝트 빌드
mvn clean package -DskipTests

# Tomcat 재배포
# (기존과 동일한 방식으로 WAR 파일 교체 후 재시작)
```

### 테스트 URL
- 클라이언트 대시보드: `http://localhost:9999/ratelocean/client_dashboard`
- 프리랜서 대시보드: `http://localhost:9999/ratelocean/dashboard`
- 이용약관: `http://localhost:9999/ratelocean/policy/terms`
- 개인정보처리방침: `http://localhost:9999/ratelocean/policy/privacy`

---

## 📌 결론

✨ **최소 구성이지만 완성도 높은 공통 하단바 완성!**

- 헤더와 자연스럽게 이어지는 다크 톤
- 학부생도 이해하고 수정할 수 있는 간단한 구조
- 모든 페이지에 재사용 가능한 설계
- 추후 확장도 쉬운 기반

부끄럽지 않은 완성도의 웹 서비스가 되었습니다! 🎉
