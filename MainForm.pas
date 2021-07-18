{*****************************************************************************
  The Class tree team (see file NOTICE.txt) licenses this file
  to you under the Apache License, Version 2.0 (the
  "License"); you may not use this file except in compliance
  with the License. A copy of this licence is found in the root directory of
  this project in the file LICENCE.txt or alternatively at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an
  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  KIND, either express or implied.  See the License for the
  specific language governing permissions and limitations
  under the License.
*****************************************************************************}

unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ToolWin, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    tb_Generate: TToolButton;
    pc_Main: TPageControl;
    ts_Tree: TTabSheet;
    ts_TextExport: TTabSheet;
    TreeView: TTreeView;
    MemoExport: TMemo;
    tb_Export: TToolButton;
    tb_CopyToClipboard: TToolButton;
    procedure tb_GenerateClick(Sender: TObject);
    procedure tb_ExportClick(Sender: TObject);
    procedure tb_CopyToClipboardClick(Sender: TObject);
  private
    procedure FillTreeClasses(TreeViewClasses:TTreeView);
    procedure ExportFromNode(Node: TTreeNode; Level: UInt16; OutputList: TStringList);
    procedure CleanupExport(OutputList: TStringList);
  public
  end;

var
  Form1: TForm1;

implementation

uses
  Rtti;

{$R *.dfm}

procedure TForm1.FillTreeClasses(TreeViewClasses:TTreeView);

  //function to get the node wich match with the TRttiType
  function FindTRttiType(lType:TRttiType):TTreeNode;
  var
    i        : integer;
    Node     : TTreeNode;
  begin
     Result:=nil;
       for i:=0 to TreeViewClasses.Items.Count-1 do
       begin
          Node:=TreeViewClasses.Items.Item[i];
          if Assigned(Node.Data) then
           if lType=TRttiType(Node.Data) then
           begin
            Result:=Node;
            exit;
           end;
       end;
  end;

  //function to get the node wich not match with the BaseType of the Parent
  function FindFirstTRttiTypeOrphan:TTreeNode;
  var
    i        : integer;
    Node     : TTreeNode;
    lType    : TRttiType;
  begin
     Result:=nil;
       for i:=0 to TreeViewClasses.Items.Count-1 do
       begin
           Node :=TreeViewClasses.Items[i];
           lType:=TRttiType(Node.Data);

          if not Assigned(lType.BaseType) then Continue;

          if lType.BaseType<>TRttiType(Node.Parent.Data) then
          begin
             Result:=Node;
             break;
           end;
       end;
  end;

var
  ctx      : TRttiContext;
  TypeList : TArray<TRttiType>;
  lType    : TRttiType;
  PNode    : TTreeNode;
  Node     : TTreeNode;
begin
  ctx := TRttiContext.Create;
  TreeViewClasses.Items.BeginUpdate;
  try
    TreeViewClasses.Items.Clear;

      //Add Root, TObject
      lType:=ctx.GetType(TObject);
      Node:=TreeViewClasses.Items.AddObject(nil,lType.Name,lType);

      //Fill the tree with all the classes
      TypeList:= ctx.GetTypes;
      for lType in TypeList do
        if lType.IsInstance then
        begin
          if Assigned(lType.BaseType) then
          TreeViewClasses.Items.AddChildObject(Node,lType.Name,lType);
        end;

      //Sort the classes
      Repeat
         Node:=FindFirstTRttiTypeOrphan;
         if Node=nil then break;
         //get the location of the node containing the BaseType
         PNode:=FindTRttiType(TRttiType(Node.Data).BaseType);
         //Move the node to the new location
         Node.MoveTo(PNode,naAddChild);
      Until 1<>1;

  finally
    TreeViewClasses.Items.EndUpdate;
    ctx.Free;
  end;
end;

procedure TForm1.tb_GenerateClick(Sender: TObject);
begin
  FillTreeClasses(TreeView);
  TreeView.FullExpand;
  TreeView.Select(TreeView.Items.GetFirstNode);
end;

procedure TForm1.tb_CopyToClipboardClick(Sender: TObject);
begin
  MemoExport.SelectAll;
  MemoExport.CopyToClipboard;
  MemoExport.ClearSelection;
end;

procedure TForm1.tb_ExportClick(Sender: TObject);
var
  sl : TStringList;
begin
  if Assigned(TreeView.Selected) then
  begin
    sl := TStringList.Create;
    try
      MemoExport.Lines.Clear;
      ExportFromNode(TreeView.Selected, 0, sl);
      CleanupExport(sl);
      MemoExport.Lines.BeginUpdate;
      MemoExport.Lines.Assign(sl);
    finally
      MemoExport.Lines.EndUpdate;
      sl.Free;
    end;
  end;
end;

procedure TForm1.ExportFromNode(Node: TTreeNode; Level: UInt16; OutputList: TStringList);
var
  s        : string;
  Child    : TTreeNode;
  Sibling  : TTreeNode;
  Sibling2 : TTreeNode;
begin
  Child   := Node.getFirstChild;
  Sibling := Node.getNextSibling;

  Sibling2 := nil;
  if Assigned(Sibling) then
    Sibling2 := Sibling.getNextSibling;

  for var i := 0 to Level-1 do
    s := s + '│ ';

  if (not Assigned(Sibling)) and (not Assigned(Sibling2)) then
  begin
    if (OutputList.Count > 0) and (Pos('└', OutputList[OutputList.Count-1]) <> 0) then
    begin
      Delete(s, 1, 2);
      s := s + '  ';
    end;

    OutputList.Add(s + '└─' + Node.Text);
  end
  else
    OutputList.Add(s + '├─' + Node.Text);

  if Assigned(Child) then
    ExportFromNode(Child, Level + 1, OutputList);

  if Assigned(Sibling) then
    ExportFromNode(Sibling, Level, OutputList);
end;

procedure TForm1.CleanupExport(OutputList: TStringList);
var
  s: string;
begin
  for var Line := 0 to OutputList.Count - 1 do
  begin
    for var i := 1 to Length(OutputList[Line]) do
    begin
      // check whether there's a preceeding └ in that column
      if (OutputList[Line][i] = '│') and (Line > 0) then
      begin
        if (OutputList[Line - 1][i] = '└') or
           (OutputList[Line - 1][i] = ' ') then
        begin
          s := OutputList[Line];
          s[i] := ' ';
          OutputList[Line] := s;
        end;
      end
      else
        if (OutputList[Line][i] = ' ') and (Line > 0) and
           (OutputList[Line - 1][i] = '│') then
        begin
          s := OutputList[Line];
          s[i] := '│';
          OutputList[Line] := s;
        end;
    end;
  end;
end;

end.
