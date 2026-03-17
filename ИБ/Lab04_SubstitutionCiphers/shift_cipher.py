from utils import ALPHABET, N, char_to_index, index_to_char

K = 28

def encrypt(text):
    result = ""

    for ch in text:
        if ch in char_to_index:
            x = char_to_index[ch]
            y = (x + K) % N
            result += index_to_char[y]
        else:
            result += ch

    return result


def decrypt(text):
    result = ""

    for ch in text:
        if ch in char_to_index:
            y = char_to_index[ch]
            x = (y - K) % N
            result += index_to_char[x]
        else:
            result += ch

    return result