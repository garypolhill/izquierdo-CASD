/*
    CASD-0:
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
      Gary Polhill,
      Macaulay Institute, Craigiebuckler, Aberdeen, AB15 8QH. United Kingdom
      g.polhill@macaulay.ac.uk
*/

/*

CASD

Verbosity.h

This is a class for controlling messages printed to the terminal
during the model run. Before any method writes a message to stdout, it
should check that an appropriate verbosity level has been specified by
the user by calling [Verbosity showXXXX] where XXXX is a category of
messages to show (not to be confused with Obj-C categories). The
method returns a boolean, which if true, means the message can be
printed.

You can either use one of the message categories below (the names of
the show... methods should be reasonably self-explanatory) or create a
new category by adding an appropriate method declaration here, and in
Verbosity.m adding a method definition using the SHOW macro (just
follow the examples in Verbosity.m).

The Verbosity class is initialised from a verbosity file, which
specifies, for each category of message, a number at or above which
the user should set the verbosity in order to see messages pertaining
to that category. The printValidMessages: method prints a list of
message categories to the specified file pointer, and setLevel: sets
the level of verbosity required by the user (it is called from
main.m). alwaysShow: provides scope for over-riding the verbosity
level, and always showing the messages belonging to the specified
category.

*/

#import <objc/Object.h>
#import <stdio.h>

@interface Verbosity: Object {
}

+(void)initialise: (const char *)verbosityFile;
+(void)printValidMessages: (FILE *)fp;
+(void)setLevel: (int)lvl;
+(BOOL)alwaysShow: (char *)message;

+(BOOL)showParseArgs;
+(BOOL)showProgress;
+(BOOL)showConnections;
+(BOOL)showStateUpdate;
+(BOOL)showAgentsUpdatingHistory;
+(BOOL)showCaseFound;
+(BOOL)showSumOfPayoffs;
+(BOOL)showCycles;
+(BOOL)showAgentsResetting;
+(BOOL)showPayoffCalcUpdatingDecisions;
+(BOOL)showPayoffCalcGivingPayoffs;
+(BOOL)showAgentsDeciding;
+(BOOL)showAgentsRemembering;
+(BOOL)showAgentsStateUpdate;
+(BOOL)showAgentsDecidingAtRandom;
+(BOOL)showAgentsUpdatingAccount;
+(BOOL)showEquilibria;
+(BOOL)showNumberRandomDecisions;
+(BOOL)showAgentsJudging;
+(BOOL)showSumOfNbrsDisapproving;
+(BOOL)showCyclicBehaviour;
+(BOOL)showNumberOfCooperators;
+(BOOL)showAgentsDecidingDeterministically;
+(BOOL)showNumberDeterministicDecisions;
+(BOOL)showVisitsCompetition;
+(BOOL)showAgentsUpdatingAge;

@end
        
