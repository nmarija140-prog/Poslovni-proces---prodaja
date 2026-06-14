unit KreiranjeRezervacije;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.ListBox, FMX.Controls.Presentation, Data.DB, Data.Win.ADODB, ProdajaTura;

type
  TForm12 = class(TForm)
    KlijentLabel: TLabel;
    RutaLabel: TLabel;
    DatumUtovaraLabel: TLabel;
    CenaLabel: TLabel;
    ComboBoxVozila: TComboBox;
    ComboBoxVozaci: TComboBox;
    DugmeSacuvajRezervaciju: TButton;
    DugmeOtkaziRez: TButton;
    Text1: TText;
    Text2: TText;
    Line1: TLine;
    DugmeNazad: TSpeedButton;
    ADOQuery1: TADOQuery;
    LabelVozac: TLabel;
    LabelVozilo: TLabel;
    procedure DugmeNazadClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OcistiLabele;
    procedure DugmeOtkaziRezClick(Sender: TObject);
    procedure DugmeSacuvajRezervacijuClick(Sender: TObject);
  private
    { Private declarations }
  public
    IDZahtevaZaPonudu: Integer;
  end;

var
  Form12: TForm12;

implementation

uses Detalji;

{$R *.fmx}
procedure TForm12.OcistiLabele;
begin
  KlijentLabel.Text := 'Klijent: ';
  RutaLabel.Text := 'Ruta: ';
  DatumUtovaraLabel.Text := 'Datum utovara: ';
  CenaLabel.Text := 'Cena: ';
  LabelVozilo.Text := '';
LabelVozac.Text := '';
LabelVozilo.Visible := False;
LabelVozac.Visible := False;

  ComboBoxVozila.ItemIndex := -1;
  ComboBoxVozaci.ItemIndex := -1;

end;

procedure TForm12.DugmeOtkaziRezClick(Sender: TObject);
var
  StatusSlobodanVoziloID, StatusSlobodanVozacID: Integer;
  RezVoziloID, RezVozacID: Integer;
begin

  ADOQuery1.Close;
  ADOQuery1.SQL.Text := 'SELECT * FROM Rezervacije WHERE ZahtevID = :ZahtevID';
  ADOQuery1.Parameters.ParamByName('ZahtevID').Value := IDZahtevaZaPonudu;
  ADOQuery1.Open;

  if ADOQuery1.IsEmpty then
  begin

    OcistiLabele;
    Form8.Show;
    Self.Hide;
    Exit;
  end;

  if MessageDlg('Da li ste sigurni da želite da otkažete rezervaciju?',
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrNo then
    Exit;

  try
    RezVoziloID := ADOQuery1.FieldByName('VoziloID').AsInteger;
    RezVozacID := ADOQuery1.FieldByName('VozacID').AsInteger;

    ADOQuery1.Close;
    ADOQuery1.SQL.Text := 'DELETE FROM Rezervacije WHERE ZahtevID = :ZahtevID';
    ADOQuery1.Parameters.ParamByName('ZahtevID').Value := IDZahtevaZaPonudu;
    ADOQuery1.ExecSQL;


    ADOQuery1.Close;
    ADOQuery1.SQL.Text := 'UPDATE Zahtevi SET StatusID = 4 WHERE [ID Zahteva] = :ZahtevID';
    ADOQuery1.Parameters.ParamByName('ZahtevID').Value := IDZahtevaZaPonudu;
    ADOQuery1.ExecSQL;


    ADOQuery1.Close;
    ADOQuery1.SQL.Text := 'SELECT idStatusa FROM statusVozila WHERE status = ''Slobodan''';
    ADOQuery1.Open;
    StatusSlobodanVoziloID := ADOQuery1.FieldByName('idStatusa').AsInteger;


    ADOQuery1.Close;
    ADOQuery1.SQL.Text := 'UPDATE Vozila SET status = :StatusID WHERE ID = :VoziloID';
    ADOQuery1.Parameters.ParamByName('StatusID').Value := StatusSlobodanVoziloID;
    ADOQuery1.Parameters.ParamByName('VoziloID').Value := RezVoziloID;
    ADOQuery1.ExecSQL;


    ADOQuery1.Close;
    ADOQuery1.SQL.Text := 'SELECT IDStatusa FROM statusVozaca WHERE StatusVozaca = ''Slobodan''';
    ADOQuery1.Open;
    StatusSlobodanVozacID := ADOQuery1.FieldByName('IDStatusa').AsInteger;

    ADOQuery1.Close;
    ADOQuery1.SQL.Text := 'UPDATE Vozaci SET Status = :StatusID WHERE IDVozaca = :VozacID';
    ADOQuery1.Parameters.ParamByName('StatusID').Value := StatusSlobodanVozacID;
    ADOQuery1.Parameters.ParamByName('VozacID').Value := RezVozacID;
    ADOQuery1.ExecSQL;

    Form8.PopuniListuZahteva(4);
    ShowMessage('Rezervacija je uspešno otkazana!');
    OcistiLabele;
    Form8.Show;
    Self.Hide;

  except
    on E: Exception do
      ShowMessage('Greška pri otkazivanju rezervacije: ' + E.Message);
  end;
end;

procedure TForm12.DugmeSacuvajRezervacijuClick(Sender: TObject);
var
  IzabranoVoziloID, IzabraniVozacID: Integer;
begin
  if ComboBoxVozila.ItemIndex = -1 then
  begin
    ShowMessage('Molimo vas, izaberite vozilo.');
    Exit;
  end;
  if ComboBoxVozaci.ItemIndex = -1 then
  begin
    ShowMessage('Molimo vas, izaberite vozača.');
    Exit;
  end;

  IzabranoVoziloID := Integer(ComboBoxVozila.Items.Objects[ComboBoxVozila.ItemIndex]);
  IzabraniVozacID := Integer(ComboBoxVozaci.Items.Objects[ComboBoxVozaci.ItemIndex]);

  try
    ADOQuery1.Close;
    ADOQuery1.SQL.Text :=
      'INSERT INTO Rezervacije (ZahtevID, VoziloID, VozacID, DatumRezervacije) ' +
      'VALUES (:ZahtevID, :VoziloID, :VozacID, :DatumRezervacije)';
    ADOQuery1.Parameters.ParamByName('ZahtevID').Value := IDZahtevaZaPonudu;
    ADOQuery1.Parameters.ParamByName('VoziloID').Value := IzabranoVoziloID;
    ADOQuery1.Parameters.ParamByName('VozacID').Value := IzabraniVozacID;
    ADOQuery1.Parameters.ParamByName('DatumRezervacije').Value := Now;
    ADOQuery1.ExecSQL;

    ShowMessage('Rezervacija je kreirana, čeka se potvrda vozača!');
    OcistiLabele;
    Form8.Show;
    Form8.PopuniListuZahteva(4);
    Self.Hide;

  except
    on E: Exception do
      ShowMessage('Greška pri čuvanju rezervacije: ' + E.Message);
  end;
end;

procedure TForm12.FormShow(Sender: TObject);
begin
  try
  OcistiLabele;

    ADOQuery1.Connection := Form8.ADOConnection1;

    ADOQuery1.Close;
   ADOQuery1.SQL.Text :=
      'SELECT z.*, k.nazivKlijenta, p.Cena ' +
      'FROM (Zahtevi z ' +
      'INNER JOIN Klijenti k ON z.KlijentID = k.IDKlijenta) ' +
      'LEFT JOIN Ponude p ON z.[ID Zahteva] = p.ZahtevID ' +
      'WHERE z.[ID Zahteva] = :IzabraniID';

    ADOQuery1.Parameters.ParamByName('IzabraniID').Value := IDZahtevaZaPonudu;
    ADOQuery1.Open;

    if not ADOQuery1.IsEmpty then
    begin

      KlijentLabel.TextSettings.WordWrap := True;
      KlijentLabel.AutoSize := True;
      RutaLabel.TextSettings.WordWrap := True;
      RutaLabel.AutoSize := True;
      DatumUtovaraLabel.TextSettings.WordWrap := True;
      DatumUtovaraLabel.AutoSize := True;
      CenaLabel.TextSettings.WordWrap := True;
      CenaLabel.AutoSize := True;


      if ADOQuery1.FieldByName('nazivKlijenta').IsNull then
        KlijentLabel.Text := 'Klijent: Nepoznato'
      else
        KlijentLabel.Text := 'Klijent: ' + ADOQuery1.FieldByName('nazivKlijenta').AsString;

      if ADOQuery1.FieldByName('MestoUtovara').IsNull or ADOQuery1.FieldByName('MestoIstovara').IsNull then
        RutaLabel.Text := 'Ruta: /'
      else
        RutaLabel.Text := 'Ruta: ' + ADOQuery1.FieldByName('MestoUtovara').AsString +
                             ' -> ' + ADOQuery1.FieldByName('MestoIstovara').AsString;

      if ADOQuery1.FieldByName('DatumUtovara').IsNull or ADOQuery1.FieldByName('DatumIstovara').IsNull then
        DatumUtovaraLabel.Text := 'Datum utovara/istovara: /'
      else
        DatumUtovaraLabel.Text := 'Datum utovara/istovara: ' + ADOQuery1.FieldByName('DatumUtovara').AsString+
                             ' -> ' + ADOQuery1.FieldByName('DatumIstovara').AsString;


      if ADOQuery1.FieldByName('Cena').IsNull then
        CenaLabel.Text := 'Cena: Nije definisana'
      else
        CenaLabel.Text := 'Cena: ' + ADOQuery1.FieldByName('Cena').AsString + ' EUR';

    end;
    ComboBoxVozila.Items.Clear;
    ADOQuery1.Close;
    ADOQuery1.SQL.Text :=
      'SELECT v.ID, v.naziv, v.registarski_broj ' +
      'FROM Vozila v ' +
      'INNER JOIN statusVozila s ON v.status = s.idStatusa ' +
      'WHERE s.status = ''Slobodan''';
    ADOQuery1.Open;
    while not ADOQuery1.Eof do
    begin
      ComboBoxVozila.Items.AddObject(
        ADOQuery1.FieldByName('naziv').AsString + ' (' + ADOQuery1.FieldByName('registarski_broj').AsString + ')',
        TObject(ADOQuery1.FieldByName('ID').AsInteger)
      );
      ADOQuery1.Next;
    end;
    ComboBoxVozaci.Items.Clear;
    ADOQuery1.Close;
  ADOQuery1.SQL.Text :=
  'SELECT v.IDVozaca, v.ImePrezime ' +
  'FROM Vozaci v ' +
  'INNER JOIN statusVozaca s ON v.Status = s.IDStatusa ' +
  'WHERE s.StatusVozaca = ''Slobodan'' ' +
  'AND v.IDVozaca NOT IN (' +
  '  SELECT r.VozacID FROM Rezervacije r ' +
  '  INNER JOIN Zahtevi z ON r.ZahtevID = z.[ID zahteva] ' +
  '  WHERE z.DatumUtovara = (SELECT DatumUtovara FROM Zahtevi WHERE [ID zahteva] = ' + IntToStr(IDZahtevaZaPonudu) + ')' +
  ')';
    ADOQuery1.Open;

    while not ADOQuery1.Eof do
    begin
      ComboBoxVozaci.Items.AddObject(
        ADOQuery1.FieldByName('ImePrezime').AsString ,TObject(ADOQuery1.FieldByName('IDVozaca').AsInteger)
      );
      ADOQuery1.Next;
    end;
    ADOQuery1.Close;
    ADOQuery1.SQL.Text :=
      'SELECT r.*, v.naziv, v.registarski_broj, voz.ImePrezime ' +
      'FROM (Rezervacije r ' +
      'INNER JOIN Vozila v ON r.VoziloID = v.ID) ' +
      'INNER JOIN Vozaci voz ON r.VozacID = voz.IDVozaca ' +
      'WHERE r.ZahtevID = :ZahtevID';
    ADOQuery1.Parameters.ParamByName('ZahtevID').Value := IDZahtevaZaPonudu;
    ADOQuery1.Open;

    if not ADOQuery1.IsEmpty then
    begin
      ComboBoxVozila.Visible := False;
      ComboBoxVozaci.Visible := False;
      DugmeSacuvajRezervaciju.Visible := False;
      Text1.Visible := False;
      Text2.Visible := False;

      LabelVozilo.Text := 'Vozilo: ' + ADOQuery1.FieldByName('naziv').AsString +
                          ' (' + ADOQuery1.FieldByName('registarski_broj').AsString + ')';
      LabelVozac.Text := 'Vozač: ' + ADOQuery1.FieldByName('ImePrezime').AsString;
      LabelVozilo.Visible := True;
      LabelVozac.Visible := True;
    end
    else
    begin
      ComboBoxVozila.Visible := True;
      ComboBoxVozaci.Visible := True;
      DugmeSacuvajRezervaciju.Visible := True;
      Text1.Visible := True;
      Text2.Visible := True;
      LabelVozilo.Visible := False;
      LabelVozac.Visible := False;
    end;

  except
    on E: Exception do
      ShowMessage('Greška pri učitavanju podataka za rezervaciju: ' + E.Message);
  end;
end;

procedure TForm12.DugmeNazadClick(Sender: TObject);
begin
  OcistiLabele;
  if not Assigned(Form8) then
    Application.CreateForm(TForm8, Form8);
  Form8.Left := Self.Left;
  Form8.Top := Self.Top;
  Form8.Width := Self.Width;
  Form8.Height := Self.Height;
  Form8.Show;
  Self.Hide;
end;

end.
