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

// while true {
//     print("user> ", terminator: "")
//     if let input = readLine() {
//         print(rep(input))
//     } else {
//         print("Error reading input")
//     }
// }

func test(test_string: String) {
    tokenize(test_string).forEach { string in
        print(string)
    }
}

test(test_string: "(+ 2 3)")
