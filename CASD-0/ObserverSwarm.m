/*
    CASD-0: ObserverSwarm.m
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

ObserverSwarm.m

*/

#import "ObserverSwarm.h"
#import "ModelSwarm.h"
#import "Verbosity.h"
#import "Agent.h" //just to control memory leaks (see -countHistoryZone)
#import <collections.h>
#import <objectbase.h>
#import <analysis.h>
#import <gui.h>
#import <stdlib.h>              //abort();
#import <tkobjc/Frame.h>        // For the legend
#import <tkobjc/Label.h>        // For the legend
#import <tkobjc/global.h>       // For the legend


#define NCOLOURS 5

static const char *colours[NCOLOURS] = {
  "black",
  "green",
  "red",
  "blue",
  "yellow"
};

static const char *greys[NCOLOURS] = {
  "black",
  "grey75",
  "grey50",
  "grey25",
  "white"
};

@implementation ObserverSwarm

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


-setBlackAndWhiteRasters: (BOOL)value {
  bwrasters = value;
  return self;
}

-buildObjects {

  int i;

  if([Verbosity showProgress]) printf("Building observer objects\n");
  [super buildObjects];

  displayPeriod = 1;

  // Load in the parameter file using a Swarm Archiver object

  if([Verbosity showProgress]) {
    printf("Loading model from file %s\n", parameterFile);
  }
  archiver = [LispArchiver create: self setPath: parameterFile];
  model = [archiver getWithZone: self key: "modelSwarm"];
  if(model == nil) {
    //raiseEvent(InvalidOperation, "Can't find archiver file for modelSwarm");
    fprintf(stderr, "\nCan't find archiver file for modelSwarm\n");
    fprintf(stderr, "I'm looking for a file called: %s\n", parameterFile);
    abort();
  }
  if([Verbosity showProgress]) printf("Model loaded successfully\n");

  if(detStrSpecified) [model setDeterministicStr: deterministicStr];

  // Build probe displays for the modelSwarm and observerSwarm, then set
  // the control panel to "Stop" so that the user can change any parameters
  // on the GUI before running the model

  CREATE_ARCHIVED_PROBE_DISPLAY(model);
  CREATE_ARCHIVED_PROBE_DISPLAY(self);

  [controlPanel setStateStopped];

  // Build the model objects

  [model buildObjects];

  // Build the GUI components

  // Build a colour map. 

  colormap = [Colormap create: self];
  				
  if(bwrasters) {
    for(i = 0; i < NCOLOURS; i++){
      [colormap setColor: i ToName: greys[i]];
    }
  }
  else {
    for(i = 0; i < NCOLOURS; i++){
      [colormap setColor: i ToName: colours[i]];
    }
  }

  // Build a raster to show the decision made by every agent.
  // Green - Cooperation
  // Red - Defection

  decisionRaster = [ZoomRaster createBegin: self];
  SET_WINDOW_GEOMETRY_RECORD_NAME(decisionRaster);
  decisionRaster = [decisionRaster createEnd];
  [decisionRaster enableDestroyNotification: self
		  notificationMethod: M(quitDecisionRaster:)];
  [decisionRaster setColormap: colormap];
  [decisionRaster setZoomFactor: 9];
  [decisionRaster setWidth: [model getSizeX] Height: [model getSizeY]];
  [decisionRaster setWindowTitle: "Decisions"];
  [decisionRaster pack];
  
  decisionDisplay = [Object2dDisplay create: self
				     setDisplayWidget: decisionRaster
				     setDiscrete2dToDisplay: [model getWorld]
				     setDisplayMessage: M(drawDecisionOn:)];
  [decisionDisplay setObjectCollection: [model getAgents]];
  
  [decisionRaster setButton: ButtonLeft
		  Client: decisionDisplay
		  Message: M(makeProbeAtX:Y:)];
  
  // Build a raster to show the process by which agents arrived at their
  // decision.
  // Black - At random
  // Green - Having only a case in which they cooperated
  // Red - Having only a case in which they defected
  // Blue - Having one case for each decision, and unaffected by social 
  //        pressure
  // Yellow - Beacuse the social pressure was too high for them

  decisionProcessRaster = [ZoomRaster createBegin: self];
  SET_WINDOW_GEOMETRY_RECORD_NAME(decisionProcessRaster);
  decisionProcessRaster = [decisionProcessRaster createEnd];
  [decisionProcessRaster enableDestroyNotification: self
		  notificationMethod: M(quitDecisionProcessRaster:)];
  [decisionProcessRaster setColormap: colormap];
  [decisionProcessRaster setZoomFactor: 9];
  [decisionProcessRaster setWidth: [model getSizeX] Height: [model getSizeY]];
  [decisionProcessRaster setWindowTitle: "Decision Processes"];
  [decisionProcessRaster pack];
  
  decisionProcessDisplay = 
    [Object2dDisplay create: self
		     setDisplayWidget: decisionProcessRaster
		     setDiscrete2dToDisplay: [model getWorld]
		     setDisplayMessage: M(drawDecisionProcessOn:)];
  [decisionProcessDisplay setObjectCollection: [model getAgents]];
  
  [decisionProcessRaster setButton: ButtonLeft
		  Client: decisionProcessDisplay
		  Message: M(makeProbeAtX:Y:)];

  // Display a legend for the previous raster

  {
    id <Frame> topFrame = [Frame create: self];
    id <Frame> line1 = [Frame createParent: topFrame];
    id <Label> text1 = [Label createParent: line1];
    id <Frame> line2 = [Frame createParent: topFrame];
    id <Label> text2 = [Label createParent: line2];

    const char *texts[] = {
      "                      Cooperate",
      "                         Defect",
      "                      At Random",
      "            Only Cooperate Case",
      "               Only Defect Case",
      "                      Two Cases",
      "                Social Pressure" };

    // I know, it is pathetic, but I couldn't be bother to do it properly

    [topFrame setWindowTitle: "Legend"];

    [text1 setText: "For the Decisions raster                "];
    [text1 setWidth: 40];
    [line1 pack];
    [text1 packFillLeft: YES];

    for(i=0; i<2; i++){
      id <Frame> line = [Frame createParent: topFrame];
      id <Label> text = [Label createParent: line];
      id <Frame> color = [Frame createParent: line];

      [text setText: texts[i]];
      [text setWidth: 30];
      [color setWidth: 10];
      if(bwrasters){
	[globalTkInterp
	  eval: "%s configure -background %s", 
	  [color getWidgetName], greys[i+1]];
      }else{
	[globalTkInterp
	  eval: "%s configure -background %s", 
	  [color getWidgetName], colours[i+1]];
      }

      [line pack];
      [text packFillLeft: YES];
      [color packFillLeft: YES];
    }

    [text2 setText: "For the Decision Processes raster       "];
    [text2 setWidth: 40];
    [line2 pack];
    [text2 packFillLeft: YES];

    for(i=0; i<5; i++){
      id <Frame> line = [Frame createParent: topFrame];
      id <Label> text = [Label createParent: line];
      id <Frame> color = [Frame createParent: line];

      [text setText: texts[i+2]];
      [text setWidth: 30];
      [color setWidth: 10];
      if(bwrasters){
	[globalTkInterp
	  eval: "%s configure -background %s", 
	  [color getWidgetName], greys[i]];
      }else{
	[globalTkInterp
	  eval: "%s configure -background %s", 
	  [color getWidgetName], colours[i]];
      }

      [line pack];
      [text packFillLeft: YES];
      [color packFillLeft: YES];
    }

  }

  // Build a time-series graph showing the wealth of the agents
  
  wealthGraph = [EZGraph create: self
                         setTitle: "Wealth of agents vs. time"
                         setAxisLabelsX: "Time" Y: "Wealth"
                         setWindowGeometryRecordName: "wealthGraph"];
  [wealthGraph enableDestroyNotification: self
               notificationMethod: M(quitWealthGraph:)];
  [wealthGraph createMaxSequence: "max"
	       withFeedFrom: [model getAgents]
	       andSelector: M(getWealthForDisplayOnly)];
  [wealthGraph createAverageSequence: "mean"
	       withFeedFrom: [model getAgents]
	       andSelector: M(getWealthForDisplayOnly)];
  [wealthGraph createMinSequence: "min"
	       withFeedFrom: [model getAgents]
	       andSelector: M(getWealthForDisplayOnly)];

  // Build a graph showing the number of cooperators and defectors
  // against time.

  decisionGraph = [EZGraph create: self
			   setTitle: "Number of defectors vs. time"
			   setAxisLabelsX: "Time" Y: "Size"
			   setWindowGeometryRecordName: "decisionGraph"];
  [decisionGraph enableDestroyNotification: self
		 notificationMethod: M(quitDecisionGraph:)];
  /*
    [decisionGraph createSequence: "cooperators"
		 withFeedFrom: model
		 andSelector: M(getNumberOfCooperators)];
  */
  [decisionGraph createSequence: "defectors"
		 withFeedFrom: model
		 andSelector: M(getNumberOfDefectors)];
  [decisionGraph createSequence: "Maximum for Reward"
		 withFeedFrom: model
		 andSelector: M(getMaximumDefectorsForReward)];

  // Build a graph showing the number of agents using one certain decision
  // process against time.

  decisionProcessGraph = 
    [EZGraph create: self
	     setTitle: "Agents using a decision process vs. time"
	     setAxisLabelsX: "Time" Y: "Size"
	     setWindowGeometryRecordName: "decisionProcessGraph"];
  [decisionProcessGraph enableDestroyNotification: self
			notificationMethod: M(quitDecisionProcessGraph:)];
  [decisionProcessGraph createSequence: "TwoCases"
			withFeedFrom: model
			andSelector: M(getTwoCasesDeciders)];
  [decisionProcessGraph createSequence: "AtRandom"
			withFeedFrom: model
			andSelector: M(getRandomDeciders)];
  [decisionProcessGraph createSequence: "SocialPressure"
			withFeedFrom: model
			andSelector: M(getSocialApprovalDeciders)];
  [decisionProcessGraph createSequence: "OnlyCooperateCase"
			withFeedFrom: model
			andSelector: M(getOnlyCooperateCaseDeciders)];
  [decisionProcessGraph createSequence: "OnlyDefectCase"
			withFeedFrom: model
			andSelector: M(getOnlyDefectCaseDeciders)];

  // Build a graph showing the number of items in various Swarm Zones each
  // time step (useful for tracing memory leaks).

  zoneGraph = [EZGraph create: self
		       setTitle: "Size of various zones vs. time"
		       setAxisLabelsX: "Time" Y: "Size"
		       setWindowGeometryRecordName: "zoneGraph"];
  [zoneGraph enableDestroyNotification: self
	     notificationMethod: M(quitZoneGraph:)];
  [zoneGraph createSequence: "scratch"
	     withFeedFrom: self
	     andSelector: M(countScratchZone)];
  [zoneGraph createSequence: "observer"
	     withFeedFrom: self
	     andSelector: M(countObserverZone)];
  [zoneGraph createSequence: "model"
	     withFeedFrom: self
	     andSelector: M(countModelZone)];
  [zoneGraph createSequence: "histories"
	     withFeedFrom: self
	     andSelector: M(countHistoryZone)];

  return self;
}

/*

updateDisplay

This method is called from the observer schedule to update the displays of 
all the various graphs and rasters.

*/

-updateDisplay {
  if(decisionRaster != nil){
    [decisionDisplay display];
    [decisionRaster drawSelf];
  }
  if(decisionProcessRaster != nil){
    [decisionProcessDisplay display];
    [decisionProcessRaster drawSelf];
  }
  if(wealthGraph != nil) {
    [wealthGraph step];
  }
  if(decisionGraph != nil) {
    [decisionGraph step];
  }
  if(decisionProcessGraph != nil) {
    [decisionProcessGraph step];
  }
  if(zoneGraph != nil) {
    [zoneGraph step];
  }
  [probeDisplayManager update];
  [actionCache doTkEvents];
  return self;
}

-buildActions {
  if([Verbosity showProgress]) printf("Building observer schedule\n");
  [super buildActions];
  [model buildActions];

  displaySchedule = [Schedule create: self
			      setRepeatInterval: displayPeriod];
  [displaySchedule at: 0 createActionTo: self message: M(updateDisplay)];
  
  // The termination schedule will make the program stop when the model
  // is terminated. this happens, for instance, when stable cooperation, or
  // stable defection have been reached.
  terminationSchedule = [Schedule create: self
			      setRepeatInterval: displayPeriod];
  [terminationSchedule at: 0 createActionTo: self message: M(checkTermination)];

  if(stopPeriodSpecified){
    outerSchedule = [Schedule createBegin: self];
    outerSchedule = [outerSchedule createEnd];
    [outerSchedule at: stopPeriod
		   createActionTo: controlPanel
		   message: M(setStateStopped)];
  }
  if(checkTimeSpecified){
    checkTimeSchedule = [Schedule createBegin: self];
    checkTimeSchedule = [checkTimeSchedule createEnd];
    [checkTimeSchedule at: checkTime
		       createActionTo: model
		       message: M(activateCheckForCyclicBehaviour)];
  }

  return self;
}

-activateIn: swarmContext {
  [super activateIn: swarmContext];
  if(outerSchedule!=nil)[outerSchedule activateIn: self];
  if(checkTimeSchedule != nil)[checkTimeSchedule activateIn: self];
  [model activateIn: self];
  [displaySchedule activateIn: self];
  [terminationSchedule activateIn: self];

  return [self getActivity];
}

-(double)countScratchZone {
  return (double)[self countZone: scratchZone];
}

-(double)countObserverZone {
  return (double)[self countZone: self];
}

-(double)countModelZone {
  return (double)[self countZone: model];
}

-(double)countHistoryZone {
  return (double)[self countZone: [Agent getAllHistoriesZone]];
}

/*

countZone: z

This method, designed by Gary Polhill, counts the number of objects in
zone z, including sub-zones.

*/

-(unsigned long long)countZone: (id <Zone>)z {
  id <List> pop = [z getPopulation];
  id <ListIndex> ix = [pop listBegin: scratchZone];
  unsigned long long c = 0;
  id member;

  for(member = [ix next]; [ix getLoc] == Member; member = [ix next]) {
    if([member isKindOfClassNamed: "Zone_c"]) {
      c += [self countZone: member];
    }
    else {
      c++;
    }
  }
  [ix drop];
  return c;
}

/*

These quit... methods are required to allow the program to cope with the
various widgets created to be destroyed by the user during the simulation.
This then stops them from being updated in the updateDisplay method.

*/

-quitDecisionRaster: caller {
  [decisionRaster drop];
  decisionRaster = nil;
  return self;
}

-quitDecisionProcessRaster: caller {
  [decisionProcessRaster drop];
  decisionProcessRaster = nil;
  return self;
}

-quitWealthGraph: caller {
  [wealthGraph drop];
  wealthGraph = nil;
  return self;
}

-quitDecisionGraph: caller {
  [decisionGraph drop];
  decisionGraph = nil;
  return self;
}

-quitDecisionProcessGraph: caller {
  [decisionProcessGraph drop];
  decisionProcessGraph = nil;
  return self;
}

-quitZoneGraph: caller {
  [zoneGraph drop];
  zoneGraph = nil;
  return self;
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
    [controlPanel setStateStopped];
  }
  return self;
}

@end

