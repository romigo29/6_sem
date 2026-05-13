# binary_codec.py
# Преобразование текста в битовую последовательность и обратно.

from config import HEADER_BITS


def text_to_bits(message: str) -> list[int]:
    """
    Кодирует сообщение в UTF-8 и добавляет 32-битный заголовок длины.
    Формат: [32 бита длины в байтах] + [биты UTF-8 сообщения].
    """
    data = message.encode("utf-8")
    length = len(data)

    if length >= 2 ** HEADER_BITS:
        raise ValueError("Сообщение слишком длинное для 32-битного заголовка длины.")

    header = f"{length:032b}"
    payload = "".join(f"{byte:08b}" for byte in data)
    return [int(bit) for bit in header + payload]


def bits_to_text(bits: list[int]) -> str:
    """
    Восстанавливает сообщение из битовой последовательности с 32-битным заголовком.
    Лишние биты после сообщения игнорируются.
    """
    if len(bits) < HEADER_BITS:
        raise ValueError("Недостаточно бит для чтения заголовка длины.")

    header_bits = bits[:HEADER_BITS]
    length = int("".join(map(str, header_bits)), 2)
    payload_size = length * 8

    if len(bits) < HEADER_BITS + payload_size:
        raise ValueError("Контейнер не содержит полного скрытого сообщения.")

    payload = bits[HEADER_BITS:HEADER_BITS + payload_size]
    bytes_data = bytearray()

    for i in range(0, payload_size, 8):
        byte_bits = payload[i:i + 8]
        bytes_data.append(int("".join(map(str, byte_bits)), 2))

    return bytes(bytes_data).decode("utf-8")
