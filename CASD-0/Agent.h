/*
    CASD-0: Agent.h
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

Agent.h

*/

#import <objectbase/SwarmObject.h>
#import <collections/List.h>
#import "PayoffCalculator.h"
#import "Decision.h"
typedef enum { atRandom = 0, onlyCooperate, onlyDefect, twoCases, 
	       socialApproval} decision_process_t;

@class ModelSwarm, DoubleSimple, History, State, Case;

@interface Agent: SwarmObject {
  History *myHistory;
  id <Zone> history_zone;
  State *myStateOfTheWorld;
  //This state of the world can be different for each agent.
  //It is their individual perception of the world,
  //the last backwardsMemory values for their descriptors.
  decision_t myDecision;
  //decision made by the Agent (cooperate or defect)
  decision_process_t myDecisionProcess;
  //process used to decide. (Only for displaying purposes)
  Case *CCase;
  //Case when they cooperated
  Case *DCase;
  //Case when they defected
  DoubleSimple *wealth;
  DoubleSimple *myPayoff;
  //Payoff obtained
  ModelSwarm *model;
  id <PayoffCalculator> payoffCalculator;

  int backwardsMemory;
  int forwardMemory;
  BOOL dOtherDefectors; //am I using that descriptor?
  BOOL dMyDecisions;//am I using that descriptor?
  int age;
  DoubleSimple *experimentationThreshold; //Aspiration Threshold
  int peerPressureThreshold;
  //Maximum number of disapproving neighbours that the Agent can bear
  id <List> nbrs;
  int x, y, numberOfNbrs;
  int nbrsDisapprovingOfMe;
}

+create: (id <Zone>)z;
+create: (id <Zone>)z model: (ModelSwarm *)m X: (int)ax Y: (int)ay;
+(id <Zone>)getAllHistoriesZone;
-setPayoffCalculator: (id <PayoffCalculator>)p;
-(int)getX;
-(int)getY;
-addNeighbour: (Agent *)a;
-setBackwardsMemory: (int)b;
-setForwardMemory: (int)f;
-setDescriptorOtherDefectors: (BOOL)descriptorOtherDefectors;
-setDescriptorMyDecisions: (BOOL)descriptorMyDecisions;
-createStateOfTheWorld;
-setExperimentationThreshold: (DoubleSimple *)expThreshold;
-setPeerPressureThreshold: (int)pPT;
-decide;
-decideAtRandom;
-decideWhenNoCases;
-decideWhenOnlyCooperate;
-decideWhenOnlyDefect;
-decideWhenTwoCases;
-resetSocialApproval;
-judgeNbrs;//Approve (default) or disapprove of your neighbours
-disapprove: (Agent *)a;
-addOneToNbrsDisapprovingOfMe;
-updateAccount;
-updateState;
-updateHistory;
-updateAge;
-reset;
-(State *)getStateOfTheWorld;
-(decision_t)getDecision;
-(Case *)getCCase;
-(Case *)getDCase;
-(DoubleSimple *)getWealth;
-(int)getNumberOfNbrs;
-(double)getWealthForDisplayOnly;
-(double)getFPPayoff; //get the payoff as a floating point number
-(decision_process_t)getDecisionProcess;
-drawDecisionOn: r;
-drawDecisionProcessOn: r;
-printLocation;
-printWealth;
-(void)drop;

@end
