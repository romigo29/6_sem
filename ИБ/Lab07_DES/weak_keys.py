# Слабые ключи DES: при шифровании дважды получаем исходный текст
WEAK_KEYS = [
    bytes.fromhex('0101010101010101'),
    bytes.fromhex('FEFEFEFEFEFEFEFE'),
    bytes.fromhex('E0E0E0E0F1F1F1F1'),
    bytes.fromhex('1F1F1F1F0E0E0E0E'),
]

# Полуслабые ключи DES: пара ключей, которые «отменяют» друг друга
SEMI_WEAK_KEYS = [
    (bytes.fromhex('011F011F010E010E'), bytes.fromhex('1F011F010E010E01')),
    (bytes.fromhex('01E001E001F101F1'), bytes.fromhex('E001E001F101F101')),
]
