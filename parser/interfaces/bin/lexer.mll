{
open Parser        (* The type token is defined in parser.mli *)
exception Eof
}
rule token = parse
    [' ' '\t' '\n']  { token lexbuf }     (* skip whitespace *)
    | "interface"    { INTERFACE }
    | "parameter"    { PARAMETER }
    | "wire"         { WIRE }
    | '('            { PARAN_L }
    | ')'            { PARAN_R }
    | '{'            { CURLY_L }
    | '}'            { CURLY_R }
    | '['            { SQUARE_L }
    | ']'            { SQUARE_R }
    | '<'            { ANGLE_L }
    | '>'            { ANGLE_R }
    | ':'            { COLON }
    | ';'            { SEMI_COLON }
    | ','            { COMMA }

    | '+'            { ADD }
    | '-'            { SUBTRACT }
    | '*'            { MULTIPLY }
    | '/'            { DIVIDE }
    | "=="           { EQUALS }
    | "!="           { NOT_EQUALS }
    | ">="           { GREATER_THAN_EQUALS }
    | "<="           { LESS_THAN_EQUALS }

    | ['0'-'9']+ as digits { INT_LITERAL (int_of_string digits) } (* TODO: Lots. Negative, different bases, etc. *)
    | ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_']* as id { ID id }
    | eof            { EOF }