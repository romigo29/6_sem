import hashlib


def read_text_from_file(filename="text.txt"):
    with open(filename, "r", encoding="utf-8") as file:
        return file.read()


def calculate_sha256(message):
    message_bytes = message.encode("utf-8")
    sha256_hash = hashlib.sha256(message_bytes).hexdigest()
    return sha256_hash


def calculate_file_sha256(filename="text.txt"):
    message = read_text_from_file(filename)
    return calculate_sha256(message)