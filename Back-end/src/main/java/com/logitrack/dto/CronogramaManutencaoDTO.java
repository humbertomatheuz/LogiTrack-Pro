package com.logitrack.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CronogramaManutencaoDTO {
    private Long id;
    private Long veiculoId;
    private String placa;
    private String modelo;
    private LocalDate dataInicio;
    private LocalDate dataFinalizacao;
    private String tipoServico;
    private BigDecimal custoEstimado;
    private String status;
}
