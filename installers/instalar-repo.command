#!/bin/bash
# Instalador de dois cliques para macOS. Empacotado em docs/instalar-repo-mac.zip
# por scripts/build-mac-zip.py (o zip preserva a permissao de execucao).
echo "Instalando a skill /repo no Claude Code..."
echo
curl -fsSL https://lucasnevescardoso.github.io/claude-skill-repo/install.sh | bash
echo
read -n 1 -s -r -p "Pressione qualquer tecla para fechar."
echo
