package com.sanaiclub.contract.service;

import org.springframework.http.ResponseEntity;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.List;

/** 계약서 파일 관리 서비스 인터페이스. 다양한 파일 저장소로 구현체 교체 가능. */
public interface ContractFileService {

    /** PDF 파일 업로드. 파일명에 타임스탬프 추가. 경로: contracts/{clientId}/{projectId}/{freelancerId}/{fileName}. */
    String uploadPdf(MultipartFile contractPdf, Integer clientId, Integer projectId, Integer freelancerId) throws IOException;

    /** PDF 파일 경로 정규화 및 이동. freelancerId가 없으면 추가하고 파일 이동. */
    String normalizeAndMovePdfPath(String originContractUrl, Integer clientId, Integer projectId, Integer freelancerId);

    /** 미확정 PDF 파일 삭제. 확정 시점에 이전 미확정 PDF 정리. */
    void cleanupUnconfirmedPdfs(Integer clientId, Integer projectId, Integer freelancerId, 
                              String currentFileName, List<String> confirmedPdfPaths);

    /** PDF 파일 삭제. 다른 계약에서 사용 중이 아닌 경우만 삭제. */
    boolean deletePdfIfNotUsed(String pdfPath, List<String> confirmedPdfPaths);

    /** PDF 파일 경로에서 File 객체 반환. 상대 경로를 절대 경로로 변환. */
    File getPdfFile(String relativePath);

    /** PDF 파일 존재 여부 확인. */
    boolean existsPdfFile(String relativePath);

    /** PDF 파일 제공. HTTP 응답용. Path Traversal 방지. */
    ResponseEntity<org.springframework.core.io.Resource> servePdfResource(String requestURI);
}
