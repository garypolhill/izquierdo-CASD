/*
    CharityWorld: DoubleInterval.m
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

Implementation of DoubleInterval class.

*/

#import "DoubleInterval.h"
#import <float.h>
#ifdef INTEL
#import <CIieeefp.h>
#else
#import <ieeefp.h>
#endif
#import <math.h>
#import <string.h>
#import <stdlib.h>
#import <errno.h>

static BOOL pos(double num) {
  fpclass_t flt_type = fpclass(num);

  return (flt_type == FP_PINF || flt_type == FP_PDENORM
	  || flt_type == FP_PZERO || flt_type == FP_PNORM) ? YES : NO;
}

static BOOL neg(double num) {
  fpclass_t flt_type = fpclass(num);

  return (flt_type == FP_NINF || flt_type == FP_NDENORM
	  || flt_type == FP_NZERO || flt_type == FP_NNORM) ? YES : NO;
}

#ifdef INTEL
static fp_pctl save_pctl;
#endif

@implementation DoubleInterval

/* New methods for this class */

-(double)min {
  return min;
}

-(double)max {
  return max;
}

-(BOOL)intersect: (DoubleInterval *)value {
  if(!(min > [value max]) && !([value min] > max)) {
    return YES;
  }
  else {
    return NO;
  }
}

-(BOOL)notIntersect: (DoubleSimple *)value {
  if([value isKindOf: [DoubleInterval class]]) {
    return (([(DoubleInterval *)value min] > max)
	    || (min > [(DoubleInterval *)value max])) ? YES : NO;
  }
  else {
    double v = [value get];
    return ((v > max) || (min > v)) ? YES : NO;
  }
}

-(BOOL)subset: (DoubleInterval *)value {
  return ((min > [value min]) && (max < [value max])) ? YES : NO;
}

-(BOOL)subsetEq: (DoubleInterval *)value {
  return ((min >= [value min]) && (max <= [value max])) ? YES : NO;
}

-(BOOL)superset: (DoubleSimple *)value {
  if([value isKindOf: [DoubleInterval class]]) {
    return ((min < [(DoubleInterval *)value min])
	    && (max > [(DoubleInterval *)value max])) ? YES : NO;
  }
  else {
    double v = [value get];

    return ((min < v) && (max > v)) ? YES : NO;
  }
}

-(BOOL)supersetEq: (DoubleSimple *)value {
  if([value isKindOf: [DoubleInterval class]]) {
    return ((min <= [(DoubleInterval *)value min])
	    && (max >= [(DoubleInterval *)value max])) ? YES : NO;
  }
  else {
    double v = [value get];

    return ((min <= v) && (max >= v)) ? YES : NO;
  }
}

/* Methods to override from DoubleSimple */

/*

parseValue:

A value may be written in one of the following ways:

(a) [min,max]   -- d = min + (max - min) / 2.0, super called with dummy string

(b) [(min),max] -- d = max, super called pointing to max

(c) [min,(max)] -- d = min, super called pointing to min

(d) [min,d,max] -- super called pointing to d

(e) d           -- min = max = d, supper called pointing to d

*/

+parseValue: (char *)str {
  char *opensq, *closesq, *openro, *closero, *comma1, *comma2;
  DoubleInterval *obj;

  opensq = strchr(str, (int)'[');
  if(opensq == NULL) {		// Case (e)
    fp_rnd default_rnd = fpgetround();

    obj = [super parseValue: str];
    fpsetround(FP_RM);
    obj->min = atof(str);
    fpsetround(FP_RP);
    obj->max = atof(str);
    fpsetround(default_rnd);
    return obj;
  }
  opensq++;
  closesq = strchr(opensq, (int)']');
  if(closesq == NULL) {
    fprintf(stderr, "Error in value string %s -- can't find ']'\n", str);
    abort();
  }
  (*closesq) = '\0';
  comma1 = strchr(opensq, (int)',');
  if(comma1 == NULL) {
    fprintf(stderr, "Error in value string %s -- can't find ','\n", str);
    abort();
  }
  (*comma1) = '\0';
  comma1++;
  comma2 = strchr(comma1, (int)',');
  if(comma2 != NULL) {		// Case (d)
    (*comma2) = '\0';
    comma2++;
    obj = [super parseValue: comma1];
#ifdef INTEL
    save_pctl = fpsetprecision(FP_PC_DBL);
#endif
    obj->min = atof(opensq);
    obj->max = atof(comma2);
#ifdef INTEL
    fpsetprecision(save_pctl);
#endif
    if(obj->d > obj->max || obj->min > obj->d) {
      fprintf(stderr, "Error in value string %s -- values not in ascending "
	      "order\n", str);
      abort();
    }
    return obj;
  }
  openro = strchr(opensq, (int)'(');
  if(openro != NULL) {		// Case (a)
    char *dummy;
    size_t dummy_size;
    double minstr;
    double maxstr;
    
#ifdef INTEL
    save_pctl = fpsetprecision(FP_PC_DBL);
#endif
    minstr = atof(opensq);
    maxstr = atof(comma1);
#ifdef INTEL
    fpsetprecision(save_pctl);
#endif
    if(minstr > maxstr) {
      fprintf(stderr, "Error in value string %s -- minimum more than "
	      "maximum\n", str);
      abort();
    }
    dummy_size = (size_t)(DBL_DIG + 5);
    dummy = (char *)malloc(dummy_size);
    if(dummy == NULL) {
      perror("Memory allocation");
      abort();
    }
    snprintf(dummy, dummy_size, "%.*e", DBL_DIG,
	     minstr + ((maxstr - minstr) / 2.0));
    obj = [super parseValue: dummy];
    free(dummy);
    obj->min = minstr;
    obj->max = maxstr;
    return obj;
  }
  openro++;
  closero = strchr(openro, (int)')');
  if(closero == NULL) {
    fprintf(stderr, "Error in value string %s -- can't find ')'\n", str);
    abort();
  }
  (*closero) = '\0';
  if(openro < comma1) {		// Case (b)
    obj = [super parseValue: comma1];
    obj->max = obj->d;
#ifdef INTEL
    save_pctl = fpsetprecision(FP_PC_DBL);
#endif
    obj->min = atof(openro);
#ifdef INTEL
    fpsetprecision(save_pctl);
#endif
  }
  else {			// Case (c)
    obj = [super parseValue: opensq];
    obj->min = obj->d;
#ifdef INTEL
    save_pctl = fpsetprecision(FP_PC_DBL);
#endif
    obj->max = atof(openro);
#ifdef INTEL
    fpsetprecision(save_pctl);
#endif
  }
  if(obj->min > obj->max) {
    fprintf(stderr, "Error in value string %s -- minimum more than "
	    "maximum\n", str);
    abort();
  }
  return obj;
}

+newUp {
  DoubleInterval *obj = [super newUp];

  obj->min = obj->max = obj->d;

  return obj;
}

-set: (DoubleSimple *)value {
  [super set: value];
  if([value isKindOf: [DoubleInterval class]]) {
    min = [(DoubleInterval *)value min];
    max = [(DoubleInterval *)value max];
  }
  else {
    min = d;
    max = d;
  }
  return self;
}

-cset: (double)value {
  [super cset: value];
  min = max = d;
  return self;
}

-setStr: (char *)str {
  fp_rnd default_rnd = fpgetround();
  double tmp;

  [super setStr: str];
  tmp = d;

  fpsetround(FP_RM);
  [super setStr: str];
  min = d;
  fpsetround(FP_RP);
  [super setStr: str];
  max = d;
  d = tmp;
  fpsetround(default_rnd);
  return self;
}

-write: (FILE *)fp {
  double tmp = d;

  fprintf(fp, "[");
  if(d == min) {
    [super write: fp];
    fprintf(fp, ",(");
    d = max;
    [super write: fp];
    d = tmp;
    fprintf(fp, ")");
  }
  else if(d == max) {
    fprintf(fp, "(");
    d = min;
    [super write: fp];
    d = tmp;
    fprintf(fp, "),");
    [super write: fp];
  }
  else {
    d = min;
    [super write: fp];
    d = tmp;
    fprintf(fp, ",");
    [super write: fp];
    fprintf(fp, ",");
    d = max;
    [super write: fp];
    d = tmp;
  }
  fprintf(fp, "]");
  return self;
}

-write: (FILE *)fp sf: (int)sigfig {
  double tmp = d;

  fprintf(fp, "[");
  if(d == min) {
    [super write: fp sf: sigfig];
    fprintf(fp, ",(");
    d = max;
    [super write: fp sf: sigfig];
    d = tmp;
    fprintf(fp, ")");
  }
  else if(d == max) {
    fprintf(fp, "(");
    d = min;
    [super write: fp sf: sigfig];
    d = tmp;
    fprintf(fp, "),");
    [super write: fp sf: sigfig];
  }
  else {
    d = min;
    [super write: fp sf: sigfig];
    d = tmp;
    fprintf(fp, ",");
    [super write: fp sf: sigfig];
    fprintf(fp, ",");
    d = max;
    [super write: fp sf: sigfig];
    d = tmp;
  }
  fprintf(fp, "]");
  return self;
}

-writeAccurately: (FILE *)fp {
  double tmp = d;

  fprintf(fp, "[");
  if(d == min) {
    [super writeAccurately: fp];
    fprintf(fp, ",(");
    d = max;
    [super writeAccurately: fp];
    d = tmp;
    fprintf(fp, ")");
  }
  else if(d == max) {
    fprintf(fp, "(");
    d = min;
    [super writeAccurately: fp];
    d = tmp;
    fprintf(fp, "),");
    [super writeAccurately: fp];
  }
  else {
    d = min;
    [super writeAccurately: fp];
    d = tmp;
    fprintf(fp, ",");
    [super writeAccurately: fp];
    fprintf(fp, ",");
    d = max;
    [super writeAccurately: fp];
    d = tmp;
  }
  fprintf(fp, "]");
  return self;
}

-abs {
  [super abs];
#ifdef INTEL
  save_pctl = fpsetprecision(FP_PC_DBL);
#endif
  if(min < 0.0 && max > 0.0) {
    max = fabs(min) > max ? fabs(min) : max;
    min = 0.0;
  }
  else if(max < 0.0) {
    double tmp;

    tmp = fabs(min);
    min = fabs(max);
    max = tmp;
  }
#ifdef INTEL
  fpsetprecision(save_pctl);
#endif
  return self;
}

-add: (DoubleSimple *)value {
  double tmp, vmin, vmax;
  fp_rnd default_rnd = fpgetround();

  if([value isKindOf: [DoubleInterval class]]) {
    vmin = [(DoubleInterval *)value min];
    vmax = [(DoubleInterval *)value max];
  }
  else {
    vmax = vmin = [value get];
  }
  [super add: value];
  tmp = d;
  d = min;
  fpsetround(FP_RM);
  [super cadd: vmin];
  min = d;
  d = max;
  fpsetround(FP_RP);
  [super cadd: vmax];
  max = d;
  d = tmp;
  fpsetround(default_rnd);
  return self;
}

-sub: (DoubleSimple *)value {
  double tmp, vmin, vmax;
  fp_rnd default_rnd = fpgetround();

  if([value isKindOf: [DoubleInterval class]]) {
    vmin = [(DoubleInterval *)value min];
    vmax = [(DoubleInterval *)value max];
  }
  else {
    vmax = vmin = [value get];
  }
  [super sub: value];
  tmp = d;
  d = min;
  fpsetround(FP_RM);
  [super csub: vmax];
  min = d;
  d = max;
  fpsetround(FP_RP);
  [super csub: vmin];
  max = d;
  d = tmp;
  fpsetround(default_rnd);
  return self;
}

/*

mul:

Which of self's and value's min and max values to use to generate the minimum
and maximum product depends entirely on the sign of each. There are nine
possibilities for min and max of self and value's signs:

(i)	min+, max+, vmin+, vmax+ : pmin = min * vmin, pmax = max * vmax
(ii)	min+, max+, vmin-, vmax+ : pmin = max * vmin, pmax = max * vmax
(iii)	min+, max+, vmin-, vmax- : pmin = max * vmin, pmax = min * vmax
(iv)	min-, max+, vmin+, vmax+ : pmin = min * vmax, pmax = max * vmax

(v)	min-, max+, vmin-, vmax+ : pmin = MIN(min * vmax, max * vmin)
                                   pmax = MAX(min * vmin, max * vmax)

(vi)	min-, max+, vmin-, vmax- : pmin = max * vmin, pmax = min * vmin
(vii)	min-, max-, vmin+, vmax+ : pmin = min * vmax, pmax = max * vmin
(viii)	min-, max-, vmin-, vmax+ : pmin = min * vmax, pmax = min * vmin
(ix)	min-, max-, vmin-, vmax- : pmin = max * vmax, pmax = min * vmin

*/

-mul: (DoubleSimple *)value {
  double vmin, vmax;
  double minProd, maxProd, vminProd, vmaxProd;
  fp_rnd default_rnd = fpgetround();
  double tmp;

  if([value isKindOf: [DoubleInterval class]]) {
    vmin = [(DoubleInterval *)value min];
    vmax = [(DoubleInterval *)value max];
  }
  else {
    vmax = vmin = [value get];
  }

  [super mul: value];

  if(pos(min)) {		// (i), (ii), (iii)
    vminProd = vmin;
    vmaxProd = vmax;
    if(pos(vmin)) {		// (i)
      minProd = min;
      maxProd = max;
    }
    else {			// (ii), (iii)
      minProd = max;
      if(pos(vmax)) {		// (ii)
	maxProd = max;
      }
      else {			// (iii)
	maxProd = min;
      }
    }
  }
  else {			// (iv), (v), (vi), (vii), (viii), (ix)
    if(neg(max)) {		// (vii), (viii), (ix)
      vminProd = vmax;
      vmaxProd = vmin;
      if(pos(vmin)) {		// (vii)
	minProd = min;
	maxProd = max;
      }
      else {			// (viii), (ix)
	maxProd = min;
	if(pos(vmax)) {		// (viii)
	  minProd = min;
	}
	else {			// (ix)
	  minProd = max;
	}
      }
    }
    else if(pos(vmin)) {	// (iv)
      vminProd = vmax;
      vmaxProd = vmax;
      minProd = min;
      maxProd = max;
    }
    else if(neg(vmax)) {	// (vi)
      vminProd = vmin;
      vmaxProd = vmin;
      minProd = max;
      maxProd = min;
    }
    else {			// (v) (sigh!)
      double try1min, try2min, try1max, try2max;

      tmp = d;
      fpsetround(FP_RM);
      d = min;
      [super cmul: vmax];
      try1min = d;
      d = max;
      [super cmul: vmin];
      try2min = d;
      fpsetround(FP_RP);
      d = min;
      [super cmul: vmin];
      try1max = d;
      d = max;
      [super cmul: vmax];
      try2max = d;
      fpsetround(default_rnd);
      d = tmp;
      min = (try1min < try2min) ? try1min : try2min;
      max = (try1max > try2max) ? try1max : try2max;
      return self;
    }
  }
  tmp = d;
  d = minProd;
  fpsetround(FP_RM);
  [super cmul: vminProd];
  min = d;
  d = maxProd;
  fpsetround(FP_RP);
  [super cmul: vmaxProd];
  max = d;
  d = tmp;
  fpsetround(default_rnd);

  return self;
}

/*

div:

Similarly to mul:, the minimum and maximum result depends on the signs of the
operands. Mostly, vmin and vmax are swapped in the operands in comparison with
mul:, but when they have a different sign this does not apply -- i.e. in
(ii), (viii), and (v) there is no change from
mul:.

(i)	min+, max+, vmin+, vmax+ : dmin = min / vmax, dmax = max / vmin
(ii)	min+, max+, vmin-, vmax+ : dmin = max / vmin, dmax = max / vmax
(iii)	min+, max+, vmin-, vmax- : dmin = max / vmax, dmax = min / vmin
(iv)	min-, max+, vmin+, vmax+ : dmin = min / vmin, dmax = max / vmin

(v)	min-, max+, vmin-, vmax+ : dmin = MIN(min / vmax, max / vmin)
                                   dmax = MAX(min / vmin, max / vmax)

(vi)	min-, max+, vmin-, vmax- : dmin = max / vmax, dmax = min / vmax
(vii)	min-, max-, vmin+, vmax+ : dmin = min / vmin, dmax = max / vmax
(viii)	min-, max-, vmin-, vmax+ : dmin = min / vmax, dmax = min / vmin
(ix)	min-, max-, vmin-, vmax- : dmin = max / vmin, pmax = min / vmax

*/

-div: (DoubleSimple *)value {
  double vmin, vmax;
  double minDiv, maxDiv, vminDiv, vmaxDiv;
  fp_rnd default_rnd = fpgetround();
  double tmp;

  if([value isKindOf: [DoubleInterval class]]) {
    vmin = [(DoubleInterval *)value min];
    vmax = [(DoubleInterval *)value max];
  }
  else {
    vmax = vmin = [value get];
  }

  [super div: value];

  if(pos(min)) {		// (i), (ii), (iii)
    vminDiv = vmax;
    vmaxDiv = vmin;
    if(pos(vmin)) {		// (i)
      minDiv = min;
      maxDiv = max;
    }
    else {			// (ii), (iii)
      minDiv = max;
      if(pos(vmax)) {		// (ii)
	maxDiv = max;
	vminDiv = vmin;
	vmaxDiv = vmax;
      }
      else {			// (iii)
	maxDiv = min;
      }
    }
  }
  else {			// (iv), (v), (vi), (vii), (viii), (ix)
    if(neg(max)) {		// (vii), (viii), (ix)
      vminDiv = vmin;
      vmaxDiv = vmax;
      if(pos(vmin)) {		// (vii)
	minDiv = min;
	maxDiv = max;
      }
      else {			// (viii), (ix)
	maxDiv = min;
	if(pos(vmax)) {		// (viii)
	  minDiv = min;
	  vminDiv = vmax;
	  vmaxDiv = vmin;
	}
	else {			// (ix)
	  minDiv = max;
	}
      }
    }
    else if(pos(vmin)) {	// (iv)
      vminDiv = vmin;
      vmaxDiv = vmin;
      minDiv = min;
      maxDiv = max;
    }
    else if(neg(vmax)) {	// (vi)
      vminDiv = vmax;
      vmaxDiv = vmax;
      minDiv = max;
      maxDiv = min;
    }
    else {			// (v) (sigh!)
      double try1min, try2min, try1max, try2max;

      tmp = d;
      fpsetround(FP_RM);
      d = min;
      [super cdiv: vmax];
      try1min = d;
      d = max;
      [super cdiv: vmin];
      try2min = d;
      fpsetround(FP_RP);
      d = min;
      [super cdiv: vmin];
      try1max = d;
      d = max;
      [super cdiv: vmax];
      try2max = d;
      fpsetround(default_rnd);
      d = tmp;
      min = (try1min < try2min) ? try1min : try2min;
      max = (try1max > try2max) ? try1max : try2max;
      return self;
    }
  }
  tmp = d;
  d = minDiv;
  fpsetround(FP_RM);
  [super cdiv: vminDiv];
  min = d;
  d = maxDiv;
  fpsetround(FP_RP);
  [super cdiv: vmaxDiv];
  max = d;
  d = tmp;
  fpsetround(default_rnd);
  return self;
}

-iadd: (int)value {
  double tmp, vmin, vmax;
  fp_rnd default_rnd = fpgetround();

  vmax = vmin = (double)value;
  [super iadd: value];
  tmp = d;
  d = min;
  fpsetround(FP_RM);
  [super cadd: vmin];
  min = d;
  d = max;
  fpsetround(FP_RP);
  [super cadd: vmax];
  max = d;
  d = tmp;
  fpsetround(default_rnd);
  return self;
}

-isub: (int)value {
  double tmp, vmin, vmax;
  fp_rnd default_rnd = fpgetround();

  vmax = vmin = (double)value;
  [super isub: value];
  tmp = d;
  d = min;
  fpsetround(FP_RM);
  [super csub: vmax];
  min = d;
  d = max;
  fpsetround(FP_RP);
  [super csub: vmin];
  max = d;
  d = tmp;
  fpsetround(default_rnd);
  return self;
}

/*

imul:

Similarly to mul:, the minimum and maximum result depends on the signs
of the operands. Since the argument is not an interval, however, there
are three fewer options to consider.

(i)	min+, max+, arg+ : pmin = min * arg, pmax = max * arg
(ii)	min+, max+, arg- : pmin = max * arg, pmax = min * arg
(iii)	min-, max+, arg+ : pmin = min * arg, pmax = max * arg
(iv)	min-, max+, arg- : pmin = max * arg, pmax = min * arg
(v)	min-, max-, arg+ : pmin = min * arg, pmax = max * arg
(vi)	min-, max-, arg- : pmin = max * arg, pmax = min * arg

*/

-imul: (int)value {
  double arg = (double)value;
  double minProd, maxProd;
  fp_rnd default_rnd = fpgetround();
  double tmp;

  [super imul: value];

  if(pos(arg)) {		// (i), (iii), (v)
    minProd = min;
    maxProd = max;
  }
  else {			// (ii), (iv), (vi)
    minProd = max;
    maxProd = min;
  }

  tmp = d;

  d = minProd;
  fpsetround(FP_RM);
  [super cmul: arg];
  min = d;
  d = maxProd;
  fpsetround(FP_RP);
  [super cmul: arg];
  max = d;
  d = tmp;
  fpsetround(default_rnd);

  return self;
}

/*

idiv:

As div: is similar to mul:, do idiv: is to imul: The former pair
differ only in which of the range delimiters of the argument to use as
operands, however, and thus, since idiv: and imul: have a non-interval
argument, their behaviour should be identical.

*/

-idiv: (int)value {
  double arg = (double)value;
  double minDiv, maxDiv;
  fp_rnd default_rnd = fpgetround();
  double tmp;

  [super idiv: value];

  if(pos(arg)) {		// (i), (iii), (v)
    minDiv = min;
    maxDiv = max;
  }
  else {			// (ii), (iv), (vi)
    minDiv = max;
    maxDiv = min;
  }

  tmp = d;

  d = minDiv;
  fpsetround(FP_RM);
  [super cdiv: arg];
  min = d;
  d = maxDiv;
  fpsetround(FP_RP);
  [super cdiv: arg];
  max = d;
  d = tmp;
  fpsetround(default_rnd);

  return self;
}

-cadd: (double)value {
  double tmp, vmin, vmax;
  fp_rnd default_rnd = fpgetround();

  vmax = vmin = value;
  [super cadd: value];
  tmp = d;
  d = min;
  fpsetround(FP_RM);
  [super cadd: vmin];
  min = d;
  d = max;
  fpsetround(FP_RP);
  [super cadd: vmax];
  max = d;
  d = tmp;
  fpsetround(default_rnd);
  return self;
}

-csub: (double)value {
  double tmp, vmin, vmax;
  fp_rnd default_rnd = fpgetround();

  vmax = vmin = value;
  [super csub: value];
  tmp = d;
  d = min;
  fpsetround(FP_RM);
  [super csub: vmax];
  min = d;
  d = max;
  fpsetround(FP_RP);
  [super csub: vmin];
  max = d;
  d = tmp;
  fpsetround(default_rnd);
  return self;
}

/*

cmul:

cmul:'s behaviour is the same as imul: except there is no cast.

*/

-cmul: (double)value {
  double minProd, maxProd;
  fp_rnd default_rnd = fpgetround();
  double tmp;

  [super cmul: value];

  if(pos(value)) {		// (i), (iii), (v)
    minProd = min;
    maxProd = max;
  }
  else {			// (ii), (iv), (vi)
    minProd = max;
    maxProd = min;
  }

  tmp = d;

  d = minProd;
  fpsetround(FP_RM);
  [super cmul: value];
  min = d;
  d = maxProd;
  fpsetround(FP_RP);
  [super cmul: value];
  max = d;
  d = tmp;
  fpsetround(default_rnd);

  return self;
}

/*

cdiv:

cdiv:'s behaviour is the same as idiv: except there is no cast.

*/

-cdiv: (double)value {
  double minDiv, maxDiv;
  fp_rnd default_rnd = fpgetround();
  double tmp;

  [super cdiv: value];

  if(pos(value)) {		// (i), (iii), (v)
    minDiv = min;
    maxDiv = max;
  }
  else {			// (ii), (iv), (vi)
    minDiv = max;
    maxDiv = min;
  }

  tmp = d;

  d = minDiv;
  fpsetround(FP_RM);
  [super cdiv: value];
  min = d;
  d = maxDiv;
  fpsetround(FP_RP);
  [super cdiv: value];
  max = d;
  d = tmp;
  fpsetround(default_rnd);

  return self;
}


-(BOOL)eq: (DoubleSimple *)value {
  double vmax, vmin;

  if([value isKindOf: [DoubleInterval class]]) {
    vmin = [(DoubleInterval *)value min];
    vmax = [(DoubleInterval *)value max];
  }
  else {
    vmin = vmax = [value get];
  }
  if(min == vmin && max == vmax && min == vmax) {
    return YES;
  }
  else {
    return NO;
  }
}

-(BOOL)ne: (DoubleSimple *)value {
  double vmax, vmin;

  if([value isKindOf: [DoubleInterval class]]) {
    vmin = [(DoubleInterval *)value min];
    vmax = [(DoubleInterval *)value max];
  }
  else {
    vmin = vmax = [value get];
  }
  if(vmin > max || min > vmax) {
    return YES;
  }
  else {
    return NO;
  }
}

-(BOOL)gt: (DoubleSimple *)value {
  double vmax;

  if([value isKindOf: [DoubleInterval class]]) {
    vmax = [(DoubleInterval *)value max];
  }
  else {
    vmax = [value get];
  }

  return (min > vmax) ? YES : NO;
}

-(BOOL)le: (DoubleSimple *)value {
  double vmin;

  if([value isKindOf: [DoubleInterval class]]) {
    vmin = [(DoubleInterval *)value min];
  }
  else {
    vmin = [value get];
  }

  return (max <= vmin) ? YES : NO;
}

-(BOOL)ge: (DoubleSimple *)value {
  double vmax;

  if([value isKindOf: [DoubleInterval class]]) {
    vmax = [(DoubleInterval *)value max];
  }
  else {
    vmax = [value get];
  }

  return (min >= vmax) ? YES : NO;
}

-(BOOL)lt: (DoubleSimple *)value {
  double vmin;

  if([value isKindOf: [DoubleInterval class]]) {
    vmin = [(DoubleInterval *)value min];
  }
  else {
    vmin = [value get];
  }

  return (max < vmin) ? YES : NO;
}

-(BOOL)ieq: (int)value {
  double vmax, vmin;

  vmin = vmax = (double)value;
  if(min == vmin && max == vmax && min == vmax) {
    return YES;
  }
  else {
    return NO;
  }
}

-(BOOL)ine: (int)value {
  double vmax, vmin;

  vmin = vmax = (double)value;
  if(vmin > max || min > vmax) {
    return YES;
  }
  else {
    return NO;
  }
}

-(BOOL)igt: (int)value {
  double vmax;

  vmax = (double)value;

  return (min > vmax) ? YES : NO;
}

-(BOOL)ile: (int)value {
  double vmin;

  vmin = (double)value;

  return (max <= vmin) ? YES : NO;
}

-(BOOL)ige: (int)value {
  double vmax;

  vmax = (double)value;

  return (min >= vmax) ? YES : NO;
}

-(BOOL)ilt: (int)value {
  double vmin;

  vmin = (double)value;

  return (max < vmin) ? YES : NO;
}

-(BOOL)ceq: (double)value {
  double vmax, vmin;

  vmin = vmax = value;
  if(min == vmin && max == vmax && min == vmax) {
    return YES;
  }
  else {
    return NO;
  }
}

-(BOOL)cne: (double)value {
  double vmax, vmin;

  vmin = vmax = value;
  if(vmin > max || min > vmax) {
    return YES;
  }
  else {
    return NO;
  }
}

-(BOOL)cgt: (double)value {
  return (min > value) ? YES : NO;
}

-(BOOL)cle: (double)value {
  return (max <= value) ? YES : NO;
}

-(BOOL)cge: (double)value {
  return (min >= value) ? YES : NO;
}

-(BOOL)clt: (double)value {
  return (max < value) ? YES : NO;
}

@end
