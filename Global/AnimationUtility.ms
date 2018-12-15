fn getControllers obj ctrls:#() =
(
	for item in refs.dependsOn obj do   
	(
		if isController item AND item.keyable do (append ctrls item)
		getControllers item ctrls:ctrls
	)
	ctrls
)