/*
    CASD-0: Case.m
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

Case.m

*/

#import "Case.h"
#import "State.h"
#import "Tube.h"
#import "DoubleSimple.h"
#import "Verbosity.h"
#import "Number.h"


@implementation Case

+create: (id <Zone>)z time: (int)t state: (State *)st decision: (decision_t)dec payoff: (Tube *)poffs nbrsDisapproving: (Tube *)nbrsDis
{

  Case *obj;
  obj = [super create: z];

  obj->time = t;
  obj->state = st;
  // Cases are only used to decide, then they are dropped,
  // so we can use just a pointer to the state.
  // Since this is the state used by the agent,
  // we must not drop it when we drop the case.
  obj->decision = dec;
  obj->payoffs = poffs;
  // Payoffs are created in the payOffCalculator object
  // only once for the whole simulation.  
  // Therefore, when we drop a case, we must not drop its payoff 
  // objects as well.
  obj->nbrsDisapproving = nbrsDis;
  // nbrsDisapproving objects are created in the method 
  // -(Case *)getMatchCaseForState: 
  // (Tube *)s decision: (decision_t)d fMemory: (int)f
  // in the History Class. The pointer is then lost and 
  // this is the only class that uses the nbrsDisapproving objects. 
  // Therefore, when we drop a case, we must drop its nbrsDisapproving 
  // objects as well.
  return obj;
}

/*

copy

Create a copy of the given case

*/


-(Case *)copy: (id <Zone>)z
{
  Case *caseCopy;
  State *stCopy;
  Tube *payoffsCopy;
  Tube *nbrsDisapprovingCopy;
  unsigned length;
  int i;
  DoubleSimple *payoff;
  Number *nbrsDis, *nbrsDisCopy;

  //Copy of the state
  stCopy = [state copy: z];

  //Copy of the Payoffs Tube
  //We don't have to create new payoffs, since there is just one 
  //payoff object per value.
  length = [payoffs getLength];
  payoffsCopy = [Tube create: z setLength: length];
  for(i = length-1 ; i >= 0; i--){
    payoff = [payoffs getObject: (unsigned)i];
    [payoffsCopy pushItem: payoff];
  }

  //Copy of the nbrsDisapproving Tube
  //Here there is a need to create new objects.
  length = [nbrsDisapproving getLength];
  nbrsDisapprovingCopy = [Tube create: z setLength: length];
  for(i = length-1; i >= 0; i--){
    nbrsDisCopy = [Number create: z];
    nbrsDis = [nbrsDisapproving getObject: (unsigned)i];
    [nbrsDisCopy setInt: [nbrsDis getInt]];
    [nbrsDisapprovingCopy pushItem: nbrsDisCopy];
  }

  caseCopy = [Case create: z time: time state: stCopy decision: decision payoff: payoffsCopy nbrsDisapproving: nbrsDisapprovingCopy];

  return caseCopy;
}

-(State *)getState
{
  return state;
}

-(decision_t)getDecision
{
  return decision;
}

-(Tube *)getPayoffs
{
  return payoffs;
}

-(Tube *)getNbrsDisapproving
{
  return nbrsDisapproving;
}

-(DoubleSimple *)getSumOfPayoffs
{
  unsigned length;
  unsigned i;
  DoubleSimple *sum = [DoubleSimple new];
 
  length = [payoffs getLength];
  [sum cset:0.0];

  for(i = 0; i < length; i++){
    [sum add: [payoffs getObject: i]];
  }

  if([Verbosity showSumOfPayoffs]){
    printf("\n\tThe sum of the payoffs for case <%p> is ", self);
    [sum writeAccurately: stdout];
  }

  return sum;
}

-(int)getSumOfNbrsDisapproving
{
  unsigned length;
  unsigned i;
  int sum = 0;
 
  length = [nbrsDisapproving getLength];
  
  for(i = 0; i < length; i++){
    sum += [[nbrsDisapproving getObject: i] getInt];
  }

  if([Verbosity showSumOfNbrsDisapproving]){
    printf("\n\tThe sum of the neighbours disapproving for case <%p> is %d"
	   , self, sum);
  }

  return sum;
}


/*

eq:

Compares two cases. The returned value is YES only if the states of the world,
the decision made, the f payoffs obtained and the f numbers of disapproving 
neighbours are identical and in the same order.

The time when the case occurred is ignored.

*/

-(BOOL)eq: (Case *)anotherCase
{
  unsigned length, anCaseLength;
  unsigned i;
  Tube *anCasePayoffs, *anCaseNbrsDis;

  if( anotherCase == nil){
    return NO;
  }

  //State
  if( ![state eq: [anotherCase getState]] ){
    return NO;
  }

  //decision
  if( decision != [anotherCase getDecision] ){
    return NO;
  }

  //Payoffs
  anCasePayoffs = [anotherCase getPayoffs];
  length = [payoffs getLength];
  anCaseLength = [anCasePayoffs getLength];

  if( length != anCaseLength ){
    return NO;
  }
  else{
    for(i = 0; i < length; i++){
      DoubleSimple *one, *two;
      one = [payoffs getObject: i];
      two = [anCasePayoffs getObject: i];
      if( [one ne: two] ){
	return NO;
      }
    }
  }

  //Neighbours disapproving 
  anCaseNbrsDis = [anotherCase getNbrsDisapproving];
  length = [nbrsDisapproving getLength];
  anCaseLength = [anCaseNbrsDis getLength];

  for(i = 0; i < length; i++){
    Number *one, *two;
    one = [nbrsDisapproving getObject: i];
    two = [anCaseNbrsDis getObject: i];
    if( ([one getInt]) != ([two getInt]) ){
      return NO;
    }
  }

  return YES;
}  
  
-print
{
  unsigned payoffLength;
  unsigned nbrsDisapprovingLength;
  int i;
  DoubleSimple *payoff;

  payoffLength = [payoffs getLength];
  nbrsDisapprovingLength = [nbrsDisapproving getLength];

  printf("\n\n\tDisplaying Case <%p>:", self);
  printf("\n\tTime: %d", time);

  [state print];

  printf("\n\tDecision:");
  if(decision == cooperate){
    printf("\tCooperate");
  }else if(decision == defect){
    printf("\tDefect");
  }
  
  printf("\n\tPayoff in chronological order:");
  for(i = payoffLength -1; i >= 0 ; i--){
    payoff = [payoffs getObject: (unsigned)i];
    printf(" ");
    [payoff writeAccurately: stdout];
  }

  printf("\n\tNeighbours dissaproving of me in chronological order:\n\t\t");
  for(i = nbrsDisapprovingLength -1; i >= 0 ; i--){
    printf("%d ", [[nbrsDisapproving getObject: i] getInt]);
  }
  printf("\n");

  return self;
}
  
-drop{
  unsigned nbrsDisapprovingLength;
  int i;

  // nbrsDisapproving objects are created in the method 
  // -(Case *)getMatchCaseForState: 
  // (Tube *)s decision: (decision_t)d fMemory: (int)f
  // in the History Class. The pointer is then lost and 
  // this is the only class that uses the nbrsDisapproving objects. 
  // Therefore, when we drop a case, we must drop its nbrsDisapproving 
  // objects as well.

  nbrsDisapprovingLength = [nbrsDisapproving getLength];
  for(i = nbrsDisapprovingLength -1; i >= 0 ; i--){
    Number *n = [nbrsDisapproving getObject: i];
    [n drop];
  }

  // Payoffs are created in the payOffCalculator object
  // only once for the whole simulation.  
  // Therefore, when we drop a case, we must not drop its payoff 
  // objects as well.

  [payoffs drop];
  [nbrsDisapproving drop];
  [super drop];

  return self;
}

@end
