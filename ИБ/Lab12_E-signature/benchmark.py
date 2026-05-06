from time import perf_counter


def measure_once(func, *args, **kwargs):
    start = perf_counter()
    result = func(*args, **kwargs)
    finish = perf_counter()
    return result, finish - start


def average_time(func, repeats: int, *args, **kwargs):
    total = 0.0
    result = None
    for _ in range(repeats):
        start = perf_counter()
        result = func(*args, **kwargs)
        total += perf_counter() - start
    return result, total / repeats
