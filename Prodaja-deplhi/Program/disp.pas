unit disp;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, UnosPodataka, FMX.Objects, FMX.Maps, ProdajaTura, PozicijaForme
  , System.IniFiles;

type
  TForm5 = class(TForm)
    MapView1: TMapView;
    Text1: TText;
    Text2: TText;
    Text3: TText;
    Text4: TText;
    Text5: TText;
    txtSlobodnaVozila: TText;
    txtVozilaUVoznji: TText;
    txtVozilaNaUtovaru: TText;
    txtVozilaSaProblemima: TText;
    hambDugme: TSpeedButton;
    hambPanel: TPanel;
    operativaDugme: TButton;
    ProdajaTuraDugme: TButton;
    ChatDugme: TButton;
    IzvestajiDugme: TButton;
    MojProfilDugme: TButton;
    OdjavaDugme: TButton;
    procedure hambDugmeClick(Sender: TObject);
    procedure ProdajaTuraDugmeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form5: TForm5;

implementation

{$R *.fmx}

procedure TForm5.FormCreate(Sender: TObject);
begin
 Position := TFormPosition.Designed;

  if LastFormX <> -1 then
  begin
    Left := Round(LastFormX);
    Top := Round(LastFormY);
  end;
end;

procedure TForm5.hambDugmeClick(Sender: TObject);
begin
hambPanel.Visible := not hambPanel.Visible;
hambDugme.BringToFront;
end;

procedure TForm5.ProdajaTuraDugmeClick(Sender: TObject);
begin
  Form8.Left := Self.Left;
  Form8.Top := Self.Top;

  Form8.Width := Self.Width;
  Form8.Height := Self.Height;

  Form8.Show;
  Self.Hide;
end;
procedure TForm5.FormClose(Sender: TObject; var Action: TCloseAction);
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
