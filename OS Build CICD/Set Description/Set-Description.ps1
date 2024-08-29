Dim fso, file, objShell
Dim markerFilePath, markerFileName
Dim systemDescription

' Path to the marker file
markerFilePath = "C:\Admin\" ' Change this to a suitable location
markerFileName = "system_description_updated.marker"

' Check if the marker file exists
If Not MarkerFileExists(markerFilePath & markerFileName) Then
    ' Get the hostname
    Set objShell = CreateObject("WScript.Shell")
    strComputerName = objShell.ExpandEnvironmentStrings("%COMPUTERNAME%")
    
    ' Set the system description
    systemDescription = strComputerName
    
    ' Update the system description
    Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
    Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_OperatingSystem")
    For Each objItem In colItems
        objItem.Description = systemDescription
        objItem.Put_
    Next
    
    ' Create the marker file to indicate that the update has been done
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set file = fso.CreateTextFile(markerFilePath & markerFileName)
    file.Close
    
    MsgBox "System description updated successfully.", vbInformation
Else
    MsgBox "System description has already been updated.", vbInformation
End If

' Function to check if marker file exists
Function MarkerFileExists(filePath)
    Set fso = CreateObject("Scripting.FileSystemObject")
    If fso.FileExists(filePath) Then
        MarkerFileExists = True
    Else
        MarkerFileExists = False
    End If
End Function
