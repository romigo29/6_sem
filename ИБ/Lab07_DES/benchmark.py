import time

def measure_speed(func, data, iterations=1000):
    start = time.time()

    for _ in range(iterations):
        func(data)

    end = time.time()
    return end - start