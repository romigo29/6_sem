from config import A, B, P_MOD


POINT_INFINITY = None


def mod_inverse(value, mod):
    value %= mod

    if value == 0:
        raise ZeroDivisionError("Обратный элемент для 0 не существует")

    return pow(value, -1, mod)


def is_on_curve(point):
    if point is POINT_INFINITY:
        return True

    x, y = point

    left = (y ** 2) % P_MOD
    right = (x ** 3 + A * x + B) % P_MOD

    return left == right


def negative_point(point):
    if point is POINT_INFINITY:
        return POINT_INFINITY

    x, y = point
    return x, (-y) % P_MOD


def add_points(point_p, point_q):
    if point_p is POINT_INFINITY:
        return point_q

    if point_q is POINT_INFINITY:
        return point_p

    x1, y1 = point_p
    x2, y2 = point_q

    if x1 == x2 and (y1 + y2) % P_MOD == 0:
        return POINT_INFINITY

    if point_p != point_q:
        numerator = y2 - y1
        denominator = x2 - x1
        lambda_value = numerator * mod_inverse(denominator, P_MOD)
    else:
        numerator = 3 * x1 ** 2 + A
        denominator = 2 * y1
        lambda_value = numerator * mod_inverse(denominator, P_MOD)

    lambda_value %= P_MOD

    x3 = (lambda_value ** 2 - x1 - x2) % P_MOD
    y3 = (lambda_value * (x1 - x3) - y1) % P_MOD

    return x3, y3


def subtract_points(point_p, point_q):
    return add_points(point_p, negative_point(point_q))


def multiply_point(k, point):
    result = POINT_INFINITY
    addend = point

    while k > 0:
        if k % 2 == 1:
            result = add_points(result, addend)

        addend = add_points(addend, addend)
        k //= 2

    return result


def find_points(x_min, x_max):
    result = []

    for x in range(x_min, x_max + 1):
        right_side = (x ** 3 + A * x + B) % P_MOD
        y_values = []

        for y in range(P_MOD):
            if (y ** 2) % P_MOD == right_side:
                y_values.append(y)

        if y_values:
            result.append((x, y_values, right_side))

    return result


def format_point(point):
    if point is POINT_INFINITY:
        return "O"

    return f"({point[0]}, {point[1]})"