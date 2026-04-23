# ui.py
import tkinter as tk
from tkinter import ttk, messagebox

from crypto_utils import generate_keys, encrypt_blocks, decrypt_blocks
from encoding_utils import (
    text_to_blocks,
    blocks_to_text,
    required_block_size,
    fit_blocks_to_length,
    trim_blocks_to_base_size,
)
from benchmark import measure_encrypt_decrypt, run_scaling_analysis

DEFAULT_MESSAGE = "Romanov Igor Vyacheslavovich"

class CryptoApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Лабораторная работа № 7 - ранцевый шифр")
        self.geometry("1180x820")

        self.keys = None
        self.cipher_values = None
        self.last_fitted_blocks = None

        self.encoding_var = tk.StringVar(value="ASCII")
        self.z_var = tk.StringVar(value="8")
        self.message_var = tk.StringVar(value=DEFAULT_MESSAGE)

        self._build_ui()
        self._sync_z_with_encoding()

    def _build_ui(self):
        top = ttk.Frame(self, padding=10)
        top.pack(fill="x")

        ttk.Label(top, text="Таблица кодировки:").grid(row=0, column=0, sticky="w", padx=5, pady=5)
        encoding_box = ttk.Combobox(
            top,
            textvariable=self.encoding_var,
            values=["ASCII", "BASE64"],
            state="readonly",
            width=12,
        )
        encoding_box.grid(row=0, column=1, sticky="w", padx=5, pady=5)
        encoding_box.bind("<<ComboboxSelected>>", lambda e: self._sync_z_with_encoding())

        ttk.Label(top, text="Число элементов z:").grid(row=0, column=2, sticky="w", padx=5, pady=5)
        ttk.Entry(top, textvariable=self.z_var, width=12).grid(row=0, column=3, sticky="w", padx=5, pady=5)

        ttk.Label(top, text="Сообщение:").grid(row=1, column=0, sticky="w", padx=5, pady=5)
        ttk.Entry(top, textvariable=self.message_var, width=70).grid(row=1, column=1, columnspan=3, sticky="we", padx=5, pady=5)

        buttons = ttk.Frame(self, padding=(10, 0, 10, 10))
        buttons.pack(fill="x")

        ttk.Button(buttons, text="Сгенерировать ключи", command=self.generate).pack(side="left", padx=5)
        ttk.Button(buttons, text="Зашифровать", command=self.encrypt).pack(side="left", padx=5)
        ttk.Button(buttons, text="Расшифровать", command=self.decrypt).pack(side="left", padx=5)
        ttk.Button(buttons, text="Оценить время", command=self.measure_single_run).pack(side="left", padx=5)
        ttk.Button(buttons, text="Анализ роста времени", command=self.run_analysis).pack(side="left", padx=5)
        ttk.Button(buttons, text="Очистить", command=self.clear_outputs).pack(side="left", padx=5)

        panes = ttk.PanedWindow(self, orient="vertical")
        panes.pack(fill="both", expand=True, padx=10, pady=10)

        key_frame = ttk.Labelframe(panes, text="Ключевая информация")
        panes.add(key_frame, weight=1)

        self.keys_text = tk.Text(key_frame, height=14, wrap="word")
        self.keys_text.pack(fill="both", expand=True, padx=5, pady=5)

        result_frame = ttk.Labelframe(panes, text="Шифрование и расшифрование")
        panes.add(result_frame, weight=2)

        self.result_text = tk.Text(result_frame, height=18, wrap="word")
        self.result_text.pack(fill="both", expand=True, padx=5, pady=5)

        analysis_frame = ttk.Labelframe(panes, text="Результаты эксперимента")
        panes.add(analysis_frame, weight=2)

        self.analysis_text = tk.Text(analysis_frame, height=16, wrap="word")
        self.analysis_text.pack(fill="both", expand=True, padx=5, pady=5)

    def _sync_z_with_encoding(self):
        mode = self.encoding_var.get().upper()
        self.z_var.set(str(required_block_size(mode)))

    def _validate_z(self) -> int:
        try:
            z = int(self.z_var.get())
        except ValueError:
            raise ValueError("Число элементов z должно быть целым числом.")

        base_size = required_block_size(self.encoding_var.get().upper())
        if z < base_size:
            raise ValueError(f"Для выбранной кодировки z должно быть не меньше {base_size}.")

        return z

    def generate(self):
        try:
            z = self._validate_z()
            self.keys = generate_keys(z)
            self.cipher_values = None
            self.last_fitted_blocks = None

            self.keys_text.delete("1.0", tk.END)
            self.keys_text.insert(tk.END, f"Режим кодировки: {self.encoding_var.get()}\n")
            self.keys_text.insert(tk.END, f"z = {z}\n\n")
            self.keys_text.insert(tk.END, "Тайный ключ d (сверхвозрастающая последовательность):\n")
            self.keys_text.insert(tk.END, f"{self.keys['secret_key']}\n\n")
            self.keys_text.insert(tk.END, f"n = {self.keys['n']}\n")
            self.keys_text.insert(tk.END, f"a = {self.keys['a']}\n\n")
            self.keys_text.insert(tk.END, "Открытый ключ e (нормальная последовательность):\n")
            self.keys_text.insert(tk.END, f"{self.keys['open_key']}\n")
        except Exception as e:
            messagebox.showerror("Ошибка", str(e))

    def encrypt(self):
        try:
            if self.keys is None:
                self.generate()

            message = self.message_var.get()
            mode = self.encoding_var.get().upper()
            z = self._validate_z()

            blocks = text_to_blocks(message, mode)
            fitted_blocks = fit_blocks_to_length(blocks, z)

            self.cipher_values = encrypt_blocks(fitted_blocks, self.keys["open_key"])
            self.last_fitted_blocks = fitted_blocks

            self.result_text.delete("1.0", tk.END)
            self.result_text.insert(tk.END, f"Исходное сообщение:\n{message}\n\n")
            self.result_text.insert(tk.END, f"Блоки после кодирования ({mode}):\n{blocks}\n\n")
            self.result_text.insert(tk.END, f"Блоки, согласованные с z = {z}:\n{fitted_blocks}\n\n")
            self.result_text.insert(tk.END, "Шифртекст:\n")
            self.result_text.insert(tk.END, " ".join(map(str, self.cipher_values)))
            self.result_text.insert(tk.END, "\n")
        except Exception as e:
            messagebox.showerror("Ошибка", str(e))

    def decrypt(self):
        try:
            if self.keys is None or self.cipher_values is None:
                raise ValueError("Сначала нужно сгенерировать ключи и выполнить шифрование.")

            mode = self.encoding_var.get().upper()
            recovered_blocks = decrypt_blocks(
                self.cipher_values,
                self.keys["secret_key"],
                self.keys["n"],
                self.keys["a"],
            )
            trimmed_blocks = trim_blocks_to_base_size(recovered_blocks, mode)
            text = blocks_to_text(trimmed_blocks, mode)

            self.result_text.insert(tk.END, "\nБлоки после расшифрования:\n")
            self.result_text.insert(tk.END, f"{recovered_blocks}\n\n")
            self.result_text.insert(tk.END, "Информационные биты блока:\n")
            self.result_text.insert(tk.END, f"{trimmed_blocks}\n\n")
            self.result_text.insert(tk.END, "Расшифрованное сообщение:\n")
            self.result_text.insert(tk.END, text + "\n")
        except Exception as e:
            messagebox.showerror("Ошибка", str(e))

    def measure_single_run(self):
        try:
            message = self.message_var.get()
            mode = self.encoding_var.get().upper()
            z = self._validate_z()

            timings = measure_encrypt_decrypt(message, mode, z)

            self.analysis_text.delete("1.0", tk.END)
            self.analysis_text.insert(tk.END, "Среднее время по серии запусков:\n\n")
            self.analysis_text.insert(tk.END, f"Кодировка: {mode}\n")
            self.analysis_text.insert(tk.END, f"z = {z}\n")
            self.analysis_text.insert(tk.END, f"Зашифрование: {timings['encrypt_ms']:.6f} мс\n")
            self.analysis_text.insert(tk.END, f"Расшифрование: {timings['decrypt_ms']:.6f} мс\n")
        except Exception as e:
            messagebox.showerror("Ошибка", str(e))

    def run_analysis(self):
        try:
            message = self.message_var.get()

            ascii_z_values = [8, 12, 16, 24, 32]
            base64_z_values = [6, 8, 12, 16, 24]

            ascii_results = run_scaling_analysis(message, "ASCII", ascii_z_values)
            base64_results = run_scaling_analysis(message, "BASE64", base64_z_values)

            self.analysis_text.delete("1.0", tk.END)
            self.analysis_text.insert(tk.END, "Изменение времени при увеличении числа элементов последовательности:\n\n")

            self.analysis_text.insert(tk.END, "ASCII\n")
            self.analysis_text.insert(tk.END, "z\tЗашифрование, мс\tРасшифрование, мс\n")
            for item in ascii_results:
                self.analysis_text.insert(
                    tk.END,
                    f"{item['z']}\t{item['encrypt_ms']:.6f}\t{item['decrypt_ms']:.6f}\n"
                )

            self.analysis_text.insert(tk.END, "\nBASE64\n")
            self.analysis_text.insert(tk.END, "z\tЗашифрование, мс\tРасшифрование, мс\n")
            for item in base64_results:
                self.analysis_text.insert(
                    tk.END,
                    f"{item['z']}\t{item['encrypt_ms']:.6f}\t{item['decrypt_ms']:.6f}\n"
                )

        except Exception as e:
            messagebox.showerror("Ошибка", str(e))

    def clear_outputs(self):
        self.keys_text.delete("1.0", tk.END)
        self.result_text.delete("1.0", tk.END)
        self.analysis_text.delete("1.0", tk.END)
        self.keys = None
        self.cipher_values = None
        self.last_fitted_blocks = None