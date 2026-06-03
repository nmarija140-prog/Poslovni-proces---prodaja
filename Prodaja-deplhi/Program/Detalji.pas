unit Detalji;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, Data.DB,
  Data.Win.ADODB, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Layouts,
  FMX.Objects;

type
  TFormDetalji = class(TForm)
    DugmePonuda: TButton;
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
    RezervacijaDugme: TButton;
    procedure FormShow(Sender: TObject);
    procedure DugmePonudaClick(Sender: TObject);
    procedure RezervacijaDugmeClick(Sender: TObject);
  private
    function PonudaPostoji: Boolean;
     function RezervacijaPostoji: Boolean;
  public
    IzabraniID: Integer;
    IzabraniStatusID: Integer;
  end;

var
  FormDetalji: TFormDetalji;

implementation
uses ProdajaTura, KreiranjePonude, KreiranjeRezervacije;

{$R *.fmx}

procedure TFormDetalji.DugmePonudaClick(Sender: TObject);
begin

 if not Assigned(Form13) then
    Application.CreateForm(TForm13, Form13);


  Form13.IDZahtevaZaPonudu := IzabraniID;

  if PonudaPostoji then
    ShowMessage('Otvara se postojeća ponuda')
  else
    ShowMessage('Kreira se nova ponuda');

  Form13.Left := Self.Left;
  Form13.Top := Self.Top;
  Form13.Width := Self.Width;
  Form13.Height := Self.Height;

  Form13.Show;
  Self.Hide;
end;

function TFormDetalji.PonudaPostoji: Boolean;
begin
  Result := False;
  ADOQuery1.Close;
  ADOQuery1.SQL.Text := 'SELECT COUNT(*) AS C FROM Ponude WHERE ZahtevID = :ID';
  ADOQuery1.Parameters.ParamByName('ID').Value := IzabraniID;
  ADOQuery1.Open;
  Result := ADOQuery1.FieldByName('C').AsInteger > 0;
end;
function TFormDetalji.RezervacijaPostoji: Boolean;
begin
  Result := False;
  ADOQuery1.Close;
  ADOQuery1.SQL.Text := 'SELECT COUNT(*) AS C FROM Rezervacije WHERE ZahtevID = :ID';
  ADOQuery1.Parameters.ParamByName('ID').Value := IzabraniID;
  ADOQuery1.Open;

  Result := ADOQuery1.FieldByName('C').AsInteger > 0;
end;

procedure TFormDetalji.RezervacijaDugmeClick(Sender: TObject);
begin
 if not Assigned(Form12) then
    Application.CreateForm(TForm12, Form12);


  Form12.IDZahtevaZaPonudu := IzabraniID;

  if RezervacijaPostoji then
    ShowMessage('Otvara se postojeća rezervacija')
  else
    ShowMessage('Kreira se nova rezervacija');

  Form12.Left := Self.Left;
  Form12.Top := Self.Top;
  Form12.Width := Self.Width;
  Form12.Height := Self.Height;

  Form12.Show;
  Self.Hide;
end;

procedure TFormDetalji.FormShow(Sender: TObject);
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

    if not ADOQuery1.IsEmpty then
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

      // DODATI OSIGURAČI: Ako je polje NULL u bazi, ispisujemo bezbedan tekst

      if ADOQuery1.FieldByName('nazivKlijenta').IsNull then
        Self.Klijent.Text := 'Klijent: Nepoznato'
      else
        Self.Klijent.Text := 'Klijent: ' + ADOQuery1.FieldByName('nazivKlijenta').AsString;

      if ADOQuery1.FieldByName('MestoUtovara').IsNull then
        Self.MestoUtovara.Text := 'Mesto utovara: /'
      else
        Self.MestoUtovara.Text := 'Mesto utovara: ' + ADOQuery1.FieldByName('MestoUtovara').AsString;

      if ADOQuery1.FieldByName('MestoIstovara').IsNull then
        Self.MestoIstovara.Text := 'Mesto istovara: /'
      else
        Self.MestoIstovara.Text := 'Mesto istovara: ' + ADOQuery1.FieldByName('MestoIstovara').AsString;

      if ADOQuery1.FieldByName('DatumUtovara').IsNull then
        Self.DatumUtovara.Text := 'Datum utovara: /'
      else
        Self.DatumUtovara.Text := 'Datum utovara: ' + ADOQuery1.FieldByName('DatumUtovara').AsString;

      if ADOQuery1.FieldByName('DatumIstovara').IsNull then
        Self.DatumIstovara.Text := 'Datum istovara: /'
      else
        Self.DatumIstovara.Text := 'Datum istovara: ' + ADOQuery1.FieldByName('DatumIstovara').AsString;

      if ADOQuery1.FieldByName('VrstaRobe').IsNull then
        Self.VrstaRobe.Text := 'Vrsta robe: /'
      else
        Self.VrstaRobe.Text := 'Vrsta robe: ' + ADOQuery1.FieldByName('VrstaRobe').AsString;

      if ADOQuery1.FieldByName('Kolicina').IsNull then
        Self.Kolicina.Text := 'Količina: /'
      else
        Self.Kolicina.Text := 'Količina: ' + ADOQuery1.FieldByName('Kolicina').AsString;

      if ADOQuery1.FieldByName('Napomena').IsNull then
        Self.Napomena.Text := 'Napomena: bez napomene'
      else
        Self.Napomena.Text := 'Napomena: ' + ADOQuery1.FieldByName('Napomena').AsString;
    end
    else
    begin
      ShowMessage('Greška: Zahtev pod ID-jem ' + IntToStr(IzabraniID) + ' ne postoji u bazi!');
    end;
  except
    on E: Exception do
      ShowMessage('Greška pri učitavanju detalja: ' + E.Message);
  end;
end;

end.
