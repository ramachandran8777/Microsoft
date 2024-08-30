Option Explicit

Dim dictGroupsNotToCreate, dictPropertiesToCopy, dictUsersToIgnore, objNetwork
Dim colSourceGroups, colDestinationGroups, objSourceGroup, objDestinationGroup, objUser
Dim colSourceAccounts, colDestinationAccounts, objSourceUser, objDestinationUser, property

' Debugging
Const DEBUGGING = True

' Source and destination computers
Const SOURCE_COMPUTER = "Srouce IP"
Const DESTINATION_COMPUTER = "Destination IP"

' Password to set on newly create user accounts on the Destination Server
Const DEFAULT_PASSWORD = "PASSWORD"

' Constants for comparison of accounts to ignore list
Const MATCH_EXACT = 1
Const MATCH_LEFT = 2

Set dictGroupsNotToCreate = CreateObject("Scripting.Dictionary")
dictGroupsNotToCreate.Add "Administrators", MATCH_EXACT
dictGroupsNotToCreate.Add "Backup Operators", MATCH_EXACT
dictGroupsNotToCreate.Add "Guests", MATCH_EXACT
dictGroupsNotToCreate.Add "Network Configuration Operators", MATCH_EXACT
dictGroupsNotToCreate.Add "Power Users", MATCH_EXACT
dictGroupsNotToCreate.Add "Remote Desktop Users", MATCH_EXACT
dictGroupsNotToCreate.Add "Replicator", MATCH_EXACT
dictGroupsNotToCreate.Add "Users", MATCH_EXACT
dictGroupsNotToCreate.Add "Debugger Users", MATCH_EXACT
dictGroupsNotToCreate.Add "HelpServicesGroup", MATCH_EXACT
dictGroupsNotToCreate.Add "Distributed COM Users", MATCH_EXACT
dictGroupsNotToCreate.Add "Performance Log Users", MATCH_EXACT
dictGroupsNotToCreate.Add "Performance Monitor Users", MATCH_EXACT
dictGroupsNotToCreate.Add "Print Operators", MATCH_EXACT
dictGroupsNotToCreate.Add "Consumer Solutions Users", MATCH_EXACT
dictGroupsNotToCreate.Add "IIS_WPG", MATCH_EXACT
dictGroupsNotToCreate.Add "TelnetClients", MATCH_EXACT


' Properties of user accounts to copy
Set dictPropertiesToCopy = CreateObject("Scripting.Dictionary")
dictPropertiesToCopy.Add "Description", True
dictPropertiesToCopy.Add "FullName", True
dictPropertiesToCopy.Add "HomeDirDrive", True
dictPropertiesToCopy.Add "HomeDirectory", True
dictPropertiesToCopy.Add "LoginHours", True
dictPropertiesToCopy.Add "LoginScript", True
dictPropertiesToCopy.Add "Profile", True

' Accounts to ignore during copying
Set dictUsersToIgnore = CreateObject("Scripting.Dictionary")
dictUsersToIgnore.Add "SUPPORT_", MATCH_LEFT
dictUsersToIgnore.Add "IUSR_", MATCH_LEFT
dictUsersToIgnore.Add "IWAM_", MATCH_LEFT
dictUsersToIgnore.Add "Administrator", MATCH_EXACT
dictUsersToIgnore.Add "Guest", MATCH_EXACT
dictUsersToIgnore.Add "HelpAssistant", MATCH_EXACT
dictUsersToIgnore.Add "ASPNET", MATCH_EXACT

' Should this account be ignored
Function IgnoreObject(Name, dictNames)
    Dim strToIgnore

    IgnoreObject = False

    For Each strToIgnore in dictNames

        ' Match Exact
        If (dictNames.Item(strToIgnore) = MATCH_EXACT) and (UCase(Name) = UCase(strToIgnore)) Then
            IgnoreObject = True
            Exit Function
        End If

        ' Match left
        If (dictNames.Item(strToIgnore) = MATCH_LEFT) and (Left(UCase(Name), Len(strToIgnore)) = UCase(strToIgnore)) Then
            IgnoreObject = True
            Exit Function
        End If

    Next' strToIgnore
End Function

Set objNetwork = CreateObject("Wscript.Network")

' Get groups on source computer and loop through them, copying as necessary
Set colSourceGroups = GetObject("WinNT://" & SOURCE_COMPUTER)
Set colDestinationGroups = GetObject("WinNT://" & DESTINATION_COMPUTER)
colSourceGroups.Filter = Array("group")

For Each objSourceGroup in colSourceGroups

    If IgnoreObject(objSourceGroup.Name, dictGroupsNotToCreate) = False then
        If (DEBUGGING) Then WScript.Echo "Creating Group: " & objSourceGroup.Name
        Set objDestinationGroup = colDestinationGroups.Create("group", objSourceGroup.Name)
        objDestinationGroup.Put "Description", objSourceGroup.Get("Description")
        objDestinationGroup.SetInfo
    Else
        If (DEBUGGING) Then WScript.Echo "Ignoring Group: " & objSourceGroup.Name
    End If
Next ' objSourceGroup

' Get accounts on source computer and loop through them, copying as necessary
Set colSourceAccounts = GetObject("WinNT://" & SOURCE_COMPUTER)
set colDestinationAccounts = GetObject("WinNT://" & DESTINATION_COMPUTER)
colSourceAccounts.Filter = Array("user")
For Each objSourceUser In colSourceAccounts

    If IgnoreObject(objSourceUser.Name, dictUsersToIgnore) = False Then
        If (DEBUGGING) Then WScript.Echo "Copying account: " & objSourceUser.Name

        On Error Resume Next

        Set objDestinationUser = colDestinationAccounts.Create("user", objSourceUser.Name)
        objDestinationUser.SetPassword DEFAULT_PASSWORD
        objDestinationUser.SetInfo

        ' Copy properties from source user to destination user
        For Each property in dictPropertiesToCopy
            If (DEBUGGING) then WScript.Echo "   Copying property " & property & " (" &  objSourceUser.Get(property) & ")"
            objDestinationUser.Put property, objSourceUser.Get(property)
            objDestinationUser.SetInfo
        Next ' property

        ' Put user into destination groups
        For Each objSourceGroup In colSourceGroups
            For Each objUser In objSourceGroup.Members
                If UCase(objUser.Name) = Ucase(objSourceUser.Name) Then 
                    If (DEBUGGING) Then WScript.Echo "Adding user " & objSourceUser.Name & " to group " & objSourceGroup.Name
                    Set objDestinationGroup = GetObject("WinNT://" & DESTINATION_COMPUTER & "/" & objSourceGroup.Name & ",group")
                    objDestinationGroup.Add(objDestinationUser.aDSPath)
                Else
                    If (DEBUGGING) Then WScript.Echo "User " & objSourceUser.Name & " is not a member of group " & objSourceGroup.Name
                End If
            Next ' objUser
        Next 'objSourceGroup

    Else
        If (DEBUGGING) Then WScript.Echo "Ignoring account: " & objSourceUser.Name
    End If
Next ' objSourceUser
