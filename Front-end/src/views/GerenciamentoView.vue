<template>
  <div class="mgmt-wrapper">
    <!-- ═══════════════ MAIN CONTENT ═══════════════ -->
    <div class="content-grid">

      <!-- ── LEFT COLUMN ─────────────────────────── -->
      <aside class="left-col">

        <!-- Form Card -->
        <div class="card-panel form-card">
          <div class="card-header-row">
            <span class="material-symbols-outlined card-header-icon">add_circle</span>
            <h2 class="card-title">{{ editMode ? 'Editar Ordem de Serviço' : 'Nova Ordem de Serviço' }}</h2>
          </div>

          <form @submit.prevent="handleSubmit" novalidate>

            <!-- Veículo Autocomplete -->
            <VeiculoAutocomplete
              id="veiculo-input"
              v-model="form.veiculoId"
              :error="errors.veiculoId"
              @select="selectVeiculoObj"
            />

            <!-- Datas -->
            <div class="field-row">
              <div class="field-group">
                <label for="dataInicio" class="field-label">Data Início</label>
                <input id="dataInicio" type="date" v-model="form.dataInicio" class="field-input"
                  :class="{ 'field-error': errors.dataInicio }" required />
                <p v-if="errors.dataInicio" class="field-error-msg">{{ errors.dataInicio }}</p>
              </div>
              <div class="field-group">
                <label for="dataFim" class="field-label">Data Fim (Est.)</label>
                <input id="dataFim" type="date" v-model="form.dataFinalizacao" class="field-input"
                  :class="{ 'field-error': errors.dataFinalizacao }" />
                <p v-if="errors.dataFinalizacao" class="field-error-msg">{{ errors.dataFinalizacao }}</p>
              </div>
            </div>

            <!-- Tipo de Serviço -->
            <div class="field-group">
              <label for="tipoServico" class="field-label">Tipo de Serviço</label>
              <div class="select-wrapper">
                <select id="tipoServico" v-model="form.tipoServico" class="field-select"
                  :class="{ 'field-error': errors.tipoServico }" required>
                  <option value="">Selecione o tipo...</option>
                  <option value="Preventiva">Preventiva</option>
                  <option value="Corretiva">Corretiva</option>
                  <option value="Troca de Pneus">Troca de Pneus</option>
                  <option value="Revisão do Motor">Revisão do Motor</option>
                  <option value="Troca de Óleo">Troca de Óleo</option>
                  <option value="Sistema Elétrico">Sistema Elétrico</option>
                  <option value="Freios">Freios</option>
                  <option value="Suspensão">Suspensão</option>
                </select>
                <span class="material-symbols-outlined select-arrow">expand_more</span>
              </div>
              <p v-if="errors.tipoServico" class="field-error-msg">{{ errors.tipoServico }}</p>
            </div>

            <!-- Custo + Status -->
            <div class="field-row">
              <div class="field-group">
                <label for="custo" class="field-label">Custo Estimado (R$)</label>
                <div class="input-prefix-wrapper">
                  <span class="input-prefix">R$</span>
                  <input id="custo" type="number" step="0.01" min="0" v-model="form.custoEstimado"
                    class="field-input field-input--prefixed" :class="{ 'field-error': errors.custoEstimado }"
                    placeholder="0,00" required />
                </div>
                <p v-if="errors.custoEstimado" class="field-error-msg">{{ errors.custoEstimado }}</p>
              </div>
              <div class="field-group">
                <label for="status" class="field-label">Status</label>
                <div class="select-wrapper">
                  <select id="status" v-model="form.status" class="field-select" required>
                    <option value="PENDENTE">PENDENTE</option>
                    <option value="EM_REALIZACAO">EM REALIZAÇÃO</option>
                    <option value="CONCLUIDA">CONCLUÍDA</option>
                  </select>
                  <span class="material-symbols-outlined select-arrow">expand_more</span>
                </div>
              </div>
            </div>

            <!-- Ações do form -->
            <div class="form-actions">
              <button v-if="editMode" type="button" class="btn-cancel" @click="cancelEdit">
                <span class="material-symbols-outlined">close</span>
                Cancelar
              </button>
              <button type="submit" class="btn-submit" :disabled="submitting">
                <span v-if="submitting" class="spinner-sm"></span>
                <span v-else class="material-symbols-outlined">save</span>
                {{ editMode ? 'Atualizar Manutenção' : 'Salvar Manutenção' }}
              </button>
            </div>

          </form>
        </div>
      </aside>

      <!-- ── RIGHT COLUMN ────────────────────────── -->
      <main class="right-col">

        <!-- Active Orders Table -->
        <div class="card-panel table-card">
          <div class="table-header">
            <div class="table-header-left">
              <span class="material-symbols-outlined table-header-icon">checklist</span>
              <h2 class="card-title">Ordens de Serviço Ativas</h2>
            </div>
            <div class="table-header-right">
              <!-- Filter by status -->
              <div class="filter-tabs">
                <button v-for="f in statusFilters" :key="f.value"
                  class="filter-tab" :class="{ 'filter-tab--active': activeFilter === f.value }"
                  @click="activeFilter = f.value">
                  {{ f.label }}
                </button>
              </div>
              <button class="icon-btn" title="Exportar" @click="exportCSV">
                <span class="material-symbols-outlined">download</span>
              </button>
            </div>
          </div>

          <!-- Loading State -->
          <div v-if="store.loading" class="loading-state">
            <div class="loading-spinner"></div>
            <p>Carregando manutenções...</p>
          </div>

          <!-- Empty State -->
          <div v-else-if="filteredManutencoes.length === 0" class="empty-state">
            <span class="material-symbols-outlined empty-icon">build_circle</span>
            <p class="empty-title">Nenhuma manutenção encontrada</p>
            <p class="empty-sub">Cadastre uma nova ordem de serviço no formulário ao lado.</p>
          </div>

          <!-- Table -->
          <div v-else class="table-scroll">
            <table class="mgmt-table">
              <thead>
                <tr>
                  <th>Veículo</th>
                  <th>Serviço</th>
                  <th>Data Início</th>
                  <th>Custo Est.</th>
                  <th>Status</th>
                  <th>Ações</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="m in filteredManutencoes" :key="m.id" class="table-row">
                  <td>
                    <div class="vehicle-cell">
                      <span class="vehicle-placa">{{ getVeiculoPlaca(m.veiculoId) }}</span>
                      <span class="vehicle-model">{{ getVeiculoModelo(m.veiculoId) }}</span>
                    </div>
                  </td>
                  <td>
                    <span class="service-type">{{ m.tipoServico }}</span>
                  </td>
                  <td>
                    <span class="date-cell">{{ formatDate(m.dataInicio) }}</span>
                  </td>
                  <td>
                    <span class="cost-cell">{{ formatCurrency(m.custoEstimado) }}</span>
                  </td>
                  <td>
                    <span class="status-badge" :class="statusClass(m.status)">
                      {{ statusLabel(m.status) }}
                    </span>
                  </td>
                  <td>
                    <div class="action-btns">
                      <button class="action-btn action-btn--edit" @click="startEdit(m)" title="Editar">
                        <span class="material-symbols-outlined">edit_note</span>
                      </button>
                      <!-- RN03: Oculto para OPERADOR -->
                      <button v-if="authStore.isAdmin" class="action-btn action-btn--delete"
                        @click="confirmDelete(m)" title="Excluir">
                        <span class="material-symbols-outlined">delete</span>
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </main>
    </div>


    <!-- ═══════════════ DELETE CONFIRM MODAL ═══════════════ -->
    <div v-if="showDeleteModal" class="modal-overlay" @click.self="showDeleteModal = false">
      <div class="modal-box" role="dialog" aria-modal="true" aria-labelledby="modal-title">
        <div class="modal-icon-wrap modal-icon-wrap--danger">
          <span class="material-symbols-outlined">warning</span>
        </div>
        <h3 id="modal-title" class="modal-title">Confirmar Exclusão</h3>
        <p class="modal-body">
          Tem certeza que deseja excluir a manutenção de
          <strong>{{ pendingDelete?.tipoServico }}</strong> para o veículo
          <strong>{{ getVeiculoPlaca(pendingDelete?.veiculoId) }}</strong>?
          Esta ação não pode ser desfeita.
        </p>
        <div class="modal-actions">
          <button class="btn-cancel" @click="showDeleteModal = false">Cancelar</button>
          <button class="btn-danger" @click="executeDelete" :disabled="deleting">
            <span v-if="deleting" class="spinner-sm"></span>
            <span v-else class="material-symbols-outlined">delete</span>
            Excluir
          </button>
        </div>
      </div>
    </div>

    <!-- ═══════════════ TOAST CONTAINER ═══════════════ -->
    <Teleport to="body">
      <div class="toast-container">
        <TransitionGroup name="toast">
          <div v-for="toast in toasts" :key="toast.id"
            class="toast-item" :class="`toast-item--${toast.type}`">
            <span class="material-symbols-outlined toast-icon">{{ toastIcon(toast.type) }}</span>
            <div class="toast-body">
              <p class="toast-title">{{ toast.title }}</p>
              <p v-if="toast.message" class="toast-message">{{ toast.message }}</p>
            </div>
            <button class="toast-close" @click="removeToast(toast.id)">
              <span class="material-symbols-outlined">close</span>
            </button>
          </div>
        </TransitionGroup>
      </div>
    </Teleport>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import { useMaintenanceStore } from '../stores/maintenance'
import VeiculoAutocomplete from '../components/common/VeiculoAutocomplete.vue'

const authStore = useAuthStore()
const store = useMaintenanceStore()

// ── Form state ───────────────────────────────────────────
const blankForm = () => ({
  veiculoId: '',
  dataInicio: '',
  dataFinalizacao: '',
  tipoServico: '',
  custoEstimado: '',
  status: 'PENDENTE',
})
const form = ref(blankForm())
const errors = ref({})
const editMode = ref(false)
const editId = ref(null)
const submitting = ref(false)

function selectVeiculoObj(v) {
  if (errors.value.veiculoId) delete errors.value.veiculoId
}

// ── Delete ──────────────────────────────────────────────
const showDeleteModal = ref(false)
const pendingDelete = ref(null)
const deleting = ref(false)

// ── Filter ──────────────────────────────────────────────
const activeFilter = ref('ALL')
const statusFilters = [
  { label: 'Todos', value: 'ALL' },
  { label: 'Pendente', value: 'PENDENTE' },
  { label: 'Em Realização', value: 'EM_REALIZACAO' },
  { label: 'Concluída', value: 'CONCLUIDA' },
]

// ── Toasts ──────────────────────────────────────────────
const toasts = ref([])
let toastCounter = 0

function addToast(type, title, message = '') {
  const id = ++toastCounter
  toasts.value.push({ id, type, title, message })
  setTimeout(() => removeToast(id), 5000)
}
function removeToast(id) {
  toasts.value = toasts.value.filter(t => t.id !== id)
}
function toastIcon(type) {
  return { success: 'check_circle', error: 'error', warning: 'warning' }[type] || 'info'
}

// ── Computed ────────────────────────────────────────────
const filteredManutencoes = computed(() => {
  if (activeFilter.value === 'ALL') return store.manutencoes
  return store.manutencoes.filter(m => m.status === activeFilter.value)
})

const upcomingSchedules = computed(() => {
  const today = new Date().toISOString().split('T')[0]
  return store.manutencoes
    .filter(m => m.dataInicio >= today && m.status === 'PENDENTE')
    .sort((a, b) => a.dataInicio.localeCompare(b.dataInicio))
    .slice(0, 4)
})

const gastoMensal = computed(() => {
  const now = new Date()
  return store.manutencoes
    .filter(m => {
      const d = new Date(m.dataInicio)
      return d.getMonth() === now.getMonth() && d.getFullYear() === now.getFullYear()
    })
    .reduce((acc, m) => acc + (Number(m.custoEstimado) || 0), 0)
})

const trendPercent = ref(12)
const trendPositive = ref(true)

// ── Helpers ─────────────────────────────────────────────
function getVeiculoPlaca(id) {
  return store.veiculos.find(v => v.id === id)?.placa || `#${id}`
}
function getVeiculoModelo(id) {
  return store.veiculos.find(v => v.id === id)?.modelo || ''
}
function formatCurrency(val) {
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(val || 0)
}
function formatDate(val) {
  if (!val) return '—'
  const [y, m, d] = val.split('-')
  return `${d}/${m}/${y}`
}
function statusLabel(s) {
  return { PENDENTE: 'PENDENTE', EM_REALIZACAO: 'EM REALIZAÇÃO', CONCLUIDA: 'CONCLUÍDA' }[s] || s
}
function statusClass(s) {
  return {
    PENDENTE: 'badge--pending',
    EM_REALIZACAO: 'badge--active',
    CONCLUIDA: 'badge--done',
  }[s] || ''
}

// ── Validation ───────────────────────────────────────────
function validate() {
  const e = {}
  if (!form.value.veiculoId) e.veiculoId = 'Selecione um veículo.'
  if (!form.value.dataInicio) e.dataInicio = 'Data de início obrigatória.'
  if (!form.value.tipoServico) e.tipoServico = 'Tipo de serviço obrigatório.'
  if (form.value.custoEstimado === '' || form.value.custoEstimado === null) {
    e.custoEstimado = 'Custo estimado obrigatório.'
  } else if (Number(form.value.custoEstimado) < 0) {
    e.custoEstimado = 'O custo não pode ser negativo.'
  }
  // RN01 – Integridade Temporal
  if (form.value.dataFinalizacao && form.value.dataInicio &&
    form.value.dataFinalizacao < form.value.dataInicio) {
    e.dataFinalizacao = 'A data de finalização não pode ser anterior à data de início.'
  }
  errors.value = e
  return Object.keys(e).length === 0
}

// ── Submit ──────────────────────────────────────────────
async function handleSubmit() {
  if (!validate()) return
  submitting.value = true
  const payload = {
    veiculoId: form.value.veiculoId,
    dataInicio: form.value.dataInicio,
    dataFinalizacao: form.value.dataFinalizacao || null,
    tipoServico: form.value.tipoServico,
    custoEstimado: Number(form.value.custoEstimado),
    status: form.value.status,
  }
  try {
    if (editMode.value) {
      await store.updateManutencao(editId.value, payload)
      addToast('success', 'Manutenção atualizada!', 'Os dados foram salvos com sucesso.')
    } else {
      await store.createManutencao(payload)
      addToast('success', 'Manutenção cadastrada!', 'Nova ordem de serviço criada com sucesso.')
    }
    resetForm()
  } catch (err) {
    const msg = err.response?.data?.message || 'Erro interno. Tente novamente.'
    addToast('error', 'Erro ao salvar', msg)
  } finally {
    submitting.value = false
  }
}

function resetForm() {
  form.value = blankForm()
  errors.value = {}
  editMode.value = false
  editId.value = null
}

function startEdit(m) {
  form.value = {
    veiculoId: m.veiculoId,
    dataInicio: m.dataInicio,
    dataFinalizacao: m.dataFinalizacao || '',
    tipoServico: m.tipoServico,
    custoEstimado: m.custoEstimado,
    status: m.status,
  }
  editMode.value = true
  editId.value = m.id
  scrollToForm()
}

function cancelEdit() {
  resetForm()
}

function confirmDelete(m) {
  pendingDelete.value = m
  showDeleteModal.value = true
}

async function executeDelete() {
  deleting.value = true
  try {
    await store.deleteManutencao(pendingDelete.value.id)
    showDeleteModal.value = false
    addToast('success', 'Manutenção excluída!', 'O registro foi removido com sucesso.')
  } catch (err) {
    const msg = err.response?.data?.message || 'Não autorizado ou erro interno.'
    addToast('error', 'Erro ao excluir', msg)
    showDeleteModal.value = false
  } finally {
    deleting.value = false
    pendingDelete.value = null
  }
}

function scrollToForm() {
  document.querySelector('.form-card')?.scrollIntoView({ behavior: 'smooth', block: 'start' })
}

function exportCSV() {
  const headers = ['ID', 'Placa', 'Veículo (Modelo)', 'Serviço', 'Custo Estimado', 'Data Início', 'Data Fim', 'Status']
  const rows = filteredManutencoes.value.map(m => [
    m.id,
    getVeiculoPlaca(m.veiculoId),
    getVeiculoModelo(m.veiculoId),
    m.tipoServico,
    m.custoEstimado,
    m.dataInicio,
    m.dataFinalizacao || '',
    m.status,
  ])
  const csv = [headers, ...rows].map(r => r.join(',')).join('\n')
  const blob = new Blob([csv], { type: 'text/csv' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `manutencoes_${new Date().toISOString().split('T')[0]}.csv`
  a.click()
  URL.revokeObjectURL(url)
}

// ── Init ─────────────────────────────────────────────────
onMounted(async () => {
  await Promise.all([store.fetchManutencoes(), store.fetchVeiculos()])
})
</script>

<style scoped>
/* ══════════════════════════════════════════
   TOKENS
══════════════════════════════════════════ */
:root {
  --primary: #1A237E;
  --primary-light: #3949AB;
  --accent: #2563EB;
  --surface: #f7f8fc;
  --surface-card: #ffffff;
  --border: rgba(0, 0, 0, 0.07);
  --text-main: #1a1a2e;
  --text-muted: #6b7280;
  --text-xs: #9ca3af;
  --success: #16a34a;
  --warning: #d97706;
  --danger: #dc2626;
  --radius-sm: 6px;
  --radius: 12px;
  --radius-lg: 16px;
  --shadow-sm: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04);
  --shadow: 0 4px 16px rgba(0,0,0,0.08), 0 1px 4px rgba(0,0,0,0.04);
  --shadow-lg: 0 12px 40px rgba(0,0,0,0.12), 0 3px 10px rgba(0,0,0,0.06);
}

/* ══════════════════════════════════════════
   WRAPPER
══════════════════════════════════════════ */
.mgmt-wrapper {
  background: #f0f2f8;
  font-family: 'Inter', 'Manrope', sans-serif;
  color: var(--text-main);
}

/* ══════════════════════════════════════════
   BREADCRUMB
══════════════════════════════════════════ */
.breadcrumb-bar {
  background: #ffffff;
  border-bottom: 1px solid var(--border);
  padding: 0.75rem 1.75rem 1rem;
}
.breadcrumb-inner {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.75rem;
  color: var(--text-muted);
  margin-bottom: 0.75rem;
}
.bc-icon { font-size: 0.875rem; }
.bc-sep { color: #d1d5db; }
.bc-item { cursor: default; }
.bc-item--active { color: #1A237E; font-weight: 600; }

.page-title-block {
  display: flex;
  align-items: flex-start;
  gap: 0.875rem;
}
.page-title-icon {
  display: flex; align-items: center; justify-content: center;
  width: 2.5rem; height: 2.5rem; border-radius: 8px;
  background: linear-gradient(135deg, #1A237E, #3949AB);
  color: white; flex-shrink: 0;
}
.page-title-icon .material-symbols-outlined {
  font-size: 1.25rem;
  font-variation-settings: 'FILL' 1;
}
.page-title {
  font-size: 1.125rem;
  font-weight: 700;
  color: #1A237E;
  margin: 0 0 0.25rem;
  font-family: 'Manrope', sans-serif;
}
.page-sub {
  font-size: 0.8rem;
  color: var(--text-muted);
  margin: 0;
  line-height: 1.5;
}
.page-sub strong { color: #1A237E; }

/* ══════════════════════════════════════════
   GRID LAYOUT
══════════════════════════════════════════ */
.content-grid {
  display: grid;
  grid-template-columns: 380px 1fr;
  gap: 1.25rem;
  padding: 1.25rem 1.75rem 2rem;
  max-width: 1400px;
  margin: 0 auto;
}
@media (max-width: 900px) {
  .content-grid { grid-template-columns: 1fr; }
}

.left-col { display: flex; flex-direction: column; gap: 1rem; }
.right-col { display: flex; flex-direction: column; gap: 1rem; }

/* ══════════════════════════════════════════
   CARD PANEL
══════════════════════════════════════════ */
.card-panel {
  background: var(--surface-card);
  border-radius: var(--radius-lg);
  border: 1px solid var(--border);
  box-shadow: var(--shadow-sm);
  padding: 1.25rem;
}

.card-header-row {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1.125rem;
}
.card-header-icon {
  font-size: 1.25rem;
  color: #1A237E;
  font-variation-settings: 'FILL' 1;
}
.card-title {
  font-size: 0.9rem;
  font-weight: 700;
  color: var(--text-main);
  margin: 0;
  font-family: 'Manrope', sans-serif;
}

/* ══════════════════════════════════════════
   FORM
══════════════════════════════════════════ */
.field-group { margin-bottom: 0.9rem; }
.field-row { display: grid; grid-template-columns: 1fr 1fr; gap: 0.75rem; }

.field-label {
  display: block;
  font-size: 0.67rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--text-muted);
  margin-bottom: 0.4rem;
}

.field-input, .field-select {
  width: 100%;
  padding: 0.6rem 0.875rem;
  background: #f7f8fc;
  border: 1.5px solid #e5e7eb;
  border-radius: var(--radius-sm);
  font-size: 0.845rem;
  font-family: inherit;
  color: var(--text-main);
  outline: none;
  transition: border .2s, box-shadow .2s, background .2s;
  -webkit-appearance: none;
  appearance: none;
}
.field-input:focus, .field-select:focus {
  border-color: #1A237E;
  background: #ffffff;
  box-shadow: 0 0 0 3px rgba(26,35,126,0.1);
}
.field-input.field-error, .field-select.field-error {
  border-color: #dc2626;
  box-shadow: 0 0 0 3px rgba(220,38,38,0.08);
}
.field-error-msg {
  font-size: 0.72rem;
  color: #dc2626;
  margin: 0.25rem 0 0;
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.select-wrapper { position: relative; }
.select-arrow {
  position: absolute;
  right: 0.75rem; top: 50%;
  transform: translateY(-50%);
  font-size: 1.1rem;
  color: var(--text-muted);
  pointer-events: none;
}

.input-prefix-wrapper { position: relative; display: flex; align-items: center; }
.input-prefix {
  position: absolute;
  left: 0.875rem;
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--text-muted);
  pointer-events: none;
}
.field-input--prefixed { padding-left: 2.5rem; }

/* ══════════════════════════════════════════
   FORM ACTIONS
══════════════════════════════════════════ */
.form-actions {
  display: flex;
  gap: 0.625rem;
  margin-top: 1.1rem;
}
.btn-submit {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.75rem 1.25rem;
  background: linear-gradient(135deg, #1A237E 0%, #2D3AAF 100%);
  color: white;
  border: none;
  border-radius: var(--radius-sm);
  font-size: 0.845rem;
  font-weight: 700;
  font-family: 'Manrope', sans-serif;
  cursor: pointer;
  box-shadow: 0 6px 20px rgba(26,35,126,.28);
  transition: all .25s ease;
}
.btn-submit:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 28px rgba(26,35,126,.35);
}
.btn-submit:disabled { opacity: .65; cursor: not-allowed; }
.btn-submit .material-symbols-outlined { font-size: 1.1rem; font-variation-settings: 'FILL' 1; }

.btn-cancel {
  display: flex; align-items: center; gap: 0.375rem;
  padding: 0.75rem 1rem;
  background: #f3f4f6;
  border: 1.5px solid #e5e7eb;
  border-radius: var(--radius-sm);
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--text-muted);
  cursor: pointer;
  transition: all .2s;
}
.btn-cancel:hover { background: #e5e7eb; color: var(--text-main); }
.btn-cancel .material-symbols-outlined { font-size: 1rem; }

/* ══════════════════════════════════════════
   COST CARD
══════════════════════════════════════════ */
.cost-card {
  background: linear-gradient(135deg, #1A237E 10%, #2D3AAF 100%);
  border: none;
  padding: 1.25rem;
}
.cost-card-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
}
.cost-label {
  font-size: 0.7rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.12em;
  color: rgba(255,255,255,.65);
  margin: 0 0 0.3rem;
}
.cost-value {
  font-size: 1.6rem;
  font-weight: 800;
  color: #ffffff;
  margin: 0 0 0.5rem;
  font-family: 'Manrope', sans-serif;
  letter-spacing: -0.02em;
}
.cost-trend {
  display: flex;
  align-items: center;
  gap: 0.3rem;
  font-size: 0.75rem;
  font-weight: 600;
  color: rgba(255,255,255,.8);
}
.trend-icon { font-size: 1rem; font-variation-settings: 'FILL' 1; }
.cost-trend--up .trend-icon { color: #4ade80; }
.cost-trend--down .trend-icon { color: #f87171; }

.cost-chart-area { flex-shrink: 0; width: 80px; }
.mini-chart { width: 100%; height: auto; }

/* ══════════════════════════════════════════
   TABLE CARD
══════════════════════════════════════════ */
.table-card { padding: 0; overflow: hidden; }
.table-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1.125rem 1.25rem;
  border-bottom: 1px solid var(--border);
  gap: 1rem;
  flex-wrap: wrap;
}
.table-header-left { display: flex; align-items: center; gap: 0.5rem; }
.table-header-right { display: flex; align-items: center; gap: 0.5rem; }
.table-header-icon {
  font-size: 1.2rem;
  color: #1A237E;
  font-variation-settings: 'FILL' 1;
}

.filter-tabs { display: flex; gap: 0.25rem; }
.filter-tab {
  padding: 0.3rem 0.7rem;
  font-size: 0.72rem;
  font-weight: 600;
  border: 1.5px solid #e5e7eb;
  border-radius: 999px;
  background: transparent;
  color: var(--text-muted);
  cursor: pointer;
  transition: all .2s;
}
.filter-tab:hover { border-color: #1A237E; color: #1A237E; }
.filter-tab--active {
  background: #1A237E;
  color: white;
  border-color: #1A237E;
}

.icon-btn {
  display: flex; align-items: center; justify-content: center;
  width: 2rem; height: 2rem;
  border: 1.5px solid #e5e7eb;
  border-radius: 8px;
  background: transparent;
  color: var(--text-muted);
  cursor: pointer;
  transition: all .2s;
}
.icon-btn:hover { border-color: #1A237E; color: #1A237E; background: rgba(26,35,126,.04); }
.icon-btn .material-symbols-outlined { font-size: 1.1rem; }

.table-scroll { overflow-x: auto; }
.mgmt-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.845rem;
}
.mgmt-table thead tr {
  background: #f8f9fc;
  border-bottom: 1px solid var(--border);
}
.mgmt-table th {
  padding: 0.65rem 1.1rem;
  text-align: left;
  font-size: 0.67rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--text-muted);
  white-space: nowrap;
}
.mgmt-table td {
  padding: 0.85rem 1.1rem;
  border-bottom: 1px solid rgba(0,0,0,0.04);
  vertical-align: middle;
}
.table-row { transition: background .15s; }
.table-row:hover { background: #f8f9fc; }
.table-row:last-child td { border-bottom: none; }

.vehicle-cell { display: flex; flex-direction: column; gap: 0.1rem; }
.vehicle-placa { font-weight: 700; color: var(--text-main); font-size: 0.875rem; }
.vehicle-model { font-size: 0.72rem; color: var(--text-muted); }

.service-type { font-weight: 500; }
.date-cell { font-size: 0.8rem; color: var(--text-muted); font-variant-numeric: tabular-nums; }
.cost-cell { font-weight: 600; font-variant-numeric: tabular-nums; }

/* ── Status Badges ── */
.status-badge {
  display: inline-block;
  padding: 0.25rem 0.625rem;
  border-radius: 999px;
  font-size: 0.66rem;
  font-weight: 800;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  white-space: nowrap;
}
.badge--pending {
  background: #FFF3E0;
  color: #E65100;
  border: 1px solid rgba(230,81,0,.15);
}
.badge--active {
  background: #E3F2FD;
  color: #1565C0;
  border: 1px solid rgba(21,101,192,.15);
}
.badge--done {
  background: #E8F5E9;
  color: #2E7D32;
  border: 1px solid rgba(46,125,50,.15);
}

/* ── Action Buttons ── */
.action-btns { display: flex; gap: 0.375rem; }
.action-btn {
  display: flex; align-items: center; justify-content: center;
  width: 1.875rem; height: 1.875rem;
  border: none; border-radius: 6px;
  cursor: pointer; transition: all .2s;
}
.action-btn .material-symbols-outlined { font-size: 1.05rem; }
.action-btn--edit {
  background: rgba(26,35,126,.08);
  color: #1A237E;
}
.action-btn--edit:hover { background: rgba(26,35,126,.18); }
.action-btn--delete {
  background: rgba(220,38,38,.08);
  color: #dc2626;
}
.action-btn--delete:hover { background: rgba(220,38,38,.18); }

/* ══════════════════════════════════════════
   LOADING / EMPTY STATES
══════════════════════════════════════════ */
.loading-state, .empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem 1.5rem;
  gap: 0.75rem;
  color: var(--text-muted);
  text-align: center;
}
.loading-spinner {
  width: 2rem; height: 2rem;
  border: 3px solid rgba(26,35,126,.12);
  border-top-color: #1A237E;
  border-radius: 50%;
  animation: spin .8s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }
.empty-icon { font-size: 2.5rem; color: #d1d5db; font-variation-settings: 'FILL' 0; }
.empty-title { font-weight: 700; color: var(--text-main); font-size: 0.9rem; margin: 0; }
.empty-sub { font-size: 0.8rem; margin: 0; }

/* ══════════════════════════════════════════
   BOTTOM ROW
══════════════════════════════════════════ */
.bottom-row {
  display: block;
}

/* Upcoming */
.upcoming-card { padding: 1.125rem; }
.upcoming-empty {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--text-muted);
  font-size: 0.8rem;
  padding: 0.5rem 0;
}
.upcoming-empty .material-symbols-outlined { font-size: 1.1rem; }
.upcoming-list { list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 0.75rem; }
.upcoming-item { display: flex; align-items: flex-start; gap: 0.625rem; }
.upcoming-dot {
  width: 8px; height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
  margin-top: 5px;
}
.upcoming-dot.badge--pending { background: #E65100; border: none; }
.upcoming-dot.badge--active { background: #1565C0; border: none; }
.upcoming-dot.badge--done { background: #2E7D32; border: none; }
.upcoming-info { flex: 1; }
.upcoming-title { font-size: 0.82rem; font-weight: 600; color: var(--text-main); margin: 0 0 0.1rem; }
.upcoming-date { font-size: 0.72rem; color: var(--text-muted); margin: 0; }




/* ══════════════════════════════════════════
   DELETE MODAL
══════════════════════════════════════════ */
.modal-overlay {
  position: fixed; inset: 0; z-index: 300;
  background: rgba(0,0,0,.45);
  backdrop-filter: blur(4px);
  display: flex; align-items: center; justify-content: center;
  padding: 1.5rem;
  animation: fadeIn .2s ease;
}
@keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

.modal-box {
  background: white;
  border-radius: var(--radius-lg);
  padding: 2rem;
  max-width: 420px;
  width: 100%;
  box-shadow: var(--shadow-lg);
  animation: scaleIn .2s ease;
  text-align: center;
}
@keyframes scaleIn { from { opacity: 0; transform: scale(.95); } to { opacity: 1; transform: scale(1); } }

.modal-icon-wrap {
  width: 3.5rem; height: 3.5rem;
  border-radius: 50%;
  display: inline-flex; align-items: center; justify-content: center;
  margin-bottom: 1rem;
}
.modal-icon-wrap--danger {
  background: rgba(220,38,38,.1);
  color: #dc2626;
}
.modal-icon-wrap .material-symbols-outlined { font-size: 1.75rem; font-variation-settings: 'FILL' 1; }

.modal-title { font-size: 1.1rem; font-weight: 700; margin: 0 0 0.75rem; }
.modal-body { font-size: 0.875rem; color: var(--text-muted); margin: 0 0 1.5rem; line-height: 1.6; }
.modal-body strong { color: var(--text-main); }

.modal-actions { display: flex; gap: 0.75rem; justify-content: center; }
.btn-danger {
  display: flex; align-items: center; gap: 0.375rem;
  padding: 0.7rem 1.25rem;
  background: linear-gradient(135deg, #dc2626, #b91c1c);
  color: white; border: none; border-radius: var(--radius-sm);
  font-size: 0.84rem; font-weight: 700; cursor: pointer;
  box-shadow: 0 4px 14px rgba(220,38,38,.3);
  transition: all .2s;
}
.btn-danger:hover:not(:disabled) { transform: translateY(-1px); box-shadow: 0 6px 18px rgba(220,38,38,.4); }
.btn-danger:disabled { opacity: .65; cursor: not-allowed; }
.btn-danger .material-symbols-outlined { font-size: 1rem; }

/* ══════════════════════════════════════════
   TOAST
══════════════════════════════════════════ */
.toast-container {
  position: fixed;
  bottom: 1.5rem;
  left: 50%;
  transform: translateX(-50%);
  z-index: 9999;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  align-items: center;
  pointer-events: none;
}
.toast-item {
  display: flex; align-items: flex-start; gap: 0.75rem;
  min-width: 300px; max-width: 480px;
  padding: 0.875rem 1rem;
  border-radius: var(--radius);
  border: 1px solid transparent;
  background: white;
  box-shadow: 0 8px 32px rgba(0,0,0,.14);
  pointer-events: all;
}
.toast-item--success { border-color: rgba(22,163,74,.2); }
.toast-item--error { border-color: rgba(220,38,38,.2); }
.toast-item--warning { border-color: rgba(217,119,6,.2); }

.toast-icon { font-size: 1.25rem; flex-shrink: 0; font-variation-settings: 'FILL' 1; }
.toast-item--success .toast-icon { color: #16a34a; }
.toast-item--error .toast-icon { color: #dc2626; }
.toast-item--warning .toast-icon { color: #d97706; }

.toast-body { flex: 1; }
.toast-title { font-weight: 700; font-size: 0.875rem; margin: 0 0 0.1rem; }
.toast-message { font-size: 0.78rem; color: var(--text-muted); margin: 0; }
.toast-close {
  background: none; border: none; cursor: pointer;
  color: var(--text-muted); padding: 0.1rem; line-height: 1;
}
.toast-close .material-symbols-outlined { font-size: 1rem; }
.toast-close:hover { color: var(--text-main); }

/* Toast transitions */
.toast-enter-active { animation: toastIn .3s ease; }
.toast-leave-active { animation: toastOut .25s ease forwards; }
@keyframes toastIn { from { opacity: 0; transform: translateY(12px) scale(.96); } to { opacity: 1; transform: none; } }
@keyframes toastOut { to { opacity: 0; transform: translateY(12px) scale(.96); } }

/* ══════════════════════════════════════════
   SPINNER SM
══════════════════════════════════════════ */
.spinner-sm {
  width: 1rem; height: 1rem;
  border: 2px solid rgba(255,255,255,.35);
  border-top-color: white;
  border-radius: 50%;
  animation: spin .7s linear infinite;
  flex-shrink: 0;
}

/* Autocomplete Custom Styles */
.autocomplete-group {
  position: relative;
}
.autocomplete-dropdown {
  position: absolute;
  top: calc(100% + 4px);
  left: 0;
  right: 0;
  background: white;
  border: 1px solid var(--border);
  border-radius: var(--radius);
  box-shadow: var(--shadow-md);
  max-height: 200px;
  overflow-y: auto;
  z-index: 50;
  margin: 0;
  padding: 0;
  list-style: none;
}
.autocomplete-item {
  padding: 0.6rem 0.8rem;
  font-size: 0.85rem;
  cursor: pointer;
  border-bottom: 1px solid #f1f5f9;
  transition: background 0.2s;
}
.autocomplete-item:last-child {
  border-bottom: none;
}
.autocomplete-item:hover {
  background: rgba(26,35,126,0.06);
}
.ac-placa {
  font-weight: 700;
  color: #1A237E;
  margin-right: 0.5rem;
}
.ac-modelo {
  color: var(--text-muted);
}
.autocomplete-item--empty {
  color: var(--text-muted);
  cursor: default;
  font-style: italic;
}
.autocomplete-item--empty:hover {
  background: transparent;
}
</style>
