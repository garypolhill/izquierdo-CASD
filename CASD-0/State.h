/*
    CASD-0: State.h
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

State.h

The state of the world is an Array of potentially two tubes with b 
(backwards memory) objects in each Tube.

1. Tube (array) with the number of the b previous other defectors.
2. Tube (array) with the agent's b previous decisions

*/

#import <objectbase/SwarmObject.h>
#import <collections/Array.h>

@class Tube;

@interface State: SwarmObject {

  unsigned length;
  BOOL descriptorOtherDefectors;
  BOOL descriptorMyDecisions;
  unsigned otherDefectorsDescriptorNumber;
  unsigned myDecisionsDescriptorNumber;
  unsigned numberOfDescriptors;
  id <Array> descriptors;
}

+create: (id <Zone>)z setLength: (unsigned)l dOtherDefectors: (BOOL)d1 dMyDecisions: (BOOL)d2;
-(State *)copy: (id <Zone>)z;
-(BOOL)eq: (State *)anotherState;
-(unsigned)getLength;
-(unsigned)getNumberOfDescriptors;
-(Tube *)getDescriptorTube: (unsigned)d;
-pushItem: item onDescriptor: (unsigned)d;
-getObject: (unsigned)t fromDescriptor: (unsigned)d;
-(BOOL)isDescriptorOtherDefectorsUsed;
-(BOOL)isDescriptorMyDecisionsUsed;
-(unsigned)getOtherDefectorsDescriptorNumber;
-(unsigned)getMyDecisionsDescriptorNumber;
-(BOOL)checkFullCooperation;
-(BOOL)checkFullDefection: (int)nNbrs;
-print;

@end

