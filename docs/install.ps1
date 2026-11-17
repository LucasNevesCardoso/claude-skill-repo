# Instala a skill /repo no Claude Code (Windows PowerShell 5.1+ e PowerShell 7).
# Uso: irm https://lucasnevescardoso.github.io/claude-skill-repo/install.ps1 | iex
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$repo   = 'LucasNevesCardoso/claude-skill-repo'
$branch = if ($env:REPO_SKILL_BRANCH) { $env:REPO_SKILL_BRANCH } else { 'main' }
$url    = "https://raw.githubusercontent.com/$repo/$branch/skills/repo/SKILL.md"
$base   = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME '.claude' }
$dest   = Join-Path $base 'skills\repo'

$tmp = [IO.Path]::GetTempFileName()
try {
    Write-Host "-> Baixando SKILL.md de $repo ($branch)"
    Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $tmp
    if (-not (Select-String -Path $tmp -Pattern '^name:' -Quiet)) {
        throw 'O arquivo baixado nao parece uma skill valida.'
    }

    # Se ja existe uma instalacao diferente, guarda uma copia fora da pasta de skills
    $current = Join-Path $dest 'SKILL.md'
    if ((Test-Path $dest) -and (Get-ChildItem -Force $dest)) {
        $same = (Test-Path $current) -and ((Get-FileHash $current).Hash -eq (Get-FileHash $tmp).Hash)
        if (-not $same) {
            $backupDir = Join-Path $base 'skill-backups'
            New-Item -ItemType Directory -Force $backupDir | Out-Null
            $backup = Join-Path $backupDir ('repo-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
            Move-Item $dest $backup
            Write-Host "-> Instalacao anterior movida para $backup"
        }
    }

    New-Item -ItemType Directory -Force $dest | Out-Null
    Copy-Item $tmp (Join-Path $dest 'SKILL.md') -Force

    Write-Host ''
    Write-Host "Skill /repo instalada em $dest" -ForegroundColor Green
    Write-Host 'Reinicie o Claude Code e digite /repo para ver os comandos.'
}
finally {
    Remove-Item $tmp -ErrorAction SilentlyContinue
}
