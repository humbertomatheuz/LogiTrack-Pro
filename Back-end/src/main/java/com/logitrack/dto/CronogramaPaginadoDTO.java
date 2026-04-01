package com.logitrack.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CronogramaPaginadoDTO {
    private List<CronogramaManutencaoDTO> content;
    private long totalElements;
    private int currentPage;
    private int pageSize;
    private int totalPages;
    private boolean hasNext;
}
