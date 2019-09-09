--DetectVertexWhetherConsistent 
fn  DVWC source target = (
	(source != target) and (source != undefined ) and (superclassof target == GeometryClass)and(getNumVerts source.mesh) == (getNumVerts target.mesh)
)
fn HasMorpherModifier obj printLog:true = (
	result = obj.modifiers[morpher] != undefined
	if (not result and printLog) do (	print ("There is no Morpher modifier be found in "+obj.name))
	result  
)
fn TransferMesh source target = (
	while source.modifiers.count > 0 do (	deleteModifier source source.modifiers.count	)
	targetShot = snapShot target	
	for i = 1 to (getNumVerts source.mesh)do(setVert source.mesh i (getVert targetShot.mesh i)	)
 	delete targetShot;
	update source
	redrawViews() ;
)
fn GetMorphers obj = (
	results = #()	
	if (HasMorpherModifier obj) then (
		for i = obj.modifiers.count to 1 by -1 do (	if (classof obj.modifiers[i] == morpher)do(append results obj.modifiers[i]))
	)
	results
)
fn SetMorphersChannelValue obj ChannelData val = (
	if (HasMorpherModifier obj)do(
		morphers = GetMorphers obj		
		target = morphers[ChannelData[1]]		
		if (WM3_MC_HasData target ChannelData[2])do(
			if val != 0 do (
				index = ChannelData[1]			
				if (index < morphers.count)do(
					for m = (index+1) to morphers.count do (
						curMorpher = morphers[m]
						for c = 1 to (WM3_NumberOfChannels curMorpher) do (
							if (WM3_MC_HasData curMorpher c)do(
								WM3_MC_SetValue curMorpher c (0 as float)
							)
						)
					)
				)
			)
			WM3_MC_SetValue target ChannelData[2] (val as float)
		)
	)
)
fn FocusChannel obj ChannelData = (
	if (HasMorpherModifier obj)do(
		morphers = GetMorphers obj		
		target = morphers[ChannelData[1]]
		
		if ($ == obj)do(modPanel.setCurrentObject target)
		if ((mod ChannelData[2] 10)==0)then(
			WM3_SetChannelPos target ((((ChannelData[2]/10)as integer)*10)-9)
			WM3_SetChannelSel target 10
		)else(
			WM3_SetChannelPos target ((((ChannelData[2]/10)as integer)*10)+1)
			WM3_SetChannelSel target ((mod ChannelData[2] 10)as integer)
		)
	)
)
fn CheckMorphersChannelExis obj ChannelData = (
	result = false;
	if (HasMorpherModifier obj)do(
		morphers = GetMorphers obj
		target = morphers[ChannelData[1]]
		result =  WM3_MC_HasData target ChannelData[2]
	)	
	return result;
)
fn RemoveChannelFromMorphers obj ChannelData = (
	if (HasMorpherModifier obj)do(
		morphers = GetMorphers obj		
		target = morphers[ChannelData[1]]
		if (WM3_MC_HasData target ChannelData[2])do(WM3_MC_Delete target ChannelData[2])
	)
)
--Find Unused Channel when ChannelName is unsupplied
fn FindChannel obj ChannelName: qbox:false straightAdd:false = (
	result = undefined;
	if (HasMorpherModifier obj)then(
		morphers = GetMorphers obj	
		for m = 1 to morphers.count do (
			curMorpher = morphers[m]
			for c = 1 to (WM3_NumberOfChannels curMorpher)do(
				if (ChannelName==unsupplied or ChannelName==undefined)then(
					if not(WM3_MC_HasData curMorpher c)do(result = #(m,c))
				)else(
					if  (matchpattern (WM3_MC_GetName curMorpher c) pattern:ChannelName)then(result = #(m,c))
				)
				if (result != undefined)do(exit;)
			)
		)
		if (result == undefined)do(
			enabledAdd = straightAdd;
			queryText = "There is no unused Channel be found. Do you want to Add a Morpher modifier ? "
			if (ChannelName != unsupplied)do(queryText = "There is no Channel Named with "+ChannelName+" . Do you want to Add "+ChannelName+"'s Channel  Data ? ")
			if (qbox)do(	enabledAdd = queryBox queryText)
			if (enabledAdd)do(				
				if (ChannelName==unsupplied)then(					
					if (maxVersion())[1] < 19000 then (
						addModifier obj (Morpher())
						result = #(morphers.count+1,1)
					)else(						
						result = #(morphers.count,(WM3_NumberOfChannels morphers[morphers.count])+1)
					)
				)else(
					result = FindChannel obj straightAdd:true;
				)
			)			
		)
	)else if (straightAdd)do(
		addModifier obj (Morpher())
		result = #(1,1)
	)
	result;
)
fn ExtractMorpherChannel target ChannelData pos: baseshape: = (
	result = undefined;
	if (HasMorpherModifier target)then(
		if (CheckMorphersChannelExis target ChannelData) then (
			maxOps.CloneNodes target offset:[0,0,0] newNodes:&newModelArray
			result = newModelArray[1]
			morphers = GetMorphers result			
			targetMorpher  = morphers[ChannelData[1]]
			channel = ChannelData[2]
			for m in morphers do (for i = 1 to (WM3_NumberOfChannels m) do (WM3_MC_SetValue m i (0 as float)))
			WM3_MC_SetValue targetMorpher channel (100 as float)
			result.name = WM3_MC_GetName targetMorpher channel
			if (baseshape != unsupplied)then (
				baseShapeChannel = 1;
				if (channel  == 1 )do (baseShapeChannel = 100;)		
				WM3_MC_BuildFromNode targetMorpher baseShapeChannel baseshape
				WM3_MC_SetValue targetMorpher baseShapeChannel (100 as float)
			)
			maxOps.CollapseNodeTo result 1 true
			if (pos == unsupplied)do (pos = target.pos)
			result.pos = pos
		)else(messageBox "Channel is not exist.")
	)
	return result;
)
fn GetMeshShape obj pureMesh DotNotClone qbox = (
	result = obj
	if (qbox)do(
		if (obj.modifiers.count > 0)do(
			pureMesh = queryBox "Target Shape have some modifiers.Do you want to Clean them ? "
		)
	)
	if not(DotNotClone) do(
		maxOps.CloneNodes obj offset:[0,0,0] newNodes:&newModelArray
		result = newModelArray[1]
	)
	if (pureMesh)then(
		while result.modifiers.count > 0 do (deleteModifier result result.modifiers.count)
	)else(
		maxOps.CollapseNodeTo result 1 true
	)
	result
)
fn ModifyMorpherBaseShape baseShape targetShape DeleteTarget:false pureMesh:false qbox:false &Progressing: = (

	targetShape = GetMeshShape targetShape pureMesh DeleteTarget qbox

	maxOps.CloneNodes baseShape offset:[0,0,0] newNodes:&newModelArray
	baseShapeTemp = newModelArray[1]
	TransferMesh baseShape targetShape
	
	morphers = GetMorphers baseShapeTemp
		
	progressStart "Loading Morpher Base Shape"
	for m = 1 to morphers.count do (
		tempMorpher = morphers[m]
		addModifier baseShape (Morpher())
		for i = 1 to (WM3_NumberOfChannels tempMorpher) do (
			if (WM3_MC_HasData tempMorpher i)do(
				ChannelData = #(m,i)
				curChannelModel = ExtractMorpherChannel baseShapeTemp ChannelData baseshape:targetShape
				redrawViews() ;
				WM3_MC_BuildFromNode baseShape.modifiers[morpher] i curChannelModel
				delete curChannelModel;
			)
			curProgressing = (100. * i / 100);
			if (Progressing != unsupplied)do(
				Progressing = curProgressing 
			)
			progressUpdate curProgressing 
		)
	)
	delete baseShapeTemp
	delete targetShape
	progressEnd()
)

fn TransferMorpherChannel Source Target ChannelName: ChannelData: pureMesh:false DeleteTarget:false qbox:false = (
	if (superclassOf source == GeometryClass)do(		
		if (ChannelData == undefined or ChannelData == unsupplied )do(ChannelData = FindChannel Source ChannelName:ChannelName straightAdd:true)
		sourceMorphers = GetMorphers Source
		sourceMorpher = sourceMorphers[ChannelData[1]]
		
		if (ChannelName == unsupplied or ChannelName == undefined)do(ChannelName = (WM3_MC_GetName sourceMorpher ChannelData[2]))
		
		if (Source != Target)then (Target = GetMeshShape Target pureMesh DeleteTarget qbox)
		
		redrawViews() ;
		WM3_MC_BuildFromNode sourceMorpher ChannelData[2] Target
		WM3_MC_SetName sourceMorpher ChannelData[2]  ChannelName
-- 		WM3_MC_SetValue sourceMorpher ChannelData[2]  100.0
		FocusChannel Source ChannelData
		if (Source != Target)do(delete Target)
	)
	return ChannelData
)
fn SnapShotToMorpherChannel _morpher refObj _channel Keyframes: MorpherChannelTargetsLimit:25 TangentType:#linear = (
	 
	if (superclassof refObj == GeometryClass )then(
 		intervalCount = 0;
		start = animationrange.start as integer/ticksPerFrame
		end = animationrange.end as integer/ticksPerFrame		
		
		if (Keyframes == unsupplied)do(
			if (MorpherChannelTargetsLimit < 3)do(MorpherChannelTargetsLimit = 3)
			Keyframes = #()
			Keyframes[MorpherChannelTargetsLimit] = End
			--Morpher Channel Targets Limit
			if (end-start > MorpherChannelTargetsLimit)then(
				intervalCount = (end-start)/MorpherChannelTargetsLimit;				
				for i = 1 to (MorpherChannelTargetsLimit-1) do (
					curkeyframe = start+(i*intervalCount)
					if (curkeyframe < end)then(Keyframes[i] = curkeyframe)
					else(Keyframes[i] = End-(intervalCount/2))					
				)
-- 				print (Keyframes.count as string + " " + Keyframes as string)
			)else(
				for i = 1 to (MorpherChannelTargetsLimit-1) do (Keyframes[i] = i)
			)
		)
		first = undefined
		progressStart "Converting keyframes snapshot to morpher channels..."		
		for currentFrame in Keyframes do (
			curShape = at time currentFrame snapshot refObj
			redrawViews();
			if (WM3_MC_HasData _morpher _channel)then(
				WM3_AddProgressiveMorphNode _morpher _channel curShape 			
				delete curShape
			)else(
				WM3_MC_BuildFromNode _morpher _channel curShape
				first = curShape
			)
			curProgressing = (100. * currentFrame / end);
			progressUpdate curProgressing 			
		)
		if (first != undefined)do(delete first)
		
		at time end with animate on (WM3_MC_SetValue _morpher  _channel 100.0)
		for key in _morpher[(getSubAnimNames _morpher)[_channel]].keys do (
			key.InTangentType = TangentType
			key.OutTangentType = TangentType
		)
		
		
		print ("Channel \""+(WM3_MC_GetName _morpher _channel) + "\" Memory Used : "+((WM3_MC_GetMemUse _morpher _channel)as integer)as string+" bytes.")
		progressEnd()		
		
		
	)else(
		messageBox (refObj as string+" needs geometry type and individual to achieve")
	)
)
fn testChannlAnimation Keyframes: = (
	target = at time 0 snapshot $
	addModifier target (Morpher())
	redrawViews()
	SnapShotToMorpherChannel target.modifiers[morpher] $ 1 Keyframes:Keyframes	
	gc()
	select target
	
)