/*
    FEARLUS model0-6-4: MiscFunc.m
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


Implementation for the functions declared in MiscFunc.h

*/

#import "MiscFunc.h"
#import "Tuple.h"

@implementation MiscFunc

+(int)Mod: (int)n inRange0To: (int)max {
  if(n < 0) {
    n += (max * ((-n / max) + 1));
  }
  return(n % max);
}

+(char *)getUsableFileNameFrom: (const char *)aName
		    withSuffix: (const char *)aSuffix {
  char *fileActuallyCreated;
  struct stat filestats;
  int counter = 0;
  char *p;

  if(!strcmp(aName, "")) {
    fprintf(stderr, "%s -- NULL filename\n", sel_get_name(_cmd));
    return NULL;
  }
  if(aSuffix[0] != '.') {
    fprintf(stderr, "%s -- Invalid suffix: %s -- must start with a '.'\n",
	    sel_get_name(_cmd), aSuffix);
    return NULL;
  }
  fileActuallyCreated = (char *)malloc(strlen(aName) + strlen(aSuffix)
                          + XTRAFILEDIGITS + 3);
  if(fileActuallyCreated == NULL) {
    fprintf(stderr, "Memory allocation error\n");
    exit(1);
  }
  // The 3 is for the -, the \0 at the end, and one for luck
  strcpy(fileActuallyCreated, aName);
  p = strrchr(fileActuallyCreated, (int)'.');
  if(p == NULL || strcmp(p, aSuffix)) {
    sprintf(fileActuallyCreated, "%s%s", aName, aSuffix);
				// Enforce a .txt suffix
    p = strrchr(fileActuallyCreated, (int)'.');
  }
				// p now points to the . in the .txt suffix
  while(stat(fileActuallyCreated, &filestats) == 0) {
				// Loop while the file exists
    counter++;
    sprintf(p, "-%0*d%s", XTRAFILEDIGITS, counter, aSuffix);
                                // Add a number into the file name
  }
  return fileActuallyCreated;
}

+(char *)enforceSuffix: (const char *)aSuffix inFileName: (const char *)aName {
  char *fileName, *p;
  
  if(!strcmp(aName, "")) {
    fprintf(stderr, "%s -- NULL filename\n", sel_get_name(_cmd));
    return NULL;
  }
  if(aSuffix[0] != '.') {
    fprintf(stderr, "%s -- Invalid suffix: %s -- must start with a '.'\n",
	    sel_get_name(_cmd), aSuffix);
    return NULL;
  }
  p = strrchr(aName, (int)'.');
  if(p == NULL || strcmp(p, aSuffix) != 0) {
    fileName = (char *)malloc(strlen(aName) + strlen(aSuffix) + 3);
    if(fileName == NULL) {
      fprintf(stderr, "Memory allocation error\n");
      exit(1);
    }
    sprintf(fileName, "%s%s", aName, aSuffix);
  }
  else {
    fileName = strdup(aName);
    if(fileName == NULL) {
      fprintf(stderr, "Memory allocation error\n");
      exit(1);
    }
  }
  return fileName;
}

/*

Here's how you get the type returned by the selector:

char type = sel_get_type(sel_get_any_typed_uid(sel_get_name(mySelector)))[0];

(Got this from EZBin.m)

Then the types are defined as follows (for the kinds of things we might be
sorting)

#define _C_CHR      'c'		// char
#define _C_UCHR     'C'		// unsigned char
#define _C_SHT      's'		// short
#define _C_USHT     'S'		// unsigned short
#define _C_INT      'i'		// int
#define _C_UINT     'I'		// unsigned int
#define _C_LNG      'l'		// long
#define _C_ULNG     'L'		// unsigned long
#define _C_FLT      'f'		// float
#define _C_DBL      'd'		// double
#define _C_CHARPTR  '*'		// char *

(Got this from objc-api.h)

Then you get the result of the method like this:

myVar = (* ((TYPE (*) (id, SEL, ...)) [ target methodFor: mySelector] ))
                                                        (target, mySelector);

where TYPE is replaced by whatever type (e.g. char, int, double) the method
returns.

(Got this from EZBin.m)

<private>
In the Obj-C book (p. 87 in the red folder printout), it mentions this. You
get the function that actually implements the method as the result of
[target methodFor: mySelector]

(Though in the book, it is as per NSObject class, with methodForSelector:
instead of methodFor:)

However, you can also call a method by doing [target perform: mySelector]

(Red folder Obj-C book, p. 61, and various Swarm files e.g. QSort.m)

This will presumably return a result of the given type. So, which is the
correct one to use?
</private>

*/

+(void)mergeSort: (id <Collection>)list withSelector: (SEL)aSel {
  // Nested function: merge -- I don't want merge to be callable from
  // outside this method. This is sort of taken from the code in Wilt,
  // N. (1995) "Classical Algorithms in C++: with New Approaches to
  // Sorting, Searching and Selection", John Wiley & Sons.
  void merge(id <Collection> original, int start, int midpoint, int end,
	      id <Array> temp, SEL aSel) {
    int i1, i2, i;
    char ty = sel_get_type(sel_get_any_typed_uid(sel_get_name(aSel)))[0];

    // merge until one of the two halves is done
    for(i1 = start, i2 = midpoint, i = start;
	i1 < midpoint && i2 < end;
	i++) {
      switch(ty) {
	// I *think* the compiler will need to know what types it is checking
	// at compile time. Hence the casts and case for each type.
      case _C_CHARPTR:
	/*	if(strcmp((char *)[[original atOffset: i1] perform: aSel],
		  (char *)[[original atOffset: i2] perform: aSel]) < 0) {
	*/
	if(strcmp( (* ((char * (*)(id, SEL, ...))
		       [ [original atOffset: i1] methodFor: aSel] ))
		   ([original atOffset: i1], aSel), 
		   (* ((char * (*)(id, SEL, ...))
		       [ [original atOffset: i2] methodFor: aSel] ))
		   ([original atOffset: i2], aSel) ) < 0) {
	  [temp atOffset: i put: [original atOffset: i1]];
	  i1++;
	}
	else {
	  [temp atOffset: i put: [original atOffset: i2]];
	  i2++;
	}
	break;
      case _C_CHR:
	/*	if((char)[[original atOffset: i1] perform: aSel]
	   < (char)[[original atOffset: i2] perform: aSel]) {
	*/
	if( (* ((char (*)(id, SEL, ...))
		[ [original atOffset: i1] methodFor: aSel] ))
	    ([original atOffset: i1], aSel)
	    < (* ((char (*)(id, SEL, ...))
		  [ [original atOffset: i2] methodFor: aSel] ))
	    ([original atOffset: i2], aSel) ) {
	  [temp atOffset: i put: [original atOffset: i1]];
	  i1++;
	}
	else {
	  [temp atOffset: i put: [original atOffset: i2]];
	  i2++;
	}
	break;
      case _C_UCHR:
	/*	if((unsigned char)[[original atOffset: i1] perform: aSel]
	   < (unsigned char)[[original atOffset: i2] perform: aSel]) {
	*/
	if( (* ((unsigned char (*)(id, SEL, ...))
		[ [original atOffset: i1] methodFor: aSel] ))
	    ([original atOffset: i1], aSel)
	    < (* ((unsigned char (*)(id, SEL, ...))
		  [ [original atOffset: i2] methodFor: aSel] ))
	    ([original atOffset: i2], aSel) ) {
	  [temp atOffset: i put: [original atOffset: i1]];
	  i1++;
	}
	else {
	  [temp atOffset: i put: [original atOffset: i2]];
	  i2++;
	}
	break;
      case _C_SHT:
	/*	if((short)[[original atOffset: i1] perform: aSel]
	   < (short)[[original atOffset: i2] perform: aSel]) {
	*/
	if( (* ((short (*)(id, SEL, ...))
		[ [original atOffset: i1] methodFor: aSel] ))
	    ([original atOffset: i1], aSel)
	    < (* ((short (*)(id, SEL, ...))
		  [ [original atOffset: i2] methodFor: aSel] ))
	    ([original atOffset: i2], aSel) ) {
	  [temp atOffset: i put: [original atOffset: i1]];
	  i1++;
	}
	else {
	  [temp atOffset: i put: [original atOffset: i2]];
	  i2++;
	}
	break;
      case _C_USHT:
	/*	if((unsigned short)[[original atOffset: i1] perform: aSel]
	   < (unsigned short)[[original atOffset: i2] perform: aSel]) {
	*/
	if( (* ((unsigned short (*)(id, SEL, ...))
		[ [original atOffset: i1] methodFor: aSel] ))
	    ([original atOffset: i1], aSel)
	    < (* ((unsigned short (*)(id, SEL, ...))
		  [ [original atOffset: i2] methodFor: aSel] ))
	    ([original atOffset: i2], aSel) ) {
	  [temp atOffset: i put: [original atOffset: i1]];
	  i1++;
	}
	else {
	  [temp atOffset: i put: [original atOffset: i2]];
	  i2++;
	}
	break;
      case _C_INT:
	/*	if((int)[[original atOffset: i1] perform: aSel]
	   < (int)[[original atOffset: i2] perform: aSel]) {
	*/
	if( (* ((int (*)(id, SEL, ...))
		[ [original atOffset: i1] methodFor: aSel] ))
	    ([original atOffset: i1], aSel)
	    < (* ((int (*)(id, SEL, ...))
		  [ [original atOffset: i2] methodFor: aSel] ))
	    ([original atOffset: i2], aSel) ) {
	  [temp atOffset: i put: [original atOffset: i1]];
	  i1++;
	}
	else {
	  [temp atOffset: i put: [original atOffset: i2]];
	  i2++;
	}
	break;
      case _C_UINT:
	/*	if((unsigned)[[original atOffset: i1] perform: aSel]
	   < (unsigned)[[original atOffset: i2] perform: aSel]) {
	*/
	if( (* ((unsigned (*)(id, SEL, ...))
		[ [original atOffset: i1] methodFor: aSel] ))
	    ([original atOffset: i1], aSel)
	    < (* ((unsigned (*)(id, SEL, ...))
		  [ [original atOffset: i2] methodFor: aSel] ))
	    ([original atOffset: i2], aSel) ) {
	  [temp atOffset: i put: [original atOffset: i1]];
	  i1++;
	}
	else {
	  [temp atOffset: i put: [original atOffset: i2]];
	  i2++;
	}
	break;
      case _C_LNG:
	/*	if((long)[[original atOffset: i1] perform: aSel]
	   < (long)[[original atOffset: i2] perform: aSel]) {
	*/
	if( (* ((long (*)(id, SEL, ...))
		[ [original atOffset: i1] methodFor: aSel] ))
	    ([original atOffset: i1], aSel)
	    < (* ((long (*)(id, SEL, ...))
		  [ [original atOffset: i2] methodFor: aSel] ))
	    ([original atOffset: i2], aSel) ) {
	  [temp atOffset: i put: [original atOffset: i1]];
	  i1++;
	}
	else {
	  [temp atOffset: i put: [original atOffset: i2]];
	  i2++;
	}
	break;
      case _C_ULNG:
	/*	if((unsigned long)[[original atOffset: i1] perform: aSel]
	   < (unsigned long)[[original atOffset: i2] perform: aSel]) {
	*/
	if( (* ((unsigned long (*)(id, SEL, ...))
		[ [original atOffset: i1] methodFor: aSel] ))
	    ([original atOffset: i1], aSel)
	    < (* ((unsigned long (*)(id, SEL, ...))
		  [ [original atOffset: i2] methodFor: aSel] ))
	    ([original atOffset: i2], aSel) ) {
	  [temp atOffset: i put: [original atOffset: i1]];
	  i1++;
	}
	else {
	  [temp atOffset: i put: [original atOffset: i2]];
	  i2++;
	}
	break;
      case _C_FLT:
	/*	if((float)[[original atOffset: i1] perform: aSel]
	   < (float)[[original atOffset: i2] perform: aSel]) {
	*/
	if( (* ((float (*)(id, SEL, ...))
		[ [original atOffset: i1] methodFor: aSel] ))
	    ([original atOffset: i1], aSel)
	    < (* ((float (*)(id, SEL, ...))
		  [ [original atOffset: i2] methodFor: aSel] ))
	    ([original atOffset: i2], aSel) ) {
	  [temp atOffset: i put: [original atOffset: i1]];
	  i1++;
	}
	else {
	  [temp atOffset: i put: [original atOffset: i2]];
	  i2++;
	}
	break;
      case _C_DBL:
	/*	if((double)[[original atOffset: i1] perform: aSel]
	   < (double)[[original atOffset: i2] perform: aSel]) {
	*/
	if( (* ((double (*)(id, SEL, ...))
		[ [original atOffset: i1] methodFor: aSel] ))
	    ([original atOffset: i1], aSel)
	    < (* ((double (*)(id, SEL, ...))
		  [ [original atOffset: i2] methodFor: aSel] ))
	    ([original atOffset: i2], aSel) ) {
	  [temp atOffset: i put: [original atOffset: i1]];
	  i1++;
	}
	else {
	  [temp atOffset: i put: [original atOffset: i2]];
	  i2++;
	}
	break;
      }
    }
    // merge the rest of the other half
    while(i1 < midpoint) {
      [temp atOffset: i put: [original atOffset: i1]];
      i++;
      i1++;
    }
    while(i2 < end) {
      [temp atOffset: i put: [original atOffset: i2]];
      i++;
      i2++;
    }
    // temp now contains the sorted bit, so copy temp back into the original
    for(i = start; i < end; i++) {
      [original atOffset: i put: [temp atOffset: i]];
    }
  }
  // Thus ends the nested merge function 
  // Now begin the mergeSort method:
  int halfLen, start, len;
  int count;
  id <Array> temp;

  count = [list getCount];
  temp = [Array create: scratchZone setCount: count];
  // halfLen is the length of each half of the current merge, len is the length
  // of the two halves together.
  for(halfLen = 1, len = 2;
      len < (2 * count);
      halfLen *= 2, len *= 2) {
    for(start = 0; start < count; start += len) {
      if(start + halfLen < count) {
	int end = (start + len < count) ? start + len : count;

	merge(list, start, start + halfLen, end, temp, aSel);
      }
    }
  }
  [temp drop];
  /* Let's look at the calls you'd get to merge from a 13 element original
     array as you loop around the halfLen/len loop and start nested loop.

     halfLen =  1, len =  2, start =  0: merge(start =  0, mid =  1, end =  2)
                             start =  2: merge(start =  2, mid =  3, end =  4)
			     start =  4: merge(start =  4, mid =  5, end =  6)
			     start =  6: merge(start =  6, mid =  7, end =  8)
			     start =  8: merge(start =  8, mid =  9, end = 10)
			     start = 10: merge(start = 10, mid = 11, end = 12)
			     start = 12: <No call to merge>
				// Merge sort 2 elements at a time
     halfLen =  2, len =  4, start =  0: merge(start =  0, mid =  2, end =  4)
                             start =  4: merge(start =  4, mid =  6, end =  8)
			     start =  8: merge(start =  8, mid = 10, end = 12)
			     start = 12: <No call to merge>
				// Merge sort 4 elements at a time
     halfLen =  4, len =  8, start =  0: merge(start =  0, mid =  4, end =  8)
                             start =  8: merge(start =  8, mid = 12, end = 13)
				// Merge sort 8 elements at a time (or
				// more preceisely, 8 element chunk
				// and then 5 element chunk)
     halfLen =  8, len = 16, start =  0: merge(start =  0, mid =  8, end = 13)
				// Merge sort the whole list

     So, I think it should now be clear how this all works. */
}

/*

shuffleList:

Sort a list in random order by associating a random number with each element
in the list and then sorting by the random number.

<private>
Old version:

This method is needed because I can't get the ListShuffler Swarm object to work
and I haven't got the time to try. It specifically takes a Swarm List object,
which it shuffles by removing items from the head or tail of the list at random
and randomly sticking them into the head or the tail of a temporary list. It
then repeats the process back into the original list.

This does not guarantee a random order to the list, however. Items that were
adjacent in the original list are more likely to be adjacent in the shuffled
list than items that were not adjacent.
</private>

*/

+(void)shuffleList: (id <List>)list {
  id <Array> temp;
  id <Zone> zone;
  int i, c;

  c = [list getCount];
  zone = [Zone create: scratchZone];
  temp = [Array create: zone setCount: c];

  for(i = 0; i < c; i++) {
    Tuple *t = [Tuple create: zone];
    [t setObj: [list removeFirst]];
    [t setDouble: [uniformDblRand getDoubleWithMin: 0.0 withMax: 1.0]];
    [temp atOffset: i put: t];
  }
  [MiscFunc mergeSort: temp withSelector: M(getDouble)];
  for(i = 0; i < c; i++) {
    [list addFirst: (Tuple *)[[temp atOffset: i] getObj]];
  }
  [zone drop];
}

/*

fileExists:

return YES if the file exists, NO if not

*/

+(BOOL)fileExists: (const char *)file {
  struct stat fstat;

  if(stat(file, &fstat) == 0) {
    return YES;
  }
  else {
    return NO;
  }
}

/*

combineN:r:

Return the number of combinations of N things taken r at a time:

N! / (N-r)!r!

*/

+(unsigned long long)combineN: (int)n r: (int)r {
  unsigned long long combinations;
  int i;

  if(n < 0 || r < 0 || r > n) return 0;
  for(combinations = 1, i = n; i > n - r; i--) {
    combinations *= i;
  }
  for(i = r; i > 1; i--) {
    combinations /= i;
  }
  return combinations;
}

/*

getNextPrime:

Return the smallest prime number greater than or equal to the argument.

*/

+(unsigned)getNextPrime: (unsigned)n {
  unsigned b = n;

  for(; n < (unsigned)(-1); n++) {
    if([MiscFunc isPrime: n]) return n;
  }
  fprintf(stderr, "Cannot find a prime number greater than or equal to %u\n",
	  b);
  return b;
}

/*

isPrime:

Return whether or not the argument is a prime number.

*/

+(BOOL)isPrime: (unsigned)n {
  unsigned i;

  for(i = 2; (i * i) <= n; i++) {
    if((n % i) == 0) return NO;
  }
  return YES;
}

@end
