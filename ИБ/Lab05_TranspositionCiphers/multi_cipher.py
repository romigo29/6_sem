# multi_cipher.py

POLISH_ALPHABET = "AĄBCĆDEĘFGHIJKLŁMNŃOÓPRSŚTUVWXYZŹŻ"
POLISH_ALPHABET += POLISH_ALPHABET.lower()


def get_permutation_indices(key):

    # Сортируем пары (символ, исходный_индекс) по символу, при равенстве — по индексу
    sorted_pairs = sorted(enumerate(key), key=lambda x: x[1])
    # indices[i] = на какую позицию переместится символ из позиции i
    indices = [0] * len(key)
    for new_pos, (old_pos, _) in enumerate(sorted_pairs):
        indices[old_pos] = new_pos
    return indices


def _get_short_block_indices(indices, block_len):
    """
    Для неполного блока (block_len < len(indices)) пересчитывает перестановку,
    оставляя только позиции < block_len и перенумеровывая их.
    """
    if block_len >= len(indices):
        return indices
    # Берём только те пары (позиция -> целевая_позиция), где обе < block_len
    # Фильтруем: оставляем позиции 0..block_len-1, и их целевые позиции
    # пересчитываем с учётом того, что некоторые целевые позиции >= block_len
    sub_indices = [(j, indices[j]) for j in range(block_len)]
    # Сортируем целевые позиции и переназначаем
    targets_sorted = sorted(range(block_len), key=lambda j: indices[j])
    new_indices = [0] * block_len
    for new_pos, j in enumerate(targets_sorted):
        new_indices[j] = new_pos
    return new_indices


def _apply_permutation(block, indices):
    """Применяет перестановку: символ из позиции j переходит в позицию indices[j]."""
    actual_indices = _get_short_block_indices(indices, len(block))
    result = [''] * len(block)
    for j in range(len(block)):
        result[actual_indices[j]] = block[j]
    return ''.join(result)


def _apply_inverse_permutation(block, indices):
    """Применяет обратную перестановку."""
    actual_indices = _get_short_block_indices(indices, len(block))
    result = [''] * len(block)
    for j in range(len(block)):
        result[j] = block[actual_indices[j]]
    return ''.join(result)


def encrypt(text, key1, key2):
    """
    Множественная (двойная) перестановка:
    1. Записываем текст в таблицу по строкам (ширина = len(key1))
    2. Переставляем столбцы по key1
    3. Читаем по строкам — получаем промежуточный текст
    4. Записываем промежуточный текст в таблицу (ширина = len(key2))
    5. Переставляем столбцы по key2
    6. Читаем по строкам — получаем шифротекст
    """
    indices1 = get_permutation_indices(key1)
    indices2 = get_permutation_indices(key2)

    # Первая перестановка по key1
    first_pass = ''
    for i in range(0, len(text), len(key1)):
        block = text[i:i + len(key1)]
        first_pass += _apply_permutation(block, indices1)

    # Вторая перестановка по key2
    second_pass = ''
    for i in range(0, len(first_pass), len(key2)):
        block = first_pass[i:i + len(key2)]
        second_pass += _apply_permutation(block, indices2)

    return second_pass


def decrypt(text, key1, key2):
    """
    Обратная двойная перестановка:
    1. Обратная перестановка по key2
    2. Обратная перестановка по key1
    """
    indices1 = get_permutation_indices(key1)
    indices2 = get_permutation_indices(key2)

    # Обратная вторая перестановка (key2)
    first_pass = ''
    for i in range(0, len(text), len(key2)):
        block = text[i:i + len(key2)]
        first_pass += _apply_inverse_permutation(block, indices2)

    # Обратная первая перестановка (key1)
    second_pass = ''
    for i in range(0, len(first_pass), len(key1)):
        block = first_pass[i:i + len(key1)]
        second_pass += _apply_inverse_permutation(block, indices1)

    return second_pass