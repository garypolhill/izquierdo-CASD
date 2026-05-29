/*
    CASD-0: History.h
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

History.h

Every agent has a history, which is an instance of this class. An agent's 
history is a collection (more precisely a list) of consecutive experiences.
An example of an agent's history is the following:

Displying history of agent at location [1,1]
Time    Other Defectors Decision        Payoff  Nbrs disapproving of me
0               1       Defect          2e+00    0
1               1       Defect          2e+00    0
2               0       Cooperate       9e+00    0
3               0       Defect          1e+01    1

When an Agent sees a certain new situation (determined by a certain state of 
the world), they try to recall a case for each possible decision by 
"consulting" their history. Their history then returns the most recent case 
that matches the given state of the world in which the agent made the 
requested decision.

*/

#import <objectbase/SwarmObject.h>
#import <collections/List.h>
#import "Decision.h"
//So we can use decision_t

@class State, Case, DoubleSimple;

@interface History: SwarmObject {
  id <List> experiences;
  unsigned historyLength;
}

+create: (id <Zone>)z;
-writeExperienceTime: (timeval_t)t otherNbrDefectors: (int)df myDecision: (decision_t)dc myPayoff: (DoubleSimple *)p myNbrsDisapprovingOfMe: (int)nd;
-(Case *)getMatchCaseForState: (State *)s decision: (decision_t)d fMemory: (int)f;
-(unsigned)getLength;
-reset;
-print;

@end
