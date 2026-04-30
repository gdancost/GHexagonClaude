// ══════════════════════════════════════════════════
//  EVENTO: Draw GUI  (usa coordenadas de GUI, não de room)
//  → No GameMaker: evento Draw → Draw GUI
// ══════════════════════════════════════════════════

// Fundo do painel da paleta
var panel_x = 0;
var panel_y = brush_panel_y;
draw_set_alpha(0.88);
draw_set_colour(make_colour_rgb(12, 15, 20));
draw_rectangle(panel_x, panel_y, room_width, room_height, false);
draw_set_alpha(0.6);
draw_set_colour(make_colour_rgb(40, 60, 80));
draw_rectangle(panel_x, panel_y, room_width, panel_y + 1, false); // linha separadora
draw_set_alpha(1.0);

// Rótulo "PINCEL"
draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(make_colour_rgb(120, 160, 200));
draw_text(brush_start_x, panel_y + brush_pad, "PINCEL  [1-4]");

// Desenha cada swatch
for (var i = 0; i < BRUSH_COUNT; i++) {
    var sx   = brush_start_x + i * (brush_swatch_sz + brush_swatch_gap);
    var sy   = brush_panel_y + brush_pad + 20;
    var pdat = BRUSH_PALETTE[i];
    var col  = pdat[4];

    var is_selected = (i == brush_colour_idx);
    var is_hover    = (i == brush_hover_idx);

    // Sombra / brilho de seleção
    if (is_selected) {
        draw_set_alpha(0.5);
        draw_set_colour(col);
        draw_rectangle(sx - 4, sy - 4, sx + brush_swatch_sz + 4, sy + brush_swatch_sz + 4, false);
    }

    // Quadrado principal
    draw_set_alpha(1.0);
    draw_set_colour(is_hover ? merge_colour(col, c_white, 0.25) : col);
    draw_rectangle(sx, sy, sx + brush_swatch_sz, sy + brush_swatch_sz, false);

    // Borda
    draw_set_colour(is_selected ? c_white : make_colour_rgb(60, 80, 100));
    draw_set_alpha(is_selected ? 1.0 : 0.5);
    draw_rectangle(sx, sy, sx + brush_swatch_sz, sy + brush_swatch_sz, true);

    // Número de atalho
    draw_set_colour(is_selected ? c_white : make_colour_rgb(150, 170, 190));
    draw_set_alpha(0.9);
    draw_set_halign(fa_center);
    draw_text(sx + brush_swatch_sz / 2, sy + brush_swatch_sz + 3, string(i + 1));

    // Nome da cor (só se selecionada)
    if (is_selected) {
        draw_set_colour(c_white);
        draw_set_alpha(1.0);
        draw_text(sx + brush_swatch_sz / 2, sy - 18, pdat[0]);
    }
}

// Cursor personalizado (pequeno círculo colorido ao lado do cursor do mouse)
var cur_col = BRUSH_PALETTE[brush_colour_idx][4];
draw_set_alpha(0.85);
draw_set_colour(cur_col);
draw_circle(mouse_x + 14, mouse_y + 14, 7, false);
draw_set_colour(c_white);
draw_set_alpha(0.9);
draw_circle(mouse_x + 14, mouse_y + 14, 7, true);
draw_set_alpha(1.0);
draw_set_halign(fa_left);




