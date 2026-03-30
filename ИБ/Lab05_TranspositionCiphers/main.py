import time
import math
import matplotlib.pyplot as plt
from route_cipher import encrypt as route_encrypt, decrypt as route_decrypt
from multi_cipher import encrypt as multi_encrypt, decrypt as multi_decrypt

POLISH_ALPHABET = "AĄBCĆDEĘFGHIJKLŁMNŃOÓPRSŚTUVWXYZŹŻ"
POLISH_ALPHABET += POLISH_ALPHABET.lower()

def plot_histogram(text, filename):
    freq = {}
    for c in text:
        if c in POLISH_ALPHABET:
            freq[c] = freq.get(c, 0) + 1
    plt.figure(figsize=(10,5))
    plt.bar(freq.keys(), freq.values())
    plt.title(filename)
    plt.savefig(filename)
    plt.close()

def save_to_file(filename, text):
    with open(filename, "w", encoding="utf-8") as f:
        f.write(text)

def main():
    with open("input.txt", "r", encoding="utf-8") as f:
        text = f.read()

    print("Выберите шифр:")
    print("1 – Маршрутная перестановка")
    print("2 – Множественная перестановка")
    choice = input("Введите номер шифра (1 или 2): ")

    if choice == "1":
        rows, cols = 10, math.ceil(len(text)/10)
        start = time.perf_counter()
        enc = route_encrypt(text, rows, cols)
        end = time.perf_counter()
        print("Зашифровано за:", end-start, "сек")

        start = time.perf_counter()
        dec = route_decrypt(enc, rows, cols)
        end = time.perf_counter()
        print("Расшифровано за:", end-start, "сек")

        save_to_file("encrypted_route.txt", enc)
        save_to_file("decrypted_route.txt", dec)

        plot_histogram(text, "hist_original_route.png")
        plot_histogram(enc, "hist_encrypted_route.png")

        print("Файлы сохранены:")
        print("- encrypted_route.txt")
        print("- decrypted_route.txt")
        print("- hist_original_route.png")
        print("- hist_encrypted_route.png")

    elif choice == "2":
        key1, key2 = "Игорь", "Романов"

        start = time.perf_counter()
        enc = multi_encrypt(text, key1, key2)
        end = time.perf_counter()
        print("Зашифровано за:", end-start, "сек")

        start = time.perf_counter()
        dec = multi_decrypt(enc, key1, key2)
        end = time.perf_counter()
        print("Расшифровано за:", end-start, "сек")

        save_to_file("encrypted_multi.txt", enc)
        save_to_file("decrypted_multi.txt", dec)

        plot_histogram(text, "hist_original_multi.png")
        plot_histogram(enc, "hist_encrypted_multi.png")

        print("Файлы сохранены:")
        print("- encrypted_multi.txt")
        print("- decrypted_multi.txt")
        print("- hist_original_multi.png")
        print("- hist_encrypted_multi.png")

    else:
        print("Неверный выбор. Завершение программы.")

if __name__ == "__main__":
    main()