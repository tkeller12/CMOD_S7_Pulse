KEYWORDS = {'delay', 'int', 'float', 'true', 'false', 'if', 'else', 'while', 'for', 'detect', 'time'}
PULSE_KEYWORDS = {'pulse', 'detect'}
TIME_UNITS = {'s', 'ms', 'us', 'ns', 'ps', 'fs'}
FREQ_UNITS = {'Hz', 'kHz', 'MHz', 'GHz', 'THz'}
COMMENTS = {'#'}

class Token:
    def __init__(self, type, value):
        self.type = type
        self.value = value

    def __repr__(self):
        return f"Token({self.type}, {self.value})"

class Lexer:
    def __init__(self, text):
        self.text = text
        self.pos = 0
        self.current_char = self.text[self.pos] if self.text else None

    def advance(self):
        self.pos += 1
        if self.pos < len(self.text):
            self.current_char = self.text[self.pos]
        else:
            self.current_char = None

    def skip_whitespace(self):
        while self.current_char is not None and self.current_char.isspace():
            self.advance()

    def number(self):
        result = ''
        scientific_notation_chars = ['e', 'E', '.', '+', '-']
        while self.current_char is not None and (self.current_char.isdigit() or self.current_char in scientific_notation_chars):
            result += self.current_char
            self.advance()
        return Token('NUMBER', float(result))

    def identifier(self):
        result = ''
        while self.current_char is not None and (self.current_char.isalnum() or self.current_char == '_'):
            result += self.current_char
            self.advance()
        return Token('IDENTIFIER', result)

    def comment(self):
        result = ''
        while self.current_char is not None and self.current_char != '\n':
            result += self.current_char
            self.advance()
        return Token('COMMENT', result.strip())

    def get_next_token(self):
        while self.current_char is not None:
            if self.current_char in COMMENTS:
                self.advance()  # Skip the comment character
                return self.comment()
            if self.current_char.isspace():
                self.skip_whitespace()
                continue
            if self.current_char.isdigit() or (self.current_char == '.' and (self.pos + 1 < len(self.text) and self.text[self.pos + 1].isdigit())):
                return self.number()
            if self.current_char.isalpha() or self.current_char == '_':
                identifier = self.identifier()
                if identifier.value in KEYWORDS:
                    return Token('KEYWORD', identifier.value)
                elif identifier.value in PULSE_KEYWORDS:
                    return Token('KEYWORD', identifier.value)
                elif identifier.value in TIME_UNITS:
                    return Token('TIME_UNIT', identifier.value)
                elif identifier.value in FREQ_UNITS:
                    return Token('FREQ_UNIT', identifier.value)
                return identifier
            if self.current_char in r'+-*/\(\){},[]#':
                char = self.current_char
                self.advance()
                return Token(char, char)
            raise Exception(f"Invalid character: {self.current_char}")
        return Token('EOF', None)

    def tokenize(self):
        tokens = []
        while True:
            token = self.get_next_token()
            tokens.append(token)
            if token.type == 'EOF':
                break
        return tokens

if __name__ == "__main__":
    pulse_program = \
r"""
# this is a comment
time p90, tau

pulse p90
delay tau
pulse 2*p90
delay tau
detect 100 ns
"""
    lexer = Lexer(pulse_program)

    tokens = lexer.tokenize()
    for token in tokens:
        print(token)