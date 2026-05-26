unit KreiranjePonude;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, Data.DB,
  Data.Win.ADODB, FMX.StdCtrls, FMX.Edit, FMX.Controls.Presentation,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, System.IniFiles, FMX.ListBox,
  FMX.EditBox, FMX.SpinBox, FMX.Objects, FMX.Printer, System.IOUtils, Winapi.ShellAPI;

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
    PonudaPostoji: Boolean;
    function GenerisiPDFPonude(out PutanjaDoPDFa: string): Boolean;
  public
    IDZahtevaZaPonudu: Integer;
  end;

var
  Form12: TForm12;

implementation
uses Detalji, ProdajaTura;

{$R *.fmx}

procedure TForm12.DugmePosaljiPonuduClick(Sender: TObject);
var
  PutanjaFajla: string;
begin
  if not PonudaSacuvana then
  begin
    ShowMessage('Prvo sačuvajte ponudu.');
    Exit;
  end;

  if GenerisiPDFPonude(PutanjaFajla) then
  begin
    ShellExecute(0, 'open', PChar(PutanjaFajla), nil, nil, 3);

    ShowMessage('Ponuda je uspešno generisana i poslata klijentu!' + sLineBreak +
                'Dokument je kreiran u folderu "Ponude" i otvoren na ekranu.');
  end;
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

      ADOQuery1.SQL.Text :=
        'INSERT INTO Ponude ' +
        '(ZahtevID, Cena, Valuta, RokPlacanja, Napomena, DatumPonude) ' +
        'VALUES (:ZahtevID, :Cena, :Valuta, :RokPlacanja, :Napomena, :DatumPonude)';

      ADOQuery1.Parameters.ParamByName('ZahtevID').Value := IDZahtevaZaPonudu;
      ADOQuery1.Parameters.ParamByName('DatumPonude').Value := Now;
    end
    else
    begin

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

    if not PonudaPostoji then
    begin
      PonudaPostoji := True;

      ADOQuery1.Close;
      ADOQuery1.SQL.Text := 'SELECT MAX(PonudaID) AS ZadnjiID FROM Ponude WHERE ZahtevID = :ZahtevID';
      ADOQuery1.Parameters.ParamByName('ZahtevID').Value := IDZahtevaZaPonudu;
      ADOQuery1.Open;

      if not ADOQuery1.Eof then
        PonudaID := ADOQuery1.FieldByName('ZadnjiID').AsInteger;
    end;

    PonudaSacuvana := True;
    DugmePosaljiPonudu.Enabled := True;

    ShowMessage('Ponuda uspešno sačuvana pod brojem: ' + IntToStr(PonudaID));

  except
    on E: Exception do
      ShowMessage('Greška pri čuvanju: ' + E.Message);
  end;
end;

procedure TForm12.FormShow(Sender: TObject);
begin
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

    ADOQuery1.Close;
    ADOQuery1.SQL.Text :=
      'SELECT PonudaID, Cena, Valuta, RokPlacanja, Napomena ' +
      'FROM Ponude WHERE ZahtevID = :ID';

    ADOQuery1.Parameters.ParamByName('ID').Value := IDZahtevaZaPonudu;
    ADOQuery1.Open;

    if not ADOQuery1.Eof then
    begin
      PonudaPostoji := True;
      PonudaSacuvana := True;
      PonudaID := ADOQuery1.FieldByName('PonudaID').AsInteger;

      EditCena.Text := ADOQuery1.FieldByName('Cena').AsString;
      SpinRokPlacanja.Value := ADOQuery1.FieldByName('RokPlacanja').AsInteger;
      MemoNapomena.Text := ADOQuery1.FieldByName('Napomena').AsString;

      ComboValuta.ItemIndex := ComboValuta.Items.IndexOf(ADOQuery1.FieldByName('Valuta').AsString);
      if ComboValuta.ItemIndex = -1 then ComboValuta.ItemIndex := 0;

      DugmePosaljiPonudu.Enabled := True;
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
  Self.Hide;
end;

function TForm12.GenerisiPDFPonude(out PutanjaDoPDFa: string): Boolean;
var
  FolderZaPonude, PutanjaDoLoga: string;
  CenaOsnovica, PdvIznos, Ukupno: Double;
  ValutaStr: string;
  Levo, Gore: Single;
  A4Slika: TBitmap;
  LogoSlika: TBitmap;
begin
  Result := False;
  try

    FolderZaPonude := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), 'Ponude');


    if not TDirectory.Exists(FolderZaPonude) then
      TDirectory.CreateDirectory(FolderZaPonude);

    PutanjaDoPDFa := TPath.Combine(FolderZaPonude, 'Ponuda_' + IntToStr(PonudaID) + '.png');
    PutanjaDoLoga := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), 'logo.png');

    CenaOsnovica := StrToFloatDef(EditCena.Text, 0);
    PdvIznos := CenaOsnovica * 0.20;
    Ukupno := CenaOsnovica + PdvIznos;
    ValutaStr := ComboValuta.Items[ComboValuta.ItemIndex];


    A4Slika := TBitmap.Create(595, 842);
    try
      if A4Slika.Canvas.BeginScene then
      try

        A4Slika.Canvas.Fill.Color := TAlphaColorRec.White;
        A4Slika.Canvas.Fill.Kind := TBrushKind.Solid;
        A4Slika.Canvas.FillRect(TRectF.Create(0, 0, 595, 842), 0, 0, [], 1.0);

        Levo := 50;

        if TFile.Exists(PutanjaDoLoga) then
        begin
          LogoSlika := TBitmap.Create;
          try
            LogoSlika.LoadFromFile(PutanjaDoLoga);
            A4Slika.Canvas.DrawBitmap(LogoSlika,
              TRectF.Create(0, 0, LogoSlika.Width, LogoSlika.Height),
              TRectF.Create(430, 50, 550, 130), 1.0);
          finally
            LogoSlika.Free;
          end;
        end;

        A4Slika.Canvas.Font.Size := 10;
        A4Slika.Canvas.Fill.Color := TAlphaColorRec.Darkgray;
        A4Slika.Canvas.FillText(TRectF.Create(Levo, 50, 400, 70), 'PREVOZNIK: MPMTransport', False, 1.0, [], TTextAlign.Leading);
        A4Slika.Canvas.FillText(TRectF.Create(Levo, 70, 400, 90), 'Adresa: Bresnicki Do 101, Kragujevac', False, 1.0, [], TTextAlign.Leading);
        A4Slika.Canvas.FillText(TRectF.Create(Levo, 90, 400, 110), 'PIB: 123456789', False, 1.0, [], TTextAlign.Leading);
        A4Slika.Canvas.FillText(TRectF.Create(Levo, 110, 400, 130), 'Email: mpmtransport@gmail.com', False, 1.0, [], TTextAlign.Leading);

        A4Slika.Canvas.Stroke.Color := TAlphaColorRec.Lightgray;
        A4Slika.Canvas.DrawLine(TPointF.Create(Levo, 150), TPointF.Create(550, 150), 1.0);

        Gore := 170;
        A4Slika.Canvas.Fill.Color := TAlphaColorRec.Black;
        A4Slika.Canvas.Font.Size := 11;
        A4Slika.Canvas.FillText(TRectF.Create(Levo, Gore, 300, Gore + 20), 'Naručilac / Klijent:', False, 1.0, [], TTextAlign.Leading);

        A4Slika.Canvas.Fill.Color := TAlphaColorRec.Darkblue;
        A4Slika.Canvas.FillText(TRectF.Create(Levo, Gore + 20, 300, Gore + 40), LabelKlijent.Text, False, 1.0, [], TTextAlign.Leading);

        A4Slika.Canvas.Fill.Color := TAlphaColorRec.Black;
        A4Slika.Canvas.FillText(TRectF.Create(350, Gore, 550, Gore + 20), 'Broj ponude: 2026-' + FormatFloat('0000', PonudaID), False, 1.0, [], TTextAlign.Leading);
        A4Slika.Canvas.FillText(TRectF.Create(350, Gore + 20, 550, Gore + 40), LabelDatum.Text, False, 1.0, [], TTextAlign.Leading);
        A4Slika.Canvas.FillText(TRectF.Create(350, Gore + 40, 550, Gore + 60), 'Važenje ponude: ' + FloatToStr(SpinRokPlacanja.Value) + ' dana', False, 1.0, [], TTextAlign.Leading);


        Gore := 250;
        A4Slika.Canvas.Font.Size := 18;
        A4Slika.Canvas.Fill.Color := TAlphaColorRec.Navy;
        A4Slika.Canvas.FillText(TRectF.Create(Levo, Gore, 500, Gore + 30), 'PONUDA br. 2026-' + FormatFloat('0000', PonudaID), False, 1.0, [], TTextAlign.Leading);


        Gore := 310;
        A4Slika.Canvas.Fill.Color := TAlphaColorRec.Lightgrey;
        A4Slika.Canvas.FillRect(TRectF.Create(Levo, Gore, 550, Gore + 25), 0, 0, [], 1.0);

        A4Slika.Canvas.Fill.Color := TAlphaColorRec.Black;
        A4Slika.Canvas.Font.Size := 10;
        A4Slika.Canvas.FillText(TRectF.Create(Levo + 10, Gore + 5, 300, Gore + 25), 'Naziv usluge / Opis rute', False, 1.0, [], TTextAlign.Leading);
        A4Slika.Canvas.FillText(TRectF.Create(450, Gore + 5, 550, Gore + 25), 'Ukupno (' + ValutaStr + ')', False, 1.0, [], TTextAlign.Leading);

        Gore := Gore + 30;
        A4Slika.Canvas.FillText(TRectF.Create(Levo + 10, Gore, 300, Gore + 20), LabelRuta.Text, False, 1.0, [], TTextAlign.Leading);
        A4Slika.Canvas.FillText(TRectF.Create(450, Gore, 550, Gore + 20), FormatFloat('#,##0.00', CenaOsnovica), False, 1.0, [], TTextAlign.Leading);

        Gore := Gore + 50;
        A4Slika.Canvas.FillText(TRectF.Create(300, Gore, 440, Gore + 20), 'Osnovica:', False, 1.0, [], TTextAlign.Leading);
        A4Slika.Canvas.FillText(TRectF.Create(450, Gore, 550, Gore + 20), FormatFloat('#,##0.00', CenaOsnovica), False, 1.0, [], TTextAlign.Leading);

        A4Slika.Canvas.FillText(TRectF.Create(300, Gore + 15, 440, Gore + 35), 'PDV (20%):', False, 1.0, [], TTextAlign.Leading);
        A4Slika.Canvas.FillText(TRectF.Create(450, Gore + 15, 550, Gore + 35), FormatFloat('#,##0.00', PdvIznos), False, 1.0, [], TTextAlign.Leading);

        A4Slika.Canvas.Font.Size := 12;
        A4Slika.Canvas.Fill.Color := TAlphaColorRec.Navy;
        A4Slika.Canvas.FillText(TRectF.Create(250, Gore + 40, 440, Gore + 65), 'UKUPNO ZA PLAĆANJE:', False, 1.0, [], TTextAlign.Leading);
        A4Slika.Canvas.FillText(TRectF.Create(450, Gore + 40, 550, Gore + 65), FormatFloat('#,##0.00', Ukupno), False, 1.0, [], TTextAlign.Leading);


        Gore := Gore + 120;
        A4Slika.Canvas.Fill.Color := TAlphaColorRec.Black;
        A4Slika.Canvas.Font.Size := 11;
        A4Slika.Canvas.FillText(TRectF.Create(Levo, Gore, 500, Gore + 20), 'Uslovi poslovanja:', False, 1.0, [], TTextAlign.Leading);

        A4Slika.Canvas.Font.Size := 9;
        A4Slika.Canvas.Fill.Color := TAlphaColorRec.Darkgray;
        A4Slika.Canvas.FillText(TRectF.Create(Levo, Gore + 20, 500, Gore + 40), '• Rok transporta: Prema dogovorenom datumu utovara.', False, 1.0, [], TTextAlign.Leading);
        A4Slika.Canvas.FillText(TRectF.Create(Levo, Gore + 35, 500, Gore + 55), '• Valuta plaćanja: ' + FloatToStr(SpinRokPlacanja.Value) + ' dana od završetka usluge.', False, 1.0, [], TTextAlign.Leading);

        A4Slika.Canvas.Font.Size := 8;
        A4Slika.Canvas.FillText(TRectF.Create(Levo, 750, 500, 770), 'Dokument je punovažan bez pečata i potpisa. Generisano automatski.', False, 1.0, [], TTextAlign.Leading);

      finally
        A4Slika.Canvas.EndScene;
      end;

      A4Slika.SaveToFile(PutanjaDoPDFa);
      Result := TFile.Exists(PutanjaDoPDFa);
    finally
      A4Slika.Free;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('Greška pri kreiranju: ' + E.Message);
      Result := False;
    end;
  end;
end;

end.
