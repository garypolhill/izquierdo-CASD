
(list
 (cons 'modelSwarm
       (make-instance 'ModelSwarm
		      #:bMemory 1
		      #:fMemory 1
		      #:descriptorOtherDefectorsStr YES
		      #:descriptorMyDecisionsStr YES
		      #:expThresholdStr DoubleSimple=21.0
		      #:peerPressureThreshold 81
		      #:envShape toroidal
		      #:nbrhood moore
                      #:xSize 50
                      #:ySize 50
                      #:radius 4
		      #:payoffCalClassStr Reward
		      #:payoffParameterFile reward.scm)))


