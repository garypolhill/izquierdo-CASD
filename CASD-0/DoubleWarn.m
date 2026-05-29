/*
    CharityWorld: DoubleWarn.m
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

Implementation for the DoubleWarn object.

*/

#import "DoubleWarn.h"
#import <string.h>
#import <stdlib.h>

#define WARN(return_type, method, opstr, lhscmd, prepstr, rhscmd) \
  double d0 = d; \
  return_type retval = [super method: value]; \
  if((last_op_detect & trap_flags) == 0) { \
    last_op_err = NO; \
  } \
  else { \
    last_op_err = YES; \
    fprintf(stderr, "Detected "); \
    [self writeLastOpErrs: stderr]; \
    fprintf(stderr, opstr); \
    lhscmd; \
    fprintf(stderr, prepstr); \
    rhscmd; \
    fprintf(stderr, "\n"); \
  } \
  d0 *= 2.0; \
  return retval
				// The d0 *= 2.0 is just a dummy statement
				// so the compiler doesn't complain if d0
				// is not used

/* class variable */

static fp_except trap_flags = 0;

/* Implementation */

@implementation DoubleWarn

/* New methods for this sub-class */

+trapInvalidOperation: (BOOL)trap {
#ifdef FP_X_INV
  trap_flags = trap ? (trap_flags | FP_X_INV) : (trap_flags & (~FP_X_INV));
#else
  fprintf(stderr, "Warning: This platform cannot trap invalid operations\n");
#endif
  return self;
}

-trapInvalidOperation: (BOOL)trap {
  [[self class] trapInvalidOperation: trap];

  return self;
}

+trapOverflow: (BOOL)trap {
#ifdef FP_X_OFL
  trap_flags = trap ? (trap_flags | FP_X_OFL) : (trap_flags & (~FP_X_OFL));
#else
  fprintf(stderr, "Warning: This platform cannot trap overflows\n");
#endif
  return self;
}

-trapOverflow: (BOOL)trap {
  [[self class] trapOverflow: trap];

  return self;
}

+trapUnderflow: (BOOL)trap {
#ifdef FP_X_UFL
  trap_flags = trap ? (trap_flags | FP_X_UFL) : (trap_flags & (~FP_X_UFL));
#else
  fprintf(stderr, "Warning: This platform cannot trap underflows\n");
#endif
  return self;
}

-trapUnderflow: (BOOL)trap {
  [[self class] trapUnderflow: trap];

  return self;
}

+trapDivideByZero: (BOOL)trap {
#ifdef FP_X_DZ
  trap_flags = trap ? (trap_flags | FP_X_DZ) : (trap_flags & (~FP_X_DZ));
#else
  fprintf(stderr, "Warning: This platform cannot trap divisions by zero\n");
#endif
  return self;
}

-trapDivideByZero: (BOOL)trap {
  [[self class] trapDivideByZero: trap];

  return self;
}

+trapImprecision: (BOOL)trap {
#ifdef FP_X_IMP
  trap_flags = trap ? (trap_flags | FP_X_IMP) : (trap_flags & (~FP_X_IMP));
#else
  fprintf(stderr, "Warning: This platform cannot trap imprecision\n");
#endif
  return self;
}

-trapImprecision: (BOOL)trap {
  [[self class] trapImprecision: trap];

  return self;
}

+trapDenormalization: (BOOL)trap {
#ifdef FP_X_DNML
  trap_flags = trap ? (trap_flags | FP_X_DNML) : (trap_flags & (~FP_X_DNML));
#else
  fprintf(stderr, "Warning: This platform cannot trap denormalization "
	  "errors\n");
#endif
  return self;
}

-trapDenormalization: (BOOL)trap {
  [[self class] trapDenormalization: trap];

  return self;
}

+trapAll {
  trap_flags = 
#ifdef FP_X_INV
	    FP_X_INV |
#endif
#ifdef FP_X_DNML
	    FP_X_DNML |
#endif
#ifdef FP_X_DZ
	    FP_X_DZ |
#endif
#ifdef FP_X_OFL
	    FP_X_OFL |
#endif
#ifdef FP_X_UFL
	    FP_X_UFL |
#endif
#ifdef FP_X_IMP
	    FP_X_IMP |
#endif
	    0;
  return self;
}

-trapAll {
  [[self class] trapAll];

  return self;
}

+trapNone {
  trap_flags = 0;
  return self;
}

-trapNone {
  [[self class] trapNone];

  return self;
}

+writeTraps: (FILE *)fp {
  fprintf(fp, "Trapping the following floating-point exceptions:\n"
	  "\tInvalid Operation: %s\n"
	  "\tDenormalization Error: %s\n"
	  "\tDivision by Zero: %s\n"
	  "\tOverflow: %s\n"
	  "\tUnderflow: %s\n"
	  "\tLoss of Precision: %s\n"
#ifdef FP_X_INV
	  , (trap_flags & FP_X_INV) == 0 ? "NO" : "YES"
#else
	  , "n/a"
#endif
#ifdef FP_X_DNML
	  , (trap_flags & FP_X_DNML) == 0 ? "NO" : "YES"
#else
	  , "n/a"
#endif
#ifdef FP_X_DZ
	  , (trap_flags & FP_X_DZ) == 0 ? "NO" : "YES"
#else
	  , "n/a"
#endif
#ifdef FP_X_OFL
	  , (trap_flags & FP_X_OFL) == 0 ? "NO" : "YES"
#else
	  , "n/a"
#endif
#ifdef FP_X_UFL
	  , (trap_flags & FP_X_UFL) == 0 ? "NO" : "YES"
#else
	  , "n/a"
#endif
#ifdef FP_X_IMP
	  , (trap_flags & FP_X_IMP) == 0 ? "NO" : "YES"
#else
	  , "n/a"
#endif
	  );
  return self;
}

-writeTraps: (FILE *)fp {
  [[self class] writeTraps: fp];

  return self;
}

/* Methods to override from DoubleSimple */

+parseValue: (char *)str {
  char *p, *q;
  id retval;

  p = strchr(str, (int)'!');
  if(p != NULL) {
    (*p) = '\0';
  }
  while(p != NULL) {
    q = p + 1;
    p = strchr(q, (int)'!');
    if(p != NULL) {
      (*p) = '\0';
    }
    if(strcmp(q, "ALL") == 0) {
      [self trapAll];
    }
    else if(strcmp(q, "INV") == 0) {
      [self trapInvalidOperation: YES];
    }
    else if(strcmp(q, "OFL") == 0) {
      [self trapOverflow: YES];
    }
    else if(strcmp(q, "UFL") == 0) {
      [self trapUnderflow: YES];
    }
    else if(strcmp(q, "IMP") == 0) {
      [self trapImprecision: YES];
    }
    else if(strcmp(q, "DZ") == 0) {
      [self trapDivideByZero: YES];
    }
    else if(strcmp(q, "DNML") == 0) {
      [self trapDenormalization: YES];
    }
    else {
      fprintf(stderr, "Invalid format in parse string: %s -- unrecognised "
	      "trap type.\n", q);
      abort();
    }
  }
  retval = [super parseValue: str];
  return retval;
}

-add: (DoubleSimple *)value {
  WARN(id, add, " adding ", [value write: stderr],
       " to ", fprintf(stderr, "%g", d0));
}

-sub: (DoubleSimple *)value {
  WARN(id, sub, " subtracting ", [value write: stderr],
       " from ", fprintf(stderr, "%g", d0));
}

-mul: (DoubleSimple *)value {
  WARN(id, mul, " multiplying ", fprintf(stderr, "%g", d0),
       " by ", [value write: stderr]);
}

-div: (DoubleSimple *)value {
  WARN(id, div, " dividing ", fprintf(stderr, "%g", d0),
       " by ", [value write: stderr]);
}

-iadd: (int)value {
  WARN(id, iadd, " adding integer ", fprintf(stderr, "%d", value),
       " to ", fprintf(stderr, "%g", d0));
}

-isub: (int)value {
  WARN(id, isub, " subtracting integer ", fprintf(stderr, "%d", value),
       " from ", fprintf(stderr, "%g", d0));
}

-imul: (int)value {
  WARN(id, imul, " multiplying ", fprintf(stderr, "%g", d0),
       " by integer ", fprintf(stderr, "%d", value));
}

-idiv: (int)value {
  WARN(id, idiv, " dividing ", fprintf(stderr, "%g", d0),
       " by integer ", fprintf(stderr, "%d", value));
}

-cadd: (double)value {
  WARN(id, cadd, " adding constant ", fprintf(stderr, "%g", value),
       " to ", fprintf(stderr, "%g", d0));
}

-csub: (double)value {
  WARN(id, csub, " subtracting constant ", fprintf(stderr, "%g", value),
       " from ", fprintf(stderr, "%g", d0));
}

-cmul: (double)value {
  WARN(id, cmul, " multiplying ", fprintf(stderr, "%g", d0),
       " by constant ", fprintf(stderr, "%g", value));
}

-cdiv: (double)value {
  WARN(id, cdiv, " dividing ", fprintf(stderr, "%g", d0),
       " by constant ", fprintf(stderr, "%g", value));
}

-(BOOL)ieq: (int)value {
  WARN(BOOL, ieq, " comparing ", fprintf(stderr, "%g", d0),
       " with integer ", fprintf(stderr, "%d", value));
}

-(BOOL)ine: (int)value {
  WARN(BOOL, ine, " comparing ", fprintf(stderr, "%g", d0),
       " with integer ", fprintf(stderr, "%d", value));
}

-(BOOL)igt: (int)value {
  WARN(BOOL, igt, " comparing ", fprintf(stderr, "%g", d0),
       " with integer ", fprintf(stderr, "%d", value));
}

-(BOOL)ile: (int)value {
  WARN(BOOL, ile, " comparing ", fprintf(stderr, "%g", d0),
       " with integer ", fprintf(stderr, "%d", value));
}

-(BOOL)ige: (int)value {
  WARN(BOOL, ige, " comparing ", fprintf(stderr, "%g", d0),
       " with integer ", fprintf(stderr, "%d", value));
}

-(BOOL)ilt: (int)value {
  WARN(BOOL, ilt, " comparing ", fprintf(stderr, "%g", d0),
       " with integer ", fprintf(stderr, "%d", value));
}

-(double)checkConst: (const char *)value {
  WARN(double, checkConst, " checking ", fprintf(stderr, "constant"),
       " value ", fprintf(stderr, "%s", value));
}

@end

