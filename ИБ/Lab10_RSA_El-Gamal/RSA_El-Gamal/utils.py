import base64
import time


def read_text_from_file(filename="text.txt"):
    with open(filename, "r", encoding="utf-8") as file:
        return file.read()


def text_to_base64(text):
    text_bytes = text.encode("ascii")
    return base64.b64encode(text_bytes).decode("ascii")


def base64_to_text(encoded_text):
    decoded_bytes = base64.b64decode(encoded_text.encode("ascii"))
    return decoded_bytes.decode("ascii")


def measure_time(function, *args):
    start = time.perf_counter()
    result = function(*args)
    end = time.perf_counter()
    return result, end - start