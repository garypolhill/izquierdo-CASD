/*
    FEARLUS model0-6-4: MiscFunc.h
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


This is a class containing miscellaneous functions. It has no instance
variables, and only class methods. Each class method can be treated as a
function that is called in an Objective style, rather than a C style.

*/

#import <objectbase/SwarmObject.h>
#import <sys/types.h>
#import <sys/stat.h>
#import <errno.h>
#import <string.h>
#import <objc/objc-api.h>
#import <collections.h>
#import <random.h>

#define XTRAFILEDIGITS 5

@interface MiscFunc: SwarmObject {
}

+(int)Mod: (int)n inRange0To: (int)max;
+(char *)getUsableFileNameFrom: (const char *)aName
		    withSuffix: (const char *)aSuffix;
+(char *)enforceSuffix: (const char *)aSuffix inFileName: (const char *)aName;
+(void)mergeSort: (id <Collection>)list withSelector: (SEL)aSel;
+(void)shuffleList: (id <List>)list;
+(BOOL)fileExists: (const char *)file;
+(unsigned long long)combineN: (int)n r: (int)r;
+(unsigned)getNextPrime: (unsigned)n;
+(BOOL)isPrime: (unsigned)n;

@end
