/*
    CASD-0: History.m
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

History.m

*/

#import "History.h"
#import "State.h"
#import "Tube.h"
#import "Case.h"
#import "Experience.h"
#import "DoubleSimple.h"
#import "Number.h"
#import "DecisionObj.h"
#import "Verbosity.h"
#import <collections.h>


@implementation History

+create: (id <Zone>)z
{
  History *obj;
  obj = [super create: z];
 
  obj->experiences = [List create: z];
 
  return obj;
}

/*

writeExperienceTime

This method adds a new experience to the memory (which is a list of 
experiences). An example of an experience is the following:

Time    Other Defectors Decision        Payoff  Nbrs disapproving of me
0               1       Defect          2e+00    0

*/

-writeExperienceTime: (timeval_t)t otherNbrDefectors: (int)df myDecision: (decision_t) dc myPayoff: (DoubleSimple *)p myNbrsDisapprovingOfMe: (int)nd
{
  Experience *anExp;
  anExp = [Experience create: [self getZone]
		      time: t 
		      otherDefectors: df 
		      decision: dc 
		      payoff: p
		      nbrsDisapprovingMe: nd];
  
  [experiences addLast: anExp];
  
  return self;
}

/*

getMatchCaseForState: decision: fMemory:

This method returns a case for a certain state of the world and a given
decision and forward memory f. A case for an experience lived at time t is 
composed of:
1. The information the agent had when it took its decision at time t (i.e., 
   the state of the world at the beginning of time t, before the decison at 
   time t was made). 
2. The decision the agent made (cooperate or defect)
3. The payoff that the agent got at time t and subsequent 
   time-steps (f payoffs in total).
4. The number of neighbours who disapproved of the Agent at time t and 
   subsequent time-steps (f numbers in total).

Imagine an agent with backwards memory 1 and the following history:

Displying history of agent at location [1,2]
Time    Other Defectors Decision        Payoff  Nbrs disapproving of me
0               1       Cooperate       1e+00    0
1               0       Cooperate       9e+00    0
2               1       Defect          2e+00    0
3               1       Cooperate       1e+00    0
4               1       Defect          2e+00    0
5               0       Defect          1e+01    1
6               1       Cooperate       1e+00    0
End of history of agent at location [1,2]

The agent must decide in the following timestep whether to cooperate or 
defect. He calls the following method to get the most recent appropriate 
case when they cooperated:

getMatchCaseForState: (Other Defectors = 1, Decision = cooperate)
            decision: Cooperate 
            fMemory: 1

The returned case (by their history)is:
Displaying Case <1ef038>:
        Time: 1
        Defectors in chronological order: 1
        My decisions in chronological order: C
        Decision:       Cooperate
        Payoff in chronological order: 9e+00
        Neighbours dissaproving of me in chronological order:
                0 
At time 1 the agent lived a similar situation: They observed that in the 
previous timestep (Time = 0) there was one other defector and the Agent had 
cooperated. Under those circumstances, the agent cooperated, got a payoff of 
9, and nobody disapproved of them.

Now the Agent calls the method with the same state of the world and forward
memory but defection as the decision.

getMatchCaseForState: (Other Defectors = 1, Decision = cooperate)
            decision: Defect 
            fMemory: 1

The returned case is now:
Displaying Case <1ef100>:
        Time: 4
        Defectors in chronological order: 1
        My decisions in chronological order: C
        Decision:       Defect
        Payoff in chronological order: 2e+00
        Neighbours dissaproving of me in chronological order:
                0 

At time 4 the agent lived a similar situation: They observed that in the 
previous timestep (Time = 3) there was one other defector and the Agent had 
cooperated. Under those circumstances, the agent defected, got a payoff of 2, 
and nobody disapproved of them.

This process is very demanding in terms of computational power, but uses very
little memory. The longer the simulation run, the longer it takes the Agents 
to find the appropriate cases. Another way of dealing with this search 
problem would be representing the cases explicitly and using a hash table. 
The search would then be much faster (especially when agents have lived for 
long), but the runs would require a lot of memory.   

*/

-(Case *)getMatchCaseForState: (State *)s decision: (decision_t)d fMemory: (int)f{
  unsigned stateLength;
  unsigned i, j;
  id <Index> expInx, internalExpInx;
  BOOL dOtherDefectors = [s isDescriptorOtherDefectorsUsed];
  BOOL dMyDecisions = [s isDescriptorMyDecisionsUsed];
  unsigned oDefectorsDescriptorNumber = -1;
  unsigned myDecisionsDescriptorNumber = -1;

  if(dOtherDefectors){
    oDefectorsDescriptorNumber = [s getOtherDefectorsDescriptorNumber];
  }
  if(dMyDecisions){
    myDecisionsDescriptorNumber = [s getMyDecisionsDescriptorNumber];
  }

  stateLength = [s getLength];
  historyLength = [experiences getCount];
 
  if(historyLength < (stateLength + f)){
    if([Verbosity showAgentsRemembering]){
      printf("\n\tNot enough timesteps have passed!");
    }
    return nil;
    //Not enough timesteps have gone by.
  }

  /*Go to the very end of the list. The End symbol indicates the special 
    position following all members in the collection. This is the location at 
    which an index is positioned just after a next message has returned nil, 
    as a result of moving beyond the last member. 
  */
  expInx = [experiences begin: scratchZone];
  [expInx setLoc: End];
  
  //Go back f timesteps (e.g. if f==1, then the index will be pointing at the
  //most recent experience when the following loop has been executed.
  for(i = 0; i < f; i++){
    [expInx prev]; 
  }

  // Remember that "End" is the position that follows the last 
  // element in a list.

  // Assuming that decision time is time t, 
  // the index is now pointing at the experience that occurred in time-step 
  // (t-f). This experience has the number of defectors,
  // our decision, and the payoff we got in time-step (t-f).

  // A case comprises: the state of the world when we made the 
  // decision, the decision, and the outcome. In other words,
  // a case at time t is composed of the number of other defectors and the 
  // agent's decisions at times (t-1), (t-2),...,(t-b) , 
  // the decision made at time t, and the payoff and number of disapproving 
  // neighbours the agent got at t, (t+1)...(t+f-1). 
  // Therefore, if we are trying to make a decision at time t, the first 
  // case that we have available is the one that happened at time t-f,
  // for which: 
  // 1. The state of the world is the number of other defectors 
  //    at time: t-f-1, t-f-2,..., t-f-b
  // 2. The decison made at time t-f.
  // 3. The payoffs at times: t-f, t-f+1, ..., t-1  
  // 4. The number of neighbours who disapproved of the Agent at time t-f and 
  //    subsequent time-steps (f numbers in total).

  for(i = historyLength - f + 1;
      // We start at the (t-f+1)th experience (which happened at time (t-f) 
      // since time starts at 0) to check the decision the agent made.
      // i is the number of experiences left, and is initialised at (t-f+1).
      (i > stateLength) && ([expInx getLoc] == Member);
      [expInx prev], i--){

    BOOL caseFound = YES;
    Experience *anExp;

    anExp = [expInx get];
    // Get the experience at time i to check the 
    // decision we made at time i.

    if([Verbosity showAgentsRemembering]){
      printf("\n\t I'm remebering the situation I lived at time %lu", 
	     [anExp getTime]);
    }

    if([anExp getDecision] != d){
      if([Verbosity showAgentsRemembering]){
	printf("\n\t\tbut I did not ");
	if(d == cooperate){
	  printf("cooperate at that time");
	}else if(d == defect){
	  printf("defect at that time");
	}
      }
      caseFound = NO;
      // Go to the previous experience
      continue;
    }

    // The decision was the same!
    if([Verbosity showAgentsRemembering]){
      if([anExp getDecision] == cooperate){
	printf("\n\t\tYes! I did cooperate that time");
      }else if([anExp getDecision] == defect){
	printf("\n\t\tYes! I did defect that time");
      }
      printf("\n\t\tLet's see if the situation was exactly the same...");
    }

    // The decision made at i is d.
    // Now we have to check that the number of defectors and the agent's 
    // decisions at times i-1, i-2, ..., i-b match the state of the world.
    internalExpInx = [experiences begin: scratchZone];
    [internalExpInx setOffset: (unsigned)[expInx getOffset]];
    [internalExpInx prev];

    //internalExpInx is now pointing at experience at i-1
    
    for(j = 0; j < stateLength; j++){
      anExp = [internalExpInx get];

      // Check that the number of other defectors in history match the 
      // required state of the world.
      if(dOtherDefectors){
	int defectorsExperience;
	int defectorsState;
	Number *defectors;
	
	defectorsExperience = [anExp getOtherDefectors];
	
	defectors = [s getObject: j 
		       fromDescriptor: oDefectorsDescriptorNumber];
	defectorsState = [defectors getInt];
	
	if(defectorsExperience != defectorsState){
	  caseFound = NO;
	  if([Verbosity showAgentsRemembering]){
	    printf("\n\t\tNo, no, it wasn't."
		   " Different number of other defectors");
	  }
	  break;
	}
      }

      // Check that the agent's decisions in their history match the 
      // required state of the world.
      if(dMyDecisions){
	decision_t decisionExperience;
	decision_t decisionState;
	DecisionObj *decisionSt;
	
	decisionExperience = [anExp getDecision];
	
	decisionSt = [s getObject: j 
			fromDescriptor: myDecisionsDescriptorNumber];
	decisionState = [decisionSt getDecision];
	
	if(decisionExperience != decisionState){
	  caseFound = NO;
	  if([Verbosity showAgentsRemembering]){
	    printf("\n\t\tNo, no, it wasn't. Different decision");
	  }
	  break;
	}
      }

      // Go to previous experience, everything is matching so far
      [internalExpInx prev];
    }
    
    [internalExpInx drop];

    if(caseFound){

      Case *aCase;
      Tube *payoffsTube, *nbrsDisapprovingTube;
      DoubleSimple *payoff;
      int time = 0;

      if([Verbosity showAgentsRemembering]){
	printf("\n\t\tYes! it was exactly the same situation."
	       "\n\t\tI've got a case!");
      }

      // Create the tubes (arrays) with the f payoffs and f numbers of 
      // neighbours disapproving of the agent.
      payoffsTube = [Tube create: scratchZone setLength: (unsigned)f];
      nbrsDisapprovingTube = [Tube create: scratchZone setLength: (unsigned)f];

      anExp = [expInx get];
      time = [anExp getTime];

      for(j = 0; j < f; j++){
	Number *nbrsDisapproving;

	anExp = [expInx get];

	payoff = [anExp getPayoff];
	[payoffsTube pushItem: payoff];

	nbrsDisapproving = [Number create: scratchZone];
	[nbrsDisapproving setInt: [anExp getNbrsDisapproving]];
	[nbrsDisapprovingTube pushItem: nbrsDisapproving];

	[expInx next];
      }

      // And create the case!
      aCase = [Case create: scratchZone 
		    time: time
		    state: s 
		    decision: d 
		    payoff: payoffsTube
		    nbrsDisapproving: nbrsDisapprovingTube];

      if([Verbosity showCaseFound]){
	[aCase print];
      }
      [expInx drop];
      return aCase;
    }

  }//End of search. We have not found any case, so return nil

  [expInx drop];

  return nil;

}

-(unsigned)getLength{
  historyLength = [experiences getCount];
  return historyLength;
}


/*

reset

Drop all the experiences and remove all the pointers in the list.

*/

-reset
{
  id <Index> expInx;
  
  expInx = [experiences begin: scratchZone];
  for([expInx next]; [expInx getLoc] == Member; [expInx next]){
    Experience *anExp = [expInx get];
    [anExp drop];
  }
  [expInx drop];

  [experiences removeAll];

  return self;
}


-print{
  id <Index> expInx;
  
  expInx = [experiences begin: scratchZone];
  printf("\nTime\tOther Defectors\tDecision\tPayoff\tNbrs disapproving of me");
  for([expInx next]; [expInx getLoc] == Member; [expInx next]){
    Experience *anExp = [expInx get];
    [anExp print];
  }
  [expInx drop];

  return self;
}
    
  
@end
