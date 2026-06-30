# WSL2 Ubuntu Forge WebNova

> Instalador pós-`wsl --install` para transformar um Ubuntu recém-instalado no WSL2 em um ambiente moderno de desenvolvimento, automação, Python, Node.js, Docker, Docker Compose, CUDA WSL e NVIDIA Container Toolkit, com painel local **WebNova** e execução real em streaming.

<p align="center">
  <img alt="WSL2 Ubuntu" src="https://img.shields.io/badge/WSL2-Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white">
  <img alt="Bash" src="https://img.shields.io/badge/Bash-Installer-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white">
  <img alt="WebNova" src="https://img.shields.io/badge/TUI-WebNova-7C3AED?style=for-the-badge">
  <img alt="Docker Compose" src="https://img.shields.io/badge/Docker%20Compose-v2-2496ED?style=for-the-badge&logo=docker&logoColor=white">
  <img alt="CUDA WSL" src="https://img.shields.io/badge/CUDA-WSL-76B900?style=for-the-badge&logo=nvidia&logoColor=white">
</p>

---

## Sumário

- [Visão geral](#visão-geral)
- [Para quem é este projeto](#para-quem-é-este-projeto)
- [O que este instalador prepara](#o-que-este-instalador-prepara)
- [Princípios de projeto](#princípios-de-projeto)
- [Arquitetura WebNova](#arquitetura-webnova)
- [Requisitos](#requisitos)
- [Instalação rápida](#instalação-rápida)
- [Uso pelo painel WebNova](#uso-pelo-painel-webnova)
- [Uso pela CLI](#uso-pela-cli)
- [Dry-run global](#dry-run-global)
- [Catálogo de ações](#catálogo-de-ações)
- [Perfis de instalação](#perfis-de-instalação)
- [Docker e Docker Compose](#docker-e-docker-compose)
- [CUDA WSL e NVIDIA Container Toolkit](#cuda-wsl-e-nvidia-container-toolkit)
- [Python stack](#python-stack)
- [Node.js stack](#nodejs-stack)
- [Validação pós-instalação](#validação-pós-instalação)
- [Segurança operacional](#segurança-operacional)
- [Troubleshooting](#troubleshooting)
- [Variáveis de ambiente](#variáveis-de-ambiente)
- [Estrutura recomendada do repositório](#estrutura-recomendada-do-repositório)
- [Checklist de qualidade](#checklist-de-qualidade)
- [Roadmap sugerido](#roadmap-sugerido)
- [Referências oficiais](#referências-oficiais)
- [Licença](#licença)

---

## Visão geral

**WSL2 Ubuntu Forge WebNova** é um instalador premium para preparar um Ubuntu recém-instalado via `wsl --install` no Windows, com foco em desenvolvimento moderno, produtividade real e validação transparente.

Ele não é um script de “jogar pacote no sistema e torcer”. Ele executa ações reais, mostra saída em streaming no painel, valida ferramentas essenciais e organiza a instalação em etapas compreensíveis.

O objetivo é transformar isto:

```text
Ubuntu recém-instalado no WSL2
```

nisto:

```text
Ambiente WSL2 pronto para desenvolvimento moderno
├── base Linux atualizada
├── terminal produtivo
├── build tools
├── Git, SSH e GitHub CLI
├── Python moderno
├── Node.js moderno
├── Docker Engine
├── Docker Compose Plugin
├── CUDA Toolkit para WSL-Ubuntu
├── NVIDIA Container Toolkit
└── painel WebNova local em 127.0.0.1
```

---

## Para quem é este projeto

Este projeto foi pensado para:

- pessoas que instalaram Ubuntu com `wsl --install` e querem deixar o ambiente pronto de forma organizada;
- desenvolvedores web, backend, Python, dados e IA;
- usuários de Docker no WSL2;
- quem precisa de CUDA no WSL2 sem instalar driver Linux indevido;
- quem prefere um painel local visual em vez de decorar dezenas de comandos;
- quem quer dry-run antes de alterar o sistema.

Este projeto **não** é indicado para:

- distribuições que não usam `apt`;
- Linux bare metal fora do WSL2;
- instalação de driver NVIDIA Linux dentro do WSL;
- ambientes corporativos com política rígida sem revisão prévia dos comandos;
- execução cega em máquinas críticas sem dry-run.

---

## O que este instalador prepara

O script atual possui **822 linhas** e um catálogo com **15 ações reais**.

Ele cobre:

| Área | O que instala/configura |
|---|---|
| Base WSL2 | `apt update`, `full-upgrade`, certificados, `curl`, `wget`, `gnupg`, `locales`, compactadores e utilitários essenciais |
| Terminal | `jq`, `yq`, `tree`, `htop`, `btop`, `ncdu`, `tmux`, `fzf`, `ripgrep`, `fd`, `bat`, `shellcheck`, `shfmt` |
| Build | `build-essential`, `pkg-config`, `gcc`, `g++`, `cmake`, `ninja`, `autoconf`, `automake`, `libtool` |
| Git | Git, Git LFS, OpenSSH e GitHub CLI |
| Python Core | Python 3, pip, venv, headers dev, pipx, setuptools, wheel e build |
| Python Modern | uv, ruff, pytest, mypy, pyright, pre-commit, nox, tox, pip-audit |
| Python Backend | FastAPI, Uvicorn, Pydantic, SQLAlchemy, Alembic, Psycopg, Redis, Celery, HTTPX |
| Python Data | JupyterLab, ipykernel, NumPy, Pandas, Polars, PyArrow, SciPy, Matplotlib, DuckDB, scikit-learn |
| Python IA | Transformers, Accelerate, Datasets, Sentence Transformers, LangChain, LlamaIndex, ChromaDB, ONNX Runtime |
| Node.js | Node/npm, Corepack, PNPM, Yarn, npm-check-updates, TypeScript |
| Docker | Docker Engine, Docker CLI, containerd, Buildx, Docker Compose Plugin |
| Docker Compose | `docker compose` e wrapper compatível `docker-compose` |
| CUDA WSL | CUDA Toolkit 13.0 para WSL-Ubuntu |
| NVIDIA Containers | NVIDIA Container Toolkit e runtime Docker via `nvidia-ctk` |
| Validação | versões, saúde do ambiente, Docker Compose, CUDA, Node, Python e ferramentas principais |

---

## Princípios de projeto

O instalador segue estes princípios:

- **execução real**, sem simulações por padrão;
- **dry-run global** para revisar antes de aplicar;
- **sem `eval`**;
- **sem hardcode de usuário**;
- **sem placeholders**;
- **sem instalar driver NVIDIA Linux dentro do WSL2**;
- **sem mexer em GRUB/kernel**;
- **sem expor servidor fora de `127.0.0.1`**;
- **stdout/stderr em streaming**, sem esconder saída;
- **APT em modo não interativo**;
- **ações separadas por perfil**;
- **validação pós-instalação**.

---

## Arquitetura WebNova

O instalador combina Bash e um servidor local leve para entregar uma experiência visual sem depender de frameworks externos.

```text
┌─────────────────────────────────────────────────────────────┐
│ Navegador no Windows                                        │
│ http://127.0.0.1:8797/?token=...                            │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ WebNova UI                                                   │
│ - cards de ações                                             │
│ - console real em streaming                                  │
│ - dry-run visual                                             │
│ - status do ambiente                                         │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ Servidor local Python em 127.0.0.1                           │
│ - /api/actions                                               │
│ - /api/status                                                │
│ - /api/run-stream                                            │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ Bash Dispatcher                                              │
│ - catálogo único de ações                                    │
│ - execução real                                              │
│ - dry-run global                                             │
│ - logs apenas no console                                     │
└─────────────────────────────────────────────────────────────┘
```

O painel local usa streaming para mostrar saída de comandos enquanto eles rodam, evitando aquele efeito “travou, mas talvez esteja funcionando”.

---

## Requisitos

### Windows

- Windows 10 compatível com WSL2 ou Windows 11.
- WSL instalado.
- Ubuntu instalado via `wsl --install`.
- Para CUDA/GPU: driver NVIDIA compatível instalado no Windows.

### Ubuntu no WSL2

- Ubuntu ou derivado compatível com `apt`.
- Bash.
- Python 3 disponível para iniciar o painel WebNova.
- Acesso `sudo`.
- Internet ativa.

Valide sua distro:

```powershell
wsl.exe -l -v
```

A distro deve aparecer como versão `2`.

---

## Instalação rápida

Dentro do Ubuntu no WSL2:

```bash
chmod +x wsl2-ubuntu-forge-webnova-v1.sh
./wsl2-ubuntu-forge-webnova-v1.sh --self-test
./wsl2-ubuntu-forge-webnova-v1.sh
```

O script exibirá uma URL local parecida com:

```text
http://127.0.0.1:8797/?token=...
```

Abra essa URL no navegador do Windows.

---

## Uso pelo painel WebNova

1. Execute o script.
2. Abra a URL exibida.
3. Revise o status do ambiente.
4. Ative **Dry-run** se quiser simular a execução sem alterar o sistema.
5. Execute ações individuais ou `install_all`.
6. Acompanhe stdout/stderr no console real.
7. Rode `validate_all` ao final.

Fluxo recomendado:

```text
status
install_base
install_terminal
install_build
install_git_gh
install_python_core
install_python_modern
install_node
install_docker
install_cuda      # somente se houver GPU NVIDIA e driver Windows pronto
validate_all
```

---

## Uso pela CLI

Listar ações:

```bash
./wsl2-ubuntu-forge-webnova-v1.sh --menu-preview
```

Executar ação individual:

```bash
./wsl2-ubuntu-forge-webnova-v1.sh --run-action install_base
```

Executar tudo definido:

```bash
./wsl2-ubuntu-forge-webnova-v1.sh --run-action install_all
```

Abrir modo CLI:

```bash
./wsl2-ubuntu-forge-webnova-v1.sh --cli
```

Gerar JSON do catálogo:

```bash
./wsl2-ubuntu-forge-webnova-v1.sh --list-actions-json
```

---

## Dry-run global

O dry-run permite revisar comandos sem aplicar mudanças.

Pelo terminal:

```bash
WEBNOVA_DRY_RUN=1 ./wsl2-ubuntu-forge-webnova-v1.sh --run-action install_all
```

Ou pelo painel WebNova, ative o modo **Dry-run** antes de executar.

Use dry-run quando:

- for a primeira execução;
- estiver em máquina corporativa;
- quiser revisar instalação CUDA/Docker;
- estiver depurando pacote/repositório;
- quiser capturar comandos planejados.

---

## Catálogo de ações

| Nº | Ação | Grupo | Tipo | Descrição |
|---:|---|---|---|---|
| 1 | `status` | Diagnóstico | Leitura | Detecta WSL2, Ubuntu, disco, memória, Docker, GPU, Python, Node e rede. |
| 2 | `install_base` | Base | Escrita | Atualiza o sistema e instala certificados, curl, wget, gnupg, locales, compactadores e utilitários básicos. |
| 3 | `install_terminal` | Base | Escrita | Instala ferramentas de terminal, inspeção, busca, formatação e produtividade. |
| 4 | `install_build` | Build | Escrita | Instala compiladores, CMake, Ninja e bibliotecas de build. |
| 5 | `install_git_gh` | Git | Escrita | Instala Git, Git LFS, OpenSSH e GitHub CLI pelo repositório oficial. |
| 6 | `install_python_core` | Python | Escrita | Instala Python 3, pip, venv, headers dev, pipx, setuptools, wheel e build. |
| 7 | `install_python_modern` | Python | Escrita | Instala uv, ruff, pytest, mypy, pyright, pre-commit, nox, tox e pip-audit. |
| 8 | `install_python_backend` | Python | Escrita | Cria ambiente isolado para FastAPI, Uvicorn, Pydantic, SQLAlchemy e stack backend. |
| 9 | `install_python_data` | Python | Escrita | Cria ambiente isolado para JupyterLab, NumPy, Pandas, Polars, PyArrow, DuckDB e scikit-learn. |
| 10 | `install_python_ai` | Python | Pesada | Cria ambiente isolado para Transformers, LangChain, LlamaIndex, ChromaDB e ONNX Runtime. |
| 11 | `install_node` | Node | Escrita | Instala Node/npm e ferramentas modernas do ecossistema JS/TS. |
| 12 | `install_docker` | Docker | Escrita | Instala Docker Engine, Buildx, Docker Compose Plugin e wrapper `docker-compose`. |
| 13 | `install_cuda` | GPU/CUDA | Pesada | Instala CUDA Toolkit WSL e NVIDIA Container Toolkit. |
| 14 | `validate_all` | Validação | Leitura | Mostra versões e valida ferramentas principais. |
| 15 | `install_all` | Execução | Pesada | Executa toda a sequência definida. |

---

## Perfis de instalação

### Core Essentials

Inclui:

```text
install_base
install_terminal
install_build
```

Recomendado para todo Ubuntu WSL2 novo.

### Git Workstation

Inclui:

```text
install_git_gh
```

Prepara Git, SSH, Git LFS e GitHub CLI.

### Python Developer

Inclui:

```text
install_python_core
install_python_modern
```

Prepara Python moderno com ferramentas de qualidade, teste e segurança.

### Python Backend

Inclui:

```text
install_python_backend
```

Cria laboratório backend isolado.

### Python Data/AI

Inclui:

```text
install_python_data
install_python_ai
```

Use com critério, porque bibliotecas de dados e IA são mais pesadas.

### Web Developer

Inclui:

```text
install_node
```

Prepara Node/npm, Corepack, PNPM, Yarn e TypeScript.

### Docker DevOps

Inclui:

```text
install_docker
```

Prepara Docker Engine, Buildx e Compose.

### GPU/CUDA

Inclui:

```text
install_cuda
```

Use apenas quando o driver NVIDIA Windows já estiver instalado e `nvidia-smi` aparecer no WSL2.

---

## Docker e Docker Compose

O instalador adiciona Docker Engine pelo repositório oficial e instala:

```text
docker-ce
docker-ce-cli
containerd.io
docker-buildx-plugin
docker-compose-plugin
```

Também cria um wrapper compatível:

```text
/usr/local/bin/docker-compose
```

Esse wrapper chama:

```bash
docker compose "$@"
```

Assim, os dois estilos funcionam:

```bash
docker compose version
docker-compose version
```

Validação recomendada:

```bash
docker version
docker compose version
docker-compose version
```

> Nota: se você usa Docker Desktop no Windows com integração WSL2, revise se deseja instalar Docker Engine dentro do Ubuntu ou usar o Docker Desktop integrado. Evite misturar estratégias sem necessidade.

---

## CUDA WSL e NVIDIA Container Toolkit

O instalador inclui a sequência CUDA WSL definida para:

- CUDA Toolkit 13.0 para WSL-Ubuntu;
- pin do repositório CUDA;
- pacote local `cuda-repo-wsl-ubuntu-13-0-local_13.0.0-1_amd64.deb`;
- keyring CUDA;
- `cuda-toolkit-13-0`;
- NVIDIA Container Toolkit;
- runtime Docker configurado via `nvidia-ctk`;
- restart do Docker via `systemctl` ou `service`.

Validações recomendadas:

```bash
nvidia-smi
nvcc --version
nvidia-ctk --version
docker run --rm --gpus all nvidia/cuda:13.0.0-base-ubuntu24.04 nvidia-smi
```

Importante:

- instale o driver NVIDIA no Windows;
- não instale driver NVIDIA Linux dentro do WSL2;
- confirme que `nvidia-smi` funciona antes de instalar CUDA;
- use dry-run antes se estiver em ambiente sensível.

---

## Python stack

### Python Core

Instala:

```text
python3
python3-pip
python3-venv
python3-dev
python-is-python3
pipx
setuptools
wheel
build
```

### Python Modern Tools

Instala via ambiente apropriado:

```text
uv
ruff
pytest
pytest-cov
mypy
pyright
pre-commit
nox
tox
pip-audit
```

### Python Backend Lab

Ambiente isolado com:

```text
fastapi
uvicorn
pydantic
sqlalchemy
alembic
psycopg
asyncpg
redis
celery
httpx
python-dotenv
```

### Python Data/Notebook Lab

Ambiente isolado com:

```text
jupyterlab
ipykernel
numpy
pandas
polars
pyarrow
scipy
matplotlib
duckdb
scikit-learn
```

### Python IA/LLM Lab

Ambiente isolado com:

```text
transformers
accelerate
datasets
sentence-transformers
langchain
llama-index
chromadb
onnxruntime
```

Boas práticas:

- não use `sudo pip install`;
- prefira `.venv` por projeto;
- use `pipx` para ferramentas globais;
- use `uv` para workflows modernos;
- evite instalar pacotes pesados de IA sem necessidade.

---

## Node.js stack

A ação Node prepara:

```text
nodejs
npm
corepack
pnpm
yarn
npm-check-updates
typescript
```

Validações:

```bash
node --version
npm --version
corepack --version
pnpm --version
yarn --version
tsc --version
```

Observação: para ambientes profissionais com múltiplas versões Node, considere evoluir o script para suportar `fnm`, `nvm` ou `volta` como perfil opcional.

---

## Validação pós-instalação

Execute:

```bash
./wsl2-ubuntu-forge-webnova-v1.sh --run-action validate_all
```

Ou pelo painel WebNova, clique em:

```text
Validar stack completa
```

Checklist esperado:

```text
python --version
pip --version
pipx --version
uv --version
ruff --version
pytest --version
node --version
npm --version
pnpm --version
docker version
docker compose version
docker-compose version
nvidia-smi
nvcc --version
nvidia-ctk --version
```

Nem todos precisam existir se você não executou todos os perfis.

---

## Segurança operacional

Antes de executar `install_all`, leia isto:

- Rode `--self-test`.
- Rode `status`.
- Use `WEBNOVA_DRY_RUN=1` na primeira passagem.
- Leia os comandos no console.
- Não instale CUDA sem GPU NVIDIA compatível.
- Não misture Docker Desktop e Docker Engine sem saber o motivo.
- Evite rodar em distro fora do WSL2.
- Mantenha backup de arquivos importantes.

O script é administrativo. Ele usa `sudo`, APT e altera o sistema quando dry-run está desligado.

---

## Troubleshooting

### O painel WebNova não abre

Confira se o servidor subiu:

```bash
./wsl2-ubuntu-forge-webnova-v1.sh
```

Copie a URL exibida e cole manualmente no navegador do Windows.

Se a porta estiver ocupada:

```bash
WEBNOVA_PORT=8899 ./wsl2-ubuntu-forge-webnova-v1.sh
```

### O script diz que não está em WSL2

Valide no PowerShell:

```powershell
wsl.exe -l -v
```

Se necessário:

```powershell
wsl.exe --set-version Ubuntu 2
```

### Sudo expirou

Rode:

```bash
sudo -v
```

Depois execute novamente a ação.

### Docker não funciona

Verifique:

```bash
docker version
docker info
docker compose version
```

Se estiver usando Docker Desktop, confirme integração WSL2 nas configurações do Docker Desktop.

### CUDA não aparece

Valide:

```bash
nvidia-smi
ls /usr/lib/wsl/lib
```

Se `nvidia-smi` não funcionar, primeiro corrija o driver NVIDIA no Windows.

### `nvcc` não encontrado

Verifique:

```bash
ls /usr/local/cuda/bin/nvcc
```

Pode ser necessário adicionar CUDA ao PATH:

```bash
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:${LD_LIBRARY_PATH:-}
```

### APT travado

Procure processos ativos:

```bash
ps aux | grep -E 'apt|dpkg'
```

Não mate processos críticos sem saber o estado. Espere instalações terminarem ou corrija dpkg com cautela.

---

## Variáveis de ambiente

| Variável | Padrão | Função |
|---|---|---|
| `WEBNOVA_HOST` | `127.0.0.1` | Host do servidor local. Não recomendado expor externamente. |
| `WEBNOVA_PORT` | `8797` | Porta do painel WebNova. |
| `WEBNOVA_DRY_RUN` | `0` | Quando `1`, comandos são mostrados mas não executados. |
| `WEBNOVA_INSTALL_ROOT` | `$HOME/.local/share/wsl2-ubuntu-forge` | Diretório local para ambientes/labs do Forge. |
| `DEBIAN_FRONTEND` | `noninteractive` | Evita prompts APT. |
| `NEEDRESTART_MODE` | `a` | Respostas automáticas para restart quando aplicável. |
| `PAGER` | `cat` | Evita paginadores interativos. |
| `SYSTEMD_PAGER` | `cat` | Evita paginadores interativos do systemd. |

Exemplo:

```bash
WEBNOVA_DRY_RUN=1 WEBNOVA_PORT=8899 ./wsl2-ubuntu-forge-webnova-v1.sh
```

---

## Estrutura recomendada do repositório

```text
wsl2-ubuntu-forge-webnova/
├── README.md
├── wsl2-ubuntu-forge-webnova-v1.sh
├── docs/
│   ├── CUDA_WSL.md
│   ├── DOCKER.md
│   ├── PYTHON_STACK.md
│   └── TROUBLESHOOTING.md
├── .github/
│   └── workflows/
│       └── ci.yml
├── CHANGELOG.md
├── SECURITY.md
├── CONTRIBUTING.md
└── LICENSE
```

Arquivos recomendados para evolução:

- `SECURITY.md`: política de segurança;
- `CONTRIBUTING.md`: regras de contribuição;
- `CHANGELOG.md`: histórico de versões;
- `.github/workflows/ci.yml`: validação automática;
- `.github/ISSUE_TEMPLATE`: issues padronizadas;
- `.github/pull_request_template.md`: checklist de PR.

---

## Checklist de qualidade

Antes de publicar uma nova versão:

```bash
bash -n wsl2-ubuntu-forge-webnova-v1.sh
./wsl2-ubuntu-forge-webnova-v1.sh --self-test
./wsl2-ubuntu-forge-webnova-v1.sh --menu-preview
./wsl2-ubuntu-forge-webnova-v1.sh --list-actions-json | python3 -m json.tool
WEBNOVA_DRY_RUN=1 ./wsl2-ubuntu-forge-webnova-v1.sh --run-action install_all
```

Checklist manual:

- [ ] Script executável.
- [ ] Sem `eval`.
- [ ] Sem GRUB/kernel.
- [ ] Sem driver NVIDIA Linux.
- [ ] WebNova limitado a `127.0.0.1`.
- [ ] Dry-run funcionando.
- [ ] Catálogo de ações consistente.
- [ ] Docker Compose validado.
- [ ] CUDA documentado com alerta WSL.
- [ ] README atualizado.

---

## Roadmap sugerido

Ideias para próximas versões:

- [ ] Página dedicada Docker no painel.
- [ ] Página dedicada CUDA/GPU no painel.
- [ ] Página dedicada Python Labs no painel.
- [ ] Perfil `fnm`/`nvm`/`volta` para Node multi-versão.
- [ ] Perfil `pyenv` opcional para múltiplas versões Python.
- [ ] Exportação opcional de relatório temporário.
- [ ] Histórico de execução em memória por sessão.
- [ ] Internacionalização PT-BR/EN.
- [ ] CI com `shellcheck` e smoke tests.
- [ ] Release versionada no GitHub.
- [ ] Assinatura/checksum SHA256 dos artefatos.
- [ ] Modo repair para APT/DPKG.
- [ ] Detecção inteligente Docker Desktop vs Docker Engine local.

---

## Referências oficiais

- [Microsoft WSL install](https://learn.microsoft.com/windows/wsl/install)
- [Microsoft WSL configuration](https://learn.microsoft.com/windows/wsl/wsl-config)
- [Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
- [Docker Compose plugin on Linux](https://docs.docker.com/compose/install/linux/)
- [NVIDIA CUDA on WSL User Guide](https://docs.nvidia.com/cuda/wsl-user-guide/index.html)
- [NVIDIA Container Toolkit install guide](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)
- [GitHub CLI](https://cli.github.com/)
- [Python Packaging User Guide](https://packaging.python.org/)
- [Astral uv](https://docs.astral.sh/uv/)
- [Astral Ruff](https://docs.astral.sh/ruff/)

---

## Licença

Este repositório ainda não declara uma licença no pacote atual.

Antes de publicar como open source, escolha uma licença compatível com seu objetivo:

- MIT: permissiva e simples;
- Apache-2.0: permissiva com cláusula de patente;
- GPL-3.0: copyleft forte;
- Proprietária: uso restrito.

Sem uma licença explícita, outras pessoas não recebem permissão clara para copiar, modificar ou distribuir o projeto.

---

## Status do projeto

```text
Versão: 1.0.0
Estado: funcional, com validação local segura
Alvo: Ubuntu no WSL2
Interface: WebNova local
Execução: Bash + servidor local Python
Porta padrão: 8797
Host padrão: 127.0.0.1
```

---

## Comando mais seguro para começar

```bash
chmod +x wsl2-ubuntu-forge-webnova-v1.sh
./wsl2-ubuntu-forge-webnova-v1.sh --self-test
WEBNOVA_DRY_RUN=1 ./wsl2-ubuntu-forge-webnova-v1.sh
```

Depois de revisar tudo no painel, desligue o dry-run e execute somente os perfis necessários.

---

<p align="center">
  <strong>WSL2 Ubuntu Forge WebNova</strong><br>
  Uma forja local para transformar Ubuntu recém-instalado em estação moderna de desenvolvimento. 🛠️✨
</p>
