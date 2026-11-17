@echo off
title Instalando a skill /repo
echo Instalando a skill /repo no Claude Code...
echo.
powershell -NoProfile -Command "irm https://lucasnevescardoso.github.io/claude-skill-repo/install.ps1 | iex"
echo.
pause
