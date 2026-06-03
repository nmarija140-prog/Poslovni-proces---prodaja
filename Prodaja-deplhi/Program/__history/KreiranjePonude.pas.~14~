unit KreiranjePonude;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, Data.DB,
  Data.Win.ADODB, FMX.StdCtrls, FMX.Edit, FMX.Controls.Presentation,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, System.IniFiles, FMX.ListBox,
  FMX.EditBox, FMX.SpinBox, FMX.Objects, System.IOUtils, Winapi.ShellAPI,
  Winapi.Windows, IdSMTP, IdMessage, IdAttachmentFile, IdExplicitTLSClientServerBase,
  IdSMTPBase, IdSSLOpenSSL, IdSSLOpenSSLHeaders;

type
  TForm13 = class(TForm)
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
    procedure FormCreate(Sender: TObject);
  private
  KlijentID: Integer;
    PonudaSacuvana: Boolean;
    PonudaID: Integer;
    PonudaPostoji: Boolean;
    KlijentEmail: string;
    function GenerisiPDFAutomatski(out PutanjaDoPDFa: string): Boolean;
    function PosaljiMejlSaPonudom(const PrimaocEmail, PutanjaDoFajla: string): Boolean;
  public
    IDZahtevaZaPonudu: Integer;
  end;

var
  Form13: TForm13;

implementation
uses Detalji, ProdajaTura;

{$R *.fmx}

procedure TForm13.DugmePosaljiPonuduClick(Sender: TObject);
var
  PutanjaDoPDFa: string;
  IDNovogStatusa: Integer;
begin
  if Trim(KlijentEmail) = '' then
  begin
    ShowMessage('Greška: Email klijenta nije pronađen u bazi!');
    Exit;
  end;

  IDNovogStatusa := 3;

  if GenerisiPDFAutomatski(PutanjaDoPDFa) then
  begin
    if PosaljiMejlSaPonudom(KlijentEmail, PutanjaDoPDFa) then
    begin
      try
        ADOQuery1.Close;
        ADOQuery1.SQL.Clear;
        ADOQuery1.SQL.Text := 'UPDATE Ponude SET StatusID = :NoviStatusID WHERE PonudaID = :PonudaID';

        ADOQuery1.Parameters.ParamByName('NoviStatusID').Value := IDNovogStatusa;
        ADOQuery1.Parameters.ParamByName('PonudaID').Value := PonudaID;
        ADOQuery1.ExecSQL;


        FormShow(Self);

        ShowMessage('PDF ponuda je uspešno poslata klijentu, a status je ažuriran!');
        Form8.PopuniListuZahteva(1, True);
      except
        on E: Exception do
          ShowMessage('Mejl je poslat, ali je puklo ažuriranje StatusID-ja u bazi: ' + E.Message);
      end;
    end
    else
    begin
      ShowMessage('Greška: PDF je napravljen, ali slanje na mejl nije uspelo.');
    end;
  end
  else
  begin
    ShowMessage('Greška: Windows sistem je blokirao generisanje PDF fajla.');
  end;
end;

procedure TForm13.DugmeSacuvajPonuduClick(Sender: TObject);
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
  '(ZahtevID, KlijentID, Cena, Valuta, RokPlacanja, Napomena, DatumPonude) ' +
  'VALUES (:ZahtevID, :KlijentID, :Cena, :Valuta, :RokPlacanja, :Napomena, :DatumPonude)';


      ADOQuery1.Parameters.ParamByName('ZahtevID').Value := IDZahtevaZaPonudu;
      ADOQuery1.Parameters.ParamByName('KlijentID').Value := KlijentID;
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

procedure TForm13.FormCreate(Sender: TObject);
begin
  IdOpenSSLSetLibPath(ExtractFilePath(ParamStr(0)));
end;

procedure TForm13.FormShow(Sender: TObject);
var
  TrenutniStatusID: Integer;
begin

  PonudaID := 0;
  PonudaPostoji := False;
  PonudaSacuvana := False;
  DugmePosaljiPonudu.Enabled := False;
  DugmeSacuvajPonudu.Enabled := True;
  KlijentEmail := '';
  TrenutniStatusID := 1;


  ComboValuta.Items.Clear;
  ComboValuta.Items.Add('EUR');
  ComboValuta.Items.Add('USD');
  ComboValuta.Items.Add('RSD');
  ComboValuta.ItemIndex := 0;

  EditCena.Text := '';
  EditCena.ReadOnly := False;
  SpinRokPlacanja.Value := 15;
  SpinRokPlacanja.Enabled := True;
  ComboValuta.Enabled := True;
  MemoNapomena.Text := 'Napomena';
  MemoNapomena.ReadOnly := False;


  DugmePosaljiPonudu.Text := 'Pošalji ponudu klijentu';
  DugmePosaljiPonudu.Width := 180;
  DugmePosaljiPonudu.Position.X := (Self.Width - DugmePosaljiPonudu.Width) / 2;

  try
    ADOQuery1.Connection := Form8.ADOConnection1;


    ADOQuery1.Close;
    ADOQuery1.SQL.Clear;
    ADOQuery1.SQL.Add('SELECT z.MestoUtovara, z.MestoIstovara, z.DatumUtovara, z.StatusID, k.nazivKlijenta, k.email, k.IDKlijenta ');
    ADOQuery1.SQL.Add('       p.PonudaID, p.Cena, p.Valuta, p.RokPlacanja, p.Napomena ');
    ADOQuery1.SQL.Add('FROM (Zahtevi z ');
    ADOQuery1.SQL.Add('INNER JOIN Klijenti k ON z.KlijentID = k.IDKlijenta) ');
    ADOQuery1.SQL.Add('LEFT JOIN Ponude p ON z.[ID zahteva] = p.ZahtevID ');
    ADOQuery1.SQL.Add('WHERE z.[ID zahteva] = :IDzahteva');

    ADOQuery1.Parameters.ParamByName('IDzahteva').Value := IDZahtevaZaPonudu;
    ADOQuery1.Open;

    if not ADOQuery1.Eof then
    begin
      LabelKlijent.Text := 'Klijent: ' + ADOQuery1.FieldByName('nazivKlijenta').AsString;
      LabelRuta.Text := 'Ruta: ' + ADOQuery1.FieldByName('MestoUtovara').AsString +
                        ' -> ' + ADOQuery1.FieldByName('MestoIstovara').AsString;
      LabelDatum.Text := 'Datum utovara: ' + ADOQuery1.FieldByName('DatumUtovara').AsString;
      KlijentEmail := ADOQuery1.FieldByName('email').AsString;
      KlijentID := ADOQuery1.FieldByName('IDKlijenta').AsInteger;

      TrenutniStatusID := ADOQuery1.FieldByName('StatusID').AsInteger;

      if not ADOQuery1.FieldByName('PonudaID').IsNull then
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
    end;


    if TrenutniStatusID = 3 then
    begin
      EditCena.ReadOnly := True;
      SpinRokPlacanja.Enabled := False;
      ComboValuta.Enabled := False;
      MemoNapomena.ReadOnly := True;

      DugmeSacuvajPonudu.Enabled := False;
      DugmePosaljiPonudu.Enabled := False;

      DugmePosaljiPonudu.Text := 'Ponuda je uspešno poslata klijentu ✔';
      DugmePosaljiPonudu.Width := 260;
      DugmePosaljiPonudu.Position.X := (Self.Width - DugmePosaljiPonudu.Width) / 2;
    end;

  except
    on E: Exception do
      ShowMessage('Greška pri učitavanju forme: ' + E.Message);
  end;
end;

procedure TForm13.MemoNapomenaEnter(Sender: TObject);
begin
  if MemoNapomena.Text = 'Napomena' then
    MemoNapomena.Text := '';
end;

procedure TForm13.MemoNapomenaExit(Sender: TObject);
begin
  if Trim(MemoNapomena.Text) = '' then
    MemoNapomena.Text := 'Napomena';
end;

procedure TForm13.SpeedButton1Click(Sender: TObject);
begin
  Form8.Show;
  Self.Hide;
end;

function TForm13.GenerisiPDFAutomatski(out PutanjaDoPDFa: string): Boolean;
var
  FolderZaPonude, PutanjaDoHTMLa: string;
  HTMLSadrzaj: TStringList;
  CenaOsnovica, PdvIznos, Ukupno: Double;
  ValutaStr, NapomenaTekst: string;
  BrojacCekanja: Integer;
begin
  Result := False;

  FolderZaPonude := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), 'Ponude');
  if not TDirectory.Exists(FolderZaPonude) then
    TDirectory.CreateDirectory(FolderZaPonude);

  PutanjaDoPDFa := TPath.Combine(FolderZaPonude, 'Ponuda_' + IntToStr(PonudaID) + '.pdf');
  PutanjaDoHTMLa := TPath.Combine(TPath.GetTempPath, 'temp_ponuda_' + IntToStr(PonudaID) + '.html');

  if TFile.Exists(PutanjaDoPDFa) then try TFile.Delete(PutanjaDoPDFa); except end;
  if TFile.Exists(PutanjaDoHTMLa) then try TFile.Delete(PutanjaDoHTMLa); except end;

  CenaOsnovica := StrToFloatDef(EditCena.Text, 0);
  PdvIznos := CenaOsnovica * 0.20;
  Ukupno := CenaOsnovica + PdvIznos;
  ValutaStr := ComboValuta.Items[ComboValuta.ItemIndex];

  if (MemoNapomena.Text <> '') and (MemoNapomena.Text <> 'Napomena') then
    NapomenaTekst := MemoNapomena.Text
  else
    NapomenaTekst := '/';

  HTMLSadrzaj := TStringList.Create;
  try
    HTMLSadrzaj.Add('<!DOCTYPE html><html><head><meta charset="UTF-8">');
    HTMLSadrzaj.Add('<style type="text/css">');
    HTMLSadrzaj.Add('html, body { font-family: Arial, sans-serif; color: #333; margin: 40px; line-height: 1.5; -webkit-print-color-adjust: exact; print-color-adjust: exact; }');
    HTMLSadrzaj.Add('* { -webkit-user-select: none; user-select: none; }');
    HTMLSadrzaj.Add('.zastita { display: block; break-inside: avoid; transform: translateZ(0); }');
    HTMLSadrzaj.Add('.header { width: 100%; border-bottom: 3px solid #1a5276; padding-bottom: 15px; margin-bottom: 25px; }');
    HTMLSadrzaj.Add('.company-name { font-size: 22px; font-weight: bold; color: #1a5276; }');
    HTMLSadrzaj.Add('.title { font-size: 26px; color: #2c3e50; font-weight: bold; margin-top: 20px; text-transform: uppercase; text-align: center; }');
    HTMLSadrzaj.Add('.info-table { width: 100%; margin-bottom: 35px; border-collapse: collapse; }');
    HTMLSadrzaj.Add('.info-table td { padding: 6px; vertical-align: top; font-size: 14px; }');
    HTMLSadrzaj.Add('.data-table { width: 100%; border-collapse: collapse; margin-bottom: 30px; }');
    HTMLSadrzaj.Add('.data-table th { background-color: #1a5276; color: white; border: 1px solid #1a5276; padding: 12px; text-align: left; font-size: 14px; }');
    HTMLSadrzaj.Add('.data-table td { border: 1px solid #d5dbdb; padding: 12px; font-size: 14px; }');
    HTMLSadrzaj.Add('.fin-table { float: right; width: 320px; margin-bottom: 40px; border-collapse: collapse; }');
    HTMLSadrzaj.Add('.fin-table td { padding: 8px; font-size: 14px; }');
    HTMLSadrzaj.Add('.total-row { font-weight: bold; font-size: 18px; color: white; background-color: #2c3e50; }');
    HTMLSadrzaj.Add('.footer { position: fixed; bottom: 20px; left: 40px; font-size: 11px; color: #7f8c8d; }');
    HTMLSadrzaj.Add('</style></head><body>');

    HTMLSadrzaj.Add('<div class="zastita">');
    HTMLSadrzaj.Add('<div class="header">');
    HTMLSadrzaj.Add('  <span class="company-name">MPM Transport d.o.o.</span><br>');
    HTMLSadrzaj.Add('  <span style="font-size:13px; color:#555;">Sektor prodaje i logistike | Adresa: Bresnički Do 101, Kragujevac<br>PIB: 123456789 | Email: mpmtransport9@gmail.com</span>');
    HTMLSadrzaj.Add('</div>');

    HTMLSadrzaj.Add('<table class="info-table"><tr>');
    HTMLSadrzaj.Add('  <td width="60%"><strong>PRIMALAC PONUDE / KLIJENT:</strong><br><span style="color:#1a5276; font-size:16px; font-weight:bold;">' + LabelKlijent.Text + '</span></td>');
    HTMLSadrzaj.Add('  <td width="40%" align="right">');
    HTMLSadrzaj.Add('     <span style="font-size:14px; color:#555;"><strong>Ponuda br:</strong> 2026-' + FormatFloat('0000', PonudaID) + '</span><br>');
    HTMLSadrzaj.Add('     <strong>' + LabelDatum.Text + '</strong><br>');
    HTMLSadrzaj.Add('     <strong>Rok važenja:</strong> 7 dana od izdavanja');
    HTMLSadrzaj.Add('  </td>');
    HTMLSadrzaj.Add('</tr></table>');

    HTMLSadrzaj.Add('<div class="title">Zvanična ponuda za vršenje usluge transporta</div><br><br>');

    HTMLSadrzaj.Add('<table class="data-table">');
    HTMLSadrzaj.Add('  <tr><th>Opis transportne rute i relacije</th><th width="180" align="right">Cena bez PDV-a (' + ValutaStr + ')</th></tr>');
    HTMLSadrzaj.Add('  <tr><td>' + LabelRuta.Text + '</td><td align="right"><strong>' + FormatFloat('#,##0.00', CenaOsnovica) + '</strong></td></tr>');
    HTMLSadrzaj.Add('</table>');

    HTMLSadrzaj.Add('<table class="fin-table">');
    HTMLSadrzaj.Add('  <tr><td>Neto osnovica:</td><td align="right">' + FormatFloat('#,##0.00', CenaOsnovica) + ' ' + ValutaStr + '</td></tr>');
    HTMLSadrzaj.Add('  <tr><td>PDV (20%):</td><td align="right">' + FormatFloat('#,##0.00', PdvIznos) + ' ' + ValutaStr + '</td></tr>');
    HTMLSadrzaj.Add('  <tr class="total-row"><td><strong>UKUPNO ZA PLAĆANJE:</strong></td><td align="right"><strong>' + FormatFloat('#,##0.00', Ukupno) + ' ' + ValutaStr + '</strong></td></tr>');
    HTMLSadrzaj.Add('</table>');
    HTMLSadrzaj.Add('<div style="clear:both;"></div>');

    HTMLSadrzaj.Add('<br><p style="font-size:14px; background-color:#f9f9f9; padding:15px; border-left:4px solid #1a5276;">');
    HTMLSadrzaj.Add('<strong>Uslovi realizacije i plaćanja:</strong><br>');
    HTMLSadrzaj.Add('• Rok plaćanja izvršene usluge iznosi <strong>' + FloatToStr(SpinRokPlacanja.Value) + ' dana</strong> od završetka transporta.<br>');
    HTMLSadrzaj.Add('• Posebne napomene naloga: ' + NapomenaTekst + '</p>');

    HTMLSadrzaj.Add('<div class="footer">Ovaj dokument je kompjuterski generisan iz MPM informacionog sistema i punovažan je bez pečata i potpisa.</div>');
    HTMLSadrzaj.Add('</div>');
    HTMLSadrzaj.Add('</body></html>');

    HTMLSadrzaj.SaveToFile(PutanjaDoHTMLa, TEncoding.UTF8);

    Winapi.ShellAPI.ShellExecute(0, 'open', 'msedge.exe',
      PChar('--headless --disable-gpu --no-pdf-header-footer --print-to-pdf="' + PutanjaDoPDFa + '" "' + PutanjaDoHTMLa + '"'),
      nil, SW_HIDE);

    BrojacCekanja := 0;
    while (not TFile.Exists(PutanjaDoPDFa)) and (BrojacCekanja < 8) do
    begin
      Sleep(1000);
      Inc(BrojacCekanja);
    end;

    if TFile.Exists(PutanjaDoHTMLa) then
      try TFile.Delete(PutanjaDoHTMLa); except end;

    Result := TFile.Exists(PutanjaDoPDFa);
  finally
    HTMLSadrzaj.Free;
  end;
end;

function TForm13.PosaljiMejlSaPonudom(const PrimaocEmail, PutanjaDoFajla: string): Boolean;
var
  IdSMTP: TIdSMTP;
  IdMessage: TIdMessage;
  IdAttachment: TIdAttachmentFile;
  IdSSL: TIdSSLIOHandlerSocketOpenSSL;
begin
  Result := False;

  IdSMTP := TIdSMTP.Create(nil);
  IdMessage := TIdMessage.Create(nil);
  IdSSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    IdMessage.From.Address := 'mpmtransport9@gmail.com';
    IdMessage.From.Name := 'MPM Transport';
    IdMessage.ReplyTo.EMailAddresses := IdMessage.From.Address;

    IdMessage.Recipients.Add.Address := PrimaocEmail;
    IdMessage.Subject := 'Zvanična ponuda za transport br. 2026-' + FormatFloat('0000', PonudaID);

    IdMessage.Body.Clear;
    IdMessage.Body.Add('Poštovani,');
    IdMessage.Body.Add('');
    IdMessage.Body.Add('U prilogu ovog mejla Vam dostavljamo našu zvaničnu ponudu za transport robe generisanu kroz MPM sistem.');
    IdMessage.Body.Add('Molimo Vas da pregledate priloženi PDF dokument i javite nam Vaš odgovor.');
    IdMessage.Body.Add('');
    IdMessage.Body.Add('Srdačan pozdrav,');
    IdMessage.Body.Add('Sektor prodaje, MPM Transport d.o.o.');

    IdAttachment := TIdAttachmentFile.Create(IdMessage.MessageParts, PutanjaDoFajla);

    IdSSL.SSLOptions.Method := sslvTLSv1_2;
    IdSSL.SSLOptions.Mode := sslmClient;

    IdSMTP.IOHandler := IdSSL;
    IdSMTP.Host := 'smtp.gmail.com';
    IdSMTP.Port := 587;
    IdSMTP.UseTLS := utUseExplicitTLS;

    IdSMTP.Username := 'mpmtransport9@gmail.com';
    IdSMTP.Password := 'ymfnudftsybjadjh';

    IdSMTP.Connect;
    try
      IdSMTP.Send(IdMessage);
      Result := True;
    finally
      IdSMTP.Disconnect;
    end;

  except
    on E: Exception do
    begin
      ShowMessage('Greška pri slanju mejla: ' + E.Message);
      Result := False;
    end;
  end;

  IdSSL.Free;
  IdSMTP.Free;
  IdMessage.Free;
end;

end.
