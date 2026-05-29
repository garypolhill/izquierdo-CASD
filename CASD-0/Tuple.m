/*
    FEARLUS model0-6-4: Tuple.m
    Copyright (C) 1999-2002  Macaulay Institute

    This file is part of FEARLUS model0-6-4, an agent-based model of land use
    change.

    FEARLUS model0-6-4 is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    FEARLUS model0-6-4 is distributed in the hope that it will be useful,
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


Implementation for the Tuple object.

*/

#import "Tuple.h"

@implementation Tuple

+create: aZone setAlpha: obj1 beta: obj2 {
  Tuple *obj;

  obj = [super create: aZone];
  obj->alpha = obj1;
  obj->beta = obj2;

  return obj;
}

-setAlpha: obj1 beta: obj2 {
  alpha = obj1;
  beta = obj2;

  return self;
}

-setAlpha: obj1 {
  alpha = obj1;

  return self;
}

-setBeta: obj2 {
  beta = obj2;

  return self;
}

-getAlpha {
  return alpha;
}

-getBeta {
  return beta;
}

-setObj: obj {
  alpha = obj;
  return self;
}

-getObj {
  return alpha;
}

@end
