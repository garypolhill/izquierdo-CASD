/*
    CASD-0: Symmetric2x2.m
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

Symmetric2x2.m

*/

#import "Symmetric2x2.h"
#import "ModelSwarm.h"
#import "DoubleSimple.h"
#import "Agent.h"
#import "Verbosity.h"
#import <collections/Array.h>
#import <stdlib.h>

@implementation Symmetric2x2

/* CASD takes special care of floating point numbers, following work 
   led by Gary Polhill that showed the nasty effects that floating point 
   numbers can have in Agent-Based simulation. Whenever there is a double 
   that has the potential to be in a comparison, a Double Object is created,
   so we can detect potential errors.
*/


/*

initialiseWithModel

This method creates the payoffs, which are read from a parameter file 
whose name is specified in the main parameter file of the simulation 
following the heading 
#:payoffParameterFile
The payoffs in the simulation are Double objects. 
They are not simple doubles because we want to make sure that floating 
point errors are not taking place in our simulations (or, if they are, we 
want to know it, and we want to assess their effects).

*/

-initialiseWithModel: (ModelSwarm *)m
{
  // The following Double object is the first Double to be created in the 
  // the simulation. It will be an instance of the Double class specified 
  // in the parameter file, after the heading 
  // #:temptationStr 
  // From then on, every time the methods 
  // parseKeepSameClass: , new: , or copy:
  // are called, they will create an instance of the class
  // to which the first Double object created belongs.
  // For example, if the parameter file says:
  // #:temptationStr DoubleWarn=10.0!ALL
  // Then all the Double objects created after temptation using the methods
  // parseKeepSameClass: , new: , or copy:
  // (which are all the Double objects in the simulation) will be instances
  // of DoubleWarn. If the parameter file specifies another type of Double
  // for subsequent Double Objects, then the simulation will abort. 
  // Therefore every Double Object in the parameter fileS (note that there 
  // are two parameter files) must be of the same class, or the simulation 
  // will abort. This is done for the sake of consistency.

  temptation = [DoubleSimple parseKeepSameClass: temptationStr];

  // The following methods create Double objects, keeping the same class
  // of the first Double created, for the sake of consistency.

  reward = [DoubleSimple parseKeepSameClass: rewardStr];
  suckers = [DoubleSimple parseKeepSameClass: suckersStr];
  punishment = [DoubleSimple parseKeepSameClass: punishmentStr];

  model = m;

  numberOfDefectors = 0;
  numberOfCooperators = 0;
  return self;
}

/*

updateDecisions

This method counts the number of cooperators and defectors in the simulation
and makes specific checks (such as making sure that there are only two agents
playing the 2x2 symmetric game).

*/

-(void)updateDecisions
{
  id <Array> agents;
  id <Index> agentsInx;
  int numberOfAgents = 0;

  agents = [model getAgents];
  agentsInx = [agents begin: scratchZone];
 
  numberOfDefectors = 0;
  numberOfCooperators = 0;

  for([agentsInx next]; [agentsInx getLoc] == Member; [agentsInx next]){
    Agent *a = [agentsInx get];
    if([a getDecision] == defect){ 
      numberOfDefectors++;
    }else if([a getDecision] == cooperate){
      numberOfCooperators++;
    }
    numberOfAgents++;
  }

  [agentsInx drop];

  if([Verbosity showPayoffCalcUpdatingDecisions]){
    printf("\n\nPayoff Calculator updating decisions:");
    printf("\n There are %d defectors and %d cooperators\n", 
	   numberOfDefectors, numberOfCooperators);
  }

  // Specific Checks

  if(numberOfAgents != 2){
    printf("\n Error! More than two players in the 2x2 symmetric game!");
    abort();
  }

  return;
}

/*

getPayoffForDecision

This method returns the payoff (Double Object) for an Agent who has made
a certain decision. The payoff matrix is the following:

Both players cooperate
Both get Reward (R)

Both players defect
Both get Punishment (P)

One cooperates, the other defects.
One gets Suckers (S), the other Temptation (T)

*/


-(DoubleSimple *)getPayoffForDecision: (decision_t)decision{

  if([Verbosity showPayoffCalcGivingPayoffs]){
    printf("\n\tPayoff Calculator gives: ");
  }
  if(numberOfCooperators == 2 && numberOfDefectors == 0){
    if([Verbosity showPayoffCalcGivingPayoffs]){
      [reward writeAccurately: stdout];
      printf(" to a cooperator");
    }
    return reward;
  }else if(numberOfDefectors == 2 && numberOfCooperators == 0){
    if([Verbosity showPayoffCalcGivingPayoffs]){
      [punishment writeAccurately: stdout];
      printf(" to a defector");
    }
    return punishment;
  }else if(numberOfDefectors == 1 && numberOfCooperators == 1){
    if(decision == cooperate){
      if([Verbosity showPayoffCalcGivingPayoffs]){
	[suckers writeAccurately: stdout];
	printf(" to a cooperator");
      }
      return suckers;
    }
    if(decision == defect){
      if([Verbosity showPayoffCalcGivingPayoffs]){
	[temptation writeAccurately: stdout];
	printf(" to a defector");
      }
      return temptation;
    }
  }else{
    printf("\n Error calculating the payoff for the 2x2 symmetric game!");
    abort();
  }
  
  return nil; // This will never happen (hopefully!)
}


/*

getPayoffForFullCooperation

Returns the payoff for an agent when everyone is cooperating,
This method is only used in the method checkEquilibria in ModelSwarm, to 
detect stable universal cooperation.

*/

-(DoubleSimple *)getPayoffForFullCooperation
{
  return reward;
}


/*

getPayoffForFullDefection

Returns the payoff for an agent when everyone is defecting.
This method is only used in the method checkEquilibria in ModelSwarm, to 
detect stable universal defection.

*/

-(DoubleSimple *)getPayoffForFullDefection
{
  return punishment;
}

/*

isRewardGiven

Check whether a reward is given or not.
This is done to analyse the outcome of a game in a simpler way than using
average payoffs. Effectively we are classifying every possible outcome of 
a game into two categories: 
1. The reward was given (cooperative outcomes).
2. The reward was not given (non-cooperative outcomes).
This clear distinction allows us to conduct simple analyses of the outcome
of the simulation.
In this case, we have assumed that the only cooperative outcome is achieved 
when both agents cooperate.

*/

-(BOOL)isRewardGiven
{
  if(numberOfCooperators == 2){
    return YES;
  }
  else{
    return NO;
  }
}
  
-(int)getMaximumDefectorsForReward{

  return 0;
}


@end
