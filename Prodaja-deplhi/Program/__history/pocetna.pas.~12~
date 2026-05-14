unit pocetna;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects ;

type
  TForm1 = class(TForm)
    PrijavaBtn: TButton;
    Text1: TText;
    Image1: TImage;
    procedure PrijavaBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses UnosPodataka, disp, NoviZahtev, System.IniFiles;

procedure TForm1.PrijavaBtnClick(Sender: TObject);
begin
Form9.Left := Self.Left;
  Form9.Top := Self.Top;
  Form9.Width := Self.Width;
  Form9.Height := Self.Height;
            Form9.Show;
            Self.Hide;
end;
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var
Ini: TIniFile;
begin
  Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'settings.ini');
  try
    Ini.WriteInteger('Pozicija', 'Left', Self.Left);
    Ini.WriteInteger('Pozicija', 'Top', Self.Top);
  finally
    Ini.Free;
  end;
end;
end.
