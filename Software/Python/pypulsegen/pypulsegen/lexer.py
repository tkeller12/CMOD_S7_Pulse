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

    def get_next_token(self):
        while self.current_char is not None:
            if self.current_char.isspace():
                self.skip_whitespace()
                continue
            if self.current_char.isdigit() or (self.current_char == '.' and (self.pos + 1 < len(self.text) and self.text[self.pos + 1].isdigit())):
                return self.number()
            if self.current_char.isalpha() or self.current_char == '_':
                return self.identifier()
            if self.current_char in '+-*/()':
                char = self.current_char
                self.advance()
                return Token(char, char)
            raise Exception(f"Invalid character: {self.current_char}")
        return Token('EOF', None)


if __name__ == "__main__":
    pulse_program = \
"""
pulse 1.0e-3us
delay tau
"""
    lexer = Lexer(pulse_program)
    token = lexer.get_next_token()
    print(token)
    while token.type != 'EOF':
        token = lexer.get_next_token()
        print(token)