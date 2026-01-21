package com.sanaiclub.user.model.dto;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
public class KftcResponseDTO {
    private String rsp_code;        // 응답코드 (A0000: 성공)
    private String rsp_message;     // 응답메시지
    private String bank_code_std;   // 은행코드
    private String account_num;     // 계좌번호
    private String account_holder_name; // 수취인 성명 (실명)
    // ... 필요한 필드 추가
}
