# 🎯 MySQL Workbench로 바로 실행하기

**현재 상태**: MySQL Workbench 설치 완료! ✅

---

## 📋 3단계로 완성

### 1단계: MySQL Workbench에서 데이터베이스 설정 (2분)

#### Workbench 실행 및 연결
1. **MySQL Workbench 8.0 실행**
2. **"Local instance"** 또는 **"localhost"** 연결 클릭
3. **Root 비밀번호** 입력 (설치 시 설정한 비밀번호)

#### 데이터베이스 생성 스크립트 실행
1. Workbench 상단 메뉴: **File → Open SQL Script...** (또는 `Ctrl+O`)
2. 다음 파일 선택:
   ```
   C:\Users\김재환\Desktop\Latelocean\Latelocean\setup-database.sql
   ```
3. **Execute** 버튼 클릭 (번개 아이콘 ⚡ 또는 `Ctrl+Shift+Enter`)
4. "Action Output"에 성공 메시지 확인

#### 덤프 파일 복원
1. 다시 **File → Open SQL Script...** (또는 `Ctrl+O`)
2. 다음 파일 선택:
   ```
   C:\program\sanaidump.sql
   ```
3. **Execute** 버튼 클릭 (번개 아이콘 ⚡)
4. 완료까지 기다리기 (수 초 소요)

#### 확인
- 좌측 **Schemas** 패널 새로고침 (🔄 아이콘)
- **sanai** 데이터베이스 확장
- **Tables** 확장하여 테이블 목록 확인 (accounts, users, contracts 등)

---

### 2단계: localhost로 설정 변경 (10초)

프로젝트 폴더에서 실행:

```batch
update-db-config.bat
```

또는 PowerShell에서:
```powershell
.\update-db-config.bat
```

---

### 3단계: 서버 시작! (20초)

```batch
start.bat
```

그 다음 브라우저에서:
```
http://localhost:9999/ratelocean/
```

---

## 🚀 완전 자동 (Workbench에서 스크립트 실행 후)

```batch
update-db-config.bat
start.bat
```

---

## 💡 빠른 참고

### SQL 스크립트 내용 (수동 실행)

Workbench Query 창에 직접 입력해도 됩니다:

```sql
-- 데이터베이스 생성
CREATE DATABASE IF NOT EXISTS sanai 
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

-- 사용자 생성
CREATE USER IF NOT EXISTS 'remote_user'@'localhost' 
  IDENTIFIED BY '0000';

-- 권한 부여
GRANT ALL PRIVILEGES ON sanai.* 
  TO 'remote_user'@'localhost';

FLUSH PRIVILEGES;
```

### 덤프 파일 위치
```
C:\program\sanaidump.sql
```

### 확인 쿼리
```sql
USE sanai;
SHOW TABLES;
```

---

## 🐛 문제 해결

### Workbench에서 localhost에 연결 안 될 때
```
- MySQL Server가 설치되어 있는지 확인
- Services.msc에서 MySQL 서비스 실행 확인
- 또는: MySQL Installer로 MySQL Server 추가 설치
```

### Root 비밀번호를 모를 때
```
설치 시 설정한 비밀번호를 사용
보통: root, admin, 또는 빈 비밀번호
```

### 덤프 파일 실행 시 오류
```
1. 먼저 sanai 데이터베이스 생성 확인
2. USE sanai; 실행
3. 덤프 파일 다시 실행
```

---

## 📂 파일 위치 요약

| 파일 | 위치 |
|------|------|
| 데이터베이스 생성 스크립트 | `setup-database.sql` (프로젝트 폴더) |
| 덤프 파일 | `C:\program\sanaidump.sql` |
| 설정 변경 | `update-db-config.bat` (프로젝트 폴더) |
| 서버 시작 | `start.bat` (프로젝트 폴더) |

---

**Workbench에서 스크립트 2개만 실행하면 끝!** 🎉
