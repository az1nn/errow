# SIGA HANDOFF v1

Portable Continuation Protocol

## Objetivo

`Siga` é uma palavra-chave de retomada operacional.

Quando o usuário disser apenas:

`Siga`

o agente NÃO deve interpretar isso simplesmente como “faça a próxima coisa”.

Antes de executar qualquer trabalho, deve reconstruir o estado real e atual do app, projeto ou workstream e decidir automaticamente qual tipo de continuação é apropriado.

O protocolo deve funcionar em qualquer ambiente: GitHub, GitLab, aplicação SaaS, projeto local, automação, documento, design, infraestrutura, agente de IA ou outro sistema com estado persistente.

## PRINCÍPIO FUNDAMENTAL

`REAL STATE > HANDOFF > MEMORY > CHAT`

A hierarquia de confiança é:

Estado real verificável do sistema
→ artefatos persistidos / handoffs
→ memória disponível
→ histórico da conversa

O chat nunca deve ser considerado sozinho como fonte canônica de estado.

Toda execução de `Siga` começa em modo:

`VERIFY-FIRST`

## SIGA — START PROTOCOL

### 1. RECONCILE

Reconstrua o estado atual usando todas as fontes disponíveis.

Dependendo do ambiente, verifique:

- estado do projeto/app;
- branch / workspace / ambiente atual;
- HEAD ou versão atualmente implantada;
- tarefas abertas;
- PRs/MRs;
- agentes ou workers ativos;
- jobs assíncronos;
- CI/CD;
- testes;
- builds;
- deploys;
- comentários ou reviews pendentes;
- gates humanos;
- bloqueios;
- artefatos persistidos;
- specs;
- ADRs;
- issues;
- estado remoto versus local.

Não assuma que o último estado descrito no chat ainda é verdadeiro.

### 2. CLASSIFY

Depois da reconciliação, classifique automaticamente a situação em exatamente um dos três modos abaixo.

#### MODE A — RESUME

Existe trabalho iniciado e interrompido que ainda precisa ser concluído.

Exemplos:

- PR aberto com implementação incompleta.
- Task iniciada.
- Bug ainda não resolvido.
- Mudanças locais não finalizadas.
- Spec com tarefas pendentes.
- Ação interrompida entre implementação e validação.

Ação:

Continue exatamente da última fronteira segura encontrada.

Não crie uma nova unidade de trabalho desnecessariamente.

#### MODE B — WATCH

O trabalho principal já foi disparado, mas existe processamento ou validação ainda acontecendo.

Exemplos:

- CI rodando.
- Agente trabalhando.
- Deploy em andamento.
- Review humano pendente.
- Job assíncrono executando.
- Pipeline esperando gate.

Ação:

Não duplique o trabalho.

Inspecione o estado atual.

Consuma resultados que já tenham terminado.

Corrija falhas quando possível.

Se ainda houver execução realmente ativa e nenhuma ação imediata for necessária, mantenha o workstream atual como unidade canônica.

Nunca abra branch, PR, task ou sessão paralela apenas porque o processo ainda não terminou.

#### MODE C — ADVANCE

O trabalho anterior terminou de maneira verificável e não há execução pendente que precise ser acompanhada.

Ação:

Determine a próxima unidade lógica de trabalho a partir de:

- roadmap;
- spec;
- tasks;
- issues;
- handoff;
- dependências;
- prioridades explicitamente definidas.

Somente neste modo uma nova branch, PR, task, spec ou workstream deve ser iniciada.

### 3. EXECUTE

Depois de selecionar o modo:

`implement → verify → classify → persist`

Toda alteração deve ser validada antes de ser considerada concluída.

A profundidade da verificação depende do app, mas deve usar as melhores provas disponíveis.

Exemplos:

- testes;
- lint;
- typecheck;
- build;
- CI;
- Engineering Graph;
- preview;
- screenshots;
- API checks;
- queries;
- logs;
- deploy health;
- human validation;
- contract validation.

Compressão de contexto nunca pode significar compressão da verificação.

## INVARIANTS

Durante uma execução `Siga`:

- Não mascarar FAIL.
- Não declarar sucesso sem evidência.
- Não duplicar trabalho já em execução.
- Não criar novo workstream sem reconciliar o existente.
- Não confiar cegamente no estado descrito pelo chat anterior.
- Não alterar comportamento apenas para fazer um gate ficar verde sem resolver a causa real.
- Não realizar merge/deploy destrutivo automaticamente quando existir gate humano explícito.
- Não apagar contexto necessário para reconstruir decisões.

Quando existir conflito:

`estado canônico atual vence memória e chat`.

## HUMAN GATES

Se existir uma decisão explicitamente reservada ao usuário:

pare somente na fronteira dessa decisão.

O restante do trabalho verificável deve ser concluído normalmente.

Exemplos:

- Design Gate.
- aprovação visual.
- merge autorizado manualmente.
- decisão arquitetural.
- produção.
- custos.
- mudança destrutiva.

O agente deve apresentar exatamente:

- estado atual;
- evidências;
- decisão necessária;
- efeito de cada alternativa relevante.

### Regra de testes humanos assíncronos — Errow

Teste humano pendente NÃO é, por si só, um human gate.

No Errow:

- validação visual, responsividade, touch UX e gameplay feel são trabalho assíncrono por padrão;
- a ausência de resultado humano não deve manter o workstream em `WATCH`;
- um PR automatizado e verificavelmente verde pode avançar para Ready for Review sem aguardar teste humano;
- achados humanos devem ser persistidos como issue, comentário de PR ou task de follow-up;
- somente uma decisão explicitamente declarada pelo usuário como gate pode bloquear avanço;
- gates técnicos automatizados vermelhos continuam bloqueantes;
- merge, produção, custo ou mudança destrutiva permanecem gates quando explicitamente reservados ao usuário.

Consultar `docs/HUMAN-TESTS.md` para o protocolo de evidência e triagem.

### Autorização permanente de merge — Errow

O usuário autorizou o agente a realizar merge automaticamente quando a unidade de trabalho estiver verificavelmente pronta.

Para um PR do Errow, o merge pode ser executado sem nova confirmação quando, no estado real atual:

- o PR está aberto e mergeável;
- não está em Draft;
- o HEAD exato foi resolvido novamente imediatamente antes da decisão;
- todos os testes, builds, checks, workflows e verificações aplicáveis ao HEAD exato concluíram com sucesso;
- não existe falha, job ainda ativo, blocker persistido ou review que exija mudança antes do merge;
- não existe um gate excepcional explicitamente declarado pelo usuário para aquele PR específico.

Quando essas condições forem satisfeitas:

1. faça o merge usando `expected_head_sha` para impedir merge de um HEAD que mudou;
2. reconcilie `master` após o merge;
3. acompanhe os workflows/deploys disparados pelo merge;
4. corrija falhas pós-merge no mesmo fluxo quando possível;
5. só considere o ciclo concluído depois que os gates pós-merge aplicáveis terminarem.

Merge aprovado desta forma não deve manter o workstream em `WATCH` aguardando uma confirmação humana redundante.

## HANDOFF DURÁVEL

Ao atingir uma fronteira natural de sessão, gere um único handoff compacto.

Formato:

```text
CAVEMAN HANDOFF v1

APP:
WORKSTREAM:
STATE:
MODE:
CANONICAL SOURCE:

CURRENT VERSION / HEAD:
BASE:
BRANCH / ENV:
PR / MR / TASK:
SPEC / ADR:

DONE:
VERIFY:
GATES:
BLOCKERS:

INVARIANTS:
NEXT:

VERIFY-FIRST:
<instruções mínimas necessárias para reconstruir o estado real na próxima execução>
```

O handoff deve registrar estado e delta, não narrar toda a sessão.

Ele precisa permitir que outro agente, chat ou app continue o trabalho sem depender do histórico desta conversa.

## NEXT SESSION

Quando uma nova sessão receber:

`Siga`

ela deve procurar primeiro pelo último handoff persistido disponível.

Em seguida deve executar novamente `VERIFY-FIRST`.

O handoff é uma hipótese sobre o último estado conhecido.

O sistema real determina o estado atual.

## COMPORTAMENTO ESPERADO

Exemplo 1:

Usuário: `Siga`

Agente:

- Reconciliou o estado real.
- Encontrou PR existente.
- CI ainda está rodando.
- Não abriu uma nova branch.
- Classificou como `WATCH`.
- Consumiu jobs concluídos.
- Encontrou um gate vermelho.
- Corrigiu a causa.
- Executou novamente as validações.
- Persistiu novo handoff.

Exemplo 2:

Usuário: `Siga`

Agente:

- Reconciliou o estado.
- Último PR está concluído.
- Todos os gates estão verdes.
- Não existem agentes/jobs ativos.
- Roadmap possui próxima task pronta.
- Classificou como `ADVANCE`.
- Criou a próxima unidade de trabalho.
- Implementou.
- Validou.
- Persistiu o novo estado.

## PORTABILIDADE

`Siga` não depende de Git.

Git/PR/CI são apenas possíveis fontes de estado.

Em outros sistemas, substitua pelos equivalentes.

Exemplo:

- Canva: design → comentários → aprovação → export.
- Trello: board → card → checklist → blockers.
- Notion: spec → tasks → decisions → status.
- SaaS: workspace → jobs → state machine → logs.
- Infra: environment → deployment → health → incidents.
- Agentes: run → child agents → tool outputs → pending actions.

A semântica permanece:

`RECONCILE → CLASSIFY → EXECUTE → VERIFY → HANDOFF`

## REGRA FINAL

`Siga` significa:

> “Descubra onde realmente estamos e continue corretamente dali.”

Nunca:

> “Apenas execute alguma próxima coisa.”

## Escopo canônico neste repositório

Para o app Errow, esta skill e o handoff adjacente são a fonte procedural persistida do protocolo SIGA.

Não criar cópias paralelas em memória, Library, outro repositório ou artefato externo.
