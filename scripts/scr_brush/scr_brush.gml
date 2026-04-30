/// @description Sistema de pincel, cores e lógica de vitória/derrota
/// @file        scr_brush.gml
///
/// Gerencia as 4 cores do pincel, a pintura dos hexágonos,
/// a validação de contiguidade e as condições de fim de jogo.

// ─── Paleta de 4 cores do pincel ─────────────────────────────────────────────
// Cada entrada: [nome, r, g, b, gamemaker_colour]
// As cores foram escolhidas para serem bem distinguíveis entre si.
globalvar BRUSH_PALETTE;
BRUSH_PALETTE = [
    ["Vermelho", 220,  60,  60,  make_colour_rgb(220,  60,  60)],
    ["Azul",      50, 130, 220,  make_colour_rgb( 50, 130, 220)],
    ["Verde",     60, 190,  90,  make_colour_rgb( 60, 190,  90)],
    ["Amarelo",  230, 200,  40,  make_colour_rgb(230, 200,  40)],
];
#macro BRUSH_NONE  -1   // hex ainda não pintado
#macro BRUSH_COUNT  4   // total de cores disponíveis

// Estados de jogo
#macro GAME_PLAYING  0
#macro GAME_WIN      1
#macro GAME_LOSE     2

// ─── Lookup de vizinhança ─────────────────────────────────────────────────────

/// @function brush_build_lookup()
/// @desc  Constrói ds_map de hex_key(q,r) → índice no array global.
///        DEVE ser chamado após hex_map_generate().
///        Retorna o ds_map (responsabilidade do chamador destruí-lo).
/// @return {Id.DsMap}
function brush_build_lookup() {
    var lookup = ds_map_create();
    for (var i = 0; i < hex_map_count; i++) {
        ds_map_set(lookup, hex_key(hex_map_q[i], hex_map_r[i]), i);
    }
    return lookup;
}

// ─── Pintura ──────────────────────────────────────────────────────────────────

/// @function brush_paint(hex_idx, colour_idx, paint_array, lookup)
/// @desc  Pinta o hexágono `hex_idx` com a cor `colour_idx`.
///        Atualiza paint_array[hex_idx] diretamente.
/// @param {real}      hex_idx      Índice do hexágono
/// @param {real}      colour_idx   Índice em BRUSH_PALETTE (0-3)
/// @param {array}     paint_array  Array de cores por hexágono (BRUSH_NONE = não pintado)
/// @param {Id.DsMap}  lookup       Mapa q,r → índice (de brush_build_lookup)
/// @return {real}  Estado do jogo: GAME_PLAYING, GAME_WIN ou GAME_LOSE
function brush_paint(hex_idx, colour_idx, paint_array, lookup) {
    paint_array[hex_idx] = colour_idx;

    // Verifica conflito de cor nos vizinhos imediatos
    var q = hex_map_q[hex_idx];
    var r = hex_map_r[hex_idx];

    for (var d = 0; d < 6; d++) {
        var nq  = q + __hex_dirs_q[d];
        var nr  = r + __hex_dirs_r[d];
        var key = hex_key(nq, nr);
        if (ds_map_exists(lookup, key)) {
            var ni = ds_map_find_value(lookup, key);
            if (paint_array[ni] == colour_idx) {
                return GAME_LOSE; // dois vizinhos com a mesma cor
            }
        }
    }

    // Verifica vitória: todos pintados e nenhum conflito
    for (var i = 0; i < hex_map_count; i++) {
        if (paint_array[i] == BRUSH_NONE) return GAME_PLAYING; // ainda faltam hexágonos
    }
    return GAME_WIN;
}

/// @function brush_check_all_conflicts(paint_array, lookup)
/// @desc  Varre todo o mapa em busca de vizinhos com mesma cor.
///        Retorna array com índices de hexágonos em conflito.
/// @param {array}    paint_array
/// @param {Id.DsMap} lookup
/// @return {array}   Índices dos hexágonos conflitantes
function brush_check_all_conflicts(paint_array, lookup) {
    var conflicts = [];
    var n = hex_map_count;
    for (var i = 0; i < n; i++) {
        if (paint_array[i] == BRUSH_NONE) continue;
        var q = hex_map_q[i];
        var r = hex_map_r[i];
        for (var d = 0; d < 6; d++) {
            var nq  = q + __hex_dirs_q[d];
            var nr  = r + __hex_dirs_r[d];
            var key = hex_key(nq, nr);
            if (ds_map_exists(lookup, key)) {
                var ni = ds_map_find_value(lookup, key);
                if (paint_array[ni] == paint_array[i]) {
                    array_push(conflicts, i);
                    break; // basta um vizinho conflitante para marcar este
                }
            }
        }
    }
    return conflicts;
}

// ─── Reset ────────────────────────────────────────────────────────────────────

/// @function brush_reset_paint(paint_array)
/// @desc  Reseta todas as células para BRUSH_NONE
function brush_reset_paint(paint_array) {
    for (var i = 0; i < array_length(paint_array); i++) {
        paint_array[i] = BRUSH_NONE;
    }
}
