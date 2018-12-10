fn getFilesRecursive folder pattern childF =
(
	my_files = #()
	join my_files (getFiles (folder +"\\"+ pattern))
	if childF do(
		dir_array = GetDirectories (folder+"/*")
		for d in dir_array do
			join dir_array (GetDirectories (d+"/*"))
		for f in dir_array do
			join my_files (getFiles (f + pattern))
	)
	my_files
)
fn selectRoot = (
	if (selection.count > 0) do (
		rootObjects = #()
		for obj in selection do (
			if (obj.parent == undefined)do (append rootObjects obj)
		)
		select rootObjects
	)
)
fn PopupInfo target: = (
	if (target == unsupplied)do (target = "log nothing")
	messageBox (target as string)
)
fn PrintInfo target = (
	if (target == unsupplied)do (target = "log nothing")
	Print (target as string)
)
fn stringValueFeild val = (
	result = undefined;
	strArray = FilterString val "[,]"
	if (classof strArray) == Array do (
		floatArray =#()
		for i=1 to strArray.count do (
			floatArray[i] = strArray[i] as float;
			if (floatArray[i] == undefined)do(
				print (val + " has invalid value")
				return undefined;
			)
		)
		if (floatArray.count > 1)do(
			if (floatArray.count == 2)then(
				result =  [floatArray[1],floatArray[2]]
			)else if (floatArray.count == 3)then(
				result = [floatArray[1],floatArray[2],floatArray[3]]
			)else if (floatArray.count == 4)then(
				result = [floatArray[1],floatArray[2],floatArray[3],floatArray[4]]
			)
		)
	)
	return result;
)
fn Approximately val1 val2 round = (return (abs (val1 - val2)) <= round;)
fn ClosePopupDialogByName name = (
	target = undefined;
	for d in (uiaccessor.getpopupdialogs()) do (
		for p in (windows.getHWNDData d)do(
			if (classof p == string )do(
				if (matchpattern p pattern:name )do(
					target = d
				)
			)
		)
	)
	if ( target != undefined)do(
		UIAccessor.CloseDialog target;
	)
	
)
fn ClearModifiersFromSelection = (
	for sel in (getCurrentSelection()) do (
		while sel.modifiers.count > 0 do (deleteModifier sel sel.modifiers.count)
		sel.pos = [0,0,0]
	)
)