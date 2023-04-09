#*******************************************************************************************
# Makefile
#
# Created by: Erik van der Tier
# on: 2023-04-09
#*******************************************************************************************
NAME = 	demo
ADDR = 	0000
OUTDIR = build
BLD_NAME = $(OUTDIR)/$(NAME).bin

SRC = 	src/main.asm \
		src/system.asm \
		src/tiles.asm \
		src/defs/interrupt.asm \
		src/defs/tinyvicky.asm \
		src/defs/io.asm 
		
OPTS = 	--long-address -b -fc

$(BLD_NAME): $(SRC)
		64tass $(OPTS) $(SRC) -o $@ --list $(basename $@).lst --labels=$(basename $@).lbl

up: 	$(BLD_NAME)
		upload $(BLD_NAME) $(ADDR)

clean:
		rm $(OUTDIR)/*

.PHONY: up clean