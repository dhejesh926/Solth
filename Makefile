build:
	gcc -O2 -Wall -std=c11     main.c     -lluajit-5.1 -ldl -lm -pthread     -static -o solth
