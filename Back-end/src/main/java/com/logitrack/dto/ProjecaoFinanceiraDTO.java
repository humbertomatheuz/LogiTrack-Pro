package com.logitrack.dto;

import java.math.BigDecimal;
import java.util.List;

public class ProjecaoFinanceiraDTO {
    
    private BigDecimal totalGeral;
    private List<CategoriaCustoDTO> categorias;
    private List<ServicoCustoDTO> servicos;

    public ProjecaoFinanceiraDTO(BigDecimal totalGeral, List<CategoriaCustoDTO> categorias, List<ServicoCustoDTO> servicos) {
        this.totalGeral = totalGeral;
        this.categorias = categorias;
        this.servicos = servicos;
    }

    public BigDecimal getTotalGeral() {
        return totalGeral;
    }

    public void setTotalGeral(BigDecimal totalGeral) {
        this.totalGeral = totalGeral;
    }

    public List<ServicoCustoDTO> getServicos() {
        return servicos;
    }

    public void setServicos(List<ServicoCustoDTO> servicos) {
        this.servicos = servicos;
    }

    public List<CategoriaCustoDTO> getCategorias() {
        return categorias;
    }

    public void setCategorias(List<CategoriaCustoDTO> categorias) {
        this.categorias = categorias;
    }

    public static class ServicoCustoDTO {
        private String servico;
        private BigDecimal custo;

        public ServicoCustoDTO(String servico, BigDecimal custo) {
            this.servico = servico;
            this.custo = custo != null ? custo : BigDecimal.ZERO;
        }

        public String getServico() { return servico; }
        public void setServico(String servico) { this.servico = servico; }
        public BigDecimal getCusto() { return custo; }
        public void setCusto(BigDecimal custo) { this.custo = custo; }
    }

    public static class CategoriaCustoDTO {
        private String tipo;
        private BigDecimal custo;

        public CategoriaCustoDTO(String tipo, BigDecimal custo) {
            this.tipo = tipo;
            this.custo = custo != null ? custo : BigDecimal.ZERO;
        }

        public String getTipo() {
            return tipo;
        }

        public void setTipo(String tipo) {
            this.tipo = tipo;
        }

        public BigDecimal getCusto() {
            return custo;
        }

        public void setCusto(BigDecimal custo) {
            this.custo = custo;
        }
    }
}
