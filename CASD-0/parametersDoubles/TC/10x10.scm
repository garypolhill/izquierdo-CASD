(list
 (cons 'modelSwarm
       (make-instance 'ModelSwarm
		      #:bMemory 1
		      #:fMemory 1
		      #:descriptorOtherDefectorsStr YES
		      #:descriptorMyDecisionsStr YES
		      #:expThresholdStr DoubleWarn=21.0!ALL
		      #:peerPressureThreshold 9
		      #:envShape toroidal
		      #:nbrhood moore
                      #:xSize 10
                      #:ySize 10
                      #:radius 1
		      #:payoffCalClassStr Reward
		      #:payoffParameterFile reward.scm)))


