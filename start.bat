flex scanner.fl
pause
bison parser.y -d
pause
gcc lex.yy.c parser.tab.c st.c
pause
a.exe < input2.txt
pause
