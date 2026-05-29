/*
    CharityWorld: DoubleDetect.h
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

This is a class to store a double-precision floating point number and
operations on it, and will set a flag to indicate whether an error has been
detected.

*/

#import <stdio.h>
#ifdef INTEL
#import <CIieeefp.h>
#else
#import <ieeefp.h>
#endif
#import "DoubleSimple.h"

@interface DoubleDetect : DoubleSimple {
  fp_except last_op_detect;	// Floating point errors detected by last op
}

/* New methods for this class */

+(BOOL)detectedAny;
-(BOOL)detectedAny;

+(BOOL)detectedAnyOf: (fp_except)flags;
-(BOOL)detectedAnyOf: (fp_except)flags;

+(BOOL)detectedInvalidOperation;
-(BOOL)detectedInvalidOperation;

+(BOOL)detectedOverflow;
-(BOOL)detectedOverflow;

+(BOOL)detectedUnderflow;
-(BOOL)detectedUnderflow;

+(BOOL)detectedDivideByZero;
-(BOOL)detectedDivideByZero;

+(BOOL)detectedImprecision;
-(BOOL)detectedImprecision;

+(BOOL)detectedDenormalization;
-(BOOL)detectedDenormalization;

+resetDetections;
-resetDetections;

+writeDetections: (FILE *)fp;
-writeDetections: (FILE *)fp;
-writeLastOpErrs: (FILE *)fp;

/* Methods to override from DoubleSimple */

-add: (DoubleSimple *)value;
-sub: (DoubleSimple *)value;
-mul: (DoubleSimple *)value;
-div: (DoubleSimple *)value;

-iadd: (int)value;
-isub: (int)value;
-imul: (int)value;
-idiv: (int)value;

-cadd: (double)value;
-csub: (double)value;
-cmul: (double)value;
-cdiv: (double)value;

-(BOOL)ieq: (int)value;
-(BOOL)ine: (int)value;
-(BOOL)igt: (int)value;
-(BOOL)ile: (int)value;
-(BOOL)ige: (int)value;
-(BOOL)ilt: (int)value;

-(double)checkConst: (const char *)value;

@end
