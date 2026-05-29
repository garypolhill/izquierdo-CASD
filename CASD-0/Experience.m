/*
    CASD-0: Experience.m
    Copyright (C) 2004  Macaulay Institute

    This file is part of CASD (Casuistry And Social Dilemmas), an agent-based
    model designed to study the behaviour of case-based reasoners when they
    face social dilemmas. Social dilemmas are modelled as n-player games.

    CASD-0 is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    CASD-0 is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details. (LICENCE file in
    this directory.)

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Contact information:
      Luis R. Izquierdo,
      Macaulay Institute, Craigiebuckler, Aberdeen, AB15 8QH. United Kingdom
      l.izquierdo@macaulay.ac.uk
*/

/*

CASD

Experience.m

*/

#import "Experience.h"
#import "DoubleSimple.h"

@implementation Experience

+create: (id <Zone>)z
{
  Experience *obj;
  obj = [super create: z];
 
  obj->time = 0;
  obj->payoff = nil;

  return obj;
}


/*

create: time: otherDefectors: decision: payoff: nbrsDisapprovingMe:

This method creates a new experience with the passed arguments 

*/

+create: (id <Zone>)z time: (timeval_t)t otherDefectors: (int)df decision: (decision_t)dc payoff: (DoubleSimple *)p nbrsDisapprovingMe: (int)nd
{

  Experience *obj;
  obj = [super create: z];

  obj->time = t;
  obj->otherDefectors = df;
  obj->decision = dc;
  obj->payoff = p;
  obj->nbrsDisapproving = nd;

  return obj;
}

-(timeval_t)getTime{
  return time;
}

-(int)getOtherDefectors{
  return otherDefectors;
}

-(decision_t)getDecision{
  return decision;
}

-(DoubleSimple *)getPayoff{
  return payoff;
}

-(int)getNbrsDisapproving
{
  return nbrsDisapproving;
}

-print {
 
  printf("\n%lu\t\t%d", time, otherDefectors);
  if(decision == cooperate){
    printf("\tCooperate");
  }else if(decision == defect){
    printf("\tDefect\t");
  }
  
  printf("\t");
  [payoff writeAccurately: stdout];
  printf("\t %d", nbrsDisapproving);

  return self;
}

@end
