/// @description Coordenadas cúbicas de hexágonos + conversão pixel
/// @file        scr_hex_utils.gml
///
/// Sistema de coordenadas cúbicas (q, r, s) onde q + r + s = 0.
/// Referência: https://www.redblobgames.com/grids/hexagons/
///
/// Convenções:
///   flat   = hexágono com face plana no topo (vértices nas laterais)
///   pointy = hexágono com vértice no topo (faces nas laterais)

// ─── Direções de vizinhança em coordenadas cúbicas ───────────────────────────
// Cada entrada é [dq, dr, ds]. Sempre 6 vizinhos.
#macro HEX_DIR_COUNT 6
globalvar __hex_dirs_q, __hex_dirs_r, __hex_dirs_s;
__hex_dirs_q = [ 1,  1,  0, -1, -1,  0];
__hex_dirs_r = [-1,  0,  1,  1,  0, -1];
__hex_dirs_s = [ 0, -1, -1,  0,  1,  1];

// ─── Chave de mapa ────────────────────────────────────────────────────────────

/// @function hex_key(q, r)
/// @desc Gera uma string-chave única para (q, r) — usada em ds_map
/// @param {real} q
/// @param {real} r
/// @return {string}
function hex_key(q, r) {
    return string(q) + "," + string(r);
}

// ─── Conversão cubo → pixel ───────────────────────────────────────────────────

/// @function hex_to_pixel_flat(q, r, size)
/// @desc Converte coordenadas cúbicas para pixel (flat-top)
/// @param {real} q     Coordenada q
/// @param {real} r     Coordenada r
/// @param {real} size  Raio do hexágono em pixels
/// @return {array}     [x, y]
function hex_to_pixel_flat(q, r, size) {
    var px = size * (3.0 / 2.0 * q);
    var py = size * (sqrt(3) / 2.0 * q + sqrt(3) * r);
    return [px, py];
}

/// @function hex_to_pixel_pointy(q, r, size)
/// @desc Converte coordenadas cúbicas para pixel (pointy-top)
/// @param {real} q     Coordenada q
/// @param {real} r     Coordenada r
/// @param {real} size  Raio do hexágono em pixels
/// @return {array}     [x, y]
function hex_to_pixel_pointy(q, r, size) {
    var px = size * (sqrt(3) * q + sqrt(3) / 2.0 * r);
    var py = size * (3.0 / 2.0 * r);
    return [px, py];
}

// ─── Vértices de um hexágono ──────────────────────────────────────────────────

/// @function hex_corners(cx, cy, size, flat)
/// @desc Retorna os 6 vértices do hexágono centrado em (cx, cy)
/// @param {real} cx    Centro X
/// @param {real} cy    Centro Y
/// @param {real} size  Raio (centro até vértice)
/// @param {bool} flat  true = flat-top, false = pointy-top
/// @return {array}     Array de 12 valores [x0,y0, x1,y1, ..., x5,y5]
function hex_corners(cx, cy, size, flat) {
    var pts = array_create(12);
    var angle_offset = flat ? 0 : 30;
    for (var i = 0; i < 6; i++) {
        var angle_deg = 60 * i + angle_offset;
        var angle_rad = degtorad(angle_deg);
        pts[i * 2]     = cx + size * cos(angle_rad);
        pts[i * 2 + 1] = cy + size * sin(angle_rad);
    }
    return pts;
}

// ─── Distância entre dois hexágonos ──────────────────────────────────────────

/// @function hex_distance(q1, r1, q2, r2)
/// @desc Distância em passos entre dois hexágonos
/// @return {real}
function hex_distance(q1, r1, q2, r2) {
    var s1 = -q1 - r1;
    var s2 = -q2 - r2;
    return max(abs(q1 - q2), abs(r1 - r2), abs(s1 - s2));
}

// ─── Cálculo de size automático ───────────────────────────────────────────────

/// @function hex_calc_size(hex_list, room_w, room_h, flat, margin)
/// @desc Calcula o tamanho ideal do hexágono para que todos caibam na room
/// @param {array}  hex_list  Array de arrays [[q,r], [q,r], ...]
/// @param {real}   room_w    Largura da room em pixels
/// @param {real}   room_h    Altura da room em pixels
/// @param {bool}   flat      Orientação
/// @param {real}   margin    Margem proporcional (ex: 0.05 = 5%)
/// @return {real}  Tamanho do hexágono em pixels
function hex_calc_size(hex_list, room_w, room_h, flat, margin) {
    var count = array_length(hex_list);
    if (count == 0) return 16;

    // Calcula bounding box com size = 1
    var min_x =  999999, max_x = -999999;
    var min_y =  999999, max_y = -999999;

    for (var i = 0; i < count; i++) {
        var q = hex_list[i][0];
        var r = hex_list[i][1];
        var pos = flat ? hex_to_pixel_flat(q, r, 1) : hex_to_pixel_pointy(q, r, 1);
        min_x = min(min_x, pos[0]);
        max_x = max(max_x, pos[0]);
        min_y = min(min_y, pos[1]);
        max_y = max(max_y, pos[1]);
    }

    var span_x = max_x - min_x;
    var span_y = max_y - min_y;

    // Unidade de borda do hex (para padding de 1 hex nas bordas)
    var unit_w = flat ? 2.0 : sqrt(3);
    var unit_h = flat ? sqrt(3) : 2.0;

    var avail_w = room_w * (1.0 - 2.0 * margin);
    var avail_h = room_h * (1.0 - 2.0 * margin);

    var size_by_x = (span_x > 0) ? avail_w / (span_x + unit_w) : avail_w / unit_w;
    var size_by_y = (span_y > 0) ? avail_h / (span_y + unit_h) : avail_h / unit_h;

    return floor(min(size_by_x, size_by_y) * 0.92);
}
