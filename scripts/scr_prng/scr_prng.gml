/// @description PRNG determinístico (Mulberry32) — seed controlada
/// @file        scr_prng.gml
///
/// Uso:
///   prng_init(42);          // inicializa com semente
///   var r = prng_next();    // retorna float [0, 1)
///   var n = prng_int(10);   // retorna int [0, 9]
///   var n = prng_range(5, 15); // retorna int [5, 15]

// Estado global da PRNG
globalvar __prng_state;
__prng_state = 0;

/// @function prng_init(seed)
/// @param {real} seed  Semente inteira (> 0)
function prng_init(seed) {
    // Garante que a semente seja inteira positiva de 32 bits
    __prng_state = (seed | 0) & 0xFFFFFFFF;
    if (__prng_state == 0) __prng_state = 1;
}

/// @function prng_next()
/// @return {real}  Número pseudoaleatório em [0, 1)
function prng_next() {
    __prng_state = (__prng_state + 0x6D2B79F5) & 0xFFFFFFFF;
    var t = __prng_state;
    t = (t ^ (t >> 15)) & 0xFFFFFFFF;
    t = (t * (1 | t)) & 0xFFFFFFFF;
    t = (t ^ (t + (t * (t ^ (t >> 7))) * 61)) & 0xFFFFFFFF;
    t = (t ^ (t >> 14)) & 0xFFFFFFFF;
    return t / 4294967296.0;
}

/// @function prng_int(max_exclusive)
/// @param {real} max_exclusive  Inteiro máximo (exclusivo)
/// @return {real}  Inteiro em [0, max_exclusive - 1]
function prng_int(max_exclusive) {
    return floor(prng_next() * max_exclusive);
}

/// @function prng_range(min_val, max_val)
/// @param {real} min_val  Mínimo (inclusivo)
/// @param {real} max_val  Máximo (inclusivo)
/// @return {real}  Inteiro em [min_val, max_val]
function prng_range(min_val, max_val) {
    return min_val + floor(prng_next() * (max_val - min_val + 1));
}
