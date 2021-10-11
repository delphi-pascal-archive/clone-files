unit main;

interface

uses
  Windows, Messages,Classes, SysUtils, Variants, Graphics, Controls, Forms,
  Dialogs, StdCtrls,ShellAPI, ActnList, ActnMan, ToolWin,
  ActnCtrls, ActnMenus, ImgList, ComCtrls, Menus, ExtCtrls, Clipbrd, Mask,
  ToolEdit, DualList, XPStyleActnCtrls,ShlObj;

type
  TForm1 = class(TForm)
    img1: TImageList;
    StatusBar1: TStatusBar;
    ActionToolBar1: TActionToolBar;
    ActionManager1: TActionManager;
    Action1: TAction;
    Action2: TAction;
    Panel1: TPanel;
    Label2: TLabel;
    ListBox1: TListBox;
    Action3: TAction;
    Action4: TAction;
    Panel2: TPanel;
    lb: TListBox;
    actSave: TAction;
    Action5: TAction;
    Action6: TAction;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    Panel3: TPanel;
    Button1: TButton;
    Panel4: TPanel;
    Label3: TLabel;
    PopupMenu2: TPopupMenu;
    N3: TMenuItem;
    N4: TMenuItem;
    Action7: TAction;
    PopupMenu3: TPopupMenu;
    MenuItem1: TMenuItem;
    ListBox2: TListBox;
    Splitter1: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure N651Click(Sender: TObject);
    procedure Action1Execute(Sender: TObject);
    procedure Action2Execute(Sender: TObject);
    procedure Action3Execute(Sender: TObject);
    procedure Action4Execute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure Action5Execute(Sender: TObject);
    procedure Action6Execute(Sender: TObject);
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure N3Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure Action7Execute(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure lbKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
   procedure WMDropFiles(var M: TMessage); message WM_DROPFILES;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

Var
CountFiles  : integer;
SizeName    : integer;
cch         : integer;

Var
hDrop : integer;
Point : TPoint;
lpszFile : PChar;

{$R *.dfm}
//------------------------------------------------------------
procedure TForm1.WMDropFiles(var M: TMessage);
Var
i: integer;
begin

hDrop := M.WParam;
DragQueryPoint(hDrop,Point);
CountFiles := DragQueryFile(hDrop, $FFFFFFFF, nil, cch);
for i:=0 to CountFiles-1 do
begin
SizeName   :=  DragQueryFile(hDrop, i, nil, cch);
GetMem(lpszFile,SizeName+1);
DragQueryFile(hDrop, i, lpszFile, SizeName+1);
lb.Items.Add(lpszFile);
FreeMem(lpszFile,SizeName+1);
end;
DragFinish(hDrop);
end;
//------------------------------------------------------------
procedure TForm1.FormCreate(Sender: TObject);
begin
 DragAcceptFiles(Handle,True);
 Action7Execute(Sender);
end;
//------------------------------------------------------------
procedure TForm1.Button1Click(Sender: TObject);
begin
 lb.Items.Clear;
 N3Click(Sender);
end;
//------------------------------------------------------------
procedure TForm1.N651Click(Sender: TObject);
begin
//
end;
//------------------------------------------------------------------------------
procedure TForm1.Action1Execute(Sender: TObject);
var
  TitleName : string;
  lpItemID : PItemIDList;
  BrowseInfo : TBrowseInfo;
  DisplayName : array[0..MAX_PATH] of char;
  TempPath : array[0..MAX_PATH] of char;
begin
  FillChar(BrowseInfo, sizeof(TBrowseInfo), #0);
  BrowseInfo.hwndOwner := Form1.Handle;
  BrowseInfo.pszDisplayName := @DisplayName;
  TitleName := 'Please specify a directory';
  BrowseInfo.lpszTitle := PChar(TitleName);
  BrowseInfo.ulFlags := BIF_RETURNONLYFSDIRS;
  lpItemID := SHBrowseForFolder(BrowseInfo);
  if lpItemId <> nil then
  begin
    SHGetPathFromIDList(lpItemID, TempPath);
    ListBox1.Items.Add(TempPath);
    //ShowMessage(TempPath);
    GlobalFreePtr(lpItemID);
  end;
end;
//------------------------------------------------------------------------------
procedure TForm1.Action2Execute(Sender: TObject);
 var k:integer;
begin

 with ListBox1 do begin
  k:=ItemIndex;
  Items.Delete(k);
  ItemIndex := k;
 end;

end;
//------------------------------------------------------------------------------
procedure TForm1.Action3Execute(Sender: TObject);
var
  f: THandle; 
  buffer: array [0..MAX_PATH] of Char;
  i, numFiles: Integer; 
begin 
  if not Clipboard.HasFormat(CF_HDROP) then Exit;
  Clipboard.Open; 
  try 
    f := Clipboard.GetAsHandle(CF_HDROP); 
    if f <> 0 then 
    begin 
      numFiles := DragQueryFile(f, $FFFFFFFF, nil, 0);
      //lb.Clear;
      for i := 0 to numfiles - 1 do 
      begin 
        buffer[0] := #0; 
        DragQueryFile(f, i, buffer, SizeOf(buffer));
        lb.Items.Add(buffer);
      end; 
    end; 
  finally 
    Clipboard.Close; 
  end; 
end;
//------------------------------------------------------------------------------
procedure TForm1.Action4Execute(Sender: TObject);
 var k:integer;
begin
with lb do begin
  k:=ItemIndex;
  Items.Delete(k);
  ItemIndex := k;
 end;
end;
//------------------------------------------------------------------------------
procedure TForm1.actSaveExecute(Sender: TObject);
begin
 ListBox1.Items.SaveToFile('Options.txt');
end;
//------------------------------------------------------------------------------
procedure TForm1.Action5Execute(Sender: TObject);
begin
 ShellAbout(Form1.Handle,'CloneFiles',
  'написал программу Михайлов Андрей' +#13+#10+'-=СПУТНИК2 АСУТП=-',
   Application.Icon.Handle);
end;
//------------------------------------------------------------------------------
//Алгоритм копирования
Function CopyFiles(Pth,f:String) : boolean;
var PathFileNew:string;
begin
 PathFileNew:=Pth+'\'+ExtractFileName(f);

 if Copyfile(PChar(f),PChar(PathFileNew),false) then
  CopyFiles:=true
 else
  CopyFiles:=false;
end;
//------------------------------------------------------------------------------
//Копируем файлы
procedure TForm1.Action6Execute(Sender: TObject);
var a,b:Integer;
err:Boolean;
begin
err:=false;
ListBox2.Clear;
ListBox2.Visible:=false;
ListBox2.Top:= Panel3.Top+Panel3.Height;
if ListBox2.Height<99 then ListBox2.Height:=99;
Splitter1.Top:=ListBox2.Top+1;
 for a := 0 to ListBox1.Items.Count-1 do begin
  {ListBox2.Items.Add('<------------------->');
  ListBox2.Items.Add('<Добавление в '+ ListBox1.Items.Strings[a]+'>'); }
  for b := 0 to lb.Items.Count-1 do begin
   if not CopyFiles(ListBox1.Items.Strings[a],lb.Items.Strings[b]) then begin
    err:=true;
    ListBox2.Visible:=true;
    ListBox2.Items.Add('Не скопировали файл:<' +
    lb.Items.Strings[b] + '> в директорию <' + ListBox1.Items.Strings[a] + '>');

   end;
  end;
 end;

if not err then ShowMessage('Копирование файлов прошло успешно!!!');

end;
//------------------------------------------------------------------------------
procedure TForm1.ListBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if Key  = 45 then Action1Execute(Sender); //insert
if Key  = 46 then Action2Execute(Sender); //del
end;
//------------------------------------------------------------------------------
procedure TForm1.N3Click(Sender: TObject);
begin
 ListBox2.Visible:=false;
end;
//------------------------------------------------------------------------------
procedure TForm1.N4Click(Sender: TObject);
begin
 Clipboard.AsText:=ListBox2.Items.Text;
end;
//------------------------------------------------------------------------------
procedure TForm1.Action7Execute(Sender: TObject);
begin
 ListBox1.Items.LoadFromFile('Options.txt');
end;
//------------------------------------------------------------------------------
procedure TForm1.ListBox1Click(Sender: TObject);
begin
 //ShellExecute(0,'explore','C:\WINDOWS',nil,nil,SW_SHOWNORMAL);
end;
//------------------------------------------------------------------------------
procedure TForm1.lbKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if Key  = 46 then Action4Execute(Sender); //del
end;
//------------------------------------------------------------------------------
procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key=67 then Action3Execute(Sender);
end;
//------------------------------------------------------------------------------
end.
