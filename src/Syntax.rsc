module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form = "form" Id name "{" Question* questions "}"; 

syntax Question 
  = Prompt prompt Id param ":" Type ("=" Expr)?
  | "if" "(" Expr condition ")" "{" Question* ifQuestions "}" ("else" "{" Question* elseQuestions "}")?
  ;

syntax Prompt = "\"" [a-zA-Z0-9?:]+ "\"";

syntax Expr 
  = "(" Expr ")"
  > "!" Expr
  | "-" Expr
  > left (Expr "*" Expr
  | Expr "%" Expr
  | Expr "/" Expr)
  > left (Expr "+" Expr
  | Expr "-" Expr)
  > left (Expr "\<" Expr
  | Expr "\<=" Expr)
  > left (Expr "\>" Expr
  | Expr "\>=" Expr)
  > left (Expr "==" Expr
  | Expr "!=" Expr)
  > left Expr "&&" Expr
  > left Expr "||" Expr
  > Id \ BoolLiteral // true/false are reserved keywords.
  | Literal
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
keyword BoolLiteral = "true" | "false";
