unit DBEditCalendario;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, mask, DBCtrls, Buttons;

type

  tValidarData = procedure (Sender: tObject) of Object;
  tErroValidar = procedure (Sender: tObject) of Object;

  TDBEdit_Calendario = class(TDBEdit)
  private
    { Private declarations }
    Botao: TBitBtn;
    Calend: TMonthCalendar;
    tela: TForm;
    fformat: String;
    fValidarData: tValidarData;
    fAoErroValidar: tErroValidar;
    procedure Clicar(sender: TObject);
    procedure DblClicar(sender: TObject);
    procedure Clicar_Calend(sender: TObject);
    procedure setformato(const Value: String);
    procedure fechar_tela_calendar(Sender: TObject; var Action: TCloseAction);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor create (dono: tcomponent); override;
    procedure resize; override;
    procedure RePaint; override;
    procedure KeyPress (var Key: char); override;
    procedure DoExit; override;
    procedure Change; override;
  published
    { Published declarations }
    Property Formato_Data: String read fformat write setformato;

    //Eventos
    property AoValidarData: tValidarData read fValidarData write fValidarData;
    property AoErroValidar: tErroValidar read fAoErroValidar write fAoErroValidar;

    Property Font;
    Property TabOrder;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Beleza', [TDBEdit_Calendario]);
end;

{ TDBEdit_Calendario }

procedure TDBEdit_Calendario.Clicar(sender: TObject);
begin

  //Abrir form com Calendario
  if tela <> nil then exit;

  Tela        := TForm.Create(Self);
  Tela.Width  := 169;
  Tela.Height := 127;

  //Verificar se cabe na tela abrir o
  //relatorio a direita do mouse
  {if mouse.Cursorpos.x + Tela.Width > Screen.Width then
    Tela.Left := (mouse.Cursorpos.x - Tela.Width)
  else Tela.Left := mouse.Cursorpos.x;

  //Verificar se cabe na tela abrir o
  //relatorio abaixo do mouse
  if mouse.Cursorpos.y + Tela.Height > Screen.Height then
    Tela.Top := (mouse.Cursorpos.y - Tela.Height)
  else Tela.Top := mouse.Cursorpos.y;
  }
  tela.Top  := 10;
  tela.Left := 10;

  showmessage(inttostr(mouse.Cursorpos.x)+' '+inttostr(tela.left));

  Tela.BorderStyle  := bsSingle;
  Tela.FormStyle    := fsStayOnTop;
  Tela.OnClose      := fechar_tela_calendar;

  Calend            := TMonthCalendar.create(self);
  Calend.OnDBlClick := Clicar_Calend;
  Calend.Hint       := 'Duplo clique para Selecionar a Data';
  Calend.ShowHint   := true;
  Calend.Font.Name  := 'Arial';
  Calend.Font.Size  := 7;
  Calend.CalColors.BackColor        := clwindow;
  Calend.CalColors.MonthBackColor   := $00E1FFFF;
  Calend.CalColors.TextColor        := clWindowText;
  Calend.CalColors.TitleBackColor   := $00BF8200;
  Calend.CalColors.TitleTextColor   := clWhite;
  Calend.CalColors.TrailingTextColor:= clGray;
  Calend.ShowToday                  := False;
  Calend.AutoSize                   := True;
  Calend.Parent                     := tela;
  Calend.Show;

  Tela.Show;

end;

constructor TDBEdit_Calendario.create(dono: tcomponent);
begin
  inherited;

  Botao           := TBitbtn.Create(self);
  Botao.Width     := 22;
  Botao.Left      := Width - 26;
  Botao.Height    := Height - 4;
  Botao.OnClick   := Clicar;
  Botao.Font.Name := 'Arial';
  Botao.Font.Size := 7;
  Botao.Caption   := '15';
  botao.hint      := 'Clique aqui para Calendario';
  botao.ShowHint  := true;
  Botao.TabStop   := False;
  Botao.parent    := self;

  text            := '';
  formato_data    := 'dd/mm/yy';
  EditMask        := '##/##/##';
  MaxLength       := length(Formato_Data);
  Width           := 110;
  OnDblClick      := DblClicar;
  Hint            := 'Duplo Clique para Buscar a data de hoje!';
  ShowHint        := True;

end;

procedure TDBEdit_Calendario.Clicar_Calend(sender: TObject);
begin

  // Verifica se deu 2 cliques na barra superior do calendario
  if mouse.CursorPos.y > tform(Calend.parent).Top + 30 then
  begin
      Text                                                 := FormatDateTime(formato_data, Calend.Date);
      DataSource.DataSet.FieldByName(DataField).AsDateTime := Calend.Date;
      TForm(Calend.parent).Close;
      Setfocus;
  end;

end;

procedure TDBEdit_Calendario.RePaint;
begin
  inherited;
  Botao.Update;
end;

procedure TDBEdit_Calendario.resize;
begin
  inherited;

  Botao.Width  := 22;
  Botao.Left   := Width - 26;
  Botao.Height := Height - 4;
  Botao.Update;

end;

procedure TDBEdit_Calendario.setformato(const Value: String);
begin
  fformat   := Value;
  MaxLength := length(Formato_Data);
end;

procedure TDBEdit_Calendario.KeyPress(var Key: char);
begin
  inherited;

end;

procedure TDBEdit_Calendario.fechar_tela_calendar(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
  tela   := nil;
end;

procedure TDBEdit_Calendario.DoExit;
begin
  inherited;

  // Validar Data
  if (Trim(Text) = '/  /') or (Trim(Text) = '') then
      Exit;

  try

      // Verificar Evento AoValidarData
      if Assigned(fValidarData) then
          AoValidarData(self);

      StrToDate(Text);
  Except
      Setfocus;

      // Verificar Evento AoErroValidar
      if Assigned(fAoErroValidar) then
          AoErroValidar(self);

      ShowMessage('Data inserida � Inv�lida!');
  end;

  if tela <> nil then
      tela.Close;

end;

procedure TDBEdit_Calendario.Change;
begin
  inherited;
  botao.Repaint;
end;

procedure TDBEdit_Calendario.DblClicar(sender: TObject);
begin
  Text                                                 := FormatDateTime(formato_data, Date);
  DataSource.DataSet.FieldByName(DataField).AsDateTime := Date;

  if tela <> Nil then Tela.Close;
end;

end.
