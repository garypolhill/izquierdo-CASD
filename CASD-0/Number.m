/*
    FEARLUS model0-6-4: Number.m
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


Implementation of Number class.

*/

#import "Number.h"
#import <string.h>

@implementation Number

-setChar: (char)value {
  myNumber.c = value;
  type = @encode(char);
  return self;
}
-setUnsignedChar: (unsigned char)value {
  myNumber.uc = value;
  type = @encode(unsigned char);
  return self;
}
-setShort: (short)value {
  myNumber.s = value;
  type = @encode(short);
  return self;
}
-setUnsignedShort: (unsigned short)value {
  myNumber.us = value;
  type = @encode(unsigned short);
  return self;
}
-setInt: (int)value {
  myNumber.i = value;
  type = @encode(int);
  return self;
}
-setUnsigned: (unsigned)value {
  myNumber.u = value;
  type = @encode(unsigned);
  return self;
}
-setLong: (long)value {
  myNumber.l = value;
  type = @encode(long);
  return self;
}
-setUnsignedLong: (unsigned long)value {
  myNumber.ul = value;
  type = @encode(unsigned long);
  return self;
}
-setLongLong: (long long)value {
  myNumber.ll = value;
  type = @encode(long long);
  return self;
}
-setUnsignedLongLong: (unsigned long long)value {
  myNumber.ull = value;
  type = @encode(unsigned long long);
  return self;
}
-setFloat: (float)value {
  myNumber.f = value;
  type = @encode(float);
  return self;
}
-setDouble: (double)value {
  myNumber.d = value;
  type = @encode(double);
  return self;
}
-setLongDouble: (long double)value {
  myNumber.ld = value;
  type = @encode(long double);
  return self;
}
-(char)getChar {
  return myNumber.c;
}
-(unsigned char)getUnsignedChar {
  return myNumber.uc;
}
-(short)getShort {
  return myNumber.s;
}
-(unsigned short)getUnsignedShort {
  return myNumber.us;
}
-(int)getInt {
  return myNumber.i;
}
-(unsigned)getUnsigned {
  return myNumber.u;
}
-(long)getLong {
  return myNumber.l;
}
-(unsigned long)getUnsignedLong {
  return myNumber.ul;
}
-(long long)getLongLong {
  return myNumber.ll;
}
-(unsigned long long)getUnsignedLongLong {
  return myNumber.ull;
}
-(float)getFloat {
  return myNumber.f;
}
-(double)getDouble {
  return myNumber.d;
}
-(long double)getLongDouble {
  return myNumber.ld;
}

-(char *)getType {
  return type;
}

-(SEL)getTypeSelector {
  if(type == NULL) {
    fprintf(stderr, "WARNING: Type not set\n");
    return M(getInt);
  }
  if(strcmp(type, @encode(char)) == 0) {
    return M(getChar);
  }
  else if(strcmp(type, @encode(unsigned char)) == 0) {
    return M(getUnsignedChar);
  }
  else if(strcmp(type, @encode(short)) == 0) {
    return M(getShort);
  }
  else if(strcmp(type, @encode(unsigned short)) == 0) {
    return M(getUnsignedShort);
  }
  else if(strcmp(type, @encode(int)) == 0) {
    return M(getInt);
  }
  else if(strcmp(type, @encode(unsigned)) == 0) {
    return M(getUnsigned);
  }
  else if(strcmp(type, @encode(long)) == 0) {
    return M(getLong);
  }
  else if(strcmp(type, @encode(unsigned long)) == 0) {
    return M(getUnsignedLong);
  }
  else if(strcmp(type, @encode(long long)) == 0) {
    return M(getLongLong);
  }
  else if(strcmp(type, @encode(unsigned long long)) == 0) {
    return M(getUnsignedLongLong);
  }
  else if(strcmp(type, @encode(float)) == 0) {
    return M(getFloat);
  }
  else if(strcmp(type, @encode(double)) == 0) {
    return M(getDouble);
  }
  else if(strcmp(type, @encode(long double)) == 0) {
    return M(getLongDouble);
  }
  else {
    fprintf(stderr, "WARNING: Type not set\n");
    return M(getInt);
  }
}

-loadFromFile: (FILE *)fp {
  char buf[100];

  fscanf(fp, "%99s", buf);	// Read in the type
  if(strcmp(buf, @encode(char)) == 0) {
    fscanf(fp, " %c", &myNumber.c);
    type = @encode(char);
  }
  else if(strcmp(buf, @encode(unsigned char)) == 0) {
    fscanf(fp, " %uc", &myNumber.u);
    type = @encode(unsigned char);
  }
  else if(strcmp(buf, @encode(short)) == 0) {
    fscanf(fp, " %hd", &myNumber.s);
    type = @encode(short);
  }
  else if(strcmp(buf, @encode(unsigned short)) == 0) {
    fscanf(fp, " %hu", &myNumber.us);
    type = @encode(unsigned short);
  }
  else if(strcmp(buf, @encode(int)) == 0) {
    fscanf(fp, " %d", &myNumber.i);
    type = @encode(int);
  }
  else if(strcmp(buf, @encode(unsigned)) == 0) {
    fscanf(fp, " %u", &myNumber.u);
    type = @encode(unsigned);
  }
  else if(strcmp(buf, @encode(long)) == 0) {
    fscanf(fp, " %ld", &myNumber.l);
    type = @encode(long);
  }
  else if(strcmp(buf, @encode(unsigned long)) == 0) {
    fscanf(fp, " %lu", &myNumber.ul);
    type = @encode(unsigned long);
  }
  else if(strcmp(buf, @encode(long long)) == 0) {
    fscanf(fp, " %lld", &myNumber.ll);
    type = @encode(long long);
  }
  else if(strcmp(buf, @encode(unsigned long long)) == 0) {
    fscanf(fp, " %llu", &myNumber.ull);
    type = @encode(unsigned long long);
  }
  else if(strcmp(buf, @encode(float)) == 0) {
    fscanf(fp, " %f", &myNumber.f);
    type = @encode(float);
  }
  else if(strcmp(buf, @encode(double)) == 0) {
    fscanf(fp, " %lf", &myNumber.d);
    type = @encode(double);
  }
  else if(strcmp(buf, @encode(long double)) == 0) {
    fscanf(fp, " %Lf", &myNumber.ld);
    type = @encode(long double);
  }
  else {
    fprintf(stderr, "WARNING: Unrecognised type: %s\n", buf);
    return nil;
  }
  return self;
}

-saveToFile: (FILE *)fp {
  fprintf(fp, "%s", type);
  if(strcmp(type, @encode(char)) == 0) {
    fprintf(fp, " %c", myNumber.c);
  }
  else if(strcmp(type, @encode(unsigned char)) == 0) {
    fprintf(fp, " %uc", myNumber.uc);
  }
  else if(strcmp(type, @encode(short)) == 0) {
    fprintf(fp, " %hd", myNumber.s);
  }
  else if(strcmp(type, @encode(unsigned short)) == 0) {
    fprintf(fp, " %hu", myNumber.us);
  }
  else if(strcmp(type, @encode(int)) == 0) {
    fprintf(fp, " %d", myNumber.i);
  }
  else if(strcmp(type, @encode(unsigned)) == 0) {
    fprintf(fp, " %u", myNumber.u);
  }
  else if(strcmp(type, @encode(long)) == 0) {
    fprintf(fp, " %ld", myNumber.l);
  }
  else if(strcmp(type, @encode(unsigned long)) == 0) {
    fprintf(fp, " %lu", myNumber.ul);
  }
  else if(strcmp(type, @encode(long long)) == 0) {
    fprintf(fp, " %lld", myNumber.ll);
  }
  else if(strcmp(type, @encode(unsigned long long)) == 0) {
    fprintf(fp, " %llu", myNumber.ull);
  }
  else if(strcmp(type, @encode(float)) == 0) {
    fprintf(fp, " %f", myNumber.f);
  }
  else if(strcmp(type, @encode(double)) == 0) {
    fprintf(fp, " %f", myNumber.d);
  }
  else if(strcmp(type, @encode(long double)) == 0) {
    fprintf(fp, " %Lf", myNumber.ld);
  }
  return self;
}

-print {
  return [self saveToFile: stdout];
}

@end

