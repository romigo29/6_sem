import tkinter as tk
from tkinter import scrolledtext, messagebox

from utils import read_text_from_file, text_to_base64, base64_to_text, measure_time
from rsa_cipher import generate_rsa_keys, rsa_encrypt, rsa_decrypt
from elgamal_cipher import generate_elgamal_keys, elgamal_encrypt, elgamal_decrypt


class CryptoApp:
    def __init__(self, root):
        self.root = root
        self.root.title("RSA и Эль-Гамаль")
        self.root.geometry("900x650")

        self.rsa_private_key = None
        self.rsa_public_key = None
        self.rsa_ciphertext = None

        self.elgamal_private_key = None
        self.elgamal_public_key = None
        self.elgamal_ciphertext = None

        self.create_widgets()

    def clear_output(self):
        self.output_area.delete("1.0", tk.END)

    def create_widgets(self):
        tk.Button(self.root, text="Считать text.txt", command=self.load_text).pack(pady=5)
        tk.Button(self.root, text="Кодировать в Base64", command=self.encode_base64).pack(pady=5)

        tk.Label(self.root, text="Исходный / промежуточный текст").pack()
        self.input_area = scrolledtext.ScrolledText(self.root, width=100, height=8)
        self.input_area.pack(pady=5)

        tk.Label(self.root, text="Результат").pack()
        self.output_area = scrolledtext.ScrolledText(self.root, width=100, height=15)
        self.output_area.pack(pady=5)

        frame = tk.Frame(self.root)
        frame.pack(pady=10)

        tk.Button(frame, text="RSA: сгенерировать ключи", command=self.generate_rsa).grid(row=0, column=0, padx=5)
        tk.Button(frame, text="RSA: зашифровать", command=self.encrypt_rsa).grid(row=0, column=1, padx=5)
        tk.Button(frame, text="RSA: расшифровать", command=self.decrypt_rsa).grid(row=0, column=2, padx=5)

        tk.Button(frame, text="Эль-Гамаль: сгенерировать ключи", command=self.generate_elgamal).grid(row=1, column=0, padx=5, pady=5)
        tk.Button(frame, text="Эль-Гамаль: зашифровать", command=self.encrypt_elgamal).grid(row=1, column=1, padx=5)
        tk.Button(frame, text="Эль-Гамаль: расшифровать", command=self.decrypt_elgamal).grid(row=1, column=2, padx=5)

        tk.Button(
            self.root,
            text="Сравнить производительность RSA и Эль-Гамаля",
            command=self.compare_algorithms
        ).pack(pady=5)

        tk.Button(self.root, text="Очистить результат", command=self.clear_output).pack(pady=5)

    def load_text(self):
        try:
            text = read_text_from_file()
            self.input_area.delete("1.0", tk.END)
            self.input_area.insert(tk.END, text)
        except FileNotFoundError:
            messagebox.showerror("Ошибка", "Файл text.txt не найден")

    def encode_base64(self):
        text = self.input_area.get("1.0", tk.END).strip()

        if not text:
            messagebox.showwarning("Предупреждение", "Сначала загрузите или введите текст")
            return

        encoded = text_to_base64(text)

        self.input_area.delete("1.0", tk.END)
        self.input_area.insert(tk.END, encoded)

        self.output_area.insert(tk.END, "Base64-представление текста:\n")
        self.output_area.insert(tk.END, encoded + "\n\n")

    def generate_rsa(self):
        self.rsa_private_key, self.rsa_public_key = generate_rsa_keys()
        self.output_area.insert(tk.END, "RSA-ключи успешно сгенерированы\n\n")

    def encrypt_rsa(self):
        if self.rsa_public_key is None:
            messagebox.showwarning("Предупреждение", "Сначала сгенерируйте RSA-ключи")
            return

        message = self.input_area.get("1.0", tk.END).strip()

        self.rsa_ciphertext, elapsed_time = measure_time(
            rsa_encrypt,
            self.rsa_public_key,
            message
        )

        self.output_area.insert(tk.END, "RSA: зашифрованный текст в байтах:\n")
        self.output_area.insert(tk.END, str(self.rsa_ciphertext) + "\n")
        self.output_area.insert(tk.END, f"Время зашифрования RSA: {elapsed_time:.8f} секунд\n\n")

    def decrypt_rsa(self):
        if self.rsa_private_key is None or self.rsa_ciphertext is None:
            messagebox.showwarning("Предупреждение", "Нет RSA-ключа или шифртекста")
            return

        decrypted, elapsed_time = measure_time(
            rsa_decrypt,
            self.rsa_private_key,
            self.rsa_ciphertext
        )

        self.output_area.insert(tk.END, "RSA: расшифрованный текст:\n")
        self.output_area.insert(tk.END, decrypted + "\n")
        self.output_area.insert(tk.END, f"Время расшифрования RSA: {elapsed_time:.8f} секунд\n\n")

    def generate_elgamal(self):
        self.elgamal_private_key, self.elgamal_public_key = generate_elgamal_keys()

        p, g, y = self.elgamal_public_key

        self.output_area.insert(tk.END, "Ключи Эль-Гамаля успешно сгенерированы\n")
        self.output_area.insert(tk.END, f"Открытый ключ: p={p}, g={g}, y={y}\n")
        self.output_area.insert(tk.END, f"Закрытый ключ: x={self.elgamal_private_key}\n\n")

    def encrypt_elgamal(self):
        if self.elgamal_public_key is None:
            messagebox.showwarning("Предупреждение", "Сначала сгенерируйте ключи Эль-Гамаля")
            return

        message = self.input_area.get("1.0", tk.END).strip()

        self.elgamal_ciphertext, elapsed_time = measure_time(
            elgamal_encrypt,
            self.elgamal_public_key,
            message
        )

        self.output_area.insert(tk.END, "Эль-Гамаль: зашифрованные блоки:\n")
        self.output_area.insert(tk.END, str(self.elgamal_ciphertext) + "\n")
        self.output_area.insert(tk.END, f"Время зашифрования Эль-Гамаля: {elapsed_time:.8f} секунд\n\n")

    def decrypt_elgamal(self):
        if self.elgamal_private_key is None or self.elgamal_ciphertext is None:
            messagebox.showwarning("Предупреждение", "Нет ключа или шифртекста Эль-Гамаля")
            return

        decrypted, elapsed_time = measure_time(
            elgamal_decrypt,
            self.elgamal_private_key,
            self.elgamal_public_key,
            self.elgamal_ciphertext
        )

        self.output_area.insert(tk.END, "Эль-Гамаль: расшифрованный текст:\n")
        self.output_area.insert(tk.END, decrypted + "\n")
        self.output_area.insert(tk.END, f"Время расшифрования Эль-Гамаля: {elapsed_time:.8f} секунд\n\n")

    def compare_algorithms(self):
        try:
            text = read_text_from_file()
        except FileNotFoundError:
            messagebox.showerror("Ошибка", "Файл text.txt не найден")
            return

        message = text_to_base64(text)

        plain_size = len(message.encode("ascii"))

        rsa_private_key, rsa_public_key = generate_rsa_keys()
        elgamal_private_key, elgamal_public_key = generate_elgamal_keys()

        rsa_ciphertext, rsa_encrypt_time = measure_time(
            rsa_encrypt,
            rsa_public_key,
            message
        )

        rsa_decrypted, rsa_decrypt_time = measure_time(
            rsa_decrypt,
            rsa_private_key,
            rsa_ciphertext
        )

        elgamal_ciphertext, elgamal_encrypt_time = measure_time(
            elgamal_encrypt,
            elgamal_public_key,
            message
        )

        elgamal_decrypted, elgamal_decrypt_time = measure_time(
            elgamal_decrypt,
            elgamal_private_key,
            elgamal_public_key,
            elgamal_ciphertext
        )

        rsa_size = len(rsa_ciphertext)
        elgamal_size = len(str(elgamal_ciphertext).encode("ascii"))

        rsa_ratio = rsa_size / plain_size
        elgamal_ratio = elgamal_size / plain_size

        self.output_area.insert(tk.END, "Сравнение производительности RSA и Эль-Гамаля\n")
        self.output_area.insert(tk.END, "-" * 70 + "\n")

        self.output_area.insert(tk.END, f"Исходный текст: {text}\n")
        self.output_area.insert(tk.END, f"Base64-представление: {message}\n")
        self.output_area.insert(tk.END, f"Размер открытого текста: {plain_size} байт\n\n")

        self.output_area.insert(tk.END, "RSA:\n")
        self.output_area.insert(tk.END, f"Размер открытого текста: {plain_size} байт\n")
        self.output_area.insert(tk.END, f"Размер криптотекста: {rsa_size} байт\n")
        self.output_area.insert(tk.END, f"Увеличение объема: в {rsa_ratio:.2f} раза\n")
        self.output_area.insert(tk.END, f"Время зашифрования: {rsa_encrypt_time:.8f} секунд\n")
        self.output_area.insert(tk.END, f"Время расшифрования: {rsa_decrypt_time:.8f} секунд\n")
        self.output_area.insert(tk.END, f"Расшифрованный текст совпадает: {rsa_decrypted == message}\n\n")

        self.output_area.insert(tk.END, "Эль-Гамаль:\n")
        self.output_area.insert(tk.END, f"Размер открытого текста: {plain_size} байт\n")
        self.output_area.insert(tk.END, f"Размер криптотекста: {elgamal_size} байт\n")
        self.output_area.insert(tk.END, f"Увеличение объема: в {elgamal_ratio:.2f} раза\n")
        self.output_area.insert(tk.END, f"Время зашифрования: {elgamal_encrypt_time:.8f} секунд\n")
        self.output_area.insert(tk.END, f"Время расшифрования: {elgamal_decrypt_time:.8f} секунд\n")
        self.output_area.insert(tk.END, f"Расшифрованный текст совпадает: {elgamal_decrypted == message}\n\n")

if __name__ == "__main__":
    root = tk.Tk()
    app = CryptoApp(root)
    root.mainloop()