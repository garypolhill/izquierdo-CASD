/*
    CASD-0: ModelSwarm.m
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

ModelSwarm.m

*/

#import "ModelSwarm.h"
#import "Agent.h"
#import "Verbosity.h"
#import "Number.h"
#import "DoubleSimple.h"
#import "Decision.h"
#import "Tube.h"
#import "State.h"
#import "Case.h"
#import <errno.h>
#import <random.h>
#import <objc/objc-api.h>
#import <stdlib.h>
#import <ctype.h>

@implementation ModelSwarm

/*

No create/createBegin/createEnd needed as the archiver is used to create the
object. 

*/

-buildObjects {
  int x = 0, y = 0;
  int i;
  
  Class payoffCalClass;
  
  checkForCyclicBehaviour = NO;
  numberOfRandomDecisions = 0;
  numberOfDeterministicDecisions = 0;
  terminated = NO;
  numberOfCooperationStates = 0;
  numberOfDefectionStates = 0;

  if([Verbosity showProgress]) printf("Building model objects");
  [super buildObjects];

  // Load in the parameter file for the payoffCalculator Object
  // using a Swarm Archiver Object

  payoffCalClass = objc_get_class(payoffCalClassStr);
  if(![payoffCalClass conformsTo: @protocol(PayoffCalculator)]) {
    /* raiseEvent(ProtocolViolation, 
	       "PayoffCalculator class %s does not conform to "
	       "PayoffCalculator Protocol"
	       "-- amend parameter file\n", payoffCalClassStr);
    */
    fprintf(stderr, "PayoffCalculator class %s does not conform to "
	    "PayoffCalculator Protocol"
	    "-- amend parameter file\n", payoffCalClassStr );
    abort();
  }

  if([Verbosity showProgress]) {
    printf("\nLoading payoffCalculator from file %s\n"
	   , payoffParameterFile);
  }
  archiver = [LispArchiver create: self setPath: payoffParameterFile];
  payoffCalculator = [archiver 
		       getWithZone: self key: "payoffCalculator"];
  if(payoffCalculator == nil) {
    /* raiseEvent(InvalidOperation, 
	       "Can't find archiver file for payoffCalculator");
    */
    fprintf(stderr, "\nCan't find archiver file for payoffCalculator");
    fprintf(stderr, "\nI'm looking for file: %s\n", payoffParameterFile);
    abort();
  }else{

    // It is in the following method where the first Double object is created.
    // The following Double objects will be instances of the same class as 
    // the first Double created. If there is any Double in the parameter 
    // files specifying a different Double class, then the simulation will 
    // abort for the sake of consistency.

    [payoffCalculator initialiseWithModel: self];
  }

  if([Verbosity showProgress]){
    printf("PayoffCalculator loaded successfully\n");
  }

  //Configure the structure of a case
  
  if(strcmp(descriptorOtherDefectorsStr,"YES") == 0){
    descriptorOtherDefectors = YES;
  }
  else{
    if(strcmp(descriptorOtherDefectorsStr,"NO") == 0){
      descriptorOtherDefectors = NO;
    }
    else{
      printf("\ndescriptorOtherDefectorsStr must be either YES or NO\n");
      abort();
    }
  }

  if(strcmp(descriptorMyDecisionsStr,"YES") == 0){
    descriptorMyDecisions = YES;
  }
  else{
    if(strcmp(descriptorMyDecisionsStr,"NO") == 0){
      descriptorMyDecisions = NO;
    }
    else{
      printf("\ndescriptorMyDecisionsStr must be either YES or NO\n");
      abort();
    }
  }

  if( (descriptorOtherDefectors == NO) && (descriptorMyDecisions == NO) ){
    printf("\n\nWARNING!!! There are no descriptors in the "
	   "state of the world!!!\n"
	   "Backwards Memory set to zero.\n\n");
    bMemory = 0;
  }

  agents = [Array create: self setCount: xSize * ySize];
  // Array to store the agents

  // Create a grid to put the agents in a space
  world = [Discrete2d createBegin: self];
  [world setSizeX: xSize Y: ySize];
  world = [world createEnd];

  if([Verbosity showProgress]) printf("Created world\n");
  
  if(fMemory <= 0){
    printf("\n\nWARNING!!! Forward Memory parameter is not positive."
	   "\nAll decisions will be taken randomly\n\n");
  }

  if(bMemory < 0){
    printf("\nBackwards Memory parameter cannot be a negative number\n");
    abort();
  }

  if(bMemory == 0){
    printf("\n\nWARNING!!! Backwards Memory parameter is zero!\n\n");
  }
  
  //Set the Aspiration Threshold
  expThreshold = [DoubleSimple parseKeepSameClass: expThresholdStr];

  // Create the agents

  for(x = 0, i = 0; x < xSize; x++) {
    for(y = 0; y < ySize; y++, i++) {
      Agent *a = [Agent create: self model: self X: x Y: y];
      // Create the agent -- each agent needs to
      // know the model object so it can ask for
      // information (e.g. the number of cooperators)

      [a setBackwardsMemory: bMemory];
      //Set the backwards memory of the agent

      [a setForwardMemory: fMemory];
      //Set the forward Memory of the agent

      [a setDescriptorOtherDefectors: descriptorOtherDefectors];
      [a setDescriptorMyDecisions: descriptorMyDecisions];

      [a createStateOfTheWorld];

      [a setExperimentationThreshold: expThreshold];
      //Set the Experimentation Threshold of the Agent

      [a setPeerPressureThreshold: peerPressureThreshold];

      [a setPayoffCalculator: payoffCalculator];
      //Set the Payoffclaculator

      [agents atOffset: i put: a];
      [world putObject: a atX: x Y: y];
    }
  }
  if([Verbosity showProgress]) printf("Created agents\n");

  // Create a neighbourhood for each agent. By default, this is a
  // Moore neighbourhood with the specified radius and the environment
  // topology is bounded.

  // First, make sure that there has not been errors in parsing the
  // environment parameters

  if(nbrhood == NULL || strcmp(nbrhood, "") == 0) nbrhood = "moore";
  if(envShape == NULL || strcmp(envShape, "") == 0) envShape = "planar";
  if(strcmp(nbrhood, "moore") != 0 && strcmp(nbrhood, "von-neumann") != 0) {
    fprintf(stderr, "Parse error in nbrhood parameter %s: should be either "
	    "\"moore\" or \"von-neumann\"\n", nbrhood);
    abort();
  }
  if(strcmp(envShape, "planar") != 0 && strcmp(envShape, "toroidal") != 0) {
    fprintf(stderr, "Parse error in envShape parameter %s: should be either "
	    "\"planar\" or \"toroidal\"\n", envShape);
    abort();
  }

  // Then, connect the agents.
  for(x = 0; x < xSize; x++) {
    for(y = 0; y < ySize; y++) {
      int xx, yy, xxx, yyy;
      Agent *a = [world getObjectAtX: x Y: y];
      for(xx = x - radius; xx <= x + radius; xx++) {
	if(strcmp(envShape, "planar") == 0
	   && (xx < 0 || xx >= xSize)) {
	  continue;
	}
	xxx = xx;
	while(xxx < 0) {
	  xxx += xSize;
	}
	xxx = xxx % xSize;
        for(yy = y - radius; yy <= y + radius; yy++) {
	  if(strcmp(envShape, "planar") == 0
	     && (yy < 0 || yy >= ySize)) {
	    continue;
	  }
	  yyy = yy;
	  while(yyy < 0) {
	    yyy += ySize;
	  }
	  yyy = yyy % ySize;
          if(xx == x && yy == y) continue;
	  if(strcmp(nbrhood, "von-neumann") == 0 && !(xx == x || yy == y)) {
	    continue;
	  }
	  if([Verbosity showConnections]) {
	    printf("Connecting agent (%d, %d) to (%d, %d)\n"
		   , x+1, y+1, xxx+1, yyy+1);
	  }
          [a addNeighbour: (Agent *)[world getObjectAtX: xxx Y: yyy]];
        }
      }
    }
  }
  if([Verbosity showProgress]) printf("Connected agents up\n");

  return self;
}

/*

buildActions

Build the schedule for the model. 

*/

-buildActions {
  if([Verbosity showProgress]) printf("Building model schedule\n");
  [super buildActions];
  
  // Create the list of simulation actions. 
  modelActions = [ActionGroup create: self];
  if([Verbosity showCycles]){
    [modelActions createActionTo: self message: M(printCycle)];
  }
  [modelActions createActionForEach: agents message: M(decide)];
  [modelActions createActionTo: payoffCalculator message: M(updateDecisions)];
  [modelActions createActionForEach: agents message: M(updateAccount)];
  [modelActions createActionForEach: agents message: M(resetSocialApproval)];
  [modelActions createActionForEach: agents message: M(judgeNbrs)];
  if([Verbosity showVisitsCompetition]){
    [modelActions createActionTo: self message: M(checkCooperationState)];
    [modelActions createActionTo: self message: M(checkDefectionState)];
  }
  if([Verbosity showEquilibria]){
    [modelActions createActionTo: self message: M(checkEquilibria)];
  }
  if([Verbosity showCyclicBehaviour]){
    [modelActions createActionTo: self message: M(checkCyclicBehaviour)];
  }
  [modelActions createActionTo: self message: M(dropCases)];
  [modelActions createActionTo: self message: M(updateState)];
  [modelActions createActionForEach: agents message: M(updateHistory)];
  [modelActions createActionForEach: agents message: M(updateState)];
  [modelActions createActionForEach: agents message: M(updateAge)];
  [modelActions createActionTo: self message: M(resetUnsuccessfulAgents)];
  // Then we create a schedule that executes the modelActions. 
  modelSchedule = [Schedule createBegin: self];
  [modelSchedule setRepeatInterval: 1];
  modelSchedule = [modelSchedule createEnd];
  [modelSchedule at: 0 createAction: modelActions]; 
  
  return self;
}

/*

updateState

This is the state of the world for an external observer, determined by the 
number of cooperators and the number of defectors at a given time in the 
simulation.

*/

-updateState{
  int numberOfAgents = [agents getCount];
  int i;

  numberOfDefectors = 0;
  numberOfCooperators = 0;
  
  for(i = 0; i < numberOfAgents; i++ ){
    Agent *a = [agents atOffset: i];
    if([a getDecision] == defect){ 
      numberOfDefectors++;
    }else{
      numberOfCooperators++;
    }
  }
  
  if([Verbosity showStateUpdate]){
    printf("\n\nState of the world:");
    printf("\n This year's number of cooperators: %d", numberOfCooperators);
    printf("\n This year's number of defectors: %d\n", numberOfDefectors);
  }

  if([Verbosity showNumberOfCooperators]){
    printf("\n%lu\t%d", getCurrentTime(), numberOfCooperators);
  }

  return self;
}

-activateIn: (id)swarmContext {
  [super activateIn: swarmContext];
  [modelSchedule activateIn: self];
  return [self getSwarmActivity];
}

/*

setDeterministicStr: detStr

Sets the decisions string (e.g. CCDDCDDDC).

*/

-setDeterministicStr: (const char *)detStr
{
  detStrSpecified = YES;
  deterministicStr = detStr;
  return self;
}


/*

getNextDeterministicDecision

Returns the next decision set in the decision string (e.g. CCDDCDDDC), from 
left to right.

*/


-(decision_t)getNextDeterministicDecision
{
  if(*deterministicStr == 'C'){
    if([Verbosity showAgentsDecidingDeterministically]){
      printf("\n\t...to cooperate");
    }
    deterministicStr++;
    numberOfDeterministicDecisions++;
    return cooperate;
  }
  else{
    if(*deterministicStr == 'D'){
      if([Verbosity showAgentsDecidingDeterministically]){
	printf("\n\t...to defect");
      }
      deterministicStr++;
      numberOfDeterministicDecisions++;
      return defect;
    }
    else{
      fprintf(stderr, "\nError reading the deterministic string");
      fprintf(stderr, "\nIt is either too short or not formed by C or D.");
      fprintf(stderr, "\nFor games in which players have forwardMemory = 1 ,"
	      " they never get the same payoff when they select different"
	      " actions, and they never die, a sufficient length for the"
	      " string is %d\n", [self getMaxNumberOfRandomDec]);
      fprintf(stderr, "\nIf players can get the same payoff when they"
	       " select different actions, the number of possible random"
	       " decisions is unlimited, since there can always be a tie!\n"); 
      abort();
    }
  }
  
}

-(BOOL)isDeterministic{
  return detStrSpecified;
}

-getWorld {
  return world;
}

-getAgents {
  return agents;
}

-(int)getSizeX {
  return xSize;
}

-(int)getSizeY {
  return ySize;
}

-getPayoffCalculator{
  return payoffCalculator;
}

-(int)getNumberOfDefectors{
  return numberOfDefectors;
}

-(int)getNumberOfCooperators{
  return numberOfCooperators;
}

-(int)getRandomDeciders{

  int numberOfAgents = [agents getCount];
  int i, numberOfRandomDeciders=0;

  for(i = 0; i < numberOfAgents; i++ ){
    Agent *a = [agents atOffset: i];
    if([a getDecisionProcess] == atRandom){ 
      numberOfRandomDeciders++;
    }
  }
  return numberOfRandomDeciders;
}

-(int)getOnlyCooperateCaseDeciders{

  int numberOfAgents = [agents getCount];
  int i, numberOfDeciders=0;

  for(i = 0; i < numberOfAgents; i++ ){
    Agent *a = [agents atOffset: i];
    if([a getDecisionProcess] == onlyCooperate){ 
      numberOfDeciders++;
    }
  }
  return numberOfDeciders;
}


-(int)getOnlyDefectCaseDeciders{

  int numberOfAgents = [agents getCount];
  int i, numberOfDeciders=0;

  for(i = 0; i < numberOfAgents; i++ ){
    Agent *a = [agents atOffset: i];
    if([a getDecisionProcess] == onlyDefect){ 
      numberOfDeciders++;
    }
  }
  return numberOfDeciders;
}

-(int)getTwoCasesDeciders{

  int numberOfAgents = [agents getCount];
  int i, numberOfDeciders=0;

  for(i = 0; i < numberOfAgents; i++ ){
    Agent *a = [agents atOffset: i];
    if([a getDecisionProcess] == twoCases){ 
      numberOfDeciders++;
    }
  }
  return numberOfDeciders;
}

-(int)getSocialApprovalDeciders {

  int numberOfAgents = [agents getCount];
  int i, numberOfDeciders=0;

  for(i = 0; i < numberOfAgents; i++ ){
    Agent *a = [agents atOffset: i];
    if([a getDecisionProcess] == socialApproval){ 
      numberOfDeciders++;
    }
  }
  return numberOfDeciders;
}

/*

resetUnsuccessfulAgents

When an Agent has negative wealth, it leaves the simulation. This is 
implemented by resetting their age, their wealth, and their memory.

*/

-resetUnsuccessfulAgents
{
  int numberOfAgents = [agents getCount];
  int i;
  DoubleSimple *wealth;
    
  for(i = 0; i < numberOfAgents; i++ ){
    Agent *a = [agents atOffset: i];
    wealth = [a getWealth];
    if([wealth ilt:0]){
      [a reset];
      if([Verbosity showAgentsResetting]){
	printf("\nAgent at location [%d,%d] has been reset", 
	       [a getX]+1, [a getY]+1);
      }
    }
  }
  
  return self;
}

-printCycle{
  printf("\n------------------------[ Cycle %09lu\n", getCurrentTime());
  return self;
}


/*

checkCyclicBehaviour


This method detects any cyclic behaviour which is ocurring when
the method is called for the first time. 
Therefore it SHOULD NOT BE CALLED early in the simulation but 
when we suspect that there could already be a cycle.
If the cycle appears AFTER this method is called for the first time, 
it will not be detected.

*/

-checkCyclicBehaviour
{
  int numberOfAgents = [agents getCount];
  int i;
  BOOL firstTime = NO;
 
  if(!checkForCyclicBehaviour){
    return self;
  }

  cyclicBehaviour = YES;

  //The first time that -checkCyclicBehaviour is called we create
  //the stateOfTheSystem, which is an array that will contain
  //the cases where the agents cooperated (one per agent) and then 
  //the cases where the agents defected (another one per agent).
  //The idea is to look for a match of that stateOfTheSystem from 
  //then on.
  if( cyclicBehaviour && (stateOfTheSystem == nil) && !terminated){
    stateOfTheSystem = [Array create: self setCount: 2*numberOfAgents];
    for(i = 0; i < numberOfAgents; i++ ){
      Case *CCase, *DCase, *CCaseCopy, *DCaseCopy;
      Agent *a = [agents atOffset: i];

      CCase = [a getCCase];
      DCase = [a getDCase];

      if(CCase == nil){
	CCaseCopy = nil;
      }
      else{
	CCaseCopy = [CCase copy: self];
      }

      if(DCase == nil){
	DCaseCopy = nil;
      }
      else{
	DCaseCopy = [DCase copy: self];
      }
      
      [stateOfTheSystem atOffset: i put: CCaseCopy];
      [stateOfTheSystem atOffset: (numberOfAgents+i) put: DCaseCopy];
    }
    timestepsInCycle = 0;
    timestepsWithRewardInCycle = 0;
    averageGroupPayoff = 0.0;
    firstTime = YES;
    numberOfRandomDecisionsCheck = numberOfRandomDecisions;
    numberOfDeterministicDecisionsCheck = numberOfDeterministicDecisions;
    cyclicBehaviour = NO;
  }


  //If there are random decisions going on, then there was no cycle when the 
  //method was called.
  if( (numberOfRandomDecisionsCheck != numberOfRandomDecisions) ||
      (numberOfDeterministicDecisionsCheck != numberOfDeterministicDecisions) ){
    printf("\n\nWARNING! There is a fair chance that checkCyclicBehaviour is"
	   "\ngoing to give the wrong answer when detecting a cycle because"
	   "\nit has been called for the first time when there was no cycle."
	   "\nTherefore, it will not be used.");
    terminated = YES;
  }

  //Here we look for a perfect match
  if(cyclicBehaviour && !firstTime && !terminated){
    for(i = 0; i < numberOfAgents; i++ ){
      Agent *a = [agents atOffset: i];
      Case *agentCCase, *agentDCase, *systemCCase, *systemDCase;

      agentCCase = [a getCCase];
      agentDCase = [a getDCase];
      systemCCase = [stateOfTheSystem atOffset: i];
      systemDCase = [stateOfTheSystem atOffset: (numberOfAgents+i)];

      if( (agentCCase == nil) && (agentDCase == nil) ){
	//This should never happen with the randomDecision check,
	//but, just in case.
	cyclicBehaviour = NO;
      }
      
      if( (agentCCase == nil) && (agentDCase != nil) ){
	if( (systemCCase != nil) || (![agentDCase eq: systemDCase]) ){
	  cyclicBehaviour = NO;
	  break;
	}
      }

      if( (agentCCase != nil) && (agentDCase == nil) ){
	if( (![agentCCase eq: systemCCase]) || (systemDCase != nil) ){
	  cyclicBehaviour = NO;
	  break;
	}
      }

      if( (agentCCase != nil) && (agentDCase !=nil) ){
	if( (![agentCCase eq: systemCCase]) || (![agentDCase eq: systemDCase]) ){
	  cyclicBehaviour = NO;
	  break;
	}
      }

    }
    timestepsInCycle++;
    if([payoffCalculator isRewardGiven]){
      timestepsWithRewardInCycle++;
    }
  }

  //Sum up all the Agents' Payoffs to calculate the average group payoff
  if(!firstTime && !terminated){
    for(i = 0; i < numberOfAgents; i++ ){
      Agent *a = [agents atOffset: i];
      averageGroupPayoff += [a getFPPayoff];
    }
  }

  if(cyclicBehaviour && (fMemory >= 0) && !terminated){
   
    printf("\n\n---------- CYCLIC BEHAVIOUR Length = %d--------Cycle %09lu\n"
	   , timestepsInCycle, getCurrentTime());
    printf("Reward given %d out of %d times --------\n", 
	   timestepsWithRewardInCycle, timestepsInCycle);
    averageGroupPayoff = 
      averageGroupPayoff/timestepsInCycle;
    printf("Average Group Payoff: %g\n", averageGroupPayoff);

    terminated = YES;
  }

  return self;
}

-activateCheckForCyclicBehaviour
{
  checkForCyclicBehaviour = YES;
  return self;
}

/*

checkEquilibria

Check whether the simulation has reached a state of universal cooperation 
or universal defection. Stop the simulation if so.

*/


-checkEquilibria
{
  int i, j;
  DoubleSimple *cooperationPayoff;
  DoubleSimple *defectionPayoff;
  int numberOfAgents = [agents getCount];

  stableCooperation = YES;
  stableDefection = YES;

  cooperationPayoff = [payoffCalculator getPayoffForFullCooperation];
  defectionPayoff = [payoffCalculator getPayoffForFullDefection];

  if( (nOfRandomDecCheck != numberOfRandomDecisions) ||
      (nOfDeterministicDecCheck != numberOfDeterministicDecisions) ){
    stableCooperation = NO;
    stableDefection = NO;
  }

  //Check stable cooperation

  //In order to have stable cooperation, every agent must have at least
  //a CCase. A DCase is not necessary under some circumstances (depending
  //on the value of expThreshold).

  if(stableCooperation){
    for(i = 0; i < numberOfAgents; i++ ){
      Agent *a = [agents atOffset: i];
      if( [a getCCase] == nil ) {
	stableCooperation = NO;
	break;
      }
    }
  }

  //Another necessary condition is that they have cooperated.

  if(stableCooperation){
    for(i = 0; i < numberOfAgents; i++ ){
      Agent *a = [agents atOffset: i];
      if( [a getDecision] != cooperate ) {
	stableCooperation = NO;
	break;
      }
    }
  }

  //The payoffs in the CCase must be all equal to that corresponding to
  //universal cooperation

  if(stableCooperation){
    for(i = 0; i < numberOfAgents; i++ ){
      Agent *a = [agents atOffset: i];
      Tube *payoffs = [[a getCCase] getPayoffs];
      for(j = 0; j < fMemory; j++){
	DoubleSimple *payoff;
	payoff = [payoffs getObject: (unsigned)j];
	if( [payoff ne: cooperationPayoff] ) {
	  stableCooperation = NO;
	  break;
	}
      }
      if(!stableCooperation) break;
    }
  }
	  
  //The state of the world observed by every agent must be universal 
  //cooperation

  if(stableCooperation){
    for(i = 0; i < numberOfAgents; i++ ){
      Agent *a = [agents atOffset: i];
      State *st = [a getStateOfTheWorld];
      if( ![st checkFullCooperation] ){
	stableCooperation = NO;
	break;
      }
      if(!stableCooperation) break;
    }
  }

  //All the previous conditions together are sufficient to guarantee 
  //stable universal cooperation: 
  //1. Since every Agent has cooperated, all the Agents' perceived state of 
  //the world for next timestep's decision is universal cooperation.
  //2. Since they have cooperated, and they have a CCase, they have 
  //necessarily used it, and this CCase has universal cooperation as state
  //of the world, since that is the state that Agents observed (the Agents
  //update their state of the world after this method is called).
  //3. In the next timestep, Agents will use the same CCase that they have 
  //observed before. They will be at exactly the same situation, and 
  //therefore they will cooperate again.

  //Similarly, check stable defection

  if(stableDefection){
    for(i = 0; i < numberOfAgents; i++ ){
      Agent *a = [agents atOffset: i];
      if( [a getDCase] == nil ) {
	stableDefection = NO;
	break;
      }
    }
  }

  if(stableDefection){
    for(i = 0; i < numberOfAgents; i++ ){
      Agent *a = [agents atOffset: i];
      if( [a getDecision] != defect ) {
	stableDefection = NO;
	break;
      }
    }
  }

  if(stableDefection){
    for(i = 0; i < numberOfAgents; i++ ){
      Agent *a = [agents atOffset: i];
      Tube *payoffs = [[a getDCase] getPayoffs];
      for(j = 0; j < fMemory; j++){
	DoubleSimple *payoff;
	payoff = [payoffs getObject: (unsigned)j];
	if( [payoff ne: defectionPayoff] ) {
	  stableDefection = NO;
	  break;
	}
      }
      if(!stableDefection) break;
    }
  }
	  
  if(stableDefection){
    for(i = 0; i < numberOfAgents; i++ ){
      Agent *a = [agents atOffset: i];
      State *st = [a getStateOfTheWorld];
      int nNbrs = [a getNumberOfNbrs];
      if( ![st checkFullDefection: nNbrs] ){
	stableDefection = NO;
	break;
      }
      if(!stableDefection) break;
    }
  }

  if( (stableCooperation || stableDefection) && (fMemory >= 0) ){
    
    if(stableCooperation){
      DoubleSimple *cooperationGroup = [cooperationPayoff copy];

      [cooperationGroup imul: numberOfAgents];
      printf("\n\n---------- STABLE COOPERATION --------Cycle %09lu\n"
	     , getCurrentTime());
      printf("Reward given 1 out of 1 times --------\n");
      printf("Average Group Payoff: ");
      [cooperationGroup writeAccurately: stdout];
      printf("\n");
      [cooperationGroup free];
    }
    
    if(stableDefection){
      DoubleSimple *defectionGroup = [defectionPayoff copy];

      [defectionGroup imul: numberOfAgents];
      printf("\n\n---------- STABLE DEFECTION --------Cycle %09lu\n"
	     , getCurrentTime());
      printf("Reward given 0 out of 1 times --------\n");
      printf("Average Group Payoff: ");
      [defectionGroup writeAccurately: stdout];
      printf("\n");
      [defectionGroup free];
    }
    
    terminated = YES;
  }

  nOfRandomDecCheck = numberOfRandomDecisions;
  nOfDeterministicDecCheck = numberOfDeterministicDecisions;

  return self;
}

      
/*

dropCases

Drop all the cases that Agents have used in this timestep. This cannot be
done before because cases might have been needed to check for equilibria and
cycles.

*/

-dropCases{
  int i;
  int numberOfAgents = [agents getCount];

  for(i = 0; i < numberOfAgents; i++ ){
    Agent *a = [agents atOffset: i];
    Case *CCase = [a getCCase];
    Case *DCase = [a getDCase];
    if(CCase != nil) [CCase drop];
    if(DCase != nil) [DCase drop];
  }

  return self;

}


/*

checkCooperationState

This method is called only if [Verbosity showVisitsCompetition].
It is implemented to study the probability that the state of the world 
determined by backwardsMemory consecutive universal cooperations is observed
before the state of the world determined by backwardsMemory consecutive
universal defections.

*/


-checkCooperationState{
  int i;
  int numberOfAgents = [agents getCount];
  BOOL found = YES;

  if(bMemory <= 0) return self;
  if(getCurrentTime() < bMemory ) return self;

  for(i = 0; i < numberOfAgents; i++ ){
    Agent *a = [agents atOffset: i];
    State *st = [a getStateOfTheWorld];
    if(st == nil){
      found = NO;
      break;
    }
    else if( ![st checkFullCooperation] ){
      found = NO;
      break;
    }
    if(!found) break;
  }

  if(found){
    numberOfCooperationStates++;
    if((numberOfDefectionStates <= 0) && (numberOfCooperationStates == 1) ){
      printf("\n\n---------- COOPERATION STATE WINS 1st VISIT --------"
	     "Cycle %09lu\n", getCurrentTime());
    }
    if((numberOfDefectionStates <= 1) && (numberOfCooperationStates == 2)){
      printf("\n\n---------- COOPERATION STATE WINS 2nd VISIT--------"
	     "Cycle %09lu\n", getCurrentTime());
    }
    if((numberOfDefectionStates <= 2) && (numberOfCooperationStates == 3)){
      printf("\n\n---------- COOPERATION STATE WINS 3rd VISIT--------"
	     "Cycle %09lu\n", getCurrentTime());
    } 
    if((numberOfDefectionStates <= 3) && (numberOfCooperationStates == 4)){
      printf("\n\n---------- COOPERATION STATE WINS 4th VISIT--------"
	     "Cycle %09lu\n", getCurrentTime());
    }   
  }

  return self;
}


/*

checkDefectionState

This method is called only if [Verbosity showVisitsCompetition].
It is implemented to study the probability that the state of the world 
determined by backwardsMemory consecutive universal cooperations is observed
before the state of the world determined by backwardsMemory consecutive
universal defections.

*/

-checkDefectionState{
  int i;
  int numberOfAgents = [agents getCount];
  BOOL found = YES;

  if(bMemory <= 0) return self;
  if(getCurrentTime() < bMemory ) return self;

  for(i = 0; i < numberOfAgents; i++ ){
    Agent *a = [agents atOffset: i];
    State *st = [a getStateOfTheWorld];
    int nNbrs = [a getNumberOfNbrs];
    if(st == nil){
      found = NO;
      break;
    }
    else if(![st checkFullDefection: nNbrs]){
      found = NO;
      break;
    }
    if(!found) break;
  }

  if(found){
    numberOfDefectionStates++;

    if((numberOfDefectionStates == 1) && (numberOfCooperationStates <= 0) ){
      printf("\n\n---------- DEFECTION STATE WINS 1st VISIT --------"
	     "Cycle %09lu\n", getCurrentTime());
    }
    if((numberOfDefectionStates == 2) && (numberOfCooperationStates <= 1) ){
      printf("\n\n---------- DEFECTION STATE WINS 2nd VISIT--------"
	     "Cycle %09lu\n", getCurrentTime());
    }
    if((numberOfDefectionStates == 3) && (numberOfCooperationStates <= 2) ){
      printf("\n\n---------- DEFECTION STATE WINS 3rd VISIT--------"
	     "Cycle %09lu\n", getCurrentTime());
    }
    if((numberOfDefectionStates == 4) && (numberOfCooperationStates <= 3) ){
      printf("\n\n---------- DEFECTION STATE WINS 4th VISIT--------"
	     "Cycle %09lu\n", getCurrentTime());
    }
  }

  return self;
}

/*

addOneRandomDecision

Keeps count of the number of random decisions made in the model. This 
method is called by Agents, everytime they make one decision at random.

*/

-addOneRandomDecision
{
  numberOfRandomDecisions++;
  return self;
}

-printNumberOfRandomDecisions
{
  printf("\nNumber of random decisions: %d\n"
	 , numberOfRandomDecisions);
  return self;
}

-printNumberOfDeterministicDecisions
{
  printf("\nNumber of deterministic decisions: %d\n"
	 , numberOfDeterministicDecisions);
  return self;
}

/*

getMaxNumberOfRandomDec

Returns the maximum number of random decisions that are made in a simulation
depending on the parameters. It is useful to know a sufficient length for 
the string parameter requested when the model is run in deterministic mode 
(i.e. when the option +d is used).

Please, note that this formula is only valid for games in which players never
get the same payoff when they select different actions (otherwise the number 
of random decisions could be infinite), where agents don't 
die (otherwise the number of random decisions could be infinite), and 
where the forward Memory is equal to 1 (otherwise the number could be infinite
or so high that, although we could still give an upper bound, it would not 
be of much use because exploring the parameter space would be intractable). 

*/

-(int)getMaxNumberOfRandomDec
{
  int numberOfAgents = [agents getCount];
  int maxNumber;
  int dOtherDefectors = 1;
  int dMyDecisions = 1;
  int i;

  if(descriptorOtherDefectors){
    for(i = 0; i < bMemory; i++){ 
      dOtherDefectors *= numberOfAgents;
    }
  }

  if(descriptorMyDecisions){
    for(i = 0; i < bMemory; i++){ 
      dMyDecisions *= 2;
    }
  }

  maxNumber = numberOfAgents*( bMemory + 
			       dOtherDefectors * dMyDecisions);

  return maxNumber;
}
  
-(int)getMaximumDefectorsForReward{

  return [payoffCalculator getMaximumDefectorsForReward];
}

-(BOOL)isTerminated
{
  return terminated;
}
     

-(void)drop {
  [super drop];
  return;
}

@end
