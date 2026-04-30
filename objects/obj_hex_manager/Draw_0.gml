/// ════════════════════════════════════════════════════════════
///  EVENTO: Draw
/// ════════════════════════════════════════════════════════════

draw_clear(make_colour_rgb(8, 11, 16));

// Fundo com grade de pontos
draw_set_colour(make_colour_rgb(20, 28, 38));
draw_set_alpha(0.5);
for (var gx = 0; gx < room_width; gx += 24) {
    for (var gy = 0; gy < room_height - 80; gy += 24) {
        draw_rectangle(gx, gy, gx + 1, gy + 1, false);
    }
}
draw_set_alpha(1.0);

// ── Desenha hexágonos ────────────────────────────────────────
var pulse = sin(hex_anim_timer * 0.07) * 0.15 + 0.85;

for (var i = 0; i < hex_map_count; i++) {
    var corners    = hex_map_corners[i];
    var cx         = hex_map_px[i];
    var cy         = hex_map_py[i];
    var paint_idx  = hex_paint[i];
    var is_hover   = (i == hex_hover) && (game_state == GAME_PLAYING);

    // Verifica conflito
    var is_conflict = false;
    for (var ci = 0; ci < array_length(hex_conflicts); ci++) {
        if (hex_conflicts[ci] == i) { is_conflict = true; break; }
    }

    // Cor de preenchimento
    var col;
    if (paint_idx == BRUSH_NONE) {
        col = make_colour_rgb(28, 38, 52);
        if (is_hover) col = merge_colour(col, c_white, 0.18);
    } else {
        col = BRUSH_PALETTE[paint_idx][4];
        if (is_hover)    col = merge_colour(col, c_white, 0.25);
        if (is_conflict) {
            var blink = (hex_anim_timer div 8) mod 2;
            if (blink) col = merge_colour(col, make_colour_rgb(255, 30, 30), 0.7);
        }
    }

    if (game_state == GAME_WIN && paint_idx != BRUSH_NONE) {
        col = merge_colour(col, c_white, (pulse - 0.7) * 1.5);
    }

    // Triangle fan (preenchimento)
    draw_set_alpha(1.0);
    draw_primitive_begin(pr_trianglefan);
    draw_vertex_colour(cx, cy, merge_colour(col, c_white, 0.18), 1.0);
    for (var v = 0; v < 6; v++) {
        draw_vertex_colour(corners[v*2], corners[v*2+1], merge_colour(col, c_black, 0.28), 1.0);
    }
    draw_vertex_colour(corners[0], corners[1], merge_colour(col, c_black, 0.28), 1.0);
    draw_primitive_end();

    // Borda
    var border_col;
    if (is_conflict)              border_col = make_colour_rgb(255, 50, 50);
    else if (is_hover)            border_col = c_white;
    else if (paint_idx != BRUSH_NONE) border_col = merge_colour(col, c_white, 0.4);
    else                          border_col = make_colour_rgb(45, 65, 85);

    draw_set_colour(border_col);
    draw_set_alpha(is_hover || is_conflict ? 1.0 : 0.55);
    draw_primitive_begin(pr_linestrip);
    for (var v = 0; v < 6; v++) draw_vertex(corners[v*2], corners[v*2+1]);
    draw_vertex(corners[0], corners[1]);
    draw_primitive_end();

    // Preview da cor ao hover em hex vazio
    if (paint_idx == BRUSH_NONE && is_hover) {
        var brush_obj2 = instance_find(obj_brush_ui, 0);
        if (instance_exists(brush_obj2)) {
            draw_set_colour(BRUSH_PALETTE[brush_obj2.brush_colour_idx][4]);
            draw_set_alpha(0.35);
            draw_circle(cx, cy, hex_map_size * 0.28, false);
        }
    }
}

draw_set_alpha(1.0);
draw_set_colour(c_white);

// ── HUD ──────────────────────────────────────────────────────
draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_set_colour(make_colour_rgb(80, 140, 200));
draw_text(10, 10, "HEXCOLOR");
draw_set_colour(make_colour_rgb(130, 165, 195));
draw_text(10, 26, "Pintados: " + string(painted_count) + "/" + string(hex_map_count));
draw_set_colour(
    array_length(hex_conflicts) > 0
        ? make_colour_rgb(220, 80, 80)
        : make_colour_rgb(80, 160, 100)
);
draw_text(10, 42,
    array_length(hex_conflicts) > 0
        ? "! Conflito detectado !"
        : "OK - Sem conflitos"
);
draw_set_colour(make_colour_rgb(65, 88, 110));
draw_text(10, 62, "[R] Novo mapa   [+/-] Qtd   [1-4] Cor");

// Barra de progresso
var bar_w = 180;
var bar_h = 5;
var bar_x = 10;
var bar_y = room_height - 94;
var prog  = (hex_map_count > 0) ? painted_count / hex_map_count : 0;
draw_set_colour(make_colour_rgb(20, 32, 45));
draw_rectangle(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, false);
draw_set_colour(make_colour_rgb(60, 190, 90));
draw_rectangle(bar_x, bar_y, bar_x + floor(bar_w * prog), bar_y + bar_h, false);
draw_set_colour(make_colour_rgb(40, 62, 82));
draw_rectangle(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, true);

// ── Overlay de fim de jogo ───────────────────────────────────
if (game_state != GAME_PLAYING && msg_alpha > 0) {
    // Escurecimento gradual
    draw_set_alpha(msg_alpha * 0.72);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, room_width, room_height - 80, false);

    var pw = 360;
    var ph = 170;
    var px = room_width  / 2 - pw / 2;
    var py = (room_height - 80) / 2 - ph / 2;

    draw_set_alpha(msg_alpha * 0.96);

    if (game_state == GAME_WIN) {
        // Painel vitória
        draw_set_colour(make_colour_rgb(15, 45, 25));
        draw_rectangle(px, py, px + pw, py + ph, false);
        draw_set_colour(make_colour_rgb(50, 200, 85));
        draw_rectangle(px, py, px + pw, py + ph, true);
        draw_set_alpha(msg_alpha);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_colour(make_colour_rgb(60, 240, 100));
        draw_text(room_width / 2, py + 38,  "VITORIA!");
        draw_set_colour(make_colour_rgb(150, 215, 165));
        draw_text(room_width / 2, py + 72,
            "Todos os " + string(hex_map_count) + " hexagonos\n" +
            "coloridos sem nenhum conflito!");
        draw_set_colour(make_colour_rgb(90, 150, 110));
        draw_text(room_width / 2, py + 132, "[Enter] ou [Espaco] para jogar novamente");
    } else {
        // Painel derrota
        draw_set_colour(make_colour_rgb(45, 12, 12));
        draw_rectangle(px, py, px + pw, py + ph, false);
        draw_set_colour(make_colour_rgb(210, 50, 50));
        draw_rectangle(px, py, px + pw, py + ph, true);
        draw_set_alpha(msg_alpha);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_colour(make_colour_rgb(245, 80, 80));
        draw_text(room_width / 2, py + 38,  "DERROTA!");
        draw_set_colour(make_colour_rgb(215, 155, 155));
        draw_text(room_width / 2, py + 72,
            "Dois hexagonos vizinhos tocaram\n" +
            "na mesma cor!");
        draw_set_colour(make_colour_rgb(155, 95, 95));
        draw_text(room_width / 2, py + 132, "[Enter] ou [Espaco] para tentar novamente");
    }
}

draw_set_alpha(1.0);
draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);





