import tkinter as tk
from tkinter import messagebox

from sha256_hasher import read_text_from_file, calculate_sha256
from performance import measure_sha256_performance


def load_text():
    try:
        message = read_text_from_file("text.txt")
        input_text.delete("1.0", tk.END)
        input_text.insert(tk.END, message)
    except FileNotFoundError:
        messagebox.showerror("Ошибка", "Файл text.txt не найден")


def hash_message():
    message = input_text.get("1.0", tk.END).strip()

    if not message:
        messagebox.showwarning("Предупреждение", "Сообщение пустое")
        return

    result = calculate_sha256(message)

    result_text.delete("1.0", tk.END)
    result_text.insert(tk.END, result)


def test_performance():
    message = input_text.get("1.0", tk.END).strip()

    if not message:
        messagebox.showwarning("Предупреждение", "Сообщение пустое")
        return

    iterations = 10000
    total_time, average_time = measure_sha256_performance(message, iterations)

    performance_text.delete("1.0", tk.END)
    performance_text.insert(
        tk.END,
        f"Количество вычислений: {iterations}\n"
        f"Общее время: {total_time:.6f} сек.\n"
        f"Среднее время одного хеширования: {average_time:.10f} сек."
    )


def clear_all():
    input_text.delete("1.0", tk.END)
    result_text.delete("1.0", tk.END)
    performance_text.delete("1.0", tk.END)


root = tk.Tk()
root.title("SHA-256 Hashing Application")
root.geometry("750x600")

title_label = tk.Label(root, text="Алгоритм хеширования SHA-256", font=("Arial", 16))
title_label.pack(pady=10)

input_label = tk.Label(root, text="Входное сообщение из text.txt:")
input_label.pack()

input_text = tk.Text(root, height=10, width=85)
input_text.pack(pady=5)

button_frame = tk.Frame(root)
button_frame.pack(pady=10)

load_button = tk.Button(button_frame, text="Загрузить text.txt", command=load_text)
load_button.grid(row=0, column=0, padx=5)

hash_button = tk.Button(button_frame, text="Вычислить SHA-256", command=hash_message)
hash_button.grid(row=0, column=1, padx=5)

performance_button = tk.Button(button_frame, text="Оценить быстродействие", command=test_performance)
performance_button.grid(row=0, column=2, padx=5)

clear_button = tk.Button(button_frame, text="Очистить", command=clear_all)
clear_button.grid(row=0, column=3, padx=5)

result_label = tk.Label(root, text="Хеш SHA-256:")
result_label.pack()

result_text = tk.Text(root, height=4, width=85)
result_text.pack(pady=5)

performance_label = tk.Label(root, text="Оценка быстродействия:")
performance_label.pack()

performance_text = tk.Text(root, height=5, width=85)
performance_text.pack(pady=5)

load_text()

root.mainloop()