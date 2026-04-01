package com.logitrack.dto;

import com.logitrack.repository.projection.VeiculoKmProjection;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.domain.Page;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class KmPercorridoResponseDTO {
    private Double kmTotalFrota;
    private Double kmFiltrado;
    private Long volumeLeve;
    private Long volumePesado;
    private Page<VeiculoKmProjection> grid;
}
