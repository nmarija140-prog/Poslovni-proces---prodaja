unit KreiranjePonude;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, Data.DB,
  Data.Win.ADODB, FMX.StdCtrls, FMX.Edit, FMX.Controls.Presentation,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, System.IniFiles;

type
  TForm12 = class(TForm)
  LabelKlijent: TLabel;
    LabelRuta: TLabel;
    LabelDatum: TLabel;
    EditCena: TEdit;
    EditRokPlacanja: TEdit;
    DugmeSacuvajPonudu: TButton;
    ADOQuery1: TADOQuery;
    MemoNapomena: TMemo;
    procedure FormShow(Sender: TObject);
    procedure MemoNapomenaExit(Sender: TObject);
    procedure MemoNapomenaEnter(Sender: TObject);

  private
    { Private declarations }
  public
    IDZahtevaZaPonudu: Integer;
  end;

var
  Form12: TForm12;

implementation
uses Detalji, ProdajaTura;

{$R *.fmx}

procedure TForm12.FormShow(Sender: TObject);
begin

  EditCena.Text := '';
  EditRokPlacanja.Text := '';
  MemoNapomena.Text := 'Napomena';

  try

    ADOQuery1.Connection := Form8.ADOConnection1;

    ADOQuery1.Close;
    ADOQuery1.SQL.Text :=
      'SELECT z.MestoUtovara, z.MestoIstovara, z.DatumUtovara, k.nazivKlijenta ' +
      'FROM Zahtevi z ' +
      'INNER JOIN Klijenti k ON z.KlijentID = k.IDKlijenta ' +
      'WHERE z.[ID Zahteva] = :IDZahteva';

    ADOQuery1.Parameters.ParamByName('IDZahteva').Value := IDZahtevaZaPonudu;
    ADOQuery1.Open;

    if not ADOQuery1.Eof then
    begin
    Self.LabelKlijent.TextSettings.WordWrap := True;
      Self.LabelKlijent.AutoSize := True;
      Self.LabelRuta.TextSettings.WordWrap := True;
      Self.LabelRuta.AutoSize := True;
      Self.LabelDatum.TextSettings.WordWrap := True;
      Self.LabelDatum.AutoSize := True;

      LabelKlijent.Text := 'Klijent: ' + ADOQuery1.FieldByName('nazivKlijenta').AsString;

      LabelRuta.Text := 'Ruta: ' + ADOQuery1.FieldByName('MestoUtovara').AsString +
                      ' -> ' + ADOQuery1.FieldByName('MestoIstovara').AsString;

      LabelDatum.Text := 'Datum utovara: ' + ADOQuery1.FieldByName('DatumUtovara').AsString;
    end;

  except
    on E: Exception do
      ShowMessage('Greška pri učitavanju podataka za ponudu: ' + E.Message);
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

end.
