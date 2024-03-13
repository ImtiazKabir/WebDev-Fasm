all:
	gcc constants.c -o const
	./const > constants.asm
	fasm main.asm
