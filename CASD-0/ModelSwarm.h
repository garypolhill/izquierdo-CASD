/*
    CASD-0: ModelSwarm.h
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

ModelSwarm.h

*/

#import <objectbase/Swarm.h>
#import <activity.h>
#import <collections/Array.h>
#import <space/Discrete2d.h>
#import "PayoffCalculator.h"
#import "Decision.h"

@class DoubleSimple;

@interface ModelSwarm: Swarm {
  id <Array> agents;
  id <Schedule> schedule;
  int xSize, ySize;
  int radius;
  Discrete2d *world;
  char *envShape; //Planar or toroidal?
  char *nbrhood;//Moore or Von Neumann?
  int numberOfDefectors; //in a given time-step
  int numberOfCooperators;//in a given time-step

  int numberOfRandomDecisions; //taken in a run
  int numberOfDeterministicDecisions; //taken in a run

  int bMemory; //backwards memory
  int fMemory; //forward memory
  BOOL descriptorOtherDefectors; //descriptor for the case base
  BOOL descriptorMyDecisions; //descriptor for the case base
  char *descriptorOtherDefectorsStr;
  char *descriptorMyDecisionsStr;
  DoubleSimple *expThreshold; //DoubleSimple is used to control 
  // floating-point errors
  char *expThresholdStr;
  int peerPressureThreshold;

  //Cycle-related variables
  id <Array> stateOfTheSystem; //To check cyclic behaviour
  BOOL cyclicBehaviour;
  BOOL stableCooperation;
  BOOL stableDefection;
  BOOL checkForCyclicBehaviour;
  int numberOfRandomDecisionsCheck;
  int numberOfDeterministicDecisionsCheck;
  int nOfRandomDecCheck;
  int nOfDeterministicDecCheck;
  int timestepsWithRewardInCycle;
  int timestepsInCycle;
  double averageGroupPayoff; //Average group payoff in the cycle
  //This double will not be used in any 
  //comparison, so we can use floating point numbers without (major) worries.
  BOOL terminated;

  //Payoffs-related variables
  char *payoffCalClassStr;
  char *payoffParameterFile;
  id <PayoffCalculator> payoffCalculator;
  id archiver; //To load the parameters

  //The string containing the decisions to be made (if +d option is used)
  const char *deterministicStr;
  BOOL detStrSpecified;

  id modelActions;
  id modelSchedule;

  //These variables are used to study how often a state of the world formed 
  //by bMemory consecutive universal cooperations (numberOfCooperationStates)
  //, and a state of the world formed by bMemory consecutive universal
  //defections have occurred. They are not necessary at all, only included 
  //for analytical purposes.
  int numberOfCooperationStates;
  int numberOfDefectionStates;
}

-buildObjects;
-buildActions;
-updateState;
-activateIn: (id)swarmContext;
-setDeterministicStr: (const char *)detStr;
-(decision_t)getNextDeterministicDecision;
-(BOOL)isDeterministic;
-getWorld;
-getAgents;
-(int)getSizeX;
-(int)getSizeY;
-getPayoffCalculator;
-(int)getNumberOfDefectors;
-(int)getNumberOfCooperators;
-(int)getRandomDeciders;
-(int)getOnlyCooperateCaseDeciders;
-(int)getOnlyDefectCaseDeciders;
-(int)getTwoCasesDeciders;
-(int)getSocialApprovalDeciders;
-resetUnsuccessfulAgents;
-printCycle;
-checkCyclicBehaviour;
-activateCheckForCyclicBehaviour;
-checkEquilibria;
-dropCases;
-addOneRandomDecision;
-printNumberOfRandomDecisions;
-printNumberOfDeterministicDecisions;
-(int)getMaxNumberOfRandomDec;
-(int)getMaximumDefectorsForReward;
-(BOOL)isTerminated;
-(void)drop;

@end
