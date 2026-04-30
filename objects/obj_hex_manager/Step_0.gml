/// ════════════════════════════════════════════════════════════
///  EVENTO: Step
/// ════════════════════════════════════════════════════════════

hex_anim_timer++;

// ── Hover do mouse ───────────────────────────────────────────
hex_hover = hex_map_get_at_point(mouse_x, mouse_y);

// ── Clique para pintar ───────────────────────────────────────
if (mouse_check_button_pressed(mb_left) && game_state == GAME_PLAYING) {
    var palette_y = room_height - 80;
    if (mouse_y < palette_y && hex_hover >= 0) {
        var brush_obj = instance_find(obj_brush_ui, 0);
        if (instance_exists(brush_obj)) {
            var colour_idx = brush_obj.brush_colour_idx;

            game_state = brush_paint(hex_hover, colour_idx, hex_paint, hex_lookup);

            painted_count = 0;
            for (var i = 0; i < hex_map_count; i++) {
                if (hex_paint[i] != BRUSH_NONE) painted_count++;
            }

            hex_conflicts = brush_check_all_conflicts(hex_paint, hex_lookup);

            if (game_state != GAME_PLAYING) msg_alpha = 0.0;
        }
    }
}

// ── Anima alpha da mensagem de fim de jogo ───────────────────
if (game_state != GAME_PLAYING) {
    msg_alpha = min(1.0, msg_alpha + 0.03);
}

// ── Tecla R — novo mapa ──────────────────────────────────────
if (keyboard_check_pressed(ord("R"))) {
    hex_seed = irandom(9999) + 1;
    hex_map_init();
}

// ── Enter / Espaço — reinicia ao fim de jogo ─────────────────
if (game_state != GAME_PLAYING) {
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
        hex_seed = irandom(9999) + 1;
        hex_map_init();
    }
}

// ── Atalhos de quantidade ────────────────────────────────────
if (game_state == GAME_PLAYING) {
    if (keyboard_check_pressed(vk_add)) {
        hex_count = min(hex_count + 2, 60);
        hex_map_init();
    }
    if (keyboard_check_pressed(vk_subtract)) {
        hex_count = max(hex_count - 2, 5);
        hex_map_init();
    }
}
