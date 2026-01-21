package com.sanaiclub.contract.service;


import com.sanaiclub.contract.model.ContractFreelancerVO;
import com.sanaiclub.contract.model.ContractProjectVO;
import com.sanaiclub.contract.model.ContractClientVO;
import com.sanaiclub.contract.model.ContractFreelancerEntity;
import com.sanaiclub.contract.dao.ContractProjectDao;
import com.sanaiclub.contract.dao.ContractFreelancerDao;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
// ...existing code...
import java.util.List;
import java.util.ArrayList;

@Service
public class ContractService {
	private final ContractProjectDao contractProjectDao;
	private final ContractFreelancerDao contractFreelancerDao;
	// 예시: 클라이언트 정보 DAO (실제 구현에 맞게 수정 필요)
	private final com.sanaiclub.contract.dao.ContractClientDao contractClientDao;

	@Autowired
	public ContractService(ContractProjectDao contractProjectDao, ContractFreelancerDao contractFreelancerDao, com.sanaiclub.contract.dao.ContractClientDao contractClientDao) {
		this.contractProjectDao = contractProjectDao;
		this.contractFreelancerDao = contractFreelancerDao;
		this.contractClientDao = contractClientDao;
	}
	// 프로젝트 ID로 클라이언트 정보 조회
	// 로그인한 사용자 정보로 클라이언트 정보 조회
	public ContractClientVO getClientByLoginUser() {
		Integer rawId = com.sanaiclub.common.util.AuthContext.getCurrentUserId();
		if (rawId == null) return null;
		Long loginUserId = rawId.longValue();
		return contractClientDao.findByUserId(loginUserId);
	}

		// 클라이언트별 프로젝트 목록 조회
		public List<ContractProjectVO> getProjectsByClientId(Long clientId) {
			return contractProjectDao.findByClientId(clientId);
		}

		// 프로젝트별 지원 프리랜서 목록 조회
		public List<ContractFreelancerVO> getFreelancersByProjectId(Long projectId) {
			return contractFreelancerDao.findByProjectId(projectId);
		}

	// DB에서 프로젝트 정보 조회
	public ContractProjectVO getProjectById(Long id) { return contractProjectDao.findById(id); }

	// DB에서 프리랜서 정보 조회
	public ContractFreelancerVO getFreelancerById(Long id) { return contractFreelancerDao.findById(id); }
}
