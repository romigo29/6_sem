ALPHABET = list("aąbcćdeęfghijklłmnńoóprsśtuvwxyzźż")
N = len(ALPHABET)  # 34

char_to_index = {c: i for i, c in enumerate(ALPHABET)}
index_to_char = {i: c for i, c in enumerate(ALPHABET)}

def generate_porta_table():
    half = N // 2  # 17

    first_half = ALPHABET[:half]
    second_half = ALPHABET[half:]

    # Ключевые пары: (a, ą), (b, c), (ć, d), ... — по 2 буквы на строку таблицы
    pairs = []
    for i in range(0, N, 2):
        pairs.append((ALPHABET[i], ALPHABET[i + 1]))

    table = {}
    for idx, pair in enumerate(pairs):
        row = [""] * N

        for i in range(half):
            j = (i + idx) % half
            # first_half[i] -> second_half[j]
            row[i] = second_half[j]
            # обратное: second_half[j] -> first_half[i]
            row[j + half] = first_half[i]

        table[pair] = row

    return table


PORTA_TABLE = generate_porta_table()


def get_row(k):
    """Найти строку таблицы по ключевому символу."""
    for pair, row in PORTA_TABLE.items():
        if k in pair:
            return row
    return None


def encrypt(text, key):
    result = []
    key = key.lower()
    j = 0

    for ch in text:
        lower_ch = ch.lower()
        if lower_ch in char_to_index:
            k = key[j % len(key)]
            row = get_row(k)

            if row is None:
                # ключевой символ не в алфавите — пропускаем
                result.append(ch)
                continue

            idx = char_to_index[lower_ch]
            encrypted_char = row[idx]

            # сохраняем регистр оригинала
            if ch != lower_ch:
                encrypted_char = encrypted_char.upper()

            result.append(encrypted_char)
            j += 1
        else:
            result.append(ch)

    return "".join(result)


# Шифр Порта — инволюция: повторное шифрование = расшифрование
decrypt = encrypt