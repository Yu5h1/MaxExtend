Enum = dotNetClass "System.Enum"
fn LoadDll dllpath = (
	LoadSucceed = classof (try(dotnet.loadAssembly dllpath)catch(false)) == dotNetObject
	if (LoadSucceed)then( print ("LoadAssembly ["+(dllpath as string)+"] Succeed ! ") )
	else ( messageBox ("LoadAssembly ["+(dllpath as string)+"] failed... ") )
	LoadSucceed
)
fn ScanningLoadDll name curLocation: previouseLocation: searchpattern:"*" Recursively:false scanning:false = ( result = undefined
	if (curLocation == unsupplied)do (curLocation = getfilenamepath (getThisScriptFilename()) )
	if (curLocation[curLocation.count] != "\\" ) do ( curLocation += "\\")		
	if ( doesFileExist (curLocation + name) )then( result = curLocation + name )else(
		dir_array = GetDirectories (curLocation+"\\"+searchpattern)
		for d in dir_array do (
			if (doesFileExist (d+name) )then( result = d + name; exit;
			)else if (Recursively and (previouseLocation == unsupplied or ( findstring d previouseLocation == undefined) ))do(
				join dir_array (GetDirectories (d+"/*"))  ) 
		)
		if (result == undefined)do( nextLocation  = pathConfig.removePathLeaf curLocation 
			if (doesDirectoryExist nextLocation and not (pathConfig.isRootPath (nextLocation+"\\")) )do(
					result = ScanningLoadDll name curLocation:(nextLocation+"\\") previouseLocation:curLocation scanning:true
			)
		)
	)
	if (scanning == false and result != undefined )do( result = LoadDll result )
	result
)
getfilenamepath (getThisScriptFilename()) +"splitimage.dll"
fn LoadDotNetClass classname DllName: curLocation: = (
	result = dotNetClass classname
	if (result  == undefined) do (
		if (DllName == unsupplied)do(DllName = (filterstring classname ".")[1] +".dll")
		print dllName
		if (ScanningLoadDll dllName curLocation:curLocation )do( result = dotNetClass classname ) 
	)
	result
)
SystemSounds = dotnetclass "System.Media.SystemSounds"

fn WinForm name = ( (dotnetclass ("System.Windows.Forms."+name)))
	
fn dnSolidBrush colorParm =  (dotNetObject "System.Drawing.SolidBrush" colorParm)
fn dnConvertType obj type = (((dotNetClass "System.Convert").ChangeType obj type))
fn dnRectangle x y w h = (dotnetobject "System.Drawing.Rectangle" x y w h)
fn dnRectangleF x y w h = (dotnetobject "System.Drawing.RectangleF" x y w h)
fn dnPoint x y = (dotnetobject "System.Drawing.Point" x y)	
fn dnFont style size = (dotnetobject "System.Drawing.Font" style size)

XmlConvert = dotnetclass "System.Xml.XmlConvert"
fn IsValidXMLName txt = ( try( XmlConvert.VerifyName txt;true )catch( false ) )
fn FilterInValidXMLChar txt = (
	result = ""
	for i = 1 to txt.count do ( if (IsValidXMLName txt[i] )do( result += txt[i] ) )
	result
)

WinFormControl = WinForm "Control"
dnFlatStyle = Winform "FlatStyle"
dnKeys = WinForm "keys"
dnCursors = WinForm "Cursors"

fn dnIntPtr param = ( (DotNetObject "System.IntPtr" param) )

dnColor = dotNetClass "System.Drawing.Color"
dnColorTranslator = dotnetclass "System.Drawing.ColorTranslator"
fn ColorToHtml c = ( dnColorTranslator.ToHtml (dnColor.FromArgb c.a c.r c.g c.b) )
fn ColorFromHtml hexColor = (
	c = (dnColorTranslator.FromHtml hexColor)
	(color c.r c.g c.b c.a)
)
dnBrushes = dotNetClass "System.Drawing.Brushes"
dnPens = dotNetClass "System.Drawing.Pens"
dnStringFormat = dotnetClass "System.Drawing.StringFormat"
dnStringAlignment = dotNetClass "System.Drawing.StringAlignment"

fn GetColorManDotNetColor tag = (
	c = (( colorman.getColor tag )*255) as color
	(dnColor.fromARGB c.r c.g c.b)
)

fn SetDotNetControlColor dnControls backcolor: forecolor: Children:false FlatStyle:(dnFlatStyle.Standard) = (
	if (backcolor == unsupplied) do (
		MaxBackColor = ( ( colorman.getColor #background )*255 ) as color
		backcolor = dnColor.fromARGB MaxBackColor.r MaxBackColor.g MaxBackColor.b
	)
	if (forecolor == unsupplied) do (
		MaxForeColor = ( ( colorman.getColor #text )*255 ) as color
		forecolor = dnColor.fromARGB MaxForeColor.r MaxForeColor.g MaxForeColor.b
	)
	if (classof dnControls != Array)do( dnControls = #(dnControls) )
	for c in dnControls do (
		if ((c == dotNetObject or classof c == dotNetControl) and (c.gettype()).IsSubclassOf WinFormControl )then(
			c.backcolor = backcolor
			c.forecolor = forecolor
			if (hasProperty c "FlatStyle")do( c.FlatStyle = FlatStyle )
			if (Children and c.Controls.count > 0)do(
				LastIndex = c.Controls.count-1;
				for i = 0 to LastIndex do( SetDotNetControlColor c.Controls.item[i] Children:Children )
			)
			c.Invalidate()
		)else(
			print (c as string + " is not Windows.Forms.Control")
		)
	)
)
fn SelectFolderDialog hwnd initPath = (
	(LoadDotNetClass "SelectionDialogUtility.SelectFolderDialog").selectfolder (dnIntPtr hwnd) initPath
)