fn IsMatchedParts parts txt = (
	result = true;
	for part in parts do (
		if (findString txt part == undefined)do(
			result = false
			exit
		)
	)
	result
)
fn ReplaceEqualsSymbolValue n l newValue = (if ((FilterString l "=")[1] == n)do (l=n+"="+newValue);l)
fn ReplaceLineFromTextFile filepath conditions = (
	if (classof conditions == Array and conditions.count > 0)do(
		TextStream = openFile filepath mode:"r"
		contents = #()
		while NOT eof TextStream do ( append contents (readLine TextStream))
		close TextStream
		TextStream = openFile filepath mode:"w"
		txt = ""
		for l in contents do (
			for c in conditions do ( l = c l )
			txt += l + "\n"
		)
		format "%" txt to:TextStream
		close TextStream
	)
)--ReplaceTextFileLine @"C:\Users\Yushi\Desktop\QQQ.txt" #(fn qq l = (if (findstring l "a" != undefined)do (l="QQQQQQQQQQQQQQ");l))
fn ConvertScriptToAbbreviation shortcutName txt: test:false = (--ConvertScriptToAbbreviation "testAbbrev" 
	if (txt == unsupplied)do (txt = getclipboardText())
	AbbrevFile = (getdir #maxData )+"MXS_EditorAbbrev.properties"
	if (doesFileExist AbbrevFile)do(
		txt = substituteString txt "\\" "\\\\"
		txt = substituteString txt "\n" "\\n"
		txt = substituteString txt "\t" "\\t"
		if not test do (
			::AbbrevName = shortcutName
			::AbbrevContent = txt
			ReplaceLineFromTextFile AbbrevFile #((fn Condition01 l = ( (ReplaceEqualsSymbolValue ::AbbrevName l ::AbbrevContent)) ))
		)		
		txt
	)	
)
fn DistributionFiles files DirType:#userStartupScripts explore:false = (--#userScripts #userStartupScripts #startupScripts #scripts #plugcfg	
	IsAllow = false
	Info = ""
	if (classOf files == array )then( IsAllow = doesFileExist files[1] )
	else if (classOf files == string ) then ( IsAllow = doesFileExist files;if IsAllow then (files = #(files)) )
	if IsAllow then (
		targetFolder = (getdir DirType)+@"\"
		for f in files do (
			if (classof f == string and doesFileExist f) do (
				destination = targetFolder+(filenamefrompath f)
				if (doesFileExist destination ) do ( deleteFile destination )
				CopyFile f destination	
			)			
		)
		if explore do (shellLaunch "explorer.exe" (getFilenamePath files[1]) )
	)else( info = "Not allow distribution of ["+(files as string)+"]\nDirType:\n#userScripts\n#userStartupScripts\n#startupScripts\n#scripts\n#plugcfg" )
)