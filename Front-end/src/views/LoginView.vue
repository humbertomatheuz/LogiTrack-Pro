<template>
  <div class="logi-wrapper">
    <!-- Decoração de fundo -->
    <div class="logi-bg-blob logi-bg-blob--top" aria-hidden="true"></div>
    <div class="logi-bg-blob logi-bg-blob--bottom" aria-hidden="true"></div>

    <!-- Painel lateral decorativo (visível em telas largas) -->
    <aside class="logi-side-panel d-none d-xl-flex">
      <img
        src="https://images.unsplash.com/photo-1553413077-190dd305871c?w=800&auto=format&fit=crop&q=80"
        alt="Modern logistics warehouse"
        class="logi-side-panel__img"
      />
      <div class="logi-side-panel__overlay"></div>
      <div class="logi-side-panel__content">
        <p class="logi-side-panel__watermark">LOGITRACK</p>
        <p class="logi-side-panel__watermark">PROTOCOL</p>
        <div class="logi-side-panel__divider"></div>
        <p class="logi-side-panel__status">Network Status: Online</p>
      </div>
    </aside>

    <!-- Conteúdo principal -->
    <main class="logi-main">
      <!-- Identidade da marca -->
      <div class="text-center mb-5">
        <div class="logi-brand-icon mb-3">
          <span class="material-symbols-outlined logi-brand-icon__symbol">local_shipping</span>
        </div>
        <h1 class="logi-brand-name">LogiTrack Pro</h1>
        <p class="logi-brand-sub">Acesso restrito ao terminal de gerenciamento</p>
      </div>

      <!-- Card de login -->
      <div class="logi-card">

        <!-- Alerta de erro -->
        <div v-if="errorMessage" class="logi-alert mb-4" role="alert">
          <span class="material-symbols-outlined logi-alert__icon">error</span>
          <div>
            <p class="logi-alert__title">{{ errorMessage.includes('servidor') ? 'Status do Servidor' : 'Credenciais Inválidas' }}</p>
            <p class="logi-alert__sub">{{ errorMessage }}</p>
          </div>
        </div>

        <form @submit.prevent="handleLogin" novalidate>

          <!-- Campo Login -->
          <div class="mb-4">
            <label for="login" class="logi-label">Login</label>
            <div class="logi-input-group">
              <span class="logi-input-icon material-symbols-outlined">person</span>
              <input
                id="login"
                v-model="form.login"
                type="text"
                class="logi-input"
                placeholder="usuário@logitrack.pro"
                autocomplete="username"
                required
              />
            </div>
          </div>

          <!-- Campo Senha -->
          <div class="mb-4">
            <div class="d-flex justify-content-between align-items-center mb-2">
              <label for="senha" class="logi-label mb-0">Senha</label>
            </div>
            <div class="logi-input-group">
              <span class="logi-input-icon material-symbols-outlined">lock</span>
              <input
                id="senha"
                v-model="form.senha"
                :type="showPassword ? 'text' : 'password'"
                class="logi-input logi-input--with-action"
                placeholder="••••••••"
                autocomplete="current-password"
                required
              />
              <button
                type="button"
                class="logi-input-action"
                @click="showPassword = !showPassword"
                :aria-label="showPassword ? 'Ocultar senha' : 'Mostrar senha'"
              >
                <span class="material-symbols-outlined">
                  {{ showPassword ? 'visibility_off' : 'visibility' }}
                </span>
              </button>
            </div>
          </div>

          <!-- Lembrar-me -->
          <div class="mb-4">
            <div class="form-check logi-check">
              <input
                id="remember"
                v-model="form.remember"
                type="checkbox"
                class="form-check-input logi-check__input"
              />
              <label for="remember" class="form-check-label logi-check__label">
                Lembrar neste dispositivo
              </label>
            </div>
          </div>

          <!-- Botão de enviar -->
          <button
            type="submit"
            class="logi-btn-submit w-100"
            :disabled="loading"
          >
            <span v-if="loading" class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
            <span v-else>Entrar</span>
            <span v-if="!loading" class="material-symbols-outlined logi-btn-submit__icon">login</span>
          </button>

        </form>

        <!-- Rodapé do card -->
        <div class="logi-card-footer">
          <span class="logi-card-footer__dot"></span>
          <p class="logi-card-footer__text">Sistema de Logística Global</p>
          <span class="logi-card-footer__dot"></span>
        </div>
      </div>

      <!-- Links do rodapé externo -->
      <footer class="logi-footer">
        <a href="#" class="logi-footer__link">Política de Privacidade</a>
        <a href="#" class="logi-footer__link">Suporte Técnico</a>
        <a href="#" class="logi-footer__link">Termos de Uso</a>
      </footer>
    </main>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const form = ref({ login: '', senha: '', remember: false })
const showPassword = ref(false)
const loading = ref(false)
const errorMessage = ref('')

async function handleLogin() {
  if (!form.value.login || !form.value.senha) {
    errorMessage.value = 'Por favor, preencha todos os campos.'
    return
  }

  loading.value = true
  errorMessage.value = ''

  try {
    await authStore.login({ login: form.value.login, senha: form.value.senha })
    router.push('/gerenciamento')
  } catch (err) {
    // Se o erro for de rede (ex: timeout ou servidor offline no Render)
    if (!err.response) {
      errorMessage.value = 'O servidor está iniciando (Cold Start). Por favor, aguarde cerca de 60 segundos e tente novamente.'
    } else if (err.response.status === 401 || err.response.status === 403) {
      errorMessage.value = 'Usuário ou senha incorretos. Por favor, verifique seus dados.'
    } else {
      errorMessage.value = 'Ocorreu um erro inesperado. Tente novamente em instantes.'
    }
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
/* ===== TOKENS DE COR ===== */
:root {
  --logi-primary:          #1A237E;
  --logi-primary-dark:     #1a237e;
  --logi-surface:          #f8f9fa;
  --logi-surface-low:      #f3f4f5;
  --logi-surface-lowest:   #ffffff;
  --logi-surface-high:     #e7e8e9;
  --logi-on-surface:       #191c1d;
  --logi-on-surface-var:   #454652;
  --logi-outline:          #767683;
  --logi-outline-var:      #c6c5d4;
  --logi-secondary-fixed:  #b4cad6;
  --logi-primary-fixed:    #e0e0ff;
  --logi-error:            #ba1a1a;
  --logi-error-container:  #ffdad6;
  --logi-on-error-container: #93000a;
}

/* ===== LAYOUT ===== */
.logi-wrapper {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #f8f9fa 0%, #f3f4f5 100%);
  font-family: 'Inter', sans-serif;
  color: var(--logi-on-surface);
  padding: 1.5rem;
  position: relative;
  overflow: hidden;
}

/* ===== BLOBS DE FUNDO ===== */
.logi-bg-blob {
  position: fixed;
  border-radius: 50%;
  pointer-events: none;
  z-index: 0;
  filter: blur(120px);
}
.logi-bg-blob--top {
  top: -10%;
  left: -5%;
  width: 40%;
  height: 60%;
  background: linear-gradient(135deg, rgba(180, 202, 214, 0.25), rgba(180, 202, 214, 0.15));
  opacity: 0.6;
  animation: float 8s ease-in-out infinite;
}
.logi-bg-blob--bottom {
  top: 60%;
  right: -10%;
  width: 50%;
  height: 50%;
  background: linear-gradient(135deg, rgba(224, 224, 255, 0.3), rgba(224, 224, 255, 0.15));
  opacity: 0.5;
  animation: float 10s ease-in-out infinite reverse;
}

@keyframes float {
  0%, 100% { transform: translate(0, 0); }
  50% { transform: translate(30px, -30px); }
}

/* ===== PAINEL LATERAL ===== */
.logi-side-panel {
  position: fixed;
  right: 0;
  top: 0;
  bottom: 0;
  width: 25%;
  overflow: hidden;
  flex-direction: column;
  background: linear-gradient(135deg, #e7e8e9 0%, #d9dadb 100%);
}
.logi-side-panel__img {
  height: 100%;
  width: 100%;
  object-fit: cover;
  filter: grayscale(100%) contrast(1.3) brightness(0.95);
  opacity: 0.85;
  mix-blend-mode: multiply;
}
.logi-side-panel__overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, rgba(26, 35, 126, 0.25), rgba(26, 35, 126, 0.15));
  backdrop-filter: contrast(0.8) brightness(1.05);
}
.logi-side-panel__content {
  position: absolute;
  bottom: 3rem;
  left: 3rem;
  right: 3rem;
  color: white;
}
.logi-side-panel__watermark {
  font-family: 'Manrope', sans-serif;
  font-size: 2.5rem;
  font-weight: 800;
  line-height: 1;
  letter-spacing: -0.02em;
  margin: 0;
  opacity: 0.08;
  text-transform: uppercase;
}
.logi-side-panel__divider {
  width: 3rem;
  height: 2.5px;
  background: linear-gradient(90deg, #e0e0ff 0%, rgba(224, 224, 255, 0.3) 100%);
  margin-top: 2rem;
  border-radius: 2px;
}
.logi-side-panel__status {
  margin-top: 1.25rem;
  font-size: 0.65rem;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 0.25em;
  color: #e0e0ff;
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

/* ===== CONTEÚDO PRINCIPAL ===== */
.logi-main {
  position: relative;
  z-index: 10;
  width: 100%;
  max-width: 480px;
}

/* ===== MARCA ===== */
.logi-brand-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 4rem;
  height: 4rem;
  border-radius: 0.75rem;
  background: linear-gradient(135deg, #1A237E 0%, #1a237e 100%);
  color: white;
  box-shadow: 0 20px 48px rgba(26, 35, 126, 0.25),
              0 8px 16px rgba(26, 35, 126, 0.15);
  animation: pulse 3s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
}

.logi-brand-icon__symbol {
  font-size: 2rem;
  font-variation-settings: 'FILL' 1, 'wght' 500;
}
.logi-brand-name {
  font-family: 'Manrope', sans-serif;
  font-size: 2rem;
  font-weight: 800;
  letter-spacing: -0.02em;
  color: #1A237E;
  margin-bottom: 0.5rem;
  background: linear-gradient(135deg, #1A237E 0%, #003fa3 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}
.logi-brand-sub {
  color: var(--logi-on-surface-var);
  font-size: 0.9rem;
  font-weight: 500;
  letter-spacing: -0.01em;
}

/* ===== CARD ===== */
.logi-card {
  background-color: var(--logi-surface-lowest);
  border-radius: 0.75rem;
  border: 1px solid rgba(198, 197, 212, 0.12);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08), 
              0 1px 3px rgba(0, 0, 0, 0.04);
  padding: 2rem 2.5rem;
  backdrop-filter: blur(8px);
}
@media (min-width: 768px) {
  .logi-card {
    padding: 2.5rem 3rem;
  }
}

/* ===== ALERTA DE ERRO ===== */
.logi-alert {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
  padding: 1rem 1.25rem;
  background-color: rgba(255, 218, 214, 0.35);
  border-left: 4px solid var(--logi-error);
  border-radius: 0 0.5rem 0.5rem 0;
  animation: slideIn 0.3s ease-out;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
.logi-alert__icon {
  color: var(--logi-error);
  font-variation-settings: 'FILL' 1;
  font-size: 1.5rem;
  flex-shrink: 0;
}
.logi-alert__title {
  font-size: 0.875rem;
  font-weight: 700;
  color: var(--logi-on-error-container);
  margin: 0 0 0.125rem;
}
.logi-alert__sub {
  font-size: 0.75rem;
  color: rgba(147, 0, 10, 0.8);
  margin: 0;
}

/* ===== LABEL ===== */
.logi-label {
  display: block;
  font-size: 0.7rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.12em;
  color: var(--logi-on-surface-var);
  margin-bottom: 0.65rem;
}

/* ===== INPUT GROUP ===== */
.logi-input-group {
  position: relative;
  transition: all 0.2s ease;
}
.logi-input-icon {
  position: absolute;
  left: 1rem;
  top: 50%;
  transform: translateY(-50%);
  color: var(--logi-outline);
  font-size: 1.25rem;
  pointer-events: none;
  transition: color 0.2s ease;
  font-variation-settings: 'FILL' 0;
}
.logi-input-group:focus-within .logi-input-icon {
  color: var(--logi-primary);
  font-variation-settings: 'FILL' 1;
}
.logi-input {
  width: 100%;
  padding: 1rem 1rem 1rem 3rem;
  background-color: var(--logi-surface-low);
  border: 1px solid transparent;
  border-radius: 0.5rem;
  font-size: 0.875rem;
  font-family: 'Inter', sans-serif;
  color: var(--logi-on-surface);
  outline: none;
  transition: all 0.2s ease;
}
.logi-input::placeholder {
  color: rgba(118, 118, 131, 0.55);
}
.logi-input:focus {
  background-color: var(--logi-surface-lowest);
  border-color: var(--logi-primary);
  box-shadow: 0 0 0 3px rgba(26, 35, 126, 0.1);
}
.logi-input--with-action {
  padding-right: 3rem;
}

/* ===== BOTÃO VER SENHA ===== */
.logi-input-action {
  position: absolute;
  right: 1rem;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  padding: 0.25rem;
  cursor: pointer;
  color: var(--logi-outline);
  line-height: 1;
  transition: all 0.2s ease;
  border-radius: 0.25rem;
}
.logi-input-action:hover {
  color: #1A237E;
}
.logi-input-action:focus {
  outline: 2px solid rgba(26, 35, 126, 0.2);
  outline-offset: 2px;
}
.logi-input-action .material-symbols-outlined {
  font-size: 1.25rem;
  font-variation-settings: 'FILL' 0;
}

/* ===== LINK ===== */
.logi-link {
  font-size: 0.75rem;
  font-weight: 600;
  color: #1A237E;
  text-decoration: none;
  transition: all 0.2s ease;
  position: relative;
}
.logi-link::after {
  content: '';
  position: absolute;
  bottom: -1px;
  left: 0;
  width: 0;
  height: 1px;
  background: #1A237E;
  transition: width 0.2s ease;
}
.logi-link:hover {
  color: #0d1a47;
}
.logi-link:hover::after {
  width: 100%;
}

/* ===== CHECKBOX ===== */
.logi-check__input {
  width: 1rem;
  height: 1rem;
  border: 1.5px solid var(--logi-outline-var);
  background-color: var(--logi-surface-low);
  cursor: pointer;
  border-radius: 0.25rem;
  transition: all 0.2s ease;
}
.logi-check__input:hover:not(:checked) {
  border-color: var(--logi-outline);
}
.logi-check__input:checked {
  background-color: #1A237E;
  border-color: #1A237E;
}
.logi-check__input:focus {
  box-shadow: 0 0 0 3px rgba(26, 35, 126, 0.1);
}
.logi-check__label {
  font-size: 0.875rem;
  color: var(--logi-on-surface-var);
  font-weight: 500;
  cursor: pointer;
  user-select: none;
}

/* ===== BOTÃO SUBMIT ===== */
.logi-btn-submit {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 1rem 1.5rem;
  border: none;
  border-radius: 0.5rem;
  background: linear-gradient(135deg, #1A237E 0%, #1a237e 100%);
  color: white;
  font-family: 'Manrope', sans-serif;
  font-size: 0.875rem;
  font-weight: 700;
  letter-spacing: 0.05em;
  box-shadow: 0 12px 32px rgba(26, 35, 126, 0.3),
              0 3px 8px rgba(26, 35, 126, 0.2);
  cursor: pointer;
  transition: all 0.3s ease;
  width: 100%;
}
.logi-btn-submit:hover:not(:disabled) {
  opacity: 0.92;
  transform: translateY(-2px);
  box-shadow: 0 16px 40px rgba(26, 35, 126, 0.35),
              0 4px 12px rgba(26, 35, 126, 0.25);
}
.logi-btn-submit:active:not(:disabled) {
  transform: translateY(0);
  box-shadow: 0 8px 24px rgba(26, 35, 126, 0.25),
              0 2px 6px rgba(26, 35, 126, 0.15);
}
.logi-btn-submit:disabled {
  opacity: 0.65;
  cursor: not-allowed;
}
.logi-btn-submit__icon {
  font-size: 1.125rem;
  font-variation-settings: 'FILL' 1;
}

/* ===== RODAPÉ DO CARD ===== */
.logi-card-footer {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  margin-top: 2rem;
  padding-top: 2rem;
  border-top: 1px solid rgba(198, 197, 212, 0.15);
}
.logi-card-footer__dot {
  width: 0.35rem;
  height: 0.35rem;
  background: linear-gradient(135deg, var(--logi-outline-var), var(--logi-outline));
  border-radius: 50%;
}
.logi-card-footer__text {
  font-size: 0.7rem;
  color: var(--logi-on-surface-var);
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  margin: 0;
}

/* ===== RODAPÉ EXTERNO ===== */
.logi-footer {
  display: flex;
  justify-content: center;
  gap: 2.5rem;
  margin-top: 2rem;
  flex-wrap: wrap;
}
.logi-footer__link {
  font-size: 0.75rem;
  color: rgba(69, 70, 82, 0.65);
  font-weight: 600;
  text-decoration: none;
  transition: all 0.2s ease;
  position: relative;
}
.logi-footer__link::after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  width: 0;
  height: 1.5px;
  background: #1A237E;
  transition: width 0.2s ease;
}
.logi-footer__link:hover {
  color: #1A237E;
}
.logi-footer__link:hover::after {
  width: 100%;
}
</style>
