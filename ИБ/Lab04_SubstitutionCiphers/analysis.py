from collections import Counter
import matplotlib.pyplot as plt
from utils import ALPHABET


def calculate_frequency(text):
    text = [ch for ch in text if ch in ALPHABET]
    total = len(text)

    counter = Counter(text)

    freq = {}
    for ch in ALPHABET:
        freq[ch] = counter[ch] / total if total > 0 else 0

    return freq


def plot_histogram(freq, title, filename):
    letters = list(freq.keys())
    values = list(freq.values())

    plt.figure()
    plt.bar(letters, values)
    plt.title(title)
    plt.xlabel("Символы")
    plt.ylabel("Частота")

    plt.xticks(rotation=45)
    plt.tight_layout()

    plt.savefig(filename)
    plt.close()