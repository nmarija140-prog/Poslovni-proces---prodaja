unit KlijentPrihvatanje;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  Data.DB, Data.Win.ADODB, FMX.StdCtrls, FMX.ScrollBox, FMX.Memo,
  FMX.Controls.Presentation;

type
  TForm14 = class(TForm)
    LabelRuta: TLabel;
    LabelDatum: TLabel;
    LabelCena: TLabel;
    LabelRokPlacanja: TLabel;
    MemoNapomena: TMemo;
    SpeedButtonNazad: TSpeedButton;
    ButtonPrihvati: TButton;
    ButtonOdbij: TButton;
    ADOQuery1: TADOQuery;
    procedure FormShow(Sender: TObject);
    procedure ButtonPrihvatiClick(Sender: TObject);
    procedure ButtonOdbijClick(Sender: TObject);
    procedure SpeedButtonNazadClick(Sender: TObject);
  private
  public
    PonudaID: Integer;
    ZahtevID: Integer;
  end;

var
  Form14: TForm14;

implementation

uses ProdajaTura, PonudeKlijenta;

{$R *.fmx}

procedure TForm14.FormShow(Sender: TObject);
var
  CenaOsnovica, PDV, Ukupno: Double;
begin
  try
    ADOQuery1.Connection := Form8.ADOConnection1;
    ADOQuery1.Close;
    ADOQuery1.SQL.Text :=
      'SELECT p.Cena, p.Valuta, p.RokPlacanja, p.Napomena, ' +
      '       z.MestoUtovara, z.MestoIstovara, z.DatumUtovara ' +
      'FROM Ponude p ' +
      'INNER JOIN Zahtevi z ON p.ZahtevID = z.[ID zahteva] ' +
      'WHERE p.PonudaID = :PonudaID';
    ADOQuery1.Parameters.ParamByName('PonudaID').Value := PonudaID;
    ADOQuery1.Open;

    if not ADOQuery1.IsEmpty then
    begin
      LabelRuta.Text := 'Ruta: ' + ADOQuery1.FieldByName('MestoUtovara').AsString +
                        ' → ' + ADOQuery1.FieldByName('MestoIstovara').AsString;
      LabelDatum.Text := 'Datum utovara: ' + ADOQuery1.FieldByName('DatumUtovara').AsString;

      CenaOsnovica := ADOQuery1.FieldByName('Cena').AsFloat;
      PDV := CenaOsnovica * 0.20;
      Ukupno := CenaOsnovica + PDV;
      LabelCena.Text := 'Ukupna cena sa PDV: ' + FormatFloat('#,##0.00', Ukupno) +
                        ' ' + ADOQuery1.FieldByName('Valuta').AsString;

      LabelRokPlacanja.Text := 'Rok plaćanja: ' + ADOQuery1.FieldByName('RokPlacanja').AsString + ' dana';
      MemoNapomena.Text := ADOQuery1.FieldByName('Napomena').AsString;
      MemoNapomena.ReadOnly := True;
    end;

  except
    on E: Exception do
      ShowMessage('Greška: ' + E.Message);
  end;
end;



procedure TForm14.ButtonPrihvatiClick(Sender: TObject);
begin
  try
    ADOQuery1.Close;
    ADOQuery1.SQL.Text := 'UPDATE Ponude SET OdgovorKlijenta = 1, StatusID = 4 WHERE PonudaID = :PonudaID';
    ADOQuery1.Parameters.ParamByName('PonudaID').Value := PonudaID;
    ADOQuery1.ExecSQL;

    ADOQuery1.Close;
    ADOQuery1.SQL.Text := 'UPDATE Zahtevi SET StatusID = 4 WHERE [ID Zahteva] = :ZahtevID';
    ADOQuery1.Parameters.ParamByName('ZahtevID').Value := ZahtevID;
    ADOQuery1.ExecSQL;

    ShowMessage('Ponuda je prihvaćena!');
    Form11.Show;
    Self.Hide;

  except
    on E: Exception do
      ShowMessage('Greška: ' + E.Message);
  end;
end;

procedure TForm14.ButtonOdbijClick(Sender: TObject);
begin
  try
    ADOQuery1.Close;
    ADOQuery1.SQL.Text := 'UPDATE Ponude SET OdgovorKlijenta = 2 WHERE PonudaID = :PonudaID';
    ADOQuery1.Parameters.ParamByName('PonudaID').Value := PonudaID;
    ADOQuery1.ExecSQL;

    ADOQuery1.Close;
    ADOQuery1.SQL.Text := 'UPDATE Zahtevi SET StatusID = 2 WHERE [ID Zahteva] = :ZahtevID';
    ADOQuery1.Parameters.ParamByName('ZahtevID').Value := ZahtevID;
    ADOQuery1.ExecSQL;

    ShowMessage('Ponuda je odbijena.');
    Form11.Show;
    Self.Hide;
  except
    on E: Exception do
      ShowMessage('Greška: ' + E.Message);
  end;
end;

procedure TForm14.SpeedButtonNazadClick(Sender: TObject);
begin
  Form11.Show;
  Self.Hide;
end;

end.
