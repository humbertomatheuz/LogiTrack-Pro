package com.logitrack.service;

import com.logitrack.dto.ManutencaoDTO;
import com.logitrack.dto.CronogramaManutencaoDTO;
import com.logitrack.dto.CronogramaPaginadoDTO;
import com.logitrack.model.Manutencao;
import com.logitrack.model.Veiculo;
import com.logitrack.repository.ManutencaoRepository;
import com.logitrack.repository.VeiculoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class ManutencaoService {

    @Autowired
    private ManutencaoRepository manutencaoRepository;

    @Autowired
    private VeiculoRepository veiculoRepository;

    public List<ManutencaoDTO> listarTodas() {
        List<ManutencaoDTO> manutencoes = manutencaoRepository.findAll().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());

        manutencoes.sort(Comparator.comparing(dto -> {
            switch (dto.getStatus() != null ? dto.getStatus() : "") {
                case "PENDENTE": return 1;
                case "EM_REALIZACAO": return 2;
                case "CONCLUIDA": return 3;
                default: return 4;
            }
        }));

        return manutencoes;
    }

    // HU06: Cronograma - busca manutenções pendentes de forma performática via SQL (JOIN + LIMIT/OFFSET)
    public CronogramaPaginadoDTO buscarCronogramaPendentes(int skip, int limit) {
        // Busca fragmento via SQL Nativo
        List<Map<String, Object>> results = manutencaoRepository.findCronogramaPendentesNative(skip, limit);
        long totalElements = manutencaoRepository.countPendentesNative();
        
        int logicalPage = (int) Math.ceil((double) skip / limit);
        int totalPages = (int) Math.ceil((double) totalElements / limit);
        
        // Converte resultados brutos do mapa SQL para DTOs
        List<CronogramaManutencaoDTO> content = results.stream()
                .map(this::toCronogramaDTOFromMap)
                .collect(Collectors.toList());
        
        CronogramaPaginadoDTO result = new CronogramaPaginadoDTO();
        result.setContent(content);
        result.setTotalElements(totalElements);
        result.setCurrentPage(logicalPage);
        result.setPageSize(limit);
        result.setTotalPages(totalPages);
        result.setHasNext((skip + limit) < totalElements);
        return result;
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

    // Converte para DTO de cronograma com dados do veículo (placa e modelo)
    private CronogramaManutencaoDTO toCronogramaDTO(Manutencao m) {
        CronogramaManutencaoDTO dto = new CronogramaManutencaoDTO();
        dto.setId(m.getId());
        dto.setVeiculoId(m.getVeiculo().getId());
        dto.setPlaca(m.getVeiculo().getPlaca());
        dto.setModelo(m.getVeiculo().getModelo());
        dto.setDataInicio(m.getDataInicio());
        dto.setDataFinalizacao(m.getDataFinalizacao());
        dto.setTipoServico(m.getTipoServico());
        dto.setCustoEstimado(m.getCustoEstimado());
        dto.setStatus(m.getStatus());
        return dto;
    }

    private CronogramaManutencaoDTO toCronogramaDTOFromMap(Map<String, Object> map) {
        CronogramaManutencaoDTO dto = new CronogramaManutencaoDTO();
        dto.setId(((Number) map.get("id")).longValue());
        dto.setVeiculoId(((Number) map.get("veiculo_id")).longValue());
        dto.setPlaca((String) map.get("placa"));
        dto.setModelo((String) map.get("modelo"));
        
        // PostgreSQL Date handling or JDBC Map handling
        Object dStart = map.get("data_inicio");
        if (dStart instanceof java.sql.Date) dto.setDataInicio(((java.sql.Date) dStart).toLocalDate());
        else if (dStart instanceof java.time.LocalDate) dto.setDataInicio((java.time.LocalDate) dStart);

        Object dEnd = map.get("data_finalizacao");
        if (dEnd instanceof java.sql.Date) dto.setDataFinalizacao(((java.sql.Date) dEnd).toLocalDate());
        else if (dEnd instanceof java.time.LocalDate) dto.setDataFinalizacao((java.time.LocalDate) dEnd);

        dto.setTipoServico((String) map.get("tipo_servico"));
        
        Object custo = map.get("custo_estimado");
        if (custo != null) {
            dto.setCustoEstimado(new java.math.BigDecimal(custo.toString()));
        }
        
        dto.setStatus((String) map.get("status"));
        return dto;
    }
}
