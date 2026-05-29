/*
    CASD-0: State.m
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

State.m

*/

#import "State.h"
#import "Tube.h"
#import "Number.h"
#import "DecisionObj.h"

@implementation State


/*

create

This method creates the appropriate Tubes depending on the number of
descriptors required.

*/

+create: (id <Zone>)z setLength: (unsigned)l dOtherDefectors: (BOOL)d1 dMyDecisions: (BOOL)d2;
{
  State *obj;
  int i;
  
  obj = [super create: z];

  obj->length = l;

  obj->numberOfDescriptors=0;

  if(d1){
    obj->otherDefectorsDescriptorNumber = obj->numberOfDescriptors;
    obj->numberOfDescriptors++;
  }

  if(d2){
    obj->myDecisionsDescriptorNumber = obj->numberOfDescriptors;
    obj->numberOfDescriptors++;
  }
  
  obj->descriptors = [Array create: z setCount: obj->numberOfDescriptors];
  for(i = 0; i < obj->numberOfDescriptors; i++) {
    Tube *descriptor = [Tube create: z setLength: (unsigned)l];
    [obj->descriptors atOffset: i put: descriptor];
  }

  obj->descriptorOtherDefectors = d1;
  obj->descriptorMyDecisions = d2;

  return obj;
}


/*

copy:

Create a copy of the given state

*/

-(State *)copy: (id <Zone>)z
{
  State *theCopy;
  int i, j;
 
  theCopy = [State create: z setLength: length 
		   dOtherDefectors: descriptorOtherDefectors
		   dMyDecisions: descriptorMyDecisions];

  if(descriptorOtherDefectors){
    Number *defectorsCopy, *defectors;
    i = [self getOtherDefectorsDescriptorNumber];

    for(j = length-1; j >= 0; j--){
      defectorsCopy = [Number create: z];

      defectors = [self getObject: (unsigned)j 
			fromDescriptor: (unsigned)i];
      [defectorsCopy setInt: [defectors getInt]];

      [theCopy pushItem: defectorsCopy onDescriptor: (unsigned)i];
    }
  }

  if(descriptorMyDecisions){
    DecisionObj *myDecisionObj, *myDecisionObjCopy;
    decision_t myDecision;
    i = [self getMyDecisionsDescriptorNumber];

    for(j = length-1; j >= 0; j--){
      myDecisionObj = [self getObject: (unsigned)j 
			fromDescriptor: (unsigned)i];
      myDecision = [myDecisionObj getDecision];
      myDecisionObjCopy = [DecisionObj create: z decision: myDecision];

      [theCopy pushItem: myDecisionObjCopy onDescriptor: (unsigned)i];
    }
  }

  return theCopy;
}


/*

eq:

This methods compares two given states of the world.
It returns YES only if they are identical (same descriptors, same 
numbers/decisions for each descriptor, and in the same order)

*/


-(BOOL)eq: (State *)anotherState
{
  unsigned anStateLength, i, j;
  BOOL desOne, desTwo;

  anStateLength = [anotherState getLength];

  if(length != anStateLength){
    return NO;
  }

  desOne = [anotherState isDescriptorOtherDefectorsUsed];
  desTwo = [anotherState isDescriptorMyDecisionsUsed];

  if(desOne != descriptorOtherDefectors){
    return NO;
  }

  if(desTwo != descriptorMyDecisions){
    return NO;
  }

  if(descriptorOtherDefectors){
    Number *anStDefectors, *defectors;
    i = [self getOtherDefectorsDescriptorNumber];

    for(j = 0; j < length; j++){

      anStDefectors = [anotherState getObject: j
				    fromDescriptor: i];
      defectors = [self getObject: j 
			fromDescriptor: i];
      if( ([anStDefectors getInt]) != ([defectors getInt]) ){
	return NO;
      }
    }
  }
  
  if(descriptorMyDecisions){
    DecisionObj *anStDecisionObj, *myDecisionObj;
    i = [self getMyDecisionsDescriptorNumber];

    for(j = 0; j < length; j++){
      anStDecisionObj = [anotherState getObject: j
				      fromDescriptor:i];
      myDecisionObj = [self getObject: j 
			  fromDescriptor: i];
      if( ([anStDecisionObj getDecision]) != ([myDecisionObj getDecision]) ){
	return NO;
      }
    }
  }

  return YES;
}


-(unsigned)getLength
{
  return length;
}

-(unsigned)getNumberOfDescriptors
{
  return numberOfDescriptors;
}

-(Tube *)getDescriptorTube: (unsigned)d
{
  return [descriptors atOffset: d];
}

-pushItem: item onDescriptor: (unsigned)d
{
  Tube *descriptor = [descriptors atOffset: d];
  [descriptor pushItemDrop: item];

  return self;
}

-getObject: (unsigned)t fromDescriptor: (unsigned)d
{
  Tube *descriptor = [descriptors atOffset: d];
  return [descriptor getObject: t];

}

-(BOOL)isDescriptorOtherDefectorsUsed
{
  return descriptorOtherDefectors;
}

-(BOOL)isDescriptorMyDecisionsUsed
{
  return descriptorMyDecisions;
}

-(unsigned)getOtherDefectorsDescriptorNumber
{
  return otherDefectorsDescriptorNumber;
}
 
-(unsigned)getMyDecisionsDescriptorNumber
{
  return myDecisionsDescriptorNumber;
}

/*

checkFullCooperation

This method returns YES only if the state of the world corresponds to a 
state of b consecutive universal cooperations (everyone cooperating). 

*/

-(BOOL)checkFullCooperation
{
  int i;
  unsigned descriptorNumber = 0;

  if(descriptorOtherDefectors){
    
    Number *defectors;

    for(i = 0; i < length ; i++){
      defectors = [self getObject: (unsigned)i 
			fromDescriptor:descriptorNumber];
      if( [defectors getInt] != 0){
	return NO;
      }
    }
    descriptorNumber++;
  }

  if(descriptorMyDecisions){
    
    DecisionObj *decObj;
    
    for(i = 0; i < length ; i++){
      decObj = [self getObject: (unsigned)i 
		     fromDescriptor:descriptorNumber];
      if( [decObj getDecision]!= cooperate){
	return NO;
      }
    }
    descriptorNumber++;
  }

  return YES;
}


/*

checkFullDefection

This method returns YES only if the state of the world corresponds to a 
state of b consecutive universal defections (everyone defecting). 

*/

-(BOOL)checkFullDefection: (int)nNbrs
{
  int i;
  unsigned descriptorNumber = 0;

  if(descriptorOtherDefectors){
    
    Number *defectors;

    for(i = 0; i < length ; i++){
      defectors = [self getObject: (unsigned)i 
			fromDescriptor:descriptorNumber];
      if( [defectors getInt] != nNbrs){
	return NO;
      }
    }
    descriptorNumber++;
  }

  if(descriptorMyDecisions){
    
    DecisionObj *decObj;
    
    for(i = 0; i < length ; i++){
      decObj = [self getObject: (unsigned)i 
		     fromDescriptor:descriptorNumber];
      if( [decObj getDecision]!= defect){
	return NO;
      }
    }
    descriptorNumber++;
  }

  return YES;
}

-print
{
  int i;
  unsigned descriptorNumber = 0;

  if(descriptorOtherDefectors){
    Number *defectors;

    printf("\n\tDefectors in chronological order:");

    for(i = length-1; i >= 0 ; i--){
      defectors = [self getObject: (unsigned)i 
			fromDescriptor:descriptorNumber];
      printf(" %d", [defectors getInt]);
    }
    descriptorNumber++;
  }

  if(descriptorMyDecisions){
    DecisionObj *decObj;

    printf("\n\tMy decisions in chronological order:");

    for(i = length-1; i >= 0 ; i--){
      decObj = [self getObject: (unsigned)i 
		     fromDescriptor:descriptorNumber];
      if([decObj getDecision]==cooperate){
	printf(" C");
      }else if([decObj getDecision]==defect){
	printf(" D");
      }
    }
    descriptorNumber++;
  }

  return self;

}


@end
