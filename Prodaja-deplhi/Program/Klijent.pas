unit Klijent;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, UnosPodataka, FMX.Objects, PozicijaForme,
  FMX.Layouts, Data.DB, Data.Win.ADODB, ProdajaTura;

type
  TForm6 = class(TForm)
    SpeedButton1: TSpeedButton;
    Image1: TImage;
    Text1: TText;
    txtImeKorisnika: TText;
    txtNazivFirme: TText;
    txtPIB: TText;
    txtAdresa: TText;
    btnOtvoriNalog: TButton;
    btnUrediProfil: TButton;
    txtEmail: TText;
    txtBrojTelefona: TText;
    Zvonce: TPath;
    Label1: TLabel;
    PravougaonikZvonce: TRectangle;
    LayoutZvonce: TLayout;
    ADOQuery1: TADOQuery;
    dugmePonude: TButton; // Osiguravamo da je dugme ispravno deklarisano
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure ZvonceClick(Sender: TObject);
    procedure dugmePonudeClick(Sender: TObject);
  private
    PraviIDKlijenta: Integer;
  public
    UlogovaniUser: Integer; // Ovde Login forma upisuje ID klijenta pri ulazu
  end;

var
  Form6: TForm6;

implementation

uses Detalji, pocetna, PonudeKlijenta; // <-- AKO TI SE CRVENI FORM2, ovde umesto Form2Unit upiši tačan naziv Unita tvoje Login/Glavne forme

{$R *.fmx}

procedure TForm6.FormCreate(Sender: TObject);
begin
  LayoutZvonce.Align := TAlignLayout.None;

  // Pozicioniramo CELO ZVONCE u gornji desni ugao forme
  LayoutZvonce.Position.X := Self.Width - LayoutZvonce.Width - 25;
  LayoutZvonce.Position.Y := 10;

  // Podešavamo sidra kroz kod da prati desnu ivicu ako se forma širi
  LayoutZvonce.Anchors := [TAnchorKind.akTop, TAnchorKind.akRight];

  PravougaonikZvonce.Position.X := 22;
  PravougaonikZvonce.Position.Y := -2;

  PravougaonikZvonce.BringToFront;
  Position := TFormPosition.Designed;

  if LastFormX <> -1 then
  begin
    Left := Round(LastFormX);
    Top := Round(LastFormY);
  end;
end;

procedure TForm6.FormShow(Sender: TObject);
var
  BrojPonuda: Integer;
begin
  try
    // Povezujemo Query sa postojećom konekcijom sa Form8
    ADOQuery1.Connection := Form8.ADOConnection1;

    // --- 1. KORAK: Pronalazimo firmu na osnovu ulogovanog e-maila ---
    ADOQuery1.Close;
    ADOQuery1.SQL.Clear;
    ADOQuery1.SQL.Add('SELECT * FROM Klijenti WHERE LoginID = :LoginID');
    ADOQuery1.Parameters.ParamByName('LoginID').Value := UlogovaniUser;
    ADOQuery1.Open;

    if not ADOQuery1.IsEmpty then
    begin
      PraviIDKlijenta := ADOQuery1.FieldByName('IDKlijenta').AsInteger;

      // Popunjavamo tekstualna polja na interfejsu
      txtNazivFirme.Text := ADOQuery1.FieldByName('nazivKlijenta').AsString;
      txtImeKorisnika.Text := ADOQuery1.FieldByName('kontaktOsoba').AsString;
      txtPIB.Text := 'PIB: ' + ADOQuery1.FieldByName('PIB').AsString;
      txtAdresa.Text := ADOQuery1.FieldByName('adresa').AsString;
      txtEmail.Text := ADOQuery1.FieldByName('email').AsString;
      txtBrojTelefona.Text := ADOQuery1.FieldByName('telefon').AsString;
    end
    else
    begin
      ShowMessage('Greška: Nisu pronađeni korisnički podaci za nalog.');
      Exit;
    end;
    ADOQuery1.Close;
    ADOQuery1.SQL.Clear;
    ADOQuery1.SQL.Add('SELECT COUNT(*) AS UkupnoNovih FROM Ponude p ');
    ADOQuery1.SQL.Add('INNER JOIN Zahtevi z ON p.ZahtevID = z.[ID zahteva] ');
    ADOQuery1.SQL.Add('WHERE z.KlijentID = :KlijentID AND p.StatusID = 3');
    ADOQuery1.Parameters.ParamByName('KlijentID').Value := PraviIDKlijenta;
    ADOQuery1.Open;

    BrojPonuda := ADOQuery1.FieldByName('UkupnoNovih').AsInteger;

    if BrojPonuda > 0 then
    begin
      Label1.Text := IntToStr(BrojPonuda);
      PravougaonikZvonce.Visible := True;

      PravougaonikZvonce.BringToFront;
      Label1.BringToFront;
    end
    else
    begin
      PravougaonikZvonce.Visible := False;
    end;

  except
    on E: Exception do
      ShowMessage('Greška pri učitavanju: ' + E.Message);
  end;
end;

procedure TForm6.SpeedButton1Click(Sender: TObject);
begin
  if Assigned(Form2) then
    Form2.Show;
  Self.Hide;
end;

procedure TForm6.dugmePonudeClick(Sender: TObject);
begin
  Form11.KlijentID := PraviIDKlijenta;
  Form11.Left := Self.Left;
  Form11.Top := Self.Top;
  Form11.Width := Self.Width;
  Form11.Height := Self.Height;
  Form11.Show;
  Self.Hide;

end;

procedure TForm6.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LastFormX := Left;
  LastFormY := Top;
end;

procedure TForm6.ZvonceClick(Sender: TObject);
begin
  Form11.KlijentID := PraviIDKlijenta;
  Form11.Left := Self.Left;
  Form11.Top := Self.Top;
  Form11.Width := Self.Width;
  Form11.Height := Self.Height;
  Form11.Show;
  Self.Hide;
end;

end.
