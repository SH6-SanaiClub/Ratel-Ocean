package com.sanaiclub.contract.service;


import com.sanaiclub.contract.model.ContractProjectEntity;
import com.sanaiclub.contract.model.ContractFreelancerEntity;
import com.sanaiclub.contract.dao.ContractProjectDao;
import com.sanaiclub.contract.dao.ContractFreelancerDao;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.sanaiclub.contract.model.ContractProjectVO;
import com.sanaiclub.contract.model.ContractFreelancerVO;
import java.util.List;
import java.util.ArrayList;

@Service
public class ContractService {
	private final ContractProjectDao contractProjectDao;
	private final ContractFreelancerDao contractFreelancerDao;

	@Autowired
	public ContractService(ContractProjectDao contractProjectDao, ContractFreelancerDao contractFreelancerDao) {
		this.contractProjectDao = contractProjectDao;
		this.contractFreelancerDao = contractFreelancerDao;
	}

	// 클라이언트별 프로젝트 목록 조회
	public java.util.List<ContractProjectVO> getProjectsByClientId(Long clientId) {
		// 실제 DB 쿼리 대신 VO 변환 예시
		List<ContractProjectEntity> entities = contractProjectDao.findByClientId(clientId);
		List<ContractProjectVO> voList = new java.util.ArrayList<>();
		for (ContractProjectEntity e : entities) {
			ContractProjectVO vo = new ContractProjectVO();
			vo.setId(e.getId());
			vo.setName(e.getName());
			vo.setDescription(e.getDescription());
			vo.setDuration(e.getDuration());
			vo.setBudget(Long.valueOf(String.valueOf(e.getBudget())));
			// vo.setStatus(e.getStatus()); // 주석 처리: Entity에 getStatus()가 없으므로 오류 방지
			voList.add(vo);
		}
		return voList;
	}

	// 프로젝트별 지원 프리랜서 목록 조회
	public java.util.List<ContractFreelancerVO> getFreelancersByProjectId(Long projectId) {
		List<ContractFreelancerEntity> entities = contractFreelancerDao.findByProjectId(projectId);
		List<ContractFreelancerVO> voList = new java.util.ArrayList<>();
		for (ContractFreelancerEntity e : entities) {
			ContractFreelancerVO vo = new ContractFreelancerVO();
			vo.setId(e.getId());
			vo.setName(e.getName());
			vo.setEmail(e.getEmail());
			vo.setPhone(e.getPhone());
			vo.setCareer(e.getCareer());
			voList.add(vo);
		}
		return voList;
	}

	// DB에서 프로젝트 정보 조회
	public ContractProjectEntity getProjectById(Long id) { return contractProjectDao.findById(id); }

	// DB에서 프리랜서 정보 조회
	public ContractFreelancerEntity getFreelancerById(Long id) { return contractFreelancerDao.findById(id); }
}
