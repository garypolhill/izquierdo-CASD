/*
    FEARLUS model0-6-4: Tube.h
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


This is a data structure to assist with doing memory. You assign a fixed length
to the tube, and push things in the top. You can get any object from within
the tube, but once there are enough objects in the tube, each time you push
something in the tube, something else drops off the other end. You can
reassign the tube's length. The intention is this can be used to store the
memory in the land parcel. Each time a land parcel changes owner, it will have
to empty the tube (maybe), and definitely reset the length of the tube to the
memory of the new owning land manager.

An object's index in a Tube does not remain constant. When a new item is
pushed into the Tube, the indexes will increment by one. The getObject method's
argument is the nth most recent object put in.

*/

#import <objectbase/SwarmObject.h>
#import <collections/Array.h>

@interface Tube: SwarmObject {
  id <Array> arr;			/* Object used to store the Tube */
  int nextSlot;				/* Current position in the array of
					   the next place to push into */
  int lastElement;			/* The length of the array - 1, for
					   convenience */
  BOOL zeroLength;			/* Allow zero length tubes, but the
					   array object won't be happy about
					   that, so deal with it using this
					   flag */
  int nItems;				/* Keep a record of the number of
					   items actually stored in the Tube */
}

+create: aZone setLength: (unsigned)len;
-(unsigned)getLength;
-(void)resetLength: (unsigned)len;	/* This will also clear the Tube */
-(void)resetLengthDrop: (unsigned)len;	/* Clear the Tube dropping every
					   element in it */
-pushItem: anObj;			/* Returns any item dropped off in case
					   it is to be dropped */
-(void)pushItemDrop: anObj;		/* Drops an item dropped off the end of
					   the tube */
-getObject: (unsigned)n;		/* This is the nth most recent object
					   pushed into the Tube */
-(void)drop;

-print;

@end
