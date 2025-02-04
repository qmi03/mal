//  If the target language has object types (OOP), then the next step
//  is to create a simple stateful Reader object in `reader.qx`. This
//  object will store the tokens and a position. The Reader object will
//  have two methods: `next` and `peek`. `next` returns the token at
//  the current position and increments the position. `peek` just
//  returns the token at the current position.
struct Reader {
    var tokens: [String]
    var position = 0
    mutating func next() -> String {
        position += 1
        return tokens[position]
    }

    func peek() -> String {
        return tokens[position]
    }
}

//  Add a function `read_str` in `reader.qx`. This function
//   will call `tokenize` and then create a new Reader object instance
//   with the tokens. Then it will call `read_form` with the Reader
//   instance.
func read_str(string: String) {
    let tokens = tokenize(string: string)
    let reader = Reader(
        tokens: tokens
    )
    read_form(reader: reader)
}

//  Add a function `tokenize` in `reader.qx`. This function will take
//   a single string and return an array/list
//   of all the tokens (strings) in it. The following regular expression
//   (PCRE) will match all mal tokens.

func tokenize(string: String) -> [String] {
    let qmal_pattern = /[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"?|;.*|[^\s\[\]{}('"`,;)]*)/
    let matches = string.matches(of: qmal_pattern)

    return matches.compactMap { match in
        String(match.1)
    }
}

func read_form(reader _: Reader) {}
