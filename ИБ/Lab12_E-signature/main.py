import json
import threading
import tkinter as tk
from tkinter import ttk, filedialog, messagebox

import rsa_signature
import elgamal_signature
import schnorr_signature
from benchmark import measure_once, average_time
from crypto_utils import int_to_hex, hex_to_int


class SignatureApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("ЭЦП: RSA, Эль-Гамаль, Шнорр")
        self.geometry("1120x760")
        self.keys = None
        self.signature = None
        self._build_ui()

    def _build_ui(self):
        root = ttk.Frame(self, padding=10)
        root.pack(fill=tk.BOTH, expand=True)

        top = ttk.Frame(root)
        top.pack(fill=tk.X)

        ttk.Label(top, text="Алгоритм:").pack(side=tk.LEFT)
        self.algorithm = tk.StringVar(value="RSA")
        ttk.Combobox(
            top,
            textvariable=self.algorithm,
            values=["RSA", "ElGamal", "Schnorr"],
            state="readonly",
            width=12,
        ).pack(side=tk.LEFT, padx=5)

        ttk.Label(top, text="Размер p/n, бит:").pack(side=tk.LEFT, padx=(15, 0))
        self.bits = tk.StringVar(value="1024")
        ttk.Entry(top, textvariable=self.bits, width=8).pack(side=tk.LEFT, padx=5)

        ttk.Label(top, text="Размер q для Шнорра, бит:").pack(side=tk.LEFT, padx=(15, 0))
        self.q_bits = tk.StringVar(value="160")
        ttk.Entry(top, textvariable=self.q_bits, width=8).pack(side=tk.LEFT, padx=5)

        self.generate_button = ttk.Button(top, text="Сгенерировать ключи", command=self.generate_keys)
        self.generate_button.pack(side=tk.LEFT, padx=10)
        ttk.Button(top, text="Загрузить text.txt", command=self.load_text_file).pack(side=tk.LEFT, padx=5)
        ttk.Button(top, text="Подписать", command=self.sign_message).pack(side=tk.LEFT, padx=5)
        ttk.Button(top, text="Проверить", command=self.verify_signature).pack(side=tk.LEFT, padx=5)
        ttk.Button(top, text="Тест времени", command=self.benchmark).pack(side=tk.LEFT, padx=5)
        ttk.Button(top, text="Очистить", command=self.clear_fields).pack(side=tk.LEFT, padx=5)

        paned = ttk.Panedwindow(root, orient=tk.HORIZONTAL)
        paned.pack(fill=tk.BOTH, expand=True, pady=10)

        left = ttk.Frame(paned)
        right = ttk.Frame(paned)
        paned.add(left, weight=2)
        paned.add(right, weight=1)

        ttk.Label(left, text="Сообщение").pack(anchor=tk.W)
        self.message_text = tk.Text(left, height=12, wrap=tk.WORD)
        self.message_text.pack(fill=tk.BOTH, expand=True)
        self.message_text.insert("1.0", "Romanov Igor")

        ttk.Label(left, text="Подпись").pack(anchor=tk.W, pady=(10, 0))
        self.signature_text = tk.Text(left, height=8, wrap=tk.WORD)
        self.signature_text.pack(fill=tk.BOTH, expand=True)

        ttk.Label(left, text="Журнал").pack(anchor=tk.W, pady=(10, 0))
        self.log_text = tk.Text(left, height=9, wrap=tk.WORD)
        self.log_text.pack(fill=tk.BOTH, expand=True)

        ttk.Label(right, text="Открытая ключевая информация").pack(anchor=tk.W)
        self.public_text = tk.Text(right, height=15, wrap=tk.WORD)
        self.public_text.pack(fill=tk.BOTH, expand=True)

        ttk.Label(right, text="Закрытая ключевая информация").pack(anchor=tk.W, pady=(10, 0))
        self.private_text = tk.Text(right, height=15, wrap=tk.WORD)
        self.private_text.pack(fill=tk.BOTH, expand=True)

        key_buttons = ttk.Frame(right)
        key_buttons.pack(fill=tk.X, pady=8)
        ttk.Button(key_buttons, text="Сохранить открытый ключ", command=self.save_public_key).pack(side=tk.LEFT, padx=3)
        ttk.Button(key_buttons, text="Загрузить открытый ключ", command=self.load_public_key).pack(side=tk.LEFT, padx=3)


    def clear_fields(self):
        self.keys = None
        self.signature = None
        self.message_text.delete("1.0", tk.END)
        self.signature_text.delete("1.0", tk.END)
        self.log_text.delete("1.0", tk.END)
        self.public_text.delete("1.0", tk.END)
        self.private_text.delete("1.0", tk.END)
        self.algorithm.set("RSA")
        self.bits.set("1024")
        self.q_bits.set("160")
        self.log("Все поля очищены. Настройки возвращены к значениям по умолчанию.")

    def log(self, text: str):
        self.log_text.insert(tk.END, text + "\n")
        self.log_text.see(tk.END)

    def message_bytes(self) -> bytes:
        return self.message_text.get("1.0", tk.END).strip().encode("utf-8")

    def generate_keys(self):
        try:
            algorithm = self.algorithm.get()
            bits = int(self.bits.get())
            q_bits = int(self.q_bits.get())
        except ValueError:
            messagebox.showerror("Ошибка", "Размеры ключей должны быть целыми числами")
            return

        self.generate_button.config(state=tk.DISABLED)
        self.log(f"Генерация ключей: {algorithm}, {bits} бит...")

        thread = threading.Thread(
            target=self._generate_keys_worker,
            args=(algorithm, bits, q_bits),
            daemon=True
        )
        thread.start()

    def _generate_keys_worker(self, algorithm: str, bits: int, q_bits: int):
        try:
            if algorithm == "RSA":
                keys, t = measure_once(rsa_signature.generate_keys, bits)
            elif algorithm == "ElGamal":
                keys, t = measure_once(elgamal_signature.generate_keys, bits)
            else:
                keys, t = measure_once(schnorr_signature.generate_keys, bits, q_bits)
            self.after(0, lambda: self._finish_key_generation(keys, t))
        except Exception as exc:
            error_message = str(exc)
            self.after(0, lambda: self._finish_key_generation_error(error_message))

    def _finish_key_generation(self, keys, elapsed_time: float):
        self.keys = keys
        self.signature = None
        self.signature_text.delete("1.0", tk.END)
        self.public_text.delete("1.0", tk.END)
        self.private_text.delete("1.0", tk.END)
        self.public_text.insert("1.0", json.dumps(self.keys.public_dict(), indent=2, ensure_ascii=False))
        self.private_text.insert("1.0", json.dumps(self.keys.private_dict(), indent=2, ensure_ascii=False))
        self.log(f"Ключи созданы за {elapsed_time:.6f} сек.")
        self.generate_button.config(state=tk.NORMAL)

    def _finish_key_generation_error(self, error_message: str):
        self.log(f"Ошибка генерации ключей: {error_message}")
        self.generate_button.config(state=tk.NORMAL)
        messagebox.showerror("Ошибка", error_message)

    def sign_message(self):
        if self.keys is None:
            messagebox.showwarning("Нет ключей", "Сначала сгенерируйте ключи")
            return
        algorithm = self.algorithm.get()
        message = self.message_bytes()
        if algorithm == "RSA":
            self.signature, t = measure_once(rsa_signature.sign, message, self.keys)
            view = {"s": int_to_hex(self.signature)}
        elif algorithm == "ElGamal":
            self.signature, t = measure_once(elgamal_signature.sign, message, self.keys)
            r, s = self.signature
            view = {"r": int_to_hex(r), "s": int_to_hex(s)}
        else:
            self.signature, t = measure_once(schnorr_signature.sign, message, self.keys)
            h, b = self.signature
            view = {"h": int_to_hex(h), "b": int_to_hex(b)}
        self.signature_text.delete("1.0", tk.END)
        self.signature_text.insert("1.0", json.dumps(view, indent=2, ensure_ascii=False))
        self.log(f"Подпись создана за {t:.6f} сек.")

    def _read_public_key(self) -> dict:
        text = self.public_text.get("1.0", tk.END).strip()
        return json.loads(text)

    def _read_signature(self):
        algorithm = self.algorithm.get()
        data = json.loads(self.signature_text.get("1.0", tk.END).strip())
        if algorithm == "RSA":
            return hex_to_int(data["s"])
        if algorithm == "ElGamal":
            return hex_to_int(data["r"]), hex_to_int(data["s"])
        return hex_to_int(data["h"]), hex_to_int(data["b"])

    def verify_signature(self):
        algorithm = self.algorithm.get()
        message = self.message_bytes()
        try:
            public_key = self._read_public_key()
            signature = self._read_signature()
            if algorithm == "RSA":
                ok = rsa_signature.verify(message, signature, public_key)
            elif algorithm == "ElGamal":
                ok = elgamal_signature.verify(message, signature, public_key)
            else:
                ok = schnorr_signature.verify(message, signature, public_key)
        except Exception as exc:
            messagebox.showerror("Ошибка проверки", str(exc))
            return
        self.log("Подпись достоверна." if ok else "Подпись НЕ прошла проверку.")
        messagebox.showinfo("Результат", "Подпись достоверна" if ok else "Подпись не прошла проверку")

    def benchmark(self):
        if self.keys is None:
            messagebox.showwarning("Нет ключей", "Сначала сгенерируйте ключи")
            return
        algorithm = self.algorithm.get()
        message = self.message_bytes()
        repeats = 10
        if algorithm == "RSA":
            sig, sign_avg = average_time(rsa_signature.sign, repeats, message, self.keys)
            verify_avg = average_time(rsa_signature.verify, repeats, message, sig, self.keys.public_dict())[1]
        elif algorithm == "ElGamal":
            sig, sign_avg = average_time(elgamal_signature.sign, repeats, message, self.keys)
            verify_avg = average_time(elgamal_signature.verify, repeats, message, sig, self.keys.public_dict())[1]
        else:
            sig, sign_avg = average_time(schnorr_signature.sign, repeats, message, self.keys)
            verify_avg = average_time(schnorr_signature.verify, repeats, message, sig, self.keys.public_dict())[1]
        self.log(f"Среднее время за {repeats} повторов: подпись = {sign_avg:.6f} сек.; проверка = {verify_avg:.6f} сек.")

    def load_text_file(self):
        path = filedialog.askopenfilename(filetypes=[("Text files", "*.txt"), ("All files", "*.*")])
        if not path:
            return
        with open(path, "r", encoding="utf-8") as f:
            data = f.read()
        self.message_text.delete("1.0", tk.END)
        self.message_text.insert("1.0", data)
        self.log(f"Загружен файл: {path}")

    def save_public_key(self):
        path = filedialog.asksaveasfilename(defaultextension=".json", filetypes=[("JSON", "*.json")])
        if not path:
            return
        with open(path, "w", encoding="utf-8") as f:
            f.write(self.public_text.get("1.0", tk.END).strip())
        self.log(f"Открытый ключ сохранен: {path}")

    def load_public_key(self):
        path = filedialog.askopenfilename(filetypes=[("JSON", "*.json"), ("All files", "*.*")])
        if not path:
            return
        with open(path, "r", encoding="utf-8") as f:
            data = f.read()
        self.public_text.delete("1.0", tk.END)
        self.public_text.insert("1.0", data)
        self.log(f"Открытый ключ загружен: {path}")


if __name__ == "__main__":
    app = SignatureApp()
    app.mainloop()
