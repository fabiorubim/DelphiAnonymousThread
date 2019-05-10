unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.Comp.DataSet;

type
  TMinhaThread = class(TThread)
  procedure Execute; override;
  end;


  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    memCliente: TFDMemTable;
    memClienteId: TIntegerField;
    memClienteNome: TStringField;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    procedure FinalizarThread(Sender: TObject);
    procedure ExecutarThread(const a: Integer; const b: string);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{ TMinhaThread }

procedure TMinhaThread.Execute; //Mais completo
begin
  inherited;
  //Código da thread
end;

//Coisas simples que precisam ser execuadas em parelelo
procedure TForm1.Button1Click(Sender: TObject);
var
  LThread : TThread;
  I: Integer;
begin
  LThread:= TThread.CreateAnonymousThread(
    procedure
    begin
      Sleep(5000);

      // Isto pode ser um problema, pois a thread principal pode tentar alterar algo na interface e ao mesmo tempo está thread pode fazer o mesmo
      //Form1.Button1.Caption := 'Trocando o texto';
      //O correto é utilizar o Syncronize. A execução dele é imediata, para o método para ser executado.
      //Dois parâmetros: o primeiro é a thread. Pode ser 'nil', só será problema se houver um monitoramento da thread
      //Caso contrário utilize TThread.Current
      //O segundo parâmetro é uma procedure do tipo TObject
      TThread.Synchronize(TThread.Current,
                          FinalizarThread);

      //Outro modo de sincronizar uma thread com a thread principal é utilizando o TThread.Queue
      //O Queue depende do SO, no seu escalonamento.
      //Utilizar em um progressbar, não tem problema em um pequeno atraso neste caso.
      //Ele é mais leve em sua execução
      TThread.Queue(TThread.Current,
                    FinalizarThread);

    end); // .start ou utilizando a variável - LThread

    LThread.OnTerminate := FinalizarThread;
    LThread.Start;
    //Precisa sempre inciar, pois no Create está como false, pois é criada como suspensa
    //Seu free é definido como true

    //Threads com banco de dados - O correto é:
//    LThread:= TThread.CreateAnonymousThread(
//    procedure
//    var
//      con: TFDConnection;
//      qry: TFDQuery;
//    begin
//      //Tomar cuidado ao lidar com o uso de conexões e querys dentro de Threads, pois podem ocorrer inconsistências
//      //O ideial é que as conexões e as querys fiquem "dentro" da Thread, não que sejam utilizadas por "fora".
//      con:= TFDConnection.Create();
//      con.Params.Text := DM.Con.Params.Text;
//
//      qry := TFDQuery.Create;
//      qry.Connection := con;
//    end);
//    LThread.OnTerminate := FinalizarThread;
//    LThread.Start;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  memCliente.First;
  while not memCliente.Eof do
  begin
    ExecutarThread(memClienteId.AsInteger, memClienteNome.AsString);
    memCliente.Next;
  end;
  memCliente.Close;
end;

procedure TForm1.ExecutarThread(const a: Integer; const b: string);
var
  AA : Integer;
  BB : String;
  Resultado: String;
begin
  AA := a;
  BB := b;
  TThread.CreateAnonymousThread(procedure
                                begin
                                  Resultado:=  BB + '' + AA.ToString
                                end).Start;
end;

procedure TForm1.FinalizarThread(Sender: TObject); //Precisa do sender
var
  teste : real;
begin
  //código ao finalizar a thread
  //ShowMessage('Terminou');
  teste:= 10000*33333333333* Random(500);
end;

end.

