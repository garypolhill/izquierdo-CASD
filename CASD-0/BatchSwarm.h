/*
    CASD-0: BatchSwarm.h
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

BatchSwarm.h

*/

#import <objectbase.h>
#import <objectbase/Swarm.h>
#import <analysis.h>
#import <activity.h>
#import <defobj.h>

@class ModelSwarm;

@interface BatchSwarm: Swarm {
  int stopPeriod;//argument of +t
  BOOL stopPeriodSpecified;  
  int checkTime;//When we are going to start looking for cycles (+c)
  BOOL checkTimeSpecified; 
  const char *deterministicStr;//string for deterministic decisions (+d)
  BOOL detStrSpecified;
  const char *parameterFile;

  ModelSwarm *model;
  id archiver;//Swarm Archiver object to load parameters from files

  id outerSchedule;
  id checkTimeSchedule;
  id terminationSchedule;
}

-setParameterFile: (const char *)filename;
-setStopPeriod: (int)stopTime;
-setCheckTime: (int)cTime;
-setDeterministicStr: (const char *)detStr;
-buildObjects;
-buildActions;
-activateIn: swarmContext;
-go;
-stop;


@end
