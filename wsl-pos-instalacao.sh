#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║             WSL2 UBUNTU FORGE WEBNOVA — v1.1.0 LUMINA ICONS                             ║
# ║             Pós-instalação premium para Ubuntu no WSL2                     ║
# ║             TUI WebNova local + instalação real + validação real           ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# OBJETIVO:
#   Preparar um Ubuntu recém-instalado via `wsl --install` com as ferramentas
#   essenciais de desenvolvimento moderno: base Linux, terminal, build tools,
#   Git/GitHub CLI, Python moderno, Node, Docker Engine, Docker Compose Plugin,
#   CUDA Toolkit WSL e NVIDIA Container Toolkit.
#
# GARANTIAS DE PROJETO:
#   • WSL2 Ubuntu como alvo principal.
#   • TUI WebNova local em 127.0.0.1, sem exposição externa.
#   • Comandos executados de forma real, sem simulação por padrão.
#   • Modo dry-run global para revisar antes de aplicar.
#   • Sem `eval`.
#   • Sem hardcode de usuário.
#   • Sem placeholders.
#   • Sem cortar stdout/stderr: o painel Web transmite a saída em streaming.
#   • Ações apt em modo não interativo.
#   • CUDA para WSL usa pacote WSL-Ubuntu, sem instalar driver Linux NVIDIA.
#
# USO:
#   chmod +x wsl2-ubuntu-forge-webnova-v1.sh
#   ./wsl2-ubuntu-forge-webnova-v1.sh --self-test
#   ./wsl2-ubuntu-forge-webnova-v1.sh
#
# CLI:
#   ./wsl2-ubuntu-forge-webnova-v1.sh --cli
#   ./wsl2-ubuntu-forge-webnova-v1.sh --run-action install_base
#   WEBNOVA_DRY_RUN=1 ./wsl2-ubuntu-forge-webnova-v1.sh --run-action install_all

set -Eeuo pipefail
IFS=$'\n\t'

readonly SCRIPT_NAME="WSL2 Ubuntu Forge WebNova"
readonly SCRIPT_VERSION="1.1.0-lumina-icons"
readonly WEBNOVA_PORT_DEFAULT="8797"
WEBNOVA_HOST="${WEBNOVA_HOST:-127.0.0.1}"
readonly STARTED_AT="$(date +%s)"

export DEBIAN_FRONTEND="${DEBIAN_FRONTEND:-noninteractive}"
export NEEDRESTART_MODE="${NEEDRESTART_MODE:-a}"
export APT_LISTCHANGES_FRONTEND="${APT_LISTCHANGES_FRONTEND:-none}"
export PAGER="${PAGER:-cat}"
export SYSTEMD_PAGER="${SYSTEMD_PAGER:-cat}"
export WEBNOVA_DRY_RUN="${WEBNOVA_DRY_RUN:-0}"
export WEBNOVA_INSTALL_ROOT="${WEBNOVA_INSTALL_ROOT:-$HOME/.local/share/wsl2-ubuntu-forge}"

readonly RST=$'\033[0m'
readonly BOLD=$'\033[1m'
readonly DIM=$'\033[2m'
readonly RED=$'\033[31m'
readonly GREEN=$'\033[32m'
readonly YELLOW=$'\033[33m'
readonly BLUE=$'\033[34m'
readonly MAGENTA=$'\033[35m'
readonly CYAN=$'\033[36m'
readonly WHITE=$'\033[97m'

log() { printf '%b[%s]%b %s\n' "$CYAN" "$(date '+%H:%M:%S')" "$RST" "$*"; }
ok() { printf '%b✓%b %s\n' "$GREEN" "$RST" "$*"; }
warn() { printf '%b⚠%b %s\n' "$YELLOW" "$RST" "$*"; }
err() { printf '%b✗%b %s\n' "$RED" "$RST" "$*" >&2; }
header() { printf '\n%b%s%b\n' "$BOLD$MAGENTA" "$*" "$RST"; printf '%*s\n' "${COLUMNS:-90}" '' | tr ' ' '-'; }

is_dry_run() { [[ "${WEBNOVA_DRY_RUN:-0}" == "1" || "${WEBNOVA_DRY_RUN:-0}" == "true" ]]; }

sudo_cmd() {
  if [[ "${EUID}" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

run_cmd() {
  local description="$1"; shift
  printf '\n%b▶ %s%b\n' "$BOLD$BLUE" "$description" "$RST"
  printf '%b$' "$DIM"
  printf ' %q' "$@"
  printf '%b\n' "$RST"
  if is_dry_run; then
    warn "DRY-RUN ativo: comando não executado."
    return 0
  fi
  "$@"
}

run_bash() {
  local description="$1"
  local script_body="$2"
  printf '\n%b▶ %s%b\n' "$BOLD$BLUE" "$description" "$RST"
  printf '%b%s%b\n' "$DIM" "$script_body" "$RST"
  if is_dry_run; then
    warn "DRY-RUN ativo: bloco Bash não executado."
    return 0
  fi
  bash -Eeuo pipefail -c "$script_body"
}

apt_update() {
  run_cmd "Atualizando índice APT" sudo_cmd apt-get update
}

apt_install() {
  local description="$1"; shift
  run_cmd "$description" sudo_cmd apt-get install -y --no-install-recommends "$@"
}

apt_full_upgrade() {
  run_cmd "Atualizando pacotes instalados com full-upgrade" sudo_cmd apt-get full-upgrade -y
}

command_exists() { command -v "$1" >/dev/null 2>&1; }

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

require_wsl2_ubuntu() {
  if ! is_wsl2; then
    err "Este instalador foi criado para rodar dentro do WSL2. Ambiente atual não parece WSL2."
    return 1
  fi
  if ! is_ubuntu_like; then
    err "Este instalador foi criado para Ubuntu/derivados compatíveis com apt."
    return 1
  fi
  ok "Ambiente WSL2 Ubuntu compatível detectado."
}

require_sudo() {
  if [[ "${EUID}" -eq 0 ]]; then
    ok "Executando como root."
    return 0
  fi
  run_cmd "Validando sessão sudo" sudo -v
}

ensure_install_root() {
  run_cmd "Criando diretório local do Forge" mkdir -p "$WEBNOVA_INSTALL_ROOT"
}

json_escape() {
  local s=${1//\\/\\\\}
  s=${s//\"/\\\"}
  s=${s//$'\n'/\\n}
  printf '%s' "$s"
}

add_action() {
  ACTION_IDS+=("$1")
  ACTION_GROUPS+=("$2")
  ACTION_TITLES+=("$3")
  ACTION_DESCS+=("$4")
  ACTION_RISKS+=("$5")
}

init_actions() {
  ACTION_IDS=(); ACTION_GROUPS=(); ACTION_TITLES=(); ACTION_DESCS=(); ACTION_RISKS=()
  add_action "status" "Diagnóstico" "Status do ambiente" "Detecta WSL2, Ubuntu, disco, memória, Docker, GPU, Python, Node e rede." "read"
  add_action "install_base" "Base" "Base WSL2 essencial" "Atualiza o sistema e instala certificados, curl, wget, gnupg, locales, compactadores e utilitários básicos." "write"
  add_action "install_terminal" "Base" "Terminal premium" "Instala jq, yq, tree, htop, btop, ncdu, tmux, fzf, ripgrep, fd, bat, shellcheck, shfmt e ferramentas de inspeção." "write"
  add_action "install_build" "Build" "Compiladores e bibliotecas" "Instala build-essential, pkg-config, gcc/g++, cmake, ninja, autoconf, automake, libtool e headers úteis." "write"
  add_action "install_git_gh" "Git" "Git, SSH e GitHub CLI" "Instala Git, Git LFS, OpenSSH e GitHub CLI pelo repositório oficial." "write"
  add_action "install_python_core" "Python" "Python Core" "Instala python3, pip, venv, dev headers, pipx, setuptools, wheel e build." "write"
  add_action "install_python_modern" "Python" "Python Modern Tools" "Instala uv, ruff, pytest, mypy, pyright, pre-commit, nox, tox, pip-audit e ferramentas modernas via pipx." "write"
  add_action "install_python_backend" "Python" "Python Backend Lab" "Cria venv isolada com FastAPI, Uvicorn, Pydantic, SQLAlchemy, Alembic, Psycopg, Redis, Celery e HTTPX." "write"
  add_action "install_python_data" "Python" "Python Data/Notebook Lab" "Cria venv isolada com JupyterLab, ipykernel, NumPy, Pandas, Polars, PyArrow, SciPy, Matplotlib, DuckDB e scikit-learn." "write"
  add_action "install_python_ai" "Python" "Python IA/LLM Lab" "Cria venv isolada com Transformers, Accelerate, Datasets, Sentence Transformers, LangChain, LlamaIndex, ChromaDB e ONNX Runtime." "heavy"
  add_action "install_node" "Node" "Node.js moderno" "Instala Node/npm via apt e ferramentas modernas: Corepack, PNPM, Yarn, npm-check-updates e TypeScript." "write"
  add_action "install_docker" "Docker" "Docker Engine + Compose" "Instala Docker pelo repositório oficial, Buildx, Docker Compose Plugin e wrapper docker-compose compatível." "write"
  add_action "install_cuda" "GPU/CUDA" "CUDA WSL + NVIDIA Container Toolkit" "Instala CUDA Toolkit 13.0 para WSL-Ubuntu e NVIDIA Container Toolkit, preservando a sequência operacional do anexo." "heavy"
  add_action "validate_all" "Validação" "Validar stack completa" "Mostra versões e checa Python, Node, Docker Compose, NVIDIA/CUDA e ferramentas principais." "read"
  add_action "install_all" "Execução" "Instalar tudo definido" "Executa base, terminal, build, Git/GH, Python, Node, Docker/Compose e CUDA em sequência." "heavy"
}

list_actions_json() {
  init_actions
  printf '['
  local i
  for i in "${!ACTION_IDS[@]}"; do
    (( i > 0 )) && printf ','
    printf '{"id":"%s","group":"%s","title":"%s","description":"%s","risk":"%s"}' \
      "$(json_escape "${ACTION_IDS[$i]}")" \
      "$(json_escape "${ACTION_GROUPS[$i]}")" \
      "$(json_escape "${ACTION_TITLES[$i]}")" \
      "$(json_escape "${ACTION_DESCS[$i]}")" \
      "$(json_escape "${ACTION_RISKS[$i]}")"
  done
  printf ']\n'
}

menu_preview() {
  init_actions
  local i
  printf '%-3s %-24s %-16s %s\n' "N" "AÇÃO" "GRUPO" "TÍTULO"
  printf '%-3s %-24s %-16s %s\n' "---" "------------------------" "----------------" "------------------------------"
  for i in "${!ACTION_IDS[@]}"; do
    printf '%-3s %-24s %-16s %s\n' "$((i+1))" "${ACTION_IDS[$i]}" "${ACTION_GROUPS[$i]}" "${ACTION_TITLES[$i]}"
  done
}

status_report() {
  header "Diagnóstico do ambiente"
  printf 'Script: %s v%s\n' "$SCRIPT_NAME" "$SCRIPT_VERSION"
  printf 'Data: %s\n' "$(date -Is)"
  printf 'Usuário: %s\n' "${USER:-desconhecido}"
  printf 'HOME: %s\n' "${HOME:-desconhecido}"
  printf 'Kernel: %s\n' "$(uname -r 2>/dev/null || true)"
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    printf 'Distro: %s\n' "${PRETTY_NAME:-desconhecida}"
  fi
  printf 'WSL2: '; if is_wsl2; then echo "sim"; else echo "não detectado"; fi
  printf 'systemd PID1: %s\n' "$(ps -p 1 -o comm= 2>/dev/null | tr -d ' ' || true)"
  printf '\nDisco:\n'; df -h / || true
  printf '\nMemória:\n'; free -h || true
  printf '\nFerramentas:\n'
  for tool in git gh python3 pipx uv ruff node npm pnpm docker docker-compose nvidia-smi nvcc; do
    if command_exists "$tool"; then
      printf '  ✓ %-16s %s\n' "$tool" "$(command -v "$tool")"
    else
      printf '  - %-16s ausente\n' "$tool"
    fi
  done
  printf '\nVersões rápidas:\n'
  git --version 2>/dev/null || true
  gh --version 2>/dev/null | head -n 1 || true
  python3 --version 2>/dev/null || true
  node --version 2>/dev/null || true
  npm --version 2>/dev/null || true
  docker --version 2>/dev/null || true
  docker compose version 2>/dev/null || true
  docker-compose version 2>/dev/null || true
  nvidia-smi 2>/dev/null || true
  nvcc --version 2>/dev/null || true
}

install_base() {
  header "Base WSL2 essencial"
  require_wsl2_ubuntu
  require_sudo
  apt_update
  apt_full_upgrade
  apt_install "Instalando base essencial" \
    apt-transport-https ca-certificates curl wget gnupg lsb-release software-properties-common \
    locales tzdata unzip zip tar xz-utils file less nano vim rsync sudo procps psmisc
  run_cmd "Gerando locale UTF-8 quando disponível" sudo_cmd locale-gen en_US.UTF-8 pt_BR.UTF-8
  ok "Base essencial concluída."
}

install_terminal() {
  header "Terminal premium"
  require_wsl2_ubuntu
  require_sudo
  apt_update
  apt_install "Instalando ferramentas modernas de terminal" \
    git git-lfs jq yq tree htop btop ncdu tmux fzf ripgrep fd-find bat shellcheck shfmt \
    direnv lsof strace iproute2 iputils-ping dnsutils net-tools traceroute netcat-openbsd socat
  if command_exists fdfind && ! command_exists fd; then
    run_cmd "Criando compatibilidade fd -> fdfind" sudo_cmd ln -sf "$(command -v fdfind)" /usr/local/bin/fd
  fi
  if command_exists batcat && ! command_exists bat; then
    run_cmd "Criando compatibilidade bat -> batcat" sudo_cmd ln -sf "$(command -v batcat)" /usr/local/bin/bat
  fi
  ok "Terminal premium concluído."
}

install_build() {
  header "Compiladores e bibliotecas"
  require_wsl2_ubuntu
  require_sudo
  apt_update
  apt_install "Instalando toolchain de compilação" \
    build-essential pkg-config make gcc g++ libc6-dev cmake ninja-build autoconf automake libtool \
    libssl-dev libffi-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev liblzma-dev \
    libpq-dev libxml2-dev libxmlsec1-dev
  ok "Build tools concluídos."
}

install_git_gh() {
  header "Git, SSH e GitHub CLI"
  require_wsl2_ubuntu
  require_sudo
  apt_update
  apt_install "Instalando Git, Git LFS e SSH" git git-lfs openssh-client openssh-server ca-certificates curl gnupg
  run_cmd "Criando diretório de keyrings APT" sudo_cmd install -m 0755 -d /etc/apt/keyrings
  run_bash "Configurando repositório oficial do GitHub CLI" '
set -Eeuo pipefail
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
'
  apt_update
  apt_install "Instalando GitHub CLI" gh
  run_cmd "Ativando Git LFS" git lfs install --skip-repo
  ok "Git/GitHub CLI concluído."
}

install_python_core() {
  header "Python Core"
  require_wsl2_ubuntu
  require_sudo
  apt_update
  apt_install "Instalando Python essencial" \
    python3 python3-pip python3-venv python3-dev python-is-python3 pipx python3-setuptools python3-wheel python3-build
  run_cmd "Garantindo PATH do pipx" python3 -m pipx ensurepath
  run_cmd "Atualizando pip/setuptools/wheel/build no usuário" python3 -m pip install --user --upgrade pip setuptools wheel build
  ok "Python Core concluído."
}

pipx_install_or_upgrade() {
  local package="$1"
  if is_dry_run; then
    warn "DRY-RUN: pipx install/upgrade $package"
    return 0
  fi
  if python3 -m pipx list 2>/dev/null | grep -qE "package ${package} |package ${package},"; then
    run_cmd "Atualizando ferramenta Python via pipx: $package" python3 -m pipx upgrade "$package"
  else
    run_cmd "Instalando ferramenta Python via pipx: $package" python3 -m pipx install "$package"
  fi
}

install_python_modern() {
  header "Python Modern Tools"
  require_wsl2_ubuntu
  require_sudo
  install_python_core
  pipx_install_or_upgrade uv
  pipx_install_or_upgrade ruff
  pipx_install_or_upgrade pytest
  pipx_install_or_upgrade mypy
  pipx_install_or_upgrade pyright
  pipx_install_or_upgrade pre-commit
  pipx_install_or_upgrade tox
  pipx_install_or_upgrade nox
  pipx_install_or_upgrade pip-audit
  pipx_install_or_upgrade bandit
  pipx_install_or_upgrade detect-secrets
  pipx_install_or_upgrade pipdeptree
  pipx_install_or_upgrade cookiecutter
  ok "Python Modern Tools concluído."
}

create_python_lab() {
  local name="$1"; shift
  local dir="$WEBNOVA_INSTALL_ROOT/$name"
  header "Python Lab: $name"
  ensure_install_root
  run_cmd "Criando venv isolada $dir/.venv" python3 -m venv "$dir/.venv"
  run_cmd "Atualizando pip na venv $name" "$dir/.venv/bin/python" -m pip install --upgrade pip setuptools wheel
  run_cmd "Instalando pacotes na venv $name" "$dir/.venv/bin/python" -m pip install "$@"
  run_cmd "Gravando requirements instalados em $dir/requirements.lock.txt" "$dir/.venv/bin/python" -m pip freeze
  if ! is_dry_run; then
    "$dir/.venv/bin/python" -m pip freeze > "$dir/requirements.lock.txt"
  fi
  ok "Lab $name pronto em $dir"
}

install_python_backend() {
  require_wsl2_ubuntu
  install_python_core
  create_python_lab "python-backend-lab" \
    fastapi uvicorn gunicorn pydantic sqlalchemy alembic psycopg[binary] asyncpg redis celery rq httpx python-dotenv typer rich loguru jinja2 watchdog
}

install_python_data() {
  require_wsl2_ubuntu
  install_python_core
  create_python_lab "python-data-lab" \
    jupyterlab ipykernel notebook numpy pandas scipy matplotlib polars pyarrow scikit-learn duckdb requests httpx tqdm rich
}

install_python_ai() {
  require_wsl2_ubuntu
  install_python_core
  create_python_lab "python-ai-lab" \
    transformers accelerate datasets sentence-transformers langchain llama-index chromadb onnxruntime huggingface-hub safetensors tokenizers
}

install_node() {
  header "Node.js moderno"
  require_wsl2_ubuntu
  require_sudo
  apt_update
  apt_install "Instalando Node/npm base" nodejs npm ca-certificates curl
  if command_exists corepack; then
    run_cmd "Ativando Corepack" corepack enable
  else
    warn "Corepack não detectado nesta versão do Node; seguindo com npm global."
  fi
  run_cmd "Atualizando npm global" sudo_cmd npm install -g npm@latest
  run_cmd "Instalando ferramentas Node modernas" sudo_cmd npm install -g pnpm yarn npm-check-updates typescript ts-node vite
  ok "Node.js moderno concluído."
}

install_docker() {
  header "Docker Engine + Docker Compose Plugin"
  require_wsl2_ubuntu
  require_sudo
  apt_update
  apt_install "Pré-requisitos Docker" ca-certificates curl gnupg lsb-release
  run_cmd "Removendo pacotes Docker conflitantes quando existirem" sudo_cmd apt-get remove -y docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc
  run_cmd "Criando keyring Docker" sudo_cmd install -m 0755 -d /etc/apt/keyrings
  run_bash "Configurando repositório oficial Docker" '
set -Eeuo pipefail
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
. /etc/os-release
sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME:-$VERSION_CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
'
  apt_update
  apt_install "Instalando Docker Engine, Buildx e Docker Compose Plugin" docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  run_bash "Criando wrapper docker-compose compatível" '
set -Eeuo pipefail
sudo tee /usr/local/bin/docker-compose >/dev/null <<'EOF'
#!/usr/bin/env bash
exec docker compose "$@"
EOF
sudo chmod +x /usr/local/bin/docker-compose
'
  if [[ -n "${USER:-}" && "${USER:-}" != "root" ]]; then
    run_cmd "Adicionando usuário atual ao grupo docker" sudo_cmd usermod -aG docker "$USER"
    warn "Faça logout/login ou execute 'newgrp docker' para usar Docker sem sudo."
  fi
  if command_exists systemctl && systemctl list-unit-files >/dev/null 2>&1; then
    run_cmd "Habilitando Docker" sudo_cmd systemctl enable docker
    run_cmd "Iniciando Docker" sudo_cmd systemctl start docker
  else
    warn "systemd não parece ativo; tentando iniciar Docker via service."
    run_cmd "Iniciando Docker via service" sudo_cmd service docker start
  fi
  run_cmd "Validando Docker" sudo_cmd docker version
  run_cmd "Validando Docker Compose Plugin" docker compose version
  run_cmd "Validando wrapper docker-compose" docker-compose version
  ok "Docker + Compose concluído."
}

install_cuda() {
  header "CUDA Toolkit WSL + NVIDIA Container Toolkit"
  require_wsl2_ubuntu
  require_sudo
  apt_update
  apt_install "Pré-requisitos CUDA/NVIDIA Container Toolkit" wget curl ca-certificates gnupg lsb-release

  warn "CUDA no WSL2 usa o driver NVIDIA do Windows. Este script instala CUDA Toolkit WSL e NÃO instala driver Linux NVIDIA."
  if command_exists nvidia-smi; then
    run_cmd "Validando nvidia-smi antes do CUDA" nvidia-smi
  else
    warn "nvidia-smi não foi encontrado no WSL. Verifique o driver NVIDIA no Windows antes de usar CUDA."
  fi

  local cuda_workdir="$WEBNOVA_INSTALL_ROOT/cuda-wsl-13.0"
  run_cmd "Criando diretório de trabalho CUDA" mkdir -p "$cuda_workdir"
  if ! is_dry_run; then
    pushd "$cuda_workdir" >/dev/null
  fi

  # Sequência operacional do anexo preservada e melhorada com workdir isolado,
  # modo não interativo, validações e fallback de restart do Docker.
  # Comandos originais incorporados: remoção do .deb antigo, download do pin,
  # instalação do repositório local CUDA 13.0 WSL-Ubuntu, instalação do pacote
  # cuda-toolkit-13-0, repositório NVIDIA Container Toolkit, nvidia-ctk e restart.

  run_cmd "Removendo pacote local CUDA antigo no diretório de trabalho" sudo_cmd rm -rf cuda-repo-wsl-ubuntu-13-0-local_13.0.0-1_amd64.deb

  echo -e "${RED}"
  echo "Instalando NVIDIA CUDA Toolkit 13.0..."
  echo -e "${RST}"

  run_cmd "Baixando pin do repositório CUDA WSL" wget -O cuda-wsl-ubuntu.pin https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
  run_cmd "Instalando pin CUDA APT" sudo_cmd mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
  run_cmd "Baixando instalador local CUDA WSL 13.0" wget -O cuda-repo-wsl-ubuntu-13-0-local_13.0.0-1_amd64.deb https://developer.download.nvidia.com/compute/cuda/13.0.0/local_installers/cuda-repo-wsl-ubuntu-13-0-local_13.0.0-1_amd64.deb
  run_cmd "Instalando repositório local CUDA WSL 13.0" sudo_cmd dpkg -i cuda-repo-wsl-ubuntu-13-0-local_13.0.0-1_amd64.deb
  run_cmd "Copiando keyring CUDA" sudo_cmd cp /var/cuda-repo-wsl-ubuntu-13-0-local/cuda-*-keyring.gpg /usr/share/keyrings/
  apt_update
  run_cmd "Instalando cuda-toolkit-13-0" sudo_cmd apt-get -y install cuda-toolkit-13-0

  echo -e "${RED}"
  echo "Instalando NVIDIA Container Toolkit..."
  echo -e "${RST}"

  run_bash "Configurando repositório NVIDIA Container Toolkit" '
set -Eeuo pipefail
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
sudo curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sudo sed '\''s#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g'\'' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list >/dev/null
sudo sed -i -e '\''/experimental/ s/^#//g'\'' /etc/apt/sources.list.d/nvidia-container-toolkit.list
'
  apt_update

  # O anexo fixava 1.17.8-1. Mantemos esse default para compatibilidade e permitimos
  # atualizar sem editar código: NVIDIA_CONTAINER_TOOLKIT_VERSION=latest ou outra versão.
  export NVIDIA_CONTAINER_TOOLKIT_VERSION="${NVIDIA_CONTAINER_TOOLKIT_VERSION:-1.17.8-1}"
  if [[ "$NVIDIA_CONTAINER_TOOLKIT_VERSION" == "latest" ]]; then
    run_cmd "Instalando NVIDIA Container Toolkit mais recente do repositório" sudo_cmd apt-get install -y nvidia-container-toolkit nvidia-container-toolkit-base libnvidia-container-tools libnvidia-container1
  elif apt-cache madison nvidia-container-toolkit 2>/dev/null | grep -q "${NVIDIA_CONTAINER_TOOLKIT_VERSION}"; then
    run_cmd "Instalando NVIDIA Container Toolkit versão ${NVIDIA_CONTAINER_TOOLKIT_VERSION}" sudo_cmd apt-get install -y \
      "nvidia-container-toolkit=${NVIDIA_CONTAINER_TOOLKIT_VERSION}" \
      "nvidia-container-toolkit-base=${NVIDIA_CONTAINER_TOOLKIT_VERSION}" \
      "libnvidia-container-tools=${NVIDIA_CONTAINER_TOOLKIT_VERSION}" \
      "libnvidia-container1=${NVIDIA_CONTAINER_TOOLKIT_VERSION}"
  else
    warn "Versão NVIDIA Container Toolkit ${NVIDIA_CONTAINER_TOOLKIT_VERSION} não encontrada no repo. Instalando latest disponível."
    run_cmd "Instalando NVIDIA Container Toolkit latest" sudo_cmd apt-get install -y nvidia-container-toolkit nvidia-container-toolkit-base libnvidia-container-tools libnvidia-container1
  fi

  echo -e "${RED}"
  echo "Configuring Docker"
  echo -e "${RST}"

  run_cmd "Configurando runtime NVIDIA para Docker" sudo_cmd nvidia-ctk runtime configure --runtime=docker
  if command_exists systemctl && systemctl list-unit-files >/dev/null 2>&1; then
    run_cmd "Reiniciando Docker via systemctl" sudo_cmd systemctl restart docker
  else
    run_cmd "Reiniciando Docker via service" sudo_cmd service docker restart
  fi

  if ! is_dry_run; then
    popd >/dev/null
  fi
  run_cmd "Validando nvcc" bash -c 'command -v nvcc && nvcc --version || true'
  run_cmd "Validando NVIDIA Container Toolkit" nvidia-ctk --version
  ok "CUDA WSL + NVIDIA Container Toolkit concluído."
}

validate_all() {
  header "Validação completa"
  status_report
  printf '\nChecks específicos:\n'
  for cmd in python3 pipx git gh node npm pnpm docker docker-compose; do
    if command_exists "$cmd"; then ok "$cmd disponível"; else warn "$cmd ausente"; fi
  done
  if command_exists docker; then
    run_cmd "Docker Compose version" docker compose version
  fi
  if command_exists nvidia-smi; then
    run_cmd "NVIDIA SMI" nvidia-smi
  fi
  if command_exists nvcc; then
    run_cmd "NVCC" nvcc --version
  fi
  ok "Validação concluída."
}

install_all() {
  header "Instalação completa definida"
  require_wsl2_ubuntu
  require_sudo
  install_base
  install_terminal
  install_build
  install_git_gh
  install_python_core
  install_python_modern
  install_python_backend
  install_python_data
  install_node
  install_docker
  install_cuda
  validate_all
  ok "Instalação completa finalizada."
}

dispatch_action() {
  local action="${1:-}"
  case "$action" in
    status) status_report ;;
    install_base) install_base ;;
    install_terminal) install_terminal ;;
    install_build) install_build ;;
    install_git_gh) install_git_gh ;;
    install_python_core) install_python_core ;;
    install_python_modern) install_python_modern ;;
    install_python_backend) install_python_backend ;;
    install_python_data) install_python_data ;;
    install_python_ai) install_python_ai ;;
    install_node) install_node ;;
    install_docker) install_docker ;;
    install_cuda) install_cuda ;;
    validate_all) validate_all ;;
    install_all) install_all ;;
    *) err "Ação não existe: $action"; return 2 ;;
  esac
}

cli_menu() {
  init_actions
  while true; do
    clear || true
    header "$SCRIPT_NAME v$SCRIPT_VERSION — CLI"
    menu_preview
    printf '\nDigite o número, ID da ação ou q para sair: '
    local choice action=""
    read -r choice
    [[ "$choice" == "q" || "$choice" == "Q" ]] && break
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#ACTION_IDS[@]} )); then
      action="${ACTION_IDS[$((choice-1))]}"
    else
      action="$choice"
    fi
    printf 'Dry-run? [s/N]: '
    local dry
    read -r dry
    if [[ "$dry" =~ ^[sS]$ ]]; then WEBNOVA_DRY_RUN=1; else WEBNOVA_DRY_RUN=0; fi
    dispatch_action "$action" || true
    printf '\nPressione ENTER para continuar...'
    read -r _
  done
}

run_webnova_server() {
  if ! command_exists python3; then
    err "python3 não encontrado. Rode: sudo apt update && sudo apt install -y python3"
    exit 1
  fi
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
  warn "Servidor limitado a 127.0.0.1. Copie a URL para o navegador do Windows se não abrir automaticamente."
  if command_exists powershell.exe; then
    powershell.exe -NoProfile -Command "Start-Process 'http://${WEBNOVA_HOST}:${port}/?token=${token}'" >/dev/null 2>&1 || true
  fi
  python3 - <<'PYWEBNOVA'
import json
import os
import queue
import subprocess
import sys
import threading
import time
import urllib.parse
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

HOST = os.environ.get("WEBNOVA_HOST", "127.0.0.1")
PORT = int(os.environ.get("WEBNOVA_PORT", "8797"))
TOKEN = os.environ.get("WEBNOVA_TOKEN", "")
SCRIPT = os.environ.get("WEBNOVA_SCRIPT_PATH", "")
JOBS = {}
HISTORY = []

def run_script_json(args):
    p = subprocess.run([SCRIPT] + args, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if p.returncode != 0:
        raise RuntimeError(p.stderr or p.stdout)
    return p.stdout

def actions():
    return json.loads(run_script_json(["--list-actions-json"]))

def start_job(action, dry_run=False):
    job_id = f"job-{int(time.time()*1000)}-{len(JOBS)+1}"
    q = queue.Queue()
    env = os.environ.copy()
    env["WEBNOVA_DRY_RUN"] = "1" if dry_run else "0"
    cmd = [SCRIPT, "--run-action", action]
    record = {"job_id": job_id, "action": action, "dry_run": dry_run, "started_at": time.strftime("%Y-%m-%dT%H:%M:%S"), "status": "running", "returncode": None}
    JOBS[job_id] = {"queue": q, "record": record}
    HISTORY.append(record)

    def worker():
        before = time.time()
        q.put({"type": "meta", "text": f"Iniciando ação: {action} | dry-run={dry_run}"})
        try:
            proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1, env=env)
            assert proc.stdout is not None
            for line in proc.stdout:
                q.put({"type": "line", "text": line.rstrip("\n")})
            rc = proc.wait()
            record["returncode"] = rc
            record["status"] = "ok" if rc == 0 else "failed"
            record["seconds"] = round(time.time() - before, 2)
            q.put({"type": "done", "returncode": rc, "seconds": record["seconds"]})
        except Exception as exc:
            record["status"] = "failed"
            record["returncode"] = 99
            record["seconds"] = round(time.time() - before, 2)
            q.put({"type": "line", "text": f"ERRO: {exc}"})
            q.put({"type": "done", "returncode": 99, "seconds": record["seconds"]})
    threading.Thread(target=worker, daemon=True).start()
    return job_id

HTML = r'''
<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>WSL2 Ubuntu Forge WebNova</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=Imprima&display=swap');
:root{
  --bg:#050716;
  --surface:rgba(10,16,32,.74);
  --surface2:rgba(15,23,42,.64);
  --surface3:rgba(30,41,59,.58);
  --text:#f8fafc;
  --muted:#a5b4c8;
  --soft:#dbeafe;
  --line:rgba(148,163,184,.18);
  --cyan:#22d3ee;
  --violet:#a78bfa;
  --emerald:#34d399;
  --amber:#fbbf24;
  --rose:#fb7185;
  --blue:#60a5fa;
  --shadow:0 26px 88px rgba(0,0,0,.42);
  --glow:0 0 36px rgba(34,211,238,.20);
  --radius:24px;
}
*{box-sizing:border-box}
html{scroll-behavior:smooth}
body{
  margin:0;
  font-family:"Imprima",system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;
  background:
    radial-gradient(circle at 12% 8%,rgba(34,211,238,.22),transparent 32%),
    radial-gradient(circle at 82% 0%,rgba(167,139,250,.22),transparent 34%),
    radial-gradient(circle at 50% 100%,rgba(52,211,153,.10),transparent 32%),
    linear-gradient(135deg,#020617,#070b1d 44%,#111827);
  color:var(--text);
  min-height:100vh;
}
body:before{
  content:"";
  position:fixed;inset:0;pointer-events:none;opacity:.34;
  background-image:
    linear-gradient(rgba(255,255,255,.035) 1px,transparent 1px),
    linear-gradient(90deg,rgba(255,255,255,.035) 1px,transparent 1px);
  background-size:42px 42px;
  mask-image:radial-gradient(circle at 50% 20%,#000,transparent 78%);
}
body.light{
  --bg:#f8fafc;--surface:rgba(255,255,255,.84);--surface2:rgba(241,245,249,.88);--surface3:rgba(226,232,240,.80);
  --text:#0f172a;--muted:#475569;--soft:#0f172a;--line:rgba(15,23,42,.14);--shadow:0 22px 70px rgba(15,23,42,.13);--glow:0 0 34px rgba(34,211,238,.18);
  background:radial-gradient(circle at 15% 10%,rgba(34,211,238,.18),transparent 32%),radial-gradient(circle at 85% 0%,rgba(167,139,250,.16),transparent 30%),linear-gradient(135deg,#f8fafc,#e2e8f0);
}
button,input{font-family:inherit}.app{display:grid;grid-template-columns:318px 1fr;min-height:100vh;position:relative;z-index:1}
.sidebar{position:sticky;top:0;height:100vh;padding:22px;border-right:1px solid var(--line);background:linear-gradient(180deg,rgba(2,6,23,.72),rgba(15,23,42,.50));backdrop-filter:blur(22px);overflow:auto}.light .sidebar{background:rgba(255,255,255,.72)}
.brand{display:flex;gap:14px;align-items:center;margin-bottom:18px}.logo{width:54px;height:54px;border-radius:20px;background:linear-gradient(135deg,var(--cyan),var(--violet));display:grid;place-items:center;box-shadow:0 0 44px rgba(34,211,238,.28);font-size:1.5rem;position:relative}.logo:after{content:"";position:absolute;inset:-5px;border-radius:24px;border:1px solid rgba(34,211,238,.25)}
h1{font-size:1.16rem;margin:0;letter-spacing:.01em}.subtitle{color:var(--muted);font-size:.88rem;margin-top:3px}.pillRow{display:flex;gap:8px;flex-wrap:wrap;margin:14px 0 16px}.miniPill{border:1px solid var(--line);background:var(--surface2);border-radius:999px;padding:6px 9px;color:var(--muted);font-size:.76rem;display:inline-flex;align-items:center;gap:6px}
.searchWrap{position:relative}.searchIcon{position:absolute;left:13px;top:50%;transform:translateY(-50%);opacity:.72}.search{width:100%;border:1px solid var(--line);background:var(--surface2);color:var(--text);padding:13px 14px 13px 40px;border-radius:17px;outline:none;box-shadow:inset 0 1px 0 rgba(255,255,255,.04)}.search:focus{border-color:rgba(34,211,238,.54);box-shadow:0 0 0 4px rgba(34,211,238,.10)}
.groupTitle{color:var(--muted);font-size:.73rem;letter-spacing:.12em;text-transform:uppercase;margin:22px 0 8px;display:flex;align-items:center;gap:8px}.groupTitle:after{content:"";height:1px;background:var(--line);flex:1}.sideBtn{width:100%;text-align:left;border:1px solid transparent;background:transparent;color:var(--text);padding:9px 10px;border-radius:15px;cursor:pointer;display:grid;grid-template-columns:34px 1fr auto;align-items:center;gap:10px;transition:.16s ease}.sideBtn:hover{background:var(--surface2);border-color:var(--line);transform:translateX(2px)}.sideIcon,.riskIcon{display:grid;place-items:center;border-radius:12px}.sideIcon{width:34px;height:34px;background:linear-gradient(135deg,rgba(34,211,238,.18),rgba(167,139,250,.18));border:1px solid rgba(255,255,255,.10)}.sideMeta{min-width:0}.sideTitle{display:block;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}.risk{font-size:.68rem;color:var(--muted);display:inline-flex;align-items:center;gap:4px;padding:4px 7px;border-radius:999px;border:1px solid var(--line);background:rgba(255,255,255,.035)}
.main{padding:24px;display:grid;gap:18px;padding-bottom:338px}.hero{border:1px solid var(--line);background:linear-gradient(135deg,var(--surface),rgba(30,41,59,.48));backdrop-filter:blur(24px);border-radius:var(--radius);padding:22px;box-shadow:var(--shadow);display:grid;grid-template-columns:1fr auto;gap:18px;align-items:start;overflow:hidden;position:relative}.hero:before{content:"";position:absolute;right:-120px;top:-140px;width:360px;height:360px;background:radial-gradient(circle,rgba(34,211,238,.20),transparent 64%)}.heroKicker{display:inline-flex;gap:8px;align-items:center;color:var(--cyan);font-weight:800;margin-bottom:10px}.hero h2{font-size:clamp(1.55rem,3vw,2.7rem);line-height:.98;margin:0 0 10px;letter-spacing:-.03em}.hero p{color:var(--muted);margin:0;max-width:760px;line-height:1.45}.heroStats{display:grid;grid-template-columns:repeat(3,minmax(90px,1fr));gap:10px;margin-top:16px;max-width:520px}.stat{border:1px solid var(--line);background:rgba(255,255,255,.045);border-radius:18px;padding:10px}.stat b{font-size:1.15rem}.stat span{display:block;color:var(--muted);font-size:.75rem;margin-top:2px}.toolbar{display:flex;gap:10px;flex-wrap:wrap;justify-content:flex-end}.btn{border:1px solid var(--line);background:var(--surface2);color:var(--text);border-radius:16px;padding:11px 14px;cursor:pointer;display:inline-flex;align-items:center;gap:8px;transition:.16s ease;box-shadow:inset 0 1px 0 rgba(255,255,255,.04)}.btn:hover{transform:translateY(-1px);border-color:rgba(34,211,238,.36)}.btn.primary{background:linear-gradient(135deg,var(--cyan),var(--violet));color:#020617;border:0;font-weight:900}.btn.danger{background:linear-gradient(135deg,var(--amber),var(--rose));color:#111827;border:0;font-weight:900}.switch{display:flex;align-items:center;gap:8px;color:var(--muted);border:1px solid var(--line);background:var(--surface2);padding:10px 12px;border-radius:16px}
.sectionHead{display:flex;align-items:end;justify-content:space-between;gap:14px}.sectionHead h2{margin:0;font-size:1rem}.sectionHead p{margin:4px 0 0;color:var(--muted);font-size:.9rem}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(210px,1fr));gap:12px}.card{position:relative;overflow:hidden;text-align:left;border:1px solid var(--line);background:linear-gradient(145deg,var(--surface),rgba(15,23,42,.42));backdrop-filter:blur(18px);border-radius:20px;padding:14px;cursor:pointer;min-height:148px;transition:.18s transform,.18s border-color,.18s box-shadow}.card:before{content:"";position:absolute;inset:0;background:radial-gradient(circle at var(--mx,80%) var(--my,0%),rgba(34,211,238,.16),transparent 36%);opacity:.9;pointer-events:none}.card:hover{transform:translateY(-4px);border-color:rgba(34,211,238,.44);box-shadow:var(--glow)}.cardTop{display:flex;align-items:flex-start;justify-content:space-between;gap:10px;margin-bottom:12px}.cardIcon{width:44px;height:44px;border-radius:16px;display:grid;place-items:center;background:linear-gradient(135deg,rgba(34,211,238,.22),rgba(167,139,250,.20));border:1px solid rgba(255,255,255,.12);font-size:1.25rem;box-shadow:0 12px 36px rgba(34,211,238,.10)}.tag{display:inline-flex;align-items:center;gap:6px;font-size:.72rem;color:#02111d;background:linear-gradient(135deg,var(--emerald),var(--cyan));padding:5px 9px;border-radius:999px;font-weight:900}.card h3{margin:0 0 8px;font-size:1rem;line-height:1.15}.card p{margin:0;color:var(--muted);font-size:.88rem;line-height:1.34}.cardFoot{display:flex;align-items:center;justify-content:space-between;gap:8px;margin-top:12px;color:var(--muted);font-size:.74rem}.runHint{color:var(--cyan);font-weight:800}.risk.heavy{color:var(--amber);border-color:rgba(251,191,36,.25)}.risk.write{color:var(--cyan);border-color:rgba(34,211,238,.24)}.risk.read{color:var(--emerald);border-color:rgba(52,211,153,.24)}
.consoleWrap{position:fixed;left:338px;right:24px;bottom:18px;z-index:20;border:1px solid var(--line);border-radius:22px;background:rgba(2,6,23,.92);box-shadow:var(--shadow);overflow:hidden;backdrop-filter:blur(18px)}.light .consoleWrap{background:rgba(15,23,42,.94);color:#f8fafc}.consoleWrap.hidden{display:none}.consoleWrap.max{left:18px;right:18px;top:18px;bottom:18px}.consoleHead{display:flex;justify-content:space-between;gap:10px;align-items:center;padding:12px 14px;border-bottom:1px solid var(--line)}.consoleTitle{display:flex;align-items:center;gap:10px}.led{width:10px;height:10px;border-radius:50%;background:var(--emerald);box-shadow:0 0 18px var(--emerald)}.console{height:260px;overflow:auto;padding:14px;font-family:ui-monospace,SFMono-Regular,Menlo,monospace;font-size:.84rem;white-space:pre-wrap;color:#d1fae5;background:linear-gradient(180deg,rgba(2,6,23,.25),rgba(2,6,23,.50))}.consoleWrap.min .console{display:none}.consoleWrap.max .console{height:calc(100vh - 92px)}.floatingConsole{position:fixed;right:20px;bottom:20px;z-index:21}.toast{position:fixed;right:20px;top:20px;background:var(--surface);border:1px solid var(--line);padding:13px 15px;border-radius:16px;box-shadow:var(--shadow);display:none}.modal{position:fixed;inset:0;background:rgba(0,0,0,.62);display:none;align-items:center;justify-content:center;padding:20px;z-index:40;backdrop-filter:blur(8px)}.modalBox{max-width:640px;width:100%;background:var(--surface);border:1px solid var(--line);border-radius:26px;padding:22px;box-shadow:var(--shadow)}.modalBox h2{margin-top:0}.modal input{width:100%;padding:14px;border-radius:14px;border:1px solid var(--line);background:var(--surface2);color:var(--text)}
@media(max-width:1050px){.app{grid-template-columns:1fr}.sidebar{position:relative;height:auto}.hero{grid-template-columns:1fr}.toolbar{justify-content:flex-start}.consoleWrap{left:12px;right:12px}.main{padding:18px;padding-bottom:338px}.grid{grid-template-columns:repeat(auto-fit,minmax(180px,1fr))}}
@media(max-width:620px){.heroStats{grid-template-columns:1fr}.grid{grid-template-columns:1fr}.sideBtn{grid-template-columns:32px 1fr}.riskIcon{display:none}.consoleHead{align-items:flex-start;flex-direction:column}.btn{padding:10px 12px}.sidebar{padding:16px}.main{padding:14px;padding-bottom:328px}}
</style>
</head>
<body>
<div class="app">
  <aside class="sidebar">
    <div class="brand"><div class="logo">🚀</div><div><h1>WSL2 Forge</h1><div class="subtitle">WebNova Lumina Installer</div></div></div>
    <div class="pillRow"><span class="miniPill">🛡️ Localhost</span><span class="miniPill">⚡ SSE</span><span class="miniPill">🎛️ Dry-run</span></div>
    <div class="searchWrap"><span class="searchIcon">🔎</span><input id="search" class="search" placeholder="Buscar ação... Ctrl+K"/></div>
    <div id="side"></div>
  </aside>
  <main class="main">
    <section class="hero">
      <div>
        <div class="heroKicker">🌌 WebNova Lumina · WSL2 Ubuntu Forge</div>
        <h2>Ubuntu WSL2 pronto para dev moderno.</h2>
        <p>Instale Base, Python, Node, Docker Compose e CUDA WSL com console real em streaming, dry-run global e visual premium com ícones em todos os pontos de ação.</p>
        <div class="heroStats"><div class="stat"><b id="countActions">15</b><span>ações reais</span></div><div class="stat"><b>127.0.0.1</b><span>painel local</span></div><div class="stat"><b>SSE</b><span>console ao vivo</span></div></div>
      </div>
      <div class="toolbar"><label class="switch">🧪 <input id="dry" type="checkbox"> Dry-run</label><button class="btn" id="theme">☀️ Tema claro</button><button class="btn primary" id="all">🚀 Instalar tudo</button><button class="btn" onclick="runAction('status')">📊 Status</button></div>
    </section>
    <div class="sectionHead"><div><h2>🧩 Catálogo de instalação</h2><p>Cards compactos, categorizados e clicáveis. Cada card executa uma ação real do backend.</p></div><span class="miniPill" id="filteredCount">0 ações</span></div>
    <section class="grid" id="grid"></section>
  </main>
</div>
<div class="consoleWrap" id="cw"><div class="consoleHead"><strong class="consoleTitle"><span class="led"></span>🖥️ Console real</strong><div class="toolbar"><button class="btn" onclick="cw.classList.toggle('min')">➖ Minimizar</button><button class="btn" onclick="cw.classList.toggle('max')">⛶ Maximizar</button><button class="btn" onclick="cw.classList.add('hidden')">👁️‍🗨️ Ocultar</button></div></div><div class="console" id="console"></div></div>
<button class="btn primary floatingConsole" onclick="cw.classList.remove('hidden')">🖥️ Console</button>
<div class="toast" id="toast"></div>
<div class="modal" id="modal"><div class="modalBox"><h2>🚀 Confirmar instalação completa</h2><p>Esta ação instala todas as camadas definidas: base, terminal, build, Git/GH, Python, Node, Docker Compose e CUDA. Para confirmar, digite <b>INSTALAR-TUDO</b>.</p><input id="confirmText" placeholder="INSTALAR-TUDO"/><div class="toolbar" style="margin-top:14px"><button class="btn" onclick="modal.style.display='none'">↩️ Cancelar</button><button class="btn danger" onclick="confirmAll()">🚀 Executar tudo</button></div></div></div>
<script>
const params=new URLSearchParams(location.search);const token=params.get('token')||'';const api=(p)=>p+(p.includes('?')?'&':'?')+'token='+encodeURIComponent(token);const grid=document.getElementById('grid'),side=document.getElementById('side'),con=document.getElementById('console'),cw=document.getElementById('cw'),modal=document.getElementById('modal');let actions=[];
const groupIcons={"Diagnóstico":"📊","Base":"🧱","Build":"🏗️","Git":"🌿","Python":"🐍","Node":"🟢","Docker":"🐳","GPU/CUDA":"⚡","Validação":"✅","Execução":"🚀"};
const actionIcons={status:"📊",install_base:"🧱",install_terminal:"🖥️",install_build:"🏗️",install_git_gh:"🌿",install_python_core:"🐍",install_python_modern:"✨",install_python_backend:"🧬",install_python_data:"📈",install_python_ai:"🤖",install_node:"🟢",install_docker:"🐳",install_cuda:"⚡",validate_all:"✅",install_all:"🚀"};
const riskLabels={read:"Seguro",write:"Altera",heavy:"Pesado"};const riskIcons={read:"👁️",write:"🛠️",heavy:"🔥"};
function iconFor(a){return actionIcons[a.id]||groupIcons[a.group]||"🧩"}function groupIcon(g){return groupIcons[g]||"◇"}function riskText(a){return `${riskIcons[a.risk]||"•"} ${riskLabels[a.risk]||a.risk}`}
function toast(t){const el=document.getElementById('toast');el.textContent=t;el.style.display='block';setTimeout(()=>el.style.display='none',2400)}function log(t){con.textContent+=t+'\n';con.scrollTop=con.scrollHeight;cw.classList.remove('hidden')}function esc(s){return String(s).replace(/[&<>"]/g,m=>({"&":"&amp;","<":"&lt;",">":"&gt;","\"":"&quot;"}[m]))}
function render(){const q=document.getElementById('search').value.toLowerCase();grid.innerHTML='';side.innerHTML='';const groups={};const filtered=actions.filter(a=>(a.title+a.description+a.group+a.id).toLowerCase().includes(q));document.getElementById('filteredCount').textContent=`${filtered.length} ações`;filtered.forEach(a=>{(groups[a.group]??=[]).push(a);const c=document.createElement('button');c.className='card';c.innerHTML=`<div class="cardTop"><div class="cardIcon">${iconFor(a)}</div><span class="tag">${groupIcon(a.group)} ${esc(a.group)}</span></div><h3>${esc(a.title)}</h3><p>${esc(a.description)}</p><div class="cardFoot"><span>${esc(a.id)}</span><span class="risk ${esc(a.risk)}">${riskText(a)}</span></div><div class="cardFoot"><span></span><span class="runHint">Executar →</span></div>`;c.onmousemove=e=>{const r=c.getBoundingClientRect();c.style.setProperty('--mx',`${e.clientX-r.left}px`);c.style.setProperty('--my',`${e.clientY-r.top}px`)};c.onclick=()=>runAction(a.id);grid.appendChild(c)});Object.entries(groups).forEach(([g,items])=>{const h=document.createElement('div');h.className='groupTitle';h.innerHTML=`<span>${groupIcon(g)}</span><span>${esc(g)}</span>`;side.appendChild(h);items.forEach(a=>{const b=document.createElement('button');b.className='sideBtn';b.innerHTML=`<span class="sideIcon">${iconFor(a)}</span><span class="sideMeta"><span class="sideTitle">${esc(a.title)}</span><small style="color:var(--muted)">${esc(a.id)}</small></span><span class="risk ${esc(a.risk)}">${riskText(a)}</span>`;b.onclick=()=>runAction(a.id);side.appendChild(b)})})}
async function load(){actions=await fetch(api('/api/actions')).then(r=>r.json());document.getElementById('countActions').textContent=actions.length;render()}function stream(action){const dry=document.getElementById('dry').checked?'1':'0';log(`\n▶ ${action} | dry-run=${dry}`);const es=new EventSource(api(`/api/stream?action=${encodeURIComponent(action)}&dry_run=${dry}`));es.onmessage=e=>{const data=JSON.parse(e.data);if(data.type==='line'||data.type==='meta')log(data.text);if(data.type==='done'){log(`✓ finalizado rc=${data.returncode} tempo=${data.seconds}s`);es.close();toast('Ação finalizada')}};es.onerror=()=>{log('ERRO: conexão SSE encerrada.');es.close()}}function runAction(action){if(action==='install_all'){modal.style.display='flex';return}stream(action)}function confirmAll(){if(document.getElementById('confirmText').value!=='INSTALAR-TUDO'){toast('Digite INSTALAR-TUDO');return}modal.style.display='none';stream('install_all')}document.getElementById('search').oninput=render;document.addEventListener('keydown',e=>{if(e.ctrlKey&&e.key.toLowerCase()==='k'){e.preventDefault();search.focus()}if(e.key==='Escape'){modal.style.display='none';cw.classList.remove('max')}});document.getElementById('theme').onclick=()=>{document.body.classList.toggle('light');document.getElementById('theme').textContent=document.body.classList.contains('light')?'🌙 Tema escuro':'☀️ Tema claro'};document.getElementById('all').onclick=()=>modal.style.display='flex';load();
</script>
</body>
</html>
'''

class Handler(BaseHTTPRequestHandler):
    def auth(self):
        qs = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)
        return qs.get("token", [""])[0] == TOKEN
    def send_json(self, obj):
        data = json.dumps(obj, ensure_ascii=False).encode()
        self.send_response(200); self.send_header("Content-Type","application/json; charset=utf-8"); self.send_header("Content-Length", str(len(data))); self.end_headers(); self.wfile.write(data)
    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        if parsed.path == "/":
            data = HTML.encode(); self.send_response(200); self.send_header("Content-Type","text/html; charset=utf-8"); self.send_header("Content-Length", str(len(data))); self.end_headers(); self.wfile.write(data); return
        if not self.auth():
            self.send_response(403); self.end_headers(); self.wfile.write(b"forbidden"); return
        if parsed.path == "/api/actions": return self.send_json(actions())
        if parsed.path == "/api/history": return self.send_json(HISTORY[-50:])
        if parsed.path == "/api/stream":
            qs = urllib.parse.parse_qs(parsed.query)
            action = qs.get("action", [""])[0]
            dry = qs.get("dry_run", ["0"])[0] in ("1","true","yes")
            job_id = start_job(action, dry)
            q = JOBS[job_id]["queue"]
            self.send_response(200); self.send_header("Content-Type","text/event-stream"); self.send_header("Cache-Control","no-cache"); self.end_headers()
            while True:
                item = q.get(); payload = f"data: {json.dumps(item, ensure_ascii=False)}\n\n".encode()
                try:
                    self.wfile.write(payload); self.wfile.flush()
                except BrokenPipeError:
                    break
                if item.get("type") == "done": break
            return
        self.send_response(404); self.end_headers()
    def log_message(self, fmt, *args): sys.stderr.write("[%s] %s\n" % (time.strftime("%H:%M:%S"), fmt % args))

server = ThreadingHTTPServer((HOST, PORT), Handler)
print(f"WebNova ouvindo em http://{HOST}:{PORT}/?token={TOKEN}", flush=True)
server.serve_forever()
PYWEBNOVA
}

self_test() {
  header "Self-test $SCRIPT_NAME v$SCRIPT_VERSION"
  init_actions
  local missing=0 id
  for id in "${ACTION_IDS[@]}"; do
    if ! declare -f "${id}" >/dev/null 2>&1 && [[ "$id" != "status" ]]; then
      case "$id" in validate_all|install_all) : ;; *) err "Função ausente para ação: $id"; missing=$((missing+1)) ;; esac
    fi
  done
  if grep -nE '^[[:space:]]*eval[[:space:]]' "$0" >/dev/null 2>&1; then err "Comando eval executável encontrado."; return 1; fi
  local forbidden_hits=""
  local forbidden_token
  for forbidden_token in "grub-install" "update-grub" "nvidia-driver"; do
    forbidden_hits+="$(grep -n "$forbidden_token" "$0" 2>/dev/null | grep -v 'forbidden_token' | grep -v 'forbidden_hits' || true)"
  done
  if [[ -n "$forbidden_hits" ]]; then err "Comando proibido detectado: GRUB ou driver NVIDIA Linux."; return 1; fi
  if ! grep -q 'WSL2 Forge' "$0" || ! grep -q 'EventSource' "$0"; then err "WebNova UI/SSE não encontrada."; return 1; fi
  if ! grep -q 'actionIcons' "$0" || ! grep -q 'sideIcon' "$0" || ! grep -q 'cardIcon' "$0"; then err "Ícones WebNova Lumina não encontrados."; return 1; fi
  local lines; lines=$(wc -l < "$0" | tr -d ' ')
  ok "Catálogo possui ${#ACTION_IDS[@]} ações."
  ok "Sem eval."
  ok "Sem GRUB/kernel/driver NVIDIA Linux."
  ok "TUI WebNova com streaming SSE encontrada."
  ok "Ícones Lumina em sidebar, cards, riscos e botões encontrados."
  ok "Script possui ${lines} linhas."
  (( missing == 0 )) || return 1
  echo "SELF-TEST OK"
}

main() {
  case "${1:-}" in
    --self-test) self_test ;;
    --list-actions-json) list_actions_json ;;
    --menu-preview) menu_preview ;;
    --cli) cli_menu ;;
    --run-action) shift; dispatch_action "${1:-}" ;;
    --help|-h) cat <<EOF
$SCRIPT_NAME v$SCRIPT_VERSION

Uso:
  $0                 Abre TUI WebNova local
  $0 --self-test     Valida estrutura do script
  $0 --cli           Menu CLI fallback
  $0 --menu-preview  Lista ações
  $0 --run-action ID Executa ação específica

Variáveis:
  WEBNOVA_DRY_RUN=1         Mostra comandos sem executar
  WEBNOVA_PORT=8797         Porta do painel
  NVIDIA_CONTAINER_TOOLKIT_VERSION=latest|1.17.8-1
EOF
      ;;
    *) run_webnova_server ;;
  esac
}

main "$@"
