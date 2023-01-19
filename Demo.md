# Demo Instructions

## Initial
1. `import ParseTree;`
2. `import Syntax;`
3. `import AST;`
4. `import CST2AST;`
5. `import Resolve;`
6. `import Check;`
7. `import Eval;`
8. `import Compile;`
9. `import Transform;`
10. `import IDE;`
11. `main();`
12. `loc demoPath = |project://sle-rug/examples/demo.myql|;`
13. `start[Form] demoForm = parse(#start[Form], demoPath);`
14. `AForm demoAST = cst2ast(demoForm);`
15. `RefGraph demoRefGraph = resolve(demoAST);`
16. `TEnv demoTEnv = collect(demoAST);`
17. `check(demoAST, demoTEnv, demoRefGraph.useDef);`
18. `VEnv demoVEnv = initialEnv(demoAST);`
19. `compile(demoAST);`
20. `Input demoInput1 = input("int1", vint(69420));`
21. `VEnv demoVEnvAfterInput1 = eval(demoAST, demoInput1, demoVEnv);`
22. `Input demoInput2 = input("bool1", vbool(true));`
23. `VEnv demoVEnvAfterInput2 = eval(demoAST, demoInput2, demoVEnvAfterInput1);`

## Rerun
1. `import ParseTree;`
2. `import Syntax;`
3. `import AST;`
4. `import CST2AST;`
5. `import Resolve;`
6. `import Check;`
7. `import Eval;`
8. `import Compile;`
9. `import Transform;`
10. `import IDE;`
11. `main();`
12. `demoPath = |project://sle-rug/examples/demo.myql|;`
13. `demoForm = parse(#start[Form], demoPath);`
14. `demoAST = cst2ast(demoForm);`
15. `demoRefGraph = resolve(demoAST);`
16. `demoTEnv = collect(demoAST);`
17. `check(demoAST, demoTEnv, demoRefGraph.useDef);`
18. `demoVEnv = initialEnv(demoAST);`
19. `compile(demoAST);`
20. `Input demoInput1 = input("int1", vint(69420));`
21. `VEnv demoVEnvAfterInput1 = eval(demoAST, demoInput1, demoVEnv);`
22. `Input demoInput2 = input("bool1", vbool(true));`
23. `VEnv demoVEnvAfterInput2 = eval(demoAST, demoInput2, demoVEnvAfterInput1);`