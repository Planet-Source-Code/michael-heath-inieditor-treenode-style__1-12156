Attribute VB_Name = "modMain"
' ***********************************************
' * INI Viewer Engine Alpha                     *
' * Code by: Michael Heath                      *
' * Code Date: 15 Oct 2000                      *
' * Email:  mheath@indy.net                     *
' * -----------------------                     *
' *                                             *
' *                                             *
' * This code was designed to view ini files in *
' * A tree node enviroment.                     *
' *                                             *
' * The purpose of this code was to provide an  *
' * Easy example of using Tree Nodes in VB6.    *
' *                                             *
' * I believe that almost any new VBer will find*
' * This code useful and easy to use.           *
' *                                             *
' * The next revision of this code will enable  *
' * Users to not only view ini files but edit   *
' * Them from the GUI.                          *
' *                                             *
' * Please enjoy the code and send me your      *
' * Comments or suggestions at mheath@indy.net  *
' ***********************************************

' Notes:
'
' You will notice on frmMain there is an object called imgSmall
' This image list must be initiated with the tree node before
' It will work.  To do that, you would right click on the tree node
' And select properties.  On the image list combo box under the General
' Tab, choose the Image list available.
' In this example, you shouldn't have to do that.  This is a reference
' If you decide to use a tree node in the future.

' To keep my node structure in order, you will notice that I
' Declared 5 different nodes.  You will also notice that
' I set the node.tag of each according to what type of node it
' Is.  This will come in handy later on for identifying what
' Type of node is being selected.


Public nodRoot As Node ' Root Node - INI File Name
Public nodSec As Node ' Sections in INI File
Public nodKey As Node ' Key of INI File
Public nodValue As Node ' Value of Key
Public nodCurrentProj As Node

Public Sub GetIniInfo(strFile As String)
On Error GoTo IniErr
' First, we'll clear out the previous file on the node if
' There was one.
Set nodCurrentProj = nodRoot
frmMain.treMain.Nodes.Remove nodCurrentProj.Index
' Make the root node the name of the file
addRoot vFileName

Dim intG As Long
Dim strline As String
Dim strLeft As String
Dim strRight As String
    Open strFile For Input As #1
        Do While Not EOF(1)
            Line Input #1, strline
            strline = UCase(strline)
            strLeft = strline
            strRight = strline
                If Left(strline, 1) = "[" Then ' This is a Key in the INI file
                    strline = Right(strline, Len(strline) - 1)
                    strline = Left(strline, Len(strline) - 1)
                    addSec strline
                ElseIf InStr(strline, "=") Then
                    For intG = 1 To Len(strline)
                        strLeft = Left(strLeft, Len(strLeft) - 1)
                        If InStr(strLeft, "=") Then
                            ' Continue removing characters
                        Else
                            ' We have what we need, let's get out of the for/next loop
                            addKey strLeft
                            Exit For
                        End If
                    Next intG
                    For intG = 1 To Len(strline)
                        strRight = Right(strRight, Len(strRight) - 1)
                        If InStr(strRight, "=") Then
                            ' Continue removing characters
                        Else
                            addValue strRight
                            Exit For
                        End If
                    Next intG
                End If
    Loop
    Close #1
    nodRoot.Expanded = True
Exit Sub
IniErr:
' Error number 91 will happen when the program is first run
' This is because there is nothing on the nodes when it
' Starts up.
If Err.Number = 91 Then
    Resume Next
Else
    MsgBox "An error has occured which will result in termination of this program." _
    & Chr(10) & Err.Number & Chr(10) & Err.Description, vbOKOnly + vbCritical, "Fatal Error"
    Unload frmMain
    Set frmMain = Nothing
    End
End If
End Sub


' ***************************************************
'Tree Node Code

Public Sub addRoot(strline As String)
  'Set up the root node as the CurrentFileName
  Set nodRoot = frmMain.treMain.Nodes.Add(, , "R", strline, 5)
  nodRoot.Tag = "Root"
End Sub
Public Sub addSec(strline As String)
' Adds the section of an INI to the treenode - ie [SAMPLE]
  Set nodSec = frmMain.treMain.Nodes.Add _
    (nodRoot, tvwChild, , strline, 4)
  nodSec.Tag = "Section"
End Sub
Public Sub addKey(strline As String)
  ' Adds the Key of an INI to the treenode ie Setting=
  Set nodKey = _
    frmMain.treMain.Nodes.Add _
    (nodSec, tvwChild, , strline, 2)
  nodKey.Tag = "Key"
End Sub
Public Sub addValue(strline As String)
' Adds the Value of the Key to treenode - ie Setting=1
  Set nodValue = frmMain.treMain.Nodes.Add(nodKey, tvwChild, , strline, 1)
  nodValue.Tag = "Value"
End Sub

Public Sub InsertNode()
On Error GoTo InsertErr
Dim ValueNod As String

' Find out what we will insert Section/Key/Value
If frmMain.treMain.SelectedItem.Tag = "Root" Then
    ValueNod = InputBox("Enter the name of the new Section", "Insert New Section")
    If ValueNod = "" Then Exit Sub
    Set nodSec = frmMain.treMain.Nodes.Add _
        (frmMain.treMain.SelectedItem, tvwChild, , ValueNod, 4)
            nodSec.Tag = "Section"
ElseIf frmMain.treMain.SelectedItem.Tag = "Section" Then
    ValueNod = InputBox("Enter the name of the new Key", "Insert New Key")
    If ValueNod = "" Then Exit Sub
    Set nodKey = frmMain.treMain.Nodes.Add _
        (frmMain.treMain.SelectedItem, tvwChild, , ValueNod, 2)
            nodKey.Tag = "Key"
ElseIf frmMain.treMain.SelectedItem.Tag = "Key" Then
    ValueNod = InputBox("Enter the name of the new Value", "Insert New Value")
    If ValueNod = "" Then Exit Sub
    Set nodValue = frmMain.treMain.Nodes.Add _
        (frmMain.treMain.SelectedItem, tvwChild, , ValueNod, 1)
            nodValue.Tag = "Value"
End If
InsertErr:
    ValueNod = ""
End Sub

Public Sub DeleteNode()
On Error GoTo DeleteErr
If frmMain.treMain.SelectedItem.Tag = "Root" Then
    MsgBox "You can not remove the file name.", vbOKOnly + vbCritical, "Error"
    GoTo DeleteErr
End If
  Set nodCurrentProj = frmMain.treMain.SelectedItem
  If Not nodCurrentProj Is Nothing Then
    frmMain.treMain.Nodes.Remove nodCurrentProj.Index
  End If
DeleteErr:
    ValueNod = ""
End Sub


