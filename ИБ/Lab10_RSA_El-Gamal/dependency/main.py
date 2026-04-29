import time
import random


def generate_odd_number(bits):
    """
    Генерирует большое нечетное число заданной битовой длины.
    Для лабораторной работы этого достаточно, так как требуется
    число n длиной 1024 или 2048 бит.
    """
    number = random.getrandbits(bits)

    # устанавливаем старший бит, чтобы число точно имело нужную длину
    number |= (1 << (bits - 1))

    # делаем число нечетным
    number |= 1

    return number


def measure_time(a, x, n, repeats=10):
    """
    Измеряет среднее время вычисления y = a^x mod n.
    """
    start = time.perf_counter()

    for _ in range(repeats):
        y = pow(a, x, n)

    end = time.perf_counter()

    return (end - start) / repeats, y



def main():
    # значения a из диапазона от 5 до 35
    a_values = [7, 31]

    # 5–10 значений x, равномерно распределенных по диапазону
    x_values = [
        10**3 + 7,
        10**10 + 19,
        10**25 + 39,
        10**40 + 63,
        10**55 + 75,
        10**70 + 81,
        10**85 + 99,
        10**100 + 267
    ]

    # значения n длиной 1024 и 2048 бит
    n_values = {
        1024: generate_odd_number(1024),
        2048: generate_odd_number(2048)
    }

    print("Результаты измерения времени вычисления y = a^x mod n")
    print("-" * 90)
    print(f"{'a':<5}{'x':<25}{'bits(n)':<10}{'time, sec':<20}{'y mod n':<20}")
    print("-" * 90)

    for a in a_values:
        for bits, n in n_values.items():
            for x in x_values:
                avg_time, y = measure_time(a, x, n)

                print(
                    f"{a:<5}"
                    f"{str(x)[:22] + '...':<25}"
                    f"{bits:<10}"
                    f"{avg_time:<20.10f}"
                    f"{str(y)[:18] + '...':<20}"
                )


if __name__ == "__main__":
    main()