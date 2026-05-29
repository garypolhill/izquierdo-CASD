/*
    CASD-0: Case.h
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

Case.h

A case (or a situation) that occurred at time t is composed of:
1. The information the agent had when they made their decision at time t 
   (i.e., the state of the world at the beginning of time t, before the 
   decison at time t was made). The state of the world is determined by the 
   number of other defectors and the agent's decisions at 
   times (t-1), (t-2),...,(t-b) 
2. The decision the agent made (cooperate or defect)
3. The payoff that the agent got at time t and subsequent 
   time-steps (f payoffs in total).
4. The number of neighbours who disapproved of the Agent at time t and 
   subsequent time-steps (f numbers in total).

Example ( b = 5, f = 3)
Displaying Case <1ed3d8>:
        Time: 37
        Defectors in chronological order: 1 1 0 1 1
        My decisions in chronological order: D D D D D
        Decision:       Defect
        Payoff in chronological order: 1e+01 2e+00 2e+00
        Neighbours dissaproving of me in chronological order:
                1 0 0 


*/

#import <objectbase/SwarmObject.h>
#import "Decision.h"
//So we can use decision_t

@class DoubleSimple, State, Tube;

@interface Case: SwarmObject {
  int time;
  State *state;
  decision_t decision;
  Tube *payoffs;
  Tube *nbrsDisapproving;
}

+create: (id <Zone>)z time: (int)t state: (State *)st decision: (decision_t)dec payoff: (Tube *)poffs nbrsDisapproving: (Tube *)nbrsDis;
-(Case *)copy: (id <Zone>)z;
-(State *)getState;
-(decision_t)getDecision;
-(Tube *)getPayoffs;
-(Tube *)getNbrsDisapproving;
-(DoubleSimple *)getSumOfPayoffs;
-(int)getSumOfNbrsDisapproving;
-(BOOL)eq: (Case *)anotherCase;
-print;
-drop;

@end
