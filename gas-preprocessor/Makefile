
CROSS=arm-linux-gnueabihf-

test:
	./gas-preprocessor.pl -as-type gas -- $(CROSS)gcc -c test.S -o test.o
	$(CROSS)objdump -d test.o > disasm
	$(CROSS)gcc -c test.S -o test.o
	$(CROSS)objdump -d test.o > disasm-ref
	diff -u disasm-ref disasm

clean:
	rm -f test.o disasm disasm-ref
