"""Gera docs/instalar-repo-mac.zip com o instalador .command executavel.

Downloads perdem o bit de execucao; dentro de um zip ele e preservado e o
Archive Utility do macOS o restaura ao descompactar.
Uso: python scripts/build-mac-zip.py
"""
import pathlib
import zipfile

root = pathlib.Path(__file__).resolve().parent.parent
src = root / "installers" / "instalar-repo.command"
out = root / "docs" / "instalar-repo-mac.zip"

data = src.read_bytes().replace(b"\r\n", b"\n")
info = zipfile.ZipInfo("instalar-repo.command", date_time=(2026, 1, 1, 0, 0, 0))
info.create_system = 3  # Unix, para o macOS respeitar as permissoes
info.external_attr = (0o100755 << 16)
info.compress_type = zipfile.ZIP_DEFLATED

with zipfile.ZipFile(out, "w") as z:
    z.writestr(info, data)
print(f"gerado {out.relative_to(root)}")
