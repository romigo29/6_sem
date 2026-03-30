from rotor import Rotor
from reflector import Reflector
from enigma_machine import EnigmaMachine
from utils import get_rotors, get_reflector_B
from analysis import plot_histogram

message = "Igor Vyacheslavovich Romanov"

rotor_VIII, rotor_II, rotor_IV = get_rotors()
reflector = Reflector(get_reflector_B())

configs = [
    (0,0,0),
    (1,2,3),
    (5,10,15),
    (7,7,7),
    (25,0,13)
]

plot_histogram(message.upper(), "Открытый текст", "original_hist.png")

for i, config in enumerate(configs):
    # --- ШИФРОВАНИЕ ---
    rotors_enc = [
        Rotor(rotor_VIII, notch=0, position=config[0], step_mode=1),
        Rotor(rotor_II, notch=0, position=config[1], step_mode=0),
        Rotor(rotor_IV, notch=0, position=config[2], step_mode=1),
    ]

    machine_enc = EnigmaMachine(rotors_enc, reflector)
    encrypted = machine_enc.encrypt(message)

    # --- ДЕШИФРОВАНИЕ ---
    # ВАЖНО: создаём заново, иначе позиции уже сдвинуты
    rotors_dec = [
        Rotor(rotor_VIII, notch=0, position=config[0], step_mode=1),
        Rotor(rotor_II, notch=0, position=config[1], step_mode=0),
        Rotor(rotor_IV, notch=0, position=config[2], step_mode=1),
    ]

    machine_dec = EnigmaMachine(rotors_dec, reflector)
    decrypted = machine_dec.decrypt(encrypted)

    print(f"Начальные позиции: {config}")
    print(f"Шифртекст: {encrypted}")
    print(f"Дешифровка: {decrypted}")
    print(f"Совпадение: {decrypted == message.upper()}")
    print()

    plot_histogram(
        encrypted,
        f"Шифртекст {config}",
        f"encrypted_hist_{i}.png"
    )