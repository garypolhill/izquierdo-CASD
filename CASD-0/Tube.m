/*
    FEARLUS model0-6-4: Tube.m
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


Implementation of Tube object. A Swarm array is used to store the Tube. Rather
than increment all the indexes of the elements, we use a variable to store the
next available slot. When an object is pushed, this variable is incremented.
When the variable is incremented beyond the end of the array, it is reset to 0.
The getObject method then counts back from the variable n + 1 times to
retrieve the object.

*/

#import "Tube.h"
#import "MiscFunc.h"

@implementation Tube

/*

create:setLength:

Creation method. Builds the array and initialises the variables.

*/

+create: aZone setLength: (unsigned)len {
  Tube *anObj;

  anObj = [super create: aZone];
  anObj->arr = [Array create: aZone setCount: len];
  anObj->nextSlot = 0;
  anObj->lastElement = (int)len - 1;
  anObj->zeroLength = NO;
  anObj->nItems = 0;

  return anObj;
}

/*

getLength

Return the length of the tube

*/

-(unsigned)getLength {
  return lastElement + 1;
}

/*

resetLength:

Change the length of the Tube. This also has the effect of removing all
elements from it

*/

-(void)resetLength: (unsigned)len {
  int i;

  for(i = 0; i < [arr getCount]; i++) {
    [arr atOffset: i put: nil];
  }
  if(len == 0) {
    zeroLength = YES;
  }
  else {
    zeroLength = NO;
    [arr setCount: len];
  }
  nextSlot = 0;
  lastElement = (int)len - 1;
  nItems = 0;
}

/*

resetLengthDrop:

Change the length of the Tube, dropping all elements from it.

*/

-(void)resetLengthDrop: (unsigned)len {
  [arr forEach: M(drop)];
  [self resetLength: len];
}

/*

pushItem:

Push an item into the Tube, returning any item pushed out.

*/

-pushItem: anObj {
  id oldObj;

  if(zeroLength) return nil;
  oldObj = [arr atOffset: nextSlot put: anObj];
  nextSlot++;
  if(nItems <= lastElement) nItems++;
  if(nextSlot > lastElement) nextSlot = 0;

  return oldObj;
}

/*

pushItemDrop:

Push an item into the Tube, dropping any item pushed out.

*/

-(void)pushItemDrop: anObj {
  id oldObj = [self pushItem: anObj];

  if(oldObj != nil) [oldObj drop];
}

/*

getObject:

Return the nth from last item pushed into the Tube. This could be nil if the
tube isn't full yet.

*/

-getObject: (unsigned)n {
  if(zeroLength) return nil;
  if((int)n > lastElement) return nil;
  return [arr atOffset: [MiscFunc Mod: (nextSlot - (int)n - 1)
				  inRange0To: lastElement + 1]];
}

/*

drop

Free up the memory from the array object.

*/

-(void)drop {
  //[arr removeAll];
  [arr drop];
  [super drop];
}

/*

print

Print the tube. Will call the print method of items if they have it.

*/

-print {
  int i;

  printf("Displaying contents of Tube <%p>:\n", self);
  printf("\tRecency\tContents\n");
  for(i = 0; i <= lastElement; i++) {
    id obj;

    printf("\t%d\t", i);
    obj = [self getObject: (unsigned)i];
    if(obj == nil) {
      printf("<nil>\n");
    }
    else {
      printf("<%p>", obj);
      if([obj respondsTo: M(print)]) {
	printf(" ");
	[obj print];
      }
      printf("\n");
    }
  }   
  return self;
}

@end
