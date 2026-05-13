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
    ADOQuery1: TADOQuery;
    ADOConnection1: TADOConnection;
    EditSearch: TEdit;
    ListaKlijenata: TListBox;
     procedure FormCreate(Sender: TObject);
     procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dodajKlijentaDugmeClick(Sender: TObject);
    procedure EditSearchChangeTracking(Sender: TObject);
    procedure ListaKlijenataItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
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
MemoNapomena.ShowHint := True;
MemoNapomena.Hint := 'Napomena';
Position := TFormPosition.DefaultPosOnly;
ListaKlijenata.Width := EditSearch.Width;
ListaKlijenata.Height := 150;

ListaKlijenata.Position.X := EditSearch.Position.X;

ListaKlijenata.Position.Y :=
  EditSearch.Position.Y + EditSearch.Height;

ListaKlijenata.BringToFront;
ListaKlijenata.Visible := False;
  dbPath := ExtractFilePath(ParamStr(0)) + 'mpmBaza.mdb';
  if not FileExists(dbPath) then
  begin
    ShowMessage('Baza ne postoji na lokaciji: ' + dbPath);
    Exit;
  end;
  try
    ADOConnection1.ConnectionString :=
      'Provider=Microsoft.Jet.OLEDB.4.0;'+
      'Data Source=' + dbPath + ';';
    ADOConnection1.Connected := True;
  except
    on E: Exception do
    begin
      ShowMessage('Greška pri konekciji sa bazom: ' + E.Message);
      Exit;
    end;
  end;
end;
procedure TForm9.ListaKlijenataItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
 EditSearch.Text := Item.Text;

  ListaKlijenata.Visible := False;
end;

procedure TForm9.EditSearchChangeTracking(Sender: TObject);
begin
  if Trim(EditSearch.Text) = '' then
  begin
    ListaKlijenata.Visible := False;
    Exit;
  end;

  ADOQuery1.Close;
  ADOQuery1.SQL.Clear;
  ADOQuery1.SQL.Text :=
    'SELECT nazivKlijenta FROM Klijenti ' +
    'WHERE nazivKlijenta LIKE :p ' +
    'ORDER BY nazivKlijenta';
  ADOQuery1.Parameters.ParamByName('p').Value :=
    EditSearch.Text + '%';

  ADOQuery1.Open;

  ListaKlijenata.Clear;
  while not ADOQuery1.Eof do
  begin
    ListaKlijenata.Items.Add(
      ADOQuery1.FieldByName('nazivKlijenta').AsString
    );

    ADOQuery1.Next;
  end;

  ListaKlijenata.Visible := ListaKlijenata.Items.Count > 0;
  ListaKlijenata.Height :=
  ListaKlijenata.Items.Count * 35;
  if ListaKlijenata.Height > 150 then
  ListaKlijenata.Height := 150;
   ListaKlijenata.BringToFront;
end;
procedure TForm9.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
    if ADOQuery1.Active then
      ADOQuery1.Close;

    if ADOConnection1.Connected then
      ADOConnection1.Connected := False;

  except
  end;
end;
procedure TForm9.dodajKlijentaDugmeClick(Sender: TObject);
begin
Form10.Show;
end;

end.
