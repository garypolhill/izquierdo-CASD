
(list
 (cons 'modelSwarm
       (make-instance 'ModelSwarm
		      #:bMemory 1
		      #:fMemory 1
		      #:descriptorOtherDefectorsStr YES
		      #:descriptorMyDecisionsStr YES
		      #:expThresholdStr DoubleWarn=21.0!ALL
		      #:peerPressureThreshold 50
		      #:envShape toroidal
		      #:nbrhood moore
                      #:xSize 30
                      #:ySize 30
                      #:radius 3
		      #:payoffCalClassStr Reward
		      #:payoffParameterFile reward.scm)))


