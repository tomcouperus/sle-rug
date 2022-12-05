# Instructions
1. Open the rascal terminal.
2. `import Syntax;`
3. `import IDE;`
4. `import ParseTree;`
5. `loc binPath = |project://sle-rug/examples/binary.myql|;`
6. `loc cycPath = |project://sle-rug/examples/cyclic.myql|;`
7. `loc taxPath = |project://sle-rug/examples/tax.myql|;`
8. `start[Form] binsf = parse(#start[Form], binPath);`
9. `start[Form] cycsf = parse(#start[Form], cycPath);`
10. `start[Form] taxsf = parse(#start[Form], taxPath);`
11. `import CST2AST;`
12. `cst2ast(binsf);`
13. `cst2ast(cycsf);`
14. `cst2ast(taxsf);`


# Tests
```test bool function = ast_node := cst2ast;```
Then run it with `:test`
