Dim strFilename  
Dim objFSO
Dim toReplace
Set objFSO = CreateObject("scripting.filesystemobject")  
strFilename = Wscript.Arguments.Item(0)
toReplace = Wscript.Arguments.Item(1)
If objFSO.fileexists(strFilename) Then  
  Call Writefile(strFilename)  
Else  
  wscript.echo "no such file! " & strFilename  
End If  
Set objFSO = Nothing  

Sub Writefile(ByVal strFilename)  
Dim objExcel  
Dim objWB  
Dim objws  

Set objExcel = CreateObject("Excel.Application")  
Set objWB = objExcel.Workbooks.Open(strFilename)

objExcel.DisplayAlerts = False
For Each objws In objWB.Sheets  
  If Not (objws.UsedRange.Address = "$A$1" And objws.Range("A1") = "") Then
   objws.Copy  
   objExcel.ActiveWorkbook.SaveAs objWB.Path & "\" & Replace(objWB.Name, toReplace, "") & "_" & objws.Name & ".txt", -4158
   objExcel.ActiveWorkbook.Close False
  End If
Next 
objExcel.DisplayAlerts = True

objWB.Close False  
objExcel.Quit  
Set objExcel = Nothing  
End Sub
