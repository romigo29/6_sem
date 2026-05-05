import time
from sha256_hasher import calculate_sha256


def measure_sha256_performance(message, iterations=10000):
    start_time = time.perf_counter()

    for _ in range(iterations):
        calculate_sha256(message)

    end_time = time.perf_counter()

    total_time = end_time - start_time
    average_time = total_time / iterations

    return total_time, average_time