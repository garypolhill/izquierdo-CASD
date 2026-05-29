ifeq ($(SWARMHOME),)
SWARMHOME=../swarm-2.1.1
endif
APPLICATION=casd
APPVERSION=1.0
BUGADDRESS=l.izquierdo@macaulay.ac.uk
AGENTS=Agent.o 
PAYOFFS= Symmetric2x2.o Reward.o
TOOLS=Tube.o Verbosity.o MiscFunc.o Number.o Tuple.o
CASEBASE=Experience.o History.o Case.o State.o DecisionObj.o
IEEE_DOUBLES=DoubleSimple.o DoubleDetect.o DoubleWarn.o DoubleInterval.o DoubleIntervalWarn.o
NOIEEE_DOUBLES=DoubleSimple.o
OOBJECTS=ModelSwarm.o ObserverSwarm.o BatchSwarm.o $(AGENTS) $(TOOLS) $(CASEBASE) $(PAYOFFS)

OOBJECTS+=$(NOIEEE_DOUBLES)

OBJECTS=main.o $(OOBJECTS)
TMPFILE=tmp

include $(SWARMHOME)/etc/swarm/Makefile.appl
-include $(OBJECTS:.o=.d)

%.d: %.m
	gcc -w -E -MMD $< > /dev/null
	@mv -f $@ $(TMPFILE)
	@sed -e 's/:/ $@:/' $(TMPFILE) > $@
	@rm -f $(TMPFILE)

reallyclean: clean
	/bin/rm -f *.d

casd.verby: Verbosity.m
	grep '^SHOW' Verbosity.m | sed -e 's/SHOW(\(.*\));.*\/\/[^0-9]*\([0-9][0-9]*\)/\1 \2/' -e '/^SHOW/d' > casd.verby
