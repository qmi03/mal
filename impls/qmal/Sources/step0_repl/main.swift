import Foundation

func READ(_ s: String) -> String {
    s
}

func EVAL(_ s: String) -> String {
    s
}

func PRINT(_ s: String) -> String {
    s
}

func rep(_ s: String) -> String {
    PRINT(EVAL(READ(s)))
}

while true {
    print("user> ", terminator: "")
    if let input = readLine() {
        print(rep(input))
    } else {
        print("Error reading input")
    }
}
