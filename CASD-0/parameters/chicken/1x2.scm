(list
 (cons 'modelSwarm
       (make-instance 'ModelSwarm
		      #:bMemory 1
		      #:fMemory 1
		      #:descriptorOtherDefectorsStr YES
		      #:descriptorMyDecisionsStr YES
		      #:expThresholdStr DoubleSimple=20.0
		      #:peerPressureThreshold 1
		      #:envShape planar
		      #:nbrhood moore
                      #:xSize 1
                      #:ySize 2
                      #:radius 1
		      #:payoffCalClassStr Symmetric2x2
		      #:payoffParameterFile chicken.scm)))


