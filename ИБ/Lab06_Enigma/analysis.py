import matplotlib.pyplot as plt
from collections import Counter
import os
import string

ALPHABET = string.ascii_uppercase

def plot_histogram(text, title, filename):
    freq = Counter([c for c in text.upper() if c in ALPHABET])

    letters = list(ALPHABET)
    values = [freq.get(letter, 0) for letter in letters]

    plt.figure()
    plt.bar(letters, values)
    plt.title(title)
    plt.xlabel("Letters")
    plt.ylabel("Frequency")

    save_path = os.path.join(os.getcwd(), filename)
    plt.savefig(save_path)
    plt.close()