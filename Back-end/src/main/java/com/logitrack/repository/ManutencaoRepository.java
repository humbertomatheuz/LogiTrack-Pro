package com.logitrack.repository;

import com.logitrack.model.Manutencao;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Repository
public interface ManutencaoRepository extends JpaRepository<Manutencao, Long> {
    boolean existsByVeiculoIdAndStatus(Long veiculoId, String status);
    
    boolean existsByVeiculoIdAndStatusAndIdNot(Long veiculoId, String status, Long id);
    
    @Query("SELECT m FROM Manutencao m JOIN FETCH m.veiculo WHERE m.status = 'PENDENTE' ORDER BY m.dataInicio ASC")
    Page<Manutencao> findPendentesCronograma(Pageable pageable);
    
    // Query para buscar TODOS os pendentes ordenados (service faz offset/limit)
    @Query("SELECT m FROM Manutencao m JOIN FETCH m.veiculo WHERE m.status = 'PENDENTE' ORDER BY m.dataInicio ASC")
    List<Manutencao> findAllPendentesCronograma();
    
    // Query para agregação de custos por tipo de veículo no período especificado
    @Query(value = "SELECT v.tipo as tipo, SUM(m.custo_estimado) as custo " +
                   "FROM manutencoes m " +
                   "JOIN veiculos v ON m.veiculo_id = v.id " +
                   "WHERE m.data_inicio >= :dataInicio AND m.data_inicio <= :dataFim " +
                   "GROUP BY v.tipo",
           nativeQuery = true)
    List<Map<String, Object>> findCustosPorTipoNoPeriodo(
            @Param("dataInicio") LocalDate dataInicio,
            @Param("dataFim") LocalDate dataFim);

    // Query para agregação de custos por tipo de serviço no período especificado
    @Query(value = "SELECT m.tipo_servico as servico, SUM(m.custo_estimado) as custo " +
                   "FROM manutencoes m " +
                   "WHERE m.data_inicio >= :dataInicio AND m.data_inicio <= :dataFim " +
                   "GROUP BY m.tipo_servico",
           nativeQuery = true)
    List<Map<String, Object>> findCustosPorServicoNoPeriodo(
            @Param("dataInicio") LocalDate dataInicio,
            @Param("dataFim") LocalDate dataFim);

    // HU06: Cronograma com Paginação e Ordenação via SQL Nativo
    @Query(value = "SELECT m.id, v.id as veiculo_id, v.placa, v.modelo, m.tipo_servico, m.custo_estimado, m.data_inicio, m.data_finalizacao, m.status " +
                   "FROM manutencoes m " +
                   "JOIN veiculos v ON m.veiculo_id = v.id " +
                   "WHERE m.status = 'PENDENTE' " +
                   "ORDER BY m.data_inicio ASC " +
                   "LIMIT :limit OFFSET :offset",
           nativeQuery = true)
    List<Map<String, Object>> findCronogramaPendentesNative(
            @Param("offset") int offset,
            @Param("limit") int limit);

    @Query(value = "SELECT COUNT(*) FROM manutencoes WHERE status = 'PENDENTE'", nativeQuery = true)
    long countPendentesNative();
}
