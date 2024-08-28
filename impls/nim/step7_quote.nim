import rdstdin, tables, sequtils, os, types, reader, printer, env, core

proc read(str: string): MalType = str.read_str

proc quasiquote(ast: MalType): MalType

proc quasiquote_loop(xs: seq[MalType]): MalType =
  result = list()
  for i in countdown(xs.high, 0):
    var elt = xs[i]
    if elt.kind == List and 0 < elt.list.len and elt.list[0] == symbol "splice-unquote":
      result = list(symbol "concat", elt.list[1], result)
    else:
      result = list(symbol "cons", quasiquote(elt), result)

proc quasiquote(ast: MalType): MalType =
  case ast.kind
  of List:
    if ast.list.len == 2 and ast.list[0] == symbol "unquote":
      result = ast.list[1]
    else:
      result = quasiquote_loop(ast.list)
  of Vector:
    result = list(symbol "vec", quasiquote_loop(ast.list))
  of Symbol:
    result = list(symbol "quote", ast)
  of HashMap:
    result = list(symbol "quote", ast)
  else:
    result = ast

proc eval(ast: MalType, env: Env): MalType =
  var ast = ast
  var env = env

  while true:

    let dbgeval = env.get("DEBUG-EVAL")
    if not (dbgeval.isNil or dbgeval.kind in {Nil, False}):
      echo "EVAL: " & ast.pr_str

    case ast.kind
    of Symbol:
      let val = env.get(ast.str)
      if val.isNil:
        raise newException(ValueError, "'" & ast.str & "' not found")
      return val
    of List:
      discard(nil) # Proceed after the case statement
    of Vector:
      return vector ast.list.mapIt(it.eval(env))
    of HashMap:
      result = hash_map()
      for k, v in ast.hash_map.pairs:
        result.hash_map[k] = v.eval(env)
      return result
    else:
      return ast

    if ast.list.len == 0: return ast

    let a0 = ast.list[0]
    if a0.kind == Symbol:
      case a0.str
      of "def!":
        let
          a1 = ast.list[1]
          a2 = ast.list[2]
        return env.set(a1.str, a2.eval(env))

      of "let*":
        let
          a1 = ast.list[1]
          a2 = ast.list[2]
        var let_env = initEnv(env)
        case a1.kind
        of List, Vector:
          for i in countup(0, a1.list.high, 2):
            let_env.set(a1.list[i].str, a1.list[i+1].eval(let_env))
        else: raise newException(ValueError, "Illegal kind in let*")
        ast = a2
        env = let_env
        continue # TCO

      of "quote":
        return ast.list[1]

      of "quasiquote":
        ast = ast.list[1].quasiquote
        continue # TCO

      of "do":
        let last = ast.list.high
        discard (ast.list[1 ..< last].mapIt(it.eval(env)))
        ast = ast.list[last]
        continue # TCO

      of "if":
        let
          a1 = ast.list[1]
          a2 = ast.list[2]
          cond = a1.eval(env)

        if cond.kind in {Nil, False}:
          if ast.list.len > 3:
            ast = ast.list[3]
            continue # TCO
          else:
            return nilObj
        else:
          ast = a2
          continue # TCO

      of "fn*":
        let
          a1 = ast.list[1]
          a2 = ast.list[2]
        var env2 = env
        let fn = proc(a: varargs[MalType]): MalType =
          var newEnv = initEnv(env2, a1, list(a))
          a2.eval(newEnv)
        return malfun(fn, a2, a1, env)

    let f = eval(a0, env)
    let args = ast.list[1 .. ^1].mapIt(it.eval(env))
    if f.kind == MalFun:
      ast = f.malfun.ast
      env = initEnv(f.malfun.env, f.malfun.params, list(args))
      continue # TCO

    return f.fun(args)

proc print(exp: MalType): string = exp.pr_str

var repl_env = initEnv()

for k, v in ns.items:
  repl_env.set(k, v)
repl_env.set("eval", fun(proc(xs: varargs[MalType]): MalType = eval(xs[0], repl_env)))
var ps = commandLineParams()
repl_env.set("*ARGV*", list((if paramCount() > 1: ps[1..ps.high] else: @[]).map(str)))


# core.nim: defined using nim
proc rep(str: string): string {.discardable.} =
  str.read.eval(repl_env).print

# core.mal: defined using mal itself
rep "(def! not (fn* (a) (if a false true)))"
rep "(def! load-file (fn* (f) (eval (read-string (str \"(do \" (slurp f) \"\nnil)\")))))"

if paramCount() >= 1:
  rep "(load-file \"" & paramStr(1) & "\")"
  quit()

while true:
  try:
    let line = readLineFromStdin("user> ")
    echo line.rep
  except Blank: discard
  except IOError: quit()
  except:
    echo getCurrentExceptionMsg()
    echo getCurrentException().getStackTrace()
