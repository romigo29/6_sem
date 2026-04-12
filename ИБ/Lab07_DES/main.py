from key_utils import prepare_key
from padding import pad, unpad
from des_ede2 import ede2_encrypt, ede2_decrypt, DEFAULT_IV
from benchmark import measure_speed
from avalanche import avalanche_ede2_steps
from weak_keys import WEAK_KEYS, SEMI_WEAK_KEYS

def main():

    # --- Загрузка текста ---
    with open("text.txt", "r", encoding="ascii") as f:
        text = f.read()

    raw = text.encode()
    data = pad(raw)

    # --- 1. Разделение на блоки с дополнением ---
    print("\n--- Разделение на блоки ---")
    num_blocks = len(data) // 8
    pad_len = len(data) - len(raw)
    print(f"Размер исходного текста: {len(raw)} байт")
    print(f"Размер после дополнения (PKCS5): {len(data)} байт (добавлено {pad_len} байт)")
    print(f"Количество блоков по 8 байт: {num_blocks}")
    print(f"Первый блок:   {data[:8]}")
    print(f"Последний блок: {data[-8:]}  (содержит {pad_len} байт дополнения)")

    # --- 2. Преобразование ключевой информации ---
    print("\n--- Преобразование ключей ---")
    key1 = prepare_key("Informat")
    key2 = prepare_key("ionsecur")
    print(f"Ключ 1 (строка -> байты): \"Informat\" -> {key1.hex()} ({len(key1)*8} бит)")
    print(f"Ключ 2 (строка -> байты): \"ionsecur\" -> {key2.hex()} ({len(key2)*8} бит)")
    print(f"Алгоритм: DES-EDE2 (E(K1) -> D(K2) -> E(K1))")

    # --- 3. Шифрование / расшифрование (CBC) ---
    print("\n--- Зашифрование / расшифрование ---")
    iv = DEFAULT_IV
    encrypt = lambda d: ede2_encrypt(d, key1, key2, iv)
    decrypt = lambda d: ede2_decrypt(d, key1, key2, iv)

    encrypted = encrypt(data)
    decrypted = unpad(decrypt(encrypted))

    print(f"Исходный текст (первые 80 символов): {text[:80]}...")
    print(f"Шифртекст (hex, первые 64 символа):  {encrypted.hex()[:64]}...")
    print(f"Расшифрованный текст (первые 80):    {decrypted.decode()[:80]}...")
    print(f"Расшифрование совпадает с оригиналом: {decrypted.decode() == text}")

    # --- Сохранение ---
    with open("encrypted.txt", "wb") as f:
        f.write(encrypted)
    with open("decrypted.txt", "w") as f:
        f.write(decrypted.decode())
    print("Файлы сохранены: encrypted.txt, decrypted.txt")

    # --- Скорость ---
    print("\n--- Скорость шифрования ---")
    iterations = 1000
    t = measure_speed(encrypt, data, iterations)
    print(f"Время на {iterations} итераций: {t:.4f} сек.")
    print(f"Среднее время на 1 итерацию: {t / iterations * 1000:.4f} мс.")

    # --- Лавинный эффект
    print("\n\n--- ЛАВИННЫЙ ЭФФЕКТ ---")
    word = data[:8]

    # ── Случай 1: заданные ключи ──
    print(f"\nСлучай 1: Заданные ключи K1=0x{key1.hex()}, K2=0x{key2.hex()}")
    for line in avalanche_ede2_steps(word, key1, key2):
        print(line)

    # ── Случай 2: слабые ключи ──
    print(f"\nСлучай 2: Слабые ключи (K1 = K2 = слабый ключ)")
    for i, wk in enumerate(WEAK_KEYS):
        print(f"\n  Слабый ключ {i+1}: 0x{wk.hex()}")
        for line in avalanche_ede2_steps(word, wk, wk):
            print(line)

    # ── Случай 3: полуслабые ключи ──
    print(f"\nСлучай 3: Полуслабые ключи")
    for i, (wk1, wk2) in enumerate(SEMI_WEAK_KEYS):
        print(f"\n  Полуслабая пара {i+1}: K1=0x{wk1.hex()}, K2=0x{wk2.hex()}")
        for line in avalanche_ede2_steps(word, wk1, wk2):
            print(line)


if __name__ == "__main__":
    main()
