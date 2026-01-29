# ==============================================
#                 Makefile
#  make
#  Author: Shirosaaki
#  Date: 2026-01-29
# =============================================

NAME = ShiroVisor

SRC = $(wildcard src/*.c)

OBJ = $(SRC:.c=.o)

all: $(OBJ) payload.bin bc.bin
	gcc -o $(NAME) $(OBJ)

payload.bin: asm/payload.asm
	nasm -f bin asm/payload.asm -o payload.bin

bc.bin: asm/bc.asm
	nasm -f bin asm/bc.asm -o bc.bin

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME)

re: fclean all

run: all
	./$(NAME)
