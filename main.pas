unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Clipbrd,
  ExtCtrls, Buttons, IniFiles;

type
  { TMainForm }

  TMainForm = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    SaveDialog1: TSaveDialog;
    Timer1: TTimer;
    ToggleBox1: TToggleBox;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ToggleBox1Change(Sender: TObject);
  private
    ClipboardText: string;
    PreviousClipboardText: string;
    ConfigFileName: string;
    FileText: string;
    ClipboardFile: TextFile;

    procedure WriteSettingsToIni(const AFileName: string; TimerEnabled: Boolean);
    procedure LoadSettingsFromIni();
    procedure SyncClipboardToText();
    procedure SyncTextToClipboard();
    procedure UpdateUI();
  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.WriteSettingsToIni(const AFileName: string; TimerEnabled: Boolean);
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  try
    IniFile.WriteString('Settings', 'FileName', AFileName);
    IniFile.WriteBool('Settings', 'TimerEnabled', TimerEnabled);
  finally
    IniFile.Free;
  end;
end;

procedure TMainForm.LoadSettingsFromIni();
var
  IniFile: TIniFile;
  FileName: string;
  TimerEnabled: Boolean;
begin
  IniFile := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  try
    FileName := IniFile.ReadString('Settings', 'FileName', '');
    TimerEnabled := IniFile.ReadBool('Settings', 'TimerEnabled', False);
  finally
    IniFile.Free;
  end;
  Label1.Caption := FileName;
  ToggleBox1.Checked := TimerEnabled;
end;

procedure TMainForm.SyncClipboardToText();
begin
  if Clipboard.AsText <> '' then
  begin
    ClipboardText := Clipboard.AsText;
    PreviousClipboardText := ClipboardText;
    Edit1.Text := ClipboardText;
  end;
end;

procedure TMainForm.SyncTextToClipboard();
begin
  if (FileText <> Clipboard.AsText) then
  begin
    Clipboard.AsText := FileText;
    Edit1.Text := FileText;
  end;
end;

procedure TMainForm.UpdateUI();
begin
  if ToggleBox1.Checked then
    ToggleBox1.Caption := 'Sync ENABLED'
  else
    ToggleBox1.Caption := 'Sync DISABLED';

  WriteSettingsToIni(Label1.Caption, Timer1.Enabled);
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    Label1.Caption := SaveDialog1.FileName;
    UpdateUI();
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  PreviousClipboardText := Clipboard.AsText;
  Label1.Caption := '';
  LoadSettingsFromIni();
  ToggleBox1.OnChange(Sender);
  SyncClipboardToText();
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
var
  FileContents: TStringList;
begin
  SyncClipboardToText();

  if Label1.Caption <> '' then
  begin
    FileContents := TStringList.Create;
    try
      FileContents.LoadFromFile(Label1.Caption);
      FileText := FileContents.Text;

      if Length(FileText) > 0 then
      begin
        if FileText[Length(FileText)] = #10 then
          Delete(FileText, Length(FileText), 1);
      end;
    finally
      FileContents.Free;
    end;

    SyncTextToClipboard();
  end;
end;

procedure TMainForm.ToggleBox1Change(Sender: TObject);
begin
  Timer1.Enabled := ToggleBox1.Checked;
  UpdateUI();
end;

end.


