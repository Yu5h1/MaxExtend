fn selectRoot = (
	if (selection.count > 0) do (
		rootObjects = #()
		for obj in getCurrentSelection() do (if (obj.parent == undefined)do (append rootObjects obj))
		select rootObjects
	)
)
fn PopupInfo target: = (messageBox (target as string))
fn PrintInfo target = (target as string)
fn ConvertStringValue txt type = (
	result = try(execute(txt))catch()
	if (classof result != type)do(
		case type of (
			Float:(result = 0.0f)
			Integer:(result = 0)
			Array:(result = #())
			Point2:(result = [0,0])
			Point3:(result = [0,0,0])
			Point4:(result = [0,0,0,0])
			Color:(result = [0,0,0,0])
		)
	)
	result
)
fn Approximately val1 val2 round = (return (abs (val1 - val2)) <= round;)
fn ClosePopupDialogByName name = (
	target = undefined;
	for d in (uiaccessor.getpopupdialogs()) do (
		for p in (windows.getHWNDData d)do(
			if (classof p == string )do(
				if (matchpattern p pattern:name )do(	target = d	)
			)
		)
	)
	if ( target != undefined)do(UIAccessor.CloseDialog target)
)
fn ClearModifiersFromSelection = (
	for sel in (getCurrentSelection()) do (
		while sel.modifiers.count > 0 do (deleteModifier sel sel.modifiers.count)
		sel.pos = [0,0,0]
	)
)