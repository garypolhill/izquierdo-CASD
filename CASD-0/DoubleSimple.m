/*
    CharityWorld: DoubleSimple.m
    Copyright (C) 2003  Macaulay Institute

    This file is part of CharityWorld, a simple agent-based model to
    demonstrate the effects of errors in floating point arithmetic on
    emergent outcomes.

    CharityWorld is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    CharityWorld is distributed in the hope that it will be useful,
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

Implementation for the DoubleSimple object. This just contains a basic
double precision floating point variable and operations for changing
it.

*/

#import "DoubleSimple.h"
#import <stdlib.h>
#import <math.h>
#import <float.h>
#import <errno.h>
#import <string.h>
#import <stdlib.h>
#import <objc/objc-api.h>

#ifdef INTEL
#  import <CIieeefp.h>
#endif

#define NZ_ACC 20		// Number of zeros back from the 'e' in a
				// floating point number printed using %.*e
				// format required to be sure that the
				// floating point number is printed to
				// maximum accuracy

/* Class variables */

Class create_class = Nil;	// The subclass to use to create all
				// DoubleSimples created after parseKeepClass
				// has been called.

char *requested_class_str = NULL;
				// This is the class the user requested in
				// the parse string.

unsigned long long counter = 0;	// Keep a count of the number of currently
				// created instances.

@implementation DoubleSimple

+(unsigned long long)getCounter {
  return counter;
}

/* Creation methods */

+parse: (char *)str {
  char *q = strdup(str);
  char *p = strchr(q, (int)'=');
  Class dblclass;
  id obj;

  if(requested_class_str != NULL) {
    free(requested_class_str);
    requested_class_str = NULL;
  }
  if(p == NULL && create_class == Nil) {
    fprintf(stderr, "Syntax error in DoubleSimple initialisation string: %s "
	    "-- could not find '='\n", str);
    abort();
  }
  else if(p == NULL) {
    dblclass = create_class;
    requested_class_str = strdup(class_get_class_name(create_class));
    p = q;
  }
  else {
    (*p) = '\0';
    p++;
    dblclass = objc_get_class(q);
    requested_class_str = strdup(q);
    if(![dblclass respondsTo: @selector(parseValue:)]) {
      fprintf(stderr, "DoubleSimple initialisation string %s contains invalid "
	      "DoubleSimple class: %s\n", str, q);
      abort();
    }
  }
  obj = [dblclass parseValue: p];
  if(![obj isKindOf: [DoubleSimple class]]) {
    fprintf(stderr, "DoubleSimple initialisation string %s contains class %s "
	    "that is not a subclass of DoubleSimple\n", str, q);
    abort();
  }
  free(q);
  return obj;
}

+parseKeepClass: (char *)str {
  id obj = [self parse: str];

  create_class = [obj class];

  return obj;
}

+parseKeepSameClass: (char *)str {
  id obj = [self parse: str];
  Class obj_class = [obj class];

  if(create_class == Nil) {
    create_class = obj_class;
  }
  else if(strcmp(requested_class_str,
		 class_get_class_name(create_class)) != 0) {
    fprintf(stderr, "Attempt to create DoubleSimple (subclass) %s "
	    "inconsistent with core class %s\n",
	    class_get_class_name(obj_class),
	    class_get_class_name(create_class));
    abort();
  }

  return obj;
}

+parseValue: (char *)str {
  return [[self new] setStr: str];
}

+new {
  return [self new: 0.0];
}

+newKeepClass: (Class)class {
  return [self new: 0.0 keepClass: class];
}

+newKeepSameClass: (Class)class {
  return [self new: 0.0 keepSameClass: class];
}

+new: (double)value {
  id obj;

  if(create_class == Nil) {
    obj = [self newUp];
  }
  else {
    obj = [create_class newUp];
  }

  [obj cset: value];

  return obj;
}

+new: (double)value keepClass: (Class)class {
  create_class = class;

  if(create_class != Nil) {
    id obj;

    if(![create_class respondsTo: @selector(newUp)]
       || ![create_class respondsTo: @selector(new)]) {
      fprintf(stderr, "Attempt to set kept class to invalid class %s\n",
	      class_get_class_name(create_class));
      abort();
    }
    obj = [create_class new];
    if(![obj isKindOf: [DoubleSimple class]]) {
      fprintf(stderr, "Attempt to set kept class to a class that is not "
	      "a subclass of DoubleSimple: %s\n",
	      class_get_class_name(create_class));
      abort();
    }
    [obj free];
  }

  return [self new: value];
}

+new: (double)value keepSameClass: (Class)class {
  if(create_class == Nil || class == Nil) {
    create_class = class;
  }
  else if(create_class != class) {
    fprintf(stderr, "Attempt to create DoubleSimple (subclass) %s "
	    "inconsistent with core class %s\n",
	    class_get_class_name(class),
	    class_get_class_name(create_class));
    abort();
  }
  return [self new: value keepClass: class];
}

+newUp {
  id obj = [super new];
  counter++;

  return obj;
}

-copy {
  return [DoubleSimple new: d];
}

-free {
  counter--;
  return [super free];
}

/* Setting and getting methods */

-set: (DoubleSimple *)value {
  d = [value get];
  return self;
}

-cset: (double)value {
  d = value;
  return self;
}

-setStr: (char *)str {
  d = [self checkConst: str];
  return self;
}  

-(double)get {
  return d;
}

/* I/O methods */

-read: (FILE *)fp {
#ifdef INTEL
  fp_pctl p = fpsetprecision(FP_PC_DBL);
#endif
  fscanf(fp, "%lf", &d);
#ifdef INTEL
  fpsetprecision(p);
#endif
  return self;
}

-write: (FILE *)fp {
#ifdef INTEL
  fp_pctl p = fpsetprecision(FP_PC_DBL);
#endif
  fprintf(fp, "%g", d);
#ifdef INTEL
  fpsetprecision(p);
#endif
  return self;
}

-write: (FILE *)fp sf: (int)sigfig {
#ifdef INTEL
  fp_pctl p = fpsetprecision(FP_PC_DBL);
#endif
  fprintf(fp, "%.*e", sigfig - 1, d);
#ifdef INTEL
  fpsetprecision(p);
#endif
  return self;
}

-writeAccurately: (FILE *)fp {
  char *buf, tbuf[3];
  int dp;
  int nz;
#ifdef INTEL
  fp_pctl pc = fpsetprecision(FP_PC_DBL);
#endif

  dp = NZ_ACC;
  do {
    char *p, *q;
    int len = snprintf(tbuf, 2, "%.*e", dp, d);
				// Use snprintf and a dummy buffer to get the
				// size of buffer needed to print the floating
				// point number to the required number of
				// decimal places
    if(len < 0) {
      perror("Error in call to snprintf");
      abort();
    }

    buf = (char *)malloc(len + 1);
				// Allocate memory for the buffer
    if(buf == NULL) {
      perror("Memory allocation");
      abort();
    }

    sprintf(buf, "%.*e", dp, d);
				// Print the floating point number to the
				// buffer in the format X.YYYYYY0000eZZZ
    p = strchr(buf, (int)'e');
				// Find the 'e' in the buffer.
    if(p == NULL) {		// If we can't find the 'e' then this is some
				// funny number like NaN or Inf
      fprintf(fp, "%e", d);
      free(buf);

#ifdef INTEL
      fpsetprecision(pc);
#endif

      return self;
    }
    q = p;			// Remember where it is...
      
    p--;			// Look back from the 'e' 
    nz = 0;			// and count the number
    while((*p) == '0') {	// of consecutive '0's
      nz++;
      p--;
    }
				// Right now, this should be the state of play:
				// X.YYYYYY0000eZZZ
				// ^buf   ^p   ^q
				// If the number is like X.0000000000eZZZ,
				// then p points here:    ^p.

    if(nz >= NZ_ACC) {		// We've got enough zeros before the 'e' to
				// ensure that maximum accuracy has been
				// achieved (according to the NZ_ACC parameter)
      if((*p) != '.') {
	p++;			// p didn't point to the decimal place, so
				// shift it right one place to point to the
				// first in a long line of zeros.
      }
      (*p) = '\0';		// Overwrite the decimal point or the first
				// in a long line of zeros with a string
				// terminator. Now we have (using # for the
				// terminator):
				// X.YYYYYY#000eZZZ# or X#0000000000eZZZ#
				// ^buf    ^p  ^q       ^buf        ^q
      fprintf(fp, "%s%s", buf, q);
				// So, printing buf then q gives:
				// X.YYYYYYeZZZ      or XeZZZ
    }
    else {
      dp += NZ_ACC;		// Increment the number of decimal places to
				// print by the required accuracy
    }

    free(buf);			// Free the buffer
  } while(nz < NZ_ACC);

#ifdef INTEL
  fpsetprecision(pc);
#endif
  return self;
}

/* Arithmetic operators */

-abs {
#ifdef INTEL
  fp_pctl p = fpsetprecision(FP_PC_DBL);
#endif
  d = fabs(d);
#ifdef INTEL
  fpsetprecision(p);
#endif
  return self;
}

-add: (DoubleSimple *)value {
#ifdef INTEL
  fp_pctl p = fpsetprecision(FP_PC_DBL);
#endif
  d += [value get];
#ifdef INTEL
  fpsetprecision(p);
#endif
  return self;
}

-sub: (DoubleSimple *)value {
#ifdef INTEL
  fp_pctl p = fpsetprecision(FP_PC_DBL);
#endif
  d -= [value get];
#ifdef INTEL
  fpsetprecision(p);
#endif
  return self;
}

-mul: (DoubleSimple *)value {
#ifdef INTEL
  fp_pctl p = fpsetprecision(FP_PC_DBL);
#endif
  d *= [value get];
#ifdef INTEL
  fpsetprecision(p);
#endif
  return self;
}

-div: (DoubleSimple *)value {
#ifdef INTEL
  fp_pctl p = fpsetprecision(FP_PC_DBL);
#endif
  d /= [value get];
#ifdef INTEL
  fpsetprecision(p);
#endif
  return self;
}

/* Arithmetic operators for integers */

-iadd: (int)value {
#ifdef INTEL
  fp_pctl p = fpsetprecision(FP_PC_DBL);
#endif
  d += (double)value;
#ifdef INTEL
  fpsetprecision(p);
#endif
  return self;
}

-isub: (int)value {
#ifdef INTEL
  fp_pctl p = fpsetprecision(FP_PC_DBL);
#endif
  d -= (double)value;
#ifdef INTEL
  fpsetprecision(p);
#endif
  return self;
}

-imul: (int)value {
#ifdef INTEL
  fp_pctl p = fpsetprecision(FP_PC_DBL);
#endif
  d *= (double)value;
#ifdef INTEL
  fpsetprecision(p);
#endif
  return self;
}

-idiv: (int)value {
#ifdef INTEL
  fp_pctl p = fpsetprecision(FP_PC_DBL);
#endif
  d /= (double)value;
#ifdef INTEL
  fpsetprecision(p);
#endif
  return self;
}

/* Arithmetic operators for constant values */

-cadd: (double)value {
#ifdef INTEL
  fp_pctl p = fpsetprecision(FP_PC_DBL);
#endif
  d += value;
#ifdef INTEL
  fpsetprecision(p);
#endif
  return self;
}

-csub: (double)value {
#ifdef INTEL
  fp_pctl p = fpsetprecision(FP_PC_DBL);
#endif
  d -= value;
#ifdef INTEL
  fpsetprecision(p);
#endif
  return self;
}

-cmul: (double)value {
#ifdef INTEL
  fp_pctl p = fpsetprecision(FP_PC_DBL);
#endif
  d *= value;
#ifdef INTEL
  fpsetprecision(p);
#endif
  return self;
}

-cdiv: (double)value {
#ifdef INTEL
  fp_pctl p = fpsetprecision(FP_PC_DBL);
#endif
  d /= value;
#ifdef INTEL
  fpsetprecision(p);
#endif
  return self;
}

/* Comparison operators */

-(BOOL)eq: (DoubleSimple *)value {
  BOOL eq;
  double v = [value get];
  eq = (d == v) ? YES : NO;
  return eq;
}

-(BOOL)ne: (DoubleSimple *)value {
  BOOL ne;
  double v = [value get];
  ne = (d != v) ? YES : NO; 
  return ne;
}

-(BOOL)gt: (DoubleSimple *)value {
  BOOL gt;
  gt = (d > [value get]) ? YES : NO;
  return gt;
}

-(BOOL)le: (DoubleSimple *)value {
  BOOL le;
  le = (d <= [value get]) ? YES : NO;
  return le;
}

-(BOOL)ge: (DoubleSimple *)value {
  BOOL ge;
  ge = (d >= [value get]) ? YES : NO;
  return ge;
}

-(BOOL)lt: (DoubleSimple *)value {
  BOOL lt;
  lt = (d < [value get]) ? YES : NO;
  return lt;
}

/* Comparison operators for integers */

-(BOOL)ieq: (int)value {
  return (d == (double)value) ? YES : NO;
}

-(BOOL)ine: (int)value {
  return (d != (double)value) ? YES : NO;
}

-(BOOL)igt: (int)value {
  return (d > (double)value) ? YES : NO;
}

-(BOOL)ile: (int)value {
  return (d <= (double)value) ? YES : NO;
}

-(BOOL)ige: (int)value {
  return (d >= (double)value) ? YES : NO;
}

-(BOOL)ilt: (int)value {
  return (d < (double)value) ? YES : NO;
}

/* Comparison operators for constant values */

-(BOOL)ceq: (double)value {
  return (d == value) ? YES : NO;
}

-(BOOL)cne: (double)value {
  return (d != value) ? YES : NO;
}

-(BOOL)cgt: (double)value {
  return (d > value) ? YES : NO;
}

-(BOOL)cle: (double)value {
  return (d <= value) ? YES : NO;
}

-(BOOL)cge: (double)value {
  return (d >= value) ? YES : NO;
}

-(BOOL)clt: (double)value {
  return (d < value) ? YES : NO;
}

/* Routine for checking that a constant can be represented accurately using
   floating point arithmetic -- it does nothing by default, but all uses of
   cadd, csub, cmul, cdiv, ceq, cne, cgt, cle, cge, and clt, should use it.
*/

-(double)checkConst: (const char *)value {
  double dd;
#ifdef INTEL
  fp_pctl p = fpsetprecision(FP_PC_DBL);
#endif
  dd = atof(value);
#ifdef INTEL
  fpsetprecision(p);
#endif
  return dd;
}

@end
