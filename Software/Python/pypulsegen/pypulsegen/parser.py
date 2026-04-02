from pypulsegen.lexer import PULSE_KEYWORDS


try:
    from .lexer import Lexer, Token
except:
    from lexer import Lexer, Token

TIME_UNITS = {'s': 1, 'ms': 1e-3, 'us': 1e-6, 'ns': 1e-9, 'ps': 1e-12, 'fs': 1e-15}
DEFALT_TIME_UNIT = 's'

class TimeDefinitionNode:
    def __init__(self, name):
        self.name = name

    def __repr__(self):
        return f"TimeDefinitionNode(name={self.name})"

class IdentifierNode:
    def __init__(self, duration):
        self.duration = duration

    def __repr__(self):
        return f"IdentifierNode(duration={self.duration})"

class NumberNode:
    def __init__(self, duration):
        self.duration = duration

    def __repr__(self):
        return f"NumberNode(duration={self.duration})"

class PulseNode:
    def __init__(self, name, duration):
        self.name = name
        self.duration = duration

    def __repr__(self):
        return f"PulseNode(name={self.name}, duration={self.duration})"

class DelayNode:
    def __init__(self, duration):
        self.duration = duration

    def __repr__(self):
        return f"DelayNode(duration={self.duration})"

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
        nodes = []
        if not isinstance(self.current_token, Token):
            raise Exception(f"Expected a type {type(Token)}, instead got {type(self.current_token)}")

        while self.current_token.type != 'EOF':
            if self.current_token.type == 'KEYWORD' and self.current_token.value in PULSE_KEYWORDS:
                node = self.parse_pulse()
                nodes.append(node)
            elif self.current_token.type == 'KEYWORD' and self.current_token.value == 'delay':
                node = self.parse_delay()
                nodes.append(node)
            elif self.current_token.type == 'KEYWORD' and self.current_token.value == 'time':
                time_definition_nodes = self.parse_time_definition()
                for node in time_definition_nodes:
                    nodes.append(node)
            elif self.current_token.type == 'COMMENT':
                self.advance()  # Skip comments
            else:
                raise Exception(f"Unexpected token: {self.current_token}")
        return nodes

    def parse_time_definition(self):
        self.eat('KEYWORD')  # eat 'time'
        time_definition_nodes = []
        name = self.eat('IDENTIFIER')  # eat time name
        node = TimeDefinitionNode(name.value)  # Create a TimeDefinitionNode with the name and a placeholder for value
        time_definition_nodes.append(node)
        while self.current_token is not None and self.current_token.type == ',':
            self.eat(',')  # eat comma
            if self.current_token is not None and self.current_token.type == 'IDENTIFIER':
                name = self.eat('IDENTIFIER').value  # eat time value (could be a number or another identifier)
                time_definition_nodes.append(TimeDefinitionNode(name))
        return time_definition_nodes

    def parse_pulse(self):
        name = self.eat('KEYWORD')  # eat 'pulse'
        if self.current_token is not None and self.current_token.type == 'NUMBER':
            duration = self.eat('NUMBER').value  # eat duration
            time_unit = self.parse_time_unit()  # eat time unit, if present
            duration_node = NumberNode(duration*TIME_UNITS[time_unit])
            return PulseNode(name.value, duration_node)
        elif self.current_token is not None and self.current_token.type == 'IDENTIFIER':
            duration = self.eat('IDENTIFIER').value  # eat pulse name
            duration_node = IdentifierNode(duration)
            return PulseNode(name.value, duration_node)
        else:
            raise Exception(f"Unexpected token: {self.current_token}, expected NUMBER or IDENTIFIER")


    def parse_delay(self):
        self.eat('KEYWORD')  # eat 'delay'
        if self.current_token is not None and self.current_token.type == 'NUMBER':
            delay = self.eat('NUMBER').value  # eat 'tau'
            time_unit = self.parse_time_unit()  # eat time unit, if present
            delay_node = NumberNode(delay*TIME_UNITS[time_unit])
            return DelayNode(delay_node)
        elif self.current_token is not None and self.current_token.type == 'IDENTIFIER':
            name = self.eat('IDENTIFIER').value  # eat 'tau'
            time_unit = self.parse_time_unit()  # eat time unit, if present
            delay_node = IdentifierNode(name)
            return DelayNode(delay_node)
        else:
            raise Exception(f"Unexpected token: {self.current_token}, expected NUMBER or IDENTIFIER")


    def parse_time_unit(self):
        if not isinstance(self.current_token, Token):
            raise Exception(f"Expected a type {type(Token)}, instead got {type(self.current_token)}")

        if self.current_token.type == 'TIME_UNIT':
            time_unit = self.eat('TIME_UNIT').value  # eat time unit
        else:
            time_unit = DEFALT_TIME_UNIT
        return time_unit


if __name__ == "__main__":
    pulse_program = \
"""
time tau, p1 # this is a comment
time p90

pulse 8.0ns
delay tau
pulse p1
delay 100 ns
pulse p90

delay 1
pulse 200 ms
detect 100 ns
"""
    lexer = Lexer(pulse_program)

    tokens = lexer.tokenize()
    print('Tokens:')
    for token in tokens:
        print(token)
    
    print('\nParsing Output...')
    parser = Parser(tokens)
    nodes = parser.parse()
    print('\nNodes:')
    for node in nodes:
        print(node)
    print('Done.')
