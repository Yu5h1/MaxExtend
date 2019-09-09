fn LoadDll dllpath = (
	LoadSucceed = (try(dotnet.loadAssembly dllpath)catch(false)) != false 
	loadinfo = "LoadAssembly ["+dllpath+"]\n"
	if (LoadSucceed)then( loadinfo = loadinfo + "Succeed ! ")else (loadinfo = loadinfo + " failed... ")			
	print loadinfo
	LoadSucceed
)
fn GetDotNetClass dllpath classname = (
	result = dotNetClass classname
	if (result  == undefined) do (
		if (LoadDll dllpath)do(	 result = dotNetClass classname	)
	)
	result
)
fn GetFileWithPatterns Dir searchPatterns = (
	if (classof searchPatterns != Array) do (searchPatterns = #(searchPatterns))
	results = #()
	for p in searchPatterns do (
		if (p[1] == ".")then( p = "*"+p )
		else if (findString p "*." == undefined) then ( p = "*."+p )
		join results (getFiles (Dir +"\\"+ p))	
	)
	results
)
fn getFilesRecursive folderPath searchPattern:"*" Recursively:false =
(
	searchPatterns = #()
	my_files = #()
	
	if (classOf searchPattern == Array) then (	join searchPatterns searchPattern)
	else(	append searchPatterns searchPattern	)		
	join my_files (GetFileWithPatterns folderPath searchPatterns)		
	if Recursively do(
		dir_array = GetDirectories (folderPath+"/*")
		for d in dir_array do (
			join dir_array (GetDirectories (d+"/*"))
		)
		for d in dir_array do (
				join my_files (GetFileWithPatterns d searchPatterns)
		)
	)
	my_files
)

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