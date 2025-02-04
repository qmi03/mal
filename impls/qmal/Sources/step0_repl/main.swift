//  Add the 4 trivial functions `READ`, `EVAL`, `PRINT`, and `rep`
//  (read-eval-print). `READ`, `EVAL`, and `PRINT` are basically just
//  stubs that return their first parameter (a string if your target
//  language is a statically typed) and `rep` calls them in order
//  passing the return to the input of the next.
import Foundation

func READ(_ param1: String) -> String {
    param1
}

func EVAL(_ param1: String) -> String {
    param1
}

func PRINT(_ param1: String) -> String {
    print("\(param1)")

    return param1
}

func rep(_ param1: String) {
    _ = PRINT(EVAL(READ(param1)))
}

while true {
    print("user> ", terminator: "")
    if let expr = readLine() {
        rep(expr)
    } else {
        print("Error reading input")
    }
}
