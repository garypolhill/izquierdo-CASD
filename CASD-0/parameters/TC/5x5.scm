(list
 (cons 'modelSwarm
       (make-instance 'ModelSwarm
		      #:bMemory 1
		      #:fMemory 1
		      #:descriptorOtherDefectorsStr YES
		      #:descriptorMyDecisionsStr YES
		      #:expThresholdStr DoubleSimple=21.0
		      #:peerPressureThreshold 9
		      #:envShape toroidal
		      #:nbrhood moore
                      #:xSize 5
                      #:ySize 5
                      #:radius 1
		      #:payoffCalClassStr Reward
		      #:payoffParameterFile reward.scm)))


