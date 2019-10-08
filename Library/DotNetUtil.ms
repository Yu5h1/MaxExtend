Local Enum = dotNetClass "System.Enum"
Local Environment = dotnetclass "System.Environment"
fn LoadDll dllpath prompt:true = (
	LoadSucceed = classof (try(dotnet.loadAssembly dllpath)catch(false)) == dotNetObject
	if (LoadSucceed)then( print ("LoadAssembly ["+(dllpath as string)+"] Succeed ! ") )
	else (
		warnningInfo = "LoadAssembly ["+(dllpath as string)+"] failed... "
		if (prompt)then(messageBox warnningInfo)else(print warnningInfo)
	)
	LoadSucceed
)
fn ScanningLoadDll name curLocation: previouseLocation: searchpattern:"*" Recursively:false scanning:false prompt:true = ( result = undefined
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
	if (scanning == false )do(
		if (result != undefined )then( result = LoadDll result prompt:prompt )
		else(result = false)	
	)
	result
)
fn LoadDotNetClass classname DllName: curLocation: prompt:true = (
	result = dotNetClass classname
	if (result  == undefined) do (
		if (DllName == unsupplied)do(DllName = (filterstring classname ".")[1] +".dll")		
		if (ScanningLoadDll dllName curLocation:curLocation prompt:prompt )do( result = dotNetClass classname ) 
	)
	result
)
fn ShowSelectFilesDialog title InitialPath:sysinfo.currentdir Types:#() ShowCheckWarrn:false DialogStyle:#Open FileOK: = (
	if (FileOK != unsupplied)do(
		DialogClass = "System.Windows.Forms.OpenFileDialog"
		if (DialogStyle == #Save)do( DialogClass = "System.Windows.Forms.SaveFileDialog" )
		theDialog = dotNetObject DialogClass			
		theDialog.title = title
		theDialog.InitialDirectory = getfilenamepath InitialPath
		theDialog.CheckFileExists = ShowCheckWarrn
		theDialog.CheckPathExists = ShowCheckWarrn
		theDialog.RestoreDirectory = false
		AdditionalfilterString = ""
		for item in types do ( AdditionalfilterString += (toUpper item) + " Files (*."+ (toLower item)+")|*."+(toLower item)+"|" )
		theDialog.fileName = getfilenamefile InitialPath
		theDialog.Filter = AdditionalfilterString+"All Files (*.*)|*.*"
		theDialog.FilterIndex = 0
		dotNet.addEventHandler theDialog "FileOK" FileOK
		theDialog.showDialog()
	)
)
Local SystemSounds = dotnetclass "System.Media.SystemSounds"

fn WinForm name = ( (dotnetclass ("System.Windows.Forms."+name)))
	
fn dnSolidBrush colorParm =  (dotNetObject "System.Drawing.SolidBrush" colorParm)
fn dnConvertType obj type = (((dotNetClass "System.Convert").ChangeType obj type))
fn dnRectangle x y w h = (dotnetobject "System.Drawing.Rectangle" x y w h)
fn dnRectangleF x y w h = (dotnetobject "System.Drawing.RectangleF" x y w h)
fn dnPoint x y = (dotnetobject "System.Drawing.Point" x y)	
fn dnFont style size = (dotnetobject "System.Drawing.Font" style size)

Local XmlConvert = dotnetclass "System.Xml.XmlConvert"
fn IsValidXMLName txt = ( try( XmlConvert.VerifyName txt;true )catch( false ) )
fn FilterInValidXMLChar txt = (
	result = ""
	for i = 1 to txt.count do ( if (IsValidXMLName txt[i] )do( result += txt[i] ) )
	result
)

Local WinFormControl = WinForm "Control"
Local dnFlatStyle = Winform "FlatStyle"
Local dnKeys = WinForm "keys"
Local dnCursors = WinForm "Cursors"

fn dnIntPtr param = ( (DotNetObject "System.IntPtr" param) )

Local dnColor = dotNetClass "System.Drawing.Color"
Local dnColorTranslator = dotnetclass "System.Drawing.ColorTranslator"
fn ColorToHtml c = ( (try(dnColorTranslator.ToHtml (dnColor.FromArgb c.a c.r c.g c.b))catch(dnColorTranslator.ToHtml dnColor.black )) )
fn ColorFromHtml hexColor = (	
	c = try(dnColorTranslator.FromHtml hexColor)catch( print ("convert "+hexColor as string +"fail");dnColor.black)
	(color c.r c.g c.b c.a)
)
Local dnBrushes = dotNetClass "System.Drawing.Brushes"
Local dnPens = dotNetClass "System.Drawing.Pens"
Local dnStringFormat = dotnetClass "System.Drawing.StringFormat"
Local dnStringAlignment = dotNetClass "System.Drawing.StringAlignment"

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
		)
	)
)
fn SelectFolderDialog hwnd InitialPath:sysinfo.currentdir = (
	if (classof hwnd == RolloutClass)do(hwnd = hwnd.hwnd)
	result = ""
	SelectionDialogClass = LoadDotNetClass "SelectionDialogUtility.SelectFolderDialog" prompt:false
	if (SelectionDialogClass != undefined)then( result = SelectionDialogClass.selectfolder (dnIntPtr hwnd) InitialPath )
	else (result = getSavePath caption:"Select Folder" initialDir:InitialPath )
	if (result == undefined)do(result = "")
	result
)

Local dnTreeNode = dotnetclass "System.Windows.Forms.TreeNode"