
(list
 (cons 'modelSwarm
       (make-instance 'ModelSwarm
		      #:bMemory 1
		      #:fMemory 1
		      #:descriptorOtherDefectorsStr YES
		      #:descriptorMyDecisionsStr YES
		      #:expThresholdStr DoubleSimple=21.0
		      #:peerPressureThreshold 50
		      #:envShape toroidal
		      #:nbrhood moore
                      #:xSize 30
                      #:ySize 30
                      #:radius 3
		      #:payoffCalClassStr Reward
		      #:payoffParameterFile reward.scm)))


