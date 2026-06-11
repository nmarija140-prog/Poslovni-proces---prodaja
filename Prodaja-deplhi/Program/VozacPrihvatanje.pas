unit VozacPrihvatanje;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects,
  Data.DB, Data.Win.ADODB, ProdajaTura, Vozac;

type
  TForm16 = class(TForm)
    LabelKlijent: TLabel;
    LabelTura: TLabel;
    LabelDatum: TLabel;
    LabelVrstaRobe: TLabel;
    LabelKolicina: TLabel;
    Memo1: TMemo;
    DugmePrihvati: TButton;
    DugmeOdbij: TButton;
    SpeedButton1: TSpeedButton;
    ADOQuery1: TADOQuery;
    procedure FormShow(Sender: TObject);
    procedure DugmePrihvatiClick(Sender: TObject);
    procedure DugmeOdbijClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
  public
    ZahtevID: Integer;
    UlogovaniVozac: Integer;
    PraviIDVozaca: Integer;
  end;

var
  Form16: TForm16;

implementation

uses VozacPonude;

{$R *.fmx}

procedure TForm16.FormShow(Sender: TObject);
begin
  try
   ADOQuery1.Connection := Form7.ADOConnection1;
    ADOQuery1.Close;
    ADOQuery1.SQL.Text :=
      'SELECT z.MestoUtovara, z.MestoIstovara, z.DatumUtovara, ' +
      '       z.VrstaRobe, z.Kolicina, z.Napomena, k.nazivKlijenta ' +
      'FROM Zahtevi z ' +
      'INNER JOIN Klijenti k ON z.KlijentID = k.IDKlijenta ' +
      'WHERE z.[ID zahteva] = :ZahtevID';
    ADOQuery1.Parameters.ParamByName('ZahtevID').Value := ZahtevID;
    ADOQuery1.Open;

    if not ADOQuery1.IsEmpty then
    begin
      LabelKlijent.Text := 'Klijent: ' + ADOQuery1.FieldByName('nazivKlijenta').AsString;
      LabelTura.Text := 'Ruta: ' + ADOQuery1.FieldByName('MestoUtovara').AsString +
                        ' → ' + ADOQuery1.FieldByName('MestoIstovara').AsString;
      LabelDatum.Text := 'Datum utovara: ' + ADOQuery1.FieldByName('DatumUtovara').AsString;
      LabelVrstaRobe.Text := 'Vrsta robe: ' + ADOQuery1.FieldByName('VrstaRobe').AsString;
      LabelKolicina.Text := 'Količina: ' + ADOQuery1.FieldByName('Kolicina').AsString;
      Memo1.Text := ADOQuery1.FieldByName('Napomena').AsString;
      Memo1.ReadOnly := True;
    end;

  except
    on E: Exception do
      ShowMessage('Greška: ' + E.Message);
  end;
end;

procedure TForm16.DugmePrihvatiClick(Sender: TObject);
var
  StatusVozilaID, StatusVozacaID, VoziloID: Integer;
begin
  try
  ADOQuery1.Connection := Form7.ADOConnection1;
    ADOQuery1.Close;
    ADOQuery1.SQL.Text := 'UPDATE Ponude SET StatusID = 5 WHERE [ZahtevID] = :ZahtevID';
    ADOQuery1.Parameters.ParamByName('ZahtevID').Value := ZahtevID;
    ADOQuery1.ExecSQL;

   ADOQuery1.Close;
   ADOQuery1.SQL.Text := 'UPDATE Zahtevi SET StatusID = 5 WHERE [ID zahteva] = :ZahtevID';
   ADOQuery1.Parameters.ParamByName('ZahtevID').Value := ZahtevID;
   ADOQuery1.ExecSQL;

    ADOQuery1.Close;
    ADOQuery1.SQL.Text := 'SELECT VoziloID FROM Rezervacije WHERE ZahtevID = :ZahtevID';
    ADOQuery1.Parameters.ParamByName('ZahtevID').Value := ZahtevID;
    ADOQuery1.Open;
    VoziloID := ADOQuery1.FieldByName('VoziloID').AsInteger;

    ADOQuery1.Close;
ADOQuery1.SQL.Text := 'SELECT idStatusa FROM statusVozila WHERE status = ''U voznji''';
ADOQuery1.Open;
ShowMessage('IsEmpty = ' + BoolToStr(ADOQuery1.IsEmpty, True) + ', StatusVozilaID = ' + ADOQuery1.FieldByName('idStatusa').AsString); // privremeno
StatusVozilaID := ADOQuery1.FieldByName('idStatusa').AsInteger;

    ADOQuery1.Close;
    ADOQuery1.SQL.Text := 'UPDATE Vozila SET status = :StatusID WHERE ID = :VoziloID';
    ADOQuery1.Parameters.ParamByName('StatusID').Value := StatusVozilaID;
    ADOQuery1.Parameters.ParamByName('VoziloID').Value := VoziloID;
    ADOQuery1.ExecSQL;

    ADOQuery1.Close;
    ADOQuery1.SQL.Text := 'SELECT IDStatusa FROM statusVozaca WHERE StatusVozaca = ''Zauzet''';
    ADOQuery1.Open;
    StatusVozacaID := ADOQuery1.FieldByName('IDStatusa').AsInteger;

    ADOQuery1.Close;
    ADOQuery1.SQL.Text := 'UPDATE Vozaci SET Status = :StatusID WHERE IDVozaca = :VozacID';
    ADOQuery1.Parameters.ParamByName('StatusID').Value := StatusVozacaID;
    ADOQuery1.Parameters.ParamByName('VozacID').Value := PraviIDVozaca;
    ADOQuery1.ExecSQL;

    ShowMessage('Tura je prihvaćena!');
    Form15.UlogovaniVozac := UlogovaniVozac;
    Form15.FormShow(Self);
    Form15.Show;
    Self.Hide;

  except
    on E: Exception do
      ShowMessage('Greška: ' + E.Message);
  end;
end;

procedure TForm16.DugmeOdbijClick(Sender: TObject);
begin
  try
    ADOQuery1.Close;
    ADOQuery1.SQL.Text := 'DELETE FROM Rezervacije WHERE ZahtevID = :ZahtevID';
    ADOQuery1.Parameters.ParamByName('ZahtevID').Value := ZahtevID;
    ADOQuery1.ExecSQL;

    ADOQuery1.Close;
    ADOQuery1.SQL.Text := 'UPDATE Ponude SET StatusID = 4 WHERE ZahtevID = :ZahtevID';
    ADOQuery1.Parameters.ParamByName('ZahtevID').Value := ZahtevID;
    ADOQuery1.ExecSQL;

    ShowMessage('Tura je odbijena. Dispečer će dodeliti drugog vozača.');
    Form15.UlogovaniVozac := UlogovaniVozac;
    Form15.FormShow(Self);
    Form15.Show;
    Self.Hide;

  except
    on E: Exception do
      ShowMessage('Greška: ' + E.Message);
  end;
end;

procedure TForm16.SpeedButton1Click(Sender: TObject);
begin
  Form15.Show;
  Self.Hide;
end;

end.
