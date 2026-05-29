/*
    CASD-0: Reward.h
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

Reward.h

This is a class implementing the payoff matrix of a version of an 
n-player Prisoner's Dilemma.

In this n-player game every agent gets a reward as long as there 
are no more than 'rewardIfThisOrFewer' defectors. 

If the reward is not given, defectors get 'defectionYield' and
cooperators get 'cooperationYield'

If the reward is given, defectors get 'defectionYield + reward' and
cooperators get 'cooperationYield + reward'

Setting the payoffs so

defectionYield > cooperationYield, and
cooperationYield + reward > defectionYield

creates a social dilemma: the Payoff that defectors get is always higher 
than the Payoff obtained by those who cooperate. However, every player is 
better off if they all cooperate than if they all defect 
(cooperationYield + reward > defectionYield). 

*/

#import <objectbase/SwarmObject.h>
#import "PayoffCalculator.h"

@class DoubleSimple, ModelSwarm;

@interface Reward: SwarmObject <PayoffCalculator> {

  /* The following variables are strings that will be read directly 
     from the parameter file and used to create the payoffs, which 
     are Double objects */
  char *defectionYieldStr;
  char *cooperationYieldStr;
  char *rewardStr;

  // Pointer to modelSwarm
  ModelSwarm *model;

  // The following objects are the payoffs
  DoubleSimple *defectionYield;
  DoubleSimple *cooperationYield;
  DoubleSimple *reward;
  DoubleSimple *defectPlusReward;
  DoubleSimple *cooperatePlusReward;

  // The value of this parameter is also read directly from the parameter 
  // file.
  int rewardIfThisOrFewer;

  int numberOfDefectors;
  int numberOfCooperators;

  BOOL rewardGiven;
}

@end
