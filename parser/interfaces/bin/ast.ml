(* Abstract Syntax Tree for Interfaces *)

type identifier = string
[@@deriving show]

type static_value_expression =
  | Literal of int
  | Variable of identifier
  | Add of static_value_expression * static_value_expression
  | Subtract of static_value_expression * static_value_expression
  | Multiply of static_value_expression * static_value_expression
  | Divide of static_value_expression * static_value_expression
  | Equals of static_value_expression * static_value_expression
  | NotEquals of static_value_expression * static_value_expression
  | GreaterThan of static_value_expression * static_value_expression
  | LessThan of static_value_expression * static_value_expression
  | GreaterThanEquals of static_value_expression * static_value_expression
  | LessThanEquals of static_value_expression * static_value_expression
[@@deriving show]
type parameter_value = static_value_expression
[@@deriving show]
type parameter_type = identifier (* TODO: Should these be reserved words? *)
[@@deriving show]
type parameter_definition = identifier * parameter_type
[@@deriving show]
type generic_interface_definition = identifier
[@@deriving show]

(* INTERFACE EXPRESSIONS *)
type array_bounds_specifier = static_value_expression
[@@deriving show]

type interface_expression =
  | Wire
  | DeclaredInterface of declared_interface_expression
  | VectorInterface of vector_interface_expression
  | GenericInterface of identifier
[@@deriving show]
and declared_interface_expression = identifier * interface_expression list * parameter_value list
[@@deriving show]
and vector_interface_expression = interface_expression * array_bounds_specifier
[@@deriving show]

(* INTERFACE DEFINITIONS *)
type record_interface_ports = identifier * interface_expression
[@@deriving show]

type interface_definition =
  | AliasInterface of alias_interface_definition
  | RecordInterface of record_interface_definition
[@@deriving show]

and alias_interface_definition = identifier * generic_interface_definition list * parameter_definition list * interface_expression
[@@deriving show]
and record_interface_definition = identifier * generic_interface_definition list * parameter_definition list * declared_interface_expression list * record_interface_ports list
[@@deriving show]


(* PROGRAM *)
type program = interface_definition list [@@deriving show]