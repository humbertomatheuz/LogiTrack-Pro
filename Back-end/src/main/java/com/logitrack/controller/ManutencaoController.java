package com.logitrack.controller;

import com.logitrack.dto.ManutencaoDTO;
import com.logitrack.service.ManutencaoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

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
