/*
    FEARLUS model0-6-4: Number.h
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


Object to contain a number.

*/

#import <objectbase/SwarmObject.h>
#import <stdio.h>

typedef union number_type {
  char c;
  unsigned char uc;
  short s;
  unsigned short us;
  int i;
  unsigned u;
  long l;
  unsigned long ul;
  long long ll;
  unsigned long long ull;
  float f;
  double d;
  long double ld;
} number_t;

@interface Number: SwarmObject {
  number_t myNumber;
  char *type;
}

-setChar: (char)value;
-setUnsignedChar: (unsigned char)value;
-setShort: (short)value;
-setUnsignedShort: (unsigned short)value;
-setInt: (int)value;
-setUnsigned: (unsigned)value;
-setLong: (long)value;
-setUnsignedLong: (unsigned long)value;
-setLongLong: (long long)value;
-setUnsignedLongLong: (unsigned long long)value;
-setFloat: (float)value;
-setDouble: (double)value;
-setLongDouble: (long double)value;
-(char)getChar;
-(unsigned char)getUnsignedChar;
-(short)getShort;
-(unsigned short)getUnsignedShort;
-(int)getInt;
-(unsigned)getUnsigned;
-(long)getLong;
-(unsigned long)getUnsignedLong;
-(long long)getLongLong;
-(unsigned long long)getUnsignedLongLong;
-(float)getFloat;
-(double)getDouble;
-(long double)getLongDouble;

-(char *)getType;
-(SEL)getTypeSelector;
-loadFromFile: (FILE *)fp;
-saveToFile: (FILE *)fp;

-print;

@end
