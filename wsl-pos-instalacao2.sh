#!/usr/bin/env bash
# WSL2 Ubuntu Forge WebNova Enterprise v2.0.0
# Preparacao enterprise-grade para Ubuntu no WSL2 com TUI WebNova local.
# Alvo: Ubuntu em WSL2 apos `wsl --install`.
# Execucao real por padrao, dry-run opcional e relatorio temporario somente sob demanda.

set -Eeuo pipefail
IFS=$'\n\t'

readonly SCRIPT_NAME="WSL2 Ubuntu Forge WebNova Enterprise"
readonly SCRIPT_VERSION="2.0.0-enterprise-forge"
readonly WEBNOVA_HOST_DEFAULT="127.0.0.1"
readonly WEBNOVA_PORT_DEFAULT="8797"
readonly WEBNOVA_LOCK_FILE_DEFAULT="/tmp/wsl2-ubuntu-forge-webnova-enterprise.lock"
readonly WEBNOVA_INSTALL_ROOT_DEFAULT="$HOME/.local/share/wsl2-ubuntu-forge-webnova"
readonly WEBNOVA_REPORT_PREFIX="wsl2-ubuntu-forge-report"
readonly CUDA_VERSION_DEFAULT="13.0.0"
readonly CUDA_PACKAGE_VERSION_DEFAULT="13-0"
readonly NVIDIA_CONTAINER_TOOLKIT_VERSION_DEFAULT="1.17.8-1"
readonly MIN_DISK_FREE_KB_DEFAULT="6291456"
readonly MIN_MEM_TOTAL_KB_DEFAULT="2097152"

WEBNOVA_HOST="${WEBNOVA_HOST:-$WEBNOVA_HOST_DEFAULT}"
WEBNOVA_PORT="${WEBNOVA_PORT:-$WEBNOVA_PORT_DEFAULT}"
WEBNOVA_LOCK_FILE="${WEBNOVA_LOCK_FILE:-$WEBNOVA_LOCK_FILE_DEFAULT}"
WEBNOVA_INSTALL_ROOT="${WEBNOVA_INSTALL_ROOT:-$WEBNOVA_INSTALL_ROOT_DEFAULT}"
WEBNOVA_DRY_RUN="${WEBNOVA_DRY_RUN:-0}"
WEBNOVA_ASSUME_YES="${WEBNOVA_ASSUME_YES:-1}"
WEBNOVA_ENABLE_AI_HEAVY="${WEBNOVA_ENABLE_AI_HEAVY:-0}"
WEBNOVA_SKIP_CUDA_WHEN_NO_GPU="${WEBNOVA_SKIP_CUDA_WHEN_NO_GPU:-0}"
CUDA_VERSION="${CUDA_VERSION:-$CUDA_VERSION_DEFAULT}"
CUDA_PACKAGE_VERSION="${CUDA_PACKAGE_VERSION:-$CUDA_PACKAGE_VERSION_DEFAULT}"
NVIDIA_CONTAINER_TOOLKIT_VERSION="${NVIDIA_CONTAINER_TOOLKIT_VERSION:-$NVIDIA_CONTAINER_TOOLKIT_VERSION_DEFAULT}"
MIN_DISK_FREE_KB="${MIN_DISK_FREE_KB:-$MIN_DISK_FREE_KB_DEFAULT}"
MIN_MEM_TOTAL_KB="${MIN_MEM_TOTAL_KB:-$MIN_MEM_TOTAL_KB_DEFAULT}"

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
export APT_LISTCHANGES_FRONTEND=none
export PAGER=cat
export SYSTEMD_PAGER=cat

C_RESET=$'\033[0m'
C_BOLD=$'\033[1m'
C_DIM=$'\033[2m'
C_RED=$'\033[31m'
C_GREEN=$'\033[32m'
C_YELLOW=$'\033[33m'
C_BLUE=$'\033[34m'
C_CYAN=$'\033[36m'
C_WHITE=$'\033[37m'

ACTIONS=()
CURRENT_ACTION=""
ACTION_STARTED_AT=0
LOCK_ACQUIRED=0

print_color() { local color="$1"; shift; printf '%b%s%b\n' "$color" "$*" "$C_RESET"; }
info() { print_color "$C_CYAN" "[INFO] $*"; }
ok() { print_color "$C_GREEN" "[OK] $*"; }
warn() { print_color "$C_YELLOW" "[AVISO] $*"; }
err() { print_color "$C_RED" "[ERRO] $*" >&2; }
header() { printf '\n%b==== %s ====%b\n' "$C_BOLD$C_BLUE" "$*" "$C_RESET"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }
is_dry_run() { [[ "${WEBNOVA_DRY_RUN:-0}" == "1" || "${WEBNOVA_DRY_RUN:-0}" == "true" ]]; }

sudo_cmd() {
  if [[ "${EUID}" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

json_escape() {
  local s=${1//\\/\\\\}
  s=${s//\"/\\\"}
  s=${s//$'\n'/\\n}
  s=${s//$'\r'/}
  printf '%s' "$s"
}

format_kb() {
  local kb="${1:-0}"
  awk -v kb="$kb" 'BEGIN{split("KB MB GB TB PB",u," "); v=kb; i=1; while(v>=1024 && i<5){v/=1024;i++} if(i==1) printf "%d %s", v,u[i]; else printf "%.2f %s", v,u[i]}'
}

disk_used_kb() { df -Pk / 2>/dev/null | awk 'NR==2{print $3+0}'; }
disk_free_kb() { df -Pk / 2>/dev/null | awk 'NR==2{print $4+0}'; }
mem_total_kb() { awk '/MemTotal:/ {print $2+0}' /proc/meminfo 2>/dev/null || echo 0; }

run_cmd() {
  local desc="$1"; shift
  info "$desc"
  printf '+ '
  printf '%q ' "$@"
  printf '\n'
  if is_dry_run; then
    warn "DRY-RUN: comando nao executado."
    return 0
  fi
  set +e
  "$@"
  local rc=$?
  set -e
  if (( rc == 0 )); then ok "$desc concluido."; else err "$desc falhou com codigo $rc."; fi
  return "$rc"
}

run_shell() {
  local desc="$1" body="$2"
  info "$desc"
  printf '+ bash -Eeuo pipefail -c %q\n' "$body"
  if is_dry_run; then
    warn "DRY-RUN: script shell nao executado."
    return 0
  fi
  set +e
  bash -Eeuo pipefail -c "$body"
  local rc=$?
  set -e
  if (( rc == 0 )); then ok "$desc concluido."; else err "$desc falhou com codigo $rc."; fi
  return "$rc"
}

retry_cmd() {
  local desc="$1" attempts="${WEBNOVA_RETRY_ATTEMPTS:-3}" delay="${WEBNOVA_RETRY_DELAY:-4}"
  shift
  local n=1 rc=0
  while (( n <= attempts )); do
    info "$desc tentativa $n/$attempts"
    set +e
    run_cmd "$desc" "$@"
    rc=$?
    set -e
    if (( rc == 0 )); then return 0; fi
    if (( n < attempts )); then
      warn "Tentativa $n falhou. Aguardando ${delay}s antes de repetir."
      sleep "$delay" || true
    fi
    n=$((n+1))
  done
  return "$rc"
}

retry_shell() {
  local desc="$1" body="$2" attempts="${WEBNOVA_RETRY_ATTEMPTS:-3}" delay="${WEBNOVA_RETRY_DELAY:-4}"
  local n=1 rc=0
  while (( n <= attempts )); do
    info "$desc tentativa $n/$attempts"
    set +e
    run_shell "$desc" "$body"
    rc=$?
    set -e
    if (( rc == 0 )); then return 0; fi
    if (( n < attempts )); then
      warn "Tentativa $n falhou. Aguardando ${delay}s antes de repetir."
      sleep "$delay" || true
    fi
    n=$((n+1))
  done
  return "$rc"
}

acquire_lock() {
  [[ "$LOCK_ACQUIRED" == "1" ]] && return 0
  if is_dry_run; then
    info "DRY-RUN: lock nao sera criado."
    return 0
  fi
  local lock_dir
  lock_dir="$(dirname "$WEBNOVA_LOCK_FILE")"
  mkdir -p "$lock_dir"
  if ( set -o noclobber; printf '%s\n' "$$" > "$WEBNOVA_LOCK_FILE" ) 2>/dev/null; then
    LOCK_ACQUIRED=1
    trap release_lock EXIT INT TERM
    ok "Lock de execucao adquirido: $WEBNOVA_LOCK_FILE"
    return 0
  fi
  local existing_pid
  existing_pid="$(cat "$WEBNOVA_LOCK_FILE" 2>/dev/null || true)"
  if [[ "$existing_pid" =~ ^[0-9]+$ ]] && ! kill -0 "$existing_pid" 2>/dev/null; then
    warn "Lock antigo detectado e processo inexistente. Removendo lock obsoleto."
    rm -f "$WEBNOVA_LOCK_FILE"
    acquire_lock
    return $?
  fi
  err "Ja existe uma execucao ativa ou lock pendente: $WEBNOVA_LOCK_FILE PID=${existing_pid:-desconhecido}"
  return 9
}

release_lock() {
  if [[ "$LOCK_ACQUIRED" == "1" ]]; then
    rm -f "$WEBNOVA_LOCK_FILE" 2>/dev/null || true
    LOCK_ACQUIRED=0
  fi
}

is_wsl2() {
  grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null || return 1
  [[ -n "${WSL_INTEROP:-}" || -n "${WSL_DISTRO_NAME:-}" || -d /run/WSL || -e /proc/sys/fs/binfmt_misc/WSLInterop ]]
}

is_ubuntu_like() {
  [[ -r /etc/os-release ]] || return 1
  # shellcheck disable=SC1091
  . /etc/os-release
  [[ "${ID:-}" == "ubuntu" || "${ID_LIKE:-}" == *"ubuntu"* || "${ID_LIKE:-}" == *"debian"* ]]
}

ubuntu_codename() {
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    printf '%s' "${VERSION_CODENAME:-${UBUNTU_CODENAME:-}}"
  fi
}

ubuntu_pretty_name() {
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    printf '%s' "${PRETTY_NAME:-desconhecido}"
  else
    printf 'desconhecido'
  fi
}

require_wsl2_ubuntu() {
  if ! is_wsl2; then
    err "Este instalador foi criado para rodar dentro do WSL2. Ambiente atual nao parece WSL2."
    return 1
  fi
  if ! is_ubuntu_like; then
    err "Este instalador foi criado para Ubuntu/derivados compativeis com apt."
    return 1
  fi
  ok "Ambiente WSL2 Ubuntu compativel detectado."
}

require_sudo() {
  if [[ "${EUID}" -eq 0 ]]; then
    ok "Executando como root."
    return 0
  fi
  retry_cmd "Validando sessao sudo" sudo -v
}

check_apt_lock() {
  local locks=(/var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/cache/apt/archives/lock)
  if command_exists fuser; then
    local lock
    for lock in "${locks[@]}"; do
      if sudo_cmd fuser "$lock" >/dev/null 2>&1; then
        err "APT/DPKG esta em uso: $lock. Feche outro apt/dpkg antes de continuar."
        return 1
      fi
    done
  fi
}

preflight_enterprise() {
  header "Auditoria pre-instalacao enterprise"
  require_wsl2_ubuntu
  local free_kb total_mem codename
  free_kb="$(disk_free_kb)"
  total_mem="$(mem_total_kb)"
  codename="$(ubuntu_codename)"
  printf 'Distro: %s\n' "$(ubuntu_pretty_name)"
  printf 'Codename: %s\n' "${codename:-desconhecido}"
  printf 'Kernel: %s\n' "$(uname -r 2>/dev/null || true)"
  printf 'PID 1: %s\n' "$(ps -p 1 -o comm= 2>/dev/null | tr -d ' ' || true)"
  printf 'Disco livre em /: %s\n' "$(format_kb "$free_kb")"
  printf 'Memoria total: %s\n' "$(format_kb "$total_mem")"
  if (( free_kb < MIN_DISK_FREE_KB )); then warn "Disco livre abaixo do recomendado: $(format_kb "$MIN_DISK_FREE_KB")"; fi
  if (( total_mem < MIN_MEM_TOTAL_KB )); then warn "Memoria total abaixo do recomendado: $(format_kb "$MIN_MEM_TOTAL_KB")"; fi
  check_apt_lock || return 1
  if command_exists curl; then retry_cmd "Testando rede HTTPS" curl -fsSL --connect-timeout 10 https://api.github.com/rate_limit >/dev/null || warn "Rede HTTPS falhou ou GitHub bloqueou a consulta."; else warn "curl ainda nao instalado."; fi
  if [[ -f /etc/wsl.conf ]]; then printf '\n/etc/wsl.conf:\n'; sed -n '1,160p' /etc/wsl.conf || true; else warn "/etc/wsl.conf ausente."; fi
  ok "Auditoria pre-instalacao concluida."
}

apt_update() { check_apt_lock; retry_cmd "Atualizando indice APT" sudo_cmd apt-get update; }
apt_full_upgrade() { check_apt_lock; retry_cmd "Atualizando pacotes instalados" sudo_cmd apt-get -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold full-upgrade; }
apt_install() {
  local desc="$1"; shift
  check_apt_lock
  retry_cmd "$desc" sudo_cmd apt-get install -y --no-install-recommends -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold "$@"
}

ensure_install_root() { run_cmd "Criando diretório local do Forge" mkdir -p "$WEBNOVA_INSTALL_ROOT"; }

add_action() {
  ACTIONS+=("$1|$2|$3|$4|$5|$6")
}

init_actions() {
  ACTIONS=()
  add_action "status" "Diagnostico" "Status do ambiente" "Mostra WSL2, Ubuntu, disco, memoria, Docker, GPU, Python, Node e rede." "read" "overview"
  add_action "preflight_audit" "Diagnostico" "Auditoria pre-instalacao" "Valida ambiente, disco, memoria, APT lock, rede, systemd e WSL antes de instalar." "read" "overview"
  add_action "install_base" "Base" "Base WSL2 essencial" "Atualiza o sistema e instala certificados, curl, wget, gnupg, locales, compactadores e utilitarios." "write" "overview"
  add_action "install_terminal" "Base" "Terminal premium" "Instala jq, yq, tree, htop, btop, ncdu, tmux, fzf, ripgrep, fd, bat, shellcheck e shfmt." "write" "overview"
  add_action "install_build" "Build" "Compiladores e bibliotecas" "Instala build-essential, pkg-config, gcc/g++, cmake, ninja, autoconf, automake e libs dev." "write" "overview"
  add_action "install_git_gh" "Git" "Git, SSH e GitHub CLI" "Instala Git, Git LFS, OpenSSH e GitHub CLI pelo repositorio oficial." "write" "overview"
  add_action "install_python_core" "Python" "Python Core" "Instala python3, pip, venv, dev headers, pipx, setuptools, wheel e build." "write" "python"
  add_action "install_python_modern" "Python" "Python Modern Tools" "Instala uv, ruff, pytest, mypy, pyright, pre-commit, nox, tox e pip-audit via pipx." "write" "python"
  add_action "install_python_backend" "Python" "Python Backend Lab" "Cria venv isolada com FastAPI, Uvicorn, Pydantic, SQLAlchemy, Alembic, Psycopg, Redis, Celery e HTTPX." "write" "python"
  add_action "install_python_data" "Python" "Python Data/Notebook Lab" "Cria venv isolada com JupyterLab, NumPy, Pandas, Polars, PyArrow, SciPy, DuckDB e scikit-learn." "write" "python"
  add_action "install_python_ai" "Python" "Python IA/LLM Lab" "Cria venv isolada com Transformers, Accelerate, Datasets, LangChain, LlamaIndex, ChromaDB e ONNX Runtime." "heavy" "python"
  add_action "install_node" "Node" "Node.js moderno" "Instala Node/npm, Corepack, PNPM, Yarn, TypeScript e npm-check-updates." "write" "node"
  add_action "install_docker" "Docker" "Docker Engine + Compose" "Instala Docker pelo repositorio oficial, Buildx, Docker Compose Plugin e wrapper docker-compose." "write" "docker"
  add_action "install_cuda" "GPU/CUDA" "CUDA WSL + NVIDIA Toolkit" "Instala CUDA Toolkit WSL, NVIDIA Container Toolkit e configura runtime Docker NVIDIA." "heavy" "cuda"
  add_action "audit_docker" "Auditoria" "Auditoria Docker" "Mostra Docker, Compose, daemon, contextos, runtime NVIDIA e uso do sistema." "read" "docker"
  add_action "audit_python_node" "Auditoria" "Auditoria Python/Node" "Mostra ferramentas Python, venvs Forge, Node, npm, pnpm, yarn, corepack e TypeScript." "read" "python"
  add_action "audit_cuda" "Auditoria" "Auditoria CUDA/NVIDIA" "Mostra nvidia-smi, nvcc, nvidia-ctk, bibliotecas WSL e teste Docker GPU quando disponivel." "read" "cuda"
  add_action "validate_all" "Validacao" "Validar stack completa" "Executa diagnosticos e versoes das ferramentas principais." "read" "overview"
  add_action "export_report" "Relatorio" "Exportar relatorio temporario" "Gera arquivo temporario markdown em /tmp somente quando solicitado." "read" "overview"
  add_action "install_all" "Execucao" "Instalar tudo definido" "Executa auditoria, base, terminal, build, Git/GH, Python, Node, Docker, CUDA e validacao." "heavy" "overview"
}

action_function_exists() { declare -F "action_$1" >/dev/null 2>&1; }

list_actions_json() {
  init_actions
  printf '['
  local i id group title desc risk page
  for i in "${!ACTIONS[@]}"; do
    IFS='|' read -r id group title desc risk page <<< "${ACTIONS[$i]}"
    (( i > 0 )) && printf ','
    printf '{"id":"%s","group":"%s","title":"%s","description":"%s","risk":"%s","page":"%s"}' \
      "$(json_escape "$id")" "$(json_escape "$group")" "$(json_escape "$title")" "$(json_escape "$desc")" "$(json_escape "$risk")" "$(json_escape "$page")"
  done
  printf ']\n'
}

menu_preview() {
  init_actions
  local i id group title desc risk page
  printf '%-3s %-24s %-16s %-8s %s\n' "N" "ACAO" "GRUPO" "RISCO" "TITULO"
  printf '%-3s %-24s %-16s %-8s %s\n' "---" "------------------------" "----------------" "--------" "------------------------------"
  for i in "${!ACTIONS[@]}"; do
    IFS='|' read -r id group title desc risk page <<< "${ACTIONS[$i]}"
    printf '%-3s %-24s %-16s %-8s %s\n' "$((i+1))" "$id" "$group" "$risk" "$title"
  done
}

status_report() {
  header "Diagnostico do ambiente"
  printf 'Script: %s v%s\n' "$SCRIPT_NAME" "$SCRIPT_VERSION"
  printf 'Data: %s\n' "$(date -Is)"
  printf 'Usuario: %s\n' "${USER:-desconhecido}"
  printf 'HOME: %s\n' "${HOME:-desconhecido}"
  printf 'Install root: %s\n' "$WEBNOVA_INSTALL_ROOT"
  printf 'Dry-run: %s\n' "$WEBNOVA_DRY_RUN"
  printf 'Distro: %s\n' "$(ubuntu_pretty_name)"
  printf 'Codename: %s\n' "$(ubuntu_codename || true)"
  printf 'Kernel: %s\n' "$(uname -r 2>/dev/null || true)"
  printf 'WSL2: '; if is_wsl2; then echo "sim"; else echo "nao detectado"; fi
  printf 'systemd PID1: %s\n' "$(ps -p 1 -o comm= 2>/dev/null | tr -d ' ' || true)"
  printf '\nDisco:\n'; df -h / || true
  printf '\nMemoria:\n'; free -h || true
  printf '\nFerramentas:\n'
  for tool in git gh python3 pipx uv ruff pytest mypy pyright pre-commit node npm pnpm yarn corepack docker docker-compose nvidia-smi nvcc nvidia-ctk; do
    if command_exists "$tool"; then
      printf '  [ok] %-18s %s\n' "$tool" "$(command -v "$tool")"
    else
      printf '  [--] %-18s ausente\n' "$tool"
    fi
  done
  printf '\nVersoes rapidas:\n'
  git --version 2>/dev/null || true
  gh --version 2>/dev/null | head -n 1 || true
  python3 --version 2>/dev/null || true
  python3 -m pip --version 2>/dev/null || true
  node --version 2>/dev/null || true
  npm --version 2>/dev/null || true
  docker --version 2>/dev/null || true
  docker compose version 2>/dev/null || true
  docker-compose version 2>/dev/null || true
  nvidia-smi 2>/dev/null || true
  nvcc --version 2>/dev/null || true
}

action_status() { status_report; }
action_preflight_audit() { preflight_enterprise; }

action_install_base() {
  header "Base WSL2 essencial"
  acquire_lock
  require_wsl2_ubuntu
  require_sudo
  apt_update
  apt_full_upgrade
  apt_install "Instalando base essencial" \
    apt-transport-https ca-certificates curl wget gnupg lsb-release software-properties-common \
    locales tzdata unzip zip tar xz-utils file less nano vim rsync sudo procps psmisc \
    apt-utils debian-archive-keyring
  run_cmd "Gerando locale UTF-8 quando disponivel" sudo_cmd locale-gen en_US.UTF-8 pt_BR.UTF-8 C.UTF-8
  ok "Base essencial concluida."
}

action_install_terminal() {
  header "Terminal premium"
  acquire_lock
  require_wsl2_ubuntu
  require_sudo
  apt_update
  apt_install "Instalando ferramentas modernas de terminal" \
    git git-lfs jq yq tree htop btop ncdu tmux fzf ripgrep fd-find bat shellcheck shfmt \
    direnv lsof strace iproute2 iputils-ping dnsutils net-tools traceroute netcat-openbsd socat \
    ca-certificates curl wget gnupg
  if command_exists fdfind && ! command_exists fd; then run_cmd "Criando compatibilidade fd -> fdfind" sudo_cmd ln -sf "$(command -v fdfind)" /usr/local/bin/fd; fi
  if command_exists batcat && ! command_exists bat; then run_cmd "Criando compatibilidade bat -> batcat" sudo_cmd ln -sf "$(command -v batcat)" /usr/local/bin/bat; fi
  ok "Terminal premium concluido."
}

action_install_build() {
  header "Compiladores e bibliotecas"
  acquire_lock
  require_wsl2_ubuntu
  require_sudo
  apt_update
  apt_install "Instalando toolchain de compilacao" \
    build-essential pkg-config make gcc g++ libc6-dev cmake ninja-build autoconf automake libtool \
    libssl-dev libffi-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev liblzma-dev \
    libpq-dev libxml2-dev libxmlsec1-dev libcurl4-openssl-dev libjpeg-dev libpng-dev
  ok "Build tools concluidos."
}

action_install_git_gh() {
  header "Git, SSH e GitHub CLI"
  acquire_lock
  require_wsl2_ubuntu
  require_sudo
  apt_update
  apt_install "Instalando Git, Git LFS e SSH" git git-lfs openssh-client openssh-server ca-certificates curl gnupg
  run_cmd "Criando diretorio de keyrings APT" sudo_cmd install -m 0755 -d /etc/apt/keyrings
  retry_shell "Configurando repositorio oficial do GitHub CLI" '
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
'
  apt_update
  apt_install "Instalando GitHub CLI" gh
  run_cmd "Ativando Git LFS" git lfs install --skip-repo
  ok "Git/GitHub CLI concluido."
}

action_install_python_core() {
  header "Python Core"
  acquire_lock
  require_wsl2_ubuntu
  require_sudo
  apt_update
  apt_install "Instalando Python essencial" \
    python3 python3-pip python3-venv python3-dev python-is-python3 pipx python3-setuptools python3-wheel python3-build
  run_cmd "Garantindo PATH do pipx" python3 -m pipx ensurepath
  run_cmd "Atualizando pip/setuptools/wheel/build no usuario" python3 -m pip install --user --upgrade pip setuptools wheel build
  ok "Python Core concluido."
}

pipx_install_or_upgrade() {
  local package="$1"
  if is_dry_run; then warn "DRY-RUN: pipx install/upgrade $package"; return 0; fi
  if python3 -m pipx list 2>/dev/null | grep -qE "package ${package}([ ,]|$)"; then
    retry_cmd "Atualizando ferramenta Python via pipx: $package" python3 -m pipx upgrade "$package"
  else
    retry_cmd "Instalando ferramenta Python via pipx: $package" python3 -m pipx install "$package"
  fi
}

action_install_python_modern() {
  header "Python Modern Tools"
  action_install_python_core
  local tools=(uv ruff pytest mypy pyright pre-commit nox tox pip-audit bandit detect-secrets commitizen)
  local tool
  for tool in "${tools[@]}"; do pipx_install_or_upgrade "$tool"; done
  ok "Python Modern Tools concluido."
}

ensure_venv_package_group() {
  local name="$1"; shift
  local venv="$WEBNOVA_INSTALL_ROOT/venvs/$name"
  ensure_install_root
  if [[ ! -d "$venv" ]]; then run_cmd "Criando venv $name" python3 -m venv "$venv"; fi
  run_cmd "Atualizando pip da venv $name" "$venv/bin/python" -m pip install --upgrade pip setuptools wheel
  retry_cmd "Instalando pacotes na venv $name" "$venv/bin/python" -m pip install --upgrade "$@"
  ok "Venv pronta: $venv"
}

action_install_python_backend() {
  header "Python Backend Lab"
  action_install_python_core
  ensure_venv_package_group backend fastapi uvicorn gunicorn pydantic pydantic-settings sqlalchemy alembic psycopg[binary] asyncpg redis celery rq httpx python-dotenv typer rich loguru
}

action_install_python_data() {
  header "Python Data/Notebook Lab"
  action_install_python_core
  ensure_venv_package_group data jupyterlab ipykernel notebook numpy pandas polars pyarrow scipy matplotlib scikit-learn duckdb requests httpx tqdm
}

action_install_python_ai() {
  header "Python IA/LLM Lab"
  if [[ "$WEBNOVA_ENABLE_AI_HEAVY" != "1" ]]; then
    warn "Pacotes IA/LLM sao pesados. Defina WEBNOVA_ENABLE_AI_HEAVY=1 para executar esta acao."
    return 0
  fi
  action_install_python_core
  ensure_venv_package_group ai transformers accelerate datasets sentence-transformers langchain llama-index chromadb onnxruntime tokenizers safetensors
}

action_install_node() {
  header "Node.js moderno"
  acquire_lock
  require_wsl2_ubuntu
  require_sudo
  apt_update
  apt_install "Instalando Node.js e npm via apt" nodejs npm ca-certificates curl gnupg
  if command_exists corepack; then run_cmd "Ativando Corepack" corepack enable; else warn "corepack nao encontrado nesta versao do Node."; fi
  retry_cmd "Instalando ferramentas Node globais" sudo_cmd npm install -g pnpm yarn typescript tsx npm-check-updates
  ok "Node.js moderno concluido."
}

action_install_docker() {
  header "Docker Engine + Docker Compose"
  acquire_lock
  require_wsl2_ubuntu
  require_sudo
  apt_update
  apt_install "Instalando prerequisitos Docker" ca-certificates curl gnupg lsb-release
  run_cmd "Criando diretorio de keyrings Docker" sudo_cmd install -m 0755 -d /etc/apt/keyrings
  retry_shell "Configurando repositorio oficial Docker" '
if [[ ! -f /etc/apt/keyrings/docker.asc ]]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc >/dev/null
  sudo chmod a+r /etc/apt/keyrings/docker.asc
fi
. /etc/os-release
CODENAME="${VERSION_CODENAME:-${UBUNTU_CODENAME:-}}"
if [[ -z "$CODENAME" ]]; then echo "Nao foi possivel detectar codename Ubuntu." >&2; exit 1; fi
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
'
  apt_update
  apt_install "Instalando Docker Engine, Buildx e Compose Plugin" docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  if [[ -n "${USER:-}" && "${USER:-}" != "root" ]]; then run_cmd "Adicionando usuario atual ao grupo docker" sudo_cmd usermod -aG docker "$USER"; fi
  run_shell "Criando wrapper docker-compose compativel" '
sudo tee /usr/local/bin/docker-compose >/dev/null <<"WRAP"
#!/usr/bin/env bash
exec docker compose "$@"
WRAP
sudo chmod +x /usr/local/bin/docker-compose
'
  if command_exists systemctl && systemctl list-unit-files >/dev/null 2>&1; then
    run_cmd "Habilitando Docker" sudo_cmd systemctl enable docker
    run_cmd "Iniciando/Reiniciando Docker" sudo_cmd systemctl restart docker
  else
    run_cmd "Iniciando Docker via service" sudo_cmd service docker start
  fi
  run_cmd "Validando Docker" docker --version
  run_cmd "Validando Docker Compose Plugin" docker compose version
  run_cmd "Validando wrapper docker-compose" docker-compose version
  ok "Docker Engine + Compose concluido."
}

action_install_cuda() {
  header "CUDA WSL + NVIDIA Container Toolkit"
  acquire_lock
  require_wsl2_ubuntu
  require_sudo
  if ! command_exists nvidia-smi; then
    warn "nvidia-smi nao foi encontrado no WSL. Instale/atualize o driver NVIDIA no Windows antes do CUDA WSL."
    if [[ "$WEBNOVA_SKIP_CUDA_WHEN_NO_GPU" == "1" ]]; then
      warn "WEBNOVA_SKIP_CUDA_WHEN_NO_GPU=1 ativo. Pulando CUDA."
      return 0
    fi
  fi
  apt_update
  apt_install "Instalando prerequisitos CUDA/NVIDIA" ca-certificates curl wget gnupg lsb-release
  local workdir="$WEBNOVA_INSTALL_ROOT/cache/cuda"
  run_cmd "Criando diretorio temporario CUDA" mkdir -p "$workdir"
  if ! is_dry_run; then pushd "$workdir" >/dev/null; fi

  # Sequencia preservada e endurecida a partir do anexo do usuario:
  # remove deb antigo, baixa pin, instala repositorio local CUDA WSL, instala toolkit,
  # instala NVIDIA Container Toolkit e configura runtime Docker.
  run_cmd "Removendo .deb CUDA local antigo" rm -f "cuda-repo-wsl-ubuntu-${CUDA_PACKAGE_VERSION}-local_${CUDA_VERSION}-1_amd64.deb"
  retry_cmd "Baixando cuda-wsl-ubuntu.pin" wget -O cuda-wsl-ubuntu.pin https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
  run_cmd "Instalando pin do repositorio CUDA" sudo_cmd mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
  retry_cmd "Baixando CUDA repo local WSL ${CUDA_VERSION}" wget -O "cuda-repo-wsl-ubuntu-${CUDA_PACKAGE_VERSION}-local_${CUDA_VERSION}-1_amd64.deb" "https://developer.download.nvidia.com/compute/cuda/${CUDA_VERSION}/local_installers/cuda-repo-wsl-ubuntu-${CUDA_PACKAGE_VERSION}-local_${CUDA_VERSION}-1_amd64.deb"
  run_cmd "Instalando pacote repo CUDA local" sudo_cmd dpkg -i "cuda-repo-wsl-ubuntu-${CUDA_PACKAGE_VERSION}-local_${CUDA_VERSION}-1_amd64.deb"
  run_cmd "Copiando keyring CUDA" sudo_cmd cp "/var/cuda-repo-wsl-ubuntu-${CUDA_PACKAGE_VERSION}-local/cuda-"*"-keyring.gpg" /usr/share/keyrings/
  apt_update
  retry_cmd "Instalando cuda-toolkit-${CUDA_PACKAGE_VERSION}" sudo_cmd apt-get -y install "cuda-toolkit-${CUDA_PACKAGE_VERSION}"

  retry_shell "Configurando repositorio NVIDIA Container Toolkit" '
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
sudo curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sudo sed '\''s#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g'\'' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list >/dev/null
sudo sed -i -e '\''/experimental/ s/^#//g'\'' /etc/apt/sources.list.d/nvidia-container-toolkit.list
'
  apt_update
  if [[ "$NVIDIA_CONTAINER_TOOLKIT_VERSION" == "latest" ]]; then
    retry_cmd "Instalando NVIDIA Container Toolkit latest" sudo_cmd apt-get install -y nvidia-container-toolkit nvidia-container-toolkit-base libnvidia-container-tools libnvidia-container1
  elif apt-cache madison nvidia-container-toolkit 2>/dev/null | grep -q "${NVIDIA_CONTAINER_TOOLKIT_VERSION}"; then
    retry_cmd "Instalando NVIDIA Container Toolkit ${NVIDIA_CONTAINER_TOOLKIT_VERSION}" sudo_cmd apt-get install -y \
      "nvidia-container-toolkit=${NVIDIA_CONTAINER_TOOLKIT_VERSION}" \
      "nvidia-container-toolkit-base=${NVIDIA_CONTAINER_TOOLKIT_VERSION}" \
      "libnvidia-container-tools=${NVIDIA_CONTAINER_TOOLKIT_VERSION}" \
      "libnvidia-container1=${NVIDIA_CONTAINER_TOOLKIT_VERSION}"
  else
    warn "Versao ${NVIDIA_CONTAINER_TOOLKIT_VERSION} nao encontrada. Instalando latest disponivel."
    retry_cmd "Instalando NVIDIA Container Toolkit latest" sudo_cmd apt-get install -y nvidia-container-toolkit nvidia-container-toolkit-base libnvidia-container-tools libnvidia-container1
  fi
  run_cmd "Configurando runtime NVIDIA para Docker" sudo_cmd nvidia-ctk runtime configure --runtime=docker
  if command_exists systemctl && systemctl list-unit-files >/dev/null 2>&1; then run_cmd "Reiniciando Docker via systemctl" sudo_cmd systemctl restart docker; else run_cmd "Reiniciando Docker via service" sudo_cmd service docker restart; fi
  if ! is_dry_run; then popd >/dev/null; fi
  run_cmd "Validando nvidia-ctk" nvidia-ctk --version
  run_cmd "Validando nvcc" bash -c 'command -v nvcc && nvcc --version || true'
  ok "CUDA WSL + NVIDIA Container Toolkit concluido."
}

action_audit_docker() {
  header "Auditoria Docker"
  if ! command_exists docker; then warn "Docker nao instalado."; return 0; fi
  run_cmd "Docker version" docker --version
  run_cmd "Docker Compose version" docker compose version
  docker-compose version 2>/dev/null || true
  run_cmd "Docker info" docker info
  run_cmd "Docker context list" docker context ls
  run_cmd "Docker system df" docker system df
  if command_exists nvidia-ctk; then run_cmd "NVIDIA CTK version" nvidia-ctk --version; fi
  if docker info 2>/dev/null | grep -qi nvidia; then ok "Runtime NVIDIA aparece no Docker info."; else warn "Runtime NVIDIA nao apareceu no Docker info."; fi
}

action_audit_python_node() {
  header "Auditoria Python/Node"
  for cmd in python3 pip pipx uv ruff pytest mypy pyright pre-commit nox tox pip-audit node npm pnpm yarn corepack tsc tsx; do
    if command_exists "$cmd"; then
      printf '\n--- %s ---\n' "$cmd"
      "$cmd" --version 2>/dev/null || "$cmd" version 2>/dev/null || true
      command -v "$cmd" || true
    else
      warn "$cmd ausente"
    fi
  done
  printf '\nVenvs Forge:\n'
  find "$WEBNOVA_INSTALL_ROOT/venvs" -maxdepth 2 -type f -name python -print 2>/dev/null || true
}

action_audit_cuda() {
  header "Auditoria CUDA/NVIDIA"
  if command_exists nvidia-smi; then run_cmd "nvidia-smi" nvidia-smi; else warn "nvidia-smi ausente no WSL."; fi
  if command_exists nvcc; then run_cmd "nvcc --version" nvcc --version; else warn "nvcc ausente."; fi
  if command_exists nvidia-ctk; then run_cmd "nvidia-ctk --version" nvidia-ctk --version; else warn "nvidia-ctk ausente."; fi
  printf '\nBibliotecas WSL NVIDIA:\n'
  ls -la /usr/lib/wsl/lib 2>/dev/null || warn "/usr/lib/wsl/lib nao encontrado."
  if command_exists docker && docker info >/dev/null 2>&1; then
    run_cmd "Teste Docker GPU leve" docker run --rm --gpus all nvidia/cuda:13.0.0-base-ubuntu24.04 nvidia-smi || warn "Teste Docker GPU falhou. Verifique driver Windows, Docker e runtime NVIDIA."
  else
    warn "Docker daemon indisponivel para teste GPU."
  fi
}

action_validate_all() {
  header "Validacao completa"
  status_report
  action_audit_python_node || true
  action_audit_docker || true
  action_audit_cuda || true
  ok "Validacao concluida."
}

generate_report_stdout() {
  printf '# Relatorio temporario - WSL2 Ubuntu Forge WebNova Enterprise\n\n'
  printf -- '- Data: %s\n' "$(date -Is)"
  printf -- '- Script: %s v%s\n' "$SCRIPT_NAME" "$SCRIPT_VERSION"
  printf -- '- Usuario: %s\n' "${USER:-desconhecido}"
  printf -- '- Distro: %s\n' "$(ubuntu_pretty_name)"
  printf -- '- Kernel: %s\n' "$(uname -r 2>/dev/null || true)"
  printf -- '- WSL2: '; if is_wsl2; then printf 'sim\n'; else printf 'nao detectado\n'; fi
  printf -- '- Dry-run: %s\n\n' "$WEBNOVA_DRY_RUN"
  printf '## Disco\n\n```\n'; df -h / || true; printf '```\n\n'
  printf '## Memoria\n\n```\n'; free -h || true; printf '```\n\n'
  printf '## Ferramentas\n\n```\n'
  for tool in git gh python3 pipx uv ruff node npm pnpm docker docker-compose nvidia-smi nvcc nvidia-ctk; do
    printf '%-18s %s\n' "$tool" "$(command -v "$tool" 2>/dev/null || echo ausente)"
  done
  printf '```\n'
}

action_export_report() {
  header "Exportar relatorio temporario"
  local output="${WEBNOVA_REPORT_PATH:-/tmp/${WEBNOVA_REPORT_PREFIX}-$(date +%Y%m%d-%H%M%S).md}"
  if is_dry_run; then warn "DRY-RUN: relatorio seria criado em $output"; generate_report_stdout; return 0; fi
  generate_report_stdout > "$output"
  ok "Relatorio temporario criado: $output"
  printf '%s\n' "$output"
}

run_subaction() {
  local action="$1"
  printf '\n%s\n' "--------------------------------------------------------------------------------"
  info "Subacao: $action"
  run_action_enterprise "$action"
}

action_install_all() {
  header "Instalacao completa definida"
  acquire_lock
  run_subaction preflight_audit
  run_subaction install_base
  run_subaction install_terminal
  run_subaction install_build
  run_subaction install_git_gh
  run_subaction install_python_core
  run_subaction install_python_modern
  run_subaction install_python_backend
  run_subaction install_python_data
  if [[ "$WEBNOVA_ENABLE_AI_HEAVY" == "1" ]]; then run_subaction install_python_ai; else warn "Python IA/LLM pesado nao entra no install_all sem WEBNOVA_ENABLE_AI_HEAVY=1."; fi
  run_subaction install_node
  run_subaction install_docker
  run_subaction install_cuda
  run_subaction validate_all
  ok "Instalacao completa finalizada."
}

dispatch_impl() {
  local action="${1:-}"
  case "$action" in
    status) action_status ;;
    preflight_audit) action_preflight_audit ;;
    install_base) action_install_base ;;
    install_terminal) action_install_terminal ;;
    install_build) action_install_build ;;
    install_git_gh) action_install_git_gh ;;
    install_python_core) action_install_python_core ;;
    install_python_modern) action_install_python_modern ;;
    install_python_backend) action_install_python_backend ;;
    install_python_data) action_install_python_data ;;
    install_python_ai) action_install_python_ai ;;
    install_node) action_install_node ;;
    install_docker) action_install_docker ;;
    install_cuda) action_install_cuda ;;
    audit_docker) action_audit_docker ;;
    audit_python_node) action_audit_python_node ;;
    audit_cuda) action_audit_cuda ;;
    validate_all) action_validate_all ;;
    export_report) action_export_report ;;
    install_all) action_install_all ;;
    *) err "Acao nao existe: $action"; return 2 ;;
  esac
}

run_action_enterprise() {
  local action="${1:-}"
  CURRENT_ACTION="$action"
  ACTION_STARTED_AT="$(date +%s)"
  local before_kb after_kb freed_kb rc elapsed
  before_kb="$(disk_used_kb)"
  printf '\nMETRICA antes: disco usado em / = %s\n' "$(format_kb "$before_kb")"
  set +e
  dispatch_impl "$action"
  rc=$?
  set -e
  after_kb="$(disk_used_kb)"
  freed_kb=$(( before_kb - after_kb ))
  elapsed=$(( $(date +%s) - ACTION_STARTED_AT ))
  printf 'METRICA depois: disco usado em / = %s\n' "$(format_kb "$after_kb")"
  if (( freed_kb >= 0 )); then printf 'METRICA delta: %s liberado/liquido\n' "$(format_kb "$freed_kb")"; else printf 'METRICA delta: %s adicionado/liquido\n' "$(format_kb "$((-freed_kb))")"; fi
  printf 'METRICA tempo: %ss\n' "$elapsed"
  printf 'METRICA retorno: %s\n' "$rc"
  return "$rc"
}

cli_menu() {
  init_actions
  while true; do
    clear || true
    header "$SCRIPT_NAME v$SCRIPT_VERSION - CLI"
    menu_preview
    printf '\nDigite o numero, ID da acao ou q para sair: '
    local choice action=""
    read -r choice
    [[ "$choice" == "q" || "$choice" == "Q" ]] && break
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#ACTIONS[@]} )); then
      IFS='|' read -r action _ <<< "${ACTIONS[$((choice-1))]}"
    else
      action="$choice"
    fi
    printf 'Dry-run? [s/N]: '
    local dry
    read -r dry
    if [[ "$dry" =~ ^[sS]$ ]]; then WEBNOVA_DRY_RUN=1; else WEBNOVA_DRY_RUN=0; fi
    run_action_enterprise "$action" || true
    printf '\nPressione ENTER para continuar...'
    read -r _
  done
}

run_webnova_server() {
  if ! command_exists python3; then err "python3 nao encontrado. Rode: sudo apt update && sudo apt install -y python3"; exit 1; fi
  local port="${WEBNOVA_PORT:-$WEBNOVA_PORT_DEFAULT}"
  local token
  token="$(python3 - <<'PYTOK'
import secrets
print(secrets.token_urlsafe(24))
PYTOK
)"
  export WEBNOVA_SCRIPT_PATH="$0"
  export WEBNOVA_TOKEN="$token"
  export WEBNOVA_PORT="$port"
  export WEBNOVA_HOST="$WEBNOVA_HOST"
  header "$SCRIPT_NAME v$SCRIPT_VERSION"
  ok "Servidor WebNova local: http://${WEBNOVA_HOST}:${port}/?token=${token}"
  warn "Servidor limitado a 127.0.0.1. Copie a URL para o navegador do Windows se nao abrir automaticamente."
  if command_exists powershell.exe; then powershell.exe -NoProfile -Command "Start-Process 'http://${WEBNOVA_HOST}:${port}/?token=${token}'" >/dev/null 2>&1 || true; fi
  python3 - <<'PYWEBNOVA'
import json, os, queue, subprocess, threading, time, urllib.parse
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

HOST=os.environ.get('WEBNOVA_HOST','127.0.0.1')
PORT=int(os.environ.get('WEBNOVA_PORT','8797'))
TOKEN=os.environ.get('WEBNOVA_TOKEN','')
SCRIPT=os.environ.get('WEBNOVA_SCRIPT_PATH','')
JOBS={}
HISTORY=[]

def run_script(args, timeout=90):
    p=subprocess.run([SCRIPT]+args,text=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=timeout)
    if p.returncode!=0:
        raise RuntimeError(p.stderr or p.stdout)
    return p.stdout

def actions():
    return json.loads(run_script(['--list-actions-json']))

def status_text():
    p=subprocess.run([SCRIPT,'--run-action','status'],text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,env={**os.environ,'WEBNOVA_DRY_RUN':'0'},timeout=90)
    return {'returncode':p.returncode,'text':p.stdout}

def report_text():
    p=subprocess.run([SCRIPT,'--report-stdout'],text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=90)
    return p.stdout

def start_job(action,dry_run=False,confirm=''):
    if action=='install_all' and confirm!='INSTALAR-TUDO':
        raise ValueError('Para install_all digite INSTALAR-TUDO no modal de confirmacao.')
    if action=='install_cuda' and confirm not in ('INSTALAR-CUDA','INSTALAR-TUDO'):
        raise ValueError('Para install_cuda digite INSTALAR-CUDA no modal de confirmacao.')
    job_id=f"job-{int(time.time()*1000)}-{len(JOBS)+1}"
    q=queue.Queue()
    env=os.environ.copy()
    env['WEBNOVA_DRY_RUN']='1' if dry_run else '0'
    cmd=[SCRIPT,'--run-action',action]
    rec={'job_id':job_id,'action':action,'dry_run':dry_run,'started_at':time.strftime('%Y-%m-%dT%H:%M:%S'),'status':'running','returncode':None,'seconds':None}
    JOBS[job_id]={'queue':q,'record':rec}
    HISTORY.append(rec)
    def worker():
        start=time.time()
        q.put({'type':'meta','text':f'Iniciando {action} | dry-run={dry_run}'})
        try:
            proc=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,bufsize=1,env=env)
            assert proc.stdout is not None
            for line in proc.stdout:
                q.put({'type':'line','text':line.rstrip('\n')})
            rc=proc.wait()
            rec['returncode']=rc; rec['status']='ok' if rc==0 else 'failed'; rec['seconds']=round(time.time()-start,2)
            q.put({'type':'done','returncode':rc,'seconds':rec['seconds']})
        except Exception as exc:
            rec['returncode']=99; rec['status']='failed'; rec['seconds']=round(time.time()-start,2)
            q.put({'type':'line','text':f'ERRO: {exc}'})
            q.put({'type':'done','returncode':99,'seconds':rec['seconds']})
    threading.Thread(target=worker,daemon=True).start()
    return job_id

HTML=r'''
<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>WSL2 Ubuntu Forge WebNova Enterprise</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=Imprima&display=swap');
:root{--bg:#050715;--surface:rgba(12,18,38,.74);--surface2:rgba(19,28,52,.68);--line:rgba(148,163,184,.18);--text:#f8fafc;--muted:#a7b4c8;--cyan:#22d3ee;--violet:#a78bfa;--emerald:#34d399;--amber:#fbbf24;--rose:#fb7185;--blue:#60a5fa;--shadow:0 24px 80px rgba(0,0,0,.42);--radius:24px}*{box-sizing:border-box}body{margin:0;font-family:"Imprima",system-ui,sans-serif;background:radial-gradient(circle at 12% 8%,rgba(34,211,238,.2),transparent 32%),radial-gradient(circle at 88% 5%,rgba(167,139,250,.2),transparent 34%),linear-gradient(135deg,#020617,#071126 44%,#111827);color:var(--text);min-height:100vh}.app{display:grid;grid-template-columns:300px 1fr;min-height:100vh}.sidebar{position:sticky;top:0;height:100vh;padding:22px;border-right:1px solid var(--line);background:rgba(2,6,23,.58);backdrop-filter:blur(18px);overflow:auto}.brand{display:flex;gap:12px;align-items:center;margin-bottom:22px}.logo{width:48px;height:48px;border-radius:18px;display:grid;place-items:center;background:linear-gradient(135deg,var(--cyan),var(--violet));box-shadow:0 0 30px rgba(34,211,238,.25);font-size:25px}.brand h1{font-size:17px;line-height:1.05;margin:0}.brand small{color:var(--muted)}.nav button,.pill,button{font-family:inherit}.nav button{width:100%;border:1px solid var(--line);background:rgba(15,23,42,.44);color:var(--text);padding:12px 14px;border-radius:16px;display:flex;gap:10px;align-items:center;margin:8px 0;cursor:pointer;text-align:left}.nav button.active{border-color:rgba(34,211,238,.65);background:rgba(34,211,238,.12)}.main{padding:24px;max-width:1600px;width:100%;margin:auto}.hero{padding:26px;border:1px solid var(--line);border-radius:var(--radius);background:linear-gradient(135deg,rgba(15,23,42,.74),rgba(30,41,59,.44));box-shadow:var(--shadow)}.hero h2{margin:0 0 8px;font-size:clamp(28px,4vw,54px);letter-spacing:-.04em}.hero p{color:var(--muted);max-width:920px}.toolbar{display:flex;flex-wrap:wrap;gap:10px;margin:18px 0}.pill,button.primary,button.ghost{border:1px solid var(--line);border-radius:999px;padding:11px 14px;color:var(--text);background:rgba(15,23,42,.55);cursor:pointer}.primary{background:linear-gradient(135deg,rgba(34,211,238,.9),rgba(167,139,250,.9))!important;color:#020617!important;font-weight:800}.danger{background:linear-gradient(135deg,rgba(251,113,133,.9),rgba(251,191,36,.85))!important;color:#020617!important;font-weight:800}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(245px,1fr));gap:14px;margin-top:18px}.card{position:relative;overflow:hidden;border:1px solid var(--line);border-radius:22px;padding:18px;background:rgba(15,23,42,.62);box-shadow:0 20px 60px rgba(0,0,0,.25)}.card:before{content:"";position:absolute;inset:-80px auto auto -80px;width:150px;height:150px;background:radial-gradient(circle,rgba(34,211,238,.18),transparent 70%)}.card h3{position:relative;margin:4px 0 8px;font-size:18px}.card p{position:relative;color:var(--muted);font-size:14px;min-height:54px}.meta{display:flex;gap:8px;flex-wrap:wrap;margin-bottom:10px}.tag{font-size:12px;border:1px solid var(--line);border-radius:999px;padding:5px 8px;color:#dbeafe;background:rgba(148,163,184,.08)}.icon{font-size:29px}.console{position:fixed;left:320px;right:24px;bottom:18px;height:34vh;min-height:230px;background:rgba(2,6,23,.92);border:1px solid rgba(34,211,238,.32);border-radius:24px;box-shadow:0 0 70px rgba(0,0,0,.55);display:flex;flex-direction:column;z-index:20}.console.hidden{display:none}.console.max{left:18px;right:18px;top:18px;bottom:18px;height:auto}.console.min{height:58px;min-height:58px;overflow:hidden}.consolebar{display:flex;align-items:center;justify-content:space-between;gap:10px;padding:12px 14px;border-bottom:1px solid var(--line)}.console pre{margin:0;padding:14px;overflow:auto;white-space:pre-wrap;font:13px/1.5 ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;color:#d1fae5;flex:1}.modal{position:fixed;inset:0;background:rgba(0,0,0,.62);display:none;align-items:center;justify-content:center;z-index:40;padding:20px}.modal.show{display:flex}.box{max-width:560px;width:100%;border:1px solid var(--line);border-radius:28px;background:#071126;padding:24px;box-shadow:var(--shadow)}input,select{width:100%;padding:12px;border-radius:14px;border:1px solid var(--line);background:rgba(15,23,42,.78);color:var(--text);margin:10px 0}.status{margin-top:18px;display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:12px}.stat{border:1px solid var(--line);border-radius:18px;background:rgba(15,23,42,.5);padding:14px}.stat b{display:block;font-size:22px}.toast{position:fixed;right:22px;top:20px;background:#06241f;border:1px solid rgba(52,211,153,.5);padding:12px 16px;border-radius:16px;display:none;z-index:60}@media(max-width:900px){.app{grid-template-columns:1fr}.sidebar{position:relative;height:auto}.console{left:14px;right:14px}.main{padding:16px}}
</style></head><body><div class="toast" id="toast"></div><div class="app"><aside class="sidebar"><div class="brand"><div class="logo">&#9889;</div><div><h1>Forge WebNova Enterprise</h1><small>WSL2 Ubuntu cockpit</small></div></div><div class="toolbar"><button class="pill" onclick="setDry(!dryRun)">Dry-run: <b id="dryState">OFF</b></button><button class="pill" onclick="downloadReport()">&#128196; Relatorio</button></div><nav class="nav" id="pages"></nav></aside><main class="main"><section class="hero"><h2>&#128640; WSL2 Ubuntu Forge</h2><p>Instalador enterprise-grade para preparar Ubuntu no WSL2 com Base, Terminal, Build, Git/GH, Python, Node, Docker Compose, CUDA WSL e NVIDIA Container Toolkit. Saida real em streaming, dry-run global, historico de sessao e metricas antes/depois.</p><div class="toolbar"><button class="primary" onclick="runAction('preflight_audit')">&#128269; Auditoria pre-flight</button><button class="primary" onclick="runAction('validate_all')">&#9989; Validar stack</button><button class="danger" onclick="openInstallAll()">&#128165; Instalar tudo</button><button class="ghost" onclick="toggleConsole('show')">&#128187; Console</button></div><div class="status" id="statusCards"></div></section><section class="grid" id="cards"></section></main></div><section class="console" id="console"><div class="consolebar"><b>&#128187; Console real</b><span><button class="pill" onclick="toggleConsole('min')">Min</button><button class="pill" onclick="toggleConsole('max')">Max</button><button class="pill" onclick="clearConsole()">Limpar</button><button class="pill" onclick="toggleConsole('hide')">Ocultar</button></span></div><pre id="out">Console pronto. Execute uma acao para ver stdout/stderr em tempo real.\n</pre></section><section class="modal" id="modal"><div class="box"><h2 id="modalTitle">Confirmar acao</h2><p id="modalText"></p><input id="confirmText" placeholder="Digite a confirmacao exata"><div class="toolbar"><button class="danger" onclick="confirmModal()">Executar</button><button class="ghost" onclick="closeModal()">Cancelar</button></div></div></section><script>
const token=new URLSearchParams(location.search).get('token')||'';let actions=[];let dryRun=false;let page='overview';let pendingAction=null;const icons={status:'&#128202;',preflight_audit:'&#128269;',install_base:'&#129520;',install_terminal:'&#9000;',install_build:'&#128736;',install_git_gh:'&#128279;',install_python_core:'&#128013;',install_python_modern:'&#9889;',install_python_backend:'&#127760;',install_python_data:'&#128200;',install_python_ai:'&#129302;',install_node:'&#129504;',install_docker:'&#128051;',install_cuda:'&#9889;',audit_docker:'&#128051;',audit_python_node:'&#128013;',audit_cuda:'&#127918;',validate_all:'&#9989;',export_report:'&#128196;',install_all:'&#128165;'};const pageNames={overview:'&#127919; Geral',python:'&#128013; Python',node:'&#129504; Node',docker:'&#128051; Docker',cuda:'&#9889; CUDA'};function toast(t){const e=document.getElementById('toast');e.textContent=t;e.style.display='block';setTimeout(()=>e.style.display='none',2600)}function setDry(v){dryRun=v;document.getElementById('dryState').textContent=v?'ON':'OFF'}function out(t){document.getElementById('out').textContent+=t+'\n';document.getElementById('out').scrollTop=999999}function clearConsole(){document.getElementById('out').textContent=''}function toggleConsole(mode){const c=document.getElementById('console');if(mode==='hide')c.classList.add('hidden');if(mode==='show')c.classList.remove('hidden');if(mode==='min')c.classList.toggle('min');if(mode==='max')c.classList.toggle('max')}async function api(path,opt={}){const r=await fetch(path+(path.includes('?')?'&':'?')+'token='+encodeURIComponent(token),opt);if(!r.ok)throw new Error(await r.text());return r.headers.get('content-type')?.includes('json')?r.json():r.text()}async function load(){actions=await api('/api/actions');renderPages();renderCards();loadStatus()}function renderPages(){const pages=[...new Set(actions.map(a=>a.page))];document.getElementById('pages').innerHTML=pages.map(p=>`<button class="${p===page?'active':''}" onclick="page='${p}';renderPages();renderCards()">${pageNames[p]||p}</button>`).join('')+`<button onclick="page='all';renderPages();renderCards()">&#128640; Todas as acoes</button>`}function renderCards(){let list=page==='all'?actions:actions.filter(a=>a.page===page);document.getElementById('cards').innerHTML=list.map(a=>`<article class="card"><div class="icon">${icons[a.id]||'&#10024;'}</div><div class="meta"><span class="tag">${a.group}</span><span class="tag">${a.risk}</span></div><h3>${a.title}</h3><p>${a.description}</p><button class="primary" onclick="runAction('${a.id}')">${icons[a.id]||'&#9654;'} Executar</button></article>`).join('')}async function loadStatus(){try{const s=await api('/api/status');document.getElementById('statusCards').innerHTML=[['Acoes',actions.length],['WSL/Status',s.returncode===0?'ok':'verificar'],['Dry-run',dryRun?'ativo':'desligado']].map(x=>`<div class="stat"><small>${x[0]}</small><b>${x[1]}</b></div>`).join('')}catch(e){}}function openInstallAll(){pendingAction='install_all';document.getElementById('modalTitle').textContent='Instalar tudo';document.getElementById('modalText').textContent='Esta acao instala todos os perfis definidos. Digite INSTALAR-TUDO para confirmar.';document.getElementById('confirmText').value='';document.getElementById('modal').classList.add('show')}function openCuda(){pendingAction='install_cuda';document.getElementById('modalTitle').textContent='Instalar CUDA';document.getElementById('modalText').textContent='Instalacao pesada de CUDA/NVIDIA Toolkit. Digite INSTALAR-CUDA para confirmar.';document.getElementById('confirmText').value='';document.getElementById('modal').classList.add('show')}function closeModal(){document.getElementById('modal').classList.remove('show')}function confirmModal(){const c=document.getElementById('confirmText').value;closeModal();runAction(pendingAction,c)}async function runAction(action,confirm=''){if(action==='install_all'&&!confirm){openInstallAll();return}if(action==='install_cuda'&&!confirm){openCuda();return}toggleConsole('show');out(`\n>>> ${action} | dry-run=${dryRun}`);try{const j=await api('/api/run',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({action,dry_run:dryRun,confirm})});stream(j.job_id)}catch(e){out('ERRO: '+e.message)}}function stream(job){const es=new EventSource('/api/stream?token='+encodeURIComponent(token)+'&job_id='+encodeURIComponent(job));es.onmessage=e=>{const m=JSON.parse(e.data);if(m.type==='line'||m.type==='meta')out(m.text);if(m.type==='done'){out(`<<< finalizado rc=${m.returncode} tempo=${m.seconds}s`);es.close();toast('Acao finalizada')}};es.onerror=()=>{out('SSE desconectado.');es.close()}}async function downloadReport(){const txt=await api('/api/report');const blob=new Blob([txt],{type:'text/markdown'});const a=document.createElement('a');a.href=URL.createObjectURL(blob);a.download='wsl2-ubuntu-forge-report.md';a.click()}document.addEventListener('keydown',e=>{if(e.key==='Escape')closeModal();if(e.ctrlKey&&e.key.toLowerCase()==='k'){page='all';renderPages();renderCards()}});load().catch(e=>out('Falha inicial: '+e.message));
</script></body></html>
'''
class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args): return
    def ok(self, data, ctype='application/json'):
        raw=data if isinstance(data,bytes) else data.encode('utf-8')
        self.send_response(200); self.send_header('content-type',ctype); self.send_header('content-length',str(len(raw))); self.end_headers(); self.wfile.write(raw)
    def fail(self, code, msg):
        raw=str(msg).encode('utf-8'); self.send_response(code); self.send_header('content-type','text/plain; charset=utf-8'); self.send_header('content-length',str(len(raw))); self.end_headers(); self.wfile.write(raw)
    def auth(self):
        q=urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)
        return q.get('token',[''])[0]==TOKEN
    def do_GET(self):
        path=urllib.parse.urlparse(self.path).path
        if path=='/': return self.ok(HTML,'text/html; charset=utf-8')
        if not self.auth(): return self.fail(403,'token invalido')
        try:
            if path=='/api/actions': return self.ok(json.dumps(actions()).encode(),'application/json')
            if path=='/api/status': return self.ok(json.dumps(status_text()).encode(),'application/json')
            if path=='/api/history': return self.ok(json.dumps(HISTORY).encode(),'application/json')
            if path=='/api/report': return self.ok(report_text(),'text/markdown; charset=utf-8')
            if path=='/api/stream':
                q=urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query); jid=q.get('job_id',[''])[0]
                if jid not in JOBS: return self.fail(404,'job nao encontrado')
                self.send_response(200); self.send_header('content-type','text/event-stream'); self.send_header('cache-control','no-cache'); self.end_headers()
                qu=JOBS[jid]['queue']
                while True:
                    item=qu.get()
                    payload=f"data: {json.dumps(item,ensure_ascii=False)}\n\n".encode('utf-8')
                    self.wfile.write(payload); self.wfile.flush()
                    if item.get('type')=='done': break
                return
            return self.fail(404,'nao encontrado')
        except Exception as exc: return self.fail(500,exc)
    def do_POST(self):
        if not self.auth(): return self.fail(403,'token invalido')
        path=urllib.parse.urlparse(self.path).path
        if path!='/api/run': return self.fail(404,'nao encontrado')
        try:
            n=int(self.headers.get('content-length','0') or 0); body=json.loads(self.rfile.read(n) or b'{}')
            jid=start_job(body.get('action',''),bool(body.get('dry_run')),body.get('confirm',''))
            return self.ok(json.dumps({'job_id':jid}).encode(),'application/json')
        except Exception as exc: return self.fail(400,exc)

server=ThreadingHTTPServer((HOST,PORT),Handler)
try:
    server.serve_forever()
except KeyboardInterrupt:
    pass
PYWEBNOVA
}

self_test() {
  header "Self-test do $SCRIPT_NAME v$SCRIPT_VERSION"
  init_actions
  local failures=0 id group title desc risk page
  if (( ${#ACTIONS[@]} < 20 )); then err "Catalogo deveria ter 20 acoes enterprise."; failures=$((failures+1)); fi
  local entry
  for entry in "${ACTIONS[@]}"; do
    IFS='|' read -r id group title desc risk page <<< "$entry"
    if ! action_function_exists "$id" && [[ "$id" != "install_all" ]]; then err "Funcao ausente para acao: action_$id"; failures=$((failures+1)); fi
  done
  local dyn_pattern="(^|[^[:alpha:]])e[v]al([^[:alpha:]]|$)"
  if grep -nE "$dyn_pattern" "$0" | grep -v "dyn_pattern" >/dev/null 2>&1; then err "Padrao proibido encontrado: execucao dinamica insegura"; failures=$((failures+1)); else ok "Sem execucao dinamica insegura."; fi
  local boot_pattern="(update-grub|grub-install|apt-get[^\n]*(nvidia-driver|linux-image))"
  if grep -nE "$boot_pattern" "$0" | grep -v "boot_pattern" >/dev/null 2>&1; then err "Padrao proibido de boot/kernel/driver Linux encontrado."; failures=$((failures+1)); else ok "Sem comandos de boot/kernel/driver Linux."; fi
  grep -q "Server-Sent Events\|text/event-stream" "$0" && ok "Streaming SSE encontrado." || { err "SSE ausente."; failures=$((failures+1)); }
  grep -q "docker-compose-plugin" "$0" && ok "Docker Compose Plugin encontrado." || { err "Docker Compose Plugin ausente."; failures=$((failures+1)); }
  grep -q "nvidia-ctk runtime configure --runtime=docker" "$0" && ok "nvidia-ctk runtime configure encontrado." || { err "nvidia-ctk runtime configure ausente."; failures=$((failures+1)); }
  grep -q "acquire_lock" "$0" && ok "Lock anti-execucao dupla encontrado." || { err "Lock ausente."; failures=$((failures+1)); }
  grep -q "METRICA antes" "$0" && ok "Metricas antes/depois encontradas." || { err "Metricas ausentes."; failures=$((failures+1)); }
  grep -q "generate_report_stdout" "$0" && ok "Relatorio sob demanda encontrado." || { err "Relatorio sob demanda ausente."; failures=$((failures+1)); }
  list_actions_json | python3 -m json.tool >/dev/null && ok "Catalogo JSON valido." || { err "Catalogo JSON invalido."; failures=$((failures+1)); }
  if (( failures > 0 )); then err "SELF-TEST FALHOU com $failures falha(s)."; return 1; fi
  ok "SELF-TEST OK. Catalogo possui ${#ACTIONS[@]} acoes."
}

usage() {
  cat <<EOF
$SCRIPT_NAME v$SCRIPT_VERSION

Uso:
  chmod +x $(basename "$0")
  ./$(basename "$0") --self-test
  ./$(basename "$0")
  ./$(basename "$0") --cli
  ./$(basename "$0") --run-action install_base
  WEBNOVA_DRY_RUN=1 ./$(basename "$0") --run-action install_all

Opcoes:
  --self-test          Valida sintaxe estrutural e catalogo.
  --menu-preview       Lista acoes.
  --list-actions-json  Emite catalogo JSON.
  --run-action ID      Executa uma acao real.
  --report-stdout      Emite relatorio markdown no stdout.
  --cli                Menu terminal simples.
  --help               Ajuda.
EOF
}

main() {
  case "${1:-}" in
    --self-test) self_test ;;
    --menu-preview) menu_preview ;;
    --list-actions-json) list_actions_json ;;
    --run-action) shift; run_action_enterprise "${1:-}" ;;
    --report-stdout) generate_report_stdout ;;
    --cli) cli_menu ;;
    --help|-h) usage ;;
    "") run_webnova_server ;;
    *) err "Opcao desconhecida: $1"; usage; exit 2 ;;
  esac
}

main "$@"
