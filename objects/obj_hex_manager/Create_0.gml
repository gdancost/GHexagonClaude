/// @description obj_hex_manager — Controlador principal (com pincel + lógica de jogo)
/// @file        obj_hex_manager.gml  [VERSÃO ATUALIZADA]
///
/// Coloque UMA instância na room_hexmap.
/// Requer obj_brush_ui também na room.
///
/// ════════════════════════════════════════════════════════════
///  EVENTO: Create
/// ════════════════════════════════════════════════════════════

// ── Parâmetros do mapa ───────────────────────────────────────
hex_count    = 10;     // quantidade de hexágonos (recomendado 10-40 para jogabilidade)
hex_seed     = 42;   //semente (mesma seed = mesmo mapa)
hex_flat     = true; //true = flat-top, false = pointy-top
hex_margin   = 0.06;

// ── Estado de jogo ───────────────────────────────────────────
game_state       = GAME_PLAYING;   // GAME_PLAYING | GAME_WIN | GAME_LOSE
hex_paint        = [];             // cor de pintura por hexágono (BRUSH_NONE = vazio)
hex_conflicts    = [];             // índices dos hexágonos em conflito (para highlight)
hex_hover        = -1;             // hex sob o cursor do mouse
hex_anim_timer   = 0;             // timer para animações de UI (pulsação, etc.)
msg_alpha        = 0.0;           // alpha da mensagem de fim de jogo
painted_count    = 0;             // quantidade de hexágonos pintados

// ── Lookup de vizinhança (reconstruído ao gerar) ─────────────
hex_lookup = ds_map_create();


/// @function hex_map_init()   [método local — chame ao (re)gerar]
function hex_map_init() {
    if (ds_map_size(hex_lookup) > 0) ds_map_clear(hex_lookup);

    // Reserva espaço para a paleta na parte inferior
    var usable_h = room_height - 80;
    hex_map_generate(hex_count, hex_seed, hex_flat, room_width, usable_h, hex_margin);

    // Reconstrói lookup q,r → índice
    ds_map_destroy(hex_lookup);
    hex_lookup = brush_build_lookup();

    // Reseta pintura
    hex_paint     = array_create(hex_map_count, BRUSH_NONE);
    hex_conflicts = [];
    hex_hover     = -1;
    game_state    = GAME_PLAYING;
    msg_alpha     = 0.0;
    painted_count = 0;
}

// Gera mapa inicial e inicializa estruturas
hex_map_init();
