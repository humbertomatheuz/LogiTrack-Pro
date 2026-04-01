package com.logitrack.repository;

import com.logitrack.model.Viagem;
import com.logitrack.repository.projection.VeiculoKmProjection;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface ViagemRepository extends JpaRepository<Viagem, Long> {

    @Query(value = "SELECT COALESCE(SUM(km_percorrida), 0) FROM viagens", nativeQuery = true)
    Double getKmTotalHistorico();

    @Query(value = "SELECT COALESCE(SUM(v.km_percorrida), 0) FROM viagens v " +
                   "JOIN veiculos ve ON v.veiculo_id = ve.id " +
                   "WHERE (CAST(:veiculoId AS INTEGER) IS NULL OR ve.id = CAST(:veiculoId AS INTEGER)) " +
                   "AND (:tipo IS NULL OR UPPER(ve.tipo) = UPPER(:tipo)) " +
                   "AND (CAST(:dataInicio AS DATE) IS NULL OR v.data_saida >= CAST(:dataInicio AS DATE)) " +
                   "AND (CAST(:dataFim AS DATE) IS NULL OR v.data_chegada <= CAST(:dataFim AS DATE))", 
           nativeQuery = true)
    Double getKmFiltrado(@Param("veiculoId") Long veiculoId,  
                         @Param("tipo") String tipo, 
                         @Param("dataInicio") LocalDate dataInicio, 
                         @Param("dataFim") LocalDate dataFim);

    @Query(value = "SELECT ve.id AS id, ve.placa AS placa, ve.modelo AS modelo, ve.tipo AS tipo, " +
                   "ve.ano AS ano, COALESCE(SUM(v.km_percorrida), 0) AS kmTotal, " +
                   "COUNT(v.id) AS totalViagens " +
                   "FROM veiculos ve " +
                   "LEFT JOIN viagens v ON v.veiculo_id = ve.id " +
                   "AND (CAST(:dataInicio AS DATE) IS NULL OR v.data_saida >= CAST(:dataInicio AS DATE)) " +
                   "AND (CAST(:dataFim AS DATE) IS NULL OR v.data_chegada <= CAST(:dataFim AS DATE)) " +
                   "WHERE (CAST(:veiculoId AS INTEGER) IS NULL OR ve.id = CAST(:veiculoId AS INTEGER)) " +
                   "AND (:tipo IS NULL OR UPPER(ve.tipo) = UPPER(:tipo)) " +
                   "GROUP BY ve.id, ve.placa, ve.modelo, ve.tipo, ve.ano " +
                   "ORDER BY kmTotal DESC",
           countQuery = "SELECT count(ve.id) FROM veiculos ve " +
                        "WHERE (CAST(:veiculoId AS INTEGER) IS NULL OR ve.id = CAST(:veiculoId AS INTEGER)) " +
                        "AND (:tipo IS NULL OR UPPER(ve.tipo) = UPPER(:tipo))",
           nativeQuery = true)
    Page<VeiculoKmProjection> findVeiculosKmPaginado(@Param("veiculoId") Long veiculoId,
                                                     @Param("tipo") String tipo,
                                                     @Param("dataInicio") LocalDate dataInicio,
                                                     @Param("dataFim") LocalDate dataFim,
                                                     Pageable pageable);

    // Endpoint for detailed modal (lazy loaded)
    List<Viagem> findByVeiculoIdOrderByDataSaidaDesc(Long veiculoId);

    // Query para contar viagens por tipo de veículo
    @Query(value = "SELECT COUNT(v.id) FROM viagens v " +
                   "JOIN veiculos ve ON v.veiculo_id = ve.id " +
                   "WHERE UPPER(ve.tipo) = UPPER(:tipo) " +
                   "AND (CAST(:dataInicio AS DATE) IS NULL OR v.data_saida >= CAST(:dataInicio AS DATE)) " +
                   "AND (CAST(:dataFim AS DATE) IS NULL OR v.data_chegada <= CAST(:dataFim AS DATE))",
           nativeQuery = true)
    Long countViagensPorTipo(@Param("tipo") String tipo,
                             @Param("dataInicio") LocalDate dataInicio,
                             @Param("dataFim") LocalDate dataFim);
}
