<template>
  <div class="dashboard-tab-content p-4">
    <h3 class="mb-4">Projeção Financeira</h3>
    
    <!-- Seção de Filtros -->
    <div class="card shadow-sm mb-4">
      <div class="card-body p-3">
        <div class="filters-container">
          <div class="flex-grow-1">
            <label class="form-label small fw-bold text-uppercase">Período de Análise</label>
            <div class="filters-row">
              <div class="flex-fill-robust">
                <label class="field-label">Data Início</label>
                <input 
                  type="date" 
                  v-model="filtros.dataInicio" 
                  class="form-control form-control-sm date-input-ios"
                  @change="validarDatas"
                >
              </div>
              <div class="flex-fill-robust">
                <label class="field-label">Data Fim</label>
                <input 
                  type="date" 
                  v-model="filtros.dataFim" 
                  class="form-control form-control-sm date-input-ios"
                  @change="validarDatas"
                >
              </div>
              <div class="filter-group">
                <button 
                  @click="aplicarFiltro" 
                  :disabled="carregando"
                  class="btn btn-primary btn-sm px-4"
                >
                  <span v-if="!carregando">Filtrar</span>
                  <span v-else>
                    <span class="spinner-border spinner-border-sm me-2"></span>
                    Carregando...
                  </span>
                </button>
              </div>
            </div>
          </div>
          <div v-if="erroValidacao" class="alert alert-warning mb-0 py-2">
            <small>{{ erroValidacao }}</small>
          </div>
        </div>
      </div>
    </div>

    <!-- Relatório Consolidado -->
    <div v-if="!carregando && dados" class="card shadow-sm mb-5">
      <div class="card-header bg-light px-4 py-3">
        <h5 class="mb-0 text-uppercase fw-bold" style="color: #1A237E;">Relatório Consolidado</h5>
      </div>
      <div class="card-body p-4">
        <div class="row">
          <!-- Detalhamento de Gastos (Esquerda) -->
          <div class="col-md-6 d-flex flex-column">
            <!-- Composição de Gastos (Veículo) -->
            <div class="mb-5">
              <h6 class="text-uppercase fw-bold text-muted mb-4">Composição por Tipo de Veículo</h6>
              <div v-if="dados.categorias.length > 0" class="flex-grow-1">
                <div v-for="categoria in dados.categorias" :key="categoria.tipo" class="mb-3">
                  <div class="d-flex justify-content-between align-items-center mb-2">
                    <span class="d-flex align-items-center">
                      <span 
                        :style="{ backgroundColor: obterCorCategoria(categoria.tipo) }"
                        class="me-2 rounded"
                        style="width: 12px; height: 12px;"
                      ></span>
                      <strong>{{ categoria.tipo }}</strong>
                    </span>
                    <strong>{{ formatarMoeda(categoria.custo) }}</strong>
                  </div>
                  <div class="progress" style="height: 6px;">
                    <div 
                      class="progress-bar" 
                      :style="{ 
                        backgroundColor: obterCorCategoria(categoria.tipo),
                        width: calcularPercentagem(categoria.custo) + '%'
                      }"
                    ></div>
                  </div>
                </div>
              </div>
              <div v-else class="text-muted text-center py-4">
                <small>Nenhum dado por categoria</small>
              </div>
            </div>

            <!-- Gastos por Serviço (Módulo Novo) -->
            <div>
              <h6 class="text-uppercase fw-bold text-muted mb-4">Gastos por Tipo de Serviço</h6>
              <div v-if="dados.servicos && dados.servicos.length > 0">
                <div v-for="item in dados.servicos" :key="item.servico" class="mb-3">
                  <div class="d-flex justify-content-between align-items-center mb-2">
                    <span class="d-flex align-items-center">
                      <span 
                        :style="{ backgroundColor: obterCorServico(item.servico) }"
                        class="me-2 rounded-circle"
                        style="width: 10px; height: 10px;"
                      ></span>
                      <span class="small fw-bold">{{ item.servico || 'Outros' }}</span>
                    </span>
                    <span class="small">{{ formatarMoeda(item.custo) }}</span>
                  </div>
                  <div class="progress" style="height: 4px;">
                    <div 
                      class="progress-bar" 
                      :style="{ 
                        backgroundColor: obterCorServico(item.servico),
                        width: calcularPercentagem(item.custo) + '%'
                      }"
                    ></div>
                  </div>
                </div>
              </div>
              <div v-else class="text-muted text-center py-4">
                <small>Nenhum dado por serviço</small>
              </div>
            </div>
          </div>

          <!-- Gráfico de Rosca (Direita) -->
          <div class="col-md-6 d-flex justify-content-center align-items-start pt-3">
            <div v-if="dados.categorias.length > 0" class="chart-wrapper">
              <canvas 
                ref="doughnutCanvas"
                width="900"
                height="900"
                class="responsive-canvas"
              ></canvas>
            </div>
            <div v-else class="text-muted text-center">
              <p>R$ 0,00</p>
              <small>Sem dados para o período</small>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- SEÇÃO CRONOGRAMA DE MANUTENÇÃO INTEGRADAS -->
    <div class="mt-5 border-top pt-5">
      <div class="d-flex justify-content-between align-items-end mb-4">
        <div>
          <h3 class="mb-1">Cronograma de Manutenção</h3>
          <p class="text-muted mb-0" style="font-size: 0.875rem;">
            Visualize todas as manutenções da frota, organizadas por prioridade de status
          </p>
        </div>
      </div>

      <div class="table-container-card">
        <div v-if="maintenanceStore.cronogramaLoading && cronograma.length === 0" class="text-center py-5">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Carregando...</span>
          </div>
        </div>

        <div v-else-if="maintenanceStore.cronogramaError" class="alert alert-danger" role="alert">
          {{ maintenanceStore.cronogramaError }}
        </div>

        <div v-else-if="cronograma.length === 0" class="alert alert-info" role="alert">
          Nenhuma manutenção encontrada.
        </div>

        <div v-else class="table-responsive-sched">
          <table class="sched-table">
            <thead>
              <tr>
                <th class="col-placa">PLACA DO VEÍCULO</th>
                <th class="col-modelo">MODELO</th>
                <th class="col-servico">TIPO DO SERVIÇO</th>
                <th class="col-custo">CUSTO ESTIMADO</th>
                <th class="col-data">DATA INÍCIO</th>
                <th class="col-data">DATA FIM</th>
                <th class="col-status">STATUS</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="manutencao in cronograma" :key="manutencao.id">
                <td class="col-placa">
                  <span class="badge badge-placa">{{ manutencao.placa }}</span>
                </td>
                <td class="col-modelo">{{ manutencao.modelo }}</td>
                <td class="col-servico">{{ manutencao.tipoServico || '—' }}</td>
                <td class="col-custo">{{ formatarCusto(manutencao.custoEstimado) }}</td>
                <td class="col-data">{{ formatarData(manutencao.dataInicio) }}</td>
                <td class="col-data">{{ formatarData(manutencao.dataFinalizacao) }}</td>
                <td class="col-status">
                  <span :class="getStatusBadgeClass(manutencao.status)">
                    {{ formatarStatus(manutencao.status) }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Botão Carregar Mais -->
      <div v-if="cronograma.length > 0" class="text-center mt-4 pb-5">
        <p class="text-muted small mb-3">
          Mostrando {{ cronograma.length }} de {{ maintenanceStore.cronogramaTotalElements }} manutenções pendentes
        </p>
        <button
          v-if="maintenanceStore.cronogramaHasNext"
          class="btn btn-outline-primary"
          :disabled="maintenanceStore.cronogramaLoading"
          @click="carregarMais"
        >
          <span v-if="maintenanceStore.cronogramaLoading" class="spinner-border spinner-border-sm me-2"></span>
          {{ maintenanceStore.cronogramaLoading ? 'Carregando...' : 'Carregar Mais' }}
        </button>
        <p v-else class="text-muted small" style="font-style: italic;">
          Fim da lista
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch, nextTick } from 'vue';
import { useProjecaoFinanceiraStore } from '../../stores/projecaoFinanceira';
import { useMaintenanceStore } from '../../stores/maintenance';

const financeStore = useProjecaoFinanceiraStore();
const maintenanceStore = useMaintenanceStore();
const doughnutCanvas = ref(null);

const filtros = ref({
  dataInicio: '',
  dataFim: ''
});

const carregando = ref(false);
const dados = ref(null);
const erroValidacao = ref('');

// Cores para as categorias
const coresCategoria = {
  'LEVE': '#FFA500',    // Laranja
  'PESADO': '#003366'   // Azul escuro
};

// Cores para os serviços (Paleta mais variada e nomes reais)
const coresServico = {
  'Revisão de Óleo/Filtros': '#4CAF50',
  'Troca de Pneus': '#2196F3',
  'Revisão de Freios': '#F44336',
  'Revisão de Motor': '#9C27B0',
  'Revisão de Suspensão': '#795548',
  'Revisão Elétrica': '#FF9800',
  'Alinhamento/Balanceamento': '#00BCD4'
};

// Inicializa os filtros com o mês atual ao montar o componente
onMounted(async () => {
  financeStore.inicializarFiltrosMesAtual();
  filtros.value.dataInicio = financeStore.filtros.dataInicio;
  filtros.value.dataFim = financeStore.filtros.dataFim;
  
  // Carrega ambos os dados
  await Promise.all([
    aplicarFiltro(),
    maintenanceStore.fetchCronograma()
  ]);
});

// Watch para redraw do canvas quando os dados mudarem
watch(() => dados.value, () => {
  nextTick(() => {
    if (dados.value && dados.value.categorias.length > 0 && doughnutCanvas.value) {
      desenharDoughnut();
    }
  });
}, { deep: true });

function obterCorCategoria(tipo) {
  return coresCategoria[tipo] || '#999999';
}

function obterCorServico(servico) {
  if (!servico) return '#e0e0e0';
  
  // Se está no mapa, retorna a cor fixa
  if (coresServico[servico]) return coresServico[servico];

  // Senão, gera uma cor determinística baseada no nome (hash simples)
  let hash = 0;
  for (let i = 0; i < servico.length; i++) {
    hash = servico.charCodeAt(i) + ((hash << 5) - hash);
  }
  const color = Math.abs(hash).toString(16).substring(0, 6).padStart(6, '0');
  return '#' + color;
}

function formatarMoeda(valor) {
  if (!valor) return 'R$ 0,00';
  const num = parseFloat(valor);
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL'
  }).format(num);
}

function calcularPercentagem(valor) {
  if (!dados.value || !dados.value.totalGeral) return 0;
  const total = parseFloat(dados.value.totalGeral);
  if (total === 0) return 0;
  return ((parseFloat(valor) / total) * 100).toFixed(1);
}

function validarDatas() {
  erroValidacao.value = '';
  
  if (!filtros.value.dataInicio || !filtros.value.dataFim) {
    return;
  }

  const dataInicio = new Date(filtros.value.dataInicio);
  const dataFim = new Date(filtros.value.dataFim);

  if (dataFim < dataInicio) {
    erroValidacao.value = 'A data de fim não pode ser anterior à data de início';
  }
}

async function aplicarFiltro() {
  validarDatas();
  
  if (erroValidacao.value) {
    return;
  }

  carregando.value = true;
  try {
    await financeStore.fetchProjecaoFinanceira(filtros.value.dataInicio, filtros.value.dataFim);
    dados.value = financeStore.dados;
  } catch (error) {
    console.error('Erro ao carregar projeção financeira:', error);
    dados.value = null;
  } finally {
    carregando.value = false;
  }
}

// ── LÓGICA DO CRONOGRAMA ────────────────────────────────

const cronograma = computed(() => maintenanceStore.cronograma);

function formatarData(data) {
  if (!data) return '—'
  const date = new Date(data + 'T00:00:00')
  const dia = String(date.getDate()).padStart(2, '0')
  const mes = String(date.getMonth() + 1).padStart(2, '0')
  const ano = date.getFullYear()
  return `${dia}/${mes}/${ano}`
}

function formatarCusto(valor) {
  if (!valor) return 'R$ 0,00'
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL',
  }).format(valor)
}

function formatarStatus(status) {
  const statusMap = {
    PENDENTE: 'Pendente',
    EM_REALIZACAO: 'Em Realização',
    CONCLUIDA: 'Concluída',
  }
  return statusMap[status] || status
}

function getStatusBadgeClass(status) {
  const classMap = {
    PENDENTE: 'status-badge status-pendente',
    EM_REALIZACAO: 'status-badge status-em-realizacao',
    CONCLUIDA: 'status-badge status-concluida',
  }
  return classMap[status] || 'status-badge'
}

async function carregarMais() {
  await maintenanceStore.carregarMaisCronograma()
}

function desenharDoughnut() {
  if (!doughnutCanvas.value || !dados.value) return;
  
  const canvas = doughnutCanvas.value;
  const ctx = canvas.getContext('2d');
  const centerX = canvas.width / 2;
  const centerY = canvas.height / 2;
  
  // Escala para alta definição (desenhamos no dobro do tamanho visual e deixamos o CSS reduzir)
  const escala = canvas.width / 450;
  
  // Raio do anel interno (Categorias)
  const raioExt1 = 140 * escala;
  const raioInt1 = 100 * escala;
  
  // Raio do anel externo (Serviços)
  const raioExt2 = 180 * escala;
  const raioInt2 = 145 * escala;

  ctx.clearRect(0, 0, canvas.width, canvas.height);
  const total = parseFloat(dados.value.totalGeral);
  if (total === 0) return;

  // 0. DESENHAR TEXTO CENTRAL
  ctx.fillStyle = '#6b7280';
  ctx.font = `bold ${Math.round(11 * escala)}px Arial`;
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  ctx.letterSpacing = '2px';
  ctx.fillText('TOTAL PROJETADO', centerX, centerY - (20 * escala));

  ctx.fillStyle = '#1A237E';
  ctx.font = `800 ${Math.round(28 * escala)}px Arial`;
  ctx.letterSpacing = '0px';
  ctx.fillText(formatarMoeda(dados.value.totalGeral), centerX, centerY + (10 * escala));

  // 1. DESENHAR ANEL INTERNO (Categorias/Veículo)
  let angT1 = -Math.PI / 2;
  dados.value.categorias.forEach(cat => {
    const p = (parseFloat(cat.custo) / total);
    const a = p * 2 * Math.PI;
    
    desenharArco(ctx, centerX, centerY, raioInt1, raioExt1, angT1, angT1 + a, obterCorCategoria(cat.tipo));
    
    // Percentual no anel interno
    const mid = angT1 + a / 2;
    const rT = (raioInt1 + raioExt1) / 2;
    if (p > 0.05) {
      escreverTexto(ctx, (p * 100).toFixed(1) + '%', centerX + rT * Math.cos(mid), centerY + rT * Math.sin(mid), `bold ${Math.round(14 * escala)}px Arial`);
    }
    angT1 += a;
  });

  // 2. DESENHAR ANEL EXTERNO (Serviços)
  let angT2 = -Math.PI / 2;
  dados.value.servicos.forEach(srv => {
    const p = (parseFloat(srv.custo) / total);
    const a = p * 2 * Math.PI;
    
    desenharArco(ctx, centerX, centerY, raioInt2, raioExt2, angT2, angT2 + a, obterCorServico(srv.servico));

    // Percentual no anel externo
    const mid = angT2 + a / 2;
    const rT = (raioInt2 + raioExt2) / 2;
    if (p > 0.04) {
      escreverTexto(ctx, (p * 100).toFixed(1) + '%', centerX + rT * Math.cos(mid), centerY + rT * Math.sin(mid), `bold ${Math.round(11 * escala)}px Arial`);
    }

    angT2 += a;
  });

  // Event Listeners
  canvas.onmousemove = (e) => mostrarTooltip(e, canvas, raioInt1, raioExt1, raioInt2, raioExt2);
  canvas.onmouseleave = () => { canvas.title = ''; };
}

function desenharArco(ctx, x, y, ri, re, as, ae, cor) {
  ctx.beginPath();
  ctx.arc(x, y, re, as, ae);
  ctx.lineTo(x + ri * Math.cos(ae), y + ri * Math.sin(ae));
  ctx.arc(x, y, ri, ae, as, true);
  ctx.closePath();
  ctx.fillStyle = cor;
  ctx.fill();
  ctx.strokeStyle = '#fff';
  ctx.lineWidth = 2;
  ctx.stroke();
}

function escreverTexto(ctx, txt, x, y, font) {
  ctx.fillStyle = '#fff';
  ctx.font = font;
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  ctx.fillText(txt, x, y);
}

function mostrarTooltip(event, canvas, ri1, re1, ri2, re2) {
  if (!dados.value) return;

  const rect = canvas.getBoundingClientRect();
  const x = event.clientX - rect.left;
  const y = event.clientY - rect.top;
  const centerX = canvas.width / 2;
  const centerY = canvas.height / 2;
  const dx = x - centerX;
  const dy = y - centerY;
  const dist = Math.sqrt(dx * dx + dy * dy);
  const total = parseFloat(dados.value.totalGeral);

  // Identifica qual anel
  let lista = null;
  let angBase = -Math.PI / 2;
  let keyProp = '';
  let labelPrefix = '';

  if (dist >= ri1 && dist <= re1) {
    lista = dados.value.categorias;
    keyProp = 'tipo';
  } else if (dist >= ri2 && dist <= re2) {
    lista = dados.value.servicos;
    keyProp = 'servico';
    labelPrefix = 'Serviço: ';
  }

  if (!lista) {
    canvas.title = '';
    canvas.style.cursor = 'default';
    return;
  }

  const angMouse = Math.atan2(dy, dx);
  let encontrado = false;

  for (const item of lista) {
    const angFatia = (parseFloat(item.custo) / total) * 2 * Math.PI;
    const angFim = angBase + angFatia;

    if (estaNoAngulo(angMouse, angBase, angFim)) {
      canvas.style.cursor = 'pointer';
      encontrado = true;
      break;
    }
    angBase = angFim;
  }

  if (!encontrado) {
    canvas.title = '';
    canvas.style.cursor = 'default';
  }
}

function estaNoAngulo(ang, start, end) {
  // Normaliza o ângulo do mouse para o intervalo 0 a 2*PI
  let normalAng = ang < 0 ? ang + 2 * Math.PI : ang;
  
  // Normaliza start/end para o mesmo intervalo
  let normalStart = start;
  while (normalStart < 0) normalStart += 2 * Math.PI;
  while (normalStart >= 2 * Math.PI) normalStart -= 2 * Math.PI;
  
  let normalEnd = end;
  while (normalEnd < 0) normalEnd += 2 * Math.PI;
  while (normalEnd >= 2 * Math.PI) normalEnd -= 2 * Math.PI;

  if (normalStart <= normalEnd) {
    return normalAng >= normalStart && normalAng <= normalEnd;
  } else {
    // Caso a fatia cruze a linha de 0/360 graus
    return normalAng >= normalStart || normalAng <= normalEnd;
  }
}
</script>

<style scoped>
.dashboard-tab-content {
  background: white;
  border-radius: 0 0 12px 12px;
  min-height: 400px;
}

.field-label {
  display: block;
  font-size: 0.65rem;
  font-weight: 700;
  text-transform: uppercase;
  color: #6b7280;
  margin-bottom: 0.4rem;
  letter-spacing: 0.05em;
}

.progress {
  background-color: #f0f0f0;
}

.position-relative {
  position: relative;
}

.position-absolute {
  position: absolute;
}

.top-50 {
  top: 50%;
}

.start-50 {
  left: 50%;
}

.translate-middle {
  transform: translate(-50%, -50%);
}

.responsive-canvas {
  width: 100%;
  height: auto;
  cursor: pointer;
  transition: opacity 0.2s;
}

.chart-wrapper {
  width: 100%;
  max-width: 450px;
  aspect-ratio: 1 / 1;
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
}

canvas:hover {
  opacity: 0.95;
}

.filter-group {
  display: flex;
  flex-direction: column;
  min-width: 100px;
}

.btn-primary {
  background-color: #1A237E;
  border-color: #1A237E;
}

.btn-primary:hover:not(:disabled) {
  background-color: #000051;
  border-color: #000051;
}

.btn-primary:disabled {
  background-color: #b0bec5;
  border-color: #b0bec5;
  cursor: not-allowed;
}

/* ────────────────────────────────────────────────────────
   RESPONSIVIDADE
   ──────────────────────────────────────────────────────── */
.filters-container {
  display: flex;
  gap: 1rem;
  align-items: flex-end;
}

.filters-row {
  display: flex;
  gap: 0.5rem;
  align-items: flex-end;
}

@media (max-width: 768px) {
  .filters-container {
    flex-direction: column;
    align-items: stretch;
  }
  
  .filters-row {
    flex-direction: column;
    align-items: stretch;
  }
  
  .filter-group {
    width: 100%;
    margin-top: 0.5rem;
  }
  
  .filter-group .btn {
    width: 100%;
  }

  .flex-fill-robust {
    width: 100%;
    min-width: 0;
  }
  
  .date-input-ios {
    padding-right: 0.35rem; /* Especial para iPhone */
  }

  .sched-table thead th:nth-child(2),
  .sched-table tbody td:nth-child(2),
  .sched-table thead th:nth-child(4),
  .sched-table tbody td:nth-child(4),
  .sched-table thead th:nth-child(6),
  .sched-table tbody td:nth-child(6) {
    display: none; /* Esconde colunas menos importantes no mobile */
  }
}

/* ────────────────────────────────────────────────────────
   ESTILOS DO CRONOGRAMA
   ──────────────────────────────────────────────────────── */

.table-container-card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.table-responsive-sched {
  max-height: 500px;
  overflow-y: auto;
}

.sched-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.875rem;
}

.sched-table thead {
  background-color: #f8f9fa;
  border-bottom: 2px solid #dee2e6;
  position: sticky;
  top: 0;
  z-index: 10;
}

.sched-table thead th {
  padding: 12px 16px;
  text-align: left;
  font-weight: 600;
  color: #495057;
  text-transform: uppercase;
  font-size: 0.75rem;
  letter-spacing: 0.5px;
  background: #f8f9fa;
}

.sched-table tbody tr {
  border-bottom: 1px solid #dee2e6;
  transition: background-color 0.2s ease;
}

.sched-table tbody tr:hover {
  background-color: #f8f9fa;
}

.sched-table tbody td {
  padding: 12px 16px;
  color: #212529;
}

.col-placa { width: 12%; }
.col-modelo { width: 15%; }
.col-servico { width: 20%; }
.col-custo { width: 12%; text-align: right; }
.col-data { width: 12%; text-align: center; }
.col-status { width: 12%; text-align: center; }

.badge-placa {
  background-color: #e7f3ff;
  color: #0066cc;
  padding: 4px 8px;
  border-radius: 4px;
  font-weight: 600;
  font-size: 0.8rem;
}

.status-badge {
  display: inline-block;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.status-pendente {
  background-color: #fff3cd;
  color: #856404;
}

.status-em-realizacao {
  background-color: #cfe2ff;
  color: #084298;
}

.status-concluida {
  background-color: #d1e7dd;
  color: #0f5132;
}

.btn-outline-primary {
  border: 2px solid #1A237E;
  color: #1A237E;
  background-color: white;
  padding: 8px 24px;
  border-radius: 6px;
  font-weight: 600;
  transition: all 0.3s ease;
}

.btn-outline-primary:hover:not(:disabled) {
  background-color: #1A237E;
  color: white;
}
</style>
