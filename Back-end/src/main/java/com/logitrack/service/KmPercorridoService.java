package com.logitrack.service;

import com.logitrack.dto.KmPercorridoResponseDTO;
import com.logitrack.model.Viagem;
import com.logitrack.repository.ViagemRepository;
import com.logitrack.repository.projection.VeiculoKmProjection;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
public class KmPercorridoService {

    @Autowired
    private ViagemRepository viagemRepository;

    public KmPercorridoResponseDTO obterResumoKmPercorrido(Long veiculoId, String tipo, LocalDate dataInicio, LocalDate dataFim, int page, int size, String sortCol, String sortDir) {
        
        Double kmTotalHistorico = viagemRepository.getKmTotalHistorico();
        Double kmFiltrado = viagemRepository.getKmFiltrado(
                veiculoId,
                tipo != null && !tipo.isEmpty() ? tipo : null,
                dataInicio, 
                dataFim
        );

        // Contar viagens por tipo
        Long volumeLeve = viagemRepository.countViagensPorTipo("LEVE", dataInicio, dataFim);
        Long volumePesado = viagemRepository.countViagensPorTipo("PESADO", dataInicio, dataFim);

        Pageable pageable = PageRequest.of(page, size);

        Page<VeiculoKmProjection> grid = viagemRepository.findVeiculosKmPaginado(
                veiculoId,
                tipo != null && !tipo.isEmpty() ? tipo : null,
                dataInicio,
                dataFim,
                pageable
        );

        return new KmPercorridoResponseDTO(kmTotalHistorico, kmFiltrado, volumeLeve, volumePesado, grid);
    }
    
    // Lazy loading for explicit modal demand (HU09)
    public List<Viagem> obterViagensPorVeiculo(Long veiculoId) {
        return viagemRepository.findByVeiculoIdOrderByDataSaidaDesc(veiculoId);
    }
}
