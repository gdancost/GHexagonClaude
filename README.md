# HexColor — Jogo de Coloração de Hexágonos (GameMaker)

Pinte todos os hexágonos com 4 cores sem que dois vizinhos toquem na mesma cor.

## Estrutura do projeto

```
hexgen_gamemaker/
├── README.md
├── scripts/
│   ├── scr_prng.gml            — PRNG determinístico (seed)
│   ├── scr_hex_utils.gml       — Coordenadas cúbicas + conversão pixel
│   ├── scr_hex_grow.gml        — Algoritmo de crescimento procedural
│   ├── scr_hex_map.gml         — Geração e armazenamento do mapa
│   └── scr_brush.gml           — Pincel: paleta, pintura e validação
├── objects/
│   ├── obj_hex_manager.gml     — Controlador principal + lógica de jogo
│   └── obj_brush_ui.gml        — Interface visual do pincel (paleta)
└── rooms/
    └── room_hexmap.gml         — Room de exemplo (640x480)
```

## Como usar

1. Crie os scripts no GameMaker com o conteúdo de cada `.gml`.
2. Coloque **obj_hex_manager** e **obj_brush_ui** na room `room_hexmap`.
   - `obj_brush_ui`: depth menor (ex: `-10`) para ficar na frente.
3. Ajuste em `obj_hex_manager` > evento **Create**:
   - `hex_count` — quantidade de hexágonos (recomendado: 10–40)
   - `hex_seed`  — semente (mesma seed = mesmo mapa)
   - `hex_flat`  — `true` = flat-top, `false` = pointy-top
4. Adicione `Draw GUI` em `obj_brush_ui` (além do Draw normal).

## Controles

| Tecla          | Ação                                  |
|----------------|---------------------------------------|
| **1 / 2 / 3 / 4** | Seleciona a cor do pincel          |
| **Click esq.** | Pinta o hexágono sob o cursor         |
| **R**          | Novo mapa (seed aleatória)            |
| **+ / −**      | Aumenta / diminui quantidade de hexs  |
| **Enter/Espaço** | Reinicia após vitória ou derrota    |

## Lógica do jogo

- **Derrota**: ao pintar um hexágono, se algum vizinho direto tiver a mesma cor, o jogo termina imediatamente.
- **Vitória**: todos os hexágonos pintados sem nenhum par de vizinhos com cor igual.
- Hexágonos em conflito **piscam em vermelho** para feedback visual.

## Ordem de criação dos scripts no GameMaker

```
1. scr_prng.gml          (sem dependências)
2. scr_hex_utils.gml     (sem dependências)
3. scr_hex_grow.gml      (usa scr_prng + scr_hex_utils)
4. scr_hex_map.gml       (usa todos acima)
5. scr_brush.gml         (usa scr_hex_utils + scr_hex_map)
```

## Conceitos técnicos

- **Coordenadas cúbicas (q, r, s)**: padrão da indústria — vizinhança e distância em O(1).
- **BFS orgânico**: crescimento pela fronteira com ordem embaralhada, produz formas orgânicas contíguas.
- **PRNG Mulberry32**: seed determinística — mesma seed = mesmo mapa.
- **ds_map de lookup**: permite encontrar o índice de qualquer hexágono por coordenada em O(1).
