unit KreiranjePonude;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, Data.DB,
  Data.Win.ADODB, FMX.StdCtrls, FMX.Edit, FMX.Controls.Presentation,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, System.IniFiles, FMX.ListBox,
  FMX.EditBox, FMX.SpinBox, FMX.Objects;

type
  TForm12 = class(TForm)
    LabelKlijent: TLabel;
    LabelRuta: TLabel;
    LabelDatum: TLabel;
    EditCena: TEdit;
    DugmeSacuvajPonudu: TButton;
    ADOQuery1: TADOQuery;
    MemoNapomena: TMemo;
    ComboValuta: TComboBox;
    SpinRokPlacanja: TSpinBox;
    Text1: TText;
    DugmePosaljiPonudu: TButton;
    SpeedButton1: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure MemoNapomenaExit(Sender: TObject);
    procedure MemoNapomenaEnter(Sender: TObject);
    procedure DugmeSacuvajPonuduClick(Sender: TObject);
    procedure DugmePosaljiPonuduClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    PonudaSacuvana: Boolean;
    PonudaID: Integer;
    PonudaPostoji: Boolean; // Prebačeno u private jer se kontroliše unutar ove forme
  public
    IDZahtevaZaPonudu: Integer;
  end;

var
  Form12: TForm12;

implementation
uses Detalji, ProdajaTura;

{$R *.fmx}

procedure TForm12.DugmePosaljiPonuduClick(Sender: TObject);
begin
  if not PonudaSacuvana then
  begin
    ShowMessage('Prvo sačuvajte ponudu.');
    Exit;
  end;

  ShowMessage('Ponuda poslata klijentu.');
end;

procedure TForm12.DugmeSacuvajPonuduClick(Sender: TObject);
begin
  try
    if EditCena.Text = '' then
    begin
      ShowMessage('Unesi cenu!');
      Exit;
    end;

    ADOQuery1.Close;
    ADOQuery1.SQL.Clear;

    if not PonudaPostoji then
    begin
      // NOVA PONUDA -> INSERT
      ADOQuery1.SQL.Text :=
        'INSERT INTO Ponude ' +
        '(ZahtevID, Cena, Valuta, RokPlacanja, Napomena, DatumPonude) ' +
        'VALUES (:ZahtevID, :Cena, :Valuta, :RokPlacanja, :Napomena, :DatumPonude)';

      ADOQuery1.Parameters.ParamByName('ZahtevID').Value := IDZahtevaZaPonudu;
      ADOQuery1.Parameters.ParamByName('DatumPonude').Value := Now;
    end
    else
    begin
      // POSTOJEĆA PONUDA -> UPDATE
      ADOQuery1.SQL.Text :=
        'UPDATE Ponude SET ' +
        'Cena = :Cena, ' +
        'Valuta = :Valuta, ' +
        'RokPlacanja = :RokPlacanja, ' +
        'Napomena = :Napomena ' +
        'WHERE PonudaID = :PonudaID';

      ADOQuery1.Parameters.ParamByName('PonudaID').Value := PonudaID;
    end;

    ADOQuery1.Parameters.ParamByName('Cena').Value := StrToFloat(EditCena.Text);
    ADOQuery1.Parameters.ParamByName('Valuta').Value := ComboValuta.Items[ComboValuta.ItemIndex];
    ADOQuery1.Parameters.ParamByName('RokPlacanja').Value := Round(SpinRokPlacanja.Value);
    ADOQuery1.Parameters.ParamByName('Napomena').Value := MemoNapomena.Text;

    ADOQuery1.ExecSQL;

    // Ako je bio INSERT, nakon izvršenja ponuda sada postoji u bazi
    if not PonudaPostoji then
    begin
      PonudaPostoji := True;
      // Opciono: Ovde bi bilo dobro izvući novonastali PonudaID iz baze (Scope_Identity)
      // ali pošto radimo osvežavanje kroz FormShow, u bazi je bezbedno.
    end;

    PonudaSacuvana := True;
    DugmePosaljiPonudu.Enabled := True;

    ShowMessage('Ponuda uspešno sačuvana.');

  except
    on E: Exception do
      ShowMessage('Greška pri čuvanju: ' + E.Message);
  end;
end;

procedure TForm12.FormShow(Sender: TObject);
begin
  // Inicijalizacija stanja forme na "čisto"
  PonudaID := 0;
  PonudaPostoji := False;
  PonudaSacuvana := False;
  DugmePosaljiPonudu.Enabled := False;

  ComboValuta.Items.Clear;
  ComboValuta.Items.Add('EUR');
  ComboValuta.Items.Add('USD');
  ComboValuta.Items.Add('RSD');
  ComboValuta.ItemIndex := 0;

  EditCena.Text := '';
  SpinRokPlacanja.Value := 15;
  MemoNapomena.Text := '';

  try
    ADOQuery1.Connection := Form8.ADOConnection1;

    // 1. Učitavanje osnovnih detalja zahteva
    ADOQuery1.Close;
    ADOQuery1.SQL.Text :=
      'SELECT z.MestoUtovara, z.MestoIstovara, z.DatumUtovara, k.nazivKlijenta ' +
      'FROM Zahtevi z ' +
      'INNER JOIN Klijenti k ON z.KlijentID = k.IDKlijenta ' +
      'WHERE z.[ID zahteva] = :IDzahteva';

    ADOQuery1.Parameters.ParamByName('IDzahteva').Value := IDZahtevaZaPonudu;
    ADOQuery1.Open;

    if not ADOQuery1.Eof then
    begin
      LabelKlijent.Text := 'Klijent: ' + ADOQuery1.FieldByName('nazivKlijenta').AsString;
      LabelRuta.Text := 'Ruta: ' + ADOQuery1.FieldByName('MestoUtovara').AsString +
                        ' -> ' + ADOQuery1.FieldByName('MestoIstovara').AsString;
      LabelDatum.Text := 'Datum utovara: ' + ADOQuery1.FieldByName('DatumUtovara').AsString;
    end;

    // 2. Provera da li ponuda već postoji za ovaj ZahtevID
    ADOQuery1.Close;
    ADOQuery1.SQL.Text :=
      'SELECT PonudaID, Cena, Valuta, RokPlacanja, Napomena ' +
      'FROM Ponude WHERE ZahtevID = :ID';

    ADOQuery1.Parameters.ParamByName('ID').Value := IDZahtevaZaPonudu;
    ADOQuery1.Open;

    if not ADOQuery1.Eof then
    begin
      // Ponuda postoji -> prebacujemo formu u Edit režim i popunjavamo je
      PonudaPostoji := True;
      PonudaSacuvana := True; // KLJUČNA IZMENA: Ponuda je već u bazi, pa je smatramo sačuvanom!
      PonudaID := ADOQuery1.FieldByName('PonudaID').AsInteger;

      EditCena.Text := ADOQuery1.FieldByName('Cena').AsString;
      SpinRokPlacanja.Value := ADOQuery1.FieldByName('RokPlacanja').AsInteger;
      MemoNapomena.Text := ADOQuery1.FieldByName('Napomena').AsString;

      ComboValuta.ItemIndex := ComboValuta.Items.IndexOf(ADOQuery1.FieldByName('Valuta').AsString);
      if ComboValuta.ItemIndex = -1 then ComboValuta.ItemIndex := 0;

      DugmePosaljiPonudu.Enabled := True; // Odmah dozvoli slanje pošto podaci postoje
    end;

  except
    on E: Exception do
      ShowMessage('Greška pri otvaranju forme: ' + E.Message);
  end;
end;

procedure TForm12.MemoNapomenaEnter(Sender: TObject);
begin
  if MemoNapomena.Text = 'Napomena' then
    MemoNapomena.Text := '';
end;

procedure TForm12.MemoNapomenaExit(Sender: TObject);
begin
  if Trim(MemoNapomena.Text) = '' then
    MemoNapomena.Text := 'Napomena';
end;

procedure TForm12.SpeedButton1Click(Sender: TObject);
begin
  Form8.Show;
end;

end.
