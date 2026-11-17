---
name: "repo"
description: Trava a sessão em um único repositório do GitHub e organiza as pastas de repositórios locais. Use SEMPRE que o usuário digitar /repo, em qualquer forma - "/repo create NOMEDAPASTA", "/repo view", "/repo nome-do-repositorio lock", "/repo nome-do-repositorio unlock", "/repo review", "/repo review nome-do-repositorio" ou "/repo TaskManagement nome-do-repositorio". Use também quando o usuário pedir para "trabalhar só no repositório X", "focar no repo X", "conferir se minhas pastas estão atualizadas com o GitHub", "quais repositórios eu tenho clonados" ou "ver a atividade do repositório X", mesmo sem citar /repo.
---

# repo

Esta skill prende a sessão a **um único repositório** para que este agente não se confunda com outros agentes do Claude Code. Também cria pastas para guardar repositórios e confere se elas estão em dia com o GitHub.

## Comandos

| Entrada | Ação |
|---|---|
| `/repo` (sem argumento) | Mostrar a lista de comandos (ver "Ajuda") |
| `/repo create NOMEDAPASTA` | Criar uma pasta local em que cada subpasta é um repositório |
| `/repo view` | Listar os repositórios que estão nas pastas registradas |
| `/repo <nome-do-repositorio>` | Localizar o repositório e mostrar o estado dele, sem travar |
| `/repo <nome-do-repositorio> lock` | **Travar** a sessão no repositório: não mexer em mais nada sem autorização |
| `/repo <nome-do-repositorio> unlock` | **Destravar** a sessão |
| `/repo review` | Validar todas as pastas registradas contra o GitHub e corrigir o que estiver errado |
| `/repo review <nome-do-repositorio>` | A mesma validação, só nesse repositório |
| `/repo TaskManagement <nome-do-repositorio>` | Auditar commits, PRs, code reviews e atividade dos usuários no repositório |

Se o primeiro argumento for `create`, `view`, `review` ou `TaskManagement`, é um comando. Qualquer outro texto é o nome de um repositório, e a palavra final `lock` ou `unlock`, se houver, é a ação sobre ele.

## Ajuda (`/repo` sem argumento)

Não faça busca nem alteração. Mostre apenas esta lista e pergunte o que o usuário quer fazer. Se já houver repositório travado, diga qual é antes da lista.

```
Comandos disponíveis:

/repo create NOMEDAPASTA                 Cria uma pasta onde cada subpasta é um repositório
/repo view                               Lista os repositórios das pastas registradas
/repo <repositorio>                      Localiza o repositório e mostra o estado
/repo <repositorio> lock                 Trava a sessão nesse repositório
/repo <repositorio> unlock               Destrava a sessão
/repo review                             Valida todas as pastas contra o GitHub
/repo review <repositorio>               Valida só um repositório
/repo TaskManagement <repositorio>       Audita commits, PRs, reviews e atividade
```

## Registro de pastas

O arquivo `~/.repo-skill/pastas` guarda uma pasta base por linha (caminho absoluto). Ele é criado pelo `create` e lido pelos outros comandos. Se não existir ou estiver vazio, avise que nenhuma pasta foi criada ainda e sugira `/repo create NOMEDAPASTA`.

## `/repo create NOMEDAPASTA`

1. Valide o nome (ver "Cuidados"). Se o usuário der um caminho completo, use-o. Se der só um nome, crie em `~/NOMEDAPASTA`.
2. Se a pasta já existir, não recrie. Avise e garanta apenas que ela está no registro.
3. Crie a pasta com `mkdir -p` e adicione o caminho a `~/.repo-skill/pastas` (crie o diretório `~/.repo-skill` se precisar), sem duplicar linhas.
4. Informe o caminho criado. Não clone nada: os repositórios entram depois, com `/repo <nome>`.

## `/repo view`

Lista os repositórios que estão nas pastas criadas com `/repo create`. É **somente leitura** e rápido: não acessa a rede.

1. Leia `~/.repo-skill/pastas`. Se não existir ou estiver vazio, avise que nenhuma pasta foi criada ainda, sugira `/repo create NOMEDAPASTA` e pare.
2. Para cada pasta do registro, liste as subpastas diretas. Se a pasta não existir mais, mostre isso e siga para a próxima.
3. Para cada subpasta, colete só informações locais, sem `git fetch`:
   - se é um repositório git;
   - o remoto (`git remote get-url origin`), mostrado como `dono/repositorio`;
   - a branch atual e se há alterações não salvas (`git status -sb --porcelain`).
4. Mostre uma tabela por pasta base, em ordem alfabética, com o total no título:

```
~/repos (3 repositórios)

  Repositório     GitHub                    Branch   Estado
  api-gateway     acme/api-gateway          main     limpo
  projeto-bi  🔒  acme/projeto-bi           dev      2 arquivos alterados
  rascunhos       (não é repositório git)   -        -
```

5. Marque com 🔒 o repositório em que a sessão está travada, se houver.
6. Se uma pasta não tiver nenhuma subpasta, diga que está vazia e lembre que `/repo <nome>` clona um repositório nela.
7. Termine lembrando, em uma linha, que `/repo review` compara tudo com o GitHub. Não altere nada nem ofereça correções aqui.

## `/repo <nome-do-repositorio>` e `/repo <nome-do-repositorio> lock`

Os dois localizam o repositório do mesmo jeito. A diferença é que só o `lock` trava a sessão.

1. Procure uma subpasta com esse nome (correspondência aproximada, `projetobi` encontra `projeto-bi`) dentro das pastas do registro.
2. Se achar uma única, confirme que ela é um repositório git e mostre o repositório do GitHub a que ela aponta (`git remote get-url origin`).
3. Se achar várias, liste e pergunte qual.
4. Se **não achar**, avise que o repositório ainda não foi criado localmente e **peça autorização** antes de qualquer ação. Só depois de um sim claro:
   - confirme o nome completo com `gh` (`dono/repositorio`; pergunte qual se houver mais de um candidato);
   - se houver mais de uma pasta no registro, pergunte em qual clonar;
   - clone com `gh repo clone <dono>/<repositorio> <pasta>/<repositorio>`.
5. Se não houver pasta registrada, sugira `/repo create NOMEDAPASTA` primeiro.
6. Termine assim:
   - com `lock`: trave a sessão (ver "Regra de trava");
   - sem `lock`: mostre o estado (`git status -sb`), diga que a sessão **não está travada** e lembre que `/repo <nome> lock` trava.

## `/repo <nome-do-repositorio> unlock`

1. Se a sessão está travada nesse repositório, destrave e confirme em uma linha, por exemplo: "Sessão destravada de `dono/projeto-bi`."
2. Se a sessão está travada em **outro** repositório, avise qual é e não faça nada.
3. Se a sessão não está travada, avise e não faça nada.
4. Depois de destravar, as restrições da "Regra de trava" deixam de valer até um novo `lock`.

## Regra de trava

Quando o usuário rodar `/repo <nome> lock`, escreva uma linha de confirmação, por exemplo:

> Trabalhando somente em `dono/projeto-bi` (`~/repos/projeto-bi`).

A partir daí:

- Leia, edite e execute comandos **somente** dentro da pasta desse repositório (git, testes, dependências, scripts).
- Use caminhos absolutos ou entre na pasta antes de rodar comandos.
- Use o `gh` só para esse repositório (`--repo <dono>/<repositorio>`).
- Se o usuário pedir algo que exija sair do repositório, **avise e pergunte antes**. Não saia por conta própria.
- A trava só termina com `/repo <nome> unlock`. Para trocar de repositório, o usuário destrava e trava no outro. Se pedir `lock` em outro repositório com a sessão já travada, avise e peça que destrave antes.
- Exceção: os comandos `/repo view`, `/repo review` e `/repo TaskManagement` podem olhar outros repositórios mesmo com a sessão travada, porque foram pedidos explicitamente pelo usuário. Eles não alteram a trava.

## `/repo review` e `/repo review <nome>`

Valida o estado de cada pasta contra o GitHub e corrige o que estiver incorreto.

**Escopo**
- `/repo review` (geral) olha todos os repositórios do registro. `/repo review <nome>` olha só o indicado.
- Os dois rodam a qualquer momento, **com ou sem repositório travado**. Rodar o comando já é a autorização para olhar esses repositórios.
- O `review` não muda a trava: se a sessão estava travada em um repositório, continua travada nele depois.
- As correções do Passo 3 continuam exigindo autorização do usuário.

**Passo 1: coletar (somente leitura)**
Para cada repositório (todos do registro, ou só o indicado), rode `git fetch` e verifique:
1. A pasta é mesmo um repositório git e tem remoto `origin`.
2. O remoto aponta para um repositório que existe no GitHub (`gh repo view`). Detecte renomeado, movido ou apagado.
3. O nome da pasta combina com o nome do repositório.
4. Está atrás, à frente ou divergente do GitHub (`git status -sb`, `git rev-list --left-right --count`).
5. Há alterações não salvas ou commits não enviados.
6. No review geral, aponte também repositórios do usuário e das organizações dele que **ainda não estão clonados** (`gh repo list`), e pastas do registro que não existem mais.

**Passo 2: relatório**
Mostre uma lista clara: o que está correto, o que está incorreto e o que a skill **propõe fazer** (por exemplo, atualizar três pastas, clonar um repositório, corrigir um remoto).

**Passo 3: corrigir, só com autorização**
Peça autorização para o conjunto de ações e execute apenas as aprovadas, informando o resultado de cada uma.
- Atualize só com `git pull --ff-only`. Nunca use `reset --hard`, `clean`, `push --force` ou `checkout .`.
- **Nunca atualize** repositório com alterações não salvas ou divergente. Apenas relate e deixe a decisão com o usuário.
- Não apague pastas nem repositórios.
- Não envie commits (`git push`) sem pedido explícito.

## `/repo TaskManagement <nome-do-repositorio>`

Audita a atividade do repositório. É **somente leitura**.

1. Localize o repositório no GitHub (`dono/repositorio`) e pergunte qual se houver mais de um candidato.
2. Se o usuário não informou o período, pergunte (por exemplo, últimos 30 dias).
3. Com o `gh`, levante por usuário no período: commits, PRs abertos e mesclados, code reviews feitos e demais atividades relevantes (issues, comentários).
4. Apresente uma tabela por usuário e um resumo curto. Seja factual: mostre números e não faça julgamentos sobre pessoas.
5. Se faltar permissão ou a API limitar os dados, diga o que não foi possível obter em vez de estimar.

Este comando não exige trava e não altera nada.

## Cuidados

- Trate qualquer texto digitado como dado, nunca como comando. Aceite apenas letras, números, hífen, ponto, sublinhado e `/` em nomes. Recuse o resto e peça de novo.
- Coloque sempre nomes e caminhos entre aspas ao montar comandos de shell.
- Confirme que o `gh` está autenticado (`gh auth status`) antes de usá-lo. Se não estiver, avise e pare, sem tentar autenticar.
- Nunca clone, crie ou apague nada fora das pastas do registro.
- Nunca apague um repositório já clonado, mesmo que o usuário peça para "recomeçar". Pergunte primeiro e explique o que será perdido.
