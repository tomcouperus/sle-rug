module Transform

import Syntax;
import Resolve;
import AST;
import ParseTree;

/* 
 * Transforming QL forms
 */
 
 
/* Normalization:
 *  wrt to the semantics of QL the following
 *     q0: "" int; 
 *     if (a) { 
 *        if (b) { 
 *          q1: "" int; 
 *        } 
 *        q2: "" int; 
 *      }
 *
 *  is equivalent to
 *     if (true) q0: "" int;
 *     if (true && a && b) q1: "" int;
 *     if (true && a) q2: "" int;
 *
 * Write a transformation that performs this flattening transformation.
 *
 */
 
AForm flatten(AForm f) {
  list[AQuestion] qs = [];
  for (q <- f.questions) {
    qs += flatten(q, lit(boolLit(true)));
  }
  f.questions = qs;
  return f; 
}

list[AQuestion] flatten(AQuestion q, AExpr cond) {
  list[AQuestion] qs = [];
  switch (q) {
    case question(_,_,_): {
      qs += ifelse(cond, [q], []);
    }
    case calculated(_,_,_,_): {
      qs += ifelse(cond, [q], []);
    }
    case ifelse(AExpr ifcond, list[AQuestion] ifqs, list[AQuestion] elseqs): {
      for (AQuestion ifq <- ifqs) {
        qs += flatten(ifq, binop(cond, land(), ifcond));
      }
      for (AQuestion elseq <- elseqs) {
        qs += flatten(elseq, binop(cond, land(), unop(uNot(), ifcond)));
      }
    }
  }
  return qs;
}

/* Rename refactoring:
 *
 * Write a refactoring transformation that consistently renames all occurrences of the same name.
 * Use the results of name resolution to find the equivalence class of a name.
 *
 */
 
start[Form] rename(start[Form] f, loc useOrDef, str newName, UseDef useDef) {
  set[loc] toRename = {};
  if (useOrDef in useDef<1>) {
    // def
    toRename += useOrDef;
    toRename += {useLoc | <loc useLoc, useOrDef> <- useDef};
  } else if (useOrDef in useDef<0>) {
    // use, so get def and do the same as above here
    if (<useOrDef, loc defLoc> <- useDef) {
      toRename += defLoc;
      toRename += {useLoc | <loc useLoc, defLoc> <- useDef};
    }
  } else {
    return f;
  }

  return visit (f) {
    case Id x => [Id]newName
      when x.src in toRename
  } 
} 
 
 
 

