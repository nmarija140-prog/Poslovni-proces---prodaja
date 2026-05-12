unit NoviZahtev;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Memo.Types, FMX.ScrollBox,
  FMX.Memo, FMX.Edit, FMX.Layouts, FMX.ListBox, Data.DB, Data.Win.ADODB,
  Data.FMTBcd, Data.SqlExpr, NovKlijent;

type
  TForm9 = class(TForm)
    dodajKlijentaDugme: TSpeedButton;
    datUtovaraDugme: TEdit;
    vrstaRobeDugme: TEdit;
    kolicinaDugme: TEdit;
    datIstovaraDugme: TEdit;
    mestoIstovaraDugme: TEdit;
    mestoUtovaraDugme: TEdit;
    MemoNapomena: TMemo;
    sacuvajZahtevDugme: TButton;
    otkaziDugme: TButton;
    EditKlijent: TEdit;
    ListKlijenti: TListBox;
    ADOQuery1: TADOQuery;
    ADOConnection1: TADOConnection;
    procedure EditKlijentChange(Sender: TObject);
     procedure FormCreate(Sender: TObject);
  procedure FormClose(Sender: TObject; var Action: TCloseAction);
  procedure ListKlijentiClick(Sender: TObject);
    procedure dodajKlijentaDugmeClick(Sender: TObject);
procedure MemoNapomenaEnter(Sender: TObject);
procedure MemoNapomenaExit(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form9: TForm9;

implementation

{$R *.fmx}

procedure TForm9.FormCreate(Sender: TObject);
var
  dbPath: string;
begin
  MemoNapomena.Text := 'Napomena';

  ListKlijenti.Visible := False;

  dbPath := ExtractFilePath(ParamStr(0)) + 'mpmBaza.mdb';

  if not FileExists(dbPath) then
  begin
    ShowMessage('Baza ne postoji na lokaciji: ' + dbPath);
    Exit;
  end;

  try
    ADOConnection1.ConnectionString :=
      'Provider=Microsoft.ACE.OLEDB.12.0;' +
      'Data Source=' + dbPath + ';';

    ADOConnection1.LoginPrompt := False;
    ADOConnection1.Connected := True;

  except
    on E: Exception do
    begin
      ShowMessage('Greška pri konekciji sa bazom: ' + E.Message);
      Exit;
    end;
  end;
end;

procedure TForm9.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
    ADOQuery1.Close;
    ADOConnection1.Connected := False;
  except
  end;
end;
procedure TForm9.dodajKlijentaDugmeClick(Sender: TObject);
begin
Form10.Show;
end;

procedure TForm9.EditKlijentChange(Sender: TObject);
begin
  if Trim(EditKlijent.Text) = '' then
  begin
    ListKlijenti.Visible := False;
    Exit;
  end;

  ADOQuery1.Close;
  ADOQuery1.SQL.Text :=
    'SELECT nazivKlijenta FROM klijenti ' +
    'WHERE nazivKlijenta LIKE :naziv';

  ADOQuery1.Parameters.ParamByName('naziv').Value :=
    EditKlijent.Text + '%';

  ADOQuery1.Open;

  ListKlijenti.Clear;

  if ADOQuery1.IsEmpty then
  begin
    ListKlijenti.Items.Add('Nema klijenta');
    ListKlijenti.Visible := True;
    Exit;
  end;

  while not ADOQuery1.Eof do
  begin
    ListKlijenti.Items.Add(
      ADOQuery1.FieldByName('nazivKlijenta').AsString
    );
    ADOQuery1.Next;
  end;

  ListKlijenti.Visible := True;
  ListKlijenti.BringToFront;
end;
procedure TForm9.ListKlijentiClick(Sender: TObject);
begin
  if ListKlijenti.ItemIndex < 0 then Exit;

  EditKlijent.Text := ListKlijenti.Items[ListKlijenti.ItemIndex];
  ListKlijenti.Visible := False;
end;
procedure TForm9.MemoNapomenaEnter(Sender: TObject);
begin
  if MemoNapomena.Text = 'Napomena' then
  begin
    MemoNapomena.Text := '';
  end;
end;

procedure TForm9.MemoNapomenaExit(Sender: TObject);
begin
  if Trim(MemoNapomena.Text) = '' then
  begin
    MemoNapomena.Text := 'Napomena';
  end;
end;


end.
