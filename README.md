# /repo — skill para Claude Code

Trava a sessão do Claude Code em **um único repositório** do GitHub, para que vários agentes trabalhando em paralelo não se confundam. Também organiza suas pastas de repositórios e confere se elas estão em dia com o GitHub.

Página: https://lucasnevescardoso.github.io/claude-skill-repo/

## Instalação

**macOS / Linux / Git Bash**

```bash
curl -fsSL https://lucasnevescardoso.github.io/claude-skill-repo/install.sh | bash
```

**Windows (PowerShell)**

```powershell
irm https://lucasnevescardoso.github.io/claude-skill-repo/install.ps1 | iex
```

O instalador grava a skill em `~/.claude/skills/repo/SKILL.md`. Se já existir uma versão diferente, ela é movida para `~/.claude/skill-backups/`. Reinicie o Claude Code e digite `/repo`.

**Como plugin** (dentro do Claude Code, recebe atualizações):

```
/plugin marketplace add LucasNevesCardoso/claude-skill-repo
/plugin install repo@repo-skill
```

## Comandos

| Comando | O que faz |
|---|---|
| `/repo` | Mostra a lista de comandos |
| `/repo create NOMEDAPASTA` | Cria uma pasta onde cada subpasta é um repositório |
| `/repo view` | Lista os repositórios das pastas registradas |
| `/repo <repositorio>` | Localiza o repositório e mostra o estado |
| `/repo <repositorio> lock` | Trava a sessão nesse repositório |
| `/repo <repositorio> unlock` | Destrava a sessão |
| `/repo review` | Valida todas as pastas contra o GitHub |
| `/repo review <repositorio>` | Valida só um repositório |
| `/repo TaskManagement <repositorio>` | Audita commits, PRs, reviews e atividade |

Requer o [GitHub CLI](https://cli.github.com/) autenticado (`gh auth login`).

## Estrutura

```
skills/repo/SKILL.md          a skill
.claude-plugin/               manifesto de plugin e marketplace
docs/                         landing page (GitHub Pages) e instaladores
```
