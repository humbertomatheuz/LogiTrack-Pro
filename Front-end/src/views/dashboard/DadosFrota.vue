<template>
  <div class="dados-frota-wrapper">
    
    <!-- Filters Top Bar -->
    <div class="filters-card">
      <VeiculoAutocomplete
        v-model="store.filters.veiculoId"
        class="km-veiculo-auto"
      />

      <div class="filter-group">
        <label>TIPO</label>
        <div class="input-with-icon">
          <select v-model="store.filters.tipo" class="filter-input padded-right">
            <option value="">Todos os Tipos</option>
            <option value="Leve">Leve</option>
            <option value="Pesado">Pesado</option>
          </select>
          <span class="material-symbols-outlined icon-right">expand_more</span>
        </div>
      </div>

      <!-- Date Range Filter Componentizado -->
      <DateRangeFilter v-model="store.filters" />

      <button class="btn-filtrar" @click="aplicarFiltros">
        <span class="material-symbols-outlined">filter_alt</span>
        Filtrar
      </button>
    </div>

    <!-- Cards Row -->
    <div class="cards-row">
      <!-- Total KM Card -->
      <div class="indicator-card card-total">
        <div class="card-content">
          <h3 class="card-subtitle">KM TOTAL DA FROTA</h3>
          <h2 class="card-value">{{ formatKm(store.kmTotalFrota) }}</h2>
          <p class="card-caption">Kilometragem acumulada histórica</p>
        </div>
        <!-- Abstract visual element on right -->
        <div class="card-graphic">
          <svg width="80" height="100" viewBox="0 0 80 100" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M75 100C75 70 50 60 40 50C30 40 15 30 15 0" stroke="rgba(255,255,255,0.1)" stroke-width="12" stroke-linecap="round"/>
            <path d="M50 100C50 75 35 65 30 50C25 35 10 25 10 0" stroke="rgba(255,255,255,0.05)" stroke-width="12" stroke-linecap="round"/>
            <circle cx="75" cy="85" r="5" fill="rgba(255,255,255,0.2)"/>
            <circle cx="15" cy="15" r="5" fill="rgba(255,255,255,0.2)"/>
          </svg>
        </div>
      </div>

      <!-- Filtered KM Card -->
      <div class="indicator-card card-filtered">
        <h3 class="card-subtitle filtered-subtitle">KM FILTRADO</h3>
        <h2 class="card-value filtered-value">{{ formatKm(store.kmFiltrado) }}</h2>
        <p class="card-caption filtered-caption">Referente ao período selecionado</p>
      </div>

      <!-- Volume Leve Card -->
      <div class="indicator-card card-filtered">
        <h3 class="card-subtitle filtered-subtitle">TOTAL DE VIAGENS VEÍCULOS LEVES</h3>
        <h2 class="card-value filtered-value">{{ store.volumeLeve }}</h2>
        <p class="card-caption filtered-caption">Quantidade de viagens</p>
      </div>

      <!-- Volume Pesado Card -->
      <div class="indicator-card card-filtered">
        <h3 class="card-subtitle filtered-subtitle">TOTAL DE VIAGENS VEÍCULOS PESADOS</h3>
        <h2 class="card-value filtered-value">{{ store.volumePesado }}</h2>
        <p class="card-caption filtered-caption">Quantidade de viagens</p>
      </div>
    </div>

    <!-- Data Table Card -->
    <div class="table-container-card">
      <div class="table-responsive">
        <table class="data-table">
          <thead>
            <tr>
              <th>PLACA</th>
              <th>MODELO</th>
              <th>TIPO</th>
              <th>ANO</th>
              <th>KM TOTAL</th>
              <th>VIAGENS</th>
              <th class="text-right">AÇÕES</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="v in store.veiculos" :key="v.id">
              <td class="col-placa">{{ v.placa }}</td>
              <td class="col-modelo">{{ v.modelo }}</td>
              <td>
                <span class="type-badge" :class="getBadgeClass(v.tipo)">{{ v.tipo }}</span>
              </td>
              <td class="col-ano">{{ v.ano }}</td>
              <td class="col-km">{{ formatNumber(v.kmTotal) }} km</td>
              <td class="col-viagens">{{ v.totalViagens || 0 }}</td>
              <td class="text-right">
                <button class="btn-action" title="Ver Detalhes" @click="openModal(v.id)">
                  <span class="material-symbols-outlined icon-action">visibility</span>
                </button>
              </td>
            </tr>
            <tr v-if="store.veiculos.length === 0">
              <td colspan="7" class="text-center py-4 text-muted">Ainda não há veículos cadastrados ou correspondentes ao filtro.</td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination Footer -->
      <div class="pagination-footer">
        <div class="pagination-info">
          Mostrando {{ store.veiculos.length }} de {{ store.totalElementos }} resultados
        </div>
        <div class="pagination-controls">
          <button class="page-btn page-arrow" :disabled="store.paginaAtual === 1" @click="mudarPagina(store.paginaAtual - 1)">
            <span class="material-symbols-outlined">chevron_left</span>
          </button>
          <button 
            v-for="p in pagesArray" 
            :key="p"
            class="page-btn"
            :class="{ active: store.paginaAtual === p }"
            @click="mudarPagina(p)"
          >
            {{ p }}
          </button>
          <button class="page-btn page-arrow" :disabled="store.paginaAtual === totalPages" @click="mudarPagina(store.paginaAtual + 1)">
            <span class="material-symbols-outlined">chevron_right</span>
          </button>
        </div>
      </div>
    </div>

    <!-- Modal Component -->
    <ViagensModal
      :show="isModalOpen"
      :veiculo-id="modalVeiculoId"
      @update:show="isModalOpen = $event"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useKmStore } from '../../stores/km'
import VeiculoAutocomplete from '../../components/common/VeiculoAutocomplete.vue'
import DateRangeFilter from '../../components/common/DateRangeFilter.vue'
import ViagensModal from '../../components/dashboard/ViagensModal.vue'

const store = useKmStore()

const isModalOpen = ref(false)
const modalVeiculoId = ref(null)

function formatKm(val) {
  if (!val) return '0'
  return val.toLocaleString('pt-BR')
}

function formatNumber(val) {
  if (!val) return '0'
  return Math.round(val).toLocaleString('pt-BR')
}

const totalPages = computed(() => {
  return Math.max(1, Math.ceil(store.totalElementos / store.itemsPorPagina))
})

const pagesArray = computed(() => {
  const tp = totalPages.value
  const current = store.paginaAtual
  let start = Math.max(1, current - 2)
  let end = Math.min(tp, current + 2)
  
  if (tp <= 5) {
    start = 1
    end = tp
  } else {
    if (current <= 3) end = 5
    if (current >= tp - 2) start = tp - 4
  }
  
  const arr = []
  for (let i = start; i <= end; i++) {
    arr.push(i)
  }
  return arr
})

function getBadgeClass(tipo) {
  switch(tipo) {
    case 'Pesado': return 'badge-pesado';
    case 'Leve': return 'badge-leve';
    default: return 'badge-default';
  }
}

async function aplicarFiltros() {
  await store.aplicarFiltros()
}

async function mudarPagina(page) {
  await store.setPagina(page)
}

function openModal(id) {
  modalVeiculoId.value = id
  isModalOpen.value = true
}

onMounted(async () => {
  await store.fetchResumo()
})
</script>

<style scoped>
/* ── Variables & Typography ───────────────────────── */
.dados-frota-wrapper {
  font-family: 'Inter', 'Manrope', -apple-system, sans-serif;
  color: #1a1a2e;
  animation: fadeIn 0.3s ease-out;
}
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(5px); }
  to { opacity: 1; transform: translateY(0); }
}

/* ── Filters Top Bar ──────────────────────────────── */
.km-veiculo-auto {
  margin-bottom: 0 !important;
  flex: 1;
}

.filters-card {
  background: #ffffff;
  border-radius: 8px;
  padding: 1.25rem;
  display: flex;
  align-items: flex-end;
  gap: 1.25rem;
  margin-bottom: 1.5rem;
  box-shadow: 0 1px 3px rgba(0,0,0,0.06);
}
@media (max-width: 768px) {
  .filters-card {
    flex-wrap: wrap;
  }
}

.filter-group {
  display: flex;
  flex-direction: column;
  flex: 1;
}
.filter-group label {
  font-size: 0.65rem;
  font-weight: 700;
  text-transform: uppercase;
  color: #6b7280;
  margin-bottom: 0.4rem;
  letter-spacing: 0.05em;
}

.input-with-icon {
  position: relative;
  display: flex;
  align-items: center;
}
.icon-left {
  position: absolute;
  left: 0.75rem;
  color: #9ca3af;
  font-size: 1.1rem;
  pointer-events: none;
}
.icon-right {
  position: absolute;
  right: 0.75rem;
  color: #9ca3af;
  font-size: 1.1rem;
  pointer-events: none;
}

.filter-input {
  width: 100%;
  background: #f8fafc;
  border: 1px solid #f1f5f9;
  border-radius: 6px;
  padding: 0.6rem 0.75rem;
  font-size: 0.85rem;
  color: #334155;
  outline: none;
  transition: all 0.2s;
  -webkit-appearance: none;
  appearance: none;
}
.filter-input:focus {
  background: #ffffff;
  border-color: #1A237E;
  box-shadow: 0 0 0 2px rgba(26,35,126,0.1);
}
.filter-input.padded-left { padding-left: 2.25rem; }
.filter-input.padded-right { padding-right: 2.25rem; }

.btn-filtrar {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.4rem;
  background: #1A237E;
  color: #fff;
  border: none;
  border-radius: 6px;
  padding: 0.65rem 1.5rem;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  height: 38px;
  transition: background 0.2s;
}
.btn-filtrar:hover {
  background: #11185b;
}
.btn-filtrar .material-symbols-outlined {
  font-size: 1.1rem;
}

/* ── Cards Row ────────────────────────────────────── */
.cards-row {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr 1fr;
  gap: 1.5rem;
  margin: 0 1rem 2rem 1rem;
}
@media (max-width: 1200px) {
  .cards-row { grid-template-columns: 1fr 1fr; }
}
@media (max-width: 768px) {
  .cards-row { grid-template-columns: 1fr; }
}

.indicator-card {
  border-radius: 12px;
  padding: 1.75rem 2rem;
  box-shadow: 0 4px 6px rgba(0,0,0,0.05);
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.card-total {
  background: #1A237E;
  color: #ffffff;
}
.card-filtered {
  background: #ffffff;
  border: 1px solid #e5e7eb;
}

.card-content {
  position: relative;
  z-index: 2;
}
.card-subtitle {
  font-size: 0.7rem;
  font-weight: 700;
  letter-spacing: 0.1em;
  margin: 0 0 0.5rem;
  opacity: 0.85;
}
.filtered-subtitle {
  color: #6b7280;
}
.card-value {
  font-size: 2.75rem;
  font-weight: 700;
  margin: 0 0 0.25rem;
  line-height: 1;
  font-family: 'Manrope', sans-serif;
  letter-spacing: -0.02em;
}
.filtered-value {
  color: #1A237E;
}
.card-caption {
  font-size: 0.75rem;
  margin: 0;
  opacity: 0.75;
}
.filtered-caption {
  color: #6b7280;
}

/* Abstract Graphic */
.card-graphic {
  position: absolute;
  right: 1.5rem;
  bottom: -1rem;
  opacity: 0.6;
  pointer-events: none;
}

/* ── Data Table ───────────────────────────────────── */
.table-container-card {
  background: #ffffff;
  border-radius: 12px;
  border: 1px solid #e5e7eb;
  padding: 1rem 0 0 0;
  box-shadow: 0 2px 4px rgba(0,0,0,0.02);
  overflow: hidden;
}

.table-responsive {
  width: 100%;
  overflow-x: auto;
}

.data-table {
  width: 100%;
  border-collapse: collapse;
}
.data-table th, 
.data-table td {
  padding: 1rem 1.5rem;
  text-align: left;
  border-bottom: 1px solid #f3f4f6;
  vertical-align: middle;
}

.data-table th {
  font-size: 0.7rem;
  font-weight: 700;
  color: #6b7280;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  background: #ffffff;
}
.data-table tbody tr {
  transition: background-color 0.2s;
}
.data-table tbody tr:hover {
  background-color: #f8fafc;
}

.col-placa {
  font-weight: 700;
  color: #1A237E;
  font-size: 0.85rem;
}
.col-modelo {
  font-size: 0.85rem;
  color: #4b5563;
}
.col-ano {
  font-size: 0.85rem;
  color: #4b5563;
}
.col-km {
  font-weight: 700;
  font-size: 0.85rem;
  color: #1f2937;
}
.col-viagens {
  font-weight: 700;
  font-size: 0.85rem;
  color: #1f2937;
}

/* Badges */
.type-badge {
  display: inline-block;
  padding: 0.25rem 0.65rem;
  border-radius: 9999px;
  font-size: 0.7rem;
  font-weight: 600;
  text-align: center;
}
.badge-pesado {
  background: #e0f2fe;
  color: #0369a1;
}
.badge-leve {
  background: #dcfce7;
  color: #15803d;
}
.badge-default {
  background: #f3f4f6;
  color: #374151;
}

.text-right { text-align: right !important; }
.text-center { text-align: center !important; }
.py-4 { padding-top: 2rem; padding-bottom: 2rem; }
.text-muted { color: #9ca3af; }

.btn-action {
  background: none;
  border: none;
  cursor: pointer;
  padding: 0.4rem;
  border-radius: 4px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: #1A237E;
  transition: background 0.2s;
}
.btn-action:hover {
  background: #f1f5f9;
}
.icon-action {
  font-size: 1.1rem;
}

/* ── Pagination ───────────────────────────────────── */
.pagination-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem 1.5rem;
  background: #fafafa;
  border-top: 1px solid #f3f4f6;
}
@media (max-width: 576px) {
  .pagination-footer {
    flex-direction: column;
    gap: 1rem;
    align-items: center;
  }
}

.pagination-info {
  font-size: 0.8rem;
  color: #6b7280;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 0.35rem;
}
.page-btn {
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 600;
  color: #374151;
  cursor: pointer;
  transition: all 0.2s;
}
.page-btn:hover:not(:disabled) {
  background: #f3f4f6;
}
.page-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
.page-btn.active {
  background: #1A237E;
  color: #ffffff;
  border-color: #1A237E;
}
.page-arrow .material-symbols-outlined {
  font-size: 1.1rem;
  color: #9ca3af;
}
.page-arrow:hover:not(:disabled) .material-symbols-outlined {
  color: #374151;
}
</style>
