import time

from shift_cipher import encrypt as shift_enc, decrypt as shift_dec
from porta_cipher import encrypt as porta_enc, decrypt as porta_dec
from analysis import calculate_frequency, plot_histogram


def read_file(path):
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def write_file(path, text):
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)


def measure_time(func, *args):
    start = time.perf_counter()
    result = func(*args)
    end = time.perf_counter()

    return result, (end - start)


def main():
    text = read_file("input.txt")

    text = text.lower()

    print("1 - Shift cipher")
    print("2 - Porta cipher")
    choice = input("Выбор: ")

    if choice == "1":
        enc, enc_time = measure_time(shift_enc, text)
        dec, dec_time = measure_time(shift_dec, enc)

    elif choice == "2":
        default_key = "kluczkluczk"
        user_input = input(f"Введите ключ (Enter = {default_key}): ").strip()

        key = user_input if user_input else default_key
        enc, enc_time = measure_time(porta_enc, text, key)
        dec, dec_time = measure_time(porta_dec, enc, key)

    else:
        print("Ошибка выбора")
        return

    write_file("encrypted.txt", enc)
    write_file("decrypted.txt", dec)

    # --- Частотный анализ ---
    freq_original = calculate_frequency(text)
    freq_encrypted = calculate_frequency(enc)

    plot_histogram(freq_original, "Частоты исходного текста", "freq_original.png")
    plot_histogram(freq_encrypted, "Частоты зашифрованного текста", "freq_encrypted.png")

    # --- Вывод времени ---
    print("\nВремя выполнения:")
    print(f"Шифрование: {enc_time:.6f} сек")
    print(f"Дешифрование: {dec_time:.6f} сек")


if __name__ == "__main__":
    main()