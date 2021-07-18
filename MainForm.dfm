object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Class tree generator'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  PixelsPerInch = 96
  TextHeight = 15
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 624
    Height = 29
    ButtonHeight = 21
    ButtonWidth = 122
    Caption = 'ToolBar1'
    List = True
    AllowTextButtons = True
    TabOrder = 0
    object tb_Generate: TToolButton
      Left = 0
      Top = 0
      Caption = '&Generate'
      ImageIndex = 0
      Style = tbsTextButton
      OnClick = tb_GenerateClick
    end
    object tb_Export: TToolButton
      Left = 63
      Top = 0
      Caption = '&Export selected node'
      ImageIndex = 1
      Style = tbsTextButton
      OnClick = tb_ExportClick
    end
    object tb_CopyToClipboard: TToolButton
      Left = 189
      Top = 0
      Caption = '&Copy to clipboard'
      ImageIndex = 2
      Style = tbsTextButton
      OnClick = tb_CopyToClipboardClick
    end
  end
  object pc_Main: TPageControl
    Left = 0
    Top = 29
    Width = 624
    Height = 412
    ActivePage = ts_Tree
    Align = alClient
    TabOrder = 1
    object ts_Tree: TTabSheet
      Caption = '&Complete tree'
      object TreeView: TTreeView
        Left = 0
        Top = 0
        Width = 616
        Height = 382
        Align = alClient
        Indent = 19
        TabOrder = 0
      end
    end
    object ts_TextExport: TTabSheet
      Caption = '&Text export'
      ImageIndex = 1
      object MemoExport: TMemo
        Left = 0
        Top = 0
        Width = 616
        Height = 382
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
  end
end
