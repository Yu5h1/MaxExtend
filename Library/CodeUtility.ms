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
fn ReplaceTextFileLine filepath conditions = (
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
fn ConvertScriptToAbbreviation shortcutName txt: = (--ConvertScriptToAbbreviation "testAbbrev" 
	if (txt == unsupplied)do (txt = getclipboardText())
	AbbrevFile = (getdir #maxData )+"MXS_EditorAbbrev.properties"
	if (doesFileExist AbbrevFile)do(		
		txt = substituteString txt "\n" "\\n"
		txt = substituteString txt "\t" "\\t"		
		::AbbrevName = shortcutName
		::AbbrevContent = txt
		ReplaceTextFileLine AbbrevFile #((fn Condition01 l = ( (ReplaceEqualsSymbolValue ::AbbrevName l ::AbbrevContent)) ))
	)	
)
