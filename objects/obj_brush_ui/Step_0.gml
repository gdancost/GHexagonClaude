// ══════════════════════════════════════════════════
//  EVENTO: Step
// ══════════════════════════════════════════════════

brush_hover_idx = -1;

// Detecta hover e clique sobre os swatches
for (var i = 0; i < BRUSH_COUNT; i++) {
    var sx = brush_start_x + i * (brush_swatch_sz + brush_swatch_gap);
    var sy = brush_panel_y + brush_pad + 20;

    if (mouse_x >= sx && mouse_x <= sx + brush_swatch_sz &&
        mouse_y >= sy && mouse_y <= sy + brush_swatch_sz) {
        brush_hover_idx = i;
        if (mouse_check_button_pressed(mb_left)) {
            brush_colour_idx = i;
        }
    }
}

// Atalhos de teclado: 1, 2, 3, 4
for (var i = 0; i < BRUSH_COUNT; i++) {
    if (keyboard_check_pressed(ord(string(i + 1)))) {
        brush_colour_idx = i;
    }
}
