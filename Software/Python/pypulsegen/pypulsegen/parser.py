try:
    from .lexer import Lexer, Token
except:
    from lexer import Lexer, Token

TIME_UNITS = ['s', 'ms', 'us', 'ns', 'ps', 'fs']
DEFALT_TIME_UNIT = 's'

class Parser:
    def __init__(self, tokens: list[Token]):
        self.tokens = tokens
        self.pos = 0
        for token in self.tokens:
            if not isinstance(token, Token):
                raise Exception(f"Expected a type {type(Token)}, instead got {type(token)}")

        self.current_token = self.tokens[self.pos]

    def advance(self):
        self.pos += 1
        if self.pos < len(self.tokens):
            self.current_token = self.tokens[self.pos]
        else:
            self.current_token = None

    def eat(self, token_type):
        if self.current_token is None:
            raise Exception(f"Unexpected end of input, expected {token_type}")

        if self.current_token.type == token_type:
            token = self.current_token
            self.advance()
            return token
        else:
            raise Exception(f"Unexpected token: {self.current_token}, expected: {token_type}")

    def parse(self):
        if not isinstance(self.current_token, Token):
            raise Exception(f"Expected a type {type(Token)}, instead got {type(self.current_token)}")

        while self.current_token.type != 'EOF':
            if self.current_token.type == 'IDENTIFIER' and self.current_token.value == 'pulse':
                self.parse_pulse()
            elif self.current_token.type == 'IDENTIFIER' and self.current_token.value == 'delay':
                self.parse_delay()
            else:
                raise Exception(f"Unexpected token: {self.current_token}")

    def parse_pulse(self):
        self.eat('IDENTIFIER')  # eat 'pulse'
        duration = self.eat('NUMBER').value  # eat duration

        time_unit = self.parse_time_unit()  # eat time unit, if present
        print(f"Pulse: {duration} {time_unit}")

    def parse_delay(self):
        self.eat('IDENTIFIER')  # eat 'delay'
        tau = self.eat('IDENTIFIER').value  # eat 'tau'
        time_unit = self.parse_time_unit()  # eat time unit, if present
        print(f"Parsed delay with tau: {tau} {time_unit}")

    def parse_time_unit(self):
        if not isinstance(self.current_token, Token):
            raise Exception(f"Expected a type {type(Token)}, instead got {type(self.current_token)}")

        if self.current_token.type == 'IDENTIFIER' and self.current_token.value in TIME_UNITS:
            time_unit = self.eat('IDENTIFIER').value  # eat time unit
        else:
            time_unit = DEFALT_TIME_UNIT
        # print(f"Parsed time unit: {time_unit}")
        return time_unit


if __name__ == "__main__":
    pulse_program = \
"""
pulse 1.0e-3us
delay tau
"""
    lexer = Lexer(pulse_program)

    tokens = lexer.tokenize()
    print('Tokens:')
    for token in tokens:
        print(token)
    
    print('Parsing Output...')
    parser = Parser(tokens)
    parser.parse()