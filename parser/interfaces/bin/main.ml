(*
open Ast

let _ =
  try
    let lexbuf = Lexing.from_channel stdin in
    while true do
      let result = Parser.main Lexer.token lexbuf in
        print_int result; print_newline(); flush stdout
    done
  with Lexer.Eof ->
    exit 0
*)

open Ast

let () =
  let lexbuf = Lexing.from_channel stdin in
  try
    let ast = Parser.main Lexer.token lexbuf in
    (* Use the derived show_program function to print the AST *)
    print_endline (show_program ast)
  with
  | Failure msg ->
    Printf.eprintf "Error: %s\n" msg
  | Parser.Error ->
    Printf.eprintf "Syntax error at position %d\n" (Lexing.lexeme_start lexbuf)