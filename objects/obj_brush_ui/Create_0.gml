/// @description obj_brush_ui — Interface visual do pincel (paleta de cores)
/// @file        obj_brush_ui.gml
///
/// Desenha a paleta na parte inferior da tela.
/// Comunica a cor selecionada via variável de instância `brush_colour_idx`.
/// O obj_hex_manager lê `brush_colour_idx` de obj_brush_ui para pintar.
///
/// Coloque UMA instância na room, em qualquer posição.
/// Depth: menor que obj_hex_manager (ex: -10) para ficar na frente.

// ══════════════════════════════════════════════════
//  EVENTO: Create
// ══════════════════════════════════════════════════
brush_colour_idx = 0;      // cor selecionada (0-3)
brush_hover_idx  = -1;     // cor sob o mouse (-1 = nenhuma)

// Layout da paleta
brush_pad        = 12;     // padding interno do painel
brush_swatch_sz  = 36;     // tamanho de cada quadrado de cor
brush_swatch_gap = 10;     // espaço entre swatches
brush_panel_h    = brush_swatch_sz + brush_pad * 2 + 20; // altura total do painel
brush_panel_y    = room_height - brush_panel_h;           // Y do painel

// Calcula X de início para centralizar os 4 swatches
var total_w = BRUSH_COUNT * brush_swatch_sz + (BRUSH_COUNT - 1) * brush_swatch_gap;
brush_start_x = room_width / 2 - total_w / 2;
