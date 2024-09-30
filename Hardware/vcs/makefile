# ============================== set verdi env========================= #
export LD_LIBRARY_PATH := ${LD_LIBRARY_PATH}:/app/EDA/Verdi_O-2018.09-SP2/share/PLI/VCS/LINUX64
export NOVAS_HOME := /app/EDA/Verdi_O-2018.09-SP2
#export NOVAS_HOME := /app/synopsys/verdi1606
#export LD_LIBRARY_PATH := ${LD_LIBRARY_PATH}:${NOVAS_HOME}/share/PLI/VCS/LINUX64


PYTHON_DIR  := ~/templates/pyauto
SRC1        := NONE
SRC2        := NONE
DST         := NONE

SIM_DIR     := ${PWD}
RUN_DIR_DCT := ${PWD}/backend/syn/dct
RUN_DIR_FM  := ${PWD}/backend/formality

TOP := topfile
NAME_BP := topfile
DIR_BP  := ${PWD}/backend/syn/backup/${NAME_BP}

SOURCE = NONE
FSDB_NUM = 
CORNER = 
COV  = on
DUMP = on
SIMMODE = RTL
# SIMMODE = RTL or PRESIM or POSTSIM


# ============================== initial VCS_option========================= #
VCS_OPT = -debug_pp -full64 +plusarg_save +v2k -sverilog +evalorder +no_notifier +vc

#======Following modified by Liu Yanghu===============
#VCS random seed control
RADM=auto

#add inculde file directory
INCDIR=+incdir+rtl/
INCDIR+=+incdir+testbench/

#add user specific VCS command options
USER_COM=

VCS_OPT+=$(INCDIR)
VCS_OPT+=$(USER_COM)

#auto means every time vcs has different random seed(vcs automatically chose)
ifeq  ($(RADM),auto)
VCS_OPT += +ntb_random_seed_automatic

else 
#off means random seed is always the same(VCS chose,user not know)
ifeq  ($(RADM),off)
VCS_OPT +=
else
#user specific random seed,must be an integer number
VCS_OPT += +ntb_random_seed=$(RADM) 
endif 
endif
#===================end=============================

ifeq	($(DUMP),on)
VCS_OPT += +define+DUMP
VCS_OPT += +FSDB=fsdb/$(SIMMODE)$(FSDB_NUM).fsdb
VCS_OPT += +DUMP
endif
VCS_OPT += -P $(VERDI_HOME)/share/PLI/VCS/LINUX64/novas.tab \
$(VERDI_HOME)/share/PLI/VCS/LINUX64/pli.a

VCS_OPT += +args=$(args)
# ==========================VCS coverage collection option================= #
ifeq	($(COV),on)
VCS_OPT += -cm_name $(SIMMODE)
#VCS_OPT += -cm_hier ./cfg/hier_file.conf
VCS_OPT += -cm line+cond+fsm
#VCS_OPT += -cm_line contassign
#VCS_OPT += -cm_cond allops+event+anywidth
#VCS_OPT += -cm_ignorepragmas
#VCS_OPT += -cm_noconst
endif

# ==========================select simfile================================ #
ifeq	($(SIMMODE),PRESIM)
SIMFILE = -f simfile/simfile_presim.f
VCS_OPT += +define+PRESIM +notimingcheck
LOG = log/sim/vcs_presim.log
else
ifeq	($(SIMMODE),POSTSIM)
SIMFILE = -f simfile/simfile_postsim.f
VCS_OPT += +define+POSTSIM +neg_tchk -negdelay +define+$(CORNER) +overlap
LOG = log/sim/vcs_postsim.log
else
SIMFILE = -f simfile/simfile_rtl.f
VCS_OPT += +notimingcheck
LOG = log/sim/vcs_rtlsim$(FSDB_NUM).log
endif
endif

# ==========================frontend script command============================== #

nlint:
	nLint -95 -2001 -rs ./nLint/my_nLint.rs -out ./log/nlint/nLint.log -f ./rtl/frontend_file.list

vcs:
	vcs $(VCS_OPT) ./tsk/timescale.v $(SIMFILE) -R |tee $(LOG)

#add by Liu Yanghu,just compile and generare simv,not run
compile:
	vcs $(VCS_OPT) ./tsk/timescale.v $(SIMFILE) |tee $(LOG)

uvm:
	vcs $(VCS_OPT) -ntb_opts uvm -timescale-1ns/1ps $(SIMFILE) |tee ./log/sim/uvm_report.log
	#vcs $(VCS_OPT) -ntb_opts uvm  $(SIMFILE) |tee ./log/sim/uvm_report.log

cov:
	urg -dir simv.vdb

verdi:
	verdi -sv -nologo -ssf ./fsdb/$(SIMMODE)$(FSDB_NUM).fsdb ./tsk/timescale.v $(SIMFILE) > ./log/sim/verdi.log
	@echo "(>.<)"

# ==========================backend script command============================== #

# Update sdc and netlist to inputs/ directory
update: ${RUN_DIR_DCT}
	make update TOP=${TOP} -C ${RUN_DIR_DCT}

backup: ${RUN_DIR_DCT}
	make backup DIR_BP=${DIR_BP} -C ${RUN_DIR_DCT}

dc: ${RUN_DIR_DCT}
	make dc TOP=${TOP} -C ${RUN_DIR_DCT}

fm_dct: ${RUN_DIR_FM}
	make fm_dct TOP=${TOP} RUN_DIR_DCT=${RUN_DIR_DCT} -C ${RUN_DIR_FM}

fm_apr: ${RUN_DIR_FM}
	make fm_apr TOP=${TOP} -C ${RUN_DIR_FM}

dc_link:
	cp ./rtl/frontend_file.list ./backend/rel/rtl.lis
	cat `more ./backend/rel/rtl.lis` > ./backend/rel/$(TOP).v
	nLint -2001 -rs ./nLint/my_nLint.rs -out ./log/nlint/rel_nLint.log ./backend/rel/$(TOP).v

# ==========================auto script command============================== #

flstgen: ${PYTHON_DIR}
	python ${PYTHON_DIR}/autoeda.py flstgen ${SRC1} ${DST}

cpfile: ${PYTHON_DIR}
	python ${PYTHON_DIR}/autoeda.py cpfile ${SRC1} ${DST}

simfilegen: ${PYTHON_DIR}
	python ${PYTHON_DIR}/autoeda.py simfilegen ${SRC1} ${SRC2} ${DST}

tbgen: ${PYTHON_DIR}
	python ${PYTHON_DIR}/autoeda.py tbgen ${SRC1} ${DST}

spramtbgen: ${PYTHON_DIR}
	python ${PYTHON_DIR}/autoeda.py spramtbgen ${SRC1} ${DST}

dpramtbgen: ${PYTHON_DIR}
	python ${PYTHON_DIR}/autoeda.py dpramtbgen ${SRC1} ${DST}

ramgen: ${PYTHON_DIR}
	python ${PYTHON_DIR}/autoeda.py ramgen ${SRC1} ${DST}

link: ${PYTHON_DIR}
	python ${PYTHON_DIR}/autoeda.py link ${SRC1} ${DST}

# ==========================system command============================== #

new:
	@echo "hello,designer"
	mkdir docs
	mv *.* docs/ 
	mkdir testbench
	mkdir rtl
	mkdir log
	mkdir log/nlint
	mkdir log/nlint/rtl
	mkdir log/sim
	mkdir fsdb
	mkdir tsk
	mkdir simfile
	mkdir nLint
	mkdir backend
	mkdir backend/rel
	mkdir backend/sdc
	mkdir backend/formality
	mkdir backend/formality/script
	mkdir backend/syn
	mkdir backend/syn/backup
	mkdir backend/syn/dct
	mkdir backend/syn/dct/inputs
	mkdir backend/syn/dct/script
	touch ./simfile/simfile_rtl.f
	touch ./simfile/simfile_presim.f
	touch ./simfile/simfile_postsim.f
	touch ./backend/rel/rtl.lis
	touch ./backend/syn/dct/inputs/backend_file.list
	touch ./rtl/frontend_file.list
	touch ./tsk/timescale.v
	@echo '`timescale 1ns/1ps' > ./tsk/timescale.v
	cp ./docs/dc.makefile ${RUN_DIR_DCT}/makefile
	cp ./docs/fm.makefile ${RUN_DIR_FM}/makefile
	cp ./docs/*.rs nLint/
	cp ./docs/dc*.tcl ${RUN_DIR_DCT}/script
	cp ./docs/sc*.tcl ${RUN_DIR_DCT}/script
	cp ./docs/path*.tcl ${RUN_DIR_DCT}/script
	cp ./docs/fm*.tcl ${RUN_DIR_FM}/script
	cp ./docs/*.sdc backend/sdc/

.PHONY: clean_dct
clean_dct: ${RUN_DIR_DCT}
	make clean TOP=${TOP} -C ${RUN_DIR_DCT}

.PHONY: clean_fm
clean_fm: ${RUN_DIR_FM}
	make clean TOP=${TOP} -C ${RUN_DIR_FM}
	
.PHONY: clean_sim
clean_sim:
	-rm -f ./*.log
	-rm -f ./*.rc
	-rm -f ./*.conf
	-rm -f ./smiv*
	-rm -f ./*.key
	-rm -f ./log/sim/*.log
	-rm -f ./fsdb/*.fsdb
	-rm -rf ./csrc
	-rm -rf ./simv*

.PHONY: clearprj
clearprj:
	mkdir ../makefile_save
	mv ./makefile ../makefile_save/
	mv ./docs/* ../makefile_save/
	-rm -rf ./* 
	mv ../makefile_save/* ./
	-rm -rf ../makefile_save
	@echo "good bye,designer"

# ==========================help============================== #
help:
	@echo "================ makefile help ================"
	@echo "make new       : create a new workspace"
	@echo -e "\n"
	@echo "================ frontend script command ================"
	@echo "make nlint     : start nlint to check the code in simfile"
	@echo "make vcs       : start simulation"
	@echo "make cov       : create the report of cover"
	@echo "make verdi     : start verdi to observe the wave"
	@echo -e "\n"
	@echo "================ backend script command ================"
	@echo "make dc_link   : link the rtl in a file for dc synthesis"
	@echo "make update    : update rtl and sdc file"
	@echo "make backup    : backup rtl and sdc file"
	@echo "make dc        : run dc synthesis scripts"
	@echo "make fm_dct    : run dc netlist formality scripts"
	@echo "make fm_apr    : run apr netlist formality scripts"
	@echo -e "\n"
	@echo "================ clean command ================"
	@echo "make clean_dct : clean synthesis redundant files"
	@echo "make clean_sim : clean the simulation temp file"
	@echo "make clearprj  : remove all files except makefile"
	@echo -e "\n"
	@echo "================ autoeda command ================"
	@echo "make flstgen   : generate file list under the specified path"
	@echo "make cpfile    : copy file from filelist/folder to destination folder"
	@echo "make tbgen     : generate testbench"
	@echo "make spramtbgen: generate testbench for auto generating single port ram model"
	@echo "make dpramtbgen: generate testbench for auto generating double port ram model"
	@echo "make ramgen    : generate ram model"
	@echo "make link      : generate module top file "
	@echo "make simfilegen: generate simfile filelist according to rtl and testbench"
