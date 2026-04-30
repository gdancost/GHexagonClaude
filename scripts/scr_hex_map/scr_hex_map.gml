/// @description Geração completa do mapa hexagonal com metadados por célula
/// @file        scr_hex_map.gml
///
/// Gera o mapa, calcula posições pixel e atribui tipos de terreno.
/// Armazena tudo em arrays acessíveis globalmente.

// ─── Tipos de terreno padrão ──────────────────────────────────────────────────
// Cada tipo: [nome, cor_r, cor_g, cor_b, peso_relativo]
// Os pesos não precisam somar 1; serão normalizados internamente.

globalvar HEX_TERRAIN_TYPES;
HEX_TERRAIN_TYPES = [
    ["Agua",     0x1A, 0x4A, 0x7A, 15],
    ["Planicie", 0x3A, 0x6E, 0x2A, 30],
    ["Floresta", 0x1E, 0x4A, 0x18, 25],
    ["Montanha", 0x6A, 0x5A, 0x4A, 15],
    ["Deserto",  0x9A, 0x80, 0x40, 10],
    ["Neve",     0xD0, 0xE0, 0xE8,  5],
];

/// @function hex_pick_terrain()
/// @desc  Seleciona um tipo de terreno aleatoriamente por peso
/// @return {real}  Índice em HEX_TERRAIN_TYPES
function hex_pick_terrain() {
    // Soma total dos pesos
    var total = 0;
    var n = array_length(HEX_TERRAIN_TYPES);
    for (var i = 0; i < n; i++) total += HEX_TERRAIN_TYPES[i][4];

    var roll = prng_next() * total;
    var acc  = 0;
    for (var i = 0; i < n; i++) {
        acc += HEX_TERRAIN_TYPES[i][4];
        if (roll < acc) return i;
    }
    return n - 1;
}

// ─── Estrutura do mapa ────────────────────────────────────────────────────────
// Após chamar hex_map_generate(), as variáveis globais abaixo ficam populadas:
//
//   hex_map_count        — número de hexágonos gerados
//   hex_map_size         — raio do hexágono em pixels
//   hex_map_flat         — bool: true = flat-top
//   hex_map_q[]          — coordenada q de cada célula
//   hex_map_r[]          — coordenada r de cada célula
//   hex_map_px[]         — posição pixel X do centro
//   hex_map_py[]         — posição pixel Y do centro
//   hex_map_terrain[]    — índice do tipo de terreno
//   hex_map_corners[][]  — array de 12 floats [x0,y0,...,x5,y5] por célula

globalvar hex_map_count, hex_map_size, hex_map_flat;
globalvar hex_map_q, hex_map_r, hex_map_px, hex_map_py;
globalvar hex_map_terrain, hex_map_corners;

/// @function hex_map_generate(count, seed, flat, room_w, room_h, margin)
/// @desc  Gera o mapa completo e popula as variáveis globais acima
/// @param {real} count   Quantidade de hexágonos
/// @param {real} seed    Semente para PRNG
/// @param {bool} flat    true = flat-top, false = pointy-top
/// @param {real} room_w  Largura da room em pixels (ex: 640)
/// @param {real} room_h  Altura da room em pixels  (ex: 480)
/// @param {real} margin  Margem proporcional (ex: 0.05 = 5%)
function hex_map_generate(count, seed, flat, room_w, room_h, margin) {
    // 1. Inicializa PRNG
    prng_init(seed);

    // 2. Cresce região orgânica
    var hex_list = hex_grow_region(count);
    var n = array_length(hex_list);

    // 3. Calcula tamanho ideal do hexágono
    var size = hex_calc_size(hex_list, room_w, room_h, flat, margin);
    size = max(size, 4); // mínimo de 4px para não sumir

    // 4. Calcula bounding box com size real para centralizar
    var min_x =  999999, max_x = -999999;
    var min_y =  999999, max_y = -999999;
    for (var i = 0; i < n; i++) {
        var q = hex_list[i][0];
        var r = hex_list[i][1];
        var pos = flat ? hex_to_pixel_flat(q, r, size)
                       : hex_to_pixel_pointy(q, r, size);
        min_x = min(min_x, pos[0]); max_x = max(max_x, pos[0]);
        min_y = min(min_y, pos[1]); max_y = max(max_y, pos[1]);
    }
    var offset_x = room_w / 2 - (min_x + max_x) / 2;
    var offset_y = room_h / 2 - (min_y + max_y) / 2;

    // 5. Popula arrays globais
    hex_map_count   = n;
    hex_map_size    = size;
    hex_map_flat    = flat;
    hex_map_q       = array_create(n);
    hex_map_r       = array_create(n);
    hex_map_px      = array_create(n);
    hex_map_py      = array_create(n);
    hex_map_terrain = array_create(n);
    hex_map_corners = array_create(n);

    for (var i = 0; i < n; i++) {
        var q = hex_list[i][0];
        var r = hex_list[i][1];
        var pos = flat ? hex_to_pixel_flat(q, r, size)
                       : hex_to_pixel_pointy(q, r, size);
        var cx = pos[0] + offset_x;
        var cy = pos[1] + offset_y;

        hex_map_q[i]       = q;
        hex_map_r[i]       = r;
        hex_map_px[i]      = cx;
        hex_map_py[i]      = cy;
        hex_map_terrain[i] = hex_pick_terrain();
        // Reduz levemente o raio visual para criar separação (gap) entre hexágonos
        hex_map_corners[i] = hex_corners(cx, cy, size * 0.95, flat);
    }

    show_debug_message(
        "HexGen: gerados " + string(n) + " hexágonos | size=" + string(size) +
        "px | seed=" + string(seed)
    );
}

/// @function hex_map_get_at_point(px, py)
/// @desc  Retorna o índice do hexágono mais próximo de um ponto (px, py).
///        Útil para detecção de clique / cursor. Retorna -1 se nenhum encontrar.
/// @param {real} px  X do ponto (ex: mouse_x)
/// @param {real} py  Y do ponto (ex: mouse_y)
/// @return {real}    Índice em hex_map_* ou -1
function hex_map_get_at_point(px, py) {
    var best_i    = -1;
    var best_dist = hex_map_size * hex_map_size; // threshold = raio²
    for (var i = 0; i < hex_map_count; i++) {
        var dx = px - hex_map_px[i];
        var dy = py - hex_map_py[i];
        var d2 = dx * dx + dy * dy;
        if (d2 < best_dist) {
            best_dist = d2;
            best_i    = i;
        }
    }
    return best_i;
}
