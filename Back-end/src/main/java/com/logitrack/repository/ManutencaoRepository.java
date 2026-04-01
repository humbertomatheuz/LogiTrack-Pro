package com.logitrack.repository;

import com.logitrack.model.Manutencao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ManutencaoRepository extends JpaRepository<Manutencao, Long> {
    boolean existsByVeiculoIdAndStatus(Long veiculoId, String status);
    
    boolean existsByVeiculoIdAndStatusAndIdNot(Long veiculoId, String status, Long id);
}
