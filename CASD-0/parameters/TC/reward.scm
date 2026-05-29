(list
 (cons 'payoffCalculator
       (make-instance 'Reward
		      #:defectionYieldStr DoubleSimple=10.0
		      #:cooperationYieldStr DoubleSimple=9.0
		      #:rewardStr DoubleSimple=10.0
		      #:rewardIfThisOrFewer 15)))
