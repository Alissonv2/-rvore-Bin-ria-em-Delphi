unit USobre;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TFSobre = class(TForm)
    Panel1: TPanel;
    ProgramIcon: TImage;
    Version: TLabel;
    Copyright: TLabel;
    Comments: TLabel;
    OKButton: TButton;
    Label4: TLabel;
    Label1: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FSobre: TFSobre;

implementation

{$R *.dfm}

end.
 
