module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form = "form" Id name QuestionBlock; 

syntax QuestionBlock = "{" Question* questions "}";

syntax Question 
  = Prompt prompt Id param ":" Type ("=" Expr)?
  | "if" "(" Expr ")" QuestionBlock ("else" QuestionBlock)?
  ;

syntax Prompt = "\"" [a-zA-Z0-9?:]+ "\"";

syntax Expr 
  = "(" Expr ")"
  > "!" Expr
  > left Expr BinOperator Expr
  | "-" Expr
  > Id \ "true" \ "false" // true/false are reserved keywords.
  | Literal
  ;

syntax BinOperator
  = "*" | "%" | "/"
  > "+" | "-"
  > "\<" | "\<="
  > "\>" | "\>="
  > "==" | "!="
  > "&&"
  > "||"
  ;

syntax Literal
  = IntLiteral
  | BoolLiteral
  | StrLiteral
  ;

syntax Type 
  = Str
  | Int
  | Bool;

lexical Str = "string";
syntax StrLiteral = "\"" ![\"] "\"";

lexical Int = "integer";
syntax IntLiteral = [0-9]+;

lexical Bool = "boolean";
syntax BoolLiteral = "true" | "false";
