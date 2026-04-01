package com.logitrack.repository.projection;

public interface VeiculoKmProjection {
    Long getId();
    String getPlaca();
    String getModelo();
    String getTipo();
    Integer getAno();
    Double getKmTotal();
}
