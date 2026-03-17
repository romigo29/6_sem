# route_cipher.py
import math

def encrypt(text, rows, cols):
    table = [['' for _ in range(cols)] for _ in range(rows)]
    for i, char in enumerate(text):
        r = i % rows
        c = i // rows
        if r < rows and c < cols:
            table[r][c] = char
    encrypted = ''.join([''.join(row) for row in table])
    return encrypted

def decrypt(text, rows, cols):
    table = [['' for _ in range(cols)] for _ in range(rows)]
    idx = 0
    for r in range(rows):
        for c in range(cols):
            if idx < len(text):
                table[r][c] = text[idx]
                idx += 1
    decrypted = ''
    for c in range(cols):
        for r in range(rows):
            decrypted += table[r][c]
    return decrypted