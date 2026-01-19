# sanai DB 협업 가이드라인 (Spring Legacy + MyBatis)

> **프로젝트**: RatelOcean (신한DS 금융 SW 아카데미)  
> **DB 호스트**: 김재환 노트북 (MySQL 8.0.33)  
> **목표**: sanai DB에 SELECT 중심으로 안정적인 원격 접속

---

## 📌 DB 접속 정보 (협업자 필독)

```
Host:     192.168.0.56
Port:     3306
Database: sanai
User:     remote_user
Password: 0000
```

---

## ✅ 사전 점검 (협업 시작 전 필수)

### Step 1: CMD에서 MySQL 접속 확인

**MySQL 설치 경로:**
```bash
cd "C:\Program Files\MySQL\MySQL Server 8.0\bin"
```

**접속 테스트:**
```bash
mysql -h 192.168.0.56 -P 3306 -u remote_user -p
```

**SQL 명령 (비밀번호 입력 후):**
```sql
SHOW DATABASES;
USE sanai;
SHOW TABLES;
SELECT NOW();
```

**성공 기준:**
- ✅ `USE sanai;` → "Database changed" 메시지
- ✅ `SHOW TABLES;` → 테이블 목록 출력
- ✅ `SELECT NOW();` → 현재 시간 출력

---

## 🔧 Spring 프로젝트 설정 (이미 완료됨)

### 1️⃣ db.properties 설정 위치
```
src/main/resources/db.properties
```

**파일 내용 (자동 생성됨):**
```properties
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://192.168.0.56:3306/sanai?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true
db.username=remote_user
db.password=0000
```

> **주의사항:**
> - URL에 `allowPublicKeyRetrieval=true` 필수 (MySQL 8.0+ 공개키 인증)
> - `serverTimezone=Asia/Seoul` 설정으로 타임존 자동 매핑
> - 로컬 개발 환경이므로 `useSSL=false` 적용

### 2️⃣ root-context.xml 설정 (src/main/resources/spring/)

**Property Placeholder (필수):**
```xml
<context:property-placeholder location="classpath:db.properties"/>
```

**HikariCP DataSource:**
```xml
<bean id="dataSource" class="com.zaxxer.hikari.HikariDataSource" destroy-method="close">
    <property name="driverClassName" value="${db.driver}"/>
    <property name="jdbcUrl" value="${db.url}"/>
    <property name="username" value="${db.username}"/>
    <property name="password" value="${db.password}"/>
    <property name="maximumPoolSize" value="10"/>
    <property name="minimumIdle" value="5"/>
    <property name="connectionTimeout" value="30000"/>
    <property name="idleTimeout" value="600000"/>
    <property name="maxLifetime" value="1800000"/>
</bean>
```

**SqlSessionFactory (MyBatis):**
```xml
<bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
    <property name="dataSource" ref="dataSource"/>
    <property name="configLocation" value="classpath:mybatis/mybatis-config.xml"/>
    <property name="mapperLocations" value="classpath:mybatis/mappers/**/*.xml"/>
</bean>
```

**SqlSessionTemplate:**
```xml
<bean id="sqlSession" class="org.mybatis.spring.SqlSessionTemplate">
    <constructor-arg ref="sqlSessionFactory"/>
</bean>
```

**MapperScanner:**
```xml
<mybatis-spring:scan base-package="com.sanaiclub"/>
```

---

## 📂 MyBatis 매퍼 파일 구조

```
src/main/resources/mybatis/
├── mybatis-config.xml
└── mappers/
    ├── admin/
    ├── career/
    ├── chat/
    ├── contract/
    ├── project/
    ├── queue/
    ├── stack/
    ├── user/
    └── wallet/
```

**매퍼 파일 작성 규칙:**
- 위치: `src/main/resources/mybatis/mappers/{모듈명}/{FileName}Mapper.xml`
- 네임스페이스: `com.sanaiclub.{모듈명}.mapper.{ClassName}Mapper`

**예시:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
    "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.sanaiclub.user.mapper.UserMapper">
    <select id="selectUserById" parameterType="int" resultType="com.sanaiclub.user.domain.User">
        SELECT * FROM users WHERE user_id = #{userId}
    </select>
</mapper>
```

---

## 💻 Mapper 인터페이스 작성

**위치:** `src/main/java/com/sanaiclub/{모듈명}/mapper/{ClassName}Mapper.java`

```java
package com.sanaiclub.user.mapper;

import com.sanaiclub.user.domain.User;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserMapper {
    User selectUserById(int userId);
}
```

---

## 🚀 빌드 및 실행

### Maven 빌드
```bash
mvn clean package
```

### WAR 파일 배포
1. `target/ratelocean.war` 생성 확인
2. Tomcat 9.x 이상의 `webapps/` 디렉토리에 복사
3. `bin\startup.bat` 실행

### 확인 URL (기본값 기준)
- **홈**: http://localhost:8080/ratelocean/
- **테스트**: http://localhost:8080/ratelocean/test
- **API 테스트**: http://localhost:8080/ratelocean/api/test

---

## 🐛 트러블슈팅

### 1. "Communications link failure" 오류
**원인**: DB 호스트 연결 불가  
**해결책**:
- 🔍 네트워크 확인: `ping 192.168.0.56`
- 🔍 MySQL 접근 가능 여부 확인 (위 "사전 점검" 참고)
- 🔍 방화벽 설정 확인 (포트 3306 열림)

### 2. "Access denied for user" 오류
**원인**: 사용자명/비밀번호 오류  
**해결책**:
- 🔍 db.properties의 db.username / db.password 확인
- 🔍 비밀번호 공백/특수문자 유무 확인

### 3. "No suitable driver found" 오류
**원인**: MySQL JDBC 드라이버 미로드  
**해결책**:
- 🔍 pom.xml에 `mysql-connector-java` 의존성 확인 (기본 설정됨)
- 🔍 `mvn clean package` 재실행

### 4. MyBatis 매퍼 미로드
**원인**: mapperLocations 미설정 또는 경로 오류  
**해결책**:
- 🔍 root-context.xml의 `mapperLocations` 주석 제거 (✅ 이미 완료)
- 🔍 XML 파일 위치: `src/main/resources/mybatis/mappers/**/*.xml`

---

## 📝 주의사항

⚠️ **협업 규칙:**
- ✅ `db.properties`, `root-context.xml` 변경 후 **팀 공유 필수**
- ✅ JSP, Controller는 기존 구조 유지 (선택적 확장만)
- ✅ 매퍼 파일은 **모듈별** 디렉토리에 구성
- ✅ SELECT 위주 작업 (INSERT/UPDATE/DELETE는 DB 소유자 협의)

---

## 📞 문의

- **DB 소유자**: 김재환 (노트북 호스트)
- **기술 스택 문의**: Spring 5.3.33, MyBatis 3.5.13, Tomcat 9.0.112

---

**마지막 업데이트**: 2026-01-14  
**상태**: ✅ 설정 완료, 협업 준비 완료
