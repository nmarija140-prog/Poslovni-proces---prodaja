unit Detalji;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, Data.DB,
  Data.Win.ADODB, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Layouts,
  FMX.Objects;

type
  TForm11 = class(TForm)
    DugmePonuda: TButton;
    DugmeKreirajRezervaciju: TButton;
    ADOQuery1: TADOQuery;
    VertScrollBox1: TVertScrollBox;
    MestoIstovara: TLabel;
    VrstaRobe: TLabel;
    DatumIstovara: TLabel;
    MestoUtovara: TLabel;
    Klijent: TLabel;
    Napomena: TLabel;
    Kolicina: TLabel;
    DatumUtovara: TLabel;
    Text1: TText;
    procedure FormShow(Sender: TObject);
    procedure DugmePonudaClick(Sender: TObject);
  private
    function PonudaPostoji: Boolean;
  public
    IzabraniID: Integer;
    IzabraniStatusID: Integer;
  end;

var
  Form11: TForm11;

implementation
uses ProdajaTura, KreiranjePonude;

{$R *.fmx}

procedure TForm11.DugmePonudaClick(Sender: TObject);
begin
  // Samo prosleđujemo ID zahteva, Form12 će u svom FormShow proveriti bazu
  Form12.IDZahtevaZaPonudu := IzabraniID;

  if PonudaPostoji then
    ShowMessage('Otvara se postojeća ponuda')
  else
    ShowMessage('Kreira se nova ponuda');

  Form12.Left := Self.Left;
  Form12.Top := Self.Top;
  Form12.Width := Self.Width;
  Form12.Height := Self.Height;

  Form12.Show;
  Self.Hide;
end;

function TForm11.PonudaPostoji: Boolean;
begin
  Result := False;
  ADOQuery1.Close;
  ADOQuery1.SQL.Text := 'SELECT COUNT(*) AS C FROM Ponude WHERE ZahtevID = :ID';
  ADOQuery1.Parameters.ParamByName('ID').Value := IzabraniID;
  ADOQuery1.Open;
  Result := ADOQuery1.FieldByName('C').AsInteger > 0;
end;

procedure TForm11.FormShow(Sender: TObject);
begin
  try
    ADOQuery1.Connection := Form8.ADOConnection1;

    ADOQuery1.Close;
    ADOQuery1.SQL.Text :=
      'SELECT z.*, k.nazivKlijenta ' +
      'FROM Zahtevi z ' +
      'INNER JOIN Klijenti k ON z.KlijentID = k.IDKlijenta ' +
      'WHERE z.[ID Zahteva] = :IzabraniID';

    ADOQuery1.Parameters.ParamByName('IzabraniID').Value := IzabraniID;
    ADOQuery1.Open;

    if not ADOQuery1.Eof then
    begin
      Self.Klijent.TextSettings.WordWrap := True;
      Self.Klijent.AutoSize := True;
      Self.MestoUtovara.TextSettings.WordWrap := True;
      Self.MestoUtovara.AutoSize := True;
      Self.MestoIstovara.TextSettings.WordWrap := True;
      Self.MestoIstovara.AutoSize := True;
      Self.DatumUtovara.TextSettings.WordWrap := True;
      Self.DatumUtovara.AutoSize := True;
      Self.DatumIstovara.TextSettings.WordWrap := True;
      Self.DatumIstovara.AutoSize := True;
      Self.VrstaRobe.TextSettings.WordWrap := True;
      Self.VrstaRobe.AutoSize := True;
      Self.Kolicina.TextSettings.WordWrap := True;
      Self.Kolicina.AutoSize := True;
      Self.Napomena.TextSettings.WordWrap := True;
      Self.Napomena.AutoSize := True;

      Self.Klijent.Text       := 'Klijent: ' + ADOQuery1.FieldByName('nazivKlijenta').AsString;
      Self.MestoUtovara.Text  := 'Mesto utovara: ' + ADOQuery1.FieldByName('MestoUtovara').AsString;
      Self.MestoIstovara.Text := 'Mesto istovara: ' + ADOQuery1.FieldByName('MestoIstovara').AsString;
      Self.DatumUtovara.Text  := 'Datum utovara: ' + ADOQuery1.FieldByName('DatumUtovara').AsString;
      Self.DatumIstovara.Text := 'Datum istovara: ' + ADOQuery1.FieldByName('DatumIstovara').AsString;
      Self.VrstaRobe.Text     := 'Vrsta robe: ' + ADOQuery1.FieldByName('VrstaRobe').AsString;
      Self.Kolicina.Text      := 'Količina: ' + ADOQuery1.FieldByName('Kolicina').AsString;
      Self.Napomena.Text      := 'Napomena: ' + ADOQuery1.FieldByName('Napomena').AsString;
    end;
  except
    on E: Exception do
      ShowMessage('Greška pri učitavanju detalja: ' + E.Message);
  end;
end;

end.
