import math
from collections import Counter
import matplotlib.pyplot as plt

LATIN_ALPHABET = (
    "abcdefghijklmnopqrstuvwxyz"
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    "æøåÆØÅ"
)

CYRILLIC_ALPHABET = (
    "абвгғдеёжзийкқлмнңоөпрстуұүфхһцчшщъыіьэюя"
    "АБВГҒДЕЁЖЗИЙКҚЛМНҢОӨПРСТУҰҮФХҺЦЧШЩЪЫІЬЭЮЯ"
)

# ==============================
# Энтропия Шеннона
# ==============================

def shannon_entropy(probabilities):
    return -sum(p * math.log2(p) for p in probabilities if p > 0)


# ==============================
# Анализ текстового файла
# ==============================

def analyze_text_file(filename, alphabet):
    with open(filename, 'r', encoding='utf-8') as f:
        text = f.read()

    filtered = [c for c in text if c in alphabet]
    total = len(filtered)

    counter = Counter(filtered)

    probabilities = [count / total for count in counter.values()]
    entropy = shannon_entropy(probabilities)

    return entropy, counter, total


# ==============================
# Анализ бинарного файла
# ==============================

def analyze_binary_file(filename):
    with open(filename, 'rb') as f:
        data = f.read()

    bits = ''.join(format(byte, '08b') for byte in data)

    total_bits = len(bits)
    counter = Counter(bits)

    probabilities = [count / total_bits for count in counter.values()]
    entropy = shannon_entropy(probabilities)

    information = total_bits * entropy

    return entropy, information, total_bits


# ==============================
# Построение гистограммы
# ==============================

def plot_histogram(counter, title, filename):
    symbols = list(counter.keys())
    frequencies = list(counter.values())

    plt.figure(figsize=(12, 6))
    plt.bar(symbols, frequencies)
    plt.title(title)
    plt.xlabel("Символы")
    plt.ylabel("Частота")
    plt.xticks(rotation=90)
    plt.tight_layout()
    plt.savefig(filename, dpi=300)
    plt.close()


# ==============================
# Энтропия бинарного канала
# ==============================

def binary_channel_entropy(p):
    if p == 0 or p == 1:
        return 0
    return -p * math.log2(p) - (1 - p) * math.log2(1 - p)


# ==============================
# Учёт ошибок канала с ограничением по пропускной способности
# ==============================
def effective_information(I_source, N_bits, p_error):
    """
    I_source – исходная информация в битах (источник)
    N_bits – количество битов в сообщении
    p_error – вероятность ошибки
    """
    H_p = binary_channel_entropy(p_error)
    C = 1 - H_p
    # Эффективная информация = минимум: источник vs канал
    I_eff = min(I_source, N_bits * C)
    return I_eff

# ==============================
# ASCII-анализ сообщения
# ==============================

def analyze_text_encoding(message):
    """
    Сначала пытается закодировать сообщение в ASCII.
    Если невозможно — автоматически использует UTF-8.
    Возвращает: (энтропия, количество информации, название кодировки)
    """

    try:
        encoded_bytes = message.encode('ascii')
        encoding_used = "ASCII"
    except UnicodeEncodeError:
        encoded_bytes = message.encode('utf-8')
        encoding_used = "UTF-8"

    bits = ''.join(format(byte, '08b') for byte in encoded_bytes)

    total_bits = len(bits)
    counter = Counter(bits)

    probabilities = [count / total_bits for count in counter.values()]
    entropy = shannon_entropy(probabilities)

    information = total_bits * entropy

    return entropy, information, encoding_used


# ==============================
# Главная программа
# ==============================

def main():

    # --- ДАТСКИЙ ---
    H_latin, counter_latin, _ = analyze_text_file(
        "dan_text.txt", LATIN_ALPHABET)

    print("Энтропия датского алфавита:", H_latin)

    plot_histogram(counter_latin,
                   "Гистограмма датского алфавита",
                   "danish_histogram.png")

    # --- КАЗАХСКИЙ ---
    H_cyr, counter_cyr, _ = analyze_text_file(
        "kaz_text.txt", CYRILLIC_ALPHABET)

    print("Энтропия казахского алфавита:", H_cyr)

    plot_histogram(counter_cyr,
                   "Гистограмма казахского алфавита",
                   "kazakh_histogram.png")

    # --- БИНАРНЫЙ ФАЙЛ ---
    H_bin, I_bin_file, N_Bits = analyze_binary_file("binary.txt")

    print("Энтропия бинарного файла:", H_bin)
    print("Количество информации бинарного файла:", I_bin_file)

    # --- ФИО ---
    fio_latin = "RomanovIgorVjatjeslavovitj"
    fio_cyr = "РомановИгорьВячеславович"

    fio_latin_letters = ''.join(c for c in fio_latin if c.isalpha())
    fio_cyr_letters = ''.join(c for c in fio_cyr if c.isalpha())

    I_latin = len(fio_latin_letters) * H_latin
    I_cyr = len(fio_cyr_letters) * H_cyr

    print("\nИнформация ФИО (датский):", I_latin)
    print("Информация ФИО (казахский):", I_cyr)

    # --- Кодирование сообщения ---
    H_enc_latin, I_enc_latin, enc_latin = analyze_text_encoding(fio_latin)
    H_enc_cyr, I_enc_cyr, enc_cyr = analyze_text_encoding(fio_cyr)

    print(f"\nЭнтропия {enc_latin} (датский ФИО):", H_enc_latin)
    print(f"Количество информации в {enc_latin} (датский ФИО):", I_enc_latin)

    print(f"\nЭнтропия {enc_cyr} (казахский ФИО):", H_enc_cyr)
    print(f"Количество информации в {enc_cyr} (казахский ФИО):", I_enc_cyr)

    # Бинарное представление ФИО (как в C#)
    I_latin_binary = len(fio_latin) * 8
    I_cyr_binary = len(fio_cyr) * 8

    print("\nБинарная длина ФИО (датский):", I_latin_binary)
    print("Бинарная длина ФИО (казахский):", I_cyr_binary)

    # --- Учет ошибок канала ---
    probabilities = [0.1, 0.5, 1.0]

    for p in probabilities:
        print(f"\np = {p}")
        print("Датский:", effective_information(I_latin_binary, len(fio_latin) * 8, p))
        print("Казахский:", effective_information(I_cyr_binary, len(fio_cyr) * 8, p))
        print("Бинарный файл:", effective_information(I_bin_file, N_Bits, p))
        print(f"{enc_latin} (датский):", effective_information(I_enc_latin, len(fio_latin) * 8, p))
        print(f"{enc_cyr} (казахский):", effective_information(I_enc_cyr, len(fio_cyr) * 8, p))


if __name__ == "__main__":
    main()