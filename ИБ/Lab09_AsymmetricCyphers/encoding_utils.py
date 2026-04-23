# encoding_utils.py
import base64

BASE64_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

def text_to_blocks(text: str, mode: str) -> list[str]:
    mode = mode.upper()

    if mode == "ASCII":
        return [format(ord(ch), "08b") for ch in text]

    if mode == "BASE64":
        encoded = base64.b64encode(text.encode("utf-8")).decode("ascii")
        blocks = []
        for ch in encoded:
            if ch == "=":
                continue
            index = BASE64_ALPHABET.index(ch)
            blocks.append(format(index, "06b"))
        return blocks

    raise ValueError("Поддерживаются только режимы ASCII и BASE64.")

def blocks_to_text(blocks: list[str], mode: str) -> str:
    mode = mode.upper()

    if mode == "ASCII":
        chars = [chr(int(bits, 2)) for bits in blocks]
        return "".join(chars)

    if mode == "BASE64":
        chars = []
        for bits in blocks:
            index = int(bits, 2)
            chars.append(BASE64_ALPHABET[index])

        encoded = "".join(chars)
        while len(encoded) % 4 != 0:
            encoded += "="

        raw = base64.b64decode(encoded.encode("ascii"))
        return raw.decode("utf-8")

    raise ValueError("Поддерживаются только режимы ASCII и BASE64.")

def required_block_size(mode: str) -> int:
    mode = mode.upper()

    if mode == "ASCII":
        return 8
    if mode == "BASE64":
        return 6

    raise ValueError("Поддерживаются только режимы ASCII и BASE64.")

def fit_blocks_to_length(blocks: list[str], z: int) -> list[str]:
    fitted = []
    for block in blocks:
        if len(block) > z:
            raise ValueError("Длина блока превышает число элементов последовательности z.")
        fitted.append(block.zfill(z))
    return fitted

def trim_blocks_to_base_size(blocks: list[str], mode: str) -> list[str]:
    base_size = required_block_size(mode)
    return [block[-base_size:] for block in blocks]