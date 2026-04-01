package com.logitrack.controller;

import com.logitrack.dto.ProjecaoFinanceiraDTO;
import com.logitrack.service.DashboardService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/dashboard")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class DashboardController {

    @Autowired
    private DashboardService dashboardService;

    @GetMapping("/projecao-financeira")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ProjecaoFinanceiraDTO> obterProjecaoFinanceira(
            @RequestParam(required = true) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dataInicio,
            @RequestParam(required = true) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dataFim) {
        
        ProjecaoFinanceiraDTO resultado = dashboardService.obterProjecaoFinanceira(dataInicio, dataFim);
        return ResponseEntity.ok(resultado);
    }
}
