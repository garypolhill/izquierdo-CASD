/*
    FEARLUS model0-6-4: Tuple.h
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


Interface for the Tuple object. This is an object that stores two objects
together. These objects will be called alpha and beta, for no particularly
good reason.

This is subclassed from Number so that you can associate an object with a
number.

*/

#import "Number.h"

@interface Tuple: Number {
  id alpha;
  id beta;
}

+create: aZone setAlpha: obj1 beta: obj2;
-setAlpha: obj1 beta: obj2;
-setAlpha: obj1;
-setBeta: obj2;
-getAlpha;
-getBeta;
-setObj: obj;
-getObj;

@end
