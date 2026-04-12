def prepare_key(user_key: str):
    # берём первые 8 символов
    key = user_key[:8]

    # дополняем если меньше
    key = key.ljust(8, '0')

    # cp1251: 1 байт на кириллический символ → ровно 8 байт для DES
    return key.encode('cp1251')