/*
    CharityWorld: DoubleWarn.h
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
operations on it, and will issue a warning message if there is any loss
of precision.

*/

#import <stdio.h>
#import "DoubleDetect.h"

@interface DoubleWarn : DoubleDetect {
  BOOL last_op_err;		// An instance variable for subclasses to use
				// indicating whether the last operation 
				// flagged one of the errors being trapped.
}

/* New methods for this class */

+trapInvalidOperation: (BOOL)trap;
-trapInvalidOperation: (BOOL)trap;

+trapOverflow: (BOOL)trap;
-trapOverflow: (BOOL)trap;

+trapUnderflow: (BOOL)trap;
-trapUnderflow: (BOOL)trap;

+trapDivideByZero: (BOOL)trap;
-trapDivideByZero: (BOOL)trap;

+trapImprecision: (BOOL)trap;
-trapImprecision: (BOOL)trap;

+trapDenormalization: (BOOL)trap;
-trapDenormalization: (BOOL)trap;

+trapAll;
-trapAll;

+trapNone;
-trapNone;

+writeTraps: (FILE *)fp;
-writeTraps: (FILE *)fp;

/* Methods to override from DoubleDetect */

+parseValue: (char *)str;

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
