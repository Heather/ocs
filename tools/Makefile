#
# Build system for ocs library and interpreter
#

# install configuration
CC        ?= cc
CD        ?= cd
RM        ?= rm -f
LS        ?= ls
INSTALL   ?= install
MKDIR     ?= $(INSTALL) -d
RMDIR     ?= rmdir
TAR       ?= tar
DIFF      ?= diff
GREP      ?= grep
FIND      ?= find
SYMLINK   ?= ln -s
PREFIX    ?= /usr/local
BINDIR    ?= $(PREFIX)/bin
LIBDIR    ?= $(PREFIX)/lib
SOLIBDIR  ?= $(PREFIX)/lib
INCDIR    ?= $(PREFIX)/include/ocs
MODDIR    ?= $(PREFIX)/share/ocs
BINMODDIR ?= $(PREFIX)/lib/ocs
MANDIR    ?= $(PREFIX)/share/man/man1
DESTDIR   ?=

include ../Makefile.common

BC_LIB = ocs.cma
N_LIB = ocs.cmxa
C_LIB = ocs.a
OCSAKE = ocsake

BC_OBJS = ocs_error.cmo ocs_port.cmo ocs_vartable.cmo ocs_sym.cmo \
	ocs_env.cmo ocs_char.cmo ocs_complex.cmo ocs_numaux.cmo \
	ocs_num.cmo ocs_numstr.cmo ocs_lex.cmo ocs_misc.cmo ocs_read.cmo \
	ocs_eval.cmo ocs_compile.cmo ocs_contin.cmo ocs_print.cmo \
	ocs_io.cmo ocs_list.cmo ocs_macro.cmo ocs_prim.cmo ocs_string.cmo \
	ocs_vector.cmo ocs_wrap.cmo ocs_top.cmo

N_OBJS = ocs_error.cmx ocs_sym.cmx ocs_vartable.cmx ocs_env.cmx \
	ocs_char.cmx ocs_misc.cmx ocs_compile.cmx ocs_eval.cmx \
	ocs_contin.cmx ocs_port.cmx ocs_complex.cmx ocs_numaux.cmx \
	ocs_num.cmx ocs_numstr.cmx ocs_print.cmx ocs_lex.cmx ocs_read.cmx \
	ocs_io.cmx ocs_list.cmx ocs_macro.cmx ocs_prim.cmx ocs_string.cmx \
	ocs_vector.cmx ocs_wrap.cmx ocs_top.cmx

OCSAKE_OBJS = make.cmx

BCI_OBJS = ocs_main.cmo
BCI = ocscm-bc

win: 
	cp ../cygwin/*.a .
	cp ../cygwin/*.o .
	make all
	
all:
	cp ../*.cmx .
	cp ../*.cmi .
	cp ../*.cmo .
	cp ../*.o .
	make build

build: $(OCSAKE)

native: $(N_LIB)

bytecode: $(BC_LIB)
	
$(N_LIB): $(N_OBJS)
	$(OCAMLOPT) -a -o $(N_LIB) $(N_OBJS)

$(BC_LIB): $(BC_OBJS)
	$(OCAMLC) -a -o $(BC_LIB) $(BC_OBJS)

$(OCSAKE): $(N_LIB) $(OCSAKE_OBJS)
	$(OCAMLOPT) -o ../$(OCSAKE) nums.cmxa unix.cmxa $(N_LIB) $(OCSAKE_OBJS)

$(BCI): $(BC_LIB) $(BCI_OBJS)
	$(OCAMLC) $(OCAMLFLAGS) -o $(BCI) nums.cma unix.cma $(BC_LIB) $(BCI_OBJS)

clean:
	-rm -f $(N_LIB) $(BC_LIB) $(C_LIB) $(INTERP) $(TEST) *.cm* *.o *.a *.exe
	-rm -f $(BCI)

depend:
	$(OCAMLDEP) *.ml *.mli > ../.depend

include ../.depend

