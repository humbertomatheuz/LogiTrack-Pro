package com.logitrack.service;

import com.logitrack.dto.ManutencaoDTO;
import com.logitrack.model.Manutencao;
import com.logitrack.model.Veiculo;
import com.logitrack.repository.ManutencaoRepository;
import com.logitrack.repository.VeiculoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ManutencaoService {

    @Autowired
    private ManutencaoRepository manutencaoRepository;

    @Autowired
    private VeiculoRepository veiculoRepository;

    public List<ManutencaoDTO> listarTodas() {
        return manutencaoRepository.findAll().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public ManutencaoDTO criar(ManutencaoDTO dto) {
        validaIntegridadeTemporal(dto.getDataInicio(), dto.getDataFinalizacao());
        
        Veiculo veiculo = veiculoRepository.findById(dto.getVeiculoId())
                .orElseThrow(() -> new IllegalArgumentException("Veículo com ID " + dto.getVeiculoId() + " não encontrado."));

        if ("EM_REALIZACAO".equals(dto.getStatus())) {
            if (manutencaoRepository.existsByVeiculoIdAndStatus(veiculo.getId(), "EM_REALIZACAO")) {
                throw new IllegalArgumentException("O veículo já possui uma manutenção EM_REALIZACAO.");
            }
        }

        Manutencao manutencao = new Manutencao();
        manutencao.setVeiculo(veiculo);
        manutencao.setDataInicio(dto.getDataInicio());
        manutencao.setDataFinalizacao(dto.getDataFinalizacao());
        manutencao.setTipoServico(dto.getTipoServico());
        manutencao.setCustoEstimado(dto.getCustoEstimado());
        
        // RN: Status padrao PENDENTE
        if (dto.getStatus() != null && !dto.getStatus().isEmpty()) {
            manutencao.setStatus(dto.getStatus());
        } else {
            manutencao.setStatus("PENDENTE");
        }

        manutencao = manutencaoRepository.save(manutencao);
        return toDTO(manutencao);
    }

    @Transactional
    public ManutencaoDTO atualizar(Long id, ManutencaoDTO dto) {
        validaIntegridadeTemporal(dto.getDataInicio(), dto.getDataFinalizacao());

        Manutencao manutencao = manutencaoRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Manutenção não encontrada."));

        Veiculo veiculo = veiculoRepository.findById(dto.getVeiculoId())
                .orElseThrow(() -> new IllegalArgumentException("Veículo com ID " + dto.getVeiculoId() + " não encontrado."));

        if ("EM_REALIZACAO".equals(dto.getStatus())) {
            if (manutencaoRepository.existsByVeiculoIdAndStatusAndIdNot(veiculo.getId(), "EM_REALIZACAO", id)) {
                throw new IllegalArgumentException("O veículo já possui uma manutenção EM_REALIZACAO.");
            }
        }

        manutencao.setVeiculo(veiculo);
        manutencao.setDataInicio(dto.getDataInicio());
        manutencao.setDataFinalizacao(dto.getDataFinalizacao());
        manutencao.setTipoServico(dto.getTipoServico());
        manutencao.setCustoEstimado(dto.getCustoEstimado());
        if (dto.getStatus() != null && !dto.getStatus().isEmpty()) {
            manutencao.setStatus(dto.getStatus());
        }

        manutencao = manutencaoRepository.save(manutencao);
        return toDTO(manutencao);
    }

    @Transactional
    public void deletar(Long id) {
        if (!manutencaoRepository.existsById(id)) {
            throw new IllegalArgumentException("Manutenção não encontrada.");
        }
        manutencaoRepository.deleteById(id);
    }

    private void validaIntegridadeTemporal(LocalDate dataInicio, LocalDate dataFinalizacao) {
        if (dataInicio != null && dataFinalizacao != null && dataFinalizacao.isBefore(dataInicio)) {
            throw new IllegalArgumentException("A data de finalização não pode ser anterior à data de início."); // HTTP 400 expected
        }
    }

    private ManutencaoDTO toDTO(Manutencao m) {
        ManutencaoDTO dto = new ManutencaoDTO();
        dto.setId(m.getId());
        dto.setVeiculoId(m.getVeiculo().getId());
        dto.setDataInicio(m.getDataInicio());
        dto.setDataFinalizacao(m.getDataFinalizacao());
        dto.setTipoServico(m.getTipoServico());
        dto.setCustoEstimado(m.getCustoEstimado());
        dto.setStatus(m.getStatus());
        return dto;
    }
}
