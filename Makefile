# project: FLP 2023 To mi nedá pokoj
# author: xmikul69
# date: 04/2023
# file: Makefile

INPUT=tests/easy1.test

all:
	swipl -q -g "run(_)" -o flp22-log -O -c pokoj.pl

flp22-log:
	swipl -q -g "run(_)" -o flp22-log -O -c pokoj.pl

flp22-log-naive:
	swipl -q -g "run(_)" -o flp22-log-naive -O -c pokoj_naive.pl

run:
# 	time swipl -s pokoj.pl -g "run()." -t halt.
	time "./flp22-log" < $(INPUT)

clean:
	rm flp22-log || true
	rm flp22-log-naive || true
	rm flp-log-xmikul69.zip || true


zip: clean
	zip -r flp-log-xmikul69.zip Makefile pokoj.pl pokoj_naive.pl tests doc README.md
