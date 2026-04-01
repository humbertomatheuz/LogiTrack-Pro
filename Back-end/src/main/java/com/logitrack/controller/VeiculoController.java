package com.logitrack.controller;

import com.logitrack.model.Veiculo;
import com.logitrack.repository.VeiculoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/veiculos")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class VeiculoController {

    @Autowired
    private VeiculoRepository veiculoRepository;

    @Autowired
    private com.logitrack.repository.ViagemRepository viagemRepository;

    @GetMapping
    public List<Veiculo> listarVeiculos() {
        return veiculoRepository.findAll();
    }

    @GetMapping("/{id}/viagens")
    public List<com.logitrack.model.Viagem> getViagensByVeiculo(@PathVariable("id") Long id) {
        return viagemRepository.findByVeiculoIdOrderByDataSaidaDesc(id);
    }
}
