import math
import os
from collections import Counter
from datetime import datetime
import matplotlib.pyplot as plt


# ==============================
# 1. Энтропия Шеннона
# ==============================

def shannon_entropy(probabilities):
    return -sum(p * math.log2(p) for p in probabilities if p > 0)


# ==============================
# 2. Получение полного пути к файлу
# ==============================

def get_file_path(filename):
    base_dir = os.path.dirname(os.path.abspath(__file__))
    return os.path.join(base_dir, filename)


# ==============================
# 3. Анализ текстового файла
# ==============================

def analyze_text_file(filename):
    filepath = get_file_path(filename)

    with open(filepath, 'r', encoding='utf-8') as f:
        text = f.read()

    total_chars = len(text)
    counter = Counter(text)

    probabilities = {char: count / total_chars for char, count in counter.items()}
    entropy = shannon_entropy(probabilities.values())

    return entropy, counter


# ==============================
# 4. Гистограмма частот
# ==============================

def plot_histogram(counter, title, filename):
    chars = list(counter.keys())
    freqs = list(counter.values())

    plt.figure(figsize=(12, 6))
    plt.bar(chars, freqs)
    plt.title(title)
    plt.xlabel("Символы")
    plt.ylabel("Частота")
    plt.xticks(rotation=90)
    plt.tight_layout()

    plt.savefig(filename, dpi=300)
    plt.close()


# ==============================
# 5. Анализ бинарного файла
# ==============================

def analyze_binary_file(filename):
    filepath = get_file_path(filename)

    with open(filepath, 'rb') as f:
        data = f.read()

    bits = ''.join(format(byte, '08b') for byte in data)

    total_bits = len(bits)
    counter = Counter(bits)

    probabilities = {bit: count / total_bits for bit, count in counter.items()}
    entropy = shannon_entropy(probabilities.values())

    return entropy


# ==============================
# 6. Количество информации
# ==============================

def information_amount(message, entropy):
    return len(message) * entropy


# ==============================
# 7. Энтропия бинарного канала
# ==============================

def binary_channel_entropy(p):
    if p == 0 or p == 1:
        return 0
    return -p * math.log2(p) - (1 - p) * math.log2(1 - p)


# ==============================
# 8. ASCII-анализ
# ==============================

def ascii_entropy(message):
    ascii_bytes = message.encode('ascii', errors='ignore')
    bits = ''.join(format(byte, '08b') for byte in ascii_bytes)

    counter = Counter(bits)
    total_bits = len(bits)

    probabilities = {bit: count / total_bits for bit, count in counter.items()}
    entropy = shannon_entropy(probabilities.values())

    return entropy

# ==============================
# 9. Вспомогательная фукнция для текущего времени
# ==============================
def get_current_time():
    now = datetime.now()
    # Форматирование: ГГГГ-ММ-ДД_ЧЧ-ММ-СС (например, 2023-10-25_14-30-05)
    return now.strftime("%Y-%m-%d_%H-%M-%S")

# ==============================
# 10. Главная программа
# ==============================

def main():

    latin_file = "eng.txt"
    entropy_latin, counter_latin = analyze_text_file(latin_file)
    print("Энтропия латинского алфавита:", entropy_latin)
    plot_histogram(counter_latin, "Гистограмма латинского алфавита", f"latin_alphabet_{get_current_time()}.png")

    cyrillic_file = "ru.txt"
    entropy_cyrillic, counter_cyrillic = analyze_text_file(cyrillic_file)
    print("Энтропия кириллического алфавита:", entropy_cyrillic)
    plot_histogram(counter_cyrillic, "Гистограмма кириллического алфавита", f"cyrillic_alphabet_{get_current_time()}.png")

    binary_file = "binary.txt"
    entropy_binary = analyze_binary_file(binary_file)
    print("Энтропия бинарного алфавита:", entropy_binary)

    default_name = "Романов Игорь Вячеславович"
    name = input(f"\nВведите ФИО (по умолчанию: {default_name}): ")
    if not name.strip():
        name = default_name

    print("\nКоличество информации (на основе энтропии латиницы):",
          information_amount(name, entropy_latin))

    print("Количество информации (на основе энтропии кириллицы):",
          information_amount(name, entropy_cyrillic))

    ascii_H = ascii_entropy(name)
    print("\nЭнтропия ASCII:", ascii_H)
    print("Количество информации в ASCII:",
          information_amount(name, ascii_H))

    print("\nЭнтропия канала при вероятности ошибки:")
    for p in [0.1, 0.5, 1.0]:
        print(f"p = {p}, H(p) = {binary_channel_entropy(p)}")


if __name__ == "__main__":
    main()