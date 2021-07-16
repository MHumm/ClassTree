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
    ToolButton1: TToolButton;
    pc_Main: TPageControl;
    ts_Tree: TTabSheet;
    ts_TextExport: TTabSheet;
    TreeView: TTreeView;
    MemoExport: TMemo;
    ToolButton2: TToolButton;
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
  private
  public
  end;

var
  Form1: TForm1;

implementation

uses
  Rtti;

{$R *.dfm}

procedure FillTreeClasses(TreeViewClasses:TTreeView);

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

procedure TForm1.ToolButton1Click(Sender: TObject);
begin
  FillTreeClasses(TreeView);
  TreeView.FullExpand;
  TreeView.Select(TreeView.Items.GetFirstNode);
end;

procedure TForm1.ToolButton2Click(Sender: TObject);
var
  Sibling : TTreeNode;

  procedure ExportFromNode(Node: TTreeNode; Level: UInt16; HasSiblings: Boolean);
  var
    s : string;
    Child : TTreeNode;
    Sibling : TTreeNode;
    Sibling2 : TTreeNode;
    ChildSibling : TTreeNode;
  begin
    Child := nil;
    Child   := Node.getFirstChild;
    Sibling := Node.getNextSibling;

    ChildSibling := nil;
    if Assigned(Child) then
      ChildSibling := Child.getNextSibling;

    Sibling2 := nil;
    if Assigned(Sibling) then
      Sibling2 := Sibling.getNextSibling;

//    for var i := 0 to Level-1 do
//      s := s + '  ';
//
//    MemoExport.Lines.Add(s + Node.Text);

    for var i := 0 to Level-1 do
      s := s + '│ ';

    if (not Assigned(Sibling)) and (not Assigned(Sibling2)) then
    begin
      if //(not Assigned(ChildSibling)) and (not Assigned(Child)) and
         //(not HasSiblings) and
         (Pos('└', MemoExport.Lines[MemoExport.Lines.Count-1]) <> 0) then
      begin
        Delete(s, 1, 2);
        s := s + '  ';
      end;

      MemoExport.Lines.Add(s + '└─' + Node.Text);
    end
    else
      MemoExport.Lines.Add(s + '├─' + Node.Text);


    if Assigned(Child) then
      ExportFromNode(Child, Level + 1, Assigned(Sibling));

    if Assigned(Sibling) then
    begin

      ExportFromNode(Sibling, Level, Assigned(Sibling2));
    end;
  end;

  procedure CleanupExport;
  var
    s: string;
  begin
    for var Line := 0 to MemoExport.Lines.Count - 1 do
    begin
      for var i := 1 to Length(MemoExport.Lines[Line]) do
      begin
        // check whether there's a preceeding └ in that column
        if (MemoExport.Lines[Line][i] = '│') and (Line > 0) then
        begin
          if (MemoExport.Lines[Line - 1][i] = '└') or
             (MemoExport.Lines[Line - 1][i] = ' ') then
          begin
            s := MemoExport.Lines[Line];
            s[i] := ' ';
            MemoExport.Lines[Line] := s;
          end;
        end
        else
          if (MemoExport.Lines[Line][i] = ' ') and (Line > 0) and
             (MemoExport.Lines[Line - 1][i] = '│') then
          begin
            s := MemoExport.Lines[Line];
            s[i] := '│';
            MemoExport.Lines[Line] := s;
          end;
      end;
    end;
  end;

begin
  if Assigned(TreeView.Selected) then
  begin
    MemoExport.Lines.Clear;

    Sibling := TreeView.Selected.getNextSibling;
    ExportFromNode(TreeView.Selected, 0, Assigned(Sibling));
    CleanupExport;
  end;
end;

end.
