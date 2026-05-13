# gui.py
# Графический интерфейс приложения на tkinter.

import os
import tkinter as tk
from tkinter import ttk, messagebox, filedialog
from docx import Document

from config import APP_TITLE, OUTPUT_DOCX
from docx_stego import (
    encode_by_line_spacing,
    decode_by_line_spacing,
    encode_by_kerning,
    decode_by_kerning,
    get_capacity,
)
from file_service import load_container_document, save_document


class StegoApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title(APP_TITLE)
        self.geometry("820x620")
        self.resizable(False, False)

        self.method_var = tk.StringVar(value="kerning")
        self.status_var = tk.StringVar(value="Готово к работе.")

        self._build_ui()

    def _build_ui(self):
        root = ttk.Frame(self, padding=12)
        root.pack(fill=tk.BOTH, expand=True)

        title = ttk.Label(
            root,
            text="Текстовая стеганография на основе пространственно-геометрических параметров",
            font=("Segoe UI", 13, "bold"),
        )
        title.pack(anchor="w", pady=(0, 10))

        method_frame = ttk.LabelFrame(root, text="Метод внедрения", padding=10)
        method_frame.pack(fill=tk.X, pady=(0, 10))

        ttk.Radiobutton(
            method_frame,
            text="Модификация кернинга / межсимвольного интервала",
            variable=self.method_var,
            value="kerning",
        ).pack(anchor="w")

        ttk.Radiobutton(
            method_frame,
            text="Модификация расстояния между строками",
            variable=self.method_var,
            value="line_spacing",
        ).pack(anchor="w")

        message_frame = ttk.LabelFrame(root, text="Скрываемое сообщение", padding=10)
        message_frame.pack(fill=tk.BOTH, expand=True, pady=(0, 10))

        self.message_text = tk.Text(message_frame, height=8, wrap="word")
        self.message_text.pack(fill=tk.BOTH, expand=True)

        button_frame = ttk.Frame(root)
        button_frame.pack(fill=tk.X, pady=(0, 10))

        ttk.Button(button_frame, text="Показать емкость", command=self.show_capacity).pack(side=tk.LEFT, padx=(0, 8))
        ttk.Button(button_frame, text="Встроить сообщение", command=self.encode_message).pack(side=tk.LEFT, padx=(0, 8))
        ttk.Button(button_frame, text="Извлечь из DOCX", command=self.decode_message).pack(side=tk.LEFT, padx=(0, 8))
        ttk.Button(button_frame, text="Очистить", command=self.clear_fields).pack(side=tk.LEFT)

        result_frame = ttk.LabelFrame(root, text="Результат", padding=10)
        result_frame.pack(fill=tk.BOTH, expand=True, pady=(0, 10))

        self.result_text = tk.Text(result_frame, height=10, wrap="word")
        self.result_text.pack(fill=tk.BOTH, expand=True)

        status = ttk.Label(root, textvariable=self.status_var, anchor="w")
        status.pack(fill=tk.X)

    def _selected_method(self) -> str:
        return self.method_var.get()

    def _write_result(self, text: str):
        self.result_text.delete("1.0", tk.END)
        self.result_text.insert(tk.END, text)

    def show_capacity(self):
        try:
            method = self._selected_method()
            doc = load_container_document(for_line_spacing=(method == "line_spacing"))
            capacity = get_capacity(doc, method)
            method_name = "межстрочный интервал" if method == "line_spacing" else "кернинг"
            self._write_result(f"Метод: {method_name}\nПримерная емкость контейнера: {capacity} байт.")
            self.status_var.set("Емкость рассчитана.")
        except Exception as error:
            messagebox.showerror("Ошибка", str(error))

    def encode_message(self):
        try:
            message = self.message_text.get("1.0", tk.END).strip()
            if not message:
                raise ValueError("Введите скрываемое сообщение.")

            method = self._selected_method()
            doc = load_container_document(for_line_spacing=(method == "line_spacing"))

            if method == "line_spacing":
                encoded_doc = encode_by_line_spacing(doc, message)
            else:
                encoded_doc = encode_by_kerning(doc, message)

            output_path = save_document(encoded_doc, OUTPUT_DOCX)
            self._write_result(
                "Сообщение успешно встроено.\n"
                f"Выходной файл: {output_path}\n\n"
                "Для проверки нажмите «Извлечь из DOCX» и выберите созданный файл."
            )
            self.status_var.set("Сообщение встроено в DOCX.")
        except Exception as error:
            messagebox.showerror("Ошибка", str(error))

    def decode_message(self):
        try:
            file_path = filedialog.askopenfilename(
                title="Выберите DOCX со скрытым сообщением",
                filetypes=[("Word document", "*.docx")],
            )

            if not file_path:
                return

            method = self._selected_method()
            doc = Document(file_path)

            if method == "line_spacing":
                message = decode_by_line_spacing(doc)
            else:
                message = decode_by_kerning(doc)

            self._write_result("Извлеченное сообщение:\n\n" + message)
            self.status_var.set(f"Сообщение извлечено из {os.path.basename(file_path)}.")
        except Exception as error:
            messagebox.showerror("Ошибка", str(error))

    def clear_fields(self):
        self.message_text.delete("1.0", tk.END)
        self.result_text.delete("1.0", tk.END)
        self.status_var.set("Поля очищены.")
