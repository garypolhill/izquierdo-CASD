/*
    CharityWorld: DoubleInterval.h
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

This is a class to store a floating point number as an interval between two
values -- one computed with round to +infinity the other computed with round
to -infinity.

Note that the logical operators return YES if and only if the operator is true
for all members of the operands. There will therefore be some cases whereby
A == B and A != B are both false... but never will both be true.

*/

#import "DoubleSimple.h"

@interface DoubleInterval: DoubleSimple {
  double min;
  double max;
}

/* New methods for this class */

-(double)min;
-(double)max;

-(BOOL)intersect: (DoubleInterval *)value;
-(BOOL)notIntersect: (DoubleSimple *)value;
-(BOOL)subset: (DoubleInterval *)value;
-(BOOL)subsetEq: (DoubleInterval *)value;
-(BOOL)superset: (DoubleSimple *)value;
-(BOOL)supersetEq: (DoubleSimple *)value;

/* Methods to override from DoubleSimple */

+parseValue: (char *)str;

+newUp;

-set: (DoubleSimple *)value;
-cset: (double)value;
-setStr: (char *)str;

-write: (FILE *)fp;
-write: (FILE *)fp sf: (int)sigfig;
-writeAccurately: (FILE *)fp;

-abs;

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

-(BOOL)eq: (DoubleSimple *)value;
-(BOOL)ne: (DoubleSimple *)value;
-(BOOL)gt: (DoubleSimple *)value;
-(BOOL)le: (DoubleSimple *)value;
-(BOOL)ge: (DoubleSimple *)value;
-(BOOL)lt: (DoubleSimple *)value;

-(BOOL)ieq: (int)value;
-(BOOL)ine: (int)value;
-(BOOL)igt: (int)value;
-(BOOL)ile: (int)value;
-(BOOL)ige: (int)value;
-(BOOL)ilt: (int)value;

-(BOOL)ceq: (double)value;
-(BOOL)cne: (double)value;
-(BOOL)cgt: (double)value;
-(BOOL)cle: (double)value;
-(BOOL)cge: (double)value;
-(BOOL)clt: (double)value;

@end
