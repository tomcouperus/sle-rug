module CST2AST

import Syntax;
import AST;

import ParseTree;
import String;
import Boolean;

/*
 * Implement a mapping from concrete syntax trees (CSTs) to abstract syntax trees (ASTs)
 *
 * - Use switch to do case distinction with concrete patterns (like in Hack your JS) 
 * - Map regular CST arguments (e.g., *, +, ?) to lists 
 *   (NB: you can iterate over * / + arguments using `<-` in comprehensions or for-loops).
 * - Map lexical nodes to Rascal primitive types (bool, int, str)
 * - See the ref example on how to obtain and propagate source locations.
 */

AForm cst2ast(start[Form] sf) {
  Form f = sf.top; // remove layout before and after form
  return form("<f.name>", [ cst2ast(q) | q <- f.questions], src=f.src); 
}

AQuestion cst2ast(Question q) {
  switch(q) {
    case (Question)`<Prompt p> <Id i> : <Type t>`:
      return question(prompt("<p>", src=p.src), id("<i>", src=i.src), cst2ast(t), src=q.src);
    case (Question)`<Prompt p> <Id i> : <Type t> = <Expr e>`:
      return calculated(prompt("<p>", src=p.src), id("<i>", src=i.src), cst2ast(t), cst2ast(e), src=q.src);
    case (Question)`if (<Expr cond>) {<Question* ifqs>}`:
      return ifelse(cst2ast(cond), [ cst2ast(q) | Question q <- ifqs], [], src=q.src);
    case (Question)`if (<Expr cond>) {<Question* ifqs>} else {<Question* elseqs>}`:
      return ifelse(cst2ast(cond), [cst2ast(q) | Question q <- ifqs], [cst2ast(q) | Question q <- elseqs], src=q.src);
    default: throw "Not implemented question format: <q>";
  }
}

AExpr cst2ast(Expr e) {
  switch (e) {
    case (Expr)`(<Expr p>)`: return cst2ast(p);
    case (Expr)`! <Expr rhs>`: return unop(uNot(src=e.src), cst2ast(rhs), src=e.src);
    case (Expr)`- <Expr rhs>`: return unop(uMinus(src=e.src), cst2ast(rhs), src=e.src);
    case (Expr)`<Expr lhs> * <Expr rhs>`: return binop(cst2ast(lhs), mult(src=e.src), cst2ast(rhs), src=e.src);
    case (Expr)`<Expr lhs> % <Expr rhs>`: return binop(cst2ast(lhs), modulo(src=e.src), cst2ast(rhs), src=e.src);
    case (Expr)`<Expr lhs> / <Expr rhs>`: return binop(cst2ast(lhs), div(src=e.src), cst2ast(rhs), src=e.src);
    case (Expr)`<Expr lhs> + <Expr rhs>`: return binop(cst2ast(lhs), add(src=e.src), cst2ast(rhs), src=e.src);
    case (Expr)`<Expr lhs> - <Expr rhs>`: return binop(cst2ast(lhs), bMinus(src=e.src), cst2ast(rhs), src=e.src);
    case (Expr)`<Expr lhs> \< <Expr rhs>`: return binop(cst2ast(lhs), less(src=e.src), cst2ast(rhs), src=e.src);
    case (Expr)`<Expr lhs> \<= <Expr rhs>`: return binop(cst2ast(lhs), leq(src=e.src), cst2ast(rhs), src=e.src);
    case (Expr)`<Expr lhs> \> <Expr rhs>`: return binop(cst2ast(lhs), greater(src=e.src), cst2ast(rhs), src=e.src);
    case (Expr)`<Expr lhs> \>= <Expr rhs>`: return binop(cst2ast(lhs), geq(src=e.src), cst2ast(rhs), src=e.src);
    case (Expr)`<Expr lhs> == <Expr rhs>`: return binop(cst2ast(lhs), eq(src=e.src), cst2ast(rhs), src=e.src);
    case (Expr)`<Expr lhs> != <Expr rhs>`: return binop(cst2ast(lhs), neq(src=e.src), cst2ast(rhs), src=e.src);
    case (Expr)`<Expr lhs> && <Expr rhs>`: return binop(cst2ast(lhs), land(src=e.src), cst2ast(rhs), src=e.src);
    case (Expr)`<Expr lhs> || <Expr rhs>`: return binop(cst2ast(lhs), lor(src=e.src), cst2ast(rhs), src=e.src);
    case (Expr)`<Id x>`: return ref(id("<x>", src=x.src), src=x.src);
    case (Expr)`<StrLiteral sLit>`: return lit(strLit("<sLit>", src=sLit.src), src=sLit.src);
    case (Expr)`<IntLiteral iLit>`: return lit(intLit(toInt("<iLit>"), src=iLit.src), src=iLit.src);
    case (Expr)`<BoolLiteral bLit>`: return lit(boolLit(fromString("<bLit>"), src=bLit.src), src=bLit.src);
    default: throw "Unhandled expression: <e>";
  }
}

AType cst2ast(Type t) {
  switch (t) {
    case (Type)`string`: return strType(src=t.src);
    case (Type)`integer`: return intType(src=t.src);
    case (Type)`boolean`: return boolType(src=t.src);
    default: throw "Not implemented type: <t>";
  }
}
