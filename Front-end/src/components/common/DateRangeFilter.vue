<template>
  <div class="field-row">
    <div class="filter-group">
      <label class="field-label">Início</label>
      <input type="date" :value="modelValue.dataInicio" @input="updateInicio" class="filter-input" />
    </div>
    <div class="filter-group">
      <label class="field-label">Fim</label>
      <input type="date" :value="modelValue.dataFim" @input="updateFim" class="filter-input" />
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({ dataInicio: '', dataFim: '' })
  }
})

const emit = defineEmits(['update:modelValue'])

function updateInicio(e) {
  emit('update:modelValue', { ...props.modelValue, dataInicio: e.target.value })
}

function updateFim(e) {
  emit('update:modelValue', { ...props.modelValue, dataFim: e.target.value })
}
</script>

<style scoped>
.field-row {
  display: flex;
  gap: 0.75rem;
  flex: 1;
}
.filter-group {
  display: flex;
  flex-direction: column;
  flex: 1;
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
.filter-input {
  width: 100%;
  background: #f8fafc;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  padding: 0.6rem 0.75rem;
  font-size: 0.85rem;
  color: #334155;
  outline: none;
  transition: all 0.2s;
  height: 38px;
}
.filter-input:focus {
  background: #ffffff;
  border-color: #1A237E;
  box-shadow: 0 0 0 2px rgba(26,35,126,0.1);
}

@media (max-width: 768px) {
  .field-row {
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .filter-group {
    width: 100%;
    min-width: 0;
  }
  
  .filter-input {
    padding-right: 0.35rem; /* Menor padding para acomodar ícone do iOS */
  }
}
</style>
