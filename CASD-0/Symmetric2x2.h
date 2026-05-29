/*
    CASD-0: Symmetric2x2.h
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

Symmetric2x2.h

This is a class implementing the following 2x2 symmetric payoff matrix:

Both players cooperate
Both get Reward (R)

Both players defect
Both get Punishment (P)

One cooperates, the other defects.
One gets Suckers (S), the other Temptation (T)

This structure allows us to model (for example) four different strategic 
games without optimal equilibrium points:

Leader:              T > S > R > P
Battle of the Sexes: S > T > R > P
Chicken:             T > R > S > P
Prisoner's Dilemma:  T > R > P > S 

*/

#import <objectbase/SwarmObject.h>
#import "PayoffCalculator.h"

@class DoubleSimple, ModelSwarm;

@interface Symmetric2x2: SwarmObject <PayoffCalculator> {

  /* The following variables are strings that will be read directly 
     from the parameter file and used to create the payoffs, which 
     are Double objects */
  char *temptationStr;
  char *rewardStr;
  char *punishmentStr;
  char *suckersStr;

  // Pointer to modelSwarm
  ModelSwarm *model;

  // The following objects are the payoffs
  DoubleSimple *temptation;
  DoubleSimple *reward;
  DoubleSimple *punishment;
  DoubleSimple *suckers;

  int numberOfDefectors;
  int numberOfCooperators;
}

@end
