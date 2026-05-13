# config.py
# Общие настройки приложения.

APP_TITLE = "Текстовая стеганография: интервалы и кернинг"

INPUT_TXT = "text.txt"
INPUT_DOCX = "text.docx"
OUTPUT_DOCX = "encoded_output.docx"

# 32 бита в начале контейнера хранят длину скрытого сообщения в байтах.
HEADER_BITS = 32

# Межстрочный интервал задается в twips: 1 пункт = 20 twips.
# 12 pt = 240 twips, 14 pt = 280 twips.
LINE_ZERO_TWIPS = 240
LINE_ONE_TWIPS = 280
LINE_THRESHOLD_TWIPS = 260

# Кернинг/межсимвольный интервал в run задается в twips.
# 0 — обычный интервал, 20 — расширение на 1 pt.
KERNING_ZERO_TWIPS = 0
KERNING_ONE_TWIPS = 20
KERNING_THRESHOLD_TWIPS = 10

# Длина строки при автоматическом разбиении text.txt на абзацы для метода интервалов.
AUTO_LINE_WIDTH = 55
