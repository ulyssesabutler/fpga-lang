type identifier = string

type parameter_value = int
type parameter_type = Integer
type parameter_definition = identifier * parameter_type
type generic_interface_definition = identifier

(* INTERFACE EXPRESSIONS *)
type array_bounds_specifier

type interface_expression =
  | Wire
  | DeclaredInterface of declared_interface_expression
  | VectorInterface of vector_interface_expression
  | GenericInterface of identifier
and declared_interface_expression = identifier * interface_expression list * parameter_value list
and vector_interface_expression = interface_expression * array_bounds_specifier

(* INTERFACE DEFINITIONS *)
type record_interface_ports = identifier * interface_expression

type interface_definition =
  | AliasInterface of identifier * generic_interface_definition list * parameter_definition list * interface_expression
  | RecordInterface of identifier * generic_interface_definition list * parameter_definition list * declared_interface_expression list * record_interface_ports list