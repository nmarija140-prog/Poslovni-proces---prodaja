unit Klijent;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, UnosPodataka, FMX.Objects, PozicijaForme;

type
  TForm6 = class(TForm)
    SpeedButton1: TSpeedButton;
    Image1: TImage;
    Text1: TText;
    txtImeKorisnika: TText;
    txtNazivFirme: TText;
    txtPIB: TText;
    txtAdresa: TText;
    btnOtvoriNalog: TButton;
    btnUrediProfil: TButton;
    txtEmail: TText;
    txtBrojTelefona: TText;
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form6: TForm6;

implementation

{$R *.fmx}

procedure TForm6.FormCreate(Sender: TObject);
begin
 Position := TFormPosition.Designed;

  if LastFormX <> -1 then
  begin
    Left := Round(LastFormX);
    Top := Round(LastFormY);
  end;
end;

procedure TForm6.SpeedButton1Click(Sender: TObject);
begin
Form2.Show;
Close;
end;
                              procedure TForm6.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LastFormX := Left;
  LastFormY := Top;
end;
end.
