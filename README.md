# 馃寣 WSL2 Ubuntu Forge WebNova 路 Lumina Icons

> 馃И Instalador p贸s-`wsl --install` para transformar um Ubuntu rec茅m-instalado no WSL2 em um ambiente moderno de desenvolvimento, automa莽茫o, Python, Node.js, Docker, Docker Compose, CUDA WSL e NVIDIA Container Toolkit, com painel local **WebNova Lumina Icons**.

<p align="center">
  <img alt="WSL2 Ubuntu" src="https://img.shields.io/badge/WSL2-Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white">
  <img alt="Bash" src="https://img.shields.io/badge/Bash-Installer-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white">
  <img alt="WebNova Lumina" src="https://img.shields.io/badge/WebNova-Lumina%20Icons-7C3AED?style=for-the-badge">
  <img alt="Docker Compose" src="https://img.shields.io/badge/Docker%20Compose-v2-2496ED?style=for-the-badge&logo=docker&logoColor=white">
  <img alt="CUDA WSL" src="https://img.shields.io/badge/CUDA-WSL-76B900?style=for-the-badge&logo=nvidia&logoColor=white">
</p>

<p align="center">
  馃┖ Diagn贸stico 路 馃П Base 路 馃洜锔?Build 路 馃尶 Git/GH 路 馃悕 Python 路 馃煩 Node 路 馃惓 Docker 路 鈿?CUDA 路 鉁?Valida莽茫o 路 馃殌 Instala莽茫o total
</p>

---

## 馃Л Sum谩rio

- [鉁?Vis茫o geral](#-vis茫o-geral)
- [馃拵 Destaques visuais Lumina Icons](#-destaques-visuais-lumina-icons)
- [馃幆 Para quem 茅 este projeto](#-para-quem-茅-este-projeto)
- [馃З O que este instalador prepara](#-o-que-este-instalador-prepara)
- [馃洝锔?Princ铆pios de seguran莽a](#锔?princ铆pios-de-seguran莽a)
- [馃寪 Arquitetura WebNova](#-arquitetura-webnova)
- [馃搵 Requisitos](#-requisitos)
- [鈿?Instala莽茫o r谩pida](#-instala莽茫o-r谩pida)
- [馃枼锔?Uso pelo painel WebNova](#锔?uso-pelo-painel-webnova)
- [鈱笍 Uso pela CLI](#锔?uso-pela-cli)
- [馃И Dry-run global](#-dry-run-global)
- [馃梻锔?Cat谩logo de a莽玫es com 铆cones](#锔?cat谩logo-de-a莽玫es-com-铆cones)
- [馃П Perfis de instala莽茫o](#-perfis-de-instala莽茫o)
- [馃悕 Python stack](#-python-stack)
- [馃煩 Node.js stack](#-nodejs-stack)
- [馃惓 Docker e Docker Compose](#-docker-e-docker-compose)
- [鈿?CUDA WSL e NVIDIA Container Toolkit](#-cuda-wsl-e-nvidia-container-toolkit)
- [鉁?Valida莽茫o p贸s-instala莽茫o](#-valida莽茫o-p贸s-instala莽茫o)
- [馃Н Troubleshooting](#-troubleshooting)
- [馃К Vari谩veis de ambiente](#-vari谩veis-de-ambiente)
- [馃搧 Estrutura recomendada do reposit贸rio](#-estrutura-recomendada-do-reposit贸rio)
- [馃И Checklist de qualidade](#-checklist-de-qualidade)
- [馃毀 Roadmap sugerido](#-roadmap-sugerido)
- [馃摎 Refer锚ncias oficiais recomendadas](#-refer锚ncias-oficiais-recomendadas)
- [馃摐 Licen莽a](#-licen莽a)

---

## 鉁?Vis茫o geral

**WSL2 Ubuntu Forge WebNova** 茅 um instalador visual para preparar um Ubuntu rec茅m-instalado com `wsl --install`.

A vers茫o **Lumina Icons** deixa o painel mais bonito, escane谩vel e agrad谩vel de usar, com 铆cones na sidebar, nos cards, nos bot玫es, nos status e nos riscos de execu莽茫o.

```text
馃尡 Ubuntu rec茅m-instalado no WSL2
        鈹?        鈻?馃寣 WebNova Lumina Icons
        鈹?        鈹溾攢鈹€ 馃П Base Linux atualizada
        鈹溾攢鈹€ 鈱笍 Terminal premium
        鈹溾攢鈹€ 馃洜锔?Build tools
        鈹溾攢鈹€ 馃尶 Git, SSH e GitHub CLI
        鈹溾攢鈹€ 馃悕 Python moderno
        鈹溾攢鈹€ 馃煩 Node.js moderno
        鈹溾攢鈹€ 馃惓 Docker Engine
        鈹溾攢鈹€ 馃З Docker Compose Plugin
        鈹溾攢鈹€ 鈿?CUDA Toolkit para WSL-Ubuntu
        鈹溾攢鈹€ 馃К NVIDIA Container Toolkit
        鈹斺攢鈹€ 鉁?Valida莽茫o final
```

O objetivo 茅 simples: transformar a instala莽茫o crua do Ubuntu em um ambiente pronto para desenvolvimento real, sem decorar dezenas de comandos e sem perder transpar锚ncia sobre o que est谩 sendo executado.

---

## 馃拵 Destaques visuais Lumina Icons

A vers茫o **v1.1.0-lumina-icons** acrescenta a camada visual que faltava no painel:

| 脕rea | Melhoria visual |
|---|---|
| 馃Л Sidebar | 脥cones por grupo e por a莽茫o |
| 馃儚 Cards | 脥cones individuais, orb visual, risco e descri莽茫o clara |
| 馃И Status | Indicadores visuais para ambiente, Docker, GPU, Python e Node |
| 馃洝锔?Riscos | Badges `馃煝 Seguro`, `馃煛 Altera`, `馃敶 Pesado` |
| 馃柋锔?Bot玫es | 脥cones em a莽玫es principais e execu莽茫o total |
| 馃攷 Busca | Campo de busca mais leg铆vel e iconizado |
| 馃 Visual | Glassmorphism leve, cards compactos e contraste dark-first |
| 馃摫 Responsivo | Grid adapt谩vel para desktop, tablet e mobile |
| 馃Ь Console | Streaming real com leitura mais clara |
| 馃殌 Modal | Instala莽茫o completa com confirma莽茫o visual |

---

## 馃幆 Para quem 茅 este projeto

Este projeto 茅 para voc锚 se precisa de um Ubuntu WSL2 pronto para:

- 馃悕 desenvolvimento Python;
- 馃寪 backend/API;
- 馃搳 dados e notebooks;
- 馃 IA/LLM;
- 馃煩 Node.js e tooling web;
- 馃惓 Docker e Docker Compose;
- 鈿?CUDA no WSL2;
- 馃И valida莽茫o p贸s-instala莽茫o;
- 馃О ambiente produtivo sem montar tudo manualmente.

Este projeto **n茫o** 茅 para:

- 鉂?Linux bare metal fora do WSL2;
- 鉂?distros sem `apt`;
- 鉂?instalar driver NVIDIA Linux dentro do WSL;
- 鉂?ambientes cr铆ticos sem dry-run;
- 鉂?execu莽茫o cega sem revisar as a莽玫es.

---

## 馃З O que este instalador prepara

O script atual possui **917 linhas** e um cat谩logo com **15 a莽玫es reais**.

| Camada | Componentes |
|---|---|
| 馃┖ Diagn贸stico | WSL2, Ubuntu, disco, mem贸ria, Docker, GPU, Python, Node e rede |
| 馃П Base | APT, certificados, `curl`, `wget`, `gnupg`, locales e utilit谩rios essenciais |
| 鈱笍 Terminal | `jq`, `yq`, `tree`, `htop`, `btop`, `ncdu`, `tmux`, `fzf`, `ripgrep`, `fd`, `bat` |
| 馃洜锔?Build | `build-essential`, `gcc`, `g++`, `cmake`, `ninja`, `autoconf`, `automake`, `libtool` |
| 馃尶 Git | Git, Git LFS, OpenSSH e GitHub CLI |
| 馃悕 Python Core | Python 3, pip, venv, dev headers, pipx, setuptools, wheel e build |
| 鉁?Python Modern | uv, ruff, pytest, mypy, pyright, pre-commit, nox, tox, pip-audit |
| 馃寪 Python Backend | FastAPI, Uvicorn, Pydantic, SQLAlchemy, Alembic, Psycopg, Redis, Celery, HTTPX |
| 馃搳 Python Data | JupyterLab, NumPy, Pandas, Polars, PyArrow, SciPy, Matplotlib, DuckDB, scikit-learn |
| 馃 Python IA | Transformers, Accelerate, Datasets, Sentence Transformers, LangChain, LlamaIndex, ChromaDB, ONNX Runtime |
| 馃煩 Node | Node/npm, Corepack, PNPM, Yarn, npm-check-updates, TypeScript |
| 馃惓 Docker | Docker Engine, Docker CLI, containerd, Buildx, Docker Compose Plugin |
| 馃З Compose | `docker compose` e wrapper compat铆vel `docker-compose` |
| 鈿?CUDA | CUDA Toolkit 13.0 para WSL-Ubuntu |
| 馃К NVIDIA | NVIDIA Container Toolkit e runtime Docker via `nvidia-ctk` |

---

## 馃洝锔?Princ铆pios de seguran莽a

O instalador foi desenhado com estes princ铆pios:

- 鉁?execu莽茫o real, sem simula莽茫o por padr茫o;
- 馃И dry-run global para revisar comandos antes de aplicar;
- 馃毇 sem `eval`;
- 馃毇 sem hardcode de usu谩rio;
- 馃毇 sem placeholders;
- 馃毇 sem mexer em GRUB/kernel;
- 馃毇 sem instalar driver NVIDIA Linux dentro do WSL2;
- 馃敀 servidor local limitado a `127.0.0.1`;
- 馃Ь stdout/stderr em streaming no console WebNova;
- 馃 APT em modo n茫o interativo;
- 馃З a莽玫es separadas por perfil;
- 鉁?valida莽茫o p贸s-instala莽茫o.

---

## 馃寪 Arquitetura WebNova

```text
鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?鈹?馃獰 Navegador no Windows                                      鈹?鈹?http://127.0.0.1:8797/?token=...                             鈹?鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?                                鈹?                                鈻?鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?鈹?馃寣 WebNova Lumina UI                                          鈹?鈹?鈹溾攢鈹€ 馃Л Sidebar iconizada                                      鈹?鈹?鈹溾攢鈹€ 馃儚 Cards compactos                                        鈹?鈹?鈹溾攢鈹€ 馃И Dry-run visual                                         鈹?鈹?鈹溾攢鈹€ 馃Ь Console real em streaming                              鈹?鈹?鈹斺攢鈹€ 馃殌 Modal de instala莽茫o completa                           鈹?鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?                                鈹?                                鈻?鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?鈹?馃悕 Servidor local Python                                      鈹?鈹?鈹溾攢鈹€ /api/actions                                              鈹?鈹?鈹溾攢鈹€ /api/status                                               鈹?鈹?鈹斺攢鈹€ /api/run-stream                                           鈹?鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?                                鈹?                                鈻?鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?鈹?馃悮 Bash Dispatcher                                            鈹?鈹?鈹溾攢鈹€ cat谩logo 煤nico de a莽玫es                                   鈹?鈹?鈹溾攢鈹€ execu莽茫o real                                             鈹?鈹?鈹溾攢鈹€ dry-run global                                            鈹?鈹?鈹斺攢鈹€ valida莽茫o de stack                                        鈹?鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?```

---

## 馃搵 Requisitos

### 馃獰 Windows

- Windows 10 compat铆vel com WSL2 ou Windows 11.
- WSL instalado.
- Ubuntu instalado via `wsl --install`.
- Para CUDA/GPU: driver NVIDIA compat铆vel instalado no Windows.

### 馃惂 Ubuntu no WSL2

- Ubuntu ou derivado compat铆vel com `apt`.
- Bash.
- Python 3 para iniciar o painel WebNova.
- Acesso `sudo`.
- Internet ativa.

Valide a vers茫o WSL:

```powershell
wsl.exe -l -v
```

A distro deve aparecer como vers茫o `2`.

---

## 鈿?Instala莽茫o r谩pida

Dentro do Ubuntu no WSL2:

```bash
chmod +x wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh
./wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh --self-test
./wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh
```

O script exibir谩 uma URL local parecida com:

```text
http://127.0.0.1:8797/?token=...
```

Abra essa URL no navegador do Windows.

---

## 馃枼锔?Uso pelo painel WebNova

No painel voc锚 pode:

1. 馃┖ ver o status do ambiente;
2. 馃攷 procurar a莽玫es pela sidebar;
3. 馃儚 executar cards individuais;
4. 馃И ativar dry-run;
5. 馃Ь acompanhar sa铆da real no console;
6. 馃殌 executar tudo definido com confirma莽茫o;
7. 鉁?validar a stack ao final.

### 馃Л Sidebar iconizada

### 馃┖ Diagn贸stico

- 馃┖ **Status do ambiente**
  `status` 路 馃煝 Leitura segura

### 馃П Base

- 馃П **Base WSL2 essencial**
  `install_base` 路 馃煛 Altera ambiente
- 鈱笍 **Terminal premium**
  `install_terminal` 路 馃煛 Altera ambiente

### 馃洜锔?Build

- 馃洜锔?**Compiladores e bibliotecas**
  `install_build` 路 馃煛 Altera ambiente

### 馃尶 Git

- 馃尶 **Git, SSH e GitHub CLI**
  `install_git_gh` 路 馃煛 Altera ambiente

### 馃悕 Python

- 馃悕 **Python Core**
  `install_python_core` 路 馃煛 Altera ambiente
- 鉁?**Python Modern Tools**
  `install_python_modern` 路 馃煛 Altera ambiente
- 馃寪 **Python Backend Lab**
  `install_python_backend` 路 馃煛 Altera ambiente
- 馃搳 **Python Data/Notebook Lab**
  `install_python_data` 路 馃煛 Altera ambiente
- 馃 **Python IA/LLM Lab**
  `install_python_ai` 路 馃敶 Pesado / avan莽ado

### 馃煩 Node

- 馃煩 **Node.js moderno**
  `install_node` 路 馃煛 Altera ambiente

### 馃惓 Docker

- 馃惓 **Docker Engine + Compose**
  `install_docker` 路 馃煛 Altera ambiente

### 鈿?GPU/CUDA

- 鈿?**CUDA WSL + NVIDIA Container Toolkit**
  `install_cuda` 路 馃敶 Pesado / avan莽ado

### 鉁?Valida莽茫o

- 鉁?**Validar stack completa**
  `validate_all` 路 馃煝 Leitura segura

### 馃殌 Execu莽茫o

- 馃殌 **Instalar tudo definido**
  `install_all` 路 馃敶 Pesado / avan莽ado


---

## 鈱笍 Uso pela CLI

Listar a莽玫es:

```bash
./wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh --menu-preview
```

Listar a莽玫es em JSON:

```bash
./wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh --list-actions-json
```

Executar uma a莽茫o espec铆fica:

```bash
./wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh --run-action install_python_core
```

Executar valida莽茫o:

```bash
./wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh --run-action validate_all
```

---

## 馃И Dry-run global

Use o dry-run para ver comandos antes de alterar o sistema:

```bash
WEBNOVA_DRY_RUN=1 ./wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh --run-action install_all
```

No painel WebNova, ative o bot茫o **馃И Dry-run** antes de executar a莽玫es.

O dry-run 茅 especialmente recomendado para:

- 馃惓 Docker;
- 鈿?CUDA;
- 馃 Python IA/LLM;
- 馃殌 Instalar tudo definido.

---

## 馃梻锔?Cat谩logo de a莽玫es com 铆cones

| # | 脥cone | A莽茫o | Grupo | Risco | O que faz |
|---:|:---:|---|---|---|---|
| 1 | 馃┖ | `status`<br>Status do ambiente | 馃┖ Diagn贸stico | 馃煝 Leitura segura | Detecta WSL2, Ubuntu, disco, mem贸ria, Docker, GPU, Python, Node e rede. |
| 2 | 馃П | `install_base`<br>Base WSL2 essencial | 馃П Base | 馃煛 Altera ambiente | Atualiza o sistema e instala certificados, curl, wget, gnupg, locales, compactadores e utilit谩rios b谩sicos. |
| 3 | 鈱笍 | `install_terminal`<br>Terminal premium | 馃П Base | 馃煛 Altera ambiente | Instala jq, yq, tree, htop, btop, ncdu, tmux, fzf, ripgrep, fd, bat, shellcheck, shfmt e ferramentas de inspe莽茫o. |
| 4 | 馃洜锔?| `install_build`<br>Compiladores e bibliotecas | 馃洜锔?Build | 馃煛 Altera ambiente | Instala build-essential, pkg-config, gcc/g++, cmake, ninja, autoconf, automake, libtool e headers 煤teis. |
| 5 | 馃尶 | `install_git_gh`<br>Git, SSH e GitHub CLI | 馃尶 Git | 馃煛 Altera ambiente | Instala Git, Git LFS, OpenSSH e GitHub CLI pelo reposit贸rio oficial. |
| 6 | 馃悕 | `install_python_core`<br>Python Core | 馃悕 Python | 馃煛 Altera ambiente | Instala python3, pip, venv, dev headers, pipx, setuptools, wheel e build. |
| 7 | 鉁?| `install_python_modern`<br>Python Modern Tools | 馃悕 Python | 馃煛 Altera ambiente | Instala uv, ruff, pytest, mypy, pyright, pre-commit, nox, tox, pip-audit e ferramentas modernas via pipx. |
| 8 | 馃寪 | `install_python_backend`<br>Python Backend Lab | 馃悕 Python | 馃煛 Altera ambiente | Cria venv isolada com FastAPI, Uvicorn, Pydantic, SQLAlchemy, Alembic, Psycopg, Redis, Celery e HTTPX. |
| 9 | 馃搳 | `install_python_data`<br>Python Data/Notebook Lab | 馃悕 Python | 馃煛 Altera ambiente | Cria venv isolada com JupyterLab, ipykernel, NumPy, Pandas, Polars, PyArrow, SciPy, Matplotlib, DuckDB e scikit-learn. |
| 10 | 馃 | `install_python_ai`<br>Python IA/LLM Lab | 馃悕 Python | 馃敶 Pesado / avan莽ado | Cria venv isolada com Transformers, Accelerate, Datasets, Sentence Transformers, LangChain, LlamaIndex, ChromaDB e ONNX Runtime. |
| 11 | 馃煩 | `install_node`<br>Node.js moderno | 馃煩 Node | 馃煛 Altera ambiente | Instala Node/npm via apt e ferramentas modernas: Corepack, PNPM, Yarn, npm-check-updates e TypeScript. |
| 12 | 馃惓 | `install_docker`<br>Docker Engine + Compose | 馃惓 Docker | 馃煛 Altera ambiente | Instala Docker pelo reposit贸rio oficial, Buildx, Docker Compose Plugin e wrapper docker-compose compat铆vel. |
| 13 | 鈿?| `install_cuda`<br>CUDA WSL + NVIDIA Container Toolkit | 鈿?GPU/CUDA | 馃敶 Pesado / avan莽ado | Instala CUDA Toolkit 13.0 para WSL-Ubuntu e NVIDIA Container Toolkit, preservando a sequ锚ncia operacional do anexo. |
| 14 | 鉁?| `validate_all`<br>Validar stack completa | 鉁?Valida莽茫o | 馃煝 Leitura segura | Mostra vers玫es e checa Python, Node, Docker Compose, NVIDIA/CUDA e ferramentas principais. |
| 15 | 馃殌 | `install_all`<br>Instalar tudo definido | 馃殌 Execu莽茫o | 馃敶 Pesado / avan莽ado | Executa base, terminal, build, Git/GH, Python, Node, Docker/Compose e CUDA em sequ锚ncia. |

---

## 馃П Perfis de instala莽茫o

### 馃П Base WSL2 essencial

Instala a funda莽茫o do Ubuntu:

```text
apt update
apt full-upgrade
certificados
curl / wget / gnupg
locales / tzdata
compactadores
utilit谩rios b谩sicos
```

### 鈱笍 Terminal premium

Ferramentas para produtividade e diagn贸stico:

```text
jq, yq, tree, htop, btop, ncdu, tmux, fzf, ripgrep, fd, bat, shellcheck, shfmt
```

### 馃洜锔?Build tools

Necess谩rio para pacotes Python, Node nativo e bibliotecas compiladas:

```text
build-essential, pkg-config, gcc, g++, cmake, ninja, autoconf, automake, libtool
```

### 馃尶 Git/GitHub

Instala:

```text
git
git-lfs
openssh-client
openssh-server
gh
```

### 馃悕 Python

Instala Python em camadas:

```text
Core 鈫?Modern Tools 鈫?Backend Lab 鈫?Data/Notebook Lab 鈫?IA/LLM Lab
```

### 馃煩 Node

Instala tooling web moderno:

```text
nodejs
npm
corepack
pnpm
yarn
npm-check-updates
typescript
```

### 馃惓 Docker

Instala:

```text
docker-ce
docker-ce-cli
containerd.io
docker-buildx-plugin
docker-compose-plugin
```

### 鈿?CUDA

Instala CUDA Toolkit 13.0 para WSL-Ubuntu e NVIDIA Container Toolkit.

---

## 馃悕 Python stack

### 馃悕 Python Core

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

### 鉁?Python Modern Tools

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

### 馃寪 Python Backend Lab

Venv isolada para backend:

```text
fastapi
uvicorn
pydantic
sqlalchemy
alembic
psycopg
redis
celery
httpx
python-dotenv
```

### 馃搳 Python Data/Notebook Lab

Venv isolada para dados e notebooks:

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

### 馃 Python IA/LLM Lab

Venv isolada para IA e LLM:

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

> 鈿狅笍 Esta etapa pode ser pesada. Use dry-run primeiro.

---

## 馃煩 Node.js stack

O instalador prepara Node.js com ferramentas 煤teis para projetos modernos:

```text
nodejs
npm
corepack
pnpm
yarn
npm-check-updates
typescript
```

Valida莽茫o esperada:

```bash
node --version
npm --version
pnpm --version
yarn --version
tsc --version
```

---

## 馃惓 Docker e Docker Compose

O perfil Docker instala Docker Engine e Compose Plugin.

Depois da instala莽茫o, estes comandos devem funcionar:

```bash
docker version
docker info
docker compose version
docker-compose version
```

O wrapper `docker-compose` 茅 criado para compatibilidade com projetos que ainda usam o comando antigo:

```text
/usr/local/bin/docker-compose 鈫?docker compose "$@"
```

> 馃惓 Prefer锚ncia moderna: use `docker compose`.

---

## 鈿?CUDA WSL e NVIDIA Container Toolkit

A instala莽茫o CUDA preserva a sequ锚ncia operacional definida para WSL-Ubuntu:

```text
cuda-wsl-ubuntu.pin
cuda-repo-wsl-ubuntu-13-0-local_13.0.0-1_amd64.deb
cuda-toolkit-13-0
nvidia-container-toolkit
nvidia-ctk runtime configure --runtime=docker
restart docker
```

### 鉁?Valida莽玫es esperadas

```bash
nvidia-smi
nvcc --version
nvidia-ctk --version
docker run --rm --gpus all nvidia/cuda:13.0.0-base-ubuntu24.04 nvidia-smi
```

### 鈿狅笍 Importante

No WSL2, o driver NVIDIA deve ficar no **Windows**. N茫o instale driver NVIDIA Linux completo dentro da distro WSL2.

---

## 鉁?Valida莽茫o p贸s-instala莽茫o

Execute:

```bash
./wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh --run-action validate_all
```

A valida莽茫o cobre:

- 馃惂 WSL2/Ubuntu;
- 馃悕 Python;
- 鉁?uv/ruff/pytest/mypy;
- 馃煩 Node/npm/pnpm/yarn;
- 馃惓 Docker/Compose;
- 鈿?NVIDIA/CUDA;
- 馃尶 Git/GH;
- 馃О ferramentas principais.

---

## 馃Н Troubleshooting

### 鉂?O painel n茫o abre no navegador

Use a URL impressa no terminal:

```text
http://127.0.0.1:8797/?token=...
```

Se a porta estiver ocupada:

```bash
WEBNOVA_PORT=8899 ./wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh
```

### 鉂?Permiss茫o sudo expirada

Rode:

```bash
sudo -v
```

Depois execute a a莽茫o novamente.

### 鉂?Docker n茫o inicia

Verifique:

```bash
systemctl status docker || service docker status
```

Em alguns ambientes WSL2, systemd precisa estar habilitado.

### 鉂?`docker-compose` n茫o encontrado

Valide:

```bash
docker compose version
ls -l /usr/local/bin/docker-compose
```

### 鉂?`nvidia-smi` n茫o funciona

Verifique no Windows:

- driver NVIDIA instalado;
- GPU compat铆vel;
- WSL2 atualizado;
- Ubuntu rodando em vers茫o 2.

### 鉂?A instala莽茫o IA/LLM demora muito

Normal. O perfil 馃 IA/LLM baixa pacotes grandes. Use dry-run antes e rode quando a rede estiver est谩vel.

---

## 馃К Vari谩veis de ambiente

| Vari谩vel | Exemplo | Fun莽茫o |
|---|---|---|
| `WEBNOVA_DRY_RUN` | `1` | Ativa dry-run global |
| `WEBNOVA_PORT` | `8797` | Define porta local do painel |
| `WEBNOVA_HOST` | `127.0.0.1` | Host local do servidor |
| `DEBIAN_FRONTEND` | `noninteractive` | Evita prompts APT interativos |

Exemplo:

```bash
WEBNOVA_DRY_RUN=1 WEBNOVA_PORT=8899 ./wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh
```

---

## 馃搧 Estrutura recomendada do reposit贸rio

```text
wsl2-ubuntu-forge-webnova/
鈹溾攢鈹€ 馃搫 README.md
鈹溾攢鈹€ 馃悮 wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh
鈹溾攢鈹€ 馃搧 docs/
鈹?  鈹溾攢鈹€ VALIDATION.md
鈹?  鈹溾攢鈹€ CUDA_WSL.md
鈹?  鈹斺攢鈹€ DOCKER.md
鈹溾攢鈹€ 馃搧 .github/
鈹?  鈹斺攢鈹€ workflows/
鈹?      鈹溾攢鈹€ ci.yml
鈹?      鈹斺攢鈹€ release.yml
鈹斺攢鈹€ 馃摐 LICENSE
```

> 馃搶 Se ainda n茫o houver licen莽a, n茫o declare uma licen莽a no README como se ela existisse.

---

## 馃И Checklist de qualidade

Antes de publicar no GitHub:

```bash
bash -n wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh
./wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh --self-test
./wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh --menu-preview
./wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh --list-actions-json | python3 -m json.tool
```

Checklist visual:

- [ ] 馃Л Sidebar com 铆cones.
- [ ] 馃儚 Cards com 铆cones.
- [ ] 馃洝锔?Riscos com badges.
- [ ] 馃Ь Console com streaming.
- [ ] 馃И Dry-run funcionando.
- [ ] 馃殌 Modal de instala莽茫o completa.
- [ ] 馃摫 Layout responsivo.
- [ ] 鉁?Valida莽茫o final executada.

---

## 馃毀 Roadmap sugerido

Ideias futuras, sem declarar como implementadas:

- 馃И CI automatizado em Ubuntu.
- 馃摝 Releases versionadas no GitHub.
- 馃搫 `SECURITY.md`.
- 馃 `CONTRIBUTING.md`.
- 馃Ь Relat贸rio export谩vel sob demanda.
- 馃寳 Tema claro opcional.
- 馃實 Internacionaliza莽茫o PT-BR/EN.
- 馃惓 P谩gina dedicada Docker.
- 馃悕 P谩gina dedicada Python.
- 馃煩 P谩gina dedicada Node.
- 鈿?P谩gina dedicada CUDA.
- 馃搳 M茅tricas antes/depois por perfil.

---

## 馃摎 Refer锚ncias oficiais recomendadas

Use estas fontes ao revisar ou evoluir o projeto:

- 馃摌 Microsoft WSL documentation.
- 馃惂 Ubuntu documentation.
- 馃惓 Docker Engine for Ubuntu documentation.
- 馃З Docker Compose documentation.
- 鈿?NVIDIA CUDA on WSL documentation.
- 馃К NVIDIA Container Toolkit documentation.
- 馃悕 Python Packaging User Guide.
- 鉁?Astral uv and Ruff documentation.
- 馃尶 GitHub CLI documentation.

---

## 馃摐 Licen莽a

Nenhuma licen莽a foi declarada neste README.

Antes de publicar como open source, escolha uma licen莽a e inclua um arquivo `LICENSE` no reposit贸rio.

---

## 鉂わ笍 Nota final

**WSL2 Ubuntu Forge WebNova 路 Lumina Icons** foi feito para deixar a primeira hora depois do `wsl --install` muito mais organizada: menos ca莽a a comandos, mais clareza, mais valida莽茫o e um painel bonito o bastante para voc锚 n茫o querer fechar na primeira tela.

```text
馃獰 Windows + 馃惂 WSL2 + 馃寣 WebNova + 馃悕 Python + 馃惓 Docker + 鈿?CUDA
= ambiente pronto para construir coisa grande.
```
