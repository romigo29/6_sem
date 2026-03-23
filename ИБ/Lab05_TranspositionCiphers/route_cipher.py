# route_cipher.py
import math


def encrypt(text, rows, cols):

    table = [['' for _ in range(cols)] for _ in range(rows)]
    for i, char in enumerate(text):
        r = i % rows
        c = i // rows
        if r < rows and c < cols:
            table[r][c] = char
    encrypted = ''.join(''.join(row) for row in table)
    return encrypted


def decrypt(text, rows, cols):

    total = len(text)
    # Сколько полных столбцов и сколько строк в неполном последнем столбце
    full_cols = total // rows        # количество столбцов, полностью заполненных
    extra_rows = total % rows        # количество строк в последнем (неполном) столбце

    # Длина каждой строки при чтении зашифрованного текста:
    # Строки 0..extra_rows-1 имеют full_cols+1 символов (у них есть символ в последнем столбце)
    # Строки extra_rows..rows-1 имеют full_cols символов
    table = [['' for _ in range(cols)] for _ in range(rows)]
    idx = 0
    for r in range(rows):
        row_len = full_cols + (1 if r < extra_rows else 0)
        for c in range(row_len):
            if idx < total:
                table[r][c] = text[idx]
                idx += 1

    # Читаем по столбцам (сверху вниз, слева направо) — обратная операция encrypt
    decrypted = ''
    for c in range(cols):
        for r in range(rows):
            if table[r][c] != '':
                decrypted += table[r][c]
    return decrypted