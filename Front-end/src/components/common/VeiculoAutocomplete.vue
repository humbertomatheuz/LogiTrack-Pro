<template>
  <div class="field-group autocomplete-group">
    <label :for="id" class="field-label">Veículo (Busca)</label>
    <div class="input-wrapper" style="position: relative;">
      <input
        :id="id"
        type="text"
        v-model="veiculoSearch"
        @focus="showVeiculoDropdown = true"
        @blur="handleVeiculoBlur"
        placeholder="Busque por placa ou modelo..."
        class="field-input"
        :class="{ 'field-error': error }"
        autocomplete="off"
      />
      <span class="material-symbols-outlined select-arrow" style="pointer-events: none; position: absolute; right: 12px; top: 50%; transform: translateY(-50%); color: var(--text-muted) !important;">search</span>
      
      <ul v-if="showVeiculoDropdown && filteredVeiculos.length > 0" class="autocomplete-dropdown">
        <li v-for="v in filteredVeiculos" :key="v.id" @mousedown.prevent="selectVeiculo(v)" class="autocomplete-item">
          <span class="ac-placa">{{ v.placa }}</span> <span class="ac-modelo">{{ v.modelo }}</span>
        </li>
      </ul>
      
      <ul v-else-if="showVeiculoDropdown && filteredVeiculos.length === 0" class="autocomplete-dropdown empty-dropdown">
        <li class="autocomplete-item autocomplete-item--empty">Nenhum veículo encontrado</li>
      </ul>
    </div>
    <p v-if="error" class="field-error-msg">{{ error }}</p>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import api from '../../services/api'

const props = defineProps({
  modelValue: {
    type: [String, Number],
    default: ''
  },
  error: {
    type: String,
    default: ''
  },
  id: {
    type: String,
    default: 'veiculo-input'
  }
})

const emit = defineEmits(['update:modelValue', 'select'])

const veiculoSearch = ref('')
const showVeiculoDropdown = ref(false)
const veiculos = ref([])

onMounted(async () => {
  try {
    const { data } = await api.get('/api/veiculos')
    veiculos.value = data
  } catch (err) {
    console.error('Erro ao buscar veículos no autocomplete', err)
  }
})

// Optional text syncing when passing initial value (e.g. edit mode)
watch(() => props.modelValue, (newVal) => {
  if (newVal) {
    const v = veiculos.value.find(v => v.id === newVal)
    if (v) {
      veiculoSearch.value = `${v.placa} — ${v.modelo}`
    } else if (typeof newVal === 'string' && !String(newVal).match(/^\d+$/)) {
      // It might be text typed manually
      veiculoSearch.value = newVal
    }
  } else {
    veiculoSearch.value = ''
  }
}, { immediate: true })

watch(veiculoSearch, (val) => {
  // Always update modelValue with what is being searched so DadosFrota can use it natively
  if (showVeiculoDropdown.value) {
    emit('update:modelValue', val)
  }
})

const filteredVeiculos = computed(() => {
  const query = veiculoSearch.value.toLowerCase()
  if (!query) return veiculos.value
  return veiculos.value.filter(v => 
    v.placa.toLowerCase().includes(query) || 
    v.modelo.toLowerCase().includes(query)
  )
})

function selectVeiculo(v) {
  emit('update:modelValue', v.id)
  emit('select', v)
  veiculoSearch.value = `${v.placa} — ${v.modelo}`
  showVeiculoDropdown.value = false
}

function handleVeiculoBlur() {
  setTimeout(() => { showVeiculoDropdown.value = false }, 200)
}
</script>

<style scoped>
/* COPIADO DA TELA DE GERENCIAMENTO */
.field-group { margin-bottom: 0.9rem; }
.field-label {
  display: block;
  font-size: 0.67rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: #6b7280;
  margin-bottom: 0.4rem;
}

.field-input {
  width: 100%;
  padding: 0.6rem 0.875rem;
  background: #f7f8fc;
  border: 1.5px solid #e5e7eb;
  border-radius: 6px;
  font-size: 0.845rem;
  font-family: inherit;
  color: #1a1a2e;
  outline: none;
  transition: border .2s, box-shadow .2s, background .2s;
  -webkit-appearance: none;
  appearance: none;
}
.field-input:focus {
  border-color: #1A237E;
  background: #ffffff;
  box-shadow: 0 0 0 3px rgba(26,35,126,0.1);
}
.field-input.field-error {
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

.autocomplete-dropdown {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  margin-top: 4px;
  max-height: 200px;
  overflow-y: auto;
  z-index: 50;
  list-style: none;
  padding: 0;
  box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);
}
.autocomplete-item {
  padding: 0.5rem 0.75rem;
  font-size: 0.85rem;
  cursor: pointer;
  border-bottom: 1px solid #f3f4f6;
  color: #1a1a2e;
}
.autocomplete-item:hover {
  background: #f0f2f8;
}
.ac-placa { 
  font-weight: 700; 
  color: #1A237E; 
}
.ac-modelo { 
  font-size: 0.8rem; 
  margin-left: 0.5rem; 
  color: #6b7280;
}
.empty-dropdown { 
  padding: 0.5rem; 
  color: #9ca3af; 
  text-align: center; 
}
</style>
