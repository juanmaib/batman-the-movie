
.SILENT:

X64 = x64sc
all: the_app 

the_app:
#	cl65 -d -g -Ln map-browser.sym -u __EXEHDR__ -t c64 -o map-browser.prg -C map-browser.cfg map-browser.s map-utility.s --include-dir "C:\Program Files (x86)\cc65\asminc"
	cl65 -d -g -Ln map-browser.sym  -u __EXEHDR__  -t c64 -o raw.prg -C map-browser.cfg map-browser.s map-utility.s --include-dir "C:\Program Files (x86)\cc65\asminc"
	exomizer sfx 0x80d  raw.prg -t 64 -o level1-map.prg -x2 -y'.byte(20,20,20,20,31,70,76,84)'  -Di_line_number=1989
	$(X64) -moncommands map-browser.sym level1-map.prg

 


#koala:
#	cl65 -d -g -Ln koala.sym -u __EXEHDR__ -t c64 -o koala.prg -C koala.cfg koala.s
#	$(X64) -moncommands koala.sym koala.prg

clean:
	del -f *~ *.o *.prg *.sym
