unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Interfaces,
  Clipbrd, ExtCtrls, Buttons,IniFiles;


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

  public

  end;

var
  MainForm: TMainForm;
  ClipboardText: string;
  PreviousClipboardText: string;
  FileName: string;
  FileText: string;
  ClipboardFile: TextFile;


implementation

{$R *.lfm}

{ TMainForm }


procedure WriteSettingsToIni(const FileName: string; TimerEnabled: Boolean);
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  try
    IniFile.WriteString('Settings', 'FileName', FileName);
    IniFile.WriteBool('Settings', 'TimerEnabled', TimerEnabled);
  finally
    IniFile.Free;
  end;
end;


procedure LoadSettingsFromIni();
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
  MainForm.label1.Caption := FileName;
  MainForm.ToggleBox1.Checked :=  TimerEnabled;
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  Savedialog1.Execute;
  label1.Caption:=Savedialog1.FileName;
  WriteSettingsToIni(label1.Caption, Timer1.Enabled)
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin


     PreviousClipboardText := Clipboard.AsText;
     label1.caption := '';
     LoadSettingsFromIni();
     ToggleBox1.OnChange(Sender);
     if Clipboard.AsText <> '' then
     begin
          ClipboardText := Clipboard.AsText;
          PreviousClipboardText := ClipboardText;
          edit1.text := ClipboardText;
     end;
end;


function GetFileText(filename:string): string;
var
  FileContents: TStringList;
  FileText:string;
begin
     FileContents := TStringList.Create;
     try
        FileContents.LoadFromFile(filename);
        FileText := FileContents.Text;
        // Костыльно пытаюсь удалить последний символ если это перевод строки
        if Length(FileText) > 0 then
        begin
          if FileText[Length(FileText)] = #10 then
          Delete(FileText, Length(FileText), 1);
        end;
     finally
        FileContents.Free;
     end;
     GetFileText := FileText;
end;


procedure WriteFileText(filename,text2write:string);
var
   ClipboardFile: TextFile;
begin
   AssignFile(ClipboardFile, filename);
   Rewrite(ClipboardFile);
   Write(ClipboardFile,text2write);
   CloseFile(ClipboardFile);
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
var
   clipcontent,filecontent:string;

begin
   // REFACTORED
   // Получаем значение файла и буфера
   clipcontent := Clipboard.AsText;
   filecontent := GetFileText(label1.caption);
   // Если они оба пустые то ничего не делаем
   if (clipcontent <> '') and (filecontent <> '') then
   begin
     // Проверяем изменился ли буфер обмена
     if (clipcontent <> PreviousClipboardText) and (label1.caption <> '') then
     begin
          try
             WriteFileText(label1.caption,clipcontent);
          finally
             PreviousClipboardText :=  clipcontent;
          end;
     end;
     // Проверяем файл
     if filecontent <>  clipcontent then
     begin
          Clipboard.AsText := filecontent;
          clipcontent := filecontent;
          PreviousClipboardText :=  clipcontent;
     end;

   end;
   edit1.text := clipcontent;


   // Если в буфере пусто и вайле пусто то не дела

  // Мониторинг содержимого буфера обмена
  // Если в буфере текст то записываем его в переменную.
  //if Clipboard.AsText <> '' then  ClipboardText := Clipboard.AsText;
  //// Если текст в буфере изменился
  //if ClipboardText <> PreviousClipboardText then
  //   begin
  //     // Выводим его содержимео в эдит-текст
  //     edit1.text := ClipboardText;
  //     // Сохраняем в переменную PreviousClipboardText
  //     PreviousClipboardText := ClipboardText;
  //     // Если имя файла не пустое то пробуем записать в этот файл
  //     //if label1.Caption <> '' then
  //        //begin
  //
  //        //end;
  //     end;
  //// Мониторинг содержимого файла
  ////if label1.Caption <> '' then
  //   //begin
  //    FileText := GetFileText(label1.caption);
  //
  //    // Если буфер и файл не совпадают записать файл в буфер
  //    if (FileText <> Clipboard.AsText) then
  //    begin
  //         Clipboard.AsText := FileText;
  //         edit1.text := FileText;
  //    end;
  //  //end;

end;

procedure TMainForm.ToggleBox1Change(Sender: TObject);
begin
       if ToggleBox1.Checked then
          begin
            ToggleBox1.Caption := 'Sync ENABLED';
            Timer1.Enabled:= True;

          end
       else
           begin
             ToggleBox1.Caption := 'Sync DISABLED';
             Timer1.Enabled:= False;
           end;
       WriteSettingsToIni(label1.Caption, Timer1.Enabled)

end;

end.

