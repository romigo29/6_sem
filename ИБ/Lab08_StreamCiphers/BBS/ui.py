import tkinter as tk
from bbs import BBS

class BBSApp:
    def __init__(self, root):
        self.root = root
        self.root.title("BBS Generator")

        self.bbs = BBS(383, 503)

        tk.Label(root, text="Количество бит:").pack()

        self.entry = tk.Entry(root)
        self.entry.pack()
        self.entry.insert(0, "512")

        tk.Button(root, text="Генерировать", command=self.generate).pack()

        self.output = tk.Text(root, height=10)
        self.output.pack()

    def format_bits(self, bits):
        # разбиваем по 8 бит
        return ' '.join(bits[i:i+8] for i in range(0, len(bits), 8))

    def generate(self):
        try:
            count = int(self.entry.get())
            bits = self.bbs.generate_bits(count)

            formatted = self.format_bits(bits)

            self.output.delete("1.0", tk.END)
            self.output.insert(tk.END, formatted)

        except ValueError as e:
            self.output.delete("1.0", tk.END)
            self.output.insert(tk.END, f"Ошибка: {str(e)}")