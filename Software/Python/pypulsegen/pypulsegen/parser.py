from .lexer import Lexer, Token

class Parser:
    def __init__(self, lexer):
        self.lexer = lexer
        self.current_token = self.lexer.get_next_token()

    def eat(self, token_type):
        if self.current_token.type == token_type:
            self.current_token = self.lexer.get_next_token()
        else:
            raise Exception(f"Unexpected token: {self.current_token}, expected: {token_type}")

    def parse(self):
        while self.current_token.type != 'EOF':
            if self.current_token.type == 'IDENTIFIER' and self.current_token.value == 'pulse':
                self.parse_pulse()
            elif self.current_token.type == 'IDENTIFIER' and self.current_token.value == 'delay':
                self.parse_delay()
            else:
                raise Exception(f"Unexpected token: {self.current_token}")

    def parse_pulse(self):
        self.eat('IDENTIFIER')  # eat 'pulse'
        duration = self.current_token
        self.eat('NUMBER')  # eat duration
        print(f"Parsed pulse with duration: {duration.value}")

    def parse_delay(self):
        self.eat('IDENTIFIER')  # eat 'delay'
        tau = self.current_token
        self.eat('IDENTIFIER')  # eat tau
        print(f"Parsed delay with tau: {tau.value}")