unit UPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Buttons, Menus, ImgList, XPMan;

type
  elem=string;
  ArvB=^No;
  No=record
  esq: ArvB;
  chave: Elem;
  dir: ArvB;
  alt: Integer;
  niv: Integer;
end;


type
  TFPrincipal = class(TForm)
    EdtValor: TEdit;
    Panel1: TPanel;
    Tela: TImage;
    BtEsquerda: TBitBtn;
    BtDireita: TBitBtn;
    BtCima: TBitBtn;
    BtBaixo: TBitBtn;
    MainMenu1: TMainMenu;
    Sobre1: TMenuItem;
    Novo1: TMenuItem;
    Novo2: TMenuItem;
    LbAltura: TLabel;
    BtInserir: TBitBtn;
    BtRemover: TBitBtn;
    BtConsultar: TBitBtn;
    Sair1: TMenuItem;
    XPManifest1: TXPManifest;
    LimparArvore: TButton;
    procedure BtInserirClick(Sender: TObject);
    procedure BtConsultarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtRemoverClick(Sender: TObject);
    procedure BtDireitaClick(Sender: TObject);
    procedure BtEsquerdaClick(Sender: TObject);
    procedure BtCimaClick(Sender: TObject);
    procedure BtBaixoClick(Sender: TObject);
    procedure Novo2Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Sobre1Click(Sender: TObject);
    procedure Sair1Click(Sender: TObject);
    procedure LimparArvoreClick(Sender: TObject);
  private
    { Private declarations }
    //Declarando procedimentos locais
    procedure Inserir(var t: ArvB; x: Elem);
    procedure Remover(out t: ArvB; x: integer);
    function RemoverMenorValor(out t: ArvB): ArvB;
    procedure Consulta(var t: ArvB; x: Elem);
    procedure Imprimir(var t: ArvB; nivel,linha: integer);
    procedure CalculaAltura(out t: ArvB);
    procedure CalculaNivel(out t: ArvB; Niv: integer);
    function BuscarFolha(x: String): Boolean;
    procedure Zerar;
    function ValidaEdit(Edit: TEdit): boolean;
    procedure LimparDesenho;
    procedure ChamaImpressao;
    procedure DesabilitaBotoes;
    procedure HabilitaBotoes;

  public
    { Public declarations }
  end;

//Vari�veis globais
var
  t:ArvB;
  coluna,linha,alttotal,contfolha: integer;
  ListaFolha: Array [1..50] of String;
  EstrBinaria, Cheia, Completa: boolean;
  UltNivel: integer;
  Niv: integer;

var
  FPrincipal: TFPrincipal;

implementation

uses USobre;


{$R *.dfm}

//Procedimento de Inser��o na �rvore
procedure TFPrincipal.inserir(var t: ArvB; x: Elem);
begin
    //Se o no for nulo
    If t=nil
    Then Begin
            new(t);
            //Atribui valor de x para a chave do No
            t^.chave:=x;
            t^.esq:=nil;
            t^.dir:=nil;
    End
    Else If  x=t^.chave
         Then MessageDlg('O elemento '+x+' j� est� na arvore!',mtinformation,[mbok],0)
         Else If strtoint(x)<strtoint(t^.chave)
              Then inserir(t^.esq,x)
              Else inserir(t^.dir,x);
end;

//Procedimento a busca de um elemento na �rvore
procedure TFPrincipal.Consulta(var t: ArvB; x: Elem);
begin
    If t=nil
    Then MessageDlg('O elemento '+x+' n�o foi encontrado!',mtWarning,[mbok],0)
    Else If x=t^.chave
         //Elemento encontrado no No atual
         Then MessageDlg('O elemento '+t^.chave+' foi encontrado!',mtinformation,[mbok],0)
         Else //Elemento encontrado numa das sub-arvores
              If x<t^.chave
              Then Begin
                      Consulta(t^.esq, X);
              End
              Else Begin
                      Consulta(t^.dir, X);
              End;
end;

procedure TFPrincipal.BtInserirClick(Sender: TObject);
begin
    If not ValidaEdit(EdtValor)
    Then exit;

    //Se a tela n�o tiver vis�vel, ent�o fica vis�vel
    If Tela.Visible=false
    Then Tela.Visible:=true;

    //Insere o No e reimprime a �rvore
    Inserir(t,EdtValor.Text);
    EdtValor.Clear;
    EdtValor.SetFocus;
    ChamaImpressao;
    LbAltura.Caption:='Altura da �rvore: '+inttostr(t^.alt);
    
    //Chama procedimento pra habilitar bot�es de seta
    HabilitaBotoes;
end;

procedure TFPrincipal.BtConsultarClick(Sender: TObject);
begin
    If not ValidaEdit(EdtValor)
    Then exit;

    //Chama procedimento de consulta, passando a �rvore
    //e o valor a ser consultado
    Consulta(t,EdtValor.text);
end;

//Procedimento de Impress�o da �rvore na tela com Pos Ordem
procedure TFPrincipal.Imprimir(var t: ArvB; nivel,linha: integer);
var OldBkMode: integer;
begin
    If t=nil
    Then exit;

    //Verificando Nos Folhas
    If (t^.esq=nil) and (t^.dir=nil)
    Then Begin
            If BuscarFolha(t^.chave)=false
            Then Begin
                    ListaFolha[contfolha]:=t^.chave;
                    Inc(contfolha,1);
            End;
    End;

    //Varre sub-arvore esquerda
    Imprimir(t^.esq,nivel-30,linha+30) ;

    //Varre sub-arvore direita
    Imprimir(t^.dir,nivel+30,linha+30) ;

    //Chama procedimento para calcular altura do No
    CalculaAltura(t);

    //Imprimi na tela (TImage)
    With Tela.Canvas do
    Begin
        Pen.Width:=2;
        //Imprimir linha
        //Se tiver filho esquerdo, entao aumenta a linha do pai pro filho esquerdo
        If t^.esq<>nil
        Then Begin
                MoveTo(nivel+15,linha+60);
                LineTo(nivel-20,linha+60);
        End;
        //Se tiver filho direito, ent�o aumenta a linha do pai pro filho direito
        If t^.dir<>nil
        Then Begin
                MoveTo(nivel+40,linha+60);
                LineTo(nivel+15,linha+60);
        End;
        //Imprimir circulo
        Brush.Style:=bsSolid;
        Brush.Color:=clMoneyGreen;
        Ellipse(nivel,linha+30,nivel+30,linha+60);
        //Imprimir texto
        OldBkMode:=SetBkMode(Handle,TRANSPARENT);
        Font.Color:=clblue;
        TextOut(nivel+4,linha+30+8,t^.chave);
    End;



end;

procedure TFPrincipal.FormShow(Sender: TObject);
begin
    //Inicializando vari�veis ao abrir programa principal
    t:=nil;
    coluna:=230;
    linha:=0;
    LbAltura.Caption:='';
    Zerar;
end;

procedure TFPrincipal.BtRemoverClick(Sender: TObject);
begin
    If not ValidaEdit(EdtValor)
    Then exit;

    //Remove o No
    Remover(t,strtoint(EdtValor.text));
    EdtValor.Clear;
    EdtValor.SetFocus;
    //Reimprime a arvore
    ChamaImpressao;
    //Atualiza Label com altura atual da arvore
    If T<>nil
    Then LbAltura.Caption:='Altura da �rvore: '+inttostr(t^.alt)
    Else LbAltura.Caption:='';
end;

//Procedimento de Remo��o na �rvore
procedure TFPrincipal.Remover(out t: ArvB; x: integer);
var temp: ArvB;
begin
    If t=nil
    Then MessageDlg('O elemento '+inttostr(x)+' n�o foi encontrado para remo��o!',mtinformation,[mbok],0)
    Else If x<strtoint(t^.chave)
         //Busca a esquerda
         Then Remover(t^.esq,x)
         Else If x>strtoint(t^.chave)
              //Busca a direita
              Then Remover(t^.dir,x)
              Else Begin
                      temp:=t;
                      //Existe somente um filho a direita
                      If t^.esq=nil
                      //Aponta para direita
                      Then t:=t.dir
                      Else
                      //Existe somente um filho a esquerda
                      If t^.dir=nil
                      //Aponta para esquerda
                      Then t:=t.esq
                      Else Begin
                              //O No possui dois filhos
                              temp:=removerMenorValor(t^.dir);
                              t^.chave:=temp^.chave;
                      End;
                      //Desaloca temp
                      FreeMem(temp,SizeOf(ArvB));
              End;
End;

//Funcao que retorna menor valor a ser removido
function TFPrincipal.RemoverMenorValor(out t: ArvB): ArvB;
var temp: ^ArvB;
begin
  If t^.esq<>nil
	Then result:=RemoverMenorValor(t^.esq)
	Else Begin
          temp^:=t;
          t:=t.dir;
          result:=temp^;
	End;
end;

//Funcao para Limpar �rvore da Tela
procedure TFPrincipal.LimparDesenho;
begin
    With Tela.Canvas do
    Begin
        //Desenhando um Ret�ngulo branco em toda a tela
        Brush.Color :=clWhite;
        Rectangle(0, 0, tela.width, tela.Height);
    End;
end;

procedure TFPrincipal.ChamaImpressao;
begin
    //Limpar e depois imprimir
    LimparDesenho;

    Zerar;
    Niv:=1;

    CalculaNivel(t,Niv);
    Imprimir(t,coluna,linha);

    alttotal:=t^.alt;

end;

procedure TFPrincipal.BtDireitaClick(Sender: TObject);
begin
    //Simula rolagem para direita
    coluna:=coluna-10;
    ChamaImpressao;
end;

procedure TFPrincipal.BtEsquerdaClick(Sender: TObject);
begin
    //Simula rolagem para esquerda
    coluna:=coluna+10;
    ChamaImpressao;
end;

procedure TFPrincipal.BtCimaClick(Sender: TObject);
begin
    //Simula rolagem para cima
    linha:=linha+10;
    ChamaImpressao;
end;

procedure TFPrincipal.BtBaixoClick(Sender: TObject);
begin
    //Simula rolagem para baixo
    linha:=linha-10;
    ChamaImpressao;
end;

procedure TFPrincipal.Novo2Click(Sender: TObject);
begin
    //Desaloca o n� t da mem�ria utilizando a fun��o FreeMen,
    //passando por parametro o tamanho(tipo) do No a ser desalocado
    FreeMem(t,SizeOf(ArvB));
    t:=nil;
    coluna:=230;
    linha:=0;
    LimparDesenho;
    //Alterando propriedades dos objetos
    //para comecar uma nova �rvore
    Tela.Visible:=false;
    EdtValor.Clear;
    EdtValor.SetFocus;
    LbAltura.Caption:='';
    Zerar;

    //Chama procedimento pra desabilitar botoes de seta
    DesabilitaBotoes;
end;

//Funcao que faz a valida��o do valor digitado pelo usu�rio
function TFPrincipal.ValidaEdit(Edit: TEdit): boolean;
begin
    result:=false;
    //Tenta transformar de string para inteiro, se der
    //erro, retorna falso
    Try
        strtoint(Edit.Text);
    Except
        MessageDlg('Valor Inv�lido',mterror,[mbok],0);
        Edit.Clear;
        Edit.SetFocus;
        exit;
    End;
    result:=true;
end;

//Faz o calculo da altura do No e armazena no campo Alt do seu registro
procedure TFPrincipal.CalculaAltura(out t: ArvB);
var alte, altd: integer;
begin
    If t^.esq<>nil
    Then alte:=t^.esq.alt
    Else alte:=0;

    If t^.dir<>nil
    Then altd:=t^.dir.alt
    Else altd:=0;

    If alte>altd
    Then t^.alt:=alte+1
    Else t^.alt:=altd+1;
end;

procedure TFPrincipal.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    //Verifica se tecla digitada � uma seta pra
    //qualquer lado, se for, chama procedimento
    //do botao conforme seu lado
    If Key=VK_DOWN
    Then BtBaixo.OnClick(Sender)
    Else If Key=VK_UP
         Then BtCima.OnClick(Sender)
         Else If Key=VK_LEFT
              Then BtEsquerda.OnClick(Sender)
              Else If Key=VK_RIGHT
                   Then BtDireita.OnClick(Sender);
end;

//Procedimento que desabilita botoes de seta
procedure TFPrincipal.DesabilitaBotoes;
begin
    BtEsquerda.Visible:=false;
    BtDireita.Visible:=false;
    BtCima.Visible:=false;
    BtBaixo.Visible:=false;
end;

procedure TFPrincipal.HabilitaBotoes;
begin
    BtEsquerda.Visible:=true;
    BtDireita.Visible:=true;
    BtCima.Visible:=true;
    BtBaixo.Visible:=true;
end;

procedure TFPrincipal.Sobre1Click(Sender: TObject);
begin
    FSobre.ShowModal;
end;

procedure TFPrincipal.Sair1Click(Sender: TObject);
begin
    close;
end;

procedure TFPrincipal.Zerar;
var cont: integer;
begin
    For cont:=1 to 50 do
        ListaFolha[cont]:='';
    EstrBinaria:=true;
    Cheia:=true;
    Completa:=true;
    UltNivel:=0;
    contfolha:=1;
end;

function TFPrincipal.BuscarFolha(x: String): boolean;
var cont: integer;
begin
    result:=false;
    For cont:=1 to 50 do
    Begin
        If x=ListaFolha[cont]
        Then Begin
                result:=true;
                exit;
        End;
    End;
end;
procedure TFPrincipal.CalculaNivel(out t: ArvB; Niv: integer);
begin
    If t=nil
    Then exit;

    t^.niv:=niv;

    If t^.niv>UltNivel
    Then UltNivel:=t^.niv;

    //Varre sub-arvore esquerda
    CalculaNivel(t^.esq,Niv+1);

    //Varre sub-arvore direita
    CalculaNivel(t^.dir,Niv+1);
end;

procedure TFPrincipal.LimparArvoreClick(Sender: TObject);
begin

    FreeMem(t,SizeOf(ArvB));
    t:=nil;
    coluna:=230;
    linha:=0;
    LimparDesenho;
    //Alterando propriedades dos objetos
    //para comecar uma nova �rvore
    Tela.Visible:=false;
    EdtValor.Clear;
    EdtValor.SetFocus;
    LbAltura.Caption:='';
    Zerar;
    showmessage('�rvore zerada com sucesso.');

end;

end.

