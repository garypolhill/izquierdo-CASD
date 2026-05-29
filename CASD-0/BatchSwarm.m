/*
    CASD-0: BatchSwarm.m
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

BatchSwarm.m

*/

#import "BatchSwarm.h"
#import "ModelSwarm.h"
#import "Verbosity.h"
#import <collections.h>
#import <objectbase.h>
#import <analysis.h>
#import <stdlib.h>              //exit(1);
#import <objc/objc-api.h>	// sel_get_name

@implementation BatchSwarm

-createEnd {
  [super createEnd];
  stopPeriodSpecified = NO;
  return self;
}

-setParameterFile: (const char *)filename {
  parameterFile = filename;
  return self;
}

-setStopPeriod: (int)stopTime {
  stopPeriodSpecified = YES;
  stopPeriod = stopTime;
  return self;
}

-setCheckTime: (int)cTime
{
  checkTimeSpecified = YES;
  checkTime = cTime;
  return self;
}

-setDeterministicStr: (const char *)detStr
{
  detStrSpecified = YES;
  deterministicStr = detStr;
  return self;
}

-buildObjects {

  if([Verbosity showProgress]) printf("Building batch objects\n");
  [super buildObjects];

  // Load in the parameter file using a Swarm Archiver object

  if([Verbosity showProgress]) {
    printf("Loading model from file %s\n", parameterFile);
  }
  archiver = [LispArchiver create: self setPath: parameterFile];
  model = [archiver getWithZone: self key: "modelSwarm"];
  if(model == nil) {
    // raiseEvent(InvalidOperation, "Can't find archiver file for modelSwarm");
    fprintf(stderr, "Can't find archiver file for modelSwarm\n");
    abort();
  }
  if([Verbosity showProgress]) printf("Model loaded successfully\n");

  if(detStrSpecified) [model setDeterministicStr: deterministicStr];

  // Build the model objects

  [model buildObjects];

  return self;
}

-buildActions {
  if([Verbosity showProgress]) printf("Building batch schedule\n");
  [super buildActions];
  [model buildActions];

  if(stopPeriodSpecified){
    outerSchedule = [Schedule createBegin: self];
    outerSchedule = [outerSchedule createEnd];
    [outerSchedule at: stopPeriod
		   createActionTo: self
		   message: M(stop)];
  }
  else{
    fprintf(stderr, "%s -- Batch mode and infinite time -- not a good "
	    "combination!\n", sel_get_name(_cmd));
    exit(1);
  }
  if(checkTimeSpecified){
    checkTimeSchedule = [Schedule createBegin: self];
    checkTimeSchedule = [checkTimeSchedule createEnd];
    [checkTimeSchedule at: checkTime
		       createActionTo: model
		       message: M(activateCheckForCyclicBehaviour)];
  }

  terminationSchedule = [Schedule create: self
				  setRepeatInterval: 1];
  [terminationSchedule at: 0 createActionTo: self message: M(checkTermination)];

  return self;
}

-activateIn: swarmContext {
  [super activateIn: swarmContext];
  if(outerSchedule!=nil)[outerSchedule activateIn: self];
  if(checkTimeSchedule != nil)[checkTimeSchedule activateIn: self];
  [model activateIn: self];
  [terminationSchedule activateIn: self];

  return [self getActivity];
}

-go {
  [[self getActivity] run];             // Run it!
 
  return [[self getActivity] getStatus];
}


-checkTermination
{
  if([model isTerminated]){
    if( [Verbosity showNumberRandomDecisions]){
      [model printNumberOfRandomDecisions];
    }
    if( [Verbosity showNumberDeterministicDecisions]){
      [model printNumberOfDeterministicDecisions];
    }
    [getTopLevelActivity() terminate];
  }
  return self;
}

-stop
{
  if([Verbosity showNumberRandomDecisions]){
    [model printNumberOfRandomDecisions];
  }
  if( [Verbosity showNumberDeterministicDecisions]){
    [model printNumberOfDeterministicDecisions];
  }
  [getTopLevelActivity() terminate];

  return self;
}

@end

