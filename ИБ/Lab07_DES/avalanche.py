from des_ede2 import ede2_encrypt_steps


def bit_diff(a: bytes, b: bytes) -> int:
    """Количество различающихся битов."""
    return sum(bin(x ^ y).count('1') for x, y in zip(a, b))


def _safe_char(b):
    if 32 <= b < 127:
        return chr(b)
    return f"\\x{b:02x}"


def _safe_str(data: bytes):
    return "".join(_safe_char(b) for b in data)


def avalanche_ede2_steps(word: bytes, key1: bytes, key2: bytes):
    """
    Пошаговый анализ лавинного эффекта через 3 шага EDE2.
    Меняем 1 бит в последнем символе блока, затем сравниваем
    промежуточные результаты каждого шага (E→D→E) по битам.
    Возвращает список строк для вывода.
    """
    block = word[:8].ljust(8, b'\x00')

    # Меняем последний символ на 1 бит
    modified = bytearray(block)
    modified[-1] ^= 1
    modified = bytes(modified)

    orig_steps = ede2_encrypt_steps(block, key1, key2)
    mod_steps = ede2_encrypt_steps(modified, key1, key2)

    total_bits = 64  # 8 байт * 8 бит

    lines = []
    lines.append(f"Исходная строка: {_safe_str(block)}")
    lines.append(f"Исходная строка с измененным битом: {_safe_str(modified)}")
    lines.append("")

    for i in range(3):
        changed_bits = bit_diff(orig_steps[i], mod_steps[i])
        pct = changed_bits / total_bits * 100
        lines.append(f"step{i+1}: {pct}%")

    return lines
