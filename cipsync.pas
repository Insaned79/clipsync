program ClipboardSync;

{$mode objfpc}{$H+}

// uses
//   Classes, SysUtils;


{$IFDEF MSWINDOWS}
uses
  Classes, SysUtils,ClipBrd;
{$ENDIF}

{$IFDEF UNIX}
uses
  Classes, SysUtils,Interfaces, Clipbrd;
{$ENDIF}


const
  SYNC_INTERVAL = 1000; // Интервал проверки изменений (в миллисекундах)

var
  ClipboardText: string;
  PreviousClipboardText: string;
  FileName: string;


procedure UpdateClipboard;
begin
  {$IFDEF MSWINDOWS}
  Clipboard.AsText := ClipboardText;
  {$ENDIF}
  
  {$IFDEF UNIX}
  SetClipboard(ClipboardText);
  {$ENDIF}
end;

procedure UpdateClipboardText;
begin
  {$IFDEF MSWINDOWS}
  ClipboardText := Clipboard.AsText;
  {$ENDIF}
  
  {$IFDEF UNIX}
  ClipboardText := GetClipboard;
  {$ENDIF}
end;

procedure ReadClipboardFile;
var
  FileContents: TStringList;
begin
  FileContents := TStringList.Create;
  try
    FileContents.LoadFromFile(FileName);
    ClipboardText := FileContents.Text;
  finally
    FileContents.Free;
  end;
end;

procedure WriteClipboardFile;
begin
  with TStringList.Create do
  begin
    Text := ClipboardText;
    SaveToFile(FileName);
    Free;
  end;
end;

function ClipboardChanged: Boolean;
begin
  Result := ClipboardText <> PreviousClipboardText;
end;

procedure SyncClipboard;
begin
  if ClipboardChanged then
  begin
    UpdateClipboard;
    WriteClipboardFile;
  end
  else
  begin
    ReadClipboardFile;
    if ClipboardChanged then
      UpdateClipboardText;
  end;
  PreviousClipboardText := ClipboardText;
end;

begin
  if ParamCount = 1 then
    FileName := ParamStr(1)
  else
  begin
    Writeln('Usage: ClipboardSync <filename>');
    Exit;
  end;

  PreviousClipboardText := Clipboard.AsText;
  while True do
  begin
    SyncClipboard;
    Sleep(SYNC_INTERVAL);
  end;
end.
