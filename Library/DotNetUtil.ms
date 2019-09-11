fn WinForm name = ( (dotnetclass ("System.Windows.Forms."+name)))
fn dnSolidBrush colorParm =  (dotNetObject "System.Drawing.SolidBrush" colorParm)
fn dnConvertType obj type = (((dotNetClass "System.Convert").ChangeType obj type))
fn dnRectangle x y w h = (dotnetobject "System.Drawing.Rectangle" x y w h)
fn dnRectangleF x y w h = (dotnetobject "System.Drawing.RectangleF" x y w h)
fn dnPoint x y = (dotnetobject "System.Drawing.Point" x y)	

XmlConvert = dotnetclass "System.Xml.XmlConvert"
fn IsValidXMLName txt = ( try( XmlConvert.VerifyName txt;true )catch( false ) )
fn FilterInValidXMLChar txt = (
	result = ""
	for i = 1 to txt.count do ( if (IsValidXMLName txt[i] )do( result += txt[i] ) )
	result
)

WinFormControl = WinForm "Control"
dnKeys = WinForm "keys"
dnCursors = WinForm "Cursors"

dnColor = dotNetClass "System.Drawing.Color"
dnBrushes = dotNetClass "System.Drawing.Brushes"
dnStringFormat = dotnetClass "System.Drawing.StringFormat"
dnStringAlignment = dotNetClass "System.Drawing.StringAlignment"

	
fn GetColorManDotNetColor tag = (
	c = (( colorman.getColor tag )*255) as color
	(dnColor.fromARGB c.r c.g c.b)
)

fn SetDotNetControlColor dnControl backcolor: forecolor: Children:false = (
	if (backcolor == unsupplied) do (
		MaxBackColor = ( ( colorman.getColor #background )*255 ) as color
		backcolor = dnColor.fromARGB MaxBackColor.r MaxBackColor.g MaxBackColor.b
	)
	if (forecolor == unsupplied) do (
		MaxForeColor = ( ( colorman.getColor #text )*255 ) as color
		forecolor = dnColor.fromARGB MaxForeColor.r MaxForeColor.g MaxForeColor.b
	)		
	dnControl.backcolor = backcolor
	dnControl.forecolor = forecolor
	if (Children and dnControl.Controls.count > 0)do(
		LastIndex = dnControl.Controls.count-1;
		for i = 0 to LastIndex do( SetDotNetControlColor dnControl.Controls.item[i] Children:Children )
	)
	dnControl.Invalidate()
)