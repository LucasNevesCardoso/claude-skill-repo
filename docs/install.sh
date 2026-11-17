#!/usr/bin/env bash
# Instala a skill /repo no Claude Code (macOS, Linux, Git Bash/WSL).
# Uso: curl -fsSL https://lucasnevescardoso.github.io/claude-skill-repo/install.sh | bash
set -euo pipefail

REPO="LucasNevesCardoso/claude-skill-repo"
BRANCH="${REPO_SKILL_BRANCH:-main}"
URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/skills/repo/SKILL.md"
BASE="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
DEST="$BASE/skills/repo"

command -v curl >/dev/null 2>&1 || { echo "Erro: curl nao encontrado." >&2; exit 1; }

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

echo "-> Baixando SKILL.md de $REPO ($BRANCH)"
curl -fsSL "$URL" -o "$tmp"
grep -q '^name:' "$tmp" || { echo "Erro: arquivo baixado nao parece uma skill valida." >&2; exit 1; }

# Se ja existe uma instalacao diferente, guarda uma copia fora da pasta de skills
if [ -d "$DEST" ] && [ -n "$(ls -A "$DEST" 2>/dev/null)" ]; then
  if ! cmp -s "$tmp" "$DEST/SKILL.md" 2>/dev/null; then
    backup="$BASE/skill-backups/repo-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$(dirname "$backup")"
    mv "$DEST" "$backup"
    echo "-> Instalacao anterior movida para $backup"
  fi
fi

mkdir -p "$DEST"
cp "$tmp" "$DEST/SKILL.md"

echo ""
echo "Skill /repo instalada em $DEST"
echo "Reinicie o Claude Code e digite /repo para ver os comandos."
