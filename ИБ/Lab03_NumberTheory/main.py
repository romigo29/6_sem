import math

# ---------- НОД ----------

def gcd(a, b):
    while b != 0:
        a, b = b, a % b
    return a

def gcd_three(a, b, c):
    return gcd(gcd(a, b), c)

# ---------- Проверка на простоту ----------

def is_prime(num):
    if num < 2:
        return False
    for i in range(2, int(math.isqrt(num)) + 1):
        if num % i == 0:
            return False
    return True

# ---------- Простые числа в интервале ----------

def primes_in_range(start, end):
    primes = []
    for num in range(start, end + 1):
        if is_prime(num):
            primes.append(num)
    return primes

# ---------- Каноническое разложение ----------

def prime_factorization(n):
    factors = {}
    divisor = 2
    while divisor * divisor <= n:
        while n % divisor == 0:
            factors[divisor] = factors.get(divisor, 0) + 1
            n //= divisor
        divisor += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors

def format_factorization(factors):
    result = []
    for prime in sorted(factors):
        power = factors[prime]
        if power == 1:
            result.append(str(prime))
        else:
            result.append(f"{prime}^{power}")
    return " · ".join(result)

# ---------- Основная программа ----------

def main():

    m = 587
    n = 621

    print("1. Простые числа в интервале [2, n]:")
    primes_2_n = primes_in_range(2, n)
    print(primes_2_n)
    print("Количество:", len(primes_2_n))
    print("n/ln(n) ≈", n / math.log(n))
    print()

    print("2. Простые числа в интервале [m, n]:")
    primes_m_n = primes_in_range(m, n)
    print(primes_m_n)
    print("Количество:", len(primes_m_n))
    print()

    print("3. Каноническое разложение:")
    factors_m = prime_factorization(m)
    factors_n = prime_factorization(n)
    print(f"{m} =", format_factorization(factors_m))
    print(f"{n} =", format_factorization(factors_n))
    print()

    print("4. Проверка числа m || n на простоту:")
    concatenated = int(str(m) + str(n))
    print("m || n =", concatenated)
    print("Является ли простым:", is_prime(concatenated))
    print()

    print(f"5. НОД({m}, {n}) =", gcd(m, n))

    print("6. НОД двух и трех чисел:")
    a, b, c = 48, 180, 72
    print(f"НОД({m}, {n}) =", gcd(m, n))
    print(f"НОД({a}, {b}, {c}) =", gcd_three(a, b, c))
    print()


if __name__ == "__main__":
    main()