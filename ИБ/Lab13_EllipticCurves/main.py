from config import X_MIN, X_MAX, K, L, P_POINT, Q_POINT, R_POINT
from elliptic_curve import (
    find_points,
    is_on_curve,
    add_points,
    subtract_points,
    multiply_point,
    format_point
)


def print_curve_points():
    print("Точки эллиптической кривой")
    print("E(-1, 1): y^2 = x^3 - x + 1 (mod 751)")
    print(f"Диапазон x: от {X_MIN} до {X_MAX}")
    print()

    points = find_points(X_MIN, X_MAX)

    print("+------+---------+---------+----------------------+")
    print("|  x   |   y1    |   y2    | x^3 - x + 1 mod 751 |")
    print("+------+---------+---------+----------------------+")

    for x, y_values, right_side in points:
        if len(y_values) == 2:
            print(f"| {x:<4} | {y_values[0]:<7} | {y_values[1]:<7} | {right_side:<20} |")
        elif len(y_values) == 1:
            print(f"| {x:<4} | {y_values[0]:<7} | {'-':<7} | {right_side:<20} |")

    print("+------+---------+---------+----------------------+")
    print()


def print_operations():
    p = P_POINT
    q = Q_POINT
    r = R_POINT

    if not is_on_curve(p):
        raise ValueError("Точка P не принадлежит кривой")

    if not is_on_curve(q):
        raise ValueError("Точка Q не принадлежит кривой")

    if not is_on_curve(r):
        raise ValueError("Точка R не принадлежит кривой")

    k_p = multiply_point(K, p)
    l_q = multiply_point(L, q)

    p_plus_q = add_points(p, q)
    expression_1 = subtract_points(add_points(k_p, l_q), r)
    expression_2 = add_points(subtract_points(p, q), r)

    print("Исходные точки и коэффициенты")
    print()
    print(f"P = {format_point(p)}")
    print(f"Q = {format_point(q)}")
    print(f"R = {format_point(r)}")
    print(f"k = {K}")
    print(f"l = {L}")
    print()

    print("Результаты операций")
    print()
    print("+----------------+-------------------------------+")
    print("| Операция       | Результат                     |")
    print("+----------------+-------------------------------+")
    print(f"| kP             | {format_point(k_p):<29} |")
    print(f"| P + Q          | {format_point(p_plus_q):<29} |")
    print(f"| kP + lQ - R    | {format_point(expression_1):<29} |")
    print(f"| P - Q + R      | {format_point(expression_2):<29} |")
    print("+----------------+-------------------------------+")


def main():
    print_curve_points()
    print_operations()


if __name__ == "__main__":
    main()