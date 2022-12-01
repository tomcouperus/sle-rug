module AST

/*
 * Define Abstract Syntax for QL
 *
 * - complete the following data types
 * - make sure there is an almost one-to-one correspondence with the grammar
 */

data AForm(loc src = |tmp:///|)
  = form(str name, list[AQuestion] questions)
  ; 

data AQuestion(loc src = |tmp:///|)
  = question(str prompt, AId id, AType idtype)
  | calculated(str prompt, AId id, AType idtype, AExpr expr)
  | ifelse(AExpr expr, list[AQuestion] ifs, list[AQuestion] elses)
  ; 

data AExpr(loc src = |tmp:///|)
  = unop(AUnOperator unop, AExpr rhs)
  | binop(AExpr lhs, ABinOperator binop, AExpr rhs)
  | ref(AId id)
  | lit(ALiteral literal)
  ;

data AUnOperator(loc src = |tmp:///|)
  = uNot()
  | uMinus()
  ;

data ABinOperator(loc src = |tmp:///|)
  = mult()
  | modulo()
  | div()
  | add()
  | bMinus()
  | less()
  | leq()
  | greater()
  | geq()
  | eq()
  | neq()
  | land()
  | lor()
  ;

data ALiteral(loc src = |tmp:///|)
  = strLit(str string)
  | intLit(int number)
  | boolLit(bool boolean)
  ;


data AId(loc src = |tmp:///|)
  = id(str name)
  ;

data AType(loc src = |tmp:///|)
  = strType()
  | intType()
  | boolType()
  ;