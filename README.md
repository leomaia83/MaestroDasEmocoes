# O Maestro das Emoções

**Vamos cuidar das emoções brincando.**

Jogo educativo em **Godot 4** para ajudar crianças neurodivergentes a reconhecer, nomear e regular as próprias emoções. A criança conta como está se sentindo, escolhe o motivo e o jogo a leva a um minijogo pensado para aquela emoção. Ele pode ser jogado com mouse ou com um **controle físico adaptado (ESP32 + joystick analógico)**, criado para crianças com dificuldades motoras finas.

<p align="center">
  <img src="assets%20quest%203/capa.jpeg" alt="Tela inicial do Maestro das Emoções" width="260">
</p>

## Como funciona

1. **Check-in emocional:** a criança escolhe como se sente: Feliz, Triste, Bravo, Assustado, Cansado ou Orgulhoso.
2. **Causa do humor:** indica o motivo (casa, escola, amigos…).
3. **Minijogo direcionado:** o jogo escolhe uma atividade de acordo com a emoção:

| Emoção | Minijogo | Objetivo |
|---|---|---|
| Bravo | **Botão da Calma** | Respiração guiada (inspirar 4s, segurar 2s, soltar 4s) segurando a nuvem |
| Assustado | **Ritmo do Maestro** | Repetir sequências de notas coloridas, estilo "Genius", em 3 rodadas |
| Triste | **Ajudas** | Associar situações difíceis a pessoas que podem ajudar |
| Cansado / Entediado | **Rotina** | Arrastar as etapas do dia para a ordem correta |
| Feliz | **Memória dos Sentimentos** | Jogo da memória com 6 pares de cartas embaralhadas |
| Orgulhoso | **Termômetro do Orgulho** | Medir o quanto se sente orgulhoso em situações do dia a dia |

4. **Feedback positivo:** uma tela de celebração ao fim de cada atividade.

## Registro para acompanhamento terapêutico

Cada check-in é salvo com data, hora, emoção e motivo em um histórico local (`historico_emocional_terapeuta.txt`, na pasta de dados do usuário do Godot). Assim, pais e terapeutas podem acompanhar a evolução emocional da criança ao longo do tempo.

```
[20/05/2026 às 21:21] Emoção: Bravo | Motivo: Escola
```

## Controle físico adaptado (ESP32)

Além do mouse, o jogo aceita um controle feito com **ESP32 + joystick analógico + botão**, conectado pela porta serial (USB):

- O ESP32 envia leituras no formato `x,y,botão` a 115200 baud.
- O jogo **calibra o centro do joystick automaticamente** na primeira leitura e aplica uma zona morta para evitar movimentos involuntários.
- Um **cursor virtual** se move pela tela com o analógico, e o botão físico funciona como clique, inclusive nos minijogos de segurar e arrastar.
- Se o cursor sair da área útil, o sistema escolhe o botão principal da tela, para que a criança nunca fique travada.

A leitura serial roda em uma **thread separada**, para não travar a interface.

## Tecnologias

- **Godot 4.6** e **GDScript**
- **ESP32** (controle físico via comunicação serial)
- Arquitetura com *autoloads* (singletons): `Global` (fluxo e histórico), `ControleSerial` (hardware) e `CursorVirtual` (cursor)
- Interface vertical (1080×1920) pensada para telas touch e tablets

## Como executar

1. Instale o [Godot 4.6](https://godotengine.org/download) ou superior.
2. Clone o repositório:
   ```bash
   git clone https://github.com/leomaia83/MaestroDasEmocoes.git
   ```
3. No Godot, clique em **Importar**, selecione o arquivo `project.godot` e execute com **F5**.

**Usando o controle ESP32 (opcional):** conecte o ESP32 por USB e confira a porta em `ControleSerial.gd` (padrão: `COM3`). A leitura serial está implementada para **Windows**. Sem o controle, o jogo funciona normalmente com o mouse.

## Estrutura

```
├── project.godot
├── Global.gd                 # Fluxo entre telas e histórico emocional
├── ControleSerial.gd         # Leitura do ESP32 em thread separada
├── CursorVirtual.gd          # Cursor controlado pelo joystick
├── menu_principal.*          # Tela inicial
├── check_in_emocional.*      # Escolha da emoção
├── causas_humor.*            # Escolha do motivo
├── botao_calma.*             # Minijogo: respiração
├── ritmo.*                   # Minijogo: sequência musical
├── ajudas.*                  # Minijogo: rede de apoio
├── rotina.*                  # Minijogo: ordenar a rotina
├── memoria.*                 # Minijogo: jogo da memória
├── termometro.*              # Minijogo: termômetro do orgulho
├── tela_feedback.*           # Tela de celebração
└── assets quest 3/           # Imagens e ícones
```

## Próximos passos

- Tela de configurações (volume, porta serial, dificuldade)
- Visualização do histórico emocional dentro do próprio jogo para o terapeuta
- Suporte à leitura serial em Linux e macOS
- Versão para Android/tablets

## Autor

**Leonardo Maia** · [LinkedIn](https://www.linkedin.com/in/leonardo-maia-menezes/) · [GitHub](https://github.com/leomaia83)

Projeto desenvolvido no curso de Ciência da Computação da Universidade de Fortaleza (Unifor).
