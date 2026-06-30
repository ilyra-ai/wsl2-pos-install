# &#x1F680; WSL2 Ubuntu Forge WebNova

> Instalador premium, visual e seguro para preparar um Ubuntu recem-instalado no WSL2 com ferramentas modernas de desenvolvimento, Python, Node.js, Docker, Docker Compose, CUDA WSL e NVIDIA Container Toolkit.

![WSL2](https://img.shields.io/badge/WSL2-Ubuntu-5E5CE6?style=for-the-badge&logo=ubuntu&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-WebNova%20TUI-00C2A8?style=for-the-badge&logo=gnubash&logoColor=white)
![Python](https://img.shields.io/badge/Python-Dev%20Ready-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose%20Plugin-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![CUDA](https://img.shields.io/badge/CUDA-WSL%20Toolkit-76B900?style=for-the-badge&logo=nvidia&logoColor=white)

---

## &#x2728; Visao geral

O **WSL2 Ubuntu Forge WebNova** e um script Bash com painel Web local para preparar uma distribuicao Ubuntu instalada via `wsl --install`.

Ele foi criado para transformar um Ubuntu limpo em um ambiente profissional para:

- &#x1F9F1; desenvolvimento base no WSL2;
- &#x1F4BB; terminal moderno e ferramentas de produtividade;
- &#x1F527; compilacao e build tools;
- &#x1F4E6; Git, GitHub CLI e fluxo de repositorio;
- &#x1F40D; Python moderno;
- &#x1F7E2; Node.js moderno;
- &#x1F433; Docker Engine com Docker Compose Plugin;
- &#x26A1; CUDA Toolkit para WSL-Ubuntu;
- &#x1F9EC; NVIDIA Container Toolkit;
- &#x1F50D; validacao geral do ambiente.

> **Nota importante de codificacao:** este README foi escrito em formato **ASCII-safe**. Os acentos e emojis foram representados com entidades HTML, como `&oacute;` e `&#x1F680;`, para evitar erros como `mojibake` ou caracteres quebrados em editores que abrem arquivos com codificacao errada.

---

## &#x1F4DA; Sumario

- [&#x2728; Visao geral](#-visao-geral)
- [&#x1F3AF; Objetivo do projeto](#-objetivo-do-projeto)
- [&#x1F5BC; WebNova Lumina Icons](#-webnova-lumina-icons)
- [&#x1F9ED; Catalogo de acoes](#-catalogo-de-acoes)
- [&#x2699; Requisitos](#-requisitos)
- [&#x1F680; Instalacao rapida](#-instalacao-rapida)
- [&#x1F310; Uso pelo painel WebNova](#-uso-pelo-painel-webnova)
- [&#x2328; Uso via CLI](#-uso-via-cli)
- [&#x1F6E1; Dry-run global](#-dry-run-global)
- [&#x1F40D; Stack Python](#-stack-python)
- [&#x1F7E2; Stack Nodejs](#-stack-nodejs)
- [&#x1F433; Docker e Docker Compose](#-docker-e-docker-compose)
- [&#x26A1; CUDA WSL e NVIDIA Container Toolkit](#-cuda-wsl-e-nvidia-container-toolkit)
- [&#x2705; Validacao](#-validacao)
- [&#x1F6E0; Troubleshooting](#-troubleshooting)
- [&#x1F512; Seguranca operacional](#-seguranca-operacional)
- [&#x1F5FA; Roadmap sugerido](#-roadmap-sugerido)

---

## &#x1F3AF; Objetivo do projeto

Depois de instalar o Ubuntu com:

```powershell
wsl --install
```

ou:

```powershell
wsl --install -d Ubuntu
```

o ambiente ainda precisa de ferramentas essenciais para trabalhar bem com desenvolvimento moderno.

Este projeto centraliza essa preparacao em um painel visual com acoes reais e verificaveis.

Ele nao tenta instalar tudo do mundo. O foco e instalar somente o que foi definido para um ambiente WSL2 Ubuntu profissional:

| Area | Conteudo |
|---|---|
| &#x1F9F1; Base | APT, certificados, curl, wget, GPG, locales, timezone e utilitarios essenciais |
| &#x1F4BB; Terminal | jq, yq, tree, htop, btop, ncdu, tmux, fzf, ripgrep, fd, bat, shellcheck, shfmt |
| &#x1F527; Build | build-essential, gcc, g++, make, cmake, ninja, pkg-config, autoconf, automake |
| &#x1F4E6; Git | git, git-lfs, OpenSSH e GitHub CLI |
| &#x1F40D; Python | python3, pip, venv, dev headers, pipx, uv, ruff, pytest, mypy e stacks opcionais |
| &#x1F7E2; Node.js | Node.js, npm, Corepack, pnpm e yarn |
| &#x1F433; Docker | Docker Engine, Buildx e Docker Compose Plugin |
| &#x26A1; CUDA | CUDA Toolkit 13.0 para WSL-Ubuntu |
| &#x1F9EC; NVIDIA | NVIDIA Container Toolkit e runtime Docker |

---

## &#x1F5BC; WebNova Lumina Icons

A interface WebNova usa um painel local em `127.0.0.1`, com foco em clareza visual e seguranca.

### &#x2728; Destaques visuais

- &#x1F9ED; sidebar com icones por area;
- &#x1F5C2; cards iconizados por acao;
- &#x1F50E; busca rapida no catalogo;
- &#x1F4CA; cards de status do ambiente;
- &#x1F5A5; console real com streaming SSE;
- &#x1F6E1; badge de risco por acao;
- &#x1F4F1; layout responsivo;
- &#x1F319; visual dark-first;
- &#x1F308; detalhes Lumina com gradientes e glassmorphism controlado;
- &#x1F680; botao de instalacao completa com confirmacao.

### &#x1F4CC; Filosofia visual

A UI foi pensada para ser bonita, mas sem virar carnaval de botao. A prioridade e:

- leitura rapida;
- contraste adequado;
- acoes bem separadas;
- feedback visual claro;
- console sempre visivel;
- navegacao simples;
- responsividade real.

---

## &#x1F9ED; Catalogo de acoes

O script possui **15 acoes reais**.

| ID | Icone | Acao | Descricao |
|---:|:---:|---|---|
| 1 | &#x1F4CA; | `status` | Mostra diagnostico rapido do WSL2 Ubuntu |
| 2 | &#x1F9F1; | `install_base` | Instala base do sistema e utilitarios essenciais |
| 3 | &#x1F4BB; | `install_terminal` | Instala ferramentas modernas de terminal |
| 4 | &#x1F527; | `install_build` | Instala compiladores e bibliotecas de build |
| 5 | &#x1F4E6; | `install_git_gh` | Instala Git, Git LFS, OpenSSH e GitHub CLI |
| 6 | &#x1F40D; | `install_python_core` | Instala Python essencial |
| 7 | &#x1F9EA; | `install_python_modern` | Instala ferramentas Python modernas |
| 8 | &#x1F310; | `install_python_backend` | Instala stack Python para APIs e backend |
| 9 | &#x1F4CA; | `install_python_data` | Instala stack Python para dados e notebooks |
| 10 | &#x1F916; | `install_python_ai` | Instala stack Python opcional para IA |
| 11 | &#x1F7E2; | `install_node` | Instala Node.js, npm, Corepack, pnpm e yarn |
| 12 | &#x1F433; | `install_docker` | Instala Docker Engine e Docker Compose Plugin |
| 13 | &#x26A1; | `install_cuda` | Instala CUDA WSL e NVIDIA Container Toolkit |
| 14 | &#x2705; | `validate_all` | Valida ferramentas instaladas |
| 15 | &#x1F680; | `install_all` | Executa todas as instalacoes definidas |

---

## &#x2699; Requisitos

### &#x1F5A5; Windows

- Windows 10 com WSL2 atualizado ou Windows 11.
- WSL instalado.
- Ubuntu instalado via WSL.
- Permissao administrativa no Windows para instalar WSL, drivers e Docker Desktop quando necessario.

### &#x1F427; Ubuntu no WSL2

- Ubuntu em modo WSL2.
- Usuario com `sudo`.
- Internet ativa.
- `bash` disponivel.
- `python3` para o servidor WebNova local.

Validar a distro:

```bash
wsl.exe -l -v
```

Validar dentro do Ubuntu:

```bash
cat /etc/os-release
uname -a
```

---

## &#x1F680; Instalacao rapida

Baixe o script e execute:

```bash
chmod +x wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh
./wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh --self-test
./wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh
```

O painel exibira uma URL local semelhante a:

```text
http://127.0.0.1:8797/?token=TOKEN_LOCAL
```

Copie e cole no navegador do Windows se ele nao abrir automaticamente.

---

## &#x1F310; Uso pelo painel WebNova

Ao abrir o painel, voce vera:

- &#x1F9ED; sidebar com todas as acoes;
- &#x1F5C2; cards de instalacao;
- &#x1F4CA; status do ambiente;
- &#x2328; console real;
- &#x1F6E1; controle de dry-run;
- &#x1F680; botao para instalacao completa.

Fluxo recomendado:

1. &#x1F4CA; execute `status`;
2. &#x1F6E1; ative dry-run se quiser simular comandos;
3. &#x1F9F1; instale base;
4. &#x1F527; instale build tools;
5. &#x1F40D; instale Python;
6. &#x1F7E2; instale Node.js;
7. &#x1F433; instale Docker;
8. &#x26A1; instale CUDA somente se tiver NVIDIA/WSL GPU pronto;
9. &#x2705; rode `validate_all`.

---

## &#x2328; Uso via CLI

Listar acoes:

```bash
./wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh --menu-preview
```

Listar acoes em JSON:

```bash
./wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh --list-actions-json
```

Executar uma acao especifica:

```bash
./wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh --run-action status
```

Executar tudo:

```bash
./wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh --run-action install_all
```

---

## &#x1F6E1; Dry-run global

O dry-run mostra os comandos sem aplicar alteracoes.

Via ambiente:

```bash
WEBNOVA_DRY_RUN=1 ./wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh --run-action install_all
```

No painel WebNova, use o controle visual de dry-run antes de rodar acoes.

### &#x26A0; Importante

Dry-run nao instala pacotes. Ele serve para revisar o plano de execucao.

---

## &#x1F40D; Stack Python

### &#x1F9F1; Python core

- `python3`
- `python3-pip`
- `python3-venv`
- `python3-dev`
- `python-is-python3`
- `pipx`
- `setuptools`
- `wheel`
- `build`

### &#x1F9EA; Python moderno

- `uv`
- `ruff`
- `pytest`
- `pytest-cov`
- `mypy`
- `pyright`
- `pre-commit`
- `virtualenv`

### &#x1F310; Backend Python

- `fastapi`
- `uvicorn`
- `pydantic`
- `sqlalchemy`
- `alembic`
- `psycopg`
- `asyncpg`
- `redis`
- `httpx`
- `python-dotenv`

### &#x1F4CA; Dados e notebooks

- `jupyterlab`
- `ipykernel`
- `notebook`
- `numpy`
- `pandas`
- `polars`
- `pyarrow`
- `scikit-learn`
- `duckdb`
- `matplotlib`

### &#x1F916; IA opcional

- `torch`
- `transformers`
- `accelerate`
- `datasets`
- `sentence-transformers`
- `onnxruntime`

> O perfil de IA e opcional porque pacotes como `torch` podem ser grandes e dependem do objetivo do ambiente.

---

## &#x1F7E2; Stack Nodejs

O script instala uma base Node.js moderna:

- `nodejs`
- `npm`
- `corepack`
- `pnpm`
- `yarn`

Validacoes esperadas:

```bash
node --version
npm --version
corepack --version
pnpm --version
yarn --version
```

---

## &#x1F433; Docker e Docker Compose

O script instala:

- `docker-ce`
- `docker-ce-cli`
- `containerd.io`
- `docker-buildx-plugin`
- `docker-compose-plugin`

Tambem cria compatibilidade com:

```bash
docker compose version
docker-compose version
```

O comando `docker-compose` e implementado como wrapper para o comando moderno:

```bash
docker compose "$@"
```

### &#x1F4CC; Observacao sobre Docker Desktop

Se voce usa Docker Desktop no Windows com integracao WSL2, valide antes de instalar Docker Engine dentro do Ubuntu para evitar conflito de estrategia.

---

## &#x26A1; CUDA WSL e NVIDIA Container Toolkit

A acao `install_cuda` segue a sequencia do instalador CUDA WSL:

1. Remove instalador local antigo, se existir.
2. Baixa o pin do repositorio CUDA WSL-Ubuntu.
3. Instala o repositorio local CUDA 13.0.
4. Copia keyring CUDA.
5. Executa `apt-get update`.
6. Instala `cuda-toolkit-13-0`.
7. Configura repositorio NVIDIA Container Toolkit.
8. Instala `nvidia-container-toolkit` e dependencias.
9. Executa `nvidia-ctk runtime configure --runtime=docker`.
10. Reinicia Docker via `systemctl` ou `service`.

### &#x26A0; Importante sobre driver NVIDIA

No WSL2, o driver NVIDIA deve estar instalado no Windows. O script nao instala driver NVIDIA Linux dentro do Ubuntu WSL2.

Validacoes uteis:

```bash
nvidia-smi
nvcc --version
nvidia-ctk --version
docker run --rm --gpus all nvidia/cuda:13.0.0-base-ubuntu24.04 nvidia-smi
```

---

## &#x2705; Validacao

Rodar self-test:

```bash
./wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh --self-test
```

Rodar validacao geral:

```bash
./wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh --run-action validate_all
```

Validacoes importantes:

| Area | Comando |
|---|---|
| &#x1F427; WSL2 | `wsl.exe -l -v` |
| &#x1F4E6; APT | `apt --version` |
| &#x1F4BB; Terminal | `jq --version` |
| &#x1F40D; Python | `python3 --version` |
| &#x1F9EA; uv | `uv --version` |
| &#x1F7E2; Node | `node --version` |
| &#x1F433; Docker | `docker version` |
| &#x1F433; Compose | `docker compose version` |
| &#x26A1; CUDA | `nvcc --version` |
| &#x1F9EC; NVIDIA | `nvidia-smi` |

---

## &#x1F6E0; Troubleshooting

### &#x274C; O painel nao abre

Tente iniciar em uma porta diferente:

```bash
WEBNOVA_PORT=8899 ./wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh
```

### &#x274C; Sem permissao sudo

Valide:

```bash
sudo -v
```

### &#x274C; Docker nao responde

Tente:

```bash
sudo systemctl restart docker || sudo service docker restart
sudo docker info
```

### &#x274C; CUDA nao aparece

Valide no Windows:

```powershell
nvidia-smi
```

Depois valide dentro do WSL2:

```bash
nvidia-smi
ls /usr/lib/wsl/lib
```

### &#x274C; Saida com caracteres quebrados

Use este README ASCII-safe. Ele evita caracteres UTF-8 diretos no arquivo fonte.

Se precisar ajustar terminal:

```bash
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
```

---

## &#x1F512; Seguranca operacional

Este projeto evita:

- `eval`;
- alteracao de GRUB;
- instalacao de kernel customizado;
- instalacao de driver NVIDIA Linux dentro do WSL2;
- exposicao do painel fora de `127.0.0.1`;
- instalacao silenciosa sem comandos visiveis;
- execucao remota sem controle local.

Recomendacoes:

- revise o dry-run antes de instalar tudo;
- execute CUDA somente se tiver GPU NVIDIA pronta no Windows;
- valide Docker Desktop versus Docker Engine antes de escolher estrategia;
- evite `sudo pip install`;
- prefira ambientes virtuais Python por projeto.

---

## &#x1F5FA; Roadmap sugerido

- &#x1F4DD; exportar relatorio temporario sob demanda;
- &#x1F5C3; historico em memoria por sessao;
- &#x1F319; tema claro opcional;
- &#x1F433; pagina dedicada Docker;
- &#x1F40D; pagina dedicada Python;
- &#x1F7E2; pagina dedicada Node.js;
- &#x26A1; pagina dedicada CUDA/GPU;
- &#x1F9EA; testes automatizados em Ubuntu via GitHub Actions;
- &#x1F4E6; releases versionadas;
- &#x1F310; internacionalizacao controlada pelo painel.

---

## &#x1F4C1; Estrutura recomendada do repositorio

```text
wsl2-ubuntu-forge-webnova/
|-- README.md
|-- wsl2-ubuntu-forge-webnova-v1.1-lumina-icons.sh
|-- docs/
|   `-- VALIDATION.md
`-- .github/
    `-- workflows/
        `-- ci.yml
```

---

## &#x1F9EA; Checklist antes de abrir uma issue

- [ ] Rodei `--self-test`.
- [ ] Rodei em WSL2 Ubuntu.
- [ ] Copiei a saida completa do console.
- [ ] Testei com dry-run.
- [ ] Confirmei se Docker Desktop esta ou nao em uso.
- [ ] Confirmei se `nvidia-smi` funciona no Windows antes de instalar CUDA.

---

## &#x1F49C; Creditos

Criado para preparar ambientes WSL2 Ubuntu com foco em qualidade, seguranca, visual moderno e execucao verificavel.

---

## &#x1F4DC; Licenca

Nenhuma licenca foi definida neste README. Adicione uma `LICENSE` ao repositorio antes de publicar como open source.
