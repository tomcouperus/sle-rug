# Instructions
1. Open the rascal terminal.
2. `import Syntax;`
3. `import IDE;`
4. `import ParseTree;`
5. `loc taxPath = |project://sle-rug/examples/tax.myql|;`
6. `start[Form] sf = parse(#start[Form], taxPath);`
7. `import CST2AST;`
8. `cst2ast(sf);`


# Tests
```test bool function = ast_node := cst2ast;```
Then run it with `:test`
