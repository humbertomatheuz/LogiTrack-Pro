package com.logitrack.controller;

import com.logitrack.dto.KmPercorridoResponseDTO;
import com.logitrack.model.Viagem;
import com.logitrack.service.KmPercorridoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/km-percorrido")
@PreAuthorize("hasRole('ADMIN')")
public class KmPercorridoController {

    @Autowired
    private KmPercorridoService kmPercorridoService;

    @GetMapping("/resumo")
    public ResponseEntity<KmPercorridoResponseDTO> obterResumo(
            @RequestParam(required = false) Long veiculoId,
            @RequestParam(required = false) String tipo,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dataInicio,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dataFim,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "kmTotal") String sortCol, // Order by kmTotal by default
            @RequestParam(defaultValue = "DESC") String sortDir
    ) {
        KmPercorridoResponseDTO response = kmPercorridoService.obterResumoKmPercorrido(veiculoId, tipo, dataInicio, dataFim, page, size, sortCol, sortDir);
        return ResponseEntity.ok(response);
    }

    // Lazy load endpoint
    @GetMapping("/veiculo/{veiculoId}/viagens")
    public ResponseEntity<List<Viagem>> listarViagens(@PathVariable Long veiculoId) {
        List<Viagem> viagens = kmPercorridoService.obterViagensPorVeiculo(veiculoId);
        if (viagens.isEmpty()) {
            return ResponseEntity.noContent().build(); // Translates to 204 or can be 200 with empty list to show friendly msg in frontend
        }
        return ResponseEntity.ok(viagens);
    }
}
