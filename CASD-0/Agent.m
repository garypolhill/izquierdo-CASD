/*
    CASD-0: Agent.m
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

CharityWorld

Agent.m

*/

#import "Agent.h"
#import "ModelSwarm.h"
#import "Verbosity.h"
#import "DoubleSimple.h"
#import "History.h"
#import "Case.h"
#import "State.h"
#import "Number.h"
#import "DecisionObj.h"
#import <random.h>

id <Zone> all_histories_zone;
BOOL created_all_histories_zone = NO;

@implementation Agent

+create: (id <Zone>)z {
  Agent *obj = [super create: z];

  obj->nbrs = nil;
  obj->wealth = nil;
  obj->myPayoff = nil;
  obj->myHistory = nil;
  obj->backwardsMemory = 0;
  obj->forwardMemory = 0;
  obj->numberOfNbrs = 0;
  obj->age = 0;
  return obj;
}

+create: (id <Zone>)z model: (ModelSwarm *)m X: (int)ax Y: (int)ay {
  Agent *obj;

  obj = [super create: z];

  obj->model = m;
  obj->nbrs = [List create: z];
  obj->wealth = [DoubleSimple new];
  obj->myPayoff = nil; 
  //This will point to any of the payoffs created
  //in the PayoffCalculator object
  obj->backwardsMemory = 0;
  obj->forwardMemory = 0;
  obj->numberOfNbrs = 0;
  obj->x = ax;
  obj->y = ay;
  obj->age = 0;
  obj->nbrsDisapprovingOfMe = 0;

  if(!created_all_histories_zone) {
    all_histories_zone = [Zone create: globalZone];
    created_all_histories_zone = YES;
  }
  obj->history_zone = [Zone create: all_histories_zone];

  obj->myHistory = [History create: obj->history_zone];
  
  return obj;
}

/* 

getAllHistoriesZone

Return the zone in which all histories are stored.

*/

+(id <Zone>)getAllHistoriesZone {
  if(!created_all_histories_zone) return nil;
  return all_histories_zone;
}


-setPayoffCalculator: (id <PayoffCalculator>)p
{
  payoffCalculator = p;
  return self;
}

-(int)getX {
  return x;
}

-(int)getY {
  return y;
}

/*

addNeighbour:

This method is called from the model when the agent is being created.
Please, note that the neighbouring agents are not in random order.

*/

-addNeighbour: (Agent *)a {
  
  if(![nbrs contains: a]) {
    [nbrs addLast: a];
    numberOfNbrs++;
  }

  return self;
}

/*

setBackwardsMemory

This method sets the Backwards memory, which 
is the number of time-steps prior to the decision for which 
the agent stores in each case the value of the descriptors. 

*/

-setBackwardsMemory: (int)b {
  if(b < 0){
    printf("\nBackwards Memory parameter cannot be a negative number\n");
    abort();
  }
  backwardsMemory = b;
  return self;
}

/*

setForwardMemory

This method sets the forward memory, which is the number of time-steps 
subsequent to the decision for which the agent stores in each case the 
payoff and social approval that they obtained.

*/

-setForwardMemory: (int)f {
  if(f <= 0){
    printf("\n\nWARNING!!! Forward Memory parameter is not positive."
	   "\nAll decisions will be taken randomly\n\n");
  }
  forwardMemory = f;
  return self;
}

-setDescriptorOtherDefectors: (BOOL)descriptorOtherDefectors
{
  dOtherDefectors = descriptorOtherDefectors;
  return self;
}

-setDescriptorMyDecisions: (BOOL)descriptorMyDecisions
{
  dMyDecisions = descriptorMyDecisions;
  return self;
}

/*

createStateOfTheWorld

Create the structure of the State of the World that the Agent will perceive:
Which descriptors the Agent is going to observe, and for how long backwards.

*/

-createStateOfTheWorld
{
  myStateOfTheWorld = [State create: [self getZone]
			     setLength: (unsigned)backwardsMemory
			     dOtherDefectors: dOtherDefectors
			     dMyDecisions: dMyDecisions];
  return self;
}


-setExperimentationThreshold: (DoubleSimple *)expThreshold
{
  experimentationThreshold = expThreshold;
  return self;
}

-setPeerPressureThreshold: (int)pPT
{
  peerPressureThreshold = pPT;
  return self;
}

/* 

decide: 

This method is called every time-step.
Basically, the Agent takes the most recent case that matches the state of 
the world for each decision (cooperate or defect).
Then the Agent must face one of the following three possibilities:

1. The Agent cannot recall any previous situations that match the 
current state of the world. In CBR terms, the agent does not hold any 
appropriate cases for the current state of the world. In that case the Agent
chooses at random (or deterministically if +d option is used).

2. The Agent does not remember a previous similar situation when they made a
certain decision, but they do recall at least one similar situation when 
they made the other decision. In this situation, Agents will explore the 
non-applied decision if the Payoff they obtained in the last previous 
similar situation was below their Aspiration Threshold; otherwise they will 
keep the same decision they previously applied in similar situations. There 
is an exception for this: If the Agent perceives that the expected 
number of neighbours (calculated as the average of the forwardMemory numbers 
of disapproving neighbours in the case) is higher than the 
peerPressureThreshold, then the Agent will cooperate.

3. The Agent remembers at least one previous similar situation when they 
made each of the two possible decisions. In this situation, the Agent will 
focus on the most recent case for each of the two decisions and choose the 
decision that provided them with the higher Payoff, as long as the expected 
number of neighbours that are going to disapprove of the agent is less or 
equal to the peerPressureThreshold. Otherwise, the agent will cooperate.

The peerPressureThreshold is the maximum number of disapproving neighbours 
that an Agent can bear.
 
A case for an experience lived at time t is composed of:
1. The information the agent had when it took its 
decision at time t (i.e., the state of the world at
the beginning of time t, before the decison at time t 
was made). 
2. The decision the agent made (cooperate or defect)
3. The payoff that the agent got at time t and subsequent 
time-steps (f payoffs in total).
4. The number of neighbours who disapproved of the Agent at time t and 
subsequent time-steps (f numbers in total).

*/

-decide
{
  
  if([Verbosity showAgentsDeciding]){
    printf("\nAgent at location [%d,%d] deciding...", x+1, y+1);
  }

  if(forwardMemory <= 0){
    [self decideAtRandom];
    return self;
  }

  if([Verbosity showAgentsRemembering]){
    printf("\n\n\tAgent at location [%d,%d] trying to remember a similar"
	   "\n\tsituation when it cooperated.\n", x+1, y+1);
  }

  CCase = [myHistory getMatchCaseForState: myStateOfTheWorld 
		     decision: cooperate
		     fMemory: forwardMemory];

  if([Verbosity showAgentsRemembering]){
    printf("\n\n\tAgent at location [%d,%d] trying to remember a similar"
	   "\n\tsituation when it defected.\n", x+1, y+1);
  }

  DCase = [myHistory getMatchCaseForState: myStateOfTheWorld
		     decision: defect
		     fMemory: forwardMemory];

  //If fewer than (backwardsMemory + forwardMemory) timesteps have gone by,
  //then CCase and DCase will be nil. 
  
  if(CCase == nil && DCase == nil){
    if([Verbosity showAgentsDeciding]){
      printf("\n\n\tI cannot remember any case for any decision");
    }
    [self decideWhenNoCases];
    return self;
  }

  if(CCase != nil && DCase == nil){
    if([Verbosity showAgentsDeciding]){
      printf("\n\n\tI only remember a previous similar situation"
	     "\n\twhen I cooperated so");
    }
    [self decideWhenOnlyCooperate];
    return self;
  }

  if(CCase == nil && DCase != nil){
    if([Verbosity showAgentsDeciding]){
      printf("\n\n\tI only remember a previous similar situation"
	     "\n\twhen I defected so");
    }
    [self decideWhenOnlyDefect];
    return self;
  }

  
  if(CCase != nil && DCase != nil){
    if([Verbosity showAgentsDeciding]){
      printf("\n\n\tI remember a previous similar situation"
	     "\n\tfor each decision");
    }
    [self decideWhenTwoCases];
  }

  //Cases are NOT dropped yet because we have to check
  //whether we have achieved stable cooperation or stable 
  //defection or any other cycle. 
  //They will be dropped in -dropCases, in ModelSwarm.m

  return self;
}
   
/*

decideAtRandom

Decide at random unless the +d option was used, in which case, the string
parameter is used to decide.

*/
 
-decideAtRandom
{
  myDecisionProcess = atRandom;

  if([model isDeterministic]) {
    if([Verbosity showAgentsDecidingDeterministically]){
      printf("\n\tI am deciding deterministically");
    }
    myDecision = [model getNextDeterministicDecision];  
  }
  else{
    int rand = [uniformIntRand getIntegerWithMin: 0 withMax: 1];

    [model addOneRandomDecision];
    if(rand == 0 ){
      myDecision = cooperate;
      if([Verbosity showAgentsDeciding]){
	printf("\n\t I happen to cooperate\n");
      }
      if([Verbosity showAgentsDecidingAtRandom]){
	printf("\n\tAgent at location [%d,%d] decided at random"
	   "\n\tto cooperate.\n", x+1, y+1);
      }
    }else{
      myDecision = defect;
      if([Verbosity showAgentsDeciding]){
	printf("\n\t I happen to defect\n");
      }
      if([Verbosity showAgentsDecidingAtRandom]){
	printf("\n\tAgent at location [%d,%d] decided at random"
	   "\n\tto defect.\n", x+1, y+1);
      }
    }
  }

  return self;
}

-decideWhenNoCases
{
  
  if([Verbosity showAgentsDeciding]){
    printf("\n\tso I decide at random");
  }
  [self decideAtRandom];
  
  return self;
}


/*

decideWhenOnlyCooperate

If you only have a case for one decision, 
explore the other one, unless you got at least the 
experimentation threshold, in which you case you keep the same decision

*/

-decideWhenOnlyCooperate
{
  DoubleSimple *score = [CCase getSumOfPayoffs];
  //superExpThreshold is the experimentationThreshold multiplied
  //by the number of payoffs involved in the average it will be
  //compared with. This is done to avoid division.
  DoubleSimple *superExpThreshold = [experimentationThreshold copy];
  [superExpThreshold imul:forwardMemory];

  myDecisionProcess = onlyCooperate;
  
  if([score lt: superExpThreshold]){
    //My score is not high enough
    //Switch decision!
    if([Verbosity showAgentsDeciding]){
      printf(",\n\tsince the score was less than "
	     "\n\tmy experimentation threshold, I defect now\n");
    }
    myDecision = defect;
  }else{
    //Keep the same decision
    if([Verbosity showAgentsDeciding]){
      printf(",\n\tsince the score was greater than (or equal to) "
	     "\n\tmy experimentation threshold, I cooperate again\n");
    }
    myDecision = cooperate;
  }
  [score free];
  [superExpThreshold free];
  return self;
}


/*

decideWhenOnlyDefect

If you only have a case in which you defected, defect again unless:
1. You did not get at least the experimentation threshold. OR
2. The number of neighbours who disapproved of you was greater than the 
peerPressureThreshold.

If 1 OR 2 are true, then cooperate.

The peerPressureThreshold is the maximum number of disapproving neighbours 
that an Agent can bear.

*/

-decideWhenOnlyDefect
{
  DoubleSimple *score = [DCase getSumOfPayoffs];
  int DNbrDisapproving;
  int superPPT;

  //superExpThreshold is the experimentationThreshold multiplied
  //by the number of payoffs involved in the average it will be
  //compared with. This is done to avoid division.
  DoubleSimple *superExpThreshold = [experimentationThreshold copy];
  [superExpThreshold imul:forwardMemory];

  //superPPT is the peerPressureThreshold multiplied
  //by the number of terms involved in the average it will be
  //compared with. This is done to avoid division.
  superPPT = peerPressureThreshold * forwardMemory;

  DNbrDisapproving = [DCase getSumOfNbrsDisapproving];

  myDecisionProcess = onlyDefect;

  if([score lt: superExpThreshold]){
    //My score is not high enough
    //Switch decision!
    if([Verbosity showAgentsDeciding]){
      printf(",\n\tsince the score was less than "
	     "\n\tmy experimentation threshold, I cooperate now\n");
    }
    myDecision = cooperate;
  }else{
    //Keep the same decision
    if([Verbosity showAgentsDeciding]){
      printf(",\n\tsince the score was greater than (or equal to)"
	     "\n\tmy experimentation threshold, I would defect again...\n");
    }
    myDecision = defect;
  }

  if(myDecision == defect){
    if(DNbrDisapproving > superPPT){
      if([Verbosity showAgentsDeciding]){
	printf("\n\tBut the expected social pressure is too high for me."
	       "\n\tTherefore I will cooperate.");
      }
      myDecision = cooperate;
      myDecisionProcess = socialApproval;
    }else{
      if([Verbosity showAgentsDeciding]){
	printf("\n\tand I defect!, because the expected social pressure"
	       "\n\tis not too high for me.");
      }
    }
  }

  [superExpThreshold free];
  [score free];
  return self;
}


/*

decideWhenTwoCases

If you have a case for each decision, choose the one with 
the higher score, as long as the expected number of neighbours that 
are going to disapprove of you is less or equal to the 
peerPressureThreshold. Otherwise, cooperate.

The peerPressureThreshold is the maximum number of disapproving neighbours 
that an Agent can bear.

*/

-decideWhenTwoCases
{
  DoubleSimple *CPayoffScore, *DPayoffScore;
  int DNbrDisapproving;
  int superPPT;

  myDecisionProcess = twoCases;

  //superPPT is the peerPressureThreshold multiplied
  //by the number of terms involved in the average it will be
  //compared with. This is done to avoid division.
  superPPT = peerPressureThreshold * forwardMemory;

  CPayoffScore = [CCase getSumOfPayoffs];
  DPayoffScore = [DCase getSumOfPayoffs];
  DNbrDisapproving = [DCase getSumOfNbrsDisapproving];

  if([CPayoffScore gt: DPayoffScore]){
    if([Verbosity showAgentsDeciding]){
      printf("\n\t and I got more when I cooperated, so I cooperate\n");
    }
    myDecision = [CCase getDecision];
  }else if([CPayoffScore lt: DPayoffScore]){
    if([Verbosity showAgentsDeciding]){
      printf("\n\t and I got more when I defected, so I would defect...");
    }
    myDecision = [DCase getDecision];
  }
  else{
    //Select at random
    if([Verbosity showAgentsDeciding]){
      printf("\n\t and I got the same in both situations, "
	     "so I decide at random, in principle.");
    }
    [self decideAtRandom];
  }
  [CPayoffScore free];
  [DPayoffScore free];

  if(myDecision == defect){
    if(DNbrDisapproving > superPPT){
      if([Verbosity showAgentsDeciding]){
	printf("\n\tBut the expected social pressure is too high for me."
	       "\n\tTherefore I will cooperate.");
      }
      myDecision = cooperate;
      myDecisionProcess = socialApproval;
    }else{
      if([Verbosity showAgentsDeciding]){
	printf("\n\tand I defect!, because the expected social pressure"
	       "\n\tis not too high for me.");
      }
    }
  }

  return self;
}

-resetSocialApproval
{
  nbrsDisapprovingOfMe = 0;
  return self;
}  

/*

judgeNbrs

Disapprove of your neighbours, if appropriate.
Agents who cooperate disapprove of their defecting neighbours.

*/


-judgeNbrs
{
  id <Index> ix;
  Agent *nbr;

  if([Verbosity showAgentsJudging]){
    printf("\n\nAgent at location [%d,%d] judging their neighbours:"
	   , x+1, y+1);
  }

  if(myDecision == cooperate) {
    for(ix = [nbrs begin: scratchZone], nbr = (Agent *)[ix next];
	[ix getLoc] == Member;
	nbr = (Agent *)[ix next]) {

      decision_t nbrDecision = [nbr getDecision];
      if( nbrDecision == defect ){
	[self disapprove: nbr];
	if([Verbosity showAgentsJudging]){
	  printf("\nAgent at location [%d,%d] disapproves of agent at "
		 "location [%d,%d]", x+1, y+1,[nbr getX]+1, [nbr getY]+1 );
	}
      }
    }
    [ix drop];
  }

  return self;
}


/*

disapprove: a

Let Agent 'a' know that you are disapproving of him

*/ 

-disapprove: (Agent *)a
{
  [a addOneToNbrsDisapprovingOfMe];
  return self;
}

-addOneToNbrsDisapprovingOfMe
{
  nbrsDisapprovingOfMe++;
  return self;
}


/*

updateAccount

Update your wealth according to the Payoff you've just received.

*/

-updateAccount{
    
  if([Verbosity showPayoffCalcGivingPayoffs]){
    printf("\n\nAgent at location [%d,%d] asking for its payoff:", x+1, y+1);
  }
  myPayoff = [payoffCalculator getPayoffForDecision: myDecision];
  [wealth add: myPayoff];

  if([Verbosity showAgentsUpdatingAccount]){
    printf("\nAgent at location [%d,%d] has now wealth = ", x+1, y+1);
    [wealth writeAccurately:stdout];
  }

  return self;
}
  

/*

updateState

Every Agent has a perception of the world, determined by the value of the
descriptors the Agent can perceive in the last backwardsMemory timesteps. 
The Agent's state of the world is updated in this method.

*/

-updateState{

  int timestepsToReport, j;
  int historyLength = [myHistory getLength];
  unsigned descriptorNumber = 0;
  id <Index> ix;
  Agent *nbr;
  int otherNbrDefectors = 0;

  for(ix = [nbrs begin: scratchZone], nbr = (Agent *)[ix next];
      [ix getLoc] == Member;
      nbr = (Agent *)[ix next]) {

    decision_t nbrDecision = [nbr getDecision];
    if( nbrDecision == defect ){
      otherNbrDefectors++;
    }
  }
  [ix drop];

  if(historyLength < backwardsMemory){
    timestepsToReport = historyLength;
  }else{
    timestepsToReport = backwardsMemory;
  }

  if([Verbosity showAgentsStateUpdate]){
    printf("\nDisplying state of the world for"
	   " agent at location [%d,%d]", x+1, y+1);
    printf("\n Length: %d", backwardsMemory);
  }

  //Descriptor Other Defectors
  if(dOtherDefectors){
    Number *otherDefectors;
    
    otherDefectors = [Number create: [self getZone]];
    [otherDefectors setInt: otherNbrDefectors];
    
    if(backwardsMemory > 0){
      [myStateOfTheWorld pushItem: otherDefectors 
			 onDescriptor: descriptorNumber];
    }
  
    if([Verbosity showAgentsStateUpdate]){
      printf("\n Number of defectors in chronological order:");
      
      for(j = timestepsToReport; j > 0; j--){
	Number *oDef;
	oDef = [myStateOfTheWorld getObject: (unsigned)(j-1) 
				  fromDescriptor:descriptorNumber];
	printf(" %d", [oDef getInt]);
      }
    }     
    descriptorNumber++; 
  }

  //Descriptor My Decisions
  if(dMyDecisions){
    DecisionObj *decisionObject;

    decisionObject = [DecisionObj create: [self getZone] decision: myDecision];
    
    if(backwardsMemory > 0){
      [myStateOfTheWorld pushItem: decisionObject 
			 onDescriptor: descriptorNumber];
    }
  
    if([Verbosity showAgentsStateUpdate]){
      printf("\n My decisions in chronological order:");
      for(j = timestepsToReport; j > 0; j--){
	DecisionObj *dec;
	dec = [myStateOfTheWorld getObject: (unsigned)(j-1) 
				 fromDescriptor:descriptorNumber];
	if([dec getDecision]==cooperate){
	  printf(" C");
	}else if([dec getDecision]==defect){
	  printf(" D");
	}
      }
      printf("\n");
    }
    descriptorNumber++;
  }

  return self;
  
}


/*

updateHistory

The history is a list of experiences. Updating it means adding the last
experience the Agent has lived

*/

-updateHistory{

  id <Index> ix;
  Agent *nbr;
  int otherNbrDefectors = 0;

  for(ix = [nbrs begin: scratchZone], nbr = (Agent *)[ix next];
      [ix getLoc] == Member;
      nbr = (Agent *)[ix next]) {

    decision_t nbrDecision = [nbr getDecision];
    if( nbrDecision == defect ){
      otherNbrDefectors++;
    }
  }
  [ix drop];

  [myHistory writeExperienceTime: (getCurrentTime())
	     otherNbrDefectors: otherNbrDefectors
	     myDecision: myDecision
	     myPayoff: myPayoff
	     myNbrsDisapprovingOfMe: nbrsDisapprovingOfMe];

  if([Verbosity showAgentsUpdatingHistory]){
    printf("\nDisplying history of agent at location [%d,%d]", x+1, y+1);
    [myHistory print];
    printf("\nEnd of history of agent at location [%d,%d]\n", x+1, y+1);
  }

  return self;
}

-updateAge{
  age++;
  if([Verbosity showAgentsUpdatingAge]){
    printf("\nAgent at location [%d,%d] is now %d years old", x+1, y+1, age);
  }
  return self;
}


/*

reset

Simulating the Agent's death. This is implemented by resetting their age, 
their wealth, and their memory. NOTE THAT THE STATE OF THE WORLD FOR THE 
AGENT IS NOT RESET. This is done for efficiency and has no effect whatsoever
in the simulation because one condition to remember a case is that 
[ historyLength >= (stateLength + f) ]
Therefore, the earliest a case is possibly remembered is when 
historyLength = (stateLength + f)
so everything that is in the State at that time has been observed by the 
agent after having been reset.

*/

-reset{
  age = 0;
  [wealth cset: 0.0];
  myPayoff = nil;
  [myHistory reset];
  
  return self;
}

-(State *)getStateOfTheWorld
{
  return myStateOfTheWorld;
}

-(decision_t)getDecision{
  return myDecision;
}

-(Case *)getCCase
{
  return CCase;
}

-(Case *)getDCase
{
  return DCase;
}

-(DoubleSimple *)getWealth {
  return [wealth copy];
}

-(int)getNumberOfNbrs
{
  return numberOfNbrs;
}

-(double)getWealthForDisplayOnly {
  return [wealth get];
}


/*

getFPPayoff

Get the Payoff as a floating point number. This is just to calculate the 
average payoff in a cycle, and therefore floating point errors are not going
to be an issue.

*/

-(double)getFPPayoff {
  return [myPayoff get];
}


-(decision_process_t)getDecisionProcess {

  return myDecisionProcess;
}


/*

drawDecisonOn:

Draws the agent on the raster with a colour indicating whether the
agent has cooperated (green) or defected (red)

*/

-drawDecisionOn: r {

  [r drawPointX: x Y: y Color: myDecision];

  return self;
}

/*

drawDecisonProcessOn:

Draws the agent on the raster with a colour indicating the process they have
used to make the decision:

Black - At random
Green - Having only a case in which they cooperated
Red - Having only a case in which they defected
Blue - Having one case for each decision, and unaffected by social 
       pressure
Yellow - Beacuse the social pressure was too high for them

*/

-drawDecisionProcessOn: r {
 
  [r drawPointX: x Y: y Color: myDecisionProcess];

  return self;
}

-printLocation{
  printf("(%d, %d)", x + 1, y + 1);
  return self;
}

-printWealth{
  [wealth writeAccurately: stdout];
  return self;
}

-(void)drop {
  if(nbrs != nil) [nbrs drop];
  if(wealth != nil) [wealth free];
  [super drop];
}

@end
