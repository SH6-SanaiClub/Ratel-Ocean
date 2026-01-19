# Ratel-Ocean 프로젝트

**프리랜서와 클라이언트를 연결하는 프로젝트 매칭 플랫폼**

---

## 🚀 빠른 시작

### 1️⃣ 서버 시작
```bash
.\scripts\deployment\start.bat
```

### 2️⃣ 접속
- 서버: http://localhost:9999/ratelocean/

### 3️⃣ 서버 종료
```bash
.\scripts\deployment\stop.bat
```

---

## 📂 프로젝트 구조

```
Latelocean/
├── src/                    # 소스 코드
│   ├── main/
│   │   ├── java/          # Java 소스
│   │   ├── resources/     # 설정 파일 (mybatis, spring)
│   │   └── webapp/        # JSP, CSS, JS
│   └── test/              # 테스트 코드
│
├── target/                # Maven 빌드 결과
│   └── ratelocean.war    # 배포용 WAR 파일
│
├── scripts/              # 실행 스크립트
│   ├── deployment/       # start.bat, stop.bat, deploy.bat
│   └── database/         # DB 유틸리티 (Python)
│
├── docs/                 # 참고 문서
├── archive/              # 과거 임시 파일 보관
├── logs/                 # 로그 파일
└── pom.xml               # Maven 설정
```

---

## 🛠️ 기술 스택

- **Java**: OpenJDK 11
- **Framework**: Spring 5.3.33 (MVC)
- **ORM**: MyBatis 3.5.13
- **Database**: MySQL 8.0
- **View**: JSP 2.3 + JSTL
- **Server**: Apache Tomcat 9.0.112 (Port 9999)
- **Build**: Maven 3.x

---

## 🎯 주요 기능

### 1. 프로젝트 추천 큐
- **자동 추천 큐**: AI 기반 매칭 (최대 5개)
- **조건 큐**: 사용자 맞춤 필터 (최대 2개 큐 × 5개 프로젝트)

### 2. 계약 관리
- AI 계약서 분석 (PDF 업로드)
- 계약 리뷰 작성 (클라이언트/프리랜서)
- 마일스톤 관리

### 3. 사용자 관리
- 프리랜서 프로필 (경력, 기술 스택)
- 클라이언트 프로필
- 지갑 시스템

---

## ⚙️ 개발 환경 설정

### MySQL 설정
- Host: `localhost:3306`
- Database: `sanai`
- User: `remote_user`
- Password: `0000`

설정 파일: [src/main/resources/db.properties](src/main/resources/db.properties)

### Tomcat 설정
- 경로: `C:\program\apache-tomcat-9.0.112`
- 포트: `9999`
- Java: `C:\program\jdk-11.0.22+7`

---

## 📖 추가 문서

- 상세 문서: [docs/](docs/) 폴더 참조
- 과거 설치 가이드: [archive/](archive/) 폴더 참조

---

## 🏃 배포 명령어

### 전체 재배포
```bash
.\scripts\deployment\redeploy.bat
```

### 수동 배포
```bash
mvn clean package
.\scripts\deployment\deploy.bat
```

---

**신한DS 금융 SW 아카데미 1차 프로젝트**  
Ratel Ocean Team
