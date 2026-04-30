/// @description Algoritmo de crescimento procedural de hexágonos (BFS orgânico)
/// @file        scr_hex_grow.gml
///
/// Gera uma região contígua de `count` hexágonos usando BFS com
/// ordem aleatória da fronteira, produzindo formas orgânicas.

/// @function hex_grow_region(count)
/// @desc  Gera lista de hexágonos contíguos via Random-Frontier BFS
/// @param {real} count  Número de hexágonos desejados (>= 1)
/// @return {array}      Array de arrays [[q, r], ...] com `count` entradas
///
/// IMPORTANTE: chame prng_init(seed) antes de usar esta função.
function hex_grow_region(count) {
    // ds_map: chave = hex_key(q,r) → 1 se visitado
    var visited   = ds_map_create();
    // ds_list: fronteira de hexágonos candidatos a expandir
    var frontier  = ds_list_create();
    // Array de resultado
    var result    = [];

    // Começa no hexágono (0, 0)
    var start_key = hex_key(0, 0);
    ds_map_add(visited, start_key, 1);
    ds_list_add(frontier, 0);   // codifica q
    ds_list_add(frontier, 0);   // codifica r
    array_push(result, [0, 0]);

    // Cresce até atingir count ou esgotar a fronteira
    while (array_length(result) < count && ds_list_size(frontier) > 0) {
        // Escolhe índice aleatório na fronteira (pares q,r)
        var pair_count = ds_list_size(frontier) / 2;
        var pick       = prng_int(pair_count);  // índice do par
        var fi         = pick * 2;              // índice real na lista

        var q = ds_list_find_value(frontier, fi);
        var r = ds_list_find_value(frontier, fi + 1);

        // Embaralha as 6 direções (Fisher-Yates in-place sobre arrays locais)
        var dq = array_create(6);
        var dr = array_create(6);
        for (var d = 0; d < 6; d++) {
            dq[d] = __hex_dirs_q[d];
            dr[d] = __hex_dirs_r[d];
        }
        // Embaralha
        for (var d = 5; d > 0; d--) {
            var j   = prng_int(d + 1);
            var tq  = dq[d]; dq[d] = dq[j]; dq[j] = tq;
            var tr  = dr[d]; dr[d] = dr[j]; dr[j] = tr;
        }

        var expanded = false;
        for (var d = 0; d < 6; d++) {
            var nq  = q + dq[d];
            var nr  = r + dr[d];
            var key = hex_key(nq, nr);

            if (!ds_map_exists(visited, key)) {
                ds_map_add(visited, key, 1);
                ds_list_add(frontier, nq);
                ds_list_add(frontier, nr);
                array_push(result, [nq, nr]);
                expanded = true;
                if (array_length(result) >= count) break;
            }
        }

        // Se não expandiu a partir deste hex, remove da fronteira
        if (!expanded) {
            ds_list_delete(frontier, fi + 1);
            ds_list_delete(frontier, fi);
        }
    }

    // Limpeza de estruturas de dados GameMaker (obrigatório evitar memory leak)
    ds_map_destroy(visited);
    ds_list_destroy(frontier);

    return result;
}
