package com.logitrack.service;

import com.logitrack.dto.ProjecaoFinanceiraDTO;
import com.logitrack.repository.ManutencaoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class DashboardService {

    @Autowired
    private ManutencaoRepository manutencaoRepository;

    public ProjecaoFinanceiraDTO obterProjecaoFinanceira(LocalDate dataInicio, LocalDate dataFim) {
        // Busca dados agregados por tipo de veículo no período
        List<Map<String, Object>> resultadosCategorias = manutencaoRepository.findCustosPorTipoNoPeriodo(dataInicio, dataFim);
        // Busca dados agregados por tipo de serviço no período
        List<Map<String, Object>> resultadosServicos = manutencaoRepository.findCustosPorServicoNoPeriodo(dataInicio, dataFim);

        BigDecimal totalGeral = BigDecimal.ZERO;
        List<ProjecaoFinanceiraDTO.CategoriaCustoDTO> categorias = new ArrayList<>();
        List<ProjecaoFinanceiraDTO.ServicoCustoDTO> servicos = new ArrayList<>();

        // Processa categorias (Tipo de Veículo)
        for (Map<String, Object> row : resultadosCategorias) {
            String tipo = (String) row.get("tipo");
            BigDecimal custo = row.get("custo") != null ? new BigDecimal(row.get("custo").toString()) : BigDecimal.ZERO;
            categorias.add(new ProjecaoFinanceiraDTO.CategoriaCustoDTO(tipo, custo));
            totalGeral = totalGeral.add(custo);
        }

        // Processa serviços (Tipo de Serviço)
        for (Map<String, Object> row : resultadosServicos) {
            String servico = (String) row.get("servico");
            BigDecimal custo = row.get("custo") != null ? new BigDecimal(row.get("custo").toString()) : BigDecimal.ZERO;
            servicos.add(new ProjecaoFinanceiraDTO.ServicoCustoDTO(servico, custo));
        }

        return new ProjecaoFinanceiraDTO(totalGeral, categorias, servicos);
    }
}
