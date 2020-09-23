VERSION 5.00
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Begin VB.Form frmMain 
   Caption         =   "Main"
   ClientHeight    =   5535
   ClientLeft      =   60
   ClientTop       =   720
   ClientWidth     =   8865
   Icon            =   "frmMain.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   5535
   ScaleWidth      =   8865
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton cmdSave 
      Caption         =   "&Save Changes"
      Height          =   375
      Left            =   1290
      TabIndex        =   2
      Top             =   5130
      Width           =   1395
   End
   Begin VB.CommandButton cmdBrowse 
      Caption         =   "&Open File"
      Height          =   375
      Left            =   30
      TabIndex        =   1
      Top             =   5130
      Width           =   1245
   End
   Begin MSComDlg.CommonDialog CommonDialog1 
      Left            =   5760
      Top             =   60
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin MSComctlLib.ImageList imgSmall 
      Left            =   5790
      Top             =   4680
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   12632256
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   5
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":0442
            Key             =   ""
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":08A2
            Key             =   ""
         EndProperty
         BeginProperty ListImage3 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":0D02
            Key             =   ""
         EndProperty
         BeginProperty ListImage4 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":1156
            Key             =   ""
         EndProperty
         BeginProperty ListImage5 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "frmMain.frx":15AA
            Key             =   ""
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.TreeView treMain 
      Height          =   5085
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   8865
      _ExtentX        =   15637
      _ExtentY        =   8969
      _Version        =   393217
      Indentation     =   18
      LineStyle       =   1
      Style           =   7
      ImageList       =   "imgSmall"
      BorderStyle     =   1
      Appearance      =   1
   End
   Begin VB.Menu mnuPopup 
      Caption         =   "PopUp"
      Begin VB.Menu mnuPopUpInsert 
         Caption         =   "&Insert"
      End
      Begin VB.Menu mnuPopUpDelete 
         Caption         =   "&Delete"
      End
      Begin VB.Menu mnuPopupBreak 
         Caption         =   "-"
      End
      Begin VB.Menu mnuPopupAbout 
         Caption         =   "&About"
      End
      Begin VB.Menu mnuPopupReadme 
         Caption         =   "&ReadMe"
      End
      Begin VB.Menu mnuPopupBreak1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuPopupExit 
         Caption         =   "E&xit"
      End
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub cmdBrowse_Click()
' Open a Common Dialog box and look for only ini files
OpenFile Me, "INI Files(*.ini) | *.ini"
If NoOpen = False Then
    GetIniInfo CurrentFileName
End If
End Sub

Private Sub cmdSave_Click()
' Error Handler
On Error GoTo TreeErr
' If there is no file loaded raise the error number to exit the sub
If CurrentFileName = "" Then Err.Raise 75
' Warn user that any additional text in file will be lost
' This editor can only deal with Sections/Keys/Values
Dim ansStr As String
ansStr = MsgBox("Any comments or items not associated with the current file will be lost. Are you sure you want to make these changes?" _
, vbYesNo + vbCritical, "Warning")
Select Case ansStr
    Case vbYes
        Dim intNew As Long
        ' Open the ini file
            Open CurrentFileName For Output As #1
                ' Cycle through all the nodes
                For intNew = 1 To treMain.Nodes.Count
                    ' Check the tag of each node to see what kind of data we have
                    If treMain.Nodes(intNew).Tag = "Section" Then
                        If intNew = 2 Then ' First line, can't have a blank one
                            Print #1, "[" & treMain.Nodes(intNew) & "]"
                        Else
                            Print #1, vbCrLf & "[" & treMain.Nodes(intNew) & "]"
                        End If
                    ElseIf treMain.Nodes(intNew).Tag = "Key" Then
                        If treMain.Nodes(intNew + 1).Tag = "Value" Then
                            Print #1, treMain.Nodes(intNew) & "=" & treMain.Nodes(intNew + 1)
                        Else
                            Print #1, treMain.Nodes(intNew) & "-"
                        End If
                    End If
                Next intNew
            Close #1
            MsgBox "Save Complete", vbOKOnly, "IniViewer & Editor"
    Case vbNo
        MsgBox "Save Aborted", vbOKOnly, "IniViewer & Editor"
End Select
Exit Sub
TreeErr:
    If Err.Number = 75 Then ' File Path access error
        MsgBox "No file opened.", vbOKOnly + vbCritical, "File Not Found"
        Exit Sub
    Else
        MsgBox "An error occurred - " & Err.Description & Chr(10) _
        & "Program terminating", vbOKOnly + vbCritical, "Fatal Error"
        Unload Me
        End
    End If
End Sub

Private Sub Form_Load()
' Get the name of the app and put it in the Caption
strAppName = App.EXEName & " - v" & App.Major & "." & App.Minor & "." & App.Revision
Me.Caption = strAppName
mnuPopup.Visible = False
End Sub

Private Sub Form_Resize()
' Resize the objects relative to the form size
If Me.WindowState = 1 Then Exit Sub
treMain.Height = frmMain.Height - 915
treMain.Width = frmMain.Width - 120
cmdBrowse.Top = treMain.Height + 20
cmdSave.Top = treMain.Height + 20
End Sub

Private Sub Form_Unload(Cancel As Integer)
' Give resources back to user
Set frmMain = Nothing
Set nodRoot = Nothing
Set nodSec = Nothing
Set nodKey = Nothing
Set nodValue = Nothing
Set nodCurrentProj = Nothing
End
End Sub

Private Sub mnuPopupAbout_Click()
MsgBox strAppName & " By: Michael Heath" _
& Chr(10) & "Last Build Date: 18 Oct 2000" & Chr(10) & Chr(10) & _
"Description: " & App.FileDescription & Chr(10) & _
"Email: " & "mheath@indy.net", vbOKOnly + vbInformation, "About IniEditor"
End Sub

Private Sub mnuPopUpDelete_Click()
DeleteNode
End Sub

Private Sub mnuPopupExit_Click()
Unload Me
End Sub

Private Sub mnuPopUpInsert_Click()
InsertNode
End Sub

Private Sub mnuPopupReadme_Click()
MsgBox PutFileInString(App.Path & "\readme.txt")
End Sub

Private Sub treMain_Click()
' If a Section Node is expanded, then we want to change the image
' I only know how to do this when the item is selected.

On Error GoTo ldErr
If treMain.SelectedItem.Tag = "Section" Then
    If treMain.SelectedItem.Expanded = True Then
        treMain.SelectedItem.Image = 3
    Else
        treMain.SelectedItem.Image = 4
    End If
End If
ldErr:
    Exit Sub
End Sub

Private Sub treMain_DblClick()
' If a Section Node is expanded, then we want to change the image
' I only know how to do this when the item is selected.
On Error GoTo ldErr
If treMain.SelectedItem.Tag = "Section" Then
    If treMain.SelectedItem.Expanded = True Then
        treMain.SelectedItem.Image = 3
    Else
        treMain.SelectedItem.Image = 4
    End If
End If
ldErr:
    Exit Sub
End Sub

Private Sub treMain_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)
If Button = 2 Then
    PopupMenu mnuPopup
End If
End Sub
