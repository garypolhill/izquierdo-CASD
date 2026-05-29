/*
    CharityWorld: DoubleIntervalWarn.h
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

A subclass of DoubleInterval that warns if any of the comparison
operators produces an uncertain result -- i.e. if neither the
comparison nor its opposite is TRUE. This assumes that DoubleInterval
has a very strict interpretation of the comparison operators (i.e. the
comparison operator returns TRUE iff for all values in any applicable
range, the comparison operator is TRUE), and it is not possible for
opposite operators to both be TRUE.

*/

#import "DoubleInterval.h"

@interface DoubleIntervalWarn: DoubleInterval {
  BOOL last_op_err;
}

/* New methods for this class */

-(BOOL)detectedError;

/* Methods to override from DoubleInterval */

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
