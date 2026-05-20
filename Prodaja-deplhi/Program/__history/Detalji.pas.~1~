unit Detalji;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, Data.DB,
  Data.Win.ADODB, FMX.StdCtrls, FMX.Controls.Presentation;

type
  TForm11 = class(TForm)
    DugmeKreirajPonudu: TButton;
    DugmeKreirajRezervaciju: TButton;
    MestoUtovara: TLabel;
    Datum: TLabel;
    VrstaRobe: TLabel;
    Kolicina: TLabel;
    NazivKlijenta: TLabel;
    Napomena: TLabel;
    MestoIstovara: TLabel;
    ADOQuery1: TADOQuery;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
   IzabraniID: Integer;
    IzabraniStatusID: Integer;
  end;

var
  Form11: TForm11;

implementation
uses ProdajaTura;

{$R *.fmx}

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

      NazivKlijenta.Text  := 'Klijent: ' + ADOQuery1.FieldByName('nazivKlijenta').AsString;
      MestoUtovara.Text   := 'Mesto utovara: ' + ADOQuery1.FieldByName('MestoUtovara').AsString;
      MestoIstovara.Text  := 'Mesto istovara: ' + ADOQuery1.FieldByName('MestoIstovara').AsString;
      Datum.Text          := 'Datum utovara: ' + ADOQuery1.FieldByName('DatumUtovara').AsString;
      VrstaRobe.Text      := 'Vrsta robe: ' + ADOQuery1.FieldByName('VrstaRobe').AsString;
      Kolicina.Text       := 'Količina (t): ' + ADOQuery1.FieldByName('Kolicina').AsString;
      Napomena.Text       := 'Napomena: ' + ADOQuery1.FieldByName('Napomena').AsString;
    end;

  except
    on E: Exception do
      ShowMessage('Greška pri učitavanju detalja: ' + E.Message);
  end;
end;

end.
