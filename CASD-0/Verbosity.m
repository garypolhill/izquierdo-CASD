/*
    CASD-0: Verbosity.m
    Copyright (C) 2004  Macaulay Institute

    This file is part of CASD (Casuistry And Social Dilemmas), an agent-based
    model designed to study the behaviour of case-based reasoners when they
    face social dilemmas. Social dilemmas are modelled as n-player games.

    CASD-0 is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    CASD-0 is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details. (LICENCE file in
    this directory.)

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Contact information:
      Gary Polhill,
      Macaulay Institute, Craigiebuckler, Aberdeen, AB15 8QH. United Kingdom
      g.polhill@macaulay.ac.uk
*/

/*

CASD

Verbosity.m

Add to this file any message category you need that is not already
present. Having put +(BOOL)showMyNewMessageCategory in Verbosity.h to
declare the new category, you need to add a definition of it in this
file. A macro has been provided for you to do so, and you should use
it. Just enter SHOW(MyNewMessageCategory) before @end, where all the
other message categories are declared.

*/

#import "Verbosity.h"
#import <objc/objc-api.h>
#import <errno.h>
#import <string.h>
#import <stdlib.h>

static int level = 0;		// A class variable (this is the way to do
				// these in Obj-C) to store the verbosity level
				// set by the user.

#define SHOW(x) static BOOL verbosity_show_ ## x (BOOL set, int val) { \
  static int value = -1; \
  if(set) { \
    value = val; \
    return YES; \
  } \
  else { \
    return (value == -1 ? NO : (val >= value ? YES : NO)); \
  } \
} \
+(BOOL)show ## x { return verbosity_show_ ## x (NO, level); } \
+(BOOL)setshow ## x { return verbosity_show_ ## x (YES, level); }
				// SHOW macro for defining messages. Note that
				// it actually creates a function called
				// verbosity_show_XXXX which has two purposes:
				// one is to set the level of verbosity at
				// which to activate the messages, the other
				// is to return whether or not the verbosity
				// level exceeds that which has been set.
				// Two methods are created to call this
				// function in the two different modes:
				// setshowXXXX and showXXXX. setshowXXXX is
				// used internally during the initialise
				// method, and therefore does not need to
				// appear in the interface file.

@implementation Verbosity

/*

initialise:

This method initialises the Verbosity class from the verbosity file. This file
specifies the level of verbosity required for each verbosity method.

The verbosity file has the following format:

<message category 1>	<verbosity level 1>
<message category 2>	<verbosity level 2>
...

*/

+(void)initialise: (const char *)verbosityFile {
  FILE *fp;
  char buf[1024];
  int lvl;

  fp = fopen(verbosityFile, "r");
  if(fp == NULL) {
    fprintf(stderr, "Cannot open verbosity file %s: %s\n", verbosityFile,
	    strerror(errno));
    abort();
  }
  strcpy(buf, "setshow");	// The buffer is used to store the method
				// names, and the first bit of all method
				// names called from here is "setshow". The
				// rest will be loaded from the file.
  while(!feof(fp)) {
    SEL setShowMethod;
    fscanf(fp, "%1019s%d", &buf[7], &lvl);
				// Read the name of the method (without the
				// show or setshow bit) from the file into
				// the buffer at the right place, and read
				// in the corresponding verbosity level.
    setShowMethod = sel_get_uid(buf);
				// Get the name of the method. (I don't know
				// if this fails nicely for an invalid method.)
    if([self respondsTo: setShowMethod]) {
				// Check that the method is valid.
      if(lvl > 0) {
	int tmp = level;

	level = lvl;
	[self perform: setShowMethod];
	level = tmp;
				// Set the level using the setshowXXXX
				// method This method uses the level
				// class variable to store the level
				// to set the XXXX messages to, so a
				// temporary copy needs to be made of
				// the user verbosity-level.
      }
      else {
	fprintf(stderr, "Error in verbosity file %s:\n\t%s: %d <<< HERE:\n\t"
		"Verbosity level for message must be non-negative\n",
		verbosityFile, &buf[7], lvl);
	abort();
      }
    }
    else {
      fprintf(stderr, "Error in verbosity file %s\n\t%s <<< HERE:\n\t"
	      "Verbosity class does not recognise this message\n"
	      "Valid messages are:\n",
	      verbosityFile, &buf[7]);
      [self printValidMessages: stderr];
      abort();
    }
  }
}

/*

printValidMessages:

Print a list of the methods for this class that begin with
"show". This provides a list of message categories that the user can
specify in the verbosity file.

The method hacks about a bit with the Obj-C API. Each class has a
meta-class, so a class is an instance of that meta-class. The
meta-class stores information about the methods in a structure of type
objc_method_list in the methods instance variable, which is accessible
directly by dereferencing. This structure has the following members
(among others -- see objc-api.h for more info):

struct objc_method_list {
  int methodCount;
  struct objc_method {
    SEL method_name;
  } methods[];
  struct objc_method_list *method_next;
}

It's a rather odd-seeming list of arrays of methods, then, this methods
instance variable of the meta-class (no doubt there is a good
reason).

Once we've got the method name, we convert it to a string and check if
the first four characters are "show". If they are, then print the rest
of the method name.

*/

+(void)printValidMessages: (FILE *)fp {
  MetaClass myClass = [self metaClass];
  struct objc_method_list *vClassMethods = myClass->methods;
				// Get the list of arrays of methods structure
				// from the methods instance variable of the
				// meta-class.
  while(vClassMethods != NULL) {
				// Loop through the list
    int i;
    struct objc_method *methods = vClassMethods->method_list;
				// Get the array

    for(i = 0; i < vClassMethods->method_count; i++) {
				// Loop through the array
      const char *methodName = sel_get_name(methods[i].method_name);
				// Get the name of the method as a string

      if(strncmp(methodName, "show", 4) == 0) {
				// If the method name begins with "show", 
				// then print the rest of the name.
	fprintf(fp, "%s\n", &methodName[4]);
      }
    }
    vClassMethods = vClassMethods->method_next;
				// Get the next member of the method list.
  }
}

+(void)setLevel: (int)lvl {
  if(lvl >= 0) {
    level = lvl;
  }
  else {
    fprintf(stderr, "Error: [%s %s] called with negative argument: %d\n",
	    class_get_class_name(self), sel_get_name(_cmd), lvl);
    abort();
  }
}

+(BOOL)alwaysShow: (char *)message {
  char *buf = malloc(strlen(message) + 8);

  sprintf(buf, "setshow%s", message);
  if([self respondsTo: sel_get_uid(buf)]) {
    int tmp = level;

    level = 0;
    [self perform: sel_get_uid(buf)];
    level = tmp;
    free(buf);
    return YES;
  }
  else {
    free(buf);
    return NO;
  }
}

SHOW(ParseArgs);//1
SHOW(Progress);//1
SHOW(Connections);//5
SHOW(StateUpdate);//5
SHOW(AgentsUpdatingHistory);//5
SHOW(CaseFound);//10
SHOW(SumOfPayoffs);//10
SHOW(Cycles);//2
SHOW(AgentsResetting);//2
SHOW(PayoffCalcUpdatingDecisions);//10
SHOW(PayoffCalcGivingPayoffs);//10
SHOW(AgentsDeciding);//10
SHOW(AgentsRemembering);//10
SHOW(AgentsStateUpdate);//10
SHOW(AgentsDecidingAtRandom);//2
SHOW(AgentsUpdatingAccount);//10
SHOW(Equilibria);//1
SHOW(NumberRandomDecisions);//10
SHOW(AgentsJudging);//10
SHOW(SumOfNbrsDisapproving);//10
SHOW(CyclicBehaviour);//1
SHOW(NumberOfCooperators);//10
SHOW(AgentsDecidingDeterministically);//10
SHOW(NumberDeterministicDecisions);//10
SHOW(VisitsCompetition);//12
SHOW(AgentsUpdatingAge);//10

/* ^^^ Enter new message categories using the SHOW(XXXX) macro here ^^^ */

@end
