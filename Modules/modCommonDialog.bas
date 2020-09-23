Attribute VB_Name = "modCommonDialog"
' ***********************************************
' * Common Dialog Code                          *
' * Code by: Michael Heath                      *
' * Code Date: Sometime in '99                  *
' * Email:  mheath@indy.net                     *
' * -----------------------                     *
' * Simple CommonDialog Routines for Open/Save  *
' * File operations.                            *
' * Being revised from time to time.            *
' ***********************************************

Public CurrentFileName As String     ' Holds filename
Public NoOpen As Boolean             ' Flag for file operation
Public vFileName As String           ' Name of File without the path
Public strAppName As String          ' Name of this App
Public Sub OpenFile(vForm As Form, vFilter As String)
' Reset the NoOpen flag
NoOpen = False
CurrentFileName = ""
' Handle errors
    On Error GoTo OpenProblem
    vForm.CommonDialog1.InitDir = App.Path
    vForm.CommonDialog1.Filter = vFilter
    vForm.CommonDialog1.FilterIndex = 1
    ' Display an Open dialog box.
    vForm.CommonDialog1.Action = 1
    vForm.Caption = strAppName & " - " & vForm.CommonDialog1.FileName
    vForm.Caption = strAppName & " - " & vForm.CommonDialog1.FileName
    CurrentFileName = vForm.CommonDialog1.FileName
    vFileName = vForm.CommonDialog1.FileTitle
    If CurrentFileName = "" Then NoOpen = True
    Exit Sub
OpenProblem:
    ' There was a problem so let's flag NoOpen as true
    NoOpen = True
    Exit Sub

End Sub

Public Sub SaveFile(vForm As Form, vFilter As String)
On Error GoTo SaveERR
    Dim FileNum As Integer
    ' Set Initial Directory to open and FileTypes
        vForm.CommonDialog1.InitDir = App.Path & "\Save"
        ' vForm.CommonDialog1.Filter = "ALL Files | *.*"
        
        vForm.CommonDialog1.Filter = vFilter
        If CurrentFileName = "" Then
            ' Code revised - Do nothing
            CurrentFileName = "NewFile"
        Else
            vForm.CommonDialog1.FileName = CurrentFileName
        End If
            vForm.CommonDialog1.ShowSave
            CurrentFileName = vForm.CommonDialog1.FileName
Exit Sub
SaveERR:
    ' No real error trap, just exit the sub and give a description of the error
    MsgBox "An error occured. " & Err.Description, vbOKOnly + vbInformation, "Save Error"
End Sub

Public Function PutFileInString(sFileName As String) As String
    'sFileName must include Path and file na
    '     me
    'eg "c:\Windows\notepad.exe"
    Dim iFree As Integer, sizeOfFile As Long
    Dim sFileString As String, sTemp As String
    iFree = FreeFile
    Open sFileName For Binary Access Read As iFree
    sizeOfFile = LOF(iFree)
    sFileString = Space$(sizeOfFile)
    Get iFree, , sFileString
    Close #iFree
    PutFileInString = sFileString
    
    ' Thanks to Robert Carter for this function
End Function



