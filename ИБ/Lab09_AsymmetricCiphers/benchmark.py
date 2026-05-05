# benchmark.py
import time
from typing import Dict, List

from crypto_utils import generate_keys, encrypt_blocks, decrypt_blocks
from encoding_utils import text_to_blocks, required_block_size, fit_blocks_to_length

def measure_encrypt_decrypt(message: str, mode: str, z: int, repeats: int = 200) -> Dict[str, float]:
    base_size = required_block_size(mode)
    if z < base_size:
        raise ValueError(f"Для режима {mode} число z должно быть не меньше {base_size}.")

    keys = generate_keys(z)
    blocks = text_to_blocks(message, mode)
    fitted_blocks = fit_blocks_to_length(blocks, z)

    start_enc = time.perf_counter()
    for _ in range(repeats):
        cipher = encrypt_blocks(fitted_blocks, keys["open_key"])
    end_enc = time.perf_counter()

    start_dec = time.perf_counter()
    for _ in range(repeats):
        decrypt_blocks(cipher, keys["secret_key"], keys["n"], keys["a"])
    end_dec = time.perf_counter()

    return {
        "encrypt_ms": (end_enc - start_enc) * 1000 / repeats,
        "decrypt_ms": (end_dec - start_dec) * 1000 / repeats,
    }

def run_scaling_analysis(message: str, mode: str, z_values: List[int], repeats: int = 200) -> List[Dict[str, float]]:
    results = []
    for z in z_values:
        timings = measure_encrypt_decrypt(message, mode, z, repeats)
        timings["z"] = z
        timings["mode"] = mode
        results.append(timings)
    return results