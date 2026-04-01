package com.logitrack.controller;

import com.logitrack.dto.ManutencaoDTO;
import com.logitrack.dto.CronogramaManutencaoDTO;
import com.logitrack.dto.CronogramaPaginadoDTO;
import com.logitrack.service.ManutencaoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;

@RestController
@RequestMapping("/api/manutencoes")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class ManutencaoController {

    @Autowired
    private ManutencaoService manutencaoService;

    @GetMapping
    public List<ManutencaoDTO> listar() {
        return manutencaoService.listarTodas();
    }

    // HU06: Endpoint cronograma - retorna manutenções PENDENTES com paginação
    // skip: número de itens a pular (offset)
    // limit: quantos itens retornar (tamanho da página)
    @GetMapping("/cronograma")
    public CronogramaPaginadoDTO obterCronograma(
            @RequestParam(defaultValue = "0") int skip,
            @RequestParam(defaultValue = "10") int limit) {
        return manutencaoService.buscarCronogramaPendentes(skip, limit);
    }

    @PostMapping
    public ResponseEntity<?> criar(@RequestBody ManutencaoDTO dto) {
        try {
            return ResponseEntity.status(HttpStatus.CREATED).body(manutencaoService.criar(dto));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("message", e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> atualizar(@PathVariable Long id, @RequestBody ManutencaoDTO dto) {
        try {
            return ResponseEntity.ok(manutencaoService.atualizar(id, dto));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("message", e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> deletar(@PathVariable Long id) {
        try {
            manutencaoService.deletar(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("message", e.getMessage()));
        }
    }
}
