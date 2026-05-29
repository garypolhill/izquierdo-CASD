/*
    CharityWorld: DoubleIntervalWarn.m
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

Implementation of DoubleIntervalWarn class

*/

#import "DoubleIntervalWarn.h"
#import <float.h>

#define XTRA_DIG 2		// Number of extra digits to add to DBL_DIG to
				// show up any inaccuracy

#define WARN(method, opposite, valuecmd, errstr) \
  BOOL retval; \
  if([super method: value]) { \
    last_op_err = NO; \
    retval = YES; \
  } \
  else if(![super opposite: value]) { \
    fprintf(stderr, "Detected uncertainty comparing "); \
    [self write: stderr sf: DBL_DIG + XTRA_DIG]; \
    fprintf(stderr, " and "); \
    valuecmd; \
    fprintf(stderr, ": %s\n", errstr); \
    last_op_err = YES; \
    retval = NO; \
  } \
  else { \
    last_op_err = NO; \
    retval = NO; \
  } \
  return retval


@implementation DoubleIntervalWarn

/* New methods for this class */

-(BOOL)detectedError {
  return last_op_err;
}

/* Methods to override from DoubleInterval */

-(BOOL)eq: (DoubleSimple *)value {
  WARN(eq, ne, [value write: stderr sf: DBL_DIG + XTRA_DIG], "!eq and !ne");
}

-(BOOL)ne: (DoubleSimple *)value {
  WARN(ne, eq, [value write: stderr sf: DBL_DIG + XTRA_DIG], "!ne and !eq");
}

-(BOOL)gt: (DoubleSimple *)value {
  WARN(gt, le, [value write: stderr sf: DBL_DIG + XTRA_DIG], "!gt and !le");
}

-(BOOL)le: (DoubleSimple *)value {
  WARN(le, gt, [value write: stderr sf: DBL_DIG + XTRA_DIG], "!le and !gt");
}

-(BOOL)ge: (DoubleSimple *)value {
  WARN(ge, lt, [value write: stderr sf: DBL_DIG + XTRA_DIG], "!ge and !lt");
}

-(BOOL)lt: (DoubleSimple *)value {
  WARN(lt, ge, [value write: stderr sf: DBL_DIG + XTRA_DIG], "!lt and !ge");
}


-(BOOL)ieq: (int)value {
  WARN(ieq, ine, fprintf(stderr, "%d", value), "!ieq and !ine");
}

-(BOOL)ine: (int)value {
  WARN(ine, ieq, fprintf(stderr, "%d", value), "!ine and !ieq");
}

-(BOOL)igt: (int)value {
  WARN(igt, ile, fprintf(stderr, "%d", value), "!igt and !ile");
}

-(BOOL)ile: (int)value {
  WARN(ile, igt, fprintf(stderr, "%d", value), "!ile and !igt");
}

-(BOOL)ige: (int)value {
  WARN(ige, ilt, fprintf(stderr, "%d", value), "!ige and !ilt");
}

-(BOOL)ilt: (int)value {
  WARN(ilt, ige, fprintf(stderr, "%d", value), "!ilt and !ige");
}


-(BOOL)ceq: (double)value {
  WARN(ceq, cne, fprintf(stderr, "%.*e", DBL_DIG + XTRA_DIG - 1, value),
       "!ceq and !cne");
}

-(BOOL)cne: (double)value {
  WARN(cne, ceq, fprintf(stderr, "%.*e", DBL_DIG + XTRA_DIG - 1, value),
       "!cne and !ceq");
}

-(BOOL)cgt: (double)value {
  WARN(cgt, cle, fprintf(stderr, "%.*e", DBL_DIG + XTRA_DIG - 1, value),
       "!cgt and !cle");
}

-(BOOL)cle: (double)value {
  WARN(cle, cgt, fprintf(stderr, "%.*e", DBL_DIG + XTRA_DIG - 1, value),
       "!cle and !cgt");
}

-(BOOL)cge: (double)value {
  WARN(cge, clt, fprintf(stderr, "%.*e", DBL_DIG + XTRA_DIG - 1, value),
       "!cge and !clt");
}

-(BOOL)clt: (double)value {
  WARN(clt, cge, fprintf(stderr, "%.*e", DBL_DIG + XTRA_DIG - 1, value),
       "!clt and !cge");
}

@end
