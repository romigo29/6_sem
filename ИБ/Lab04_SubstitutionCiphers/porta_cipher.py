from utils import ALPHABET

def generate_porta_table():
    N = len(ALPHABET)
    half = N // 2

    table = {}
    pairs = []

    # создаём пары букв
    i = 0
    while i < N:
        if i+1 < N:
            pairs.append((ALPHABET[i], ALPHABET[i+1]))
        else:
            # если последний символ без пары, делаем "одиночку"
            pairs.append((ALPHABET[i],))
        i += 2

    for idx, pair in enumerate(pairs):
        shift = half + idx

        row = ""
        for j in range(N):
            row += ALPHABET[(j + shift) % N]

        table[pair] = row

    return table

PORTA_TABLE = generate_porta_table()

def get_row(k):
    for pair in PORTA_TABLE:
        if k in pair:
            return PORTA_TABLE[pair]
    return None

def encrypt(text, key):
    result = ""
    key = key.lower()
    j = 0

    for ch in text:
        if ch in ALPHABET:
            k = key[j % len(key)]
            row = get_row(k)

            idx = ALPHABET.index(ch)

            if row and idx < len(row):
                result += row[idx]
            else:
                result += ch  # fallback

            j += 1
        else:
            result += ch

    return result


decrypt = encrypt