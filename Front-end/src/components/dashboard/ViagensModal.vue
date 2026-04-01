<template>
  <div v-if="show" class="modal-overlay" @click.self="close">
    <div class="modal-dialog-custom">
      <div class="modal-content-custom">
        
        <!-- Header -->
        <div class="modal-header-custom">
          <div class="modal-title-area">
            <h2 class="modal-title">Detalhamento de Viagens: {{ veiculo?.placa || 'Carregando...' }}</h2>
            <p class="modal-subtitle" v-if="veiculo">
              {{ veiculo?.modelo }} <span v-if="veiculo?.motorista">• Motorista: {{ veiculo.motorista }}</span>
            </p>
          </div>
          <button class="btn-close-custom" @click="close" aria-label="Close">
            <span class="material-symbols-outlined">close</span>
          </button>
        </div>

        <!-- Body -->
        <div class="modal-body-custom">
          
          <div v-if="loading" class="loading-state">
            <div class="spinner"></div>
            <p>Carregando histórico...</p>
          </div>

          <div v-else-if="error" class="error-state">
            <p>{{ error }}</p>
          </div>

          <div v-else-if="viagens.length === 0" class="empty-state">
            <p>Nenhum histórico de viagem encontrado para este veículo</p>
          </div>

          <div v-else class="table-responsive">
            <table class="data-table">
              <thead>
                <tr>
                  <!-- Columns: Data de Saída, Data de Chegada, Origem, Destino e KM Percorrida -->
                  <th @click="sortBy('dataSaida')" class="sortable">
                    SAÍDA <span v-if="sortKey === 'dataSaida'" class="material-symbols-outlined sort-icon">{{ sortAsc ? 'arrow_upward' : 'arrow_downward' }}</span>
                  </th>
                  <th @click="sortBy('dataChegada')" class="sortable">
                    CHEGADA <span v-if="sortKey === 'dataChegada'" class="material-symbols-outlined sort-icon">{{ sortAsc ? 'arrow_upward' : 'arrow_downward' }}</span>
                  </th>
                  <th @click="sortBy('origem')" class="sortable">
                    ORIGEM <span v-if="sortKey === 'origem'" class="material-symbols-outlined sort-icon">{{ sortAsc ? 'arrow_upward' : 'arrow_downward' }}</span>
                  </th>
                  <th @click="sortBy('destino')" class="sortable">
                    DESTINO <span v-if="sortKey === 'destino'" class="material-symbols-outlined sort-icon">{{ sortAsc ? 'arrow_upward' : 'arrow_downward' }}</span>
                  </th>
                  <th @click="sortBy('kmPercorrida')" class="sortable text-right">
                    KM <span v-if="sortKey === 'kmPercorrida'" class="material-symbols-outlined sort-icon">{{ sortAsc ? 'arrow_upward' : 'arrow_downward' }}</span>
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="viagem in sortedViagens" :key="viagem.id">
                  <td>{{ formatDateTime(viagem.dataSaida) }}</td>
                  <td>{{ formatDateTime(viagem.dataChegada) }}</td>
                  <td>{{ viagem.origem }}</td>
                  <td>{{ viagem.destino }}</td>
                  <td class="col-km text-right">{{ formatNumber(viagem.kmPercorrida) }}</td>
                </tr>
              </tbody>
            </table>
          </div>

        </div>

        <!-- Footer -->
        <div class="modal-footer-custom">
          <button class="btn-fechar" @click="close">Fechar</button>
        </div>

      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import api from '../../services/api'
import { useKmStore } from '../../stores/km'

const props = defineProps({
  show: Boolean,
  veiculoId: {
    type: [Number, String],
    default: null
  }
})

const emit = defineEmits(['update:show'])

const kmStore = useKmStore()

const viagens = ref([])
const loading = ref(false)
const error = ref(null)

const sortKey = ref('dataSaida')
const sortAsc = ref(false)

// Obter os dados do veículo a partir da store
const veiculo = computed(() => {
  if (!props.veiculoId) return null
  return kmStore.veiculos.find(v => v.id === props.veiculoId) || kmStore.veiculos.find(v => v.id == props.veiculoId)
})

const sortedViagens = computed(() => {
  return [...viagens.value].sort((a, b) => {
    let valA = a[sortKey.value]
    let valB = b[sortKey.value]

    if (sortKey.value === 'dataSaida' || sortKey.value === 'dataChegada') {
      valA = new Date(valA).getTime()
      valB = new Date(valB).getTime()
    }

    if (valA < valB) return sortAsc.value ? -1 : 1
    if (valA > valB) return sortAsc.value ? 1 : -1
    return 0
  })
})

function sortBy(key) {
  if (sortKey.value === key) {
    sortAsc.value = !sortAsc.value
  } else {
    sortKey.value = key
    sortAsc.value = true
  }
}

function formatDateTime(dateString) {
  if (!dateString) return '-'
  const d = new Date(dateString)
  if (isNaN(d)) return dateString
  const day = String(d.getDate()).padStart(2, '0')
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const year = String(d.getFullYear()).slice(-2)
  const hours = String(d.getHours()).padStart(2, '0')
  const minutes = String(d.getMinutes()).padStart(2, '0')
  return `${day}/${month}/${year} ${hours}:${minutes}`
}

function formatNumber(val) {
  if (!val) return '0'
  return Math.round(val).toLocaleString('pt-BR')
}

async function fetchViagens() {
  if (!props.veiculoId) return

  loading.value = true
  error.value = null
  viagens.value = []

  try {
    const response = await api.get(`/api/veiculos/${props.veiculoId}/viagens`)
    
    viagens.value = response.data
  } catch (err) {
    console.error('Erro ao buscar viagens', err)
    error.value = 'Houve um erro ao carregar as viagens. Tente novamente mais tarde.'
  } finally {
    loading.value = false
  }
}

watch(() => props.show, (newVal) => {
  if (newVal) {
    document.body.style.overflow = 'hidden'
    fetchViagens()
  } else {
    document.body.style.overflow = ''
  }
})

function close() {
  emit('update:show', false)
}

onMounted(() => {
  if (props.show) {
    document.body.style.overflow = 'hidden'
    fetchViagens()
  }
})

onUnmounted(() => {
  document.body.style.overflow = ''
})
</script>

<style scoped>
/* ── Variables & Typography ───────────────────────── */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1050;
  animation: fadeInModal 0.2s ease-out;
  backdrop-filter: blur(2px);
}

@keyframes fadeInModal {
  from { opacity: 0; }
  to { opacity: 1; }
}

.modal-dialog-custom {
  background: #ffffff;
  width: 90%;
  max-width: 900px; /* Modal largo para tabela */
  border-radius: 12px;
  box-shadow: 0 10px 25px rgba(0,0,0,0.1);
  display: flex;
  flex-direction: column;
  max-height: 90vh;
  animation: slideInDown 0.3s ease-out;
}

@keyframes slideInDown {
  from { opacity: 0; transform: translateY(-20px); }
  to { opacity: 1; transform: translateY(0); }
}

.modal-header-custom {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 1.5rem 2rem;
  border-bottom: 1px solid #e5e7eb;
}

.modal-title-area {
  display: flex;
  flex-direction: column;
}

.modal-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: #1A237E;
  margin: 0;
  font-family: 'Manrope', -apple-system, sans-serif;
}

.modal-subtitle {
  font-size: 0.85rem;
  color: #6b7280;
  margin: 0.25rem 0 0 0;
}

.btn-close-custom {
  background: none;
  border: none;
  cursor: pointer;
  color: #6b7280;
  transition: color 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0.25rem;
}

.btn-close-custom:hover {
  color: #111827;
}

.modal-body-custom {
  padding: 1.5rem 2rem;
  overflow-y: auto;
  flex: 1;
}

.loading-state, .error-state, .empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem 0;
  color: #6b7280;
  text-align: center;
}

.spinner {
  border: 4px solid #f3f3f3;
  border-top: 4px solid #1A237E;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
  margin-bottom: 1rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.table-responsive {
  width: 100%;
}

.data-table {
  width: 100%;
  border-collapse: collapse;
}

.data-table th, 
.data-table td {
  padding: 1rem;
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
  background: #f8fafc;
  cursor: default;
}

.data-table th.sortable {
  cursor: pointer;
  user-select: none;
}
.data-table th.sortable:hover {
  background: #e2e8f0;
}

.sort-icon {
  font-size: 0.9rem;
  vertical-align: middle;
  margin-left: 0.2rem;
}

.data-table tbody tr {
  transition: background-color 0.2s;
}

.data-table tbody tr:hover {
  background-color: #f8fafc;
}

.col-km {
  font-weight: 700;
  color: #1A237E;
}

.text-right {
  text-align: right !important;
}

.modal-footer-custom {
  padding: 1.25rem 2rem;
  border-top: 1px solid #e5e7eb;
  display: flex;
  justify-content: flex-end;
  background: #fafafa;
  border-bottom-left-radius: 12px;
  border-bottom-right-radius: 12px;
}

.btn-fechar {
  background: white;
  color: #1A237E;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  padding: 0.5rem 1.5rem;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
}

.btn-fechar:hover {
  background: #f1f5f9;
}
</style>
