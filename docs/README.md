# Ratel-Ocean

신한DS 금융 SW 아카데미 6기 4회차 팀 사나이클럽 1차 프로젝트

## 프로젝트 소개

프리랜서와 클라이언트를 연결하는 프로젝트 매칭 플랫폼입니다.

---

## 🚀 빠른 시작

### ⚠️ 처음 실행 시 (로컬 MySQL 설치 필요)

**완전한 로컬 개발 환경 구축**: [로컬개발환경구축가이드.md](로컬개발환경구축가이드.md) | [실행가이드_최종.md](실행가이드_최종.md)

```batch
# 1. MySQL 8.0 설치 (https://dev.mysql.com/downloads/mysql/)
# 2. 데이터베이스 자동 설정
setup-database.bat

# 3. localhost로 변경
update-db-config.bat

# 4. 서버 시작
start.bat
```

### ✅ 환경 구축 완료 후

```batch
# 전체 재배포 및 시작 (권장)
redeploy.bat

# 또는 단계별 실행
start.bat
```

### 접속
```
http://localhost:9999/ratelocean/
```

**📖 자세한 가이드**: [실행준비완료.md](실행준비완료.md) | [QUICK_START_GUIDE.md](QUICK_START_GUIDE.md)

---

## 기술 스택

- **Language**: Java 11
- **Framework**: Spring Framework 5.3.33
- **View**: JSP 2.3 + JSTL
- **Database**: MySQL 8.0
- **ORM**: MyBatis 3.5.13
- **WAS**: Apache Tomcat 9.0.112
- **Connection Pool**: HikariCP 4.0.3
- **Logging**: SLF4J + Logback
- **Build Tool**: Maven 3.x

---

## 실행 스크립트

### 환경 설정
| 스크립트 | 설명 |
|---------|------|
| `setup-environment.bat` | 전체 환경 체크 및 안내 |
| `setup-database.bat` | MySQL DB 자동 생성 및 복원 |
| `update-db-config.bat` | localhost로 자동 변경 |
| `check.bat` | 현재 환경 체크 |

### 서버 실행
| 스크립트 | 설명 |
|---------|------|
| `deploy.bat` | WAR 파일을 Tomcat에 배포 |
| `start.bat` | Tomcat 서버 시작 |
| `stop.bat` | Tomcat 서버 중지 |
| `redeploy.bat` | 전체 재배포 (중지→배포→시작) |

---

## 환경 설정

### 로컬 데이터베이스 (권장)
- **Host**: localhost:3306
- **Database**: sanai (덤프 파일에서 복원)
- **User**: remote_user
- **Password**: 0000
- **덤프 파일**: `C:\program\sanaidump.sql`
- **설정 파일**: `src/main/resources/db.properties`

### 원격 데이터베이스 (선택)
- **Host**: 192.168.0.56:3306
- **Database**: sanai
- **User**: remote_user

### Tomcat
- **위치**: `C:\program\apache-tomcat-9.0.112`
- **포트**: 9999
- **설정**: `C:\program\apache-tomcat-9.0.112\conf\server.xml`

---

## 프로젝트 구조

```
Latelocean/
├── src/main/
│   ├── java/com/sanaiclub/     # Java 소스
│   ├── resources/               # 설정 파일
│   │   ├── db.properties       # DB 설정
│   │   ├── mybatis/            # MyBatis 매퍼
│   │   └── spring/             # Spring 설정
│   └── webapp/                  # 웹 리소스
│       ├── WEB-INF/views/      # JSP 페이지
│       └── resources/          # CSS, JS, 이미지
├── target/
│   └── ratelocean.war          # 빌드된 WAR 파일
├── deploy.bat                   # 배포 스크립트
├── start.bat                    # 시작 스크립트
├── stop.bat                     # 중지 스크립트
└── redeploy.bat                 # 재배포 스크립트
```
