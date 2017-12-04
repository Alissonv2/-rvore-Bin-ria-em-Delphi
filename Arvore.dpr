//Insercao, Remocao e Vizualizacao na ABB
//Definicao de Nos Folhas
program Arvore;

uses
  Forms,
  UPrincipal in 'UPrincipal.pas' {FPrincipal},
  USobre in 'USobre.pas' {FSobre};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'ABB';
  Application.CreateForm(TFPrincipal, FPrincipal);
  Application.CreateForm(TFSobre, FSobre);
  Application.Run;
end.
