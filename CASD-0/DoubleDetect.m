/*
    CharityWorld: DoubleDetect.m
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

Implementation for the DoubleDetect class.

*/

#import "DoubleDetect.h"
#import <string.h>

#define DETECT(type, method) \
  fp_except save = fpgetsticky(); \
  type retval; \
  \
  fpsetsticky(0); \
  retval = [super method: value]; \
  last_op_detect = fpgetsticky(); \
  detected |= last_op_detect; \
  fpsetsticky(save); \
  return retval

/* Class variable */

static fp_except detected = 0;	// Stores the exceptions detected

/* Implementation */

@implementation DoubleDetect

/* New methods for this sub-class */

+(BOOL)detectedAny {
  return (detected == 0) ? NO : YES;
}

-(BOOL)detectedAny {
  return [[self class] detectedAny];
}

+(BOOL)detectedAnyOf: (fp_except)flags {
  return ((detected & flags) == 0) ? NO : YES;
}

-(BOOL)detectedAnyOf: (fp_except)flags {
  return [[self class] detectedAnyOf: flags];
}

+(BOOL)detectedInvalidOperation {
#ifdef FP_X_INV
  return ((detected & FP_X_INV) == 0) ? NO : YES;
#else
  return NO;
#endif
}

-(BOOL)detectedInvalidOperation {
  return [[self class] detectedInvalidOperation];
}

+(BOOL)detectedOverflow {
#ifdef FP_X_OFL
  return ((detected & FP_X_OFL) == 0) ? NO : YES;
#else
  return NO;
#endif
}

-(BOOL)detectedOverflow {
  return [[self class] detectedOverflow];
}

+(BOOL)detectedUnderflow {
#ifdef FP_X_UFL
  return ((detected & FP_X_UFL) == 0) ? NO : YES;
#else
  return NO;
#endif
}

-(BOOL)detectedUnderflow {
  return [[self class] detectedUnderflow];
}

+(BOOL)detectedDivideByZero {
#ifdef FP_X_DZ
  return ((detected & FP_X_DZ) == 0) ? NO : YES;
#else
  return NO;
#endif
}

-(BOOL)detectedDivideByZero {
  return [[self class] detectedDivideByZero];
}

+(BOOL)detectedImprecision {
#ifdef FP_X_IMP
  return ((detected & FP_X_IMP) == 0) ? NO : YES;
#else
  return NO;
#endif
}

-(BOOL)detectedImprecision {
  return [[self class] detectedImprecision];
}

+(BOOL)detectedDenormalization {
#ifdef FP_X_DNML
  return ((detected & FP_X_DNML) == 0) ? NO : YES;
#else
  return NO;
#endif
}

-(BOOL)detectedDenormalization {
  return [[self class] detectedDenormalization];
}

+resetDetections {
  detected = 0;

  return self;
}

-resetDetections {
  [[self class] resetDetections];

  return self;
}

+writeDetections: (FILE *)fp {
  fprintf(fp, "Detected the following floating-point exceptions since last "
	  "reset:\n"
	  "\tInvalid Operation: %s\n"
	  "\tDenormalization Error: %s\n"
	  "\tDivision by Zero: %s\n"
	  "\tOverflow: %s\n"
	  "\tUnderflow: %s\n"
	  "\tLoss of Precision: %s\n"
#ifdef FP_X_INV
	  , (detected & FP_X_INV) == 0 ? "NO" : "YES"
#else
	  , "n/a"
#endif
#ifdef FP_X_DNML
	  , (detected & FP_X_DNML) == 0 ? "NO" : "YES"
#else
	  , "n/a"
#endif
#ifdef FP_X_DZ
	  , (detected & FP_X_DZ) == 0 ? "NO" : "YES"
#else
	  , "n/a"
#endif
#ifdef FP_X_OFL
	  , (detected & FP_X_OFL) == 0 ? "NO" : "YES"
#else
	  , "n/a"
#endif
#ifdef FP_X_UFL
	  , (detected & FP_X_UFL) == 0 ? "NO" : "YES"
#else
	  , "n/a"
#endif
#ifdef FP_X_IMP
	  , (detected & FP_X_IMP) == 0 ? "NO" : "YES"
#else
	  , "n/a"
#endif
	  );
  return self;
}

-writeDetections: (FILE *)fp {
  [[self class] writeDetections: fp];

  return self;
}

-writeLastOpErrs: (FILE *)fp {
  int ctr = 0;
#ifdef FP_X_INV
  if((last_op_detect & FP_X_INV) != 0) {
    fprintf(fp, "%sInvalid Operation", ctr++ > 0 ? ", " : "");
  }
#endif
#ifdef FP_X_DNML
  if((last_op_detect & FP_X_DNML) != 0) {
    fprintf(fp, "%sDenormalization Error", ctr++ > 0 ? ", " : "");
  }
#endif
#ifdef FP_X_DZ
  if((last_op_detect & FP_X_DZ) != 0) {
    fprintf(fp, "%sDivision by Zero", ctr++ > 0 ? ", " : "");
  }
#endif
#ifdef FP_X_OFL
  if((last_op_detect & FP_X_OFL) != 0) {
    fprintf(fp, "%sFloating Point Overflow", ctr++ > 0 ? ", " : "");
  }
#endif
#ifdef FP_X_UFL
  if((last_op_detect & FP_X_UFL) != 0) {
    fprintf(fp, "%sFloating Point Underflow", ctr++ > 0 ? ", " : "");
  }
#endif
#ifdef FP_X_IMP
  if((last_op_detect & FP_X_IMP) != 0) {
    fprintf(fp, "%sLoss of Precision", ctr++ > 0 ? ", " : "");
  }
#endif
  return self;
}

/* Methods to override from DoubleSimple */

-add: (DoubleSimple *)value {
  DETECT(id, add);
}

-sub: (DoubleSimple *)value {
  DETECT(id, sub);
}

-mul: (DoubleSimple *)value {
  DETECT(id, mul);
}

-div: (DoubleSimple *)value {
  DETECT(id, div);
}

-iadd: (int)value {
  DETECT(id, iadd);
}

-isub: (int)value {
  DETECT(id, isub);
}

-imul: (int)value {
  DETECT(id, imul);
}

-idiv: (int)value {
  DETECT(id, idiv);
}

-cadd: (double)value {
  DETECT(id, cadd);
}

-csub: (double)value {
  DETECT(id, csub);
}

-cmul: (double)value {
  DETECT(id, cmul);
}

-cdiv: (double)value {
  DETECT(id, cdiv);
}

-(BOOL)ieq: (int)value {
  DETECT(BOOL, ieq);
}

-(BOOL)ine: (int)value {
  DETECT(BOOL, ine);
}

-(BOOL)igt: (int)value {
  DETECT(BOOL, igt);
}

-(BOOL)ile: (int)value {
  DETECT(BOOL, ile);
}

-(BOOL)ige: (int)value {
  DETECT(BOOL, ige);
}

-(BOOL)ilt: (int)value {
  DETECT(BOOL, ilt);
}

-(double)checkConst: (const char *)value {
  DETECT(double, checkConst);
}

@end

