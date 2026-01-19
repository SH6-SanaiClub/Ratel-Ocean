# 정적 리소스 (Images) 저장소

## 📍 위치
```
src/main/webapp/resources/images/
```

## 📂 폴더 구조 및 파일 설명

### 로고 이미지
- **ratelogo.png** - RatelOcean 메인 로고 (PNG 형식)
- **freelancehub-logo.svg** - FreelanceHub 로고 (SVG 형식, 확장성 우수)

### 플레이스홀더 이미지
- **freelancer-placeholder.jpg** - 프리랜서 프로필 기본 이미지
- **client-placeholder.jpg** - 클라이언트/회사 프로필 기본 이미지

### 추가 이미지 (필요 시)
```
images/
├── logo/                 # 로고 파일들
│   ├── ratelogo.png
│   └── freelancehub-logo.svg
├── placeholder/          # 기본 이미지들
│   ├── freelancer-placeholder.jpg
│   └── client-placeholder.jpg
├── icons/                # 아이콘들 (선택)
│   ├── project.svg
│   ├── wallet.svg
│   ├── chat.svg
│   └── user.svg
├── banners/              # 배너 이미지들 (선택)
│   └── hero-banner.jpg
└── screenshots/          # 스크린샷/예제 이미지 (선택)
```

## 🔗 JSP에서 사용하는 방법

### 이미지 태그 (절대 경로 권장)
```jsp
<!-- 로고 -->
<img src="${pageContext.request.contextPath}/resources/images/ratelogo.png" alt="RatelOcean 로고">

<!-- 프로필 플레이스홀더 -->
<img src="${pageContext.request.contextPath}/resources/images/freelancer-placeholder.jpg" alt="프리랜서 프로필">
```

### Spring의 mvc:resources 매핑
servlet-context.xml에서 자동으로 매핑됨:
```xml
<mvc:resources mapping="/resources/**" location="/resources/"/>
```

이를 통해 다음과 같이 접근 가능:
```
URL: http://localhost:9999/ratelocean/resources/images/ratelogo.png
```

## 📝 이미지 추가 가이드

### 1. 이미지 저장
```
1. 파일을 images/ 폴더에 저장
2. 파일명은 소문자 + 하이픈 사용 (예: my-image.png)
3. 최적화된 크기와 포맷 사용
```

### 2. 권장 이미지 포맷
- **로고/아이콘**: SVG (확장성) 또는 PNG (투명도)
- **사진/배경**: JPG (용량 최적화)
- **아이콘 세트**: SVG Sprite 또는 개별 SVG

### 3. 성능 최적화
```
- 이미지 크기 최소화 (압축 도구 사용)
- WebP 형식 고려 (브라우저 지원 확인)
- CDN 배포 검토 (프로덕션)
```

---

**마지막 업데이트**: 2026-01-14
