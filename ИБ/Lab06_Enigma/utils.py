def get_rotors():
    rotor_VIII = "FKQHTLXOCBJSPDZRAMEWNIUYGV"
    rotor_II   = "AJDKSIRUXBLHWTMCQGZNPYFVOE"
    rotor_IV   = "ESOVPZJAYQUIRHXLNFTGKDCMWB"

    return rotor_VIII, rotor_II, rotor_IV


def get_reflector_B():
    return {
        'A':'Y','B':'R','C':'U','D':'H','E':'Q','F':'S',
        'G':'L','H':'D','I':'P','J':'X','K':'N','L':'G',
        'M':'O','N':'K','O':'M','P':'I','Q':'E','R':'B',
        'S':'F','T':'Z','U':'C','V':'W','W':'V','X':'J',
        'Y':'A','Z':'T'
    }