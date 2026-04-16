import tkinter as tk
from rc4 import RC4

class RC4App:
    def __init__(self, root):
        self.root = root
        self.root.title("RC4 Cipher")

        self.rc4 = RC4([15, 14, 13, 12, 11, 10])
        self.last_cipher = None

        tk.Button(root, text="Зашифровать", command=self.encrypt).pack()
        tk.Button(root, text="Расшифровать", command=self.decrypt).pack()

        self.output = tk.Text(root, height=15)
        self.output.pack()

    def encrypt(self):
        try:
            with open("text.txt", "r", encoding="utf-8") as f:
                text = f.read()

            cipher, time_spent = self.rc4.encrypt(text)
            self.last_cipher = cipher

            with open("cipher.txt", "w", encoding="utf-8") as f:
                f.write(str(cipher))

            speed = len(text) / time_spent if time_spent > 0 else 0

            self.output.delete("1.0", tk.END)
            self.output.insert(tk.END,
                f"Шифртекст записан в cipher.txt\n"
                f"Время генерации ПСП: {time_spent:.6f} сек\n"
                f"Скорость: {speed:.2f} байт/сек"
            )

        except Exception as e:
            self.output.insert(tk.END, f"Ошибка: {str(e)}\n")

    def decrypt(self):
        try:
            if self.last_cipher is None:
                self.output.insert(tk.END, "Нет данных\n")
                return

            text, time_spent = self.rc4.decrypt(self.last_cipher)

            with open("decrypted.txt", "w", encoding="utf-8") as f:
                f.write(text)

            speed = len(self.last_cipher) / time_spent if time_spent > 0 else 0

            self.output.delete("1.0", tk.END)
            self.output.insert(tk.END,
                f"Расшифрованный текст записан в decrypted.txt\n"
                f"Время генерации ПСП: {time_spent:.6f} сек\n"
                f"Скорость: {speed:.2f} байт/сек"
            )

        except Exception as e:
            self.output.insert(tk.END, f"Ошибка: {str(e)}\n")