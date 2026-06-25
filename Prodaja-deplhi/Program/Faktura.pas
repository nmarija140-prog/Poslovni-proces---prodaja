unit Faktura;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects,
  Data.DB, Data.Win.ADODB, System.IniFiles, System.IOUtils,
  Winapi.ShellAPI, Winapi.Windows,
  IdSMTP, IdMessage, IdAttachmentFile, IdExplicitTLSClientServerBase,
  IdSMTPBase, IdSSLOpenSSL, IdSSLOpenSSLHeaders;

type
  TForm17 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Button1: TButton;
    SpeedButton1: TSpeedButton;
    ADOQuery1: TADOQuery;
    LabelStatusFakture: TLabel;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    KlijentEmail: string;
    FakturaID: Integer;
    FakturaPostoji: Boolean;
    CenaOsnovica: Double;
    ValutaStr: string;
    RokPlacanja: Integer;
    function GenerisiFakturaPDF(out PutanjaDoPDFa: string): Boolean;
    function PosaljiMejlSaFakturom(const PrimaocEmail, PutanjaDoFajla: string): Boolean;
  public
    IDZahtevaZaFakturu: Integer;
  end;

var
  Form17: TForm17;

implementation

uses ProdajaTura;

{$R *.fmx}

procedure TForm17.FormCreate(Sender: TObject);
begin
  IdOpenSSLSetLibPath(ExtractFilePath(ParamStr(0)));
end;

procedure TForm17.FormShow(Sender: TObject);
begin
  FakturaID := 0;
  FakturaPostoji := False;
  KlijentEmail := '';
  CenaOsnovica := 0;
  ValutaStr := 'EUR';
  RokPlacanja := 15;

  Button1.Enabled := True;
  LabelStatusFakture.Text := '';

  try
    ADOQuery1.Connection := Form8.ADOConnection1;

    ADOQuery1.Close;
    ADOQuery1.SQL.Clear;
    ADOQuery1.SQL.Add('SELECT z.MestoUtovara, z.MestoIstovara, z.DatumUtovara, z.DatumIstovara,');
    ADOQuery1.SQL.Add('       k.nazivKlijenta, k.email,');
    ADOQuery1.SQL.Add('       p.Cena, p.Valuta, p.RokPlacanja');
    ADOQuery1.SQL.Add('FROM (Zahtevi z');
    ADOQuery1.SQL.Add('INNER JOIN Klijenti k ON z.KlijentID = k.IDKlijenta)');
    ADOQuery1.SQL.Add('LEFT JOIN Ponude p ON z.[ID zahteva] = p.ZahtevID');
    ADOQuery1.SQL.Add('WHERE z.[ID zahteva] = :IDZahteva');
    ADOQuery1.Parameters.ParamByName('IDZahteva').Value := IDZahtevaZaFakturu;
    ADOQuery1.Open;

    if not ADOQuery1.IsEmpty then
    begin
      Label1.Text := 'Klijent: ' + ADOQuery1.FieldByName('nazivKlijenta').AsString;
      Label2.Text := 'Ruta: ' + ADOQuery1.FieldByName('MestoUtovara').AsString +
                        ' → ' + ADOQuery1.FieldByName('MestoIstovara').AsString;
      Label3.Text := 'Datum isporuke: ' + ADOQuery1.FieldByName('DatumIstovara').AsString;
      KlijentEmail := ADOQuery1.FieldByName('email').AsString;
      CenaOsnovica := ADOQuery1.FieldByName('Cena').AsFloat;
      ValutaStr := ADOQuery1.FieldByName('Valuta').AsString;
      RokPlacanja := ADOQuery1.FieldByName('RokPlacanja').AsInteger;
      Label4.Text := 'Cena (bez PDV): ' + FormatFloat('#,##0.00', CenaOsnovica) + ' ' + ValutaStr;
      Label5.Text := 'Rok plaćanja: ' + IntToStr(RokPlacanja) + ' dana';
    end;


    ADOQuery1.Close;
    ADOQuery1.SQL.Text := 'SELECT FakturaID FROM Fakture WHERE ZahtevID = :ZahtevID';
    ADOQuery1.Parameters.ParamByName('ZahtevID').Value := IDZahtevaZaFakturu;
    ADOQuery1.Open;

    if not ADOQuery1.IsEmpty then
    begin
      FakturaPostoji := True;
      FakturaID := ADOQuery1.FieldByName('FakturaID').AsInteger;
      Button1.Enabled := False;
      LabelStatusFakture.Text := '✔ Faktura br. ' + IntToStr(FakturaID) + ' je već izdata';
    end;

  except
    on E: Exception do
      ShowMessage('Greška pri učitavanju: ' + E.Message);
  end;
end;

procedure TForm17.Button1Click(Sender: TObject);
var
  PutanjaDoPDFa: string;
begin
  if Trim(KlijentEmail) = '' then
  begin
    ShowMessage('Greška: Email klijenta nije pronađen!');
    Exit;
  end;

  try

    ADOQuery1.Close;
    ADOQuery1.SQL.Text :=
      'INSERT INTO Fakture (ZahtevID, DatumFakture, Iznos, StatusPlacanja) ' +
      'VALUES (:ZahtevID, :DatumFakture, :Iznos, :StatusPlacanja)';
    ADOQuery1.Parameters.ParamByName('ZahtevID').Value := IDZahtevaZaFakturu;
    ADOQuery1.Parameters.ParamByName('DatumFakture').Value := Now;
    ADOQuery1.Parameters.ParamByName('Iznos').Value := CenaOsnovica * 1.20;
    ADOQuery1.Parameters.ParamByName('StatusPlacanja').Value := 'Neplaćeno';
    ADOQuery1.ExecSQL;


    ADOQuery1.Close;
    ADOQuery1.SQL.Text := 'SELECT MAX(FakturaID) AS ZadnjiID FROM Fakture WHERE ZahtevID = :ZahtevID';
    ADOQuery1.Parameters.ParamByName('ZahtevID').Value := IDZahtevaZaFakturu;
    ADOQuery1.Open;
    FakturaID := ADOQuery1.FieldByName('ZadnjiID').AsInteger;


    if GenerisiFakturaPDF(PutanjaDoPDFa) then
    begin
      if PosaljiMejlSaFakturom(KlijentEmail, PutanjaDoPDFa) then
      begin
        Button1.Enabled := False;
        LabelStatusFakture.Text := '✔ Faktura br. ' + IntToStr(FakturaID) + ' je uspešno izdata i poslata!';
        ShowMessage('Faktura je uspešno izdata i poslata klijentu!');
        Form8.PopuniListuZahteva(-1);
      end
      else
        ShowMessage('PDF je napravljen ali slanje mejla nije uspelo.');
    end
    else
      ShowMessage('Greška pri generisanju PDF-a.');

  except
    on E: Exception do
      ShowMessage('Greška: ' + E.Message);
  end;
end;

function TForm17.GenerisiFakturaPDF(out PutanjaDoPDFa: string): Boolean;
var
  FolderZaFakture, PutanjaDoHTMLa: string;
  HTMLSadrzaj: TStringList;
  PDV, Ukupno: Double;
  BrojacCekanja: Integer;
begin
  Result := False;

  PDV := CenaOsnovica * 0.20;
  Ukupno := CenaOsnovica + PDV;

  FolderZaFakture := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), 'Fakture');
  if not TDirectory.Exists(FolderZaFakture) then
    TDirectory.CreateDirectory(FolderZaFakture);

  PutanjaDoPDFa := TPath.Combine(FolderZaFakture, 'Faktura_' + IntToStr(FakturaID) + '.pdf');
  PutanjaDoHTMLa := TPath.Combine(TPath.GetTempPath, 'temp_faktura_' + IntToStr(FakturaID) + '.html');

  if TFile.Exists(PutanjaDoPDFa) then try TFile.Delete(PutanjaDoPDFa); except end;
  if TFile.Exists(PutanjaDoHTMLa) then try TFile.Delete(PutanjaDoHTMLa); except end;

  HTMLSadrzaj := TStringList.Create;
  try
    HTMLSadrzaj.Add('<!DOCTYPE html><html><head><meta charset="UTF-8">');
    HTMLSadrzaj.Add('<style type="text/css">');
    HTMLSadrzaj.Add('html, body { font-family: Arial, sans-serif; color: #333; margin: 40px; line-height: 1.5; -webkit-print-color-adjust: exact; print-color-adjust: exact; }');
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

    HTMLSadrzaj.Add('<div class="header">');
    HTMLSadrzaj.Add('  <span class="company-name">MPM Transport d.o.o.</span><br>');
    HTMLSadrzaj.Add('  <span style="font-size:13px; color:#555;">Sektor prodaje i logistike | Adresa: Bresnički Do 101, Kragujevac<br>PIB: 123456789 | Email: mpmtransport9@gmail.com</span>');
    HTMLSadrzaj.Add('</div>');

    HTMLSadrzaj.Add('<table class="info-table"><tr>');
    HTMLSadrzaj.Add('  <td width="60%"><strong>KUPAC:</strong><br><span style="color:#1a5276; font-size:16px; font-weight:bold;">' + Label1.Text + '</span></td>');
    HTMLSadrzaj.Add('  <td width="40%" align="right">');
    HTMLSadrzaj.Add('    <span style="font-size:14px; color:#555;"><strong>Faktura br:</strong> 2026-' + FormatFloat('0000', FakturaID) + '</span><br>');
    HTMLSadrzaj.Add('    <strong>Datum izdavanja:</strong> ' + DateToStr(Now) + '<br>');
    HTMLSadrzaj.Add('    <strong>Rok plaćanja:</strong> ' + IntToStr(RokPlacanja) + ' dana');
    HTMLSadrzaj.Add('  </td>');
    HTMLSadrzaj.Add('</tr></table>');

    HTMLSadrzaj.Add('<div class="title">Faktura za izvršenu uslugu transporta</div><br><br>');

    HTMLSadrzaj.Add('<table class="data-table">');
    HTMLSadrzaj.Add('  <tr><th>Opis usluge</th><th width="180" align="right">Iznos bez PDV (' + ValutaStr + ')</th></tr>');
    HTMLSadrzaj.Add('  <tr><td>' + Label2.Text + '<br>' + Label3.Text + '</td>');
    HTMLSadrzaj.Add('      <td align="right"><strong>' + FormatFloat('#,##0.00', CenaOsnovica) + '</strong></td></tr>');
    HTMLSadrzaj.Add('</table>');

    HTMLSadrzaj.Add('<table class="fin-table">');
    HTMLSadrzaj.Add('  <tr><td>Neto osnovica:</td><td align="right">' + FormatFloat('#,##0.00', CenaOsnovica) + ' ' + ValutaStr + '</td></tr>');
    HTMLSadrzaj.Add('  <tr><td>PDV (20%):</td><td align="right">' + FormatFloat('#,##0.00', PDV) + ' ' + ValutaStr + '</td></tr>');
    HTMLSadrzaj.Add('  <tr class="total-row"><td><strong>UKUPNO ZA PLAĆANJE:</strong></td><td align="right"><strong>' + FormatFloat('#,##0.00', Ukupno) + ' ' + ValutaStr + '</strong></td></tr>');
    HTMLSadrzaj.Add('</table>');
    HTMLSadrzaj.Add('<div style="clear:both;"></div>');

    HTMLSadrzaj.Add('<br><p style="font-size:14px; background-color:#f9f9f9; padding:15px; border-left:4px solid #1a5276;">');
    HTMLSadrzaj.Add('Plaćanje izvršiti na račun: <strong>160-123456789-00</strong>, poziv na broj: <strong>2026-' + FormatFloat('0000', FakturaID) + '</strong></p>');

    HTMLSadrzaj.Add('<div class="footer">Ovaj dokument je kompjuterski generisan iz MPM informacionog sistema.</div>');
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

function TForm17.PosaljiMejlSaFakturom(const PrimaocEmail, PutanjaDoFajla: string): Boolean;
var
  IdSMTP: TIdSMTP;
  IdMsg: TIdMessage;
  IdAttachment: TIdAttachmentFile;
  IdSSL: TIdSSLIOHandlerSocketOpenSSL;
begin
  Result := False;

  IdSMTP := TIdSMTP.Create(nil);
  IdMsg := TIdMessage.Create(nil);
  IdSSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    IdMsg.From.Address := 'nmarija140@gmail.com';
    IdMsg.From.Name := 'MPM Transport';
    IdMsg.Recipients.Add.Address := PrimaocEmail;
    IdMsg.Subject := 'Faktura za izvršen transport br. 2026-' + FormatFloat('0000', FakturaID);

    IdMsg.Body.Clear;
    IdMsg.Body.Add('Poštovani,');
    IdMsg.Body.Add('');
    IdMsg.Body.Add('U prilogu Vam dostavljamo fakturu za izvršenu transportnu uslugu.');
    IdMsg.Body.Add('Molimo Vas da izvršite uplatu u navedenom roku.');
    IdMsg.Body.Add('');
    IdMsg.Body.Add('Srdačan pozdrav,');
    IdMsg.Body.Add('Sektor prodaje, MPM Transport d.o.o.');

    IdAttachment := TIdAttachmentFile.Create(IdMsg.MessageParts, PutanjaDoFajla);

    IdSSL.SSLOptions.Method := sslvTLSv1_2;
    IdSSL.SSLOptions.Mode := sslmClient;

    IdSMTP.IOHandler := IdSSL;
    IdSMTP.Host := 'smtp.gmail.com';
    IdSMTP.Port := 587;
    IdSMTP.UseTLS := utUseExplicitTLS;
    IdSMTP.Username := 'nmarija140@gmail.com';
    IdSMTP.Password := 'xfuycgmsauyopqmo';

    IdSMTP.Connect;
    try
      IdSMTP.Send(IdMsg);
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
  IdMsg.Free;
end;

procedure TForm17.SpeedButton1Click(Sender: TObject);
begin
  Form8.Left := Self.Left;
  Form8.Top := Self.Top;
  Form8.Width := Self.Width;
  Form8.Height := Self.Height;
  Form8.Show;
  Self.Hide;
end;

end.
