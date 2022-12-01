module CST2AST

import Syntax;
import AST;

import ParseTree;
import IO;

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
      return question("<p>", id("<i>"), cst2ast(t));
    case (Question)`<Prompt p> <Id i> : <Type t> = <Expr e>`:
      return calculated("<p>", id("<i>"), cst2ast(t), cst2ast(e));
    case (Question)`if (<Expr cond>) {<Question* ifqs>}`:
      return ifelse(cst2ast(cond), [ cst2ast(q) | q <- ifqs], []);
    case (Question)`if (<Expr cond>) {<Question* ifqs>} else {<Question* elseqs>}`:
      return ifelse(cst2ast(cond), [cst2ast(q) | q <- ifqs], [cst2ast(q) | q <- elseqs]);
    default: throw "Not implemented question format: <q>";
  }
}

AExpr cst2ast(Expr e) {
  switch (e) {
    case (Expr)`<Id x>`: return ref(id("<x>", src=x.src), src=x.src);
    // etc.
    
    default: throw "Unhandled expression: <e>";
  }
}

default AType cst2ast(Type t) {
  throw "Not implemented type: <t>";
}
